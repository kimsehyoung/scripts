#!/bin/bash
# https://eff-certbot.readthedocs.io/en/stable/using.html
# https://certbot-dns-cloudflare.readthedocs.io/en/stable/
# https://letsencrypt.status.io/
set -euxo pipefail

DOMAIN=domain.co.kr
SUB_DOMAIN="*.${DOMAIN}"
EMAIL="test@gmail.com"
RSA_KEY_SIZE=2048

docker run -it --rm --name certbot \
    -v ${CERT_HOME}/letsencrypt:/etc/letsencrypt \
    -v ${SECRET_HOME}/certbot/cloudflare.ini:${SECRET_HOME}/cloudflare.ini
    certbot/dns-cloudflare:v2.4.0 certonly \
    -d ${SUB_DOMAIN} --email ${EMAIL} \
    --dns-cloudflare \
    --dns-cloudflare-credentials ${SECRET_HOME}/cloudflare.ini \
    --non-interactive --agree-tos \
    --server https://acme-v02.api.letsencrypt.org/directory

sudo openssl dhparam -out ${CERT_HOME}/letsencrypt/live/${DOMAIN}/dhparam.pem ${RSA_KEY_SIZE}