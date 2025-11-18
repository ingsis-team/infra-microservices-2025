#!/bin/bash

# Script para renovar certificados de Let's Encrypt
# Ejecutar este script periódicamente (ej: cronjob semanal)

set -e

echo "### Renovando certificados de Let's Encrypt..."

docker-compose run --rm --entrypoint "\
  certbot renew" reverse-proxy

echo "### Recargando nginx..."
docker-compose exec reverse-proxy nginx -s reload

echo "### Certificados renovados exitosamente."

