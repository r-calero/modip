# Remote conversion worker

A conversion worker turns the 2D compounds downloaded by MODIP into 3D
structures with Open Babel (`--gen3D`). The main stack already runs one
(`converter` service); remote workers on other machines of the private network
add capacity. A worker only connects to the conversion broker of the main
server, over mutual TLS. It never connects to MySQL and has no access to the
MODIP data.

Each worker runs one conversion at a time with `MODIP_BABEL_THREADS` threads
(4; more threads do not make Open Babel faster). On a machine with many cores,
start one worker per 4 cores with `--scale converter=N`; the replicas share
the same certificate. Do not give Open Babel one thread per core: it slows
down badly as soon as anything else uses the CPU.

## 1. On the main server

In `.env`:

```
MODIP_CONVERSION_BIND=10.0.0.10            # private address of the main server
MODIP_CONVERSION_PUBLIC_HOST=10.0.0.10     # address the workers use
MODIP_CONVERSION_BROKER_HOSTS=10.0.0.10    # names/IPs in the broker certificate
MODIP_CONVERSION_WORKERS=local,lab-02      # allowed workers
```

Then:

```
docker compose run --rm certs renew-broker       # only if the hosts changed
docker compose run --rm -T certs worker lab-02 > lab-02.tar.gz
docker compose up -d conversion-broker
```

`lab-02.tar.gz` contains the CA certificate, the certificate and private key
of the worker and a filled `.env.worker`. Copy it to the worker machine over a
secure channel (scp) and delete it from the main server afterwards.

Allow port 7443 on the main server only from the worker machines, for example:

```
ufw allow from 10.0.0.21 to any port 7443 proto tcp
```

## 2. On the worker machine

Requirements: Docker with Compose v2, x86_64 (or amd64 emulation).

```
git clone https://github.com/r-calero/modip.git
cd modip/deploy/worker
tar -xzf ~/lab-02.tar.gz
sudo chown -R 1000:1000 certs && chmod 600 certs/worker.key
docker compose -f docker-compose.worker.yml up -d --build
docker compose -f docker-compose.worker.yml logs -f
```

The worker appears in the Admin page of MODIP (section "3D conversions") after
its first request.

Instead of building, the image can be copied from the main server:
`docker save modip/converter:latest | ssh lab-02 docker load`.

## Revoking a worker

Remove its name from `MODIP_CONVERSION_WORKERS` and recreate the broker
(`docker compose up -d conversion-broker`). Its requests are rejected from
then on. A conversion it had in progress goes back to the queue after
`MODIP_CONVERSION_LEASE` seconds.
