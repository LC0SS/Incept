#!/bin/bash

set -e

WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

echo "Checking WordPress files..."

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Installing WordPress..."

    mkdir -p /var/www/html
    cd /var/www/html

    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz

    chown -R www-data:www-data /var/www/html

    echo "Waiting for MariaDB..."
    until mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" > /dev/null 2>&1; do
        sleep 2
    done

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost=mariadb \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    echo "Create user..."
    wp user create \
    "$WP_USER" \
    "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD" \
    --role=subscriber \
    --allow-root

    chown -R www-data:www-data /var/www/html

    echo "WordPress installed!"
else
    echo "WordPress already installed"
fi

exec php-fpm8.2 -F