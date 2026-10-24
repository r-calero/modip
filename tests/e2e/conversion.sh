#!/bin/bash
# 2D->3D conversion queue: broker, workers (local and remote), mutual TLS,
# docking jobs that wait for the conversions, leases and manual retry.
# Run after security.sh, docking.sh and downloads.sh on the same stack (it
# uses their users, target, receptor and the compounds queued by downloads.sh).
# MODIP_CONVERSION_WORKERS must include lab-02 (see README.md).
. "$(dirname "$0")/lib.sh"

TID=$(sql "select id from targets where name='Test target'"); AD=$(sql "select id from users where name='admin1'")
login admin1 admin1 "$PASSWORD" >/dev/null
job_json() { curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$1.json"; }
start_job() { # "cid:cid" -> docking job id
  local t=$(token admin1 "/users/$AD/docking")
  curl -s -o /dev/null -w '%{redirect_url}' -c "$T/admin1" -b "$T/admin1" --data-urlencode "authenticity_token=$t" \
    --data-urlencode "target[target_id]=$TID" --data-urlencode "cids=pages:;cids:$1" "$B/users/$AD/start_docking" | grep -oE '[0-9]+$'; }
wait_sql() { # query, expected value, seconds
  local v; for i in $(seq 1 "$3"); do v=$(sql "$1"); [ "$v" = "$2" ] && break; sleep 1; done; echo "$v"; }
client() { docker compose run --rm --no-deps -T -v "$ROOT/tests/e2e:/t:ro" --entrypoint ruby converter /t/conversion_client.rb "$@" 2>/dev/null | tr -d '\r' | tail -1; }
admin_post() { local t=$(token admin1 /admin); code admin1 --data-urlencode "authenticity_token=$t" "$B$1" | cut -d' ' -f1; }
# Puts compounds back in 2D with a queued conversion: to_2d "cid,cid" [timeout]
to_2d() {
  sql "update compounds set coordinate=NULL, coordinate_source_id=255, coordinate_unit_id=255, path=concat('data/Compounds/2D/', cid, '.sdf') where cid in ($1)"
  sql "update conversion_jobs j join compounds c on c.id=j.compound_id set j.status='queued', j.worker=NULL, j.claim_token=NULL, j.error=NULL, j.attempts=0, j.finished_at=NULL, j.timeout_seconds=${2:-300} where c.cid in ($1)"
}

# Only the given compounds keep their pending conversions; the others are
# set aside ("held") so test clients claim exactly these: only_pending "cid,cid"
only_pending() { sql "update conversion_jobs j join compounds c on c.id=j.compound_id set j.status='held' where j.status='queued' and c.cid not in ($1)"; }
release_held() { sql "update conversion_jobs set status='queued' where status='held'"; }

section "Queue filled by the download (downloads.sh)"
Q=$(sql "select id from queries where query like '%1004[uid]%' order by id desc limit 1")
QUEUED=$(sql "select count(*) from conversion_jobs where query_id=$Q")
check "the download queued conversions" "$(echo "$QUEUED" | awk '{print ($1>0)?"yes":"no"}')" "yes"
check "one CompoundQueued3D notification per queued compound" "$(sql "select count(distinct cn.cid) from compound_notifications cn join notifications n on n.id=cn.notification_id join compound_notification_types t on t.id=cn.compound_notification_type_id where n.query_id=$Q and t.name='CompoundQueued3D'")" "$QUEUED"
check "every conversion ends" "$(wait_sql "select count(*) from conversion_jobs where status in ('queued','running')" 0 1200)" "0"
DONE=$(sql "select count(*) from conversion_jobs where query_id=$Q and status='done'")
check "most conversions succeed" "$(echo "$DONE $QUEUED" | awk '{print ($1*2>=$2)?"yes":"no"}')" "yes"
check "converted compounds are 3D, source MODIP, file in 3D/" "$(sql "select count(*) from conversion_jobs j join compounds c on c.id=j.compound_id where j.status='done' and c.coordinate='3D Coordinates' and c.coordinate_source_id=7 and c.path like 'data/Compounds/3D/%'")" "$DONE"
check "done jobs record the local worker" "$(sql "select count(*) from conversion_jobs where status='done' and worker like 'local@%'")" "$DONE"
p=$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/queries/$Q/progress.json")
check "progress.json reports the conversions" "$(echo "$p" | python3 -c 'import sys,json; c=json.load(sys.stdin)["conversions"]; print(c["total"], c["pending"])')" "$QUEUED 0"

section "Worker registry"
check "the idle local worker keeps contacting the broker" "$(wait_sql "select current_job_id is null and last_seen_at > NOW() - INTERVAL 45 SECOND from conversion_workers where cn='local' and label<>'test'" 1 45)" "1"
A=$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/admin")
check "admin page: workers table" "$(echo "$A" | grep -c 'id="conversion-workers"')" "1"
check "admin page: local worker shown as idle" "$(echo "$A" | grep -A3 '<strong>local</strong>' | grep -c 'worker-state">idle')" "1"
N=$(sql "select count(*) from conversion_jobs where status='done' and worker=(select name from conversion_workers where cn='local' and label<>'test')")
check "admin page: conversions done in the last day" "$(echo "$A" | grep -A6 '<strong>local</strong>' | grep -c "<td>$N</td>")" "1"

# The download also queued a docking job for its compounds; it would compete
# with Open Babel for the CPU during these tests.
sql "update docking_jobs set status='cancelled', finished_at=NOW() where status in ('waiting','queued','running')"
docker compose restart docking >/dev/null 2>&1

C=($(sql "select c.cid from conversion_jobs j join compounds c on c.id=j.compound_id where j.status='done' order by j.id limit 4"))
C3D=$(sql "select cid from compounds where coordinate='3D Coordinates' and coordinate_source_id<>7 order by id limit 1")
check "compounds for the next tests" "${#C[@]}" "4"

section "A docking job waits for the conversions of its compounds"
docker compose stop converter >/dev/null 2>&1
to_2d "${C[0]},${C[1]}"
sql "update conversion_jobs j join compounds c on c.id=j.compound_id set j.timeout_seconds=1 where c.cid=${C[1]}"
J=$(start_job "${C[0]}:${C[1]}:$C3D")
j=$(job_json "$J")
check "job starts waiting" "$(echo "$j" | json_get status)" "waiting"
check "job reports 2 pending conversions" "$(echo "$j" | json_get pending_conversions)" "2"
check "job page says it is waiting" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$J" | grep -c 'Waiting for 2 3D conversions')" "1"
check "compound page shows the queued conversion" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/compounds/$(sql "select id from compounds where cid=${C[0]}")" | grep -c '2D (3D conversion queued)')" "1"
sleep 8
check "still waiting without workers" "$(job_json "$J" | json_get status)" "waiting"
docker compose start converter >/dev/null 2>&1
check "the conversion that ran out of time is marked timeout" "$(wait_sql "select j.status from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[1]}" timeout 300)" "timeout"
check "the other one is converted again" "$(wait_sql "select j.status from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[0]}" done 300)" "done"
for i in $(seq 1 150); do s=$(job_json "$J" | json_get status); [ "$s" = finished ] && break; sleep 2; done
check "docking runs once the conversions ended" "$s" "finished"
check "the converted compound is docked" "$(sql "select success from docking_job_logs where docking_job_id=$J and cid='${C[0]}'")" "1"
check "the compound left in 2D is not docked" "$(sql "select concat(success, ':', message like '%2D compound%') from docking_job_logs where docking_job_id=$J and cid='${C[1]}'")" "0:1"
check "the 3D compound is docked" "$(sql "select success from docking_job_logs where docking_job_id=$J and cid='$C3D'")" "1"
check "a job for 3D compounds starts queued" "$(job_json "$(start_job "$C3D")" | json_get status | sed 's/running/queued/;s/finished/queued/')" "queued"

