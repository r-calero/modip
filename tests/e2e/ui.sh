#!/bin/bash
# Layout, flash messages, structure images, 3D pose viewer, energy chart.
# Run after security.sh and docking.sh on the same stack. With Google Chrome
# installed (CHROME=path), the viewer and the chart are also run in a
# headless browser.
. "$(dirname "$0")/lib.sh"
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}

TID=$(sql "select id from targets where name='Test target'"); RT=$(sql "select id from receptor_types where name='HIV protease'")
CID=$(sql "select c.cid from compounds c join receptor_compounds rc on rc.compound_id=c.id order by rc.value limit 1")
COMP=$(sql "select id from compounds where cid='$CID'")
POSE=$(sql "select rc.path from receptor_compounds rc join compounds c on c.id=rc.compound_id where c.cid='$CID' limit 1")
ENC_POSE=$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$POSE")

section "Layout"
check "page title of a compound" "$(curl -s "$B/compounds/$COMP" | grep -o '<title>[^<]*' | sed 's/<title>//')" "CID $CID - MODIP"
check "Home is active on the home page" "$(curl -s "$B/" | grep -c '<li class="active"><a href="/">Home</a>')" "1"
check "Home is not active on other pages" "$(curl -s "$B/assays" | grep -c '<li class="active"><a href="/">Home</a>')" "0"
login fl alice wrong-password >/dev/null
check "flash message shown once" "$(curl -s -c "$T/fl" -b "$T/fl" "$B/login" | grep -o 'Invalid user/password combination\|Too many failed login attempts' | wc -l | tr -d ' ')" "1"
check "footer with the license" "$(curl -s "$B/" | grep -c 'GNU AGPL v3')" "1"

section "Compound and ranking pages"
H=$(curl -s "$B/compounds/$COMP")
check "2D structure from PubChem" "$(echo "$H" | grep -c "pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$CID/PNG")" "1"
check "docking results with a 3D link" "$(echo "$H" | grep -c 'View in 3D' | awk '{print ($1>0)?"yes":"no"}')" "yes"
H=$(curl -s "$B/users/$TID/compound_ranking/filter_one/$RT/filter_two/$RT/filter_tree/$RT")
check "ranking has 3D links" "$(echo "$H" | grep -c '>3D<' | awk '{print ($1>0)?"yes":"no"}')" "yes"
check "ranking has structure thumbnails" "$(echo "$H" | grep -c 'structure-image' | awk '{print ($1>0)?"yes":"no"}')" "yes"

section "3D pose viewer"
check "viewer page" "$(code g "$B/poses?path=$ENC_POSE" | cut -d' ' -f1)" "200"
curl -s "$B/poses/data?path=$ENC_POSE" > "$T/pose.json"
check "viewer data has the receptor" "$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print("ATOM" in d["receptor"])' "$T/pose.json")" "True"
check "viewer data has every pose model" "$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["pose"].count("ENDMDL"))' "$T/pose.json")" "$(sql "select count(*) from receptor_compounds where path='$POSE'")"
check "unknown pose path refused" "$(code g "$B/poses/data?path=/etc/passwd" | cut -d' ' -f2)" "$B/errors"
check "3Dmol.js served" "$(curl -s -o /dev/null -w '%{http_code}' "$B/javascripts/vendor/3Dmol-2.0.4.min.js")" "200"

section "Energy chart"
curl -s "$B/targets/$TID/energies.json" > "$T/energies.json"
check "chart data: one series per receptor type" "$(python3 -c 'import json,sys; print([s["name"] for s in json.load(open(sys.argv[1]))["series"]])' "$T/energies.json")" "['HIV protease']"
check "chart data: every docked compound counted once" "$(python3 -c 'import json,sys; print(sum(json.load(open(sys.argv[1]))["series"][0]["counts"]))' "$T/energies.json")" "$(sql "select count(distinct compound_id) from receptor_compounds")"
check "Chart.js served" "$(curl -s -o /dev/null -w '%{http_code}' "$B/javascripts/vendor/Chart-2.9.4.min.js")" "200"

if [ -x "$CHROME" ]; then
  section "In a headless browser (real page, recorded JSON)"
  # page_harness DIR URL JSON: local copy of a page whose $.getJSON returns JSON.
  page_harness() {
    mkdir -p "$1"; curl -s "$B$2" > "$1/raw.html"
    curl -s "$B$(grep -oE '/assets/application-[a-f0-9]+\.js' "$1/raw.html" | head -1)" > "$1/app.js"
    for js in 3Dmol-2.0.4.min.js Chart-2.9.4.min.js; do curl -s "$B/javascripts/vendor/$js" > "$1/$js"; done
    printf '$.getJSON = function () { var d = $.Deferred(); setTimeout(function () { d.resolve(%s); }, 10); return d.promise(); };\n' "$(cat "$3")" > "$1/fake.js"
    python3 - "$1" <<'PY'
import sys, re
d = sys.argv[1]
h = open(d + '/raw.html').read()
h = re.sub(r'<script src="/assets/application-[a-f0-9]+\.js"[^>]*></script>', '<script src="app.js"></script><script src="fake.js"></script>', h)
h = re.sub(r'<script src="/assets/[^"]+"[^>]*></script>', '', h)
h = re.sub(r'<link [^>]*stylesheet[^>]*>', '', h)
h = h.replace('/javascripts/vendor/', '')
open(d + '/index.html', 'w').write(h)
PY
    "$CHROME" --headless=new --no-first-run --allow-file-access-from-files --use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader \
      --user-data-dir="$1/profile" --virtual-time-budget=15000 --dump-dom "file://$1/index.html" 2>/dev/null > "$1/dom.html"
  }
  page_harness "$T/viewer" "/poses?path=$ENC_POSE" "$T/pose.json"
  check "viewer draws a WebGL canvas" "$(grep -c '<canvas' "$T/viewer/dom.html")" "1"
  check "viewer shows no load error (text only in the script)" "$(grep -o 'could not be loaded' "$T/viewer/dom.html" | wc -l | tr -d ' ')" "1"
  page_harness "$T/chart" "/targets/$TID" "$T/energies.json"
  check "chart is drawn" "$(grep -c '<canvas[^>]*chartjs-render-monitor' "$T/chart/dom.html")" "1"
  check "chart summary" "$(grep -o 'HIV protease: [0-9]* compounds, best -[0-9.]* kcal/mol' "$T/chart/dom.html" | wc -l | tr -d ' ')" "1"
fi

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
