# Step 7: Production Deployment Configuration

## Context
You have successfully integrated frontend and api services into your Docker monorepo. Now you need to prepare for production deployment on your VPS (robert108.mikrus.xyz).

## Current Production Ports (Mikrus VPS)
- MQTT (mosquitto): 40098
- Grafana: 40099
- Node-RED: 40100
- InfluxDB: 40101
- **API (NEW)**: 40102
- **Frontend (NEW)**: 40103

## Task
Create production-ready configuration for VPS deployment with:
1. Production environment variables
2. Optimized Docker configurations
3. Nginx reverse proxy configuration (optional)
4. SSL/TLS setup (optional)
5. Backup and monitoring procedures

## Implementation

### 1. Create Production Environment File

Create `.env.production`:
```bash
# ===========================================
# PRODUCTION ENVIRONMENT - Mikrus VPS
# ===========================================

# Network Configuration
COMPOSE_PROJECT_NAME=renewable-energy-iot
DOCKER_NETWORK=iot-network

# ===========================================
# MQTT Broker - Mosquitto
# ===========================================
MQTT_PORT=40098
MQTT_WS_PORT=9001
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=<STRONG_PASSWORD_HERE>
MOSQUITTO_LOG_LEVEL=information
MOSQUITTO_MAX_CONNECTIONS=1000
MOSQUITTO_MAX_QUEUED_MESSAGES=100
MOSQUITTO_AUTOSAVE_INTERVAL=1800

# ===========================================
# InfluxDB 2.x
# ===========================================
INFLUXDB_PORT=40101
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=<STRONG_PASSWORD_HERE>
INFLUXDB_ADMIN_TOKEN=<STRONG_TOKEN_HERE>
INFLUXDB_HTTP_AUTH_ENABLED=false
INFLUXDB_DB=renewable_energy
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=30d
INFLUXDB_SETUP_MODE=setup
INFLUXDB_REPORTING_DISABLED=true
INFLUXDB_META_DIR=/var/lib/influxdb2/meta
INFLUXDB_DATA_DIR=/var/lib/influxdb2/data
INFLUXDB_WAL_DIR=/var/lib/influxdb2/wal
INFLUXDB_ENGINE_PATH=/var/lib/influxdb2/engine
INFLUXDB_MAX_CONCURRENT_COMPACTIONS=0
INFLUXDB_HTTP_BIND_ADDRESS=:8086
INFLUXDB_HTTP_PORT=8086
INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=0
INFLUXDB_HTTP_READ_TIMEOUT=30s
INFLUXDB_LOGGING_LEVEL=info
INFLUXDB_LOGGING_FORMAT=auto
INFLUXDB_METRICS_DISABLED=true
INFLUXDB_PPROF_ENABLED=false

# ===========================================
# Node-RED
# ===========================================
NODE_RED_PORT=40100
NODE_RED_USERNAME=admin
NODE_RED_PASSWORD=<STRONG_PASSWORD_HERE>

# ===========================================
# Grafana
# ===========================================
GRAFANA_PORT=40099
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=<STRONG_PASSWORD_HERE>
GF_SERVER_ROOT_URL=http://robert108.mikrus.xyz:40099
GF_SERVER_SERVE_FROM_SUB_PATH=false

# ===========================================
# API Backend
# ===========================================
API_PORT=40102
NODE_ENV=production
INFLUXDB_URL=http://influxdb:8086
CORS_ORIGIN=http://robert108.mikrus.xyz:40103,https://robert108.mikrus.xyz:40103
TEST_TOKEN=<INFLUXDB_ADMIN_TOKEN>

# ===========================================
# Frontend
# ===========================================
FRONTEND_PORT=40103
VITE_API_URL=http://robert108.mikrus.xyz:40102
VITE_API_BASE_URL=http://robert108.mikrus.xyz:40102/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
VITE_APP_TITLE=Renewable Energy Monitoring
VITE_APP_VERSION=1.0.0
```

### 2. Create Production Docker Compose Override

Create `docker-compose.prod.yml`:
```yaml
version: '3.8'

services:
  # API - Production overrides
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
    environment:
      - NODE_ENV=production
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  # Frontend - Production overrides
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
        - VITE_API_URL=${VITE_API_URL}
        - VITE_API_BASE_URL=${VITE_API_BASE_URL}
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 256M
        reservations:
          cpus: '0.1'
          memory: 128M
```

### 3. Update Production Build Process

Create `scripts/deploy-production-apps.ps1`:
```powershell
#!/usr/bin/env pwsh
# Production Deployment Script for Frontend and API

param(
    [switch]$Build,
    [switch]$Deploy,
    [switch]$Restart,
    [switch]$Logs,
    [switch]$Status
)

$ErrorActionPreference = "Stop"

Write-Host "`n🚀 Renewable Energy IoT - Production Deployment`n" -ForegroundColor Cyan

# Load production environment
$envFile = ".env.production"
if (Test-Path $envFile) {
    Write-Host "📋 Loading production environment from $envFile" -ForegroundColor Yellow
} else {
    Write-Host "❌ Production environment file not found: $envFile" -ForegroundColor Red
    exit 1
}

# Build services
if ($Build) {
    Write-Host "`n🔨 Building production images...`n" -ForegroundColor Cyan
    
    Write-Host "Building API..." -ForegroundColor Yellow
    docker-compose `
        --env-file .env.production `
        -f docker-compose.yml `
        -f docker-compose.prod.yml `
        build --no-cache api
    
    Write-Host "`nBuilding Frontend..." -ForegroundColor Yellow
    docker-compose `
        --env-file .env.production `
        -f docker-compose.yml `
        -f docker-compose.prod.yml `
        build --no-cache frontend
    
    Write-Host "`n✅ Build completed`n" -ForegroundColor Green
}

# Deploy services
if ($Deploy) {
    Write-Host "`n🚢 Deploying to production...`n" -ForegroundColor Cyan
    
    # Stop existing services
    Write-Host "Stopping existing services..." -ForegroundColor Yellow
    docker-compose `
        --env-file .env.production `
        stop api frontend
    
    # Remove old containers
    Write-Host "Removing old containers..." -ForegroundColor Yellow
    docker-compose `
        --env-file .env.production `
        rm -f api frontend
    
    # Start new services
    Write-Host "Starting new services..." -ForegroundColor Yellow
    docker-compose `
        --env-file .env.production `
        -f docker-compose.yml `
        -f docker-compose.prod.yml `
        up -d api frontend
    
    Write-Host "`n✅ Deployment completed`n" -ForegroundColor Green
    
    # Show status
    Write-Host "Service Status:" -ForegroundColor Cyan
    docker-compose --env-file .env.production ps api frontend
}

# Restart services
if ($Restart) {
    Write-Host "`n🔄 Restarting services...`n" -ForegroundColor Cyan
    
    docker-compose --env-file .env.production restart api frontend
    
    Write-Host "`n✅ Services restarted`n" -ForegroundColor Green
}

# Show logs
if ($Logs) {
    Write-Host "`n📋 Showing logs (Ctrl+C to exit)...`n" -ForegroundColor Cyan
    
    docker-compose --env-file .env.production logs -f --tail=100 api frontend
}

# Show status
if ($Status) {
    Write-Host "`n📊 Service Status`n" -ForegroundColor Cyan
    
    docker-compose --env-file .env.production ps
    
    Write-Host "`n🔍 Health Checks`n" -ForegroundColor Cyan
    
    $apiPort = (Get-Content .env.production | Select-String "API_PORT=").ToString().Split("=")[1]
    $frontendPort = (Get-Content .env.production | Select-String "FRONTEND_PORT=").ToString().Split("=")[1]
    
    Write-Host "API Health:" -ForegroundColor Yellow
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$apiPort/health" -TimeoutSec 5
        Write-Host "   ✅ $($health | ConvertTo-Json)" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Not responding" -ForegroundColor Red
    }
    
    Write-Host "`nFrontend Health:" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$frontendPort/health" -TimeoutSec 5
        Write-Host "   ✅ Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Not responding" -ForegroundColor Red
    }
}

# Show help if no parameters
if (-not ($Build -or $Deploy -or $Restart -or $Logs -or $Status)) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\deploy-production-apps.ps1 -Build     # Build production images" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Deploy    # Deploy to production" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Restart   # Restart services" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Logs      # Show logs" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Status    # Show status" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "✨ Done!`n" -ForegroundColor Cyan
```

### 4. Create Backup Script for API Data

Create `scripts/backup-apps.ps1`:
```powershell
#!/usr/bin/env pwsh
# Backup script for API and Frontend configurations

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "backups/apps-$timestamp"

Write-Host "`n💾 Creating backup...`n" -ForegroundColor Cyan

# Create backup directory
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

# Backup API
Write-Host "Backing up API..." -ForegroundColor Yellow
Copy-Item -Recurse "api/src" "$backupDir/api-src"
Copy-Item "api/package.json" "$backupDir/api-package.json"
Copy-Item "api/Dockerfile" "$backupDir/api-Dockerfile"

# Backup Frontend
Write-Host "Backing up Frontend..." -ForegroundColor Yellow
Copy-Item -Recurse "frontend/src" "$backupDir/frontend-src"
Copy-Item "frontend/package.json" "$backupDir/frontend-package.json"
Copy-Item "frontend/Dockerfile" "$backupDir/frontend-Dockerfile"
Copy-Item "frontend/nginx.conf" "$backupDir/frontend-nginx.conf"

# Backup configurations
Write-Host "Backing up configurations..." -ForegroundColor Yellow
Copy-Item ".env.production" "$backupDir/.env.production"
Copy-Item "docker-compose.yml" "$backupDir/docker-compose.yml"
Copy-Item "docker-compose.prod.yml" "$backupDir/docker-compose.prod.yml"

# Create archive
Write-Host "Creating archive..." -ForegroundColor Yellow
Compress-Archive -Path $backupDir -DestinationPath "$backupDir.zip"
Remove-Item -Recurse -Force $backupDir

Write-Host "`n✅ Backup created: $backupDir.zip`n" -ForegroundColor Green
```

### 5. Update Main README with Production URLs

Add to your main `README.md`:

```markdown
## Production Access URLs

Access the production system at:

- **Frontend Dashboard**: http://robert108.mikrus.xyz:40103
- **API Endpoints**: http://robert108.mikrus.xyz:40102
  - Health: http://robert108.mikrus.xyz:40102/health
  - Summary: http://robert108.mikrus.xyz:40102/api/summary/{device}
- **Grafana**: http://robert108.mikrus.xyz:40099
- **Node-RED**: http://robert108.mikrus.xyz:40100
- **InfluxDB**: http://robert108.mikrus.xyz:40101

## Quick Production Deployment

```powershell
# Build production images
.\scripts\deploy-production-apps.ps1 -Build

# Deploy to production
.\scripts\deploy-production-apps.ps1 -Deploy

# Check status
.\scripts\deploy-production-apps.ps1 -Status

# View logs
.\scripts\deploy-production-apps.ps1 -Logs
```
```

### 6. Create Monitoring Script

Create `scripts/monitor-apps.ps1`:
```powershell
#!/usr/bin/env pwsh
# Monitoring script for API and Frontend

Write-Host "`n📊 System Monitoring Dashboard`n" -ForegroundColor Cyan

while ($true) {
    Clear-Host
    Write-Host "🔄 Renewable Energy IoT - Live Monitoring" -ForegroundColor Cyan
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "Press Ctrl+C to exit`n" -ForegroundColor Yellow
    
    # API Health
    Write-Host "API Service:" -ForegroundColor Yellow
    try {
        $apiHealth = Invoke-RestMethod -Uri "http://localhost:40102/health" -TimeoutSec 3
        Write-Host "   Status: ✅ Healthy" -ForegroundColor Green
        Write-Host "   Response: $($apiHealth | ConvertTo-Json)" -ForegroundColor Gray
    } catch {
        Write-Host "   Status: ❌ Unhealthy" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Red
    }
    
    # Frontend Health
    Write-Host "`nFrontend Service:" -ForegroundColor Yellow
    try {
        $frontendHealth = Invoke-WebRequest -Uri "http://localhost:40103/health" -TimeoutSec 3
        Write-Host "   Status: ✅ Healthy (HTTP $($frontendHealth.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "   Status: ❌ Unhealthy" -ForegroundColor Red
    }
    
    # Container Stats
    Write-Host "`nContainer Status:" -ForegroundColor Yellow
    $containers = docker ps --filter "name=iot-api" --filter "name=iot-frontend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    Write-Host $containers -ForegroundColor Gray
    
    # Resource Usage
    Write-Host "`nResource Usage:" -ForegroundColor Yellow
    $stats = docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" iot-api iot-frontend 2>$null
    Write-Host $stats -ForegroundColor Gray
    
    Start-Sleep -Seconds 5
}
```

## Deployment Steps for VPS

### Initial Deployment:

1. **Prepare environment:**
```powershell
# Copy .env.production and update passwords/tokens
cp env.example .env.production
# Edit .env.production with production values
```

2. **Build images:**
```powershell
.\scripts\deploy-production-apps.ps1 -Build
```

3. **Deploy services:**
```powershell
.\scripts\deploy-production-apps.ps1 -Deploy
```

4. **Verify deployment:**
```powershell
.\scripts\deploy-production-apps.ps1 -Status
```

5. **Access services:**
- Frontend: http://robert108.mikrus.xyz:40103
- API: http://robert108.mikrus.xyz:40102

### Updates and Maintenance:

```powershell
# Rebuild and deploy
.\scripts\deploy-production-apps.ps1 -Build
.\scripts\deploy-production-apps.ps1 -Deploy

# Restart services (without rebuild)
.\scripts\deploy-production-apps.ps1 -Restart

# Monitor services
.\scripts\monitor-apps.ps1

# Create backup
.\scripts\backup-apps.ps1
```

## Security Considerations

1. **Change default passwords** in `.env.production`
2. **Use strong tokens** for InfluxDB and authentication
3. **Enable HTTPS** if possible (requires SSL certificates)
4. **Implement rate limiting** in API (add express-rate-limit)
5. **Regular backups** of InfluxDB data and configurations
6. **Monitor logs** for suspicious activity
7. **Keep Docker images updated** regularly

## Performance Optimization

1. **Enable Docker BuildKit:**
```powershell
$env:DOCKER_BUILDKIT=1
$env:COMPOSE_DOCKER_CLI_BUILD=1
```

2. **Resource limits** are set in docker-compose.prod.yml
3. **Log rotation** is configured with max-size: 10m, max-file: 3
4. **Frontend caching** is enabled in nginx.conf
5. **API connection pooling** (already implemented in InfluxDB client)

## Next Steps
- Monitor system performance
- Set up automated backups
- Implement SSL/TLS certificates (optional)
- Configure firewall rules on VPS
- Set up alerts for service failures

## Notes
- All ports are configured for Mikrus VPS
- Frontend is served via nginx for optimal performance
- API has resource limits to prevent memory leaks
- Logs are automatically rotated to save disk space
- Health checks ensure services restart on failure
- Use docker-compose.prod.yml for production-specific settings

