# Production Deployment Guide

This guide covers deploying the Renewable Energy IoT Monitoring System to production environments.

## Production Environments

This system supports deployment to two production environments:

1. **edubad.zut.edu.pl** - Primary production server with Nginx reverse proxy
2. **Mikrus VPS (robert108.mikrus.xyz)** - Secondary production server with direct port access

## Prerequisites

- Docker and Docker Compose installed on VPS
- SSH access to the VPS
- Production environment file (`.env.production`) configured
- Root/administrator access (for edubad.zut.edu.pl)

---

# Deployment to edubad.zut.edu.pl

## Server Specifications

- **Server**: edubad.zut.edu.pl (82.145.64.204)
- **OS**: Ubuntu 24.04 LTS
- **Resources**: 4 vCPU, 8 GB RAM, 40 GB SSD
- **Access**: SSH with administrator privileges (sudo)
- **Reverse Proxy**: Nginx (path-based routing)
- **Backups**: Daily snapshots (automatic or manual)

## Architecture Overview

The edubad.zut.edu.pl deployment uses **Nginx reverse proxy** for path-based routing, allowing all services to be accessed through a single domain with different paths:

- All web services accessible via `http://edubad.zut.edu.pl/{service-path}/`
- MQTT broker requires direct connection (protocol-specific)
- Services run in Docker containers on internal network
- Nginx handles SSL/TLS termination (when configured)

## Production Ports (Internal)

Services run on standard ports internally within Docker network:
- **MQTT (Mosquitto)**: 1883 (internal)
- **Grafana**: 3000 (internal)
- **Node-RED**: 1880 (internal)
- **InfluxDB**: 8086 (internal)
- **API**: 3001 (internal)
- **Frontend**: 80 (internal)
- **Nginx**: 80 (external, accessible from internet)

## Initial Setup

### 1. SSH to Server

```bash
ssh admin@edubad.zut.edu.pl
# or using IP address
ssh admin@82.145.64.204
```

### 2. Install Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose-plugin

# Add user to docker group (if needed)
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker installation
docker --version
docker compose version
```

### 3. Clone Repository

```bash
# Clone the repository
git clone https://github.com/Viktar-T/plat-edu-bad-data-mvp.git
cd plat-edu-bad-data-mvp
```

### 4. Prepare Environment File

```bash
# Copy example to production
cp env.example .env.production

# Edit .env.production and update:
# - All passwords (use strong passwords)
# - All tokens (use strong tokens)
# - Server URLs to edubad.zut.edu.pl
# - Verify Nginx configuration paths
nano .env.production
```

**Important Configuration for edubad.zut.edu.pl:**

```bash
# Server Configuration
SERVER_IP=edubad.zut.edu.pl
SERVER_PORT=22

# Nginx Reverse Proxy URLs
GF_SERVER_ROOT_URL=http://edubad.zut.edu.pl/grafana
GF_SERVER_SERVE_FROM_SUB_PATH=true

# API Configuration
VITE_API_URL=http://edubad.zut.edu.pl/api
VITE_API_BASE_URL=http://edubad.zut.edu.pl/api
CORS_ORIGIN=http://edubad.zut.edu.pl

# All passwords and tokens should be changed from defaults
```

**Grafana Sub-Path Configuration:**

When using Nginx reverse proxy, Grafana must be configured to serve from a sub-path. Ensure these environment variables are set in your `docker-compose.yml`:

```yaml
environment:
  - GF_SERVER_ROOT_URL=http://edubad.zut.edu.pl/grafana
  - GF_SERVER_SERVE_FROM_SUB_PATH=true
