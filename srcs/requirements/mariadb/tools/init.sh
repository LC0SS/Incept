#!/bin/bash

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)

mysqld_safe &

while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB is ready!"

if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "Initializing database..."

    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.initialized
fi

mysqladmin -u root shutdown

exec mysqld_safe