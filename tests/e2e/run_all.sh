#!/bin/bash
# Rebuilds a DISPOSABLE test stack (docker compose down -v: the database and
# the data volumes are deleted) and runs the e2e suites.
#
#   tests/e2e/run_all.sh                          # every suite
#   SUITES="security ui" tests/e2e/run_all.sh     # some of them
set -u
cd "$(dirname "$0")/../.."
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
export COMPOSE_FILE=docker-compose.yml:docker-compose.apache.yml MYSQL_HOST_PORT=13306 MODIP_ADMIN_USERS=admin1 MODIP_FORCE_SSL=false \
  MODIP_CAPTCHA_SITE_KEY=1x00000000000000000000AA MODIP_CAPTCHA_SECRET=1x0000000000000000000000000000000AA \
  NGINX_AUTH_RATE=1000r/m NGINX_JOBS_RATE=1000r/m MODIP_SMTP_ADDRESS=mailpit MODIP_SMTP_PORT=1025 MODIP_SMTP_STARTTLS=false \
  MODIP_SMTP_USER=modip@example.org MODIP_SMTP_PASSWORD=x MAILPIT_URL=http://127.0.0.1:18025 \
  MODIP_CONVERSION_WORKERS=local,lab-02
docker compose down -v >/dev/null 2>&1; docker rm -f modip-mailpit >/dev/null 2>&1
docker compose build 2>&1 | grep -E "ERROR|aborted|Built"
docker compose up -d 2>&1 | grep -i " error"
docker run -d --name modip-mailpit --network modip_net --network-alias mailpit -p 127.0.0.1:18025:8025 axllent/mailpit:v1.21.8 --smtp-auth-accept-any --smtp-auth-allow-insecure >/dev/null
for i in $(seq 1 60); do s=$(docker compose ps -a --format '{{.Service}}={{.Health}}' | tr '\n' ' '); echo "$s" | grep -q "nginx=healthy" && break; sleep 5; done
echo "stack: $s"
for suite in ${SUITES:-security docking downloads conversion ui}; do
  echo "### $suite"
  tests/e2e/$suite.sh 2>&1 | grep -E "FAIL|PASS=|progress seen|download time|conversions ended"
done
