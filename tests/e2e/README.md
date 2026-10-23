# End-to-end tests

Shell scripts that exercise a running MODIP stack through nginx, the way a
browser does (sessions, CSRF tokens, captcha, forms), and check the results in
MySQL and in the containers.

**They create and delete users, targets, queries and docking jobs. Run them
only on a disposable test stack, never on production data.**

## Run

```bash
# Test settings (Turnstile test keys always accept; high rate limits for the tests)
export COMPOSE_FILE=docker-compose.yml:docker-compose.apache.yml \
       MODIP_ADMIN_USERS=admin1 MODIP_FORCE_SSL=false \
       MODIP_CAPTCHA_SITE_KEY=1x00000000000000000000AA \
       MODIP_CAPTCHA_SECRET=1x0000000000000000000000000000000AA \
       NGINX_AUTH_RATE=1000r/m NGINX_JOBS_RATE=1000r/m

docker compose down -v        # empty database
docker compose up -d --build

tests/e2e/security.sh && tests/e2e/docking.sh && tests/e2e/ui.sh
```

| Script | What it checks |
|---|---|
| `security.sh` | Roles and ownership, mass assignment, file access, CVE-2013-0156, registration and login protection, bcrypt, password reset, headers; downloads AID 1000 from PubChem |
| `docking.sh` | PDB receptor preparation, docking queue and progress, cancel, restart recovery, exports, admin page |
| `ui.sh` | Layout, flash messages, structure images, 3D viewer and energy chart (also in headless Chrome when available) |

Optional variables: `BASE_URL` (default `http://127.0.0.1:8484`),
`MAILPIT_URL` (to check e-mails sent to a [Mailpit](https://mailpit.axllent.org)
SMTP server, e.g. `http://127.0.0.1:18025`), `CHROME` (browser binary).
They need network access to PubChem and RCSB.
