#!/bin/sh
set -e

echo "Starting NGINX Reverse Proxy..."

# Crear directorios necesarios
mkdir -p /var/www/certbot
mkdir -p /etc/letsencrypt
mkdir -p /var/log/nginx

# Verificar si existen certificados SSL
if [ -f "/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem" ]; then
    echo "SSL certificates found for ${DOMAIN_NAME}"
    
    # Usar configuración con SSL
    if [ -f "/etc/nginx/nginx-ssl.conf" ]; then
        cp /etc/nginx/nginx-ssl.conf /etc/nginx/conf.d/default.conf
    fi
else
    echo "No SSL certificates found. Running in HTTP mode."
    echo "To enable HTTPS, run: docker-compose exec reverse-proxy certbot --nginx -d ${DOMAIN_NAME}"
fi

# Iniciar nginx
exec "$@"

