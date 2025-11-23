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

# Verificar si nginx ya está corriendo intentando hacer reload
if nginx -s reload 2>/dev/null; then
    echo "Nginx ya está corriendo. Saltando inicialización."
    # Si nginx ya está corriendo, solo hacer las operaciones de certbot y mantener el proceso
    NGINX_ALREADY_RUNNING=true
else
    # Iniciar nginx en background para que certbot pueda validar
    echo "Iniciando nginx en background..."
    nginx -g 'daemon on;'
    NGINX_ALREADY_RUNNING=false
    
    # Esperar a que nginx esté listo
    sleep 5
fi

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

# Si nginx ya estaba corriendo, mantener el proceso actual (wait infinito)
if [ "$NGINX_ALREADY_RUNNING" = true ]; then
    echo "Nginx ya está corriendo. Manteniendo el proceso..."
    # Mantener el script corriendo para que el contenedor no termine
    tail -f /dev/null
else
    # Si nginx está en background, detenerlo y reiniciarlo en foreground
    echo "Deteniendo nginx en background para iniciarlo en foreground..."
    nginx -s quit
    sleep 2
    
    # Mantener nginx corriendo en foreground (reemplaza el proceso actual)
    echo "Manteniendo nginx corriendo en foreground..."
    exec nginx -g 'daemon off;'
fi
