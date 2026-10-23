#!/bin/bash
# Helpers shared by the end-to-end tests. They talk to a running MODIP stack
# through nginx (BASE_URL) and read MySQL through `docker compose exec`.
#
# Run them ONLY against a disposable test stack: they create and delete users,
# targets, queries and docking jobs. See tests/e2e/README.md.

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$ROOT"
B=${BASE_URL:-http://127.0.0.1:8484}
MAILPIT=${MAILPIT_URL:-}
PASSWORD=${TEST_PASSWORD:-Str0ng-Passw0rd-X}
CAPTCHA="cf-turnstile-response=XXXX.DUMMY.TOKEN.XXXX"   # accepted by Turnstile test keys
export COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.yml:docker-compose.apache.yml}
set -a; . ./.env; set +a
unset SSL_CERT_FILE SSL_KEY_FILE SSL_CERT_DIR             # .env values must not reach curl
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT

PASS=0; FAIL=0
ok()     { PASS=$((PASS+1)); echo "  OK   $1"; }
bad()    { FAIL=$((FAIL+1)); echo "  FAIL $1"; }
check()  { if [ "$2" = "$3" ]; then ok "$1 ($2)"; else bad "$1 (got: $2, expected: $3)"; fi; }
section(){ echo "== $1"; }
finish() { echo "PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]; }

sql()    { docker compose exec -T mysql mysql -N -u"$MODIP_DB_USER" -p"$MODIP_DB_PASSWORD" "$MODIP_DB_NAME" -e "$1" 2>/dev/null; }
web_sh() { docker compose exec -T web sh -c "$1" | tr -d '\r'; }
# HTTP status and redirect of a request made with the cookie jar $1.
code()   { curl -s -o /dev/null -w '%{http_code} %{redirect_url}' -c "$T/$1" -b "$T/$1" "${@:2}"; }
page()   { curl -s -c "$T/$1" -b "$T/$1" "$B$2" > "$T/$1.page"; }
# CSRF token of a page (jar $1, path $2); keeps the page for ftoken.
token()  { page "$1" "$2"; grep -oE 'content="[^"]+" name="csrf-token"|name="csrf-token" content="[^"]+"' "$T/$1.page" | grep -oE 'content="[^"]+"' | sed 's/content="//;s/"$//'; }
# Signed form timestamp of the last page fetched with jar $1.
ftoken() { grep -oE 'name="form_started" type="hidden" value="[^"]+"' "$T/$1.page" | sed 's/.*value="//;s/"$//'; }

# register NAME [extra curl args]: account with $PASSWORD (waits the form's minimum time).
register() {
  local t=$(token "$1" /users/new); local f=$(ftoken "$1"); sleep 3
  curl -s -o /dev/null -c "$T/$1" -b "$T/$1" --data-urlencode "authenticity_token=$t" --data-urlencode "form_started=$f" -d "$CAPTCHA" \
    --data-urlencode "user[name]=$1" --data-urlencode "user[email]=$1@example.org" --data-urlencode "user[password]=$PASSWORD" \
    --data-urlencode "user[password_confirmation]=$PASSWORD" "${@:2}" "$B/users"
}
# login JAR NAME PASSWORD: prints status and redirect.
login() {
  local t=$(token "$1" /login)
  code "$1" --data-urlencode "authenticity_token=$t" -d "$CAPTCHA" --data-urlencode "name=$2" --data-urlencode "password=$3" "$B/login"
}
json_get() { python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$1'))"; }