section "Manual retry (admin page)"
CJ=$(sql "select j.id from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[1]}")
check "admin page lists the failed conversion" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/admin" | grep -c "admin/conversions/$CJ/retry")" "1"
login bob bob N3w-Str0ng-Passw0rd >/dev/null
t=$(token bob /); check "a non-admin cannot retry" "$(code bob --data-urlencode "authenticity_token=$t" "$B/admin/conversions/$CJ/retry" | cut -d' ' -f1)" "302"
check "not queued by the non-admin" "$(sql "select status from conversion_jobs where id=$CJ")" "timeout"
check "retry (POST)" "$(admin_post "/admin/conversions/$CJ/retry")" "302"
check "queued again with the retry timeout" "$(sql "select timeout_seconds from conversion_jobs where id=$CJ")" "${MODIP_BABEL_RETRY_TIMEOUT:-900}"
check "converted after the retry" "$(wait_sql "select status from conversion_jobs where id=$CJ" done 300)" "done"
check "compound page shows 3D" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/compounds/$(sql "select id from compounds where cid=${C[1]}")" | grep -c 'id="compound-dimension">3D<')" "1"
sql "update conversion_jobs set status='failed', error='test' where id=$CJ"
check "retry all (POST)" "$(admin_post /admin/conversions/retry)" "302"
check "retry all queued it" "$(sql "select status from conversion_jobs where id=$CJ" | sed 's/running/queued/;s/done/queued/')" "queued"
wait_sql "select count(*) from conversion_jobs where status in ('queued','running')" 0 300 >/dev/null

section "Mutual TLS"
docker compose run --rm --no-deps -T certs worker lab-x >/dev/null 2>&1   # valid certificate, not in MODIP_CONVERSION_WORKERS
check "allowed worker certificate" "$(client ping local)" "ALLOWED lost"
check "certificate not in MODIP_CONVERSION_WORKERS" "$(client ping lab-x | cut -d' ' -f1)" "DENIED"
check "no client certificate" "$(client nocert)" "REFUSED DRb::DRbConnError"
check "certificate from another CA" "$(client foreign)" "REFUSED DRb::DRbConnError"
check "plain druby" "$(client plain)" "REFUSED DRb::DRbConnError"
check "rejected worker is logged" "$(docker compose logs conversion-broker 2>&1 | grep -c 'rejected worker "lab-x"' | awk '{print ($1>0)?"yes":"no"}')" "yes"

