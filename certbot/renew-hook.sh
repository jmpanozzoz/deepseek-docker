#!/bin/sh
docker compose stop nginx
docker compose run --rm certbot renew
docker compose start nginx