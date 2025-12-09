# Infrastructure Microservices 2025

## Description

This repository contains the Docker Compose orchestration for the complete Snippet Searcher platform. It brings together all microservices, databases, and infrastructure components into a single, production-ready deployment.

## Architecture

The infrastructure consists of:

### Frontend
- **PrintScript UI**: React-based frontend application (port 80 via proxy)

### Backend Services
- **Snippet Service**: Manages code snippets (port 8080)
- **Permission Service**: Handles access control (port 8081)
- **PrintScript Service**: Code validation, formatting, linting, and execution (port 8082)
- **Asset Service**: Stores snippet content (port 8083)

### Infrastructure Components
- **Nginx Reverse Proxy**: Routes traffic and handles SSL/TLS (ports 80, 443)
- **Certbot**: Manages Let's Encrypt SSL certificates
- **DuckDNS**: Dynamic DNS service for domain management
- **Redis**: Caching and asynchronous processing (port 6379)
- **Azurite**: Azure Storage emulator for asset storage

### Databases
- **Snippet DB**: PostgreSQL database for snippet metadata
- **Permission DB**: PostgreSQL database for permissions
- **PrintScript DB**: PostgreSQL database for PrintScript service

## Features

- **Complete Stack**: All services orchestrated together
- **SSL/TLS Support**: Automatic Let's Encrypt certificate management
- **Dynamic DNS**: DuckDNS integration for domain management
- **Health Checks**: All services include health check configurations
- **Service Discovery**: Services communicate via Docker network
- **Persistent Storage**: Volumes for databases and storage
- **Auto-restart**: Services restart automatically on failure

## Prerequisites

- Docker and Docker Compose installed
- Domain name configured with DuckDNS (or modify for your domain)
- Environment variables configured (see Configuration section)

## Quick Start

### 1. Configure Environment Variables

Create a `.env` file in the repository root with the following variables:

```bash
# Environment
ENVIRONMENT=dev
IMAGE_TAG=dev

# DuckDNS Configuration
DUCKDNS_SUBDOMAIN=snippet-prueba
DUCKDNS_TOKEN=your-duckdns-token

# Let's Encrypt
LETSENCRYPT_EMAIL=your-email@example.com

# Database Configuration
POSTGRES_SNIPPET_DB=snippetdb
POSTGRES_SNIPPET_USER=snippetuser
POSTGRES_SNIPPET_PASSWORD=your-password

POSTGRES_PERMISSION_DB=permissiondb
POSTGRES_PERMISSION_USER=permissionuser
POSTGRES_PERMISSION_PASSWORD=your-password

POSTGRES_PRINTSCRIPT_DB=printscriptdb
POSTGRES_PRINTSCRIPT_USER=printscriptuser
POSTGRES_PRINTSCRIPT_PASSWORD=your-password

# Service URLs (internal Docker network)
ASSET_URL=http://asset-service:8080
PERMISSION_URL=http://permission-service:8080
PRINTSCRIPT_URL=http://printscript-service:8080

# Auth0 Configuration
AUTH0_DOMAIN=your-domain.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
AUTH0_AUDIENCE=your-api-audience
AUTH_SERVER_URI=https://your-domain.auth0.com/
AUTH0_MANAGEMENT_TOKEN=your-management-token

# New Relic (Optional)
NEW_RELIC_LICENSE_KEY=your-license-key
NEW_RELIC_APP_NAME_SNIPPET=snippet-service
NEW_RELIC_APP_NAME_PERMISSION=permission-service
NEW_RELIC_APP_NAME_PRINTSCRIPT=printscript-service
JAVA_TOOL_OPTIONS=-javaagent:/newrelic/newrelic.jar

# GitHub Packages (for PrintScript Service)
GITHUB_USERNAME=your-github-username
GITHUB_TOKEN=your-github-token

# Redis Streams (Optional)
STREAM_KEY_LINT=lint
STREAM_KEY_FORMAT=format
STREAM_KEY_TEST=test
GROUPS_PRODUCT=product
GROUPS_PRODUCT1=product1
GROUPS_PRODUCT2=product2
```

### 2. Start All Services

```bash
docker-compose up -d --build
```

### 3. Access the Application

- **Frontend**: https://snippet-prueba.duckdns.org (or http://localhost)
- **Snippet Service API**: https://snippet-prueba.duckdns.org/api/
- **Permission Service API**: https://snippet-prueba.duckdns.org/api/permissions/
- **PrintScript Service API**: https://snippet-prueba.duckdns.org/printscript/

## Service Ports

| Service | Internal Port | External Port | Access Via |
|---------|--------------|---------------|------------|
| Frontend | 80 | - | Nginx (443) |
| Snippet Service | 8080 | 8080 | Nginx or direct |
| Permission Service | 8080 | 8081 | Nginx or direct |
| PrintScript Service | 8080 | 8082 | Nginx or direct |
| Asset Service | 8080 | 8083 | Nginx or direct |
| Nginx | 80, 443 | 80, 443 | Direct |
| Redis | 6379 | - | Internal only |
| PostgreSQL | 5432 | - | Internal only |

