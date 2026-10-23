#!/bin/bash
# Access control, file access, CVE-2013-0156, registration/login protection,
# passwords and password reset. Run on a fresh test stack (see README.md).
. "$(dirname "$0")/lib.sh"

section "Guests (not logged in)"
for p in / /assays /compounds /targets /help /about /receptor_types /cycles; do
  check "guest can read $p" "$(code g "$B$p" | cut -d' ' -f1)" "200"; done
check "guest ranking list" "$(code g -X POST "$B/users/compound_rank" -d x=1 | cut -d' ' -f1)" "302"
for p in /targets/new /receptor_types/new /cycles/new /admin /schedules; do
  check "guest blocked $p" "$(code g "$B$p" | cut -d' ' -f2)" "$B/login"; done
curl -s -c "$T/g2" -b "$T/g2" "$B/" >/dev/null
check "home does not log in as the shared account" "$(code g2 "$B/admin" | cut -d' ' -f2)" "$B/login"
check "login as test/test rejected (read-only guest mode)" "$(login g3 test test | cut -d' ' -f2)" "$B/login"

section "Registration and mass assignment"
register alice --data-urlencode "user[hashed_password]=HACKED" --data-urlencode "user[salt]=HACKED"
register bob
register admin1
check "hashed_password cannot be set from the form" "$(sql "select hashed_password='HACKED' or salt='HACKED' from users where name='alice'")" "0"
A=$(sql "select id from users where name='alice'"); Bo=$(sql "select id from users where name='bob'")
check "alice logs in" "$(login alice alice "$PASSWORD" | cut -d' ' -f1)" "302"
login bob bob "$PASSWORD" >/dev/null; login admin1 admin1 "$PASSWORD" >/dev/null

section "Shared data is admin-only (MODIP_ADMIN_USERS=admin1)"
t=$(token alice /targets)
check "non-admin cannot create a target" "$(code alice --data-urlencode "authenticity_token=$t" --data-urlencode "target[name]=Alice target" "$B/targets" | cut -d' ' -f2)" "$B/errors"
t=$(token admin1 /targets/new)
curl -s -c "$T/admin1" -b "$T/admin1" --data-urlencode "authenticity_token=$t" --data-urlencode "target[name]=../../evil" "$B/targets" > "$T/evil.html"
check "target name with ../ rejected" "$(grep -c 'may only contain' "$T/evil.html")" "1"
check "admin creates a target" "$(code admin1 --data-urlencode "authenticity_token=$t" --data-urlencode "target[name]=Test target" --data-urlencode "target[root]=/etc" "$B/targets" | cut -d' ' -f1)" "302"
check "target root is not mass-assignable" "$(sql "select root from targets where name='Test target'")" "data/Targets/Test_target"
TID=$(sql "select id from targets where name='Test target'")

section "Ownership of accounts and queries"
check "bob cannot edit alice" "$(code bob "$B/users/$A/edit" | cut -d' ' -f2)" "$B/errors"
check "bob cannot list alice's queries" "$(code bob "$B/users/$A/queries" | cut -d' ' -f2)" "$B/errors"
check "alice edits her account" "$(code alice "$B/users/$A/edit" | cut -d' ' -f1)" "200"
TESTID=$(sql "select id from users where name='test'")
check "nobody edits the shared account" "$(code admin1 "$B/users/$TESTID/edit" | cut -d' ' -f2)" "$B/errors"
t=$(token alice "/users/$A/queries/new")
code alice --data-urlencode "authenticity_token=$t" --data-urlencode "query[query]=1000[uid]" --data-urlencode "query[target_id]=$TID" \
  --data-urlencode "query[outcome_assay_filter]=eAssayOutcome_All" --data-urlencode "query[user_id]=$Bo" \
  --data-urlencode "sch[written_on(1i)]=2026" --data-urlencode "sch[written_on(2i)]=1" --data-urlencode "sch[written_on(3i)]=1" \
  --data-urlencode "sch[written_on(4i)]=0" --data-urlencode "sch[written_on(5i)]=0" --data-urlencode "cycle[written_on]=1" "$B/users/$A/queries" >/dev/null
Q=$(sql "select id from queries where query='1000[uid]'")
check "query belongs to alice (user_id cannot be forged)" "$(sql "select user_id from queries where id=$Q")" "$A"
t=$(token bob /)
check "bob cannot start alice's query" "$(code bob -X POST -H "X-CSRF-Token: $t" -H 'Accept: text/javascript' "$B/queries/$Q/start" | cut -d' ' -f2)" "$B/errors"
check "bob cannot read alice's notifications" "$(code bob -H 'Accept: text/event-stream' "$B/queries/$Q/download_notification" | cut -d' ' -f2)" "$B/errors"

section "File access"
check "download_conformer refuses an arbitrary path" "$(code g -X POST --data-urlencode "resource=/proc/1/environ" "$B/users/$TID/1/1/download_conformer" | cut -d' ' -f2)" "$B/errors"
drb() { web_sh "ruby -rdrb -e 'DRb.start_service; d = DRbObject.new(nil, ENV[\"$1\"]); begin; d.$2; puts \"DONE\"; rescue Exception => e; puts e.class; end'"; }
check "docking server refuses /etc/passwd" "$(drb MODIP_DOCKING_DRB_URI 'get_resource("/etc/passwd")')" "ArgumentError"
check "download server refuses /etc/passwd" "$(drb MODIP_DOWNLOAD_DRB_URI 'data_download("/etc/passwd")')" "ArgumentError"
check "docking server refuses deleting the targets root" "$(drb MODIP_DOCKING_DRB_URI 'delete_receptor("data/Targets")')" "ArgumentError"

section "CVE-2013-0156 (XML parameters)"
curl -s -o /dev/null -c "$T/g" -b "$T/g" -H 'Content-Type: application/xml' --data '<user><name type="yaml">--- !ruby/object:Object {}</name></user>' "$B/users"
check "XML body is not parsed" "$(web_sh 'grep -A2 "POST \"/users\"" log/production.log | tail -3 | grep -c "ruby/object"')" "0"

section "A real download still works (POST + CSRF)"
check "GET start is not allowed (CSRF)" "$(code alice "$B/queries/$Q/start" | cut -d' ' -f2)" "$B/errors"
t=$(token alice "/users/$A/queries")
check "alice starts her query" "$(code alice -X POST -H "X-CSRF-Token: $t" -H 'Accept: text/javascript' -H 'X-Requested-With: XMLHttpRequest' "$B/queries/$Q/start" | cut -d' ' -f1)" "200"
for i in $(seq 1 40); do sleep 5; [ "$(sql "select count(*) from finished_notifications fn join notifications n on n.id=fn.notification_id where n.query_id=$Q")" -gt 0 ] && break; done
check "assay downloaded" "$(sql "select count(*) from assays where aid='1000'")" "1"
check "57 compounds stored" "$(sql "select count(*) from compounds")" "57"
check "download notifications saved" "$(sql "select count(*) > 50 from notifications where query_id=$Q")" "1"

section "Registration protection"
t=$(token bot1 /users/new); f=$(ftoken bot1)
curl -s -o /dev/null -c "$T/bot1" -b "$T/bot1" --data-urlencode "authenticity_token=$t" --data-urlencode "form_started=$f" -d "$CAPTCHA" \
  --data-urlencode "user[name]=bot1" --data-urlencode "user[email]=bot1@example.org" --data-urlencode "user[password]=$PASSWORD" --data-urlencode "user[password_confirmation]=$PASSWORD" "$B/users"
check "form sent in under 3 s rejected" "$(sql "select count(*) from users where name='bot1'")" "0"
register bot2 --data-urlencode "contact_website=http://spam.example"
check "honeypot filled rejected" "$(sql "select count(*) from users where name='bot2'")" "0"
t=$(token bot3 /users/new); f=$(ftoken bot3); sleep 3
curl -s -o /dev/null -c "$T/bot3" -b "$T/bot3" --data-urlencode "authenticity_token=$t" --data-urlencode "form_started=$f" \
  --data-urlencode "user[name]=bot3" --data-urlencode "user[email]=bot3@example.org" --data-urlencode "user[password]=$PASSWORD" --data-urlencode "user[password_confirmation]=$PASSWORD" "$B/users"
