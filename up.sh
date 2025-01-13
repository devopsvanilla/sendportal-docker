#!/usr/bin/env bash

for var in $(grep -v '^#' .env | sed 's/=.*//'); do
    unset $var
done

export $(grep -v '^#' .env | xargs)

APP_KEY=$(openssl rand -base64 32) && sed -i "s|^APP_KEY=.*$|APP_KEY=base64:${APP_KEY}|" .env

docker-compose down

docker-compose up -d --build

docker exec -it ${APP_NAME}-app sh -c "cd /var/www/html && php artisan sp:install"
