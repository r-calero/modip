# Puma 1.6 configuration (used by docker-compose.yml and the Procfile).
#
# One process with threads: the DRb observers that receive download/docking
# notifications live in this process, so Puma must not fork workers.
threads Integer(ENV['PUMA_MIN_THREADS'] || 1), Integer(ENV['PUMA_MAX_THREADS'] || 16)
bind "tcp://0.0.0.0:#{ENV['MODIP_WEB_PORT'] || ENV['PORT'] || 3000}"
environment ENV['RACK_ENV'] || 'production'
