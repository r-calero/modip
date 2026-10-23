#!/bin/bash
# Download of several assays in parallel and the progress bar of the queries
# page. Run after security.sh (it uses its admin1 user and target).
. "$(dirname "$0")/lib.sh"
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
AIDS="1002 1003 1011 1004"   # 9 + 8 + 27 + 156 compounds

TID=$(sql "select id from targets where name='Test target'"); AD=$(sql "select id from users where name='admin1'")
login admin1 admin1 "$PASSWORD" >/dev/null
QUERY=$(echo $AIDS | sed 's/\([0-9]*\)/\1[uid]/g; s/ / OR /g')
t=$(token admin1 "/users/$AD/queries/new")
code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "query[query]=$QUERY" --data-urlencode "query[target_id]=$TID" \
  --data-urlencode "query[outcome_assay_filter]=eAssayOutcome_All" --data-urlencode "sch[written_on(1i)]=2026" --data-urlencode "sch[written_on(2i)]=1" \
  --data-urlencode "sch[written_on(3i)]=1" --data-urlencode "sch[written_on(4i)]=0" --data-urlencode "sch[written_on(5i)]=0" --data-urlencode "cycle[written_on]=1" "$B/users/$AD/queries" >/dev/null
Q=$(sql "select id from queries where query='$QUERY'")

section "Download of $(echo $AIDS | wc -w | tr -d ' ') assays ($QUERY)"
progress() { curl -s -c "$T/admin1" -b "$T/admin1" "$B/queries/$Q/progress.json"; }
check "progress before starting" "$(progress | json_get status)" "idle"
t=$(token admin1 "/users/$AD/queries")
START=$(date +%s)
check "start (POST)" "$(code admin1 -X POST -H "X-CSRF-Token: $t" -H 'Accept: text/javascript' -H 'X-Requested-With: XMLHttpRequest' "$B/queries/$Q/start" | cut -d' ' -f1)" "200"
SEEN=""; STATUS=""
for i in $(seq 1 600); do
  p=$(progress); s=$(echo "$p" | json_get status); pct=$(echo "$p" | json_get percent)
  [ "$s" = running ] && SEEN="$SEEN $pct"
  if [ "$s" != running ] && [ "$s" != idle ]; then STATUS=$s; break; fi
  sleep 1
done
ELAPSED=$(( $(date +%s) - START ))
echo "  progress seen:$(echo $SEEN | tr ' ' '\n' | uniq | tr '\n' ' ')"
echo "  download time: ${ELAPSED}s"
check "download complete" "$STATUS" "complete"
check "final percent" "$(progress | json_get percent)" "100.0"
check "progress is monotonic" "$(echo $SEEN | tr ' ' '\n' | python3 -c 'import sys; v=[float(x) for x in sys.stdin.read().split()]; print("yes" if v==sorted(v) else "no")')" "yes"
check "intermediate values were shown" "$(echo $SEEN | tr ' ' '\n' | awk '$1>0 && $1<100' | wc -l | awk '{print ($1>0)?"yes":"no"}')" "yes"
for aid in $AIDS; do check "assay $aid stored" "$(sql "select count(*) from assays where aid='$aid'")" "1"; done
check "every assay completed" "$(sql "select count(*) from notifications where query_id=$Q and event='AssayCompleted'")" "$(echo $AIDS | wc -w | tr -d ' ')"
check "rows of every assay stored" "$(sql "select count(distinct a.aid) from assays a join assays_compounds ac on ac.assay_id=a.id where a.aid in ($(echo $AIDS | tr ' ' ','))")" "$(echo $AIDS | wc -w | tr -d ' ')"
check "compounds converted to 3D by MODIP are stored" "$(sql "select count(*) > 0 from compounds where coordinate_source_id = 7")" "1"
check "no unexpected compound errors" "$(sql "select count(*) from notifications where query_id=$Q and message like 'unexpected error%'")" "0"
check "assays ran in parallel" "$(docker compose logs download 2>&1 | grep -oE 'total compound [0-9]+' | wc -l | awk '{print ($1>=4)?"yes":"no"}')" "yes"

if [ -x "$CHROME" ]; then
  section "Queries page progress bar in a headless browser (recorded stages)"
  H="$T/queries"; mkdir -p "$H"
  curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/queries" > "$H/raw.html"
  curl -s "$B$(grep -oE '/assets/application-[a-f0-9]+\.js' "$H/raw.html" | head -1)" > "$H/app.js"
  curl -s "$B/javascripts/index.js" > "$H/index.js"; curl -s "$B/javascripts/jquery-ui-1.8.20.min.js" > "$H/jquery-ui.js"
  cat > "$H/fake.js" <<JS
// Three polls: 40% -> 80% -> complete; then the page must stop polling.
var stages = [{running: true, status: "running", percent: 40.0, total_assays: 4, completed_assays: 1},
              {running: true, status: "running", percent: 80.0, total_assays: 4, completed_assays: 3},
              {running: false, status: "complete", percent: 100.0}], polls = 0;
\$.getJSON = function () { var d = \$.Deferred(), s = stages[Math.min(polls++, stages.length - 1)]; setTimeout(function () { d.resolve(s); }, 10); return d.promise(); };
\$(function () { start_see($Q); start_download_progress("$Q", "/progress.json"); setTimeout(function () { \$("body").attr("data-polls", polls); }, 12000); });
JS
  python3 - "$H" <<'PY'
import sys, re
d = sys.argv[1]
h = open(d + '/raw.html').read()
h = re.sub(r'<script src="/assets/application-[a-f0-9]+\.js"[^>]*></script>', '<script src="app.js"></script>', h)
h = re.sub(r'<script src="/javascripts/index\.js[^"]*"[^>]*></script>', '<script src="index.js"></script>', h)
h = re.sub(r'<script src="/javascripts/jquery-ui-1\.8\.20\.min\.js[^"]*"[^>]*></script>', '<script src="jquery-ui.js"></script>', h)
h = re.sub(r'<script src="/assets/[^"]+"[^>]*></script>', '', h)
h = re.sub(r'<link [^>]*stylesheet[^>]*>', '', h)
h = h.replace('</body>', '<script src="fake.js"></script></body>')
open(d + '/index.html', 'w').write(h)
PY
  "$CHROME" --headless=new --no-first-run --allow-file-access-from-files --user-data-dir="$H/profile" --virtual-time-budget=15000 --dump-dom "file://$H/index.html" 2>/dev/null > "$H/dom.html"
  check "bar reaches 100%" "$(grep -oE "id=\"progressbar-$Q\" style=\"width: [0-9.]+%" "$H/dom.html" | grep -oE '[0-9.]+%$')" "100%"
  check "status shows complete" "$(grep -oE "id=\"status-$Q\"[^>]*>[^<]*" "$H/dom.html" | sed 's/.*>//')" "complete"
  check "polling stops when finished (3 polls)" "$(grep -oE 'data-polls="[0-9]+"' "$H/dom.html" | grep -oE '[0-9]+')" "3"
fi

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
