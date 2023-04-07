#!/bin/bash
# https://letsencrypt.status.io/
DOMAIN=domain.co.kr
SUB_DOMAIN="*.${DOMAIN}"
EMAIL="test@gmail.com"
RSA_KEY_SIZE=2048
PATH="$PWD/certbot"

docker run -it --rm --name certbot \
        -v "$PATH/etc/letsencrypt":/etc/letsencrypt \
        -v "$PATH/var/lib/letsencrypt":/var/lib/letsencrypt \
        certbot/certbot:v2.0.0 certonly \
        -d ${SUB_DOMAIN} --email ${EMAIL} \
        --manual --preferred-challenges dns \
        --rsa-key-size ${rsa_key_size} \
        --agree-tos --force-renewal \
        --server https://acme-v02.api.letsencrypt.org/directory -v

sudo openssl dhparam -out $PATH/etc/letsencrypt/live/${DOMAIN}/dhparam.pem ${RSA_KEY_SIZE}