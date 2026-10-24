#!/bin/bash
# Download of several assays in parallel and the progress bar of the queries
# page. Run after security.sh (it uses its admin1 user and target).
. "$(dirname "$0")/lib.sh"
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
AIDS="1002 1003 1011 1004"   # 9 + 8 + 27 + 156 compounds

TID=$(sql "select id from targets where name='Test target'"); AD=$(sql "select id from users where name='admin1'")
login admin1 admin1 "$PASSWORD" >/dev/null
new_query() { # text -> query id
  local t=$(token admin1 "/users/$AD/queries/new")
  code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "query[query]=$1" --data-urlencode "query[target_id]=$TID" \
    --data-urlencode "query[outcome_assay_filter]=eAssayOutcome_All" --data-urlencode "sch[written_on(1i)]=2026" --data-urlencode "sch[written_on(2i)]=1" \
    --data-urlencode "sch[written_on(3i)]=1" --data-urlencode "sch[written_on(4i)]=0" --data-urlencode "sch[written_on(5i)]=0" --data-urlencode "cycle[written_on]=1" "$B/users/$AD/queries" >/dev/null
  sql "select max(id) from queries where query='$1'"
}
query_post() { # query id, start|stop
  local t=$(token admin1 "/users/$AD/queries")
  code admin1 -X POST -H "X-CSRF-Token: $t" -H 'Accept: text/javascript' -H 'X-Requested-With: XMLHttpRequest' "$B/queries/$1/$2" | cut -d' ' -f1
}
# Queries page that lists a query (5 per page, by id).
queries_page() { curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/queries?page=$(( ($(sql "select count(*) from queries where user_id=$AD and id<=$1") + 4) / 5 ))"; }
wait_running() { for i in $(seq 1 60); do [ "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/queries/$1/progress.json" | json_get running)" = True ] && break; sleep 1; done; }
QUERY=$(echo $AIDS | sed 's/\([0-9]*\)/\1[uid]/g; s/ / OR /g')
Q=$(new_query "$QUERY")

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
check "compounds without 3D conformer are queued for conversion" "$(sql "select count(*) > 0 from conversion_jobs where query_id=$Q")" "1"
check "the download does not wait for the conversions" "$(sql "select count(*) > 0 from conversion_jobs where query_id=$Q and status in ('queued','running')")" "1"
for i in $(seq 1 1200); do [ "$(sql "select count(*) from conversion_jobs where query_id=$Q and status in ('queued','running')")" = 0 ] && break; sleep 1; done
echo "  conversions ended $(( $(date +%s) - START ))s after the start"
check "compounds converted to 3D by MODIP are stored" "$(sql "select count(*) > 0 from compounds where coordinate_source_id = 7")" "1"
check "no unexpected compound errors" "$(sql "select count(*) from notifications where query_id=$Q and message like 'unexpected error%'")" "0"
check "assays ran in parallel" "$(docker compose logs download 2>&1 | grep -oE 'total compound [0-9]+' | wc -l | awk '{print ($1>=4)?"yes":"no"}')" "yes"

section "Result of each query run (last_status)"
summary() { sql "select last_summary from queries where id=$1" | python3 -c "import sys,json; d=json.load(sys.stdin); print(' '.join(str(d[k]) for k in sys.argv[1:]))" "${@:2}"; }
check "a new query has never run" "$(sql "select last_status from queries where id=$(new_query '1002[uid]')")" "never"
check "complete after the download" "$(sql "select last_status from queries where id=$Q")" "complete"
check "start and end time recorded" "$(sql "select last_started_at is not null and last_finished_at >= last_started_at from queries where id=$Q")" "1"
check "summary counts: assays new, compounds new, queued for 3D" "$(summary $Q assays_new compounds_new compounds_queued_3d)" "4 $(sql "select count(distinct cn.cid) from compound_notifications cn join notifications n on n.id=cn.notification_id where n.query_id=$Q and n.event in ('CompoundInserted','CompoundQueued3D')") $(sql "select count(*) from conversion_jobs where query_id=$Q")"
check "queries page shows the result" "$(queries_page $Q | grep -A3 "id=\"last-run-$Q\"" | grep -c 'label label-success query-status">complete')" "1"
check "queries page: green download bar" "$(queries_page $Q | grep -c "class=\"progress progress-success\" id=\"progress-$Q\"")" "1"
Q2=$(new_query "1002[uid] OR 1003[uid]")
query_post "$Q2" start >/dev/null
for i in $(seq 1 120); do s=$(sql "select last_status from queries where id=$Q2"); [ "$s" != running ] && [ "$s" != never ] && break; sleep 1; done
check "assays already stored: run complete" "$s" "complete"
check "summary counts assays already stored" "$(summary $Q2 assays_new assays_existing)" "0 2"
check "message says already in the database" "$(sql "select count(*) from notifications where query_id=$Q2 and message='assay 1002 is already in the database'")" "1"
Q3=$(new_query "cathepsin B")   # about 2000 assays: still running when it is stopped
query_post "$Q3" start >/dev/null; wait_running "$Q3"
check "stop (POST)" "$(query_post "$Q3" stop)" "200"
check "stopped by the user" "$(sql "select last_status from queries where id=$Q3")" "stopped"
query_post "$Q3" start >/dev/null; wait_running "$Q3"
docker compose restart download >/dev/null 2>&1
sleep 62
curl -s -c "$T/admin1" -b "$T/admin1" "$B/queries/$Q3/progress.json" >/dev/null
check "interrupted by a download server restart" "$(sql "select last_status from queries where id=$Q3")" "interrupted"
check "queries page: red bar for the interrupted run" "$(queries_page $Q3 | grep -c "class=\"progress progress-danger\" id=\"progress-$Q3\"")" "1"
sql "delete from conversion_jobs where query_id=$Q3"   # not needed by the next suites
check "admin page counts queries by result" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/admin" | grep -A12 'id="query-statuses"' | grep -c 'query-status">interrupted')" "1"