section "Results are validated by the broker"
docker compose stop converter >/dev/null 2>&1
to_2d "${C[2]}"; only_pending "${C[2]}"
check "garbage SDF is rejected" "$(client garbage local)" "INVALID rejected 3D result: no atoms"
check "job marked failed with the reason" "$(sql "select concat(j.status, ':', j.error like 'Rejected 3D result%') from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[2]}")" "failed:1"
to_2d "${C[2]}"; only_pending "${C[2]}"
check "2D coordinates are rejected" "$(client flat local)" "INVALID rejected 3D result: coordinates are not 3D"
check "the compound stays in 2D" "$(sql "select coordinate is null from compounds where cid=${C[2]}")" "1"

section "Lease: a job of a worker that stopped responding goes back to the queue"
to_2d "${C[2]}"; only_pending "${C[2]}"
check "a worker claims the job and dies" "$(client claim local | cut -d' ' -f1,3)" "CLAIMED ${C[2]}"
sql "update conversion_jobs j join compounds c on c.id=j.compound_id set j.heartbeat_at = NOW() - INTERVAL 1 HOUR where c.cid=${C[2]}"
check "queued again after the lease" "$(wait_sql "select j.status from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[2]}" queued 45)" "queued"
check "a second lost lease fails the job" "$(client claim local | cut -d' ' -f1)" "CLAIMED"
sql "update conversion_jobs j join compounds c on c.id=j.compound_id set j.heartbeat_at = NOW() - INTERVAL 1 HOUR where c.cid=${C[2]}"
check "failed after two lost leases" "$(wait_sql "select j.status from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[2]}" failed 45)" "failed"

section "Worker shutdown gives the job back"
to_2d "${C[3]}" 600; only_pending "${C[3]}"
docker compose start converter >/dev/null 2>&1
wait_sql "select j.status from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[3]}" running 60 >/dev/null
check "registry shows the compound being converted" "$(sql "select current_cid from conversion_workers where cn='local' and label<>'test'")" "${C[3]}"
check "admin page: worker shown as converting" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/admin" | grep -A4 '<strong>local</strong>' | grep -c "CID ${C[3]}")" "1"
docker compose stop converter >/dev/null 2>&1
check "registry cleared on release" "$(sql "select current_job_id is null from conversion_workers where cn='local' and label<>'test'")" "1"
check "released on stop" "$(sql "select concat(j.status, ':', j.attempts) from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[3]}")" "queued:0"

section "Remote worker (deploy/worker)"
W="$T/worker"; mkdir -p "$W"; cp deploy/worker/docker-compose.worker.yml "$W/"
docker compose run --rm --no-deps -T -e MODIP_CONVERSION_PUBLIC_HOST=host.docker.internal certs worker lab-02 2>/dev/null | tar -xzf - -C "$W"
check "bundle has certificates and .env.worker" "$(ls "$W/certs" | tr '\n' ' ')$(grep -c MODIP_BROKER_URI "$W/.env.worker")" "ca.crt worker.crt worker.key 1"
sed -i '' "s#context: ../..#context: $ROOT#" "$W/docker-compose.worker.yml"
sed -i '' "s#^MODIP_BROKER_URI=.*#MODIP_BROKER_URI=drbssl://host.docker.internal:${MODIP_CONVERSION_BROKER_PORT:-7443}#" "$W/.env.worker"
echo "MODIP_WORKER_LABEL=remote-test" >> "$W/.env.worker"
chmod 644 "$W/certs/"*   # the files are owned by the test user, the worker runs as uid 1000
docker compose -p modip-worker-test -f "$W/docker-compose.worker.yml" up -d >/dev/null 2>&1
check "remote worker converts the queued compound" "$(wait_sql "select j.status from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[3]}" done 300)" "done"
check "done by lab-02" "$(sql "select j.worker from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[3]}")" "lab-02@remote-test"
check "admin page lists the remote worker" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/admin" | grep -A1 '<strong>lab-02</strong>' | grep -c '<td>remote-test</td>')" "1"
docker compose -p modip-worker-test -f "$W/docker-compose.worker.yml" down >/dev/null 2>&1
release_held
docker compose start converter >/dev/null 2>&1

section "Older 2D compounds (backfill)"
sql "delete j from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[2]}"
check "backfill (POST)" "$(admin_post /admin/conversions/backfill)" "302"
check "backfill queued the compound without a job" "$(sql "select count(*) from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[2]} and j.priority=0")" "1"
admin_post /admin/conversions/backfill >/dev/null
check "backfill is idempotent" "$(sql "select count(*) from conversion_jobs j join compounds c on c.id=j.compound_id where c.cid=${C[2]}")" "1"

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
