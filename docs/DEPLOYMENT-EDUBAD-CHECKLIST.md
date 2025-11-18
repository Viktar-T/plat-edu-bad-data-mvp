# 🚀 Deployment Checklist - edubad.zut.edu.pl

## 📋 Pre-Deployment Preparation

This document provides a complete checklist and preparation guide for deploying the Renewable Energy IoT Monitoring System to **edubad.zut.edu.pl** (82.145.64.204).

---

## 🔍 Current System Analysis

### ✅ Local Development Status (Working)
- **Nginx Reverse Proxy**: Port 8080
- **React Frontend**: `http://localhost:8080/app/`
- **Express API**: `http://localhost:8080/api/`
- **Grafana**: `http://localhost:8080/grafana/`
- **Node-RED**: `http://localhost:8080/nodered/`
- **InfluxDB Admin**: `http://localhost:8080/influxdb/`
- **MQTT**: `localhost:1883` (direct connection)

### 🎯 Production Architecture (edubad.zut.edu.pl)
Production deployment uses **direct port access** for each service (no nginx reverse proxy):

- **Frontend Dashboard**: Individual port
- **API Endpoints**: Individual port  
- **Grafana**: Individual port
- **Node-RED**: Individual port
- **InfluxDB**: Individual port
- **MQTT**: Individual port

---

## 📦 1. Repository Preparation

### Files to Review and Update

#### ✅ Core Configuration Files
- [x] `docker-compose.yml` - Production Docker Compose configuration
- [x] `.env.production` - Production environment variables
- [ ] Update `.env.production` with edubad.zut.edu.pl specific settings

#### ✅ Service Configurations
- [x] `mosquitto/config/mosquitto.conf` - MQTT broker configuration
- [x] `mosquitto/config/passwd` - MQTT authentication (encrypted passwords)
- [x] `mosquitto/config/acl` - MQTT access control
- [x] `influxdb/config/` - InfluxDB configuration files
- [x] `node-red/settings.js` - Node-RED configuration
- [x] `node-red/package.json` - Node-RED dependencies
- [x] `grafana/provisioning/` - Grafana auto-provisioning

#### ✅ Application Code
- [x] `api/` - Express.js backend (ready)
- [x] `frontend/` - React frontend (ready)
- [x] `frontend/Dockerfile` - Frontend build configuration
- [x] `api/Dockerfile` - API build configuration

#### ⚠️ Security Review Required
- [ ] Change all default passwords in `.env.production`
- [ ] Generate strong tokens for InfluxDB
- [ ] Review MQTT passwords
- [ ] Review Node-RED admin password
- [ ] Review Grafana admin password

---

## 🔧 2. Environment Configuration (.env.production)

### Required Updates for edubad.zut.edu.pl

Create/update `.env.production` with the following configuration:

```bash
# ===========================================
# PRODUCTION ENVIRONMENT - edubad.zut.edu.pl
# ===========================================

# Network Configuration
COMPOSE_PROJECT_NAME=renewable-energy-iot
DOCKER_NETWORK=iot-network

# ===========================================
# PORT CONFIGURATION - Update with actual ports
# ===========================================
MQTT_PORT=[YOUR_MQTT_PORT]           # e.g., 40098
GRAFANA_PORT=[YOUR_GRAFANA_PORT]     # e.g., 40099
NODE_RED_PORT=[YOUR_NODERED_PORT]    # e.g., 40100
INFLUXDB_PORT=[YOUR_INFLUXDB_PORT]   # e.g., 40101
API_PORT=[YOUR_API_PORT]             # e.g., 40102
FRONTEND_PORT=[YOUR_FRONTEND_PORT]   # e.g., 40103

# ===========================================
# SERVER CONFIGURATION
# ===========================================
SERVER_HOST=edubad.zut.edu.pl
SERVER_IP=82.145.64.204

# ===========================================
# MQTT BROKER - SECURITY CRITICAL
# ===========================================
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=[CHANGE_TO_STRONG_PASSWORD]
MOSQUITTO_LOG_LEVEL=information

# ===========================================
# INFLUXDB - SECURITY CRITICAL
# ===========================================
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=[CHANGE_TO_STRONG_PASSWORD]
INFLUXDB_ADMIN_TOKEN=[CHANGE_TO_STRONG_TOKEN]
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=30d

# ===========================================
# NODE-RED - SECURITY CRITICAL
# ===========================================
NODE_RED_USERNAME=admin
NODE_RED_PASSWORD=[CHANGE_TO_STRONG_PASSWORD]

# ===========================================
# GRAFANA - SECURITY CRITICAL
# ===========================================
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=[CHANGE_TO_STRONG_PASSWORD]
GF_SERVER_ROOT_URL=http://edubad.zut.edu.pl:[YOUR_GRAFANA_PORT]
GF_SERVER_SERVE_FROM_SUB_PATH=false

# ===========================================
# API BACKEND
# ===========================================
NODE_ENV=production
INFLUXDB_URL=http://influxdb:8086
CORS_ORIGIN=http://edubad.zut.edu.pl:[YOUR_FRONTEND_PORT],https://edubad.zut.edu.pl:[YOUR_FRONTEND_PORT]
TEST_TOKEN=[SAME_AS_INFLUXDB_ADMIN_TOKEN]

# ===========================================
# FRONTEND
# ===========================================
VITE_API_URL=http://edubad.zut.edu.pl:[YOUR_API_PORT]
VITE_API_BASE_URL=http://edubad.zut.edu.pl:[YOUR_API_PORT]/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
```

### 🔐 Security Recommendations

1. **Generate Strong Passwords**:
   ```bash
   # Generate random password (20 characters)
   openssl rand -base64 20
   ```

2. **Generate Strong Token**:
   ```bash
   # Generate random token (32 characters)
   openssl rand -hex 32
   ```

3. **Update MQTT Passwords**:
   ```bash
   # On the server, update Mosquitto passwords
   docker exec iot-mosquitto mosquitto_passwd -b /mosquitto/config/passwd admin [NEW_PASSWORD]
   ```

---

## 📂 3. Files to Transfer

### Required Directories and Files

```
plat-edu-bad-data-mvp/
├── docker-compose.yml              # ✅ Production compose file
├── docker-compose.prod.yml         # ✅ Optional production override
├── .env.production → .env          # ⚠️ Update then transfer
├── mosquitto/                      # ✅ Complete directory
│   ├── config/
│   │   ├── mosquitto.conf
│   │   ├── passwd
│   │   └── acl
├── influxdb/                       # ✅ Complete directory
│   └── config/
├── node-red/                       # ✅ Complete directory
│   ├── settings.js
│   ├── package.json
│   ├── startup.sh
│   └── flows/
├── grafana/                        # ✅ Complete directory
│   ├── dashboards/
│   └── provisioning/
├── api/                            # ✅ Complete directory
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│   └── public/
├── frontend/                       # ✅ Complete directory
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│   ├── public/
│   ├── nginx.conf
│   └── vite.config.js
└── nginx/                          # ⚠️ Only if using nginx
    └── nginx.conf
```

### 📋 File Verification Checklist

```bash
# Run this on your local machine to verify all required files exist
$files = @(
    "docker-compose.yml",
    ".env.production",
    "mosquitto/config/mosquitto.conf",
    "mosquitto/config/passwd",
    "mosquitto/config/acl",
    "influxdb/config/influxdb.conf",
    "node-red/settings.js",
    "node-red/package.json",
    "node-red/startup.sh",
    "grafana/provisioning/datasources/influxdb.yaml",
    "grafana/provisioning/dashboards/dashboard.yaml",
    "api/Dockerfile",
    "api/package.json",
    "api/src/index.js",
    "frontend/Dockerfile",
    "frontend/package.json",
    "frontend/vite.config.js"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
    }
}
```

---

## 🔍 4. Configuration Review

### Docker Compose Validation

```bash
# Validate docker-compose.yml syntax
docker-compose -f docker-compose.yml --env-file .env.production config
```

### Port Configuration Check

```bash
# Verify no port conflicts on production server
# SSH to edubad.zut.edu.pl and run:
sudo netstat -tulpn | grep -E '(40098|40099|40100|40101|40102|40103)'
```

### Build Images Locally (Recommended)

```powershell
# Build API image
docker-compose -f docker-compose.yml --env-file .env.production build api

# Build Frontend image  
docker-compose -f docker-compose.yml --env-file .env.production build frontend

# Test run locally
docker-compose -f docker-compose.yml --env-file .env.production up -d
```

---

## 🚢 5. Deployment Steps

### Step 1: Prepare Local Repository

```powershell
# 1. Update .env.production with edubad.zut.edu.pl configuration
# Edit .env.production manually

# 2. Commit changes (optional, but recommended)
git status
git add .
git commit -m "Configure for edubad.zut.edu.pl deployment"

# 3. Push to repository
git push origin main
```

### Step 2: Transfer Files to Server

**Option A: Using Git (Recommended)**

```bash
# SSH to edubad.zut.edu.pl
ssh admin@edubad.zut.edu.pl
# or
ssh admin@82.145.64.204

# Clone repository
cd ~
git clone https://github.com/Viktar-T/plat-edu-bad-data-mvp.git
cd plat-edu-bad-data-mvp

# Copy production environment
cp .env.production .env

# Update .env with server-specific values if needed
nano .env
```

**Option B: Using SCP (Alternative)**

```powershell
# From your local machine
$remoteHost = "admin@edubad.zut.edu.pl"
$remotePath = "~/renewable-energy-iot"

# Create remote directory
ssh $remoteHost "mkdir -p $remotePath"

# Transfer files
scp docker-compose.yml "${remoteHost}:${remotePath}/"
scp .env.production "${remoteHost}:${remotePath}/.env"
scp -r mosquitto "${remoteHost}:${remotePath}/"
scp -r influxdb "${remoteHost}:${remotePath}/"
scp -r node-red "${remoteHost}:${remotePath}/"
scp -r grafana "${remoteHost}:${remotePath}/"
scp -r api "${remoteHost}:${remotePath}/"
scp -r frontend "${remoteHost}:${remotePath}/"
```

### Step 3: Server Preparation

```bash
# SSH to edubad.zut.edu.pl
ssh admin@edubad.zut.edu.pl

# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Fix permissions (CRITICAL for Docker volumes)
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data

# Create necessary directories
mkdir -p ./influxdb/data
mkdir -p ./grafana/data
mkdir -p ./node-red/data
mkdir -p ./mosquitto/data
mkdir -p ./mosquitto/log
```

### Step 4: Deploy Services

```bash
# Pull Docker images
sudo docker-compose pull

# Build custom images (API and Frontend)
sudo docker-compose build --no-cache api frontend

# Start all services
sudo docker-compose up -d

# Check service status
sudo docker-compose ps

# View logs
sudo docker-compose logs -f
```

### Step 5: Verify Deployment

```bash
# Check container status
sudo docker-compose ps

# Check container logs
sudo docker-compose logs mosquitto
sudo docker-compose logs influxdb
sudo docker-compose logs node-red
sudo docker-compose logs grafana
sudo docker-compose logs api
sudo docker-compose logs frontend

# Check health of services
docker inspect --format='{{json .State.Health}}' iot-mosquitto
docker inspect --format='{{json .State.Health}}' iot-influxdb2
docker inspect --format='{{json .State.Health}}' iot-node-red
docker inspect --format='{{json .State.Health}}' iot-grafana
docker inspect --format='{{json .State.Health}}' iot-api
docker inspect --format='{{json .State.Health}}' iot-frontend
```

---

## ✅ 6. Post-Deployment Verification

### Service Accessibility Tests

```bash
# Test each service (replace [PORT] with actual port numbers)
curl -f http://edubad.zut.edu.pl:[GRAFANA_PORT]/api/health
curl -f http://edubad.zut.edu.pl:[NODERED_PORT]/
curl -f http://edubad.zut.edu.pl:[INFLUXDB_PORT]/health
curl -f http://edubad.zut.edu.pl:[API_PORT]/health
curl -f http://edubad.zut.edu.pl:[API_PORT]/api/health
curl -f http://edubad.zut.edu.pl:[FRONTEND_PORT]/
```

### MQTT Connection Test

```bash
# Test MQTT broker connection
mosquitto_sub -h edubad.zut.edu.pl -p [MQTT_PORT] -u admin -P [PASSWORD] -t "test/#" -v
```

### Database Connection Test

```bash
# Test InfluxDB connection
curl -X GET "http://edubad.zut.edu.pl:[INFLUXDB_PORT]/api/v2/buckets" \
  -H "Authorization: Token [YOUR_INFLUXDB_TOKEN]"
```

### Web Interface Tests

