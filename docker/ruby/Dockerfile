# Ruby image shared by every MODIP service.
#
#   target "app":     web (PIAM), database and download servers
#   target "docking": docking server (adds AutoDock Vina and AutoDockTools)
#
# Ruby 2.2.10 on Debian 8 (jessie) runs the locked stack (Rails 3.2.8,
# json 1.8.3, mysql2 0.3.17, therubyracer 0.12.1) without changing any gem
# version in PIAM/Gemfile.lock. Debian 8 also ships the tools of that era:
# MySQL 5.5 client, Open Babel 2.3.2, AutoDock Vina 1.1.2, MGLTools 1.5.7.

# Up-to-date CA certificates, so TLS to PubChem/NCBI works on the old base.
FROM debian:bookworm-slim AS certs
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

FROM ruby:2.2.10 AS base

# Debian 8 lives in archive.debian.org now (its signing keys expired).
RUN printf '%s\n' \
      'deb [trusted=yes] http://archive.debian.org/debian jessie main contrib non-free' \
      'deb [trusted=yes] http://archive.debian.org/debian-security jessie/updates main' \
      > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libmysqlclient-dev openbabel tzdata \
 && rm -rf /var/lib/apt/lists/*

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# The base image ships Bundler 1.16.1 in three places; leave only 1.11.2,
# the version that wrote Gemfile.lock.
ENV BUNDLER_VERSION=1.11.2
RUN gem uninstall -i /usr/local/lib/ruby/gems/2.2.0 bundler -v 1.16.1 -x \
 && rm -rf /usr/local/lib/ruby/gems/2.2.0/specifications/default/bundler-*.gemspec \
           /usr/local/lib/ruby/site_ruby/2.2.0/bundler /usr/local/lib/ruby/site_ruby/2.2.0/bundler.rb \
 && gem install bundler -v 1.11.2 --no-document --force \
 && gem install libv8 -v 3.16.14.13 --platform x86_64-linux --no-document

# Project gems (not on rubygems.org): install them before bundling so Bundler
# uses these builds instead of downloading same-named public gems.
WORKDIR /src
COPY entrez /src/entrez
COPY DownloadEngine /src/DownloadEngine
COPY Docking /src/Docking
RUN cd /src/entrez && git init -q && git add -A && gem build -q entrez.gemspec \
 && gem install --local --ignore-dependencies --no-document entrez-*.gem \
 && cd /src/DownloadEngine && gem build -q download_engine.gemspec \
 && gem install --local --ignore-dependencies --no-document download_engine-*.gem \
 && cd /src/Docking && gem build -q docking.gemspec \
 && gem install --local --no-document docking-*.gem \
 && rm -rf /src

WORKDIR /app
COPY PIAM/Gemfile PIAM/Gemfile.lock /app/PIAM/
RUN cd /app/PIAM && bundle install --jobs 4 --retry 3

RUN groupadd --gid 1000 modip && useradd --uid 1000 --gid modip --create-home modip
COPY docker/ruby/drb-healthcheck /usr/local/bin/drb-healthcheck
RUN chmod 755 /usr/local/bin/drb-healthcheck

# Docking tools. Separate stage so code changes do not reinstall them.
FROM base AS docking-tools
RUN apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends autodock-vina autodocktools \
 && rm -rf /var/lib/apt/lists/* \
 && printf '#!/bin/sh\n# MGLTools "pythonsh": python 2 with MolKit/AutoDockTools\nexec python2 "$@"\n' > /usr/local/bin/pythonsh \
 && chmod 755 /usr/local/bin/pythonsh

FROM base AS app
COPY --chown=modip:modip PIAM /app/PIAM
COPY --chown=modip:modip Server /app/Server
RUN cd /app/PIAM && RAILS_ENV=production ENTREZ_EMAIL=build@localhost bundle exec rake assets:precompile \
 && mkdir -p /app/PIAM/log /app/PIAM/tmp /app/Server/data /app/Server/log /app/Server/tmp \
 && chown -R modip:modip /app
USER modip

FROM docking-tools AS docking
COPY --chown=modip:modip PIAM /app/PIAM
COPY --chown=modip:modip Server /app/Server
RUN mkdir -p /app/Server/data /app/Server/log /app/Server/tmp && chown -R modip:modip /app
USER modip
