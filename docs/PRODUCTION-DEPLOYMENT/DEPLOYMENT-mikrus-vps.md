# Deployment to Mikrus VPS (robert108.mikrus.xyz)

This guide covers deploying the Renewable Energy IoT Monitoring System to Mikrus VPS with direct port access.

## Server Specifications

- **Server**: robert108.mikrus.xyz
- **SSH Port**: 10108
- **SSH User**: viktar (or root)
- **Access**: SSH with user credentials
- **Architecture**: Nginx reverse proxy (path-based routing)
- **Backups**: Manual backups via scripts

## Architecture Overview

The Mikrus VPS deployment uses **Nginx reverse proxy** for path-based routing, allowing all services to be accessed through a single port with different paths:

- All web services accessible via `http://robert108.mikrus.xyz:20108/{service-path}/`
- MQTT broker requires direct connection (protocol-specific)
- Services run in Docker containers on internal network
- Nginx handles routing and SSL/TLS termination (when configured)

## Production Ports

**External Access (via Nginx):**
- **Nginx Reverse Proxy**: 20108 (HTTP), 30108 (HTTPS)
- **MQTT (Mosquitto)**: 40098 (direct connection, protocol-specific)

**Internal Ports (Docker network):**
- **Grafana**: 3000 (internal)
- **Node-RED**: 1880 (internal)
- **InfluxDB**: 8086 (internal)
- **API**: 3001 (internal)
- **Frontend**: 80 (internal)
- **Nginx**: 80 (internal, exposed as 20108 externally)

## Initial Setup

### 1. SSH to Server

```bash
# Connect as viktar user
ssh viktar@robert108.mikrus.xyz -p10108

# Or connect as root user
ssh root@robert108.mikrus.xyz -p10108

# First time connection (skip host key verification)
ssh -o StrictHostKeyChecking=no viktar@robert108.mikrus.xyz -p10108
```

### 2. Install Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker (if not already installed)
sudo apt install -y docker.io docker-compose-plugin

# Add user to docker group (if needed)
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker installation
docker --version
docker compose version
```

### 3. Clone Repository

**If repository doesn't exist yet:**

```bash
# Navigate to home directory
cd ~

# Clone the repository
git clone https://github.com/Viktar-T/plat-edu-bad-data-mvp.git
cd plat-edu-bad-data-mvp
```

**If repository already exists and containers are running:**

```bash
# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Pull latest changes from repository
git pull origin main

# Or if you're on a different branch
git pull origin <branch-name>

# If you have local changes, stash them first
git stash
git pull origin main
git stash pop

# After pulling changes, rebuild and restart services
sudo docker compose down
sudo docker compose up -d --build

# Verify services are running
sudo docker compose ps
```

**Note**: When pulling changes with running containers:
1. Pull the latest code changes
2. Stop running containers (`docker compose down`)
3. Rebuild images if Dockerfiles changed (`--build` flag)
4. Start services again (`docker compose up -d`)
5. This ensures all configuration changes are applied

### 4. Prepare Environment File

```bash
# Copy example to production
cp env.example .env.production

# Edit .env.production and update:
# - All passwords (use strong passwords)
# - All tokens (use strong tokens)
# - Server URLs to robert108.mikrus.xyz
# - Verify all port numbers
nano .env.production
```

**Important Configuration for Mikrus VPS:**

```bash
# Server Configuration
SERVER_IP=robert108.mikrus.xyz
SERVER_PORT=10108

# Mikrus Custom Ports
NGINX_PORT=20108                   # Nginx reverse proxy (HTTP)
NGINX_HTTPS_PORT=30108             # Nginx reverse proxy (HTTPS)
MQTT_PORT=40098                    # MQTT broker (direct connection)

# Production URLs - Nginx Reverse Proxy (Path-Based Routing)
GF_SERVER_ROOT_URL=http://robert108.mikrus.xyz:20108/grafana
GF_SERVER_SERVE_FROM_SUB_PATH=true

# API Configuration
VITE_API_URL=http://robert108.mikrus.xyz:20108/api
VITE_API_BASE_URL=http://robert108.mikrus.xyz:20108/api
CORS_ORIGIN=http://robert108.mikrus.xyz:20108

