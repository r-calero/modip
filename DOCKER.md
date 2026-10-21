# Despliegue de MODIP con Docker Compose

## Arquitectura

Cada servidor de MODIP corre en su propio contenedor. Se comunican por dRuby
dentro de la red interna `modip`; solo nginx publica puertos.

```
 Internet ──HTTPS──> nginx ──HTTP──> web (PIAM, Rails 3.2.8 + Puma 1.6.3)
                                      │ dRuby            ▲ dRuby (notificaciones)
                                      ├──> download ─────┘──> database ──> mysql
                                      │    (PubChem REST)     (ActiveRecord)
                                      └──> docking ───────────────────────> mysql
                                           (Open Babel, Vina, AutoDockTools)
```

| Servicio   | Qué ejecuta                  | dRuby (interno)          |
|------------|------------------------------|--------------------------|
| `mysql`    | MySQL 5.7.44                 | —                        |
| `database` | `Server/database_server.rb`  | `druby://database:9001`  |
| `download` | `Server/download_server.rb`  | `druby://download:1989`  |
| `docking`  | `Server/docking_server.rb`   | `druby://docking:1997`   |
| `web`      | PIAM (Rails) en Puma         | `druby://web:9100` (callbacks) |
| `nginx`    | Proxy HTTPS                  | —                        |

`download` y `docking` comparten el volumen `modip_data` (`Server/data`), porque
las rutas de los compuestos guardadas en MySQL apuntan a él.

## Versiones

| Componente | Versión | Motivo |
|---|---|---|
| Ruby | 2.2.10 (Debian 8) | La más nueva que ejecuta el `Gemfile.lock` sin cambiar ninguna gema (json 1.8.3 no compila en Ruby ≥ 2.4) |
| Bundler | 1.11.2 | La que generó el `Gemfile.lock` |
| Gemas | Las del `PIAM/Gemfile.lock` (Rails 3.2.8, mysql2 0.3.17, therubyracer 0.12.1…) | Sin cambios |
| download_engine / entrez / docking | 2.0.0 / 0.5.8.3 / 0.0.1 | Se compilan desde este repositorio |
| MySQL | 5.7.44, `sql_mode=NO_ENGINE_SUBSTITUTION` | Compatible con el cliente MySQL 5.5 de mysql2 0.3.17 y con el volcado de 5.5 |
| Open Babel / AutoDock Vina / MGLTools | 2.3.2 / 1.1.2 / 1.5.7 | Paquetes de Debian 8 |
| nginx | 1.27-alpine | TLS 1.2/1.3, HTTP/2 |

Las imágenes son `linux/amd64` (MySQL 5.7 y libv8 no existen para ARM).

## Puesta en marcha

1. Requisitos: Docker Engine 24+ con Compose v2, en un host x86_64.
2. Configuración:
   ```bash
   cp .env.example .env
   openssl rand -hex 64      # pega el resultado en MODIP_SECRET_TOKEN
   ```
   Edita en `.env` como mínimo: `MODIP_SERVER_NAME`, las claves de MySQL
   (`MYSQL_ROOT_PASSWORD`, `MODIP_DB_PASSWORD`), `MODIP_SECRET_TOKEN` y el SMTP.
3. Certificados: copia el certificado y la clave en la carpeta de
   `SSL_CERT_DIR` (por defecto `docker/nginx/certs/`) con los nombres de
   `SSL_CERT_FILE` y `SSL_KEY_FILE` (por defecto `fullchain.pem` y `privkey.pem`).
   Si usas Let's Encrypt, apunta `SSL_CERT_DIR` a `/etc/letsencrypt/live/<dominio>`.
4. Arranque:
   ```bash
   docker compose up -d --build
   docker compose ps          # todos deben quedar "healthy"
   ```
   Arrancan en orden: mysql → database → download/docking → web → nginx.

La primera vez que el volumen de MySQL está vacío se carga el esquema de
`MODIP_DB_SCHEMA_FILE` (por defecto `database_schema-2015-6-10.sql`, el más
reciente) en la base `MODIP_DB_NAME`, y se crea el usuario `test`/`test` que la
web usa cuando nadie ha iniciado sesión.

### Detrás de un Apache que ya maneja los certificados

Apache termina TLS y hace de proxy a nginx, que sirve solo HTTP en
`127.0.0.1:8484` y no necesita certificados:

```
Navegador ──HTTPS──> Apache (certificados) ──HTTP──> nginx 127.0.0.1:8484 ──> web
```