if [ -x "$CHROME" ]; then
  section "Queries page progress bar in a headless browser (recorded stages)"
  H="$T/queries"; mkdir -p "$H"
  queries_page $Q > "$H/raw.html"
  curl -s "$B$(grep -oE '/assets/application-[a-f0-9]+\.js' "$H/raw.html" | head -1)" > "$H/app.js"
  curl -s "$B/javascripts/index.js" > "$H/index.js"; curl -s "$B/javascripts/jquery-ui-1.8.20.min.js" > "$H/jquery-ui.js"
  cat > "$H/fake.js" <<JS
// Three polls: 40% -> 80% -> complete; then the page must stop polling.
// 3D conversions still pending after the download: polling goes on until they end.
var conv = function (done, failed, pending) { return {total: 16, done: done, failed: failed, pending: pending}; };
var last = {status: "complete", summary: "assays: 4 new \u00b7 compounds: 199 new (16 queued for 3D)", finished_at: "2026-10-25 10:00"};
var stages = [{running: true, status: "running", percent: 40.0, total_assays: 4, completed_assays: 1, conversions: conv(0, 0, 16)},
              {running: true, status: "running", percent: 80.0, total_assays: 4, completed_assays: 3, conversions: conv(2, 0, 14)},
              {running: false, status: "complete", percent: 100.0, conversions: conv(10, 1, 5), last_run: last},
              {running: false, status: "complete", percent: 100.0, conversions: conv(15, 1, 0), last_run: last}], polls = 0;
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
  check "polling goes on until the conversions end (4 polls)" "$(grep -oE 'data-polls="[0-9]+"' "$H/dom.html" | grep -oE '[0-9]+')" "4"
  check "download bar turns green" "$(grep -oE "class=\"progress [^\"]*\" id=\"progress-$Q\"" "$H/dom.html" | grep -c 'progress-success')" "1"
  check "conversion bar turns orange (1 failed)" "$(grep -oE "class=\"progress [^\"]*\" id=\"conversion-progress-$Q\"" "$H/dom.html" | grep -c 'progress-warning')" "1"
  check "last run shown" "$(tr -d '\n' < "$H/dom.html" | grep -oE "id=\"last-run-$Q\"[^>]*>[[:space:]]*<span class=\"[^\"]*\">[a-z ]+" | grep -E 'label-success' | grep -c '>complete')" "1"
fi

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
