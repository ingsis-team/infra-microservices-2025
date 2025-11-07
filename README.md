# Infrastructure Microservices 2025

## Description
Infrastructure and orchestration configuration for the 2025 microservices architecture. Contains Docker Compose files and infrastructure setup for deploying and managing all microservices together.

## Purpose

This repository provides:
- **Docker Compose Configuration**: Orchestrates all microservices (Snippet Service, Permission Service, PrintScript Service)
- **Infrastructure Setup**: Database, Redis, and other infrastructure components
- **Service Dependencies**: Manages dependencies and startup order between services
- **Environment Configuration**: Centralized environment variable management

## Services Included

- **Snippet Service 2025**: Code snippet management service (port 8080)
- **Permission Service 2025**: Permission management service (port 8081)
- **PrintScript Service 2025**: PrintScript code processing service (port 8082)
- **PostgreSQL**: Database for all services
- **Redis**: Cache and message broker for PrintScript Service

## Running the Infrastructure

### Prerequisites
- Docker and Docker Compose installed
- Environment variables configured (see `.env` file or environment)

### Start All Services
```bash
docker-compose up -d --build
```

### Stop All Services
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

### View Logs for Specific Service
```bash
docker-compose logs -f snippet-service
docker-compose logs -f permission-service
docker-compose logs -f printscript-service
```

## Environment Variables

Configure the following environment variables (typically in a `.env` file):

### Database Configuration
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: Database name
- `DB_HOST`: Database host
- `DB_PORT`: Database port

### Service Ports
- `SNIPPET_SERVICE_PORT`: Port for Snippet Service (default: 8080)
- `PERMISSION_SERVICE_PORT`: Port for Permission Service (default: 8081)
- `PRINTSCRIPT_SERVICE_PORT`: Port for PrintScript Service (default: 8082)

### GitHub Packages (for PrintScript Service)
- `GITHUB_USERNAME`: GitHub username for accessing packages
- `GITHUB_TOKEN`: GitHub token with read permissions

### Other Services
- `ASSET_URL`: Asset service URL (for PrintScript Service)
- `REDIS_HOST`: Redis host
- `REDIS_PORT`: Redis port

## Service URLs

Once running, services are available at:
- **Snippet Service**: http://localhost:8080
- **Permission Service**: http://localhost:8081
- **PrintScript Service**: http://localhost:8082

### Swagger Documentation
- **Snippet Service**: http://localhost:8080/swagger-ui.html
- **Permission Service**: http://localhost:8081/swagger-ui.html
- **PrintScript Service**: http://localhost:8082/swagger-ui.html

## Architecture

```
┌─────────────────┐
│  Snippet Service│ (Port 8080)
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
┌────────▼────────┐  ┌─────▼──────────┐
│Permission Service│  │PrintScript     │ (Port 8082)
│(Port 8081)      │  │Service         │
└────────┬────────┘  └─────┬──────────┘
         │                 │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   PostgreSQL    │
         └─────────────────┘
                  │
         ┌────────▼────────┐
         │     Redis       │
         └─────────────────┘
```

## Health Checks

All services include health checks. Check service status:

```bash
docker-compose ps
```

## Troubleshooting

### Services Not Starting
1. Check logs: `docker-compose logs [service-name]`
2. Verify environment variables are set correctly
3. Ensure ports are not already in use
4. Check database connectivity

### Database Connection Issues
- Verify PostgreSQL container is healthy: `docker-compose ps db`
- Check database credentials in environment variables
- Ensure database is initialized (check init scripts)

### Port Conflicts
- Modify port mappings in `docker-compose.yml` if ports are already in use
- Update service URLs accordingly

## Development

For local development of individual services, refer to each service's README:
- `snippet-service-2025/README.md`
- `permission-service-2025/README.md`
- `printscript-service-2025/README.md`