1. En `.env`:
   ```
   COMPOSE_FILE=docker-compose.yml:docker-compose.apache.yml
   NGINX_BIND_ADDRESS=127.0.0.1     # 0.0.0.0 si Apache está en otra máquina
   NGINX_PROXY_PORT=8484
   MODIP_SERVER_NAME=modip.example.org
   ```
   `SSL_*`, `NGINX_HTTP_PORT`, `NGINX_HTTPS_PORT` y `MODIP_HTTPS_REDIRECT_PORT` no se usan en este
   modo. Hace falta Docker Compose 2.24.4 o posterior.
2. En Apache, partiendo de [docker/apache/modip-vhost.conf](docker/apache/modip-vhost.conf):
   ```bash
   sudo a2enmod ssl proxy proxy_http headers
   sudo cp docker/apache/modip-vhost.conf /etc/apache2/sites-available/modip.conf
   sudo nano /etc/apache2/sites-available/modip.conf   # ServerName y rutas de certificados
   sudo a2ensite modip && sudo apachectl configtest && sudo systemctl reload apache2
   ```
3. `docker compose up -d --build`

Lo esencial del virtualhost es `ProxyPreserveHost On` (Rails usa el nombre
público) y `RequestHeader set X-Forwarded-Proto "https"` (Rails genera enlaces y
redirecciones `https://`). En CentOS/RHEL, los módulos se cargan en
`/etc/httpd/conf.modules.d/` y, con SELinux, hace falta
`setsebool -P httpd_can_network_connect 1` para que Apache conecte al puerto 8484.

### Puertos distintos de 80/443

```
NGINX_HTTP_PORT=8484
NGINX_HTTPS_PORT=8443
MODIP_HTTPS_REDIRECT_PORT=:8443
```

### Renovar certificados (certbot webroot)

nginx sirve `/.well-known/acme-challenge/` desde `ACME_WEBROOT_DIR`:
```bash
certbot certonly --webroot -w ./docker/nginx/acme -d modip.example.org
docker compose exec nginx nginx -s reload
```

## Operación

```bash
docker compose logs -f web download          # logs en vivo
docker compose restart download              # reiniciar un servicio
docker compose exec mysql sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > backup.sql
docker compose up -d --build                 # actualizar tras un git pull
```

- MySQL se publica solo en `127.0.0.1:${MYSQL_HOST_PORT}` del host, para
  administración (por ejemplo, para lanzar consultas SQL de diagnóstico).
- Volúmenes: `mysql_data`, `modip_data` (ensayos, compuestos, dianas),
  `download_log` (`Server/log/service.log`) y `web_log` (`PIAM/log`).

### Migrar una instalación existente

```bash
docker compose up -d mysql
docker compose exec -T mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < volcado.sql
docker compose up -d download
docker compose cp /ruta/antigua/Server/data/. download:/app/Server/data/
docker compose exec -u root download chown -R modip:modip /app/Server/data
docker compose up -d
```

## Cambios en el código para Docker

Todos leen variables de entorno y, si no existen, usan los valores de antes,
así que la instalación sin Docker sigue funcionando igual.

- URIs dRuby: `MODIP_DATABASE_DRB_URI`, `MODIP_DOWNLOAD_DRB_URI`,
  `MODIP_DOCKING_DRB_URI` (servidores y clientes) y `MODIP_WEB_DRB_URI`
  (dirección de callbacks de la web).
- MySQL: `MODIP_DB_*` en `Server/database_configuration.rb` y en
  `PIAM/config/database.yml` (producción).
- SMTP (`MODIP_SMTP_*`), `MODIP_SECRET_TOKEN` y `MODIP_SERVE_STATIC_ASSETS`.
- `config.assets.initialize_on_precompile = false`, para precompilar assets sin
  conectarse a MySQL ni a dRuby.
- `PIAM/lib/ruby2_compat.rb`: la corrección de una línea de Sass 3.2 y de
  Sprockets 2.2 aplicada a Sass 3.1.15 y Sprockets 2.1.3. Con Ruby ≥ 2.0, sin
  ella el CSS no se comprime y se ignoran los `//= require` de los assets
  (jQuery y Bootstrap no se incluyen).

## Notas

- La web corre en un único proceso Puma con hilos (`PUMA_MIN_THREADS`/
  `PUMA_MAX_THREADS`). Es obligatorio: los observers que reciben las
  notificaciones por dRuby viven en memoria de ese proceso. `PIAM/config/puma.rb`
  no se usa (sus directivas son de Puma 2+).
- Los puertos dRuby no se publican fuera de la red interna: dRuby no tiene
  autenticación.
- Para repartir los servicios en varios hosts, la red `modip` puede ser una red
  overlay de Docker Swarm. Los nombres de servicio siguen resolviendo igual,
  pero `download` y `docking` necesitan el mismo almacenamiento compartido
  (por ejemplo NFS) para `modip_data`.
