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

 download ──(compuestos 2D)──> conversion_jobs (MySQL)
                                      ▲
 converter(es) ──TLS mutuo──> conversion-broker
 (Open Babel; locales o en otros equipos de la red privada)
```

| Servicio   | Qué ejecuta                  | dRuby (interno)          |
|------------|------------------------------|--------------------------|
| `mysql`    | MySQL 5.7.44                 | —                        |
| `database` | `Server/database_server.rb`  | `druby://database:9001`  |
| `download` | `Server/download_server.rb`  | `druby://download:1989`  |
| `docking`  | `Server/docking_server.rb`   | `druby://docking:1997`   |
| `web`      | PIAM (Rails) en Puma         | `druby://web:9100` (callbacks) |
| `nginx`    | Proxy HTTPS                  | —                        |
| `conversion-broker` | `Server/conversion_broker.rb` | `drbssl://conversion-broker:7443` (TLS mutuo) |
| `converter` | `Server/conversion_worker.rb` (Open Babel) | — (cliente del broker) |
| `certs`    | `deploy/conversion/certs.sh` (se ejecuta y termina) | — |

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
  `download_log` (`Server/log/service.log`), `web_log` (`PIAM/log`) y
  `modip_certs` (CA y certificados de las conversiones; incluye la clave
  privada de la CA, conviene respaldarlo).

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

Todos leen variables de entorno. Las credenciales (MySQL y `MODIP_SECRET_TOKEN`)
ya no tienen valores por defecto en el código: también fuera de Docker hay que
definirlas en el entorno.

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

## Usuarios y permisos

| Rol | Quién | Qué puede hacer |
|---|---|---|
| Invitado | Sin sesión | Leer: ensayos, compuestos, dianas, ranking de resultados, ayuda |
| Registrado | Cuenta personal | Lo anterior, más sus propias consultas, descargas y dockings |
| Administrador | Usuarios de `MODIP_ADMIN_USERS` | Lo anterior, más gestionar dianas, receptores, tipos de receptor y ciclos |

- `MODIP_ADMIN_USERS`: nombres de usuario separados por comas. Si está vacío,
  todos los usuarios registrados son administradores (comportamiento antiguo).
- `MODIP_GUEST_MODE=readonly` (por defecto): los visitantes sin sesión solo
  leen, y no se puede iniciar sesión con la cuenta compartida `test`.
- `MODIP_GUEST_MODE=full`: los visitantes trabajan como la cuenta compartida
  `test`, como en versiones anteriores, pero sin permisos de administración y
  sin poder modificar esa cuenta.
- `MODIP_SECRET_TOKEN` es obligatorio en producción: la web no arranca sin él.

## Seguridad de cuentas y formularios

| Variable | Por defecto | Qué hace |
|---|---|---|
| `MODIP_CAPTCHA_SITE_KEY`, `MODIP_CAPTCHA_SECRET` | vacías | Claves de Cloudflare Turnstile (https://dash.cloudflare.com → Turnstile). Sin ellas el captcha está desactivado. |
| `MODIP_REQUIRE_EMAIL_CONFIRMATION` | `false` | `true`: la cuenta solo se crea al abrir el enlace enviado por correo (necesita SMTP funcionando). |
| `MODIP_PASSWORD_MIN_LENGTH` | `12` | Longitud mínima de las contraseñas nuevas. |
| `MODIP_FORCE_SSL` | `true` | La app solo funciona por HTTPS (HSTS, cookies `secure`). `false` solo para pruebas locales sin TLS. |
| `NGINX_AUTH_RATE`, `NGINX_JOBS_RATE` | `10r/m`, `20r/m` | Peticiones `POST` por IP a login/registro/recuperación de contraseña, y al arranque de descargas y dockings (con ráfaga de 5). Por encima responde 429. |
| `MODIP_DRB_ALLOW` | redes privadas | Redes que pueden conectarse a los servidores dRuby (separadas por espacios). |

Además:
- **Registro:** captcha, campo trampa (honeypot) y tiempo mínimo de 3 segundos para rellenar el formulario.
- **Login:** tras 3 fallos desde una IP pide captcha; tras 5 fallos para un mismo usuario, o 20 desde una IP, bloquea 15 minutos.
- **Contraseñas** con bcrypt. Las cuentas antiguas (SHA-256) siguen funcionando y se convierten a bcrypt en su siguiente login correcto.
- **"Forgot your password?"** envía un enlace firmado, válido una hora y de un solo uso.
- **Perfil:** cambiar la contraseña o el correo pide la contraseña actual.
- **Acciones que cambian estado** (iniciar o parar descargas, cancelar dockings) son `POST`, protegidas contra CSRF.

Para tareas sueltas dentro del contenedor web (consola, `rails runner`), usa
`MODIP_NO_DRB=true` para que no intenten levantar un segundo servidor dRuby:
```bash
docker compose exec -e MODIP_NO_DRB=true web bundle exec rails console production
```

## Migraciones de la base de datos

El servicio `migrate` aplica las migraciones pendientes (`PIAM/db/migrate`) en
cada `docker compose up` y termina; `database`, `docking` y `web` esperan a que
acabe. Sirve también para bases creadas desde el volcado SQL: las migraciones
de 2013 se registran como ya aplicadas y solo se ejecutan las nuevas.
```bash
docker compose run --rm migrate      # aplicarlas a mano
```

## Trabajos de docking

- Cada docking es un trabajo guardado en MySQL (`docking_jobs`, con un registro
  por compuesto en `docking_job_logs`). El servidor de docking los ejecuta de
  uno en uno, en orden de llegada.
- La página del trabajo muestra el progreso, el compuesto en curso y el
  registro, leyendo la base de datos cada 2 segundos. Se puede recargar o
  cerrar sin perder nada. *Docking → My jobs* lista todos los trabajos.
- **Cancelar** detiene el Vina en curso y no procesa más compuestos.
- Si el servidor de docking se reinicia, los trabajos en curso se retoman desde
  el primer compuesto pendiente.
- Al terminar, el usuario recibe un correo con los mejores resultados (si el
  SMTP funciona). Tras una descarga, los compuestos nuevos se encolan solos si
  la diana tiene receptores.
- El panel *Admin* muestra el resumen del sistema, los usuarios (se pueden
  borrar) y los trabajos de todos (se pueden cancelar).
- La barra de progreso es verde si el trabajo terminó bien (que un compuesto
  no dé poses es un resultado válido), naranja si algún compuesto no se pudo
  dockear (quedó en 2D, no existe o dio error), roja si el trabajo falló y gris
  si se canceló.
- Exportaciones: el ranking en CSV y las poses en `.tar.gz` (de un trabajo o de
  toda la diana).
- Los receptores se pueden subir ya preparados (`.pdbqt`) o como `.pdb`: MODIP
  los prepara con AutoDockTools y añade los hidrógenos polares.

## Rendimiento de las descargas

- Los ensayos de una consulta se descargan en paralelo (`MODIP_DOWNLOAD_THREADS`,
  2 por defecto) respetando el límite de PubChem (5 peticiones/s por IP).
- Los compuestos se piden por lotes de 100 (una petición para los registros 3D
  y otra para los 2D), y las filas de los ensayos se guardan por lotes, con
  índices nuevos en MySQL (`compounds.cid`, `assays.aid`, etc.).
- Los compuestos que PubChem no tiene en 3D se guardan en 2D y se encolan
  para convertirlos (ver *Conversiones 2D → 3D*), así la descarga no espera a
  Open Babel.
- En el docking, cada ligando se prepara una vez y se reutiliza
  (`data/Ligands`).
- La barra de progreso de las consultas la calcula el servidor de descargas
  (ensayos completados más la fracción de los que están en curso) y la página
  la consulta cada 2 segundos.
- Cada consulta guarda el resultado de su última ejecución (*last run*):
  `never`, `running`, `complete`, `partial` (falló algún ensayo o compuesto),
  `failed` (error general), `stopped` (detenida por el usuario) o
  `interrupted` (el servidor de descargas se reinició durante la descarga),
  con las horas y un resumen (ensayos y compuestos nuevos, ya guardados,
  encolados a 3D, descartados y fallidos). Al terminar, la barra se pone verde,
  naranja o roja según ese resultado; la de conversiones, verde o naranja si
  alguna falló. *Admin* cuenta las consultas por resultado.
- Las confirmaciones (borrar, cancelar, reintentar) usan un modal de la propia
  aplicación en vez del diálogo del navegador.

## Conversiones 2D → 3D

Convertir a 3D con Open Babel (`--gen3D`) tarda unos 40 s por molécula, así
que no se hace durante la descarga:

1. La descarga guarda el compuesto en 2D, crea un trabajo en `conversion_jobs`
   y sigue (evento `CompoundQueued3D`).
2. Los workers (`converter`) piden trabajos al `conversion-broker`, convierten
   y devuelven el SDF en 3D. El broker lo valida (mismo CID y número de átomos
   pesados, coordenadas z no nulas, máximo 5 MB), lo guarda en
   `data/Compounds/3D` y marca el compuesto como 3D (fuente MODIP).
3. El docking que se lanza al terminar la descarga queda **waiting** mientras
   haya conversiones pendientes de sus compuestos. Cuando todas terminan pasa a
   la cola y dockea los que llegaron a 3D; los que quedaron en 2D aparecen en
   el registro como no procesados.

Detalles:

- Un worker hace una conversión a la vez; se pueden poner más
  (`MODIP_CONVERSION_LOCAL_WORKERS`, uno por cada 4 núcleos libres más o menos,
  teniendo en cuenta que el docking corre en el mismo equipo). Cada conversión usa
  `MODIP_BABEL_THREADS` hilos (4): con un hilo por núcleo, Open Babel se queda
  casi parado en cuanto el docking usa la CPU (medido: más de 120 s frente a
  unos 8 s con 4 hilos para la misma molécula).
- Cada conversión tiene un máximo de `MODIP_BABEL_TIMEOUT` segundos (300). Si
  se supera o falla, el compuesto queda en 2D y el trabajo en `timeout` o
  `failed`. **No se reintenta solo**: en *Admin → 3D conversions* hay
  *Retry* por trabajo y *Retry all*, con `MODIP_BABEL_RETRY_TIMEOUT` (900 s).
- Si un worker deja de dar señales (heartbeat) durante
  `MODIP_CONVERSION_LEASE` segundos (120), su trabajo vuelve a la cola; a la
  segunda vez se marca como fallido. Un worker que se detiene devuelve su
  trabajo a la cola.
- *Admin → 3D conversions* muestra una tabla con los workers que contactaron
  al broker en el último día: estado (*converting*, *idle* o *disconnected*
  tras 2 minutos sin contacto), compuesto en curso, último contacto y
  conversiones hechas y fallidas en 24 h. El broker anota a cada worker
  (`conversion_workers`) aunque no tenga trabajo. Hay también un botón para
  encolar los compuestos 2D descargados antes de existir la cola.
- La barra de la consulta muestra una segunda barra con las conversiones, y la
  ficha del compuesto indica si está en 3D o el estado de su conversión.
- `MODIP_CONVERSION_MODE=inline` vuelve al comportamiento anterior (la
  descarga convierte ella misma).

### Seguridad del broker

- Broker y workers se autentican con TLS mutuo (`drbssl://`). Todos los
  certificados los firma una CA propia de la instalación que crea el servicio
  `certs` en el primer arranque (volumen `modip_certs`).
- El nombre (CN) del certificado del worker es su identidad y debe estar en
  `MODIP_CONVERSION_WORKERS`; quitarlo lo revoca. Los workers comprueban que el
  certificado del broker es `conversion-broker`.
- Además hay una lista de redes permitidas (`MODIP_CONVERSION_ALLOW`, por
  defecto rangos privados) y el puerto se publica solo en
  `MODIP_CONVERSION_BIND` (`127.0.0.1` por defecto: solo workers locales).
- Los workers no tienen acceso a MySQL ni al volumen de datos: reciben el SDF
  en 2D y devuelven el 3D. Las horas de lease se calculan con el reloj de
  MySQL, no con el de los workers.

```bash
docker compose run --rm certs list             # certificados emitidos
docker compose run --rm certs renew-broker     # tras cambiar MODIP_CONVERSION_BROKER_HOSTS
docker compose logs -f conversion-broker converter
```

### Workers en otros equipos

Ver [deploy/worker/README.md](deploy/worker/README.md). En resumen: en el
servidor se ajustan `MODIP_CONVERSION_BIND`, `MODIP_CONVERSION_PUBLIC_HOST` y
`MODIP_CONVERSION_WORKERS`, se genera el paquete del worker con
`docker compose run --rm -T certs worker NOMBRE > NOMBRE.tar.gz` y en el otro
equipo se descomprime en `deploy/worker` y se arranca
`docker compose -f docker-compose.worker.yml up -d --build`. El puerto 7443
debe abrirse solo para los equipos de los workers.

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
