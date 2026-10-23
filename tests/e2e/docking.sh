#!/bin/bash
# Docking jobs: PDB receptor preparation, queue, progress, cancel, restart
# recovery, e-mail, exports, admin page. Run after security.sh on the same
# stack (it uses its users, target and downloaded compounds).
. "$(dirname "$0")/lib.sh"

PDB="$T/1hsg.pdb"
curl -sL -m 60 https://files.rcsb.org/download/1HSG.pdb | grep "^ATOM" > "$PDB"   # HIV-1 protease
job_json() { curl -s -c "$T/$1" -b "$T/$1" "$B/users/$2/docking_jobs/$3.json"; }
start_job() { # jar, user id, target id, "cid:cid:cid" -> job id (same format as users.js)
  local t=$(token "$1" "/users/$2/docking")
  curl -s -o /dev/null -w '%{redirect_url}' -c "$T/$1" -b "$T/$1" --data-urlencode "authenticity_token=$t" \
    --data-urlencode "target[target_id]=$3" --data-urlencode "cids=pages:;cids:$4" "$B/users/$2/start_docking" | grep -oE '[0-9]+$'; }
wait_status() { for i in $(seq 1 "$5"); do s=$(job_json "$1" "$2" "$3" | json_get status); [ "$s" = "$4" ] && break; sleep 2; done; echo "$s"; }
wait_processed() { for i in $(seq 1 90); do p=$(job_json "$1" "$2" "$3" | json_get processed); [ "$p" -ge 1 ] 2>/dev/null && break; sleep 2; done; }

TID=$(sql "select id from targets where name='Test target'"); AD=$(sql "select id from users where name='admin1'")
CIDS=($(sql "select cid from compounds order by id limit 12"))
login admin1 admin1 "$PASSWORD" >/dev/null

section "Receptor from a PDB file"
t=$(token admin1 /receptor_types/new)
curl -s -o /dev/null -c "$T/admin1" -b "$T/admin1" --data-urlencode "authenticity_token=$t" --data-urlencode "receptor_type[name]=HIV protease" "$B/receptor_types"
RT=$(sql "select id from receptor_types where name='HIV protease'")
t=$(token admin1 "/targets/$TID/prepare_receptors/new")
check "admin uploads a .pdb receptor" "$(code admin1 -F "authenticity_token=$t" -F "prepare_receptor[target_id]=$TID" -F "prepare_receptor[receptor_type_id]=$RT" \
  -F "prepare_receptor[uploaded_receptor]=@$PDB;filename=1hsg_protein.pdb" -F "prepare_receptor[center_x]=13.07" -F "prepare_receptor[center_y]=22.47" -F "prepare_receptor[center_z]=5.56" \
  -F "prepare_receptor[size_x]=22" -F "prepare_receptor[size_y]=22" -F "prepare_receptor[size_z]=22" -F "prepare_receptor[energy_range]=3" -F "prepare_receptor[number_of_conformer]=3" \
  -F "prepare_receptor[cpu_number]=2" "$B/targets/$TID/prepare_receptors" | cut -d' ' -f1)" "302"
RP=$(sql "select receptor from prepare_receptors limit 1")
check "stored receptor is the generated .pdbqt" "$RP" "data/Targets/Test_target/1hsg_protein.pdbqt"
check "pdbqt has polar hydrogens" "$(docker compose exec -T docking sh -c "grep -c ' HD' $RP" | tr -d '\r' | awk '{print ($1>100)?"yes":"no"}')" "yes"

section "Docking job: progress, log, e-mail"
J1=$(start_job admin1 "$AD" "$TID" "${CIDS[0]}:${CIDS[1]}:${CIDS[2]}")
check "job page opens" "$(code admin1 "$B/users/$AD/docking_jobs/$J1" | cut -d' ' -f1)" "200"
PERCENTS=""; for i in $(seq 1 120); do j=$(job_json admin1 "$AD" "$J1"); PERCENTS="$PERCENTS $(echo "$j" | json_get percent)"; s=$(echo "$j" | json_get status); [ "$s" = finished ] && break; sleep 2; done
echo "  progress seen:$(echo $PERCENTS | tr ' ' '\n' | uniq | tr '\n' ' ')"
check "job finished" "$s" "finished"
check "progress is monotonic and ends at 100" "$(echo $PERCENTS | tr ' ' '\n' | python3 -c 'import sys; v=[float(x) for x in sys.stdin.read().split()]; print("yes" if v==sorted(v) and v[-1]==100.0 else "no")')" "yes"
check "3 compounds processed" "$(job_json admin1 "$AD" "$J1" | json_get processed)" "3"
check "3 log lines" "$(sql "select count(*) from docking_job_logs where docking_job_id=$J1")" "3"
check "incremental log polling (after=)" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$J1.json?after=999999999" | python3 -c 'import sys,json; print(len(json.load(sys.stdin)["logs"]))')" "0"
check "poses stored" "$(sql "select count(distinct compound_id) from receptor_compounds")" "3"
if [ -n "$MAILPIT" ]; then
  for i in $(seq 1 45); do n=$(curl -s "$MAILPIT/api/v1/messages" | python3 -c 'import sys,json; print(sum(1 for m in json.load(sys.stdin)["messages"] if "docking job" in m["Subject"]))'); [ "$n" -gt 0 ] && break; sleep 2; done
  check "finished-job e-mail sent" "$n" "1"
fi

section "Cancel a running job"
J2=$(start_job admin1 "$AD" "$TID" "$(IFS=:; echo "${CIDS[*]:3:6}")")
wait_processed admin1 "$AD" "$J2"
t=$(token admin1 "/users/$AD/docking_jobs/$J2")
check "cancel (POST)" "$(code admin1 --data-urlencode "authenticity_token=$t" "$B/users/$AD/docking_jobs/$J2/cancel" | cut -d' ' -f1)" "302"
sleep 8
check "status cancelled" "$(job_json admin1 "$AD" "$J2" | json_get status)" "cancelled"
P2=$(job_json admin1 "$AD" "$J2" | json_get processed); sleep 8
check "no more compounds after cancelling" "$(job_json admin1 "$AD" "$J2" | json_get processed)" "$P2"
check "vina stopped" "$(docker compose exec -T docking sh -c 'pgrep -c vina || true' | tr -d '\r')" "0"

section "A job survives a docking server restart"
J3=$(start_job admin1 "$AD" "$TID" "${CIDS[9]}:${CIDS[10]}:${CIDS[11]}")
wait_processed admin1 "$AD" "$J3"
docker compose restart docking >/dev/null 2>&1
check "job resumes and finishes" "$(wait_status admin1 "$AD" "$J3" finished 120)" "finished"
check "each compound processed once" "$(sql "select processed_compounds, count(l.id) from docking_jobs j join docking_job_logs l on l.docking_job_id=j.id where j.id=$J3 group by j.id" | tr '\t' ' ')" "3 3"

section "Exports"
curl -s -o "$T/rank.csv" "$B/users/$TID/compound_ranking/filter_one/$RT/filter_two/$RT/filter_tree/$RT.csv"
check "ranking CSV header" "$(head -1 "$T/rank.csv" | tr -d '\r')" "rank,cid,HIV protease (kcal/mol),HIV protease (kcal/mol),HIV protease (kcal/mol)"
check "ranking CSV rows" "$(awk -F, 'NR>1 && $3!=""' "$T/rank.csv" | wc -l | tr -d ' ')" "$(sql "select count(distinct compound_id) from receptor_compounds")"
curl -s -o "$T/poses.tgz" "$B/targets/$TID/poses?job_id=$J1"
check "job poses archive" "$(tar tzf "$T/poses.tgz" | grep -c '\.pdbqt$')" "3"
curl -s -o "$T/all.tgz" "$B/targets/$TID/poses"
check "target poses archive" "$(tar tzf "$T/all.tgz" | grep -c '\.pdbqt$')" "$(sql "select count(distinct path) from receptor_compounds")"

section "Pages, ownership and admin"
check "my jobs page" "$(code admin1 "$B/users/$AD/docking_jobs" | cut -d' ' -f1)" "200"
check "old docking_progress link opens the last job" "$(code admin1 "$B/users/$AD/docking/$TID/docking_progress" | cut -d' ' -f2)" "$B/users/$AD/docking_jobs/$J3"
login bob bob N3w-Str0ng-Passw0rd >/dev/null; BO=$(sql "select id from users where name='bob'")
check "bob cannot see admin1's job" "$(code bob "$B/users/$AD/docking_jobs/$J1.json" | cut -d' ' -f2)" "$B/errors"
check "bob cannot open the admin page" "$(code bob "$B/admin" | cut -d' ' -f2)" "$B/errors"
check "admin page" "$(code admin1 "$B/admin" | cut -d' ' -f1)" "200"
t=$(token admin1 /admin)
check "admin deletes bob" "$(code admin1 --data-urlencode "authenticity_token=$t" -d "_method=delete" "$B/admin/users/$BO" | cut -d' ' -f1)" "302"
check "bob is gone" "$(sql "select count(*) from users where name='bob'")" "0"

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
