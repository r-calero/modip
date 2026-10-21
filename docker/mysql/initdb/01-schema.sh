#!/bin/bash
# Loads the MODIP schema into $MYSQL_DATABASE. Runs only when the MySQL data
# volume is empty (first start).
#
# The dump creates and selects a database called `modip`; those two lines are
# dropped so the schema goes into the database named in .env (MODIP_DB_NAME).
set -e
schema=/modip/schema.sql
echo "MODIP: loading schema into database ${MYSQL_DATABASE}"
sed -e '/^CREATE DATABASE /d' -e '/^USE `/d' "$schema" \
  | MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --protocol=socket -uroot "$MYSQL_DATABASE"
echo "MODIP: schema loaded"
