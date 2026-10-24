#!/bin/bash
# Layout, flash messages, structure images, 3D pose viewer, energy chart,
# confirmation modal and colours of the docking progress bars.
# Run after security.sh and docking.sh on the same stack (conversion.sh adds
# a docking job with a compound left in 2D). With Google Chrome
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

section "Confirmations and docking bars"
AD=$(sql "select id from users where name='admin1'")
login admin1 admin1 "$PASSWORD" >/dev/null
A=$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/admin")
check "admin buttons use the confirmation modal (title on every data-confirm)" "$(echo "$A" | grep -o 'data-confirm=' | wc -l | tr -d ' ')" "$(echo "$A" | grep -o 'data-confirm-title=' | wc -l | tr -d ' ')"
check "delete links have no per-row modal" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/targets" | grep -c 'class="modal hide fade"')" "0"
check "delete links ask for confirmation" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/targets" | grep -c 'data-confirm-title="Delete a resource"' | awk '{print ($1>0)?"yes":"no"}')" "yes"
L=$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs")
for state in "finished:progress-success" "cancelled:progress-muted"; do
  J=$(sql "select id from docking_jobs where user_id=$AD and status='${state%%:*}' and skipped_compounds=0 order by id limit 1")
  check "job page: ${state%%:*} job bar is ${state#*:}" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$J" | grep -c "class=\"progress ${state#*:}\" id=\"job-progress\"")" "1"
done
J=$(sql "select id from docking_jobs where status='finished' and skipped_compounds>0 order by id limit 1")
if [ -n "$J" ]; then
  check "job page: compounds not docked turn the bar orange" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$J" | grep -c 'class="progress progress-warning" id="job-progress"')" "1"
  N=$(sql "select skipped_compounds from docking_jobs where id=$J")   # not inside the pipe: docker exec reads stdin
  check "job page: not docked compounds counted" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$J" | grep -c "$N not docked")" "1"
fi
check "jobs list: coloured bars" "$(echo "$L" | grep -c 'progress-success docking-progress' | awk '{print ($1>0)?"yes":"no"}')" "yes"

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
  # page_harness DIR URL JSON [JAR] [TEST_JS]: local copy of a page whose
  # $.getJSON returns JSON, optionally fetched with a cookie jar and with a
  # test script appended.
  page_harness() {
    mkdir -p "$1"; curl -s ${4:+-b "$T/$4"} "$B$2" > "$1/raw.html"
    curl -s "$B$(grep -oE '/assets/application-[a-f0-9]+\.js' "$1/raw.html" | head -1)" > "$1/app.js"
    for js in 3Dmol-2.0.4.min.js Chart-2.9.4.min.js; do curl -s "$B/javascripts/vendor/$js" > "$1/$js"; done
    printf '$.getJSON = function () { var d = $.Deferred(); setTimeout(function () { d.resolve(%s); }, 10); return d.promise(); };\n' "$(cat "$3")" > "$1/fake.js"
    [ -n "$5" ] && cat "$5" >> "$1/fake.js"
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

  # Confirmation modal on the admin page: Cancel sends nothing, the confirm
  # button sends the form, the browser's confirm() is never used.
  echo '{}' > "$T/empty.json"
  cat > "$T/confirm_test.js" <<'JS'
window.nativeConfirms = 0;
window.confirm = function () { window.nativeConfirms++; return false; };
$(function () {
  var sent = 0, button = $('input[data-confirm]').first(), shown = 0, title = '';
  $(document).on('submit', 'form', function (e) { e.preventDefault(); sent++; return false; });
  var step = function (f) { setTimeout(f, 800); };
  button.trigger('click');
  step(function () {
    shown = ($('#confirm-modal').data('modal') || {}).isShown ? 1 : 0;   // no CSS here: no 'in' class
    title = $('#confirm-modal-title').text() === button.data('confirm-title') ? 'title' : 'no-title';
    $('#confirm-modal-cancel').trigger('click');
    step(function () {
      var afterCancel = sent;
      button.trigger('click');
      step(function () {
        $('#confirm-modal-ok').trigger('click');
        step(function () { $('body').attr('data-confirm-test', [shown, title, afterCancel, sent, window.nativeConfirms].join(':')); });
      });
    });
  });
});
JS
  page_harness "$T/confirm" "/admin" "$T/empty.json" admin1 "$T/confirm_test.js"
  check "modal shown, Cancel sends nothing, OK sends once, no native confirm" "$(grep -oE 'data-confirm-test="[^"]*"' "$T/confirm/dom.html" | sed 's/.*="//;s/"$//')" "1:title:0:1:0"
fi

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