Open in browser:
- **Frontend**: `http://edubad.zut.edu.pl:[FRONTEND_PORT]/`
- **Grafana**: `http://edubad.zut.edu.pl:[GRAFANA_PORT]/`
- **Node-RED**: `http://edubad.zut.edu.pl:[NODERED_PORT]/`
- **InfluxDB**: `http://edubad.zut.edu.pl:[INFLUXDB_PORT]/`

---

## 🔧 7. Troubleshooting

### Common Issues and Solutions

#### Issue 1: Permission Denied Errors

```bash
# Fix Docker volume permissions
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data
```

#### Issue 2: Port Already in Use

```bash
# Check what's using the port
sudo netstat -tulpn | grep [PORT_NUMBER]

# Stop conflicting service
sudo systemctl stop [service_name]

# Or change port in .env file
```

#### Issue 3: Container Fails to Start

```bash
# Check container logs
sudo docker-compose logs [service_name]

# Restart specific service
sudo docker-compose restart [service_name]

# Recreate container
sudo docker-compose up -d --force-recreate [service_name]
```

#### Issue 4: Network Connectivity Issues

```bash
# Check Docker network
sudo docker network ls
sudo docker network inspect iot-network

# Recreate network
sudo docker-compose down
sudo docker-compose up -d
```

---

## 📊 8. Monitoring and Maintenance

### Health Check Commands

```bash
# Check all service status
sudo docker-compose ps

# Check resource usage
sudo docker stats

# Check disk usage
df -h
sudo du -sh ./influxdb/data
sudo du -sh ./grafana/data
sudo du -sh ./node-red/data
sudo du -sh ./mosquitto/data
```

### Log Monitoring

```bash
# View real-time logs
sudo docker-compose logs -f --tail=100

# View specific service logs
sudo docker-compose logs -f --tail=100 [service_name]

# Search logs for errors
sudo docker-compose logs | grep -i error
```

### Backup Strategy

```bash
# Create backup directory
mkdir -p ~/backups/renewable-energy-iot/$(date +%Y%m%d)

# Backup InfluxDB data
sudo docker exec iot-influxdb2 influx backup /backups/backup-$(date +%Y%m%d) -t [INFLUXDB_TOKEN]
sudo cp -r ./influxdb/data ~/backups/renewable-energy-iot/$(date +%Y%m%d)/

# Backup Grafana data
sudo cp -r ./grafana/data ~/backups/renewable-energy-iot/$(date +%Y%m%d)/

# Backup Node-RED flows
sudo cp -r ./node-red/data ~/backups/renewable-energy-iot/$(date +%Y%m%d)/

# Backup MQTT configuration
sudo cp -r ./mosquitto/config ~/backups/renewable-energy-iot/$(date +%Y%m%d)/
```

---

## 🔄 9. Update Procedure

### Updating the Application

```bash
# SSH to server
ssh admin@edubad.zut.edu.pl

# Navigate to project
cd ~/plat-edu-bad-data-mvp

# Pull latest changes
git pull origin main

# Rebuild and restart
sudo docker-compose build --no-cache api frontend
sudo docker-compose up -d

# Verify
sudo docker-compose ps
```

---

## 📝 10. Deployment Checklist Summary

### Pre-Deployment
- [ ] Update `.env.production` with edubad.zut.edu.pl configuration
- [ ] Change all default passwords
- [ ] Generate strong tokens
- [ ] Verify all required files exist
- [ ] Test build locally
- [ ] Commit and push changes to Git

### Deployment
- [ ] SSH to edubad.zut.edu.pl
- [ ] Clone/update repository
- [ ] Copy `.env.production` to `.env`
- [ ] Fix directory permissions
- [ ] Pull Docker images
- [ ] Build custom images
- [ ] Start services with `docker-compose up -d`

### Post-Deployment
- [ ] Verify all containers are running
- [ ] Test service accessibility
- [ ] Test MQTT connection
- [ ] Test InfluxDB connection
- [ ] Access web interfaces
- [ ] Monitor logs for errors
- [ ] Set up automated backups
- [ ] Document final port configuration

---

## 📞 Support and Contact

For deployment issues or questions:
- **Documentation**: Check `docs/` directory
- **Troubleshooting**: See section 7 above
- **Logs**: Always check Docker logs first

---

**Deployment Date**: _________________  
**Deployed By**: _________________  
**Server**: edubad.zut.edu.pl (82.145.64.204)  
**Status**: ⬜ Pending | ⬜ In Progress | ⬜ Completed | ⬜ Failed  


