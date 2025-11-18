#!/bin/bash

# Script para verificar el estado de todos los servicios

echo "🔍 Verificando estado de servicios..."
echo ""

# Cargar variables de entorno
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "📋 Estado de contenedores:"
docker-compose ps
echo ""

echo "🌐 Verificando conectividad externa..."
if [ ! -z "$DOMAIN_NAME" ]; then
    echo "Testing https://$DOMAIN_NAME/health"
    curl -k -s https://$DOMAIN_NAME/health && echo " ✅" || echo " ❌"
else
    echo "⚠️  DOMAIN_NAME no configurado en .env"
fi
echo ""

echo "🔐 Verificando certificados SSL..."
if [ -d "certbot/conf/live/$DOMAIN_NAME" ]; then
    echo "✅ Certificados encontrados en certbot/conf/live/$DOMAIN_NAME"
    echo "Expiran el:"
    sudo openssl x509 -enddate -noout -in certbot/conf/live/$DOMAIN_NAME/cert.pem
else
    echo "❌ No se encontraron certificados SSL"
    echo "Ejecuta: bash scripts/init-letsencrypt.sh"
fi
echo ""

echo "🔄 Verificando servicios internos..."
docker-compose exec -T reverse-proxy sh -c "curl -s http://web:80 > /dev/null && echo '✅ Frontend (web)' || echo '❌ Frontend (web)'"
docker-compose exec -T reverse-proxy sh -c "curl -s http://snippet-service:8080/actuator/health > /dev/null && echo '✅ Snippet Service' || echo '❌ Snippet Service'"
docker-compose exec -T reverse-proxy sh -c "curl -s http://permission-service:8081/actuator/health > /dev/null && echo '✅ Permission Service' || echo '❌ Permission Service'"
docker-compose exec -T reverse-proxy sh -c "curl -s http://printscript-service:8082/actuator/health > /dev/null && echo '✅ PrintScript Service' || echo '❌ PrintScript Service'"
echo ""

echo "💾 Verificando bases de datos..."
docker-compose exec -T snippet-db pg_isready -U ${POSTGRES_SNIPPET_USER} > /dev/null && echo "✅ Snippet DB" || echo "❌ Snippet DB"
docker-compose exec -T permission-db pg_isready -U ${POSTGRES_PERMISSION_USER} > /dev/null && echo "✅ Permission DB" || echo "❌ Permission DB"
docker-compose exec -T printscript-db pg_isready -U ${POSTGRES_PRINTSCRIPT_USER} > /dev/null && echo "✅ PrintScript DB" || echo "❌ PrintScript DB"
echo ""

echo "🔴 Verificando Redis..."
docker-compose exec -T redis redis-cli ping > /dev/null && echo "✅ Redis" || echo "❌ Redis"
echo ""

echo "📊 Uso de recursos:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo ""

echo "✨ Verificación completa!"