# All passwords and tokens should be changed from defaults
```

**Important**: Replace all `<STRONG_PASSWORD_HERE>` and `<STRONG_TOKEN_HERE>` placeholders with actual secure values.

**Environment Variables Explained:**

The `.env.production` file contains configuration that Docker Compose uses to set up your services. Key sections include:

- **Server Information**: Your server hostname and SSH port
- **Service Ports**: Each service gets its own port (40098-40103)
- **Service URLs**: Where services can be accessed from the internet
- **Passwords & Tokens**: Security credentials for each service
- **Database Configuration**: InfluxDB organization, bucket, and retention settings

### 5. Fix Permissions

```bash
# Fix permissions for Docker volumes (IMPORTANT)
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data
```

**Why This Matters:**

Docker containers run as specific users (UIDs). These commands ensure:
- Grafana (UID 472) can write to its data directory
- Node-RED (UID 1000) can write to its data directory
- Mosquitto (UID 1883) can write to its data and log directories
- InfluxDB (UID 472) can write to its data directory

Without proper permissions, services will fail to start or won't be able to save data.

### 6. Configure Nginx

The Nginx configuration is located at `nginx/nginx.conf`. For Mikrus VPS, ensure:

1. **Server name** is set correctly (or use `_` for any domain)
2. **Upstream backends** match Docker service names
3. **Path routing** is configured for all services
4. **Port mapping** is set to 20108 (HTTP) and 30108 (HTTPS)

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
    - "20108:80"      # HTTP
    - "30108:443"     # HTTPS (when SSL is configured)
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

**Note**: For Mikrus VPS deployment with Nginx:
- Services should use `expose` instead of `ports` (internal-only)
- Grafana must be configured with `GF_SERVER_SERVE_FROM_SUB_PATH=true`
- All services are accessible through Nginx on port 20108

### 7. Configure Firewall

Mikrus VPS typically manages firewall rules through their control panel, but you can verify:

```bash
# Check if Nginx port is accessible (from your local machine)
curl http://robert108.mikrus.xyz:20108/health

# Test service paths
curl http://robert108.mikrus.xyz:20108/grafana/
curl http://robert108.mikrus.xyz:20108/nodered/
curl http://robert108.mikrus.xyz:20108/influxdb/

# On the server, check if ports are listening
sudo netstat -tulpn | grep -E "20108|30108|40098"
sudo ss -tulpn | grep -E "20108|30108|40098"
```

**Note**: Mikrus VPS usually has ports pre-configured. If ports are not accessible, check:
1. Mikrus control panel firewall settings
2. Docker container port mappings in `docker-compose.yml`
3. Nginx service health status
4. Service health status

### 8. Build and Deploy Services

**Option A: Using PowerShell Scripts (from Windows)**

```powershell
# From your local Windows machine
# Build production images
.\scripts\deploy-production-apps.ps1 -Build

# Deploy services
.\scripts\deploy-production-apps.ps1 -Deploy

# Check status
.\scripts\deploy-production-apps.ps1 -Status
```

**Option B: Manual Deployment (on VPS)**

```bash
# Copy production environment
cp .env.production .env

# Build and start all services
sudo docker compose up -d --build

# Verify all services are running
sudo docker compose ps

# Check service logs
sudo docker compose logs -f
```

**Option C: Using Deployment Script (on VPS)**

```bash
# If you have the deployment script on VPS
./scripts/deploy-mikrus.ps1 -Full

# Or prepare and deploy separately
./scripts/deploy-mikrus.ps1 -Prepare
./scripts/deploy-mikrus.ps1 -Deploy
```

## Accessing Services on Mikrus VPS

Once deployed, access services through Nginx reverse proxy:

- **Grafana Dashboard**: http://robert108.mikrus.xyz:20108/grafana/
  - Default credentials: `admin` / `admin` (change in production!)
- **Node-RED Editor**: http://robert108.mikrus.xyz:20108/nodered/
  - Default credentials: `admin` / `adminpassword` (change in production!)
- **InfluxDB Admin**: http://robert108.mikrus.xyz:20108/influxdb/
  - Default credentials: `admin` / `admin_password_123` (change in production!)
- **API Endpoints**: http://robert108.mikrus.xyz:20108/api/
  - Health: http://robert108.mikrus.xyz:20108/api/health
  - Summary: http://robert108.mikrus.xyz:20108/api/summary/{device}
- **React Frontend**: http://robert108.mikrus.xyz:20108/app/
- **Root URL**: http://robert108.mikrus.xyz:20108/ (redirects to Grafana)
- **Health Check**: http://robert108.mikrus.xyz:20108/health
- **MQTT Broker**: robert108.mikrus.xyz:40098
  - Default credentials: `admin` / `admin_password_456` (change in production!)
  - Requires MQTT client (not accessible via browser, direct connection only)

## Nginx Reverse Proxy Architecture

### Service Port Mapping

All services are accessible through Nginx reverse proxy on port 20108:

```
Internet
   │
   ├─→ Port 20108 (HTTP) → Nginx Reverse Proxy
   │   ├─→ /grafana/ → Grafana Dashboard (internal:3000)
   │   ├─→ /nodered/ → Node-RED Editor (internal:1880)
   │   ├─→ /influxdb/ → InfluxDB Admin (internal:8086)
   │   ├─→ /api/ → Express Backend API (internal:3001)
   │   ├─→ /app/ → React Frontend (internal:80)
   │   └─→ / → Redirect to Grafana
   │
   └─→ Port 40098 → MQTT Broker (Mosquitto) - Direct connection only
```

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

### Advantages of Nginx Reverse Proxy

- **Clean URLs**: Single port with path-based routing
- **Centralized SSL/TLS**: Configure certificates once on Nginx
- **Security**: Centralized security headers and rate limiting
- **Performance**: Efficient routing and compression
- **Flexibility**: Easy to add/remove services

### Considerations

- **Single Point of Failure**: Nginx must be running for all services
- **Configuration**: Requires Nginx configuration knowledge
- **Debugging**: May need to check both Nginx and service logs

## Maintenance Operations

### Restart Services

```bash
# Restart all services
sudo docker compose restart

# Restart specific service
sudo docker compose restart nginx
sudo docker compose restart grafana
sudo docker compose restart node-red
sudo docker compose restart influxdb
sudo docker compose restart mosquitto
sudo docker compose restart api
sudo docker compose restart frontend
```

### View Logs

```bash
# View all logs
sudo docker compose logs -f

# View specific service logs
sudo docker compose logs -f nginx
sudo docker compose logs -f grafana
sudo docker compose logs -f node-red
sudo docker compose logs -f influxdb
sudo docker compose logs -f mosquitto
sudo docker compose logs -f api
sudo docker compose logs -f frontend

# View last 100 lines of logs
sudo docker compose logs --tail=100 grafana

# View logs with timestamps
sudo docker compose logs -f -t grafana
```

### Check Service Status

```bash
# Check all services status
sudo docker compose ps

# Check specific service
sudo docker compose ps grafana

# Check service health
sudo docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Check resource usage
docker stats
```

### Update Services

```bash
# Pull latest code
git pull --ff-only

# Rebuild and restart services
sudo docker compose up -d --build

# Verify deployment
sudo docker compose ps

# Check logs for errors
sudo docker compose logs --tail=50
```

### Stop Services

```bash
# Stop all services
sudo docker compose stop

# Stop specific service
sudo docker compose stop grafana

# Stop and remove containers (keeps volumes)
sudo docker compose down

# Stop and remove everything including volumes (WARNING: deletes data!)
sudo docker compose down -v
```

### Backup

Create manual backups of your data and configuration:

```bash
# Create backup directory
mkdir -p ~/backups

# Backup InfluxDB data
sudo docker compose exec influxdb influx backup /backups/backup-$(date +%Y%m%d-%H%M%S)

# Backup configuration files
tar -czf ~/backups/config-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  .env.production \
  docker-compose.yml \
  grafana/provisioning/ \
  node-red/data/ \
  nginx/nginx.conf

# Backup Docker volumes
sudo docker run --rm \
  -v plat-edu-bad-data-mvp_influxdb_data:/data:ro \
  -v ~/backups:/backup \
  alpine tar czf /backup/volumes-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .

# List backups
ls -lh ~/backups/
```

**Automated Backup Script:**

If using PowerShell scripts from Windows:

```powershell
# Create backup
.\scripts\backup-apps.ps1

# Backups are saved to backups/apps-{timestamp}.zip
```

## Production Configuration

### Resource Limits

Production services can have resource limits configured in `docker-compose.prod.yml`:

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
- **Grafana**: Checks `/api/health` endpoint every 30 seconds
- **InfluxDB**: Checks `/health` endpoint every 30 seconds
- **Node-RED**: Checks HTTP endpoint every 30 seconds
- Services automatically restart if health checks fail

## Security Considerations

1. **Change Default Passwords**: Update all passwords in `.env.production`
   - Grafana: Change from `admin/admin`
   - Node-RED: Change from `admin/adminpassword`
   - InfluxDB: Change from `admin/admin_password_123`
   - MQTT: Change from `admin/admin_password_456`

2. **Use Strong Tokens**: Generate secure tokens for InfluxDB
   ```bash
   # Generate secure token
   openssl rand -hex 32
   ```

3. **Enable HTTPS**: Consider setting up SSL/TLS certificates for each service
   - Use Let's Encrypt for free certificates
   - Configure certificates per service

4. **Rate Limiting**: API should implement rate limiting (future enhancement)

5. **Regular Backups**: Run backup script regularly
   ```bash
   # Add to crontab for daily backups
   crontab -e
   # Add: 0 2 * * * /home/viktar/plat-edu-bad-data-mvp/scripts/backup.sh
   ```

6. **Monitor Logs**: Check logs for suspicious activity
   ```bash
   # Check for failed login attempts
   sudo docker compose logs | grep -i "failed\|error\|unauthorized"
   ```

7. **Keep Updated**: Regularly update Docker images and dependencies
   ```bash
   # Update Docker images
   sudo docker compose pull
   sudo docker compose up -d
   ```

8. **Firewall Rules**: Ensure only necessary ports are open
   - Port 10108: SSH (required)
   - Port 20108: Nginx HTTP (required)
   - Port 30108: Nginx HTTPS (required when SSL is configured)
   - Port 40098: MQTT broker (required for direct MQTT connections)
   - Close all other ports

## Troubleshooting

### Services Not Starting

```bash
# Check logs for errors
sudo docker compose logs

# Check Docker status
sudo docker compose ps

# Check individual service logs
sudo docker compose logs grafana
sudo docker compose logs node-red
sudo docker compose logs influxdb

# Check Docker daemon
sudo systemctl status docker

# Restart Docker daemon (if needed)
sudo systemctl restart docker
```

### Port Already in Use

```bash
# Check what's using the ports
sudo netstat -tulpn | grep -E "20108|30108|40098"
sudo ss -tulpn | grep -E "20108|30108|40098"

# Check Docker containers using ports
sudo docker ps --format "table {{.Names}}\t{{.Ports}}"

# Stop conflicting containers
sudo docker stop <container-name>

# Or change ports in .env.production and docker-compose.yml
```

### Nginx Not Routing Correctly

```bash
# Check Nginx container logs
sudo docker compose logs nginx

# Verify Nginx configuration
sudo docker compose exec nginx nginx -t

# Reload Nginx configuration (if config changed)
sudo docker compose exec nginx nginx -s reload

# Check if services are accessible internally
sudo docker compose exec nginx ping -c 3 iot-grafana
sudo docker compose exec nginx curl http://iot-grafana:3000/api/health

# Test Nginx routing
curl http://localhost:20108/health
curl http://localhost:20108/grafana/
```

### API Not Connecting to InfluxDB

```bash
# Check API environment variables
sudo docker compose exec api env | grep INFLUX

# Check network connectivity
sudo docker compose exec api ping -c 3 influxdb

# Check InfluxDB health (internal)
curl http://localhost:8086/health

# Check InfluxDB through Nginx
curl http://localhost:20108/influxdb/health

# Check InfluxDB logs
sudo docker compose logs influxdb

# Verify InfluxDB is accessible from API container
sudo docker compose exec api curl http://iot-influxdb2:8086/health
```

### Frontend Not Loading

```bash
# Check frontend logs
sudo docker compose logs frontend

# Verify environment variables were set during build
sudo docker compose exec frontend env | grep VITE

# Rebuild frontend with correct env vars
sudo docker compose up -d --build frontend

# Check if frontend container is running
sudo docker compose ps frontend

# Check port mapping
sudo docker compose ps | grep frontend

# Check frontend through Nginx
curl http://localhost:20108/app/
```

### Grafana Not Accessible

```bash
# Check Grafana logs
sudo docker compose logs grafana

# Check Nginx logs for routing issues
sudo docker compose logs nginx | grep grafana

# Verify Grafana is running
sudo docker compose ps grafana

# Check Grafana health (internal)
curl http://localhost:3000/api/health

# Check Grafana through Nginx
curl http://localhost:20108/grafana/

# Verify environment variables
sudo docker compose exec grafana env | grep GF_

# Verify Grafana sub-path configuration
sudo docker compose exec grafana env | grep GF_SERVER_SERVE_FROM_SUB_PATH
```

### Node-RED Not Accessible

```bash
# Check Node-RED logs
sudo docker compose logs node-red

# Check Nginx logs for routing issues
sudo docker compose logs nginx | grep nodered

# Verify Node-RED is running
sudo docker compose ps node-red

# Check Node-RED health (internal)
curl http://localhost:1880

# Check Node-RED through Nginx
curl http://localhost:20108/nodered/

# Check Node-RED can connect to InfluxDB
sudo docker compose exec node-red env | grep INFLUX
```

### MQTT Broker Issues

```bash
# Check Mosquitto logs
sudo docker compose logs mosquitto

# Test MQTT connection (from local machine)
mosquitto_pub -h robert108.mikrus.xyz -p 40098 -u admin -P admin_password_456 -t test/topic -m "test message"

# Check MQTT port is open
nc -zv robert108.mikrus.xyz 40098

# Verify Mosquitto configuration
sudo docker compose exec mosquitto cat /mosquitto/config/mosquitto.conf
```

### Permission Denied Errors

```bash
# Fix permissions for all volumes
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data

# Fix permissions recursively
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data

# Restart services after fixing permissions
sudo docker compose restart
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Check Docker disk usage
sudo docker system df

# Clean up unused Docker resources
sudo docker system prune -a

# Remove unused volumes (WARNING: may delete data!)
sudo docker volume prune

# Check largest directories
du -sh * | sort -h
```

## Performance Optimization

### Enable Docker BuildKit

```bash
# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Or add to ~/.bashrc for persistence
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
echo 'export COMPOSE_DOCKER_CLI_BUILD=1' >> ~/.bashrc
```

### Monitor Resource Usage

```bash
# Monitor all containers
docker stats

# Monitor specific containers
docker stats iot-grafana iot-node-red iot-influxdb2

# Check container resource limits
sudo docker inspect iot-grafana | grep -A 10 "Resources"
```

### Optimize InfluxDB

```bash
# Check InfluxDB performance
sudo docker compose exec influxdb influx query 'SHOW STATS'

# Monitor InfluxDB disk usage
sudo docker compose exec influxdb influx query 'SHOW DATABASES'
```

## Backup and Recovery

### Create Backup

**Using PowerShell Script (from Windows):**

```powershell
.\scripts\backup-apps.ps1
```

**Manual Backup (on VPS):**

```bash
# Create backup script
cat > ~/backup-iot-system.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/backups
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR

# Backup InfluxDB
sudo docker compose exec -T influxdb influx backup /backups/backup-$DATE

# Backup configuration
tar -czf $BACKUP_DIR/config-$DATE.tar.gz \
  .env.production \
  docker-compose.yml \
  grafana/provisioning/ \
  node-red/data/

echo "Backup completed: $BACKUP_DIR/config-$DATE.tar.gz"
EOF

chmod +x ~/backup-iot-system.sh
~/backup-iot-system.sh
```

### Restore from Backup

```bash
# Restore InfluxDB backup
sudo docker compose exec influxdb influx restore /backups/backup-YYYYMMDD-HHMMSS

# Restore configuration files
tar -xzf ~/backups/config-YYYYMMDD-HHMMSS.tar.gz

# Restart services
sudo docker compose restart
```

## Next Steps

- Set up automated backups (cron job)
- Configure SSL/TLS certificates for each service
- Implement rate limiting in API
- Set up monitoring alerts
- Configure log aggregation
- Set up automated updates
- Implement health check monitoring
- Create disaster recovery plan

## Support

For issues or questions:

1. **Check Logs**: `sudo docker compose logs -f`
2. **Review Troubleshooting**: See troubleshooting section above
3. **Check Service Health**: `sudo docker compose ps`
4. **Monitor Resources**: `docker stats`
5. **Verify Ports**: Test each service port individually
6. **Check Permissions**: Verify file permissions on volumes

## Quick Reference

### Common Commands

```bash
# Start all services
sudo docker compose up -d

# Stop all services
sudo docker compose stop

# Restart all services
sudo docker compose restart

# View logs
sudo docker compose logs -f

# Check status
sudo docker compose ps

# Rebuild services
sudo docker compose up -d --build

# Remove everything
sudo docker compose down -v
```

### Service URLs

- Grafana: http://robert108.mikrus.xyz:20108/grafana/
- Node-RED: http://robert108.mikrus.xyz:20108/nodered/
- InfluxDB: http://robert108.mikrus.xyz:20108/influxdb/
- API: http://robert108.mikrus.xyz:20108/api/
- Frontend: http://robert108.mikrus.xyz:20108/app/
- Root/Health: http://robert108.mikrus.xyz:20108/health
- MQTT: robert108.mikrus.xyz:40098 (direct connection)

### Default Credentials (CHANGE IN PRODUCTION!)

- Grafana: `admin` / `admin`
- Node-RED: `admin` / `adminpassword`
- InfluxDB: `admin` / `admin_password_123`
- MQTT: `admin` / `admin_password_456`

