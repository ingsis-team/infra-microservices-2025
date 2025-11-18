FROM nginx:alpine

# Instalar certbot para Let's Encrypt
RUN apk add --no-cache certbot certbot-nginx openssl

# Crear directorios necesarios
RUN mkdir -p /var/www/certbot /etc/letsencrypt /var/log/nginx

# Copiar configuración de NGINX
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# El contenedor de nginx:alpine automáticamente procesa templates con envsubst
# Las variables de entorno se sustituyen en archivos .template

EXPOSE 80 443

# Script de inicialización
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