```

**Important**: Replace all `<STRONG_PASSWORD_HERE>` and `<STRONG_TOKEN_HERE>` placeholders with actual secure values.

### 5. Fix Permissions

```bash
# Fix permissions for Docker volumes (IMPORTANT)
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data
```

### 6. Configure Nginx

The Nginx configuration is located at `nginx/nginx.conf`. For edubad.zut.edu.pl, ensure:

1. **Server name** is set correctly (or use `_` for any domain)
2. **Upstream backends** match Docker service names
3. **Path routing** is configured for all services

Verify the configuration:

```bash
# Check Nginx configuration syntax
docker run --rm -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro nginx:alpine nginx -t
```

**Important**: Ensure the Nginx service is added to `docker-compose.yml`. If not present, add the following service definition:

```yaml
nginx:
  image: nginx:alpine
  container_name: iot-nginx
  ports:
    - "80:80"
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  restart: unless-stopped
  depends_on:
    grafana:
      condition: service_healthy
    node-red:
      condition: service_healthy
    influxdb:
      condition: service_healthy
  healthcheck:
    test: ["CMD-SHELL", "wget -qO- http://localhost/health || exit 1"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 30s
  networks:
    - iot-network
```

**Note**: For edubad.zut.edu.pl deployment, you may need to:
- Change service ports from `expose` to internal-only (remove port mappings for Grafana, Node-RED, InfluxDB)
- Or keep ports for direct access alongside Nginx reverse proxy
- Configure Grafana to work behind reverse proxy by setting `GF_SERVER_SERVE_FROM_SUB_PATH=true`

### 7. Configure Firewall

Ensure port 80 (HTTP) is open for external access:

```bash
# Check firewall status
sudo ufw status

# Allow HTTP traffic (if UFW is active)
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp  # SSH access

# Reload firewall
sudo ufw reload
```

**Note**: If the server uses a different firewall (iptables, firewalld), configure accordingly. For university networks, you may need to coordinate with network administrators.

### 8. Build and Deploy Services

```bash
# Copy production environment
cp .env.production .env

# Build and start all services (including Nginx)
sudo docker compose up -d --build

# Verify all services are running
sudo docker compose ps

# Check service logs
sudo docker compose logs -f
```

## Accessing Services on edubad.zut.edu.pl

Once deployed, access services through Nginx reverse proxy:

- **Grafana Dashboard**: http://edubad.zut.edu.pl/grafana/
- **Node-RED Editor**: http://edubad.zut.edu.pl/nodered/
- **InfluxDB Admin**: http://edubad.zut.edu.pl/influxdb/
- **API Endpoints**: http://edubad.zut.edu.pl/api/
  - Health: http://edubad.zut.edu.pl/api/health
  - Summary: http://edubad.zut.edu.pl/api/summary/{device}
- **React Frontend**: http://edubad.zut.edu.pl/app/
- **Root URL**: http://edubad.zut.edu.pl/ (redirects to Grafana)
- **Health Check**: http://edubad.zut.edu.pl/health
- **MQTT Broker**: edubad.zut.edu.pl:1883 (direct connection, requires port forwarding if needed)

## Nginx Reverse Proxy Configuration

The Nginx reverse proxy provides:

### Path-Based Routing

All services are accessible through path-based routing:
- `/grafana/` → Grafana Dashboard
- `/nodered/` → Node-RED Editor
- `/influxdb/` → InfluxDB Admin
- `/api/` → Express Backend API
- `/app/` → React Frontend
- `/` → Default redirect to Grafana

### Features

- **WebSocket Support**: Enabled for Grafana and Node-RED
- **Rate Limiting**: API endpoints (10 req/s), general routes (30 req/s)
- **Security Headers**: X-Frame-Options, XSS Protection, Content Security Policy
- **Gzip Compression**: Enabled for text-based content
- **Health Checks**: `/health` endpoint for monitoring

### Upstream Services

Nginx routes to internal Docker services:
- `grafana_backend` → `iot-grafana:3000`
- `nodered_backend` → `iot-node-red:1880`
- `influxdb_backend` → `iot-influxdb2:8086`
- `api_backend` → `iot-api:3001` (if configured)
- `frontend_backend` → `iot-frontend:80` (if configured)

## Maintenance Operations

### Restart Services

```bash
# Restart all services
sudo docker compose restart

# Restart specific service
sudo docker compose restart nginx
sudo docker compose restart grafana
```

### View Logs

```bash
# View all logs
sudo docker compose logs -f

# View specific service logs
sudo docker compose logs -f nginx
sudo docker compose logs -f grafana
sudo docker compose logs -f api
```

### Update Services

```bash
# Pull latest code
git pull --ff-only

# Rebuild and restart services
sudo docker compose up -d --build

# Verify deployment
sudo docker compose ps
```

### Backup

The server is configured for **daily snapshots** (automatic or manual). Additionally, you can create manual backups:

```bash
# Create backup of InfluxDB data
sudo docker compose exec influxdb influx backup /backups/backup-$(date +%Y%m%d-%H%M%S)

# Backup configuration files
tar -czf backup-config-$(date +%Y%m%d-%H%M%S).tar.gz \
  .env.production \
  nginx/nginx.conf \
  docker-compose.yml \
  grafana/provisioning/ \
  node-red/data/

# Backup all Docker volumes
sudo docker run --rm \
  -v plat-edu-bad-data-mvp_influxdb_data:/data:ro \
  -v $(pwd):/backup \
  alpine tar czf /backup/volumes-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
```

**Daily Snapshots:**

The server infrastructure provides daily snapshots. Coordinate with system administrators to:
- Verify snapshot schedule (automatic or manual)
- Test snapshot restoration procedures
- Monitor snapshot storage space

## Troubleshooting

### Nginx Not Routing Correctly

```bash
# Check Nginx container logs
sudo docker compose logs nginx

# Verify Nginx configuration
sudo docker compose exec nginx nginx -t

# Check if services are accessible internally
sudo docker compose exec nginx ping iot-grafana
sudo docker compose exec nginx curl http://iot-grafana:3000/api/health
```

### Services Not Accessible

```bash
# Check if all containers are running
sudo docker compose ps

# Check service health
sudo docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Verify network connectivity
sudo docker compose exec grafana ping iot-influxdb2
```

### Port Conflicts

```bash
# Check what's using port 80
sudo netstat -tulpn | grep :80
sudo ss -tulpn | grep :80

# If port 80 is in use, you may need to:
# 1. Stop conflicting service
# 2. Or configure Nginx to use different port
# 3. Update firewall rules accordingly
```

### SSL/TLS Configuration (Future)

To enable HTTPS:

1. Obtain SSL certificates (Let's Encrypt recommended)
2. Update `nginx/nginx.conf` with SSL configuration
3. Uncomment HTTPS server block
4. Update service URLs to use `https://`

---

# Deployment to Mikrus VPS (robert108.mikrus.xyz)

## Production Ports

- **MQTT (Mosquitto)**: 40098
- **Grafana**: 40099
- **Node-RED**: 40100
- **InfluxDB**: 40101
- **API**: 40102
- **Frontend**: 40103

## Initial Setup

### 1. Prepare Environment File

Copy and configure the production environment file:

```powershell
# Copy example to production
cp env.example .env.production

# Edit .env.production and update:
# - All passwords (use strong passwords)
# - All tokens (use strong tokens)
# - Verify all URLs and ports
```

**Important**: Replace all `<STRONG_PASSWORD_HERE>` and `<STRONG_TOKEN_HERE>` placeholders with actual secure values.

### 2. Build Production Images

```powershell
.\scripts\deploy-production-apps.ps1 -Build
```

This will:
- Build API service with production optimizations
- Build Frontend service with production environment variables
- Use `docker-compose.prod.yml` for production-specific settings

### 3. Deploy Services

```powershell
.\scripts\deploy-production-apps.ps1 -Deploy
```

This will:
- Stop existing services
- Remove old containers
- Start new services with production configuration
- Show service status

### 4. Verify Deployment

```powershell
# Check service status
.\scripts\deploy-production-apps.ps1 -Status

# View logs
.\scripts\deploy-production-apps.ps1 -Logs
```

## Accessing Production Services

Once deployed, access services at:

- **Frontend Dashboard**: http://robert108.mikrus.xyz:40103
- **API Endpoints**: http://robert108.mikrus.xyz:40102
  - Health: http://robert108.mikrus.xyz:40102/health
  - Summary: http://robert108.mikrus.xyz:40102/api/summary/{device}
- **Grafana**: http://robert108.mikrus.xyz:40099
- **Node-RED**: http://robert108.mikrus.xyz:40100
- **InfluxDB**: http://robert108.mikrus.xyz:40101

## Maintenance Operations

### Restart Services

```powershell
.\scripts\deploy-production-apps.ps1 -Restart
```

### Monitor Services

```powershell
.\scripts\monitor-apps.ps1
```

This provides a live monitoring dashboard showing:
- API health status
- Frontend health status
- Container status
- Resource usage (CPU, Memory)

### Create Backup

```powershell
.\scripts\backup-apps.ps1
```

This creates a backup of:
- API source code and configuration
- Frontend source code and configuration
- Docker compose files
- Environment configuration

Backups are saved to `backups/apps-{timestamp}.zip`

## Updating Services

### Full Update (Rebuild and Deploy)

```powershell
# 1. Build new images
.\scripts\deploy-production-apps.ps1 -Build

# 2. Deploy new services
.\scripts\deploy-production-apps.ps1 -Deploy

# 3. Verify deployment
.\scripts\deploy-production-apps.ps1 -Status
```

### Quick Restart (No Rebuild)

```powershell
.\scripts\deploy-production-apps.ps1 -Restart
```

## Production Configuration

### Resource Limits

Production services have resource limits configured in `docker-compose.prod.yml`:

**API Service:**
- CPU Limit: 0.5 cores
- Memory Limit: 512MB
- CPU Reservation: 0.25 cores
- Memory Reservation: 256MB

**Frontend Service:**
- CPU Limit: 0.25 cores
- Memory Limit: 256MB
- CPU Reservation: 0.1 cores
- Memory Reservation: 128MB

### Logging

Production services use JSON file logging with rotation:
- Max log file size: 10MB
- Max log files: 3
- Logs are automatically rotated

### Health Checks

All services have health checks configured:
- **API**: Checks `/health` endpoint every 30 seconds
- **Frontend**: Checks `/health` endpoint every 30 seconds
- Services automatically restart if health checks fail

## Security Considerations

1. **Change Default Passwords**: Update all passwords in `.env.production`
2. **Use Strong Tokens**: Generate secure tokens for InfluxDB
3. **Enable HTTPS**: Consider setting up SSL/TLS certificates
4. **Rate Limiting**: API should implement rate limiting (future enhancement)
5. **Regular Backups**: Run backup script regularly
6. **Monitor Logs**: Check logs for suspicious activity
7. **Keep Updated**: Regularly update Docker images and dependencies

## Troubleshooting

### Services Not Starting

```powershell
# Check logs
.\scripts\deploy-production-apps.ps1 -Logs

# Check Docker status
docker-compose --env-file .env.production ps

# Check individual service logs
docker-compose --env-file .env.production logs api
docker-compose --env-file .env.production logs frontend
```

### API Not Connecting to InfluxDB

```powershell
# Check API environment variables
docker exec iot-api env | Select-String "INFLUX"

# Check network connectivity
docker exec iot-api ping influxdb -c 3

# Check InfluxDB health
curl http://localhost:40101/health
```

### Frontend Not Loading

```powershell
# Rebuild frontend with correct env vars
.\scripts\deploy-production-apps.ps1 -Build
.\scripts\deploy-production-apps.ps1 -Deploy

# Check frontend logs
docker-compose --env-file .env.production logs frontend

# Verify environment variables were set during build
docker exec iot-frontend env | Select-String "VITE"
```

### Port Conflicts

```powershell
# Check what's using the ports
netstat -ano | Select-String "40102"
netstat -ano | Select-String "40103"

# Stop conflicting services or change ports in .env.production
```

## Performance Optimization

### Enable Docker BuildKit

```powershell
$env:DOCKER_BUILDKIT=1
$env:COMPOSE_DOCKER_CLI_BUILD=1
```

### Monitor Resource Usage

```powershell
# Use monitoring script
.\scripts\monitor-apps.ps1

# Or check manually
docker stats iot-api iot-frontend
```

## Backup and Recovery

### Create Backup

```powershell
.\scripts\backup-apps.ps1
```

### Restore from Backup

1. Extract backup archive
2. Copy files back to their locations
3. Rebuild and deploy services

## Next Steps

- Set up automated backups (cron job)
- Configure SSL/TLS certificates
- Implement rate limiting in API
- Set up monitoring alerts
- Configure firewall rules on VPS
- Set up log aggregation

## Support

For issues or questions:
1. Check logs: `.\scripts\deploy-production-apps.ps1 -Logs`
2. Review troubleshooting section above
3. Check service health: `.\scripts\deploy-production-apps.ps1 -Status`
4. Monitor resources: `.\scripts\monitor-apps.ps1`

---

# Deployment Environment Comparison

## edubad.zut.edu.pl vs Mikrus VPS

| Feature | edubad.zut.edu.pl | Mikrus VPS |
|---------|-------------------|------------|
| **Server** | edubad.zut.edu.pl (82.145.64.204) | robert108.mikrus.xyz |
| **Resources** | 4 vCPU, 8 GB RAM, 40 GB SSD | Varies (check Mikrus plan) |
| **OS** | Ubuntu 24.04 LTS | Varies |
| **Access** | Single domain with path-based routing | Direct port access |
| **Reverse Proxy** | ✅ Nginx (path-based) | ❌ Direct ports |
| **URL Structure** | `http://edubad.zut.edu.pl/{service}/` | `http://robert108.mikrus.xyz:{port}` |
| **Ports** | Single port (80) for all services | Multiple ports (40098-40103) |
| **SSL/TLS** | Can be configured on Nginx | Per-service configuration |
| **Backups** | Daily snapshots (automatic/manual) | Manual backups via scripts |
| **Use Case** | Production with clean URLs | Development/testing, direct access |
| **Firewall** | Port 80 (HTTP), 443 (HTTPS) | Multiple ports (40098-40103) |

## Choosing a Deployment Environment

### Use edubad.zut.edu.pl when:
- ✅ You need clean, professional URLs
- ✅ You want SSL/TLS termination at the proxy level
- ✅ You prefer path-based routing (`/grafana/`, `/api/`, etc.)
- ✅ You have access to server with root/admin privileges
- ✅ You need daily automated snapshots
- ✅ You want centralized logging and monitoring

### Use Mikrus VPS when:
- ✅ You need direct port access for testing
- ✅ You're developing or testing individual services
- ✅ You prefer simpler setup without reverse proxy
- ✅ You need quick deployment without Nginx configuration
- ✅ You're using Mikrus hosting platform

## Migration Between Environments

To migrate from Mikrus VPS to edubad.zut.edu.pl:

1. **Export data** from Mikrus VPS:
   ```bash
   # Backup InfluxDB
   docker exec iot-influxdb2 influx backup /backups/backup-$(date +%Y%m%d)
   
   # Export Grafana dashboards
   # Export Node-RED flows
   ```

2. **Update environment variables** for edubad.zut.edu.pl:
   - Change `SERVER_IP` to `edubad.zut.edu.pl`
   - Update `GF_SERVER_ROOT_URL` to use sub-path
   - Add `GF_SERVER_SERVE_FROM_SUB_PATH=true`

3. **Add Nginx service** to docker-compose.yml

4. **Import data** on edubad.zut.edu.pl:
   ```bash
   # Restore InfluxDB
   docker exec iot-influxdb2 influx restore /backups/backup-YYYYMMDD
   ```

5. **Update DNS/firewall** rules as needed

