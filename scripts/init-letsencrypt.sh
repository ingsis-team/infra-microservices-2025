#!/bin/bash

# Script para inicializar Let's Encrypt con Certbot
# Basado en: https://github.com/wmnnd/nginx-certbot

set -e

# Cargar variables de entorno
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

domains=($DOMAIN_NAME)
rsa_key_size=4096
data_path="./certbot"
email="$LETSENCRYPT_EMAIL" # Debe estar en .env
staging=${STAGING:-0} # Set to 1 if you're testing

echo "### Preparando directorios..."
mkdir -p "$data_path/conf"
mkdir -p "$data_path/www"

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Descargando parámetros TLS recomendados..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creando certificados dummy para $domains..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" reverse-proxy
echo

echo "### Iniciando nginx..."
docker-compose up --force-recreate -d reverse-proxy
echo

echo "### Eliminando certificados dummy para $domains..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" reverse-proxy
echo

echo "### Solicitando certificado de Let's Encrypt para $domains..."

# Habilitar staging mode si es necesario
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    --email $email \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d $domains" reverse-proxy
echo

echo "### Recargando nginx..."
docker-compose exec reverse-proxy nginx -s reload

echo "### ¡Listo! HTTPS configurado correctamente."