check "registration without captcha rejected" "$(sql "select count(*) from users where name='bot3'")" "0"
check "captcha widget in the form" "$(curl -s "$B/users/new" | grep -c 'cf-turnstile')" "1"
t=$(token weak /users/new); f=$(ftoken weak); sleep 3
curl -s -o "$T/weak.html" -c "$T/weak" -b "$T/weak" --data-urlencode "authenticity_token=$t" --data-urlencode "form_started=$f" -d "$CAPTCHA" \
  --data-urlencode "user[name]=weak" --data-urlencode "user[email]=weak@example.org" --data-urlencode "user[password]=short1" --data-urlencode "user[password_confirmation]=short1" "$B/users"
check "short password rejected" "$(grep -c 'at least 12 characters' "$T/weak.html")" "1"

section "Passwords"
check "new passwords use bcrypt" "$(sql "select left(hashed_password,4) from users where name='alice'")" '$2a$'
check "legacy SHA-256 account upgraded on its first valid check" "$(sql "select left(hashed_password,4), salt from users where name='test'" | tr '\t' ' ')" '$2a$ bcrypt'
check "wrong password rejected" "$(login alice alice wrong-password | cut -d' ' -f2)" "$B/login"

section "Login throttling"
for i in 1 2 3 4 5; do login carl alice "wrong-$i" >/dev/null; done
login carl2 alice "$PASSWORD" >/dev/null
check "6th attempt for the same user is locked" "$(curl -s -c "$T/carl2" -b "$T/carl2" "$B/login" | grep -q 'Too many failed' && echo yes)" "yes"
check "captcha shown after 3 failures from an IP" "$(curl -s "$B/login" | grep -c 'cf-turnstile')" "1"

section "Password reset"
web_sh 'cd /app/PIAM && MODIP_NO_DRB=true bundle exec rails runner "
u = User.find_by_name(%q(bob)); t = SignedToken.generate(%q(password-reset), {%q(user_id) => u.id, %q(fingerprint) => u.password_fingerprint}, 3600)
File.write(%q(/tmp/reset_token), t)" 2>/dev/null' >/dev/null
RT=$(web_sh 'cat /tmp/reset_token')
check "reset link opens" "$(code r1 -G --data-urlencode "token=$RT" "$B/password/reset" | cut -d' ' -f1)" "200"
t=$(token r1 "/password/reset?token=$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$RT")")
check "password changed with the link" "$(code r1 --data-urlencode "authenticity_token=$t" --data-urlencode "token=$RT" --data-urlencode "password=N3w-Str0ng-Passw0rd" --data-urlencode "password_confirmation=N3w-Str0ng-Passw0rd" "$B/password/reset" | cut -d' ' -f2)" "$B/login"
check "the same link cannot be used twice" "$(code r2 -G --data-urlencode "token=$RT" "$B/password/reset" | cut -d' ' -f2)" "$B/password/forgot"
check "bob logs in with the new password" "$(login bob2 bob N3w-Str0ng-Passw0rd | cut -d' ' -f1)" "302"
check "tampered link rejected" "$(code r3 -G --data-urlencode "token=${RT}x" "$B/password/reset" | cut -d' ' -f2)" "$B/password/forgot"

section "Profile changes need the current password"
t=$(token alice "/users/$A/edit")
code alice --data-urlencode "authenticity_token=$t" -d "_method=put" --data-urlencode "user[email]=evil@example.org" --data-urlencode "current_password=wrong" "$B/users/$A" >/dev/null
check "e-mail unchanged without the current password" "$(sql "select email from users where id=$A")" "alice@example.org"

section "nginx"
check "security headers" "$(curl -s -D - -o /dev/null "$B/" | grep -ciE '^(x-frame-options|referrer-policy|content-security-policy|x-content-type-options):')" "4"

section "Rails errors"
check "no 500 errors" "$(web_sh 'grep -c "Completed 500" log/production.log')" "0"
finish