## Nginx Routing

The Nginx reverse proxy routes requests as follows:

- `/` → PrintScript UI (frontend)
- `/api/` → Snippet Service
- `/api/permissions/` → Permission Service
- `/printscript/` → PrintScript Service (rewritten to remove `/printscript` prefix)

## SSL/TLS Configuration

The infrastructure uses Let's Encrypt for SSL certificates:

1. **Initial Setup**: Certbot creates dummy certificates so Nginx can start
2. **Certificate Request**: Certbot requests real certificates from Let's Encrypt
3. **Auto-renewal**: Certificates are automatically renewed before expiration

### For Local Development

To disable SSL for local testing, modify `nginx/nginx.conf`:
- Comment out the HTTPS server block
- Uncomment the HTTP-only configuration
- Remove the redirect from HTTP to HTTPS

## Service Dependencies

```
Frontend (PrintScript UI)
  └─ Depends on: All backend services

Nginx (Reverse Proxy)
  └─ Depends on: All services + DuckDNS

Snippet Service
  └─ Depends on: snippet-db, redis

Permission Service
  └─ Depends on: permission-db, redis

PrintScript Service
  └─ Depends on: printscript-db, redis

Asset Service
  └─ Depends on: azurite
```

## Health Checks

All services include health check configurations:

- **Databases**: PostgreSQL readiness checks
- **Redis**: Ping checks
- **PrintScript Service**: HTTP health endpoint checks
- **Other Services**: Automatic restart on failure

## Volumes

Persistent data is stored in Docker volumes:

- `snippet_volume`: Snippet database data
- `permission_volume`: Permission database data
- `printscript_volume`: PrintScript database data
- `azurite_volume`: Asset storage data
- `nginx-logs`: Nginx log files

## Monitoring

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f snippet-service
docker-compose logs -f printscript-service
docker-compose logs -f proxy
```

### Health Endpoints

- PrintScript Service: `http://localhost:8082/actuator/health`
- Other services may have health endpoints (check Swagger docs)

## Troubleshooting

### SSL Certificate Issues

If SSL certificates fail to generate:
1. Check DuckDNS configuration
2. Verify domain points to your server
3. Check firewall allows ports 80 and 443
4. Review certbot logs: `docker-compose logs proxy`

### Service Connection Issues

If services can't connect:
1. Verify all services are on the same network (`app-network`)
2. Check service names match in environment variables
3. Ensure health checks are passing: `docker-compose ps`

### Database Connection Issues

If databases fail to connect:
1. Check database health: `docker-compose ps | grep db`
2. Verify credentials in `.env` file
3. Check database logs: `docker-compose logs snippet-db`

### Port Conflicts

If ports are already in use:
1. Check what's using the port: `netstat -ano | findstr :8080`
2. Modify port mappings in `docker-compose.yml`
3. Update Nginx configuration if needed

## Stopping Services

### Stop All Services

```bash
docker-compose down
```

### Stop and Remove Volumes

```bash
docker-compose down -v
```

**Warning**: This will delete all database data!

## Updating Services

### Update Specific Service

```bash
docker-compose up -d --build snippet-service
```

### Update All Services

```bash
docker-compose up -d --build
```

### Pull Latest Images

```bash
docker-compose pull
docker-compose up -d
```

## Network Architecture

All services communicate via the `app-network` Docker bridge network:

```
Internet
  ↓
Nginx (Reverse Proxy)
  ├─→ PrintScript UI
  ├─→ Snippet Service → snippet-db, redis
  ├─→ Permission Service → permission-db, redis
  └─→ PrintScript Service → printscript-db, redis
  └─→ Asset Service → azurite
```

## Security Considerations

- **SSL/TLS**: All external traffic should use HTTPS
- **Internal Network**: Services communicate on isolated Docker network
- **Database Access**: Databases are not exposed externally
- **Authentication**: All services use Auth0 JWT authentication
- **Secrets**: Store sensitive values in `.env` file (not in git)

## Development vs Production

### Development
- Use local images or build from source
- May disable SSL for easier debugging
- Use local storage (Azurite) instead of Azure

### Production
- Use published images from GitHub Container Registry
- Enable SSL/TLS with Let's Encrypt
- Configure proper Azure Storage (replace Azurite)
- Set up proper monitoring and logging
- Configure backup strategies for databases

## Environment-Specific Configuration

The `ENVIRONMENT` variable controls:
- Container naming: `{service}-${ENVIRONMENT}`
- Image tags: Uses `${IMAGE_TAG}` from environment
- Database names and users

Common values:
- `dev`: Development environment
- `staging`: Staging environment
- `prod`: Production environment

## Additional Resources

- **Snippet Service Docs**: See `snippet-service-2025/README.md`
- **PrintScript Service Docs**: See `printscript-service-2025/README.md`
- **Permission Service Docs**: See `permission-service-2025/README.md`
- **Frontend Docs**: See `printscript-ui/README.md`

## Support

For issues or questions:
1. Check service-specific README files
2. Review Docker logs: `docker-compose logs`
3. Check health endpoints
4. Verify environment variables

