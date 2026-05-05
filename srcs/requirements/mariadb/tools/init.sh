#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# INIT SYSTEM TABLES (CRUCIAL)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=root --datadir=/var/lib/mysql
fi

# Start MariaDB
mysqld_safe --bind-address=0.0.0.0 &

# Wait
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB is ready!"

# INIT DB ONLY ONCE
if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "Creating database..."

    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.initialized
fi

# Restart clean
mysqladmin -u root shutdown

exec mysqld_safe --bind-address=0.0.0.0