#!/bin/bash
# Targeted regressions for the fix to how Vina, Open Babel and AutoDockTools
# are invoked (no shell) and to the naming of result files.
#
# Run it after security.sh and docking.sh on the same stack: it uses their
# admin1 user and downloaded compounds.
#
#   tests/e2e/names.sh
. "$(dirname "$0")/lib.sh"

# Target names are restricted by the model; receptor type names are not, and
# they are what reaches the file names and the command line.
TARGET='Catepsina B 1GMY'
RTYPE='Catepsina B (1GMY) "nitrilo" 50%'
PDB="$T/1hsg.pdb"
curl -sL -m 60 https://files.rcsb.org/download/1HSG.pdb | grep "^ATOM" > "$PDB"
AD=$(sql "select id from users where name='admin1'")
login admin1 admin1 "$PASSWORD" >/dev/null

section "A receptor type with awkward characters in its name"
t=$(token admin1 /targets/new)
check "a target name with & and accents is refused" "$(code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode 'target[name]=Catepsina B & homólogos' "$B/targets" | cut -d' ' -f1)" "200"
# Re-runnable: the target and the receptor type are created only once.
if [ -z "$(sql "select id from targets where name=\"$TARGET\"")" ]; then
  t=$(token admin1 /targets/new)
  check "target created" "$(code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "target[name]=$TARGET" "$B/targets" | cut -d' ' -f1)" "302"
fi
TID=$(sql "select id from targets where name=\"$TARGET\"")
check "target available" "$(test -n "$TID" && echo yes || echo no)" "yes"
check "folder name is sanitised" "$(sql "select root from targets where id=$TID")" "data/Targets/Catepsina_B_1GMY"

# Looked up with LIKE: the name itself carries double quotes.
if [ -z "$(sql "select id from receptor_types where name like '%nitrilo%' limit 1")" ]; then
  t=$(token admin1 /receptor_types/new)
  curl -s -o /dev/null -c "$T/admin1" -b "$T/admin1" --data-urlencode "authenticity_token=$t" \
    --data-urlencode "receptor_type[name]=$RTYPE" "$B/receptor_types"
fi
RT=$(sql "select id from receptor_types where name like '%nitrilo%' order by id limit 1")
check "receptor type stored verbatim (the model allows any name)" "$(test -n "$RT" && echo yes || echo no)" "yes"

section "The models refuse what they cannot store"
t=$(token admin1 /receptor_types/new)
check "a receptor type longer than the column is refused" "$(code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "receptor_type[name]=$(python3 -c 'print("X"*60)')" "$B/receptor_types" | cut -d' ' -f1)" "200"
check "it was not stored truncated" "$(sql "select count(*) from receptor_types where name like 'XXXXX%'")" "0"
t=$(token admin1 /receptor_types/new)
check "an empty receptor type is refused" "$(code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "receptor_type[name]=   " "$B/receptor_types" | cut -d' ' -f1)" "200"
t=$(token admin1 /receptor_types/new)
check "a duplicate receptor type is refused" "$(code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "receptor_type[name]=$RTYPE" "$B/receptor_types" | cut -d' ' -f1)" "200"
t=$(token admin1 "/targets/$TID/prepare_receptors/new")
check "a receptor without a type answers with the form, not a 500" "$(code admin1 -F "authenticity_token=$t" -F "prepare_receptor[target_id]=$TID" -F "prepare_receptor[receptor_type_id]=" \
  -F "prepare_receptor[uploaded_receptor]=@$PDB;filename=1hsg_protein.pdb" \
  -F "prepare_receptor[center_x]=13.07" -F "prepare_receptor[center_y]=22.47" -F "prepare_receptor[center_z]=5.56" \
  -F "prepare_receptor[size_x]=22" -F "prepare_receptor[size_y]=22" -F "prepare_receptor[size_z]=22" \
  -F "prepare_receptor[energy_range]=3" -F "prepare_receptor[number_of_conformer]=3" \
  -F "prepare_receptor[cpu_number]=4" "$B/targets/$TID/prepare_receptors" | cut -d' ' -f1)" "200"

section "Receptor preparation (AutoDockTools through the new call path)"
if [ -z "$(sql "select id from prepare_receptors where target_id=$TID")" ]; then
t=$(token admin1 "/targets/$TID/prepare_receptors/new")
check "upload and prepare" "$(code admin1 -F "authenticity_token=$t" -F "prepare_receptor[target_id]=$TID" -F "prepare_receptor[receptor_type_id]=$RT" \
  -F "prepare_receptor[uploaded_receptor]=@$PDB;filename=1hsg_protein.pdb" \
  -F "prepare_receptor[center_x]=13.07" -F "prepare_receptor[center_y]=22.47" -F "prepare_receptor[center_z]=5.56" \
  -F "prepare_receptor[size_x]=22" -F "prepare_receptor[size_y]=22" -F "prepare_receptor[size_z]=22" \
  -F "prepare_receptor[energy_range]=3" -F "prepare_receptor[number_of_conformer]=3" \
  -F "prepare_receptor[cpu_number]=4" "$B/targets/$TID/prepare_receptors" | cut -d' ' -f1)" "302"
fi
RP=$(sql "select receptor from prepare_receptors where target_id=$TID")
check "pdbqt produced" "$RP" "data/Targets/Catepsina_B_1GMY/1hsg_protein.pdbqt"
check "polar hydrogens added" "$(docker compose exec -T docking sh -c "grep -c ' HD' '$RP'" | tr -d '\r' | awk '{print ($1>100)?"yes":"no"}')" "yes"

section "Docking end to end with those names"
CID=$(sql "select c.cid from compounds c where c.coordinate='3D Coordinates' order by c.id limit 1")
t=$(token admin1 "/users/$AD/docking")
JOB=$(curl -s -o /dev/null -w '%{redirect_url}' -c "$T/admin1" -b "$T/admin1" --data-urlencode "authenticity_token=$t" \
  --data-urlencode "target[target_id]=$TID" --data-urlencode "cids=pages:;cids:$CID" "$B/users/$AD/start_docking" | grep -oE '[0-9]+$')
for i in $(seq 1 150); do
  s=$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$AD/docking_jobs/$JOB.json" | json_get status)
  [ "$s" = finished ] || [ "$s" = failed ] && break
  sleep 2
done
check "job finished" "$s" "finished"
POSES=$(sql "select count(*) from receptor_compounds rc join prepare_receptors p on p.id=rc.prepare_receptor_id where p.target_id=$TID")
check "poses were produced (this is what used to fail silently)" "$(echo "$POSES" | awk '{print ($1>0)?"yes":"no"}')" "yes"
check "no missing-file errors in the log" "$(sql "select count(*) from docking_job_logs where docking_job_id=$JOB and message like '%No such file%'")" "0"
check "result file name has no shell characters" "$(sql "select count(*) from receptor_compounds rc join prepare_receptors p on p.id=rc.prepare_receptor_id where p.target_id=$TID and rc.path regexp '[^A-Za-z0-9_./-]'")" "0"

section "The results are usable afterwards"
POSE=$(sql "select rc.path from receptor_compounds rc join prepare_receptors p on p.id=rc.prepare_receptor_id where p.target_id=$TID limit 1")
ENC=$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$POSE")
check "3D viewer page opens" "$(code admin1 "$B/poses?path=$ENC" | cut -d' ' -f1)" "200"
check "viewer data has receptor and poses" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/poses/data?path=$ENC" | python3 -c 'import sys,json; d=json.load(sys.stdin); print("ATOM" in d["receptor"] and "ENDMDL" in d["pose"])')" "True"
curl -s -o "$T/poses.tgz" -c "$T/admin1" -b "$T/admin1" "$B/targets/$TID/poses"
check "poses export contains the file" "$(tar tzf "$T/poses.tgz" | grep -c '\.pdbqt$' | awk '{print ($1>0)?"yes":"no"}')" "yes"
check "ranking CSV header carries the awkward name" "$(curl -s -c "$T/admin1" -b "$T/admin1" "$B/users/$TID/compound_ranking/filter_one/$RT/filter_two/$RT/filter_tree/$RT.csv" | head -1 | grep -c 'nitrilo')" "1"

section "Atom count of a large molecule (SDF counts line)"
check "no compound reports a four-digit atom count" "$(sql "select count(*) from compounds where atom_number > 999")" "0"
check "atom_number is consistent with heavy_atom_count" "$(sql "select count(*) from compounds where atom_number < heavy_atom_count")" "0"

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
