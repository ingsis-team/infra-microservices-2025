#!/bin/bash

CERT_PATH="/etc/letsencrypt/live/super-snippet.duckdns.org/fullchain.pem"
CERT_DIR="/etc/letsencrypt/live/super-snippet.duckdns.org"

# Crear certificados dummy primero para que nginx pueda iniciar
if [ ! -f "$CERT_PATH" ]; then
    echo "Creando certificados dummy temporales para que nginx pueda iniciar..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
        -keyout "$CERT_DIR/privkey.pem" \
        -out "$CERT_DIR/fullchain.pem" \
        -subj "/CN=super-snippet.duckdns.org" 2>/dev/null || true
    touch "$CERT_DIR/.dummy" 2>/dev/null || true
    echo "Certificados dummy creados."
fi

# Iniciar nginx en background para que certbot pueda validar
echo "Iniciando nginx en background..."
nginx -g 'daemon on;'

# Esperar a que nginx esté listo
sleep 5

# Intentar obtener certificados reales si están usando dummy
if [ -f "$CERT_DIR/.dummy" ]; then
    echo "Intentando obtener certificados reales de Let's Encrypt..."
    
    certbot certonly --webroot \
        -w /var/www/certbot \
        -d super-snippet.duckdns.org \
        --email ${CERTBOT_EMAIL:-admin@example.com} \
        --agree-tos \
        --no-eff-email \
        --non-interactive && {
        echo "Certificados obtenidos exitosamente. Reiniciando nginx..."
        # Reiniciar nginx para cargar los certificados reales
        nginx -s reload
        rm -f "$CERT_DIR/.dummy" 2>/dev/null || true
    } || {
        echo "No se pudieron obtener certificados reales. Continuando con certificados dummy."
    }
else
    echo "Certificados reales ya existen."
fi

# Mantener nginx corriendo en foreground (reemplaza el proceso actual)
echo "Manteniendo nginx corriendo..."
exec nginx -g 'daemon off;'
