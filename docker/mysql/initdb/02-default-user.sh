#!/bin/bash
# Default account used by the web app when nobody is logged in
# (User::DefaultUser / User::DefaultPass = "test" / "test").
# hashed_password = SHA256(password + "wibble" + salt), as in app/models/user.rb.
set -e
echo "MODIP: creating default user 'test'"
MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --protocol=socket -uroot "$MYSQL_DATABASE" <<'SQL'
INSERT INTO users (name, email, hashed_password, salt)
SELECT 'test', 'test@localhost', '88338c898815899b6af0adac6ae19b63cfa0aec1e4b72b0d59f07a80e3acb8b4', 'modip-docker-default-user'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM users WHERE name = 'test');
SQL
