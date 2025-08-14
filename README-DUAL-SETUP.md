# 🚀 Renewable Energy IoT Monitoring System - Dual Development/Deployment Setup

> **Professional IoT monitoring system with path-based routing and dual environment support**

## 📋 Overview

This project implements a comprehensive renewable energy IoT monitoring system with **dual environment support** and **path-based routing** using Nginx reverse proxy. The system saves 4 Mikrus VPS ports while providing a professional, scalable architecture.

### 🎯 Key Features
- **Dual Environment**: Local development + Production deployment
- **Path-Based Routing**: Single port for all web services via Nginx
- **Port Efficiency**: Uses only 4 Mikrus ports instead of 8+
- **Professional URLs**: Clean, organized URL structure
- **SSL Ready**: Easy HTTPS implementation
- **Scalable Architecture**: Easy to add new services

### 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MIKRUS VPS (Production)                  │
├─────────────────────────────────────────────────────────────┤
│  Port 10108: SSH Access                                     │
│  Port 20108: Nginx Reverse Proxy (All Web Services)        │
│  Port 30108: HTTPS (Future SSL)                             │
│  Port 40098: MQTT Broker (IoT Devices)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    NGINX REVERSE PROXY                      │
├─────────────────────────────────────────────────────────────┤
│  /grafana     → Grafana Dashboard                           │
│  /nodered     → Node-RED Editor                             │
│  /influxdb    → InfluxDB Admin                              │
│  /            → Redirects to /grafana/                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### **Local Development (Windows)**
```powershell
# Start local development environment
.\scripts\dev-local.ps1

# Access your services via Nginx reverse proxy:
# - Grafana:  http://localhost:8080/grafana/
# - Node-RED: http://localhost:8080/nodered/
# - InfluxDB: http://localhost:8080/influxdb/
# - Health:   http://localhost:8080/health
# MQTT remains direct: 1883 (TCP), 9001 (WS)
# (Express API and React App under development, not started)
```

### **Production Deployment (Mikrus VPS)**
```powershell
# Prepare and deploy to VPS
.\scripts\deploy-production.ps1 -Full

# Access your services:
# - Grafana: http://robert108.mikrus.xyz:20108/grafana
# - Node-RED: http://robert108.mikrus.xyz:20108/nodered
# - InfluxDB: http://robert108.mikrus.xyz:20108/influxdb
# (Express API and React App under development, not deployed)
```

---

## 📁 Project Structure

```
plat-edu-bad-data-mvp/
├── 📄 docker-compose.yml              # Production configuration
├── 📄 docker-compose.local.yml        # Local development
├── 📄 .env.local                      # Local environment variables
├── 📄 .env.production                 # Production environment variables
├── 📄 env.example                     # Environment template
├── 📁 nginx/
│   └── 📄 nginx.conf                  # Nginx reverse proxy config
├── 📁 scripts/
│   ├── 📄 dev-local.ps1               # Local development script
│   └── 📄 deploy-production.ps1       # Production deployment script
├── 📁 mosquitto/                      # MQTT broker configuration
├── 📁 influxdb/                       # InfluxDB configuration
├── 📁 node-red/                       # Node-RED configuration
├── 📁 grafana/                        # Grafana configuration
├── 📁 web-app-for-testing/            # Custom web application
└── 📁 docs/                           # Documentation
```

---

## 🔧 Environment Configuration

### **Local Development (.env.local)**
```bash
# Local Development Settings
SERVER_IP=localhost
SERVER_PORT=22

# Standard ports for local development
MQTT_PORT=1883
MQTT_WS_PORT=9001
NODE_RED_PORT=1880
INFLUXDB_PORT=8086
GRAFANA_PORT=3000
# Local URLs
GF_SERVER_ROOT_URL=http://localhost:3000
```

### **Production (.env.production)**
```bash
# Production Settings (Mikrus VPS)
SERVER_IP=robert108.mikrus.xyz
SERVER_PORT=10108

# Mikrus custom ports with path-based routing
MQTT_PORT=40098                    # MQTT broker
NGINX_HTTP_PORT=20108              # Nginx reverse proxy
NGINX_HTTPS_PORT=30108             # HTTPS (future)

# Production URLs
GF_SERVER_ROOT_URL=http://robert108.mikrus.xyz:20108/grafana
##
```

---

## 🌐 URL Structure

### **Local Development URLs**
```
http://localhost:8080/grafana/     # Grafana Dashboard (via Nginx)
http://localhost:8080/nodered/     # Node-RED Editor (via Nginx)
http://localhost:8080/influxdb/    # InfluxDB Admin (via Nginx)
http://localhost:8080/health       # Nginx health endpoint
localhost:1883                     # MQTT Broker (direct)
localhost:9001                     # MQTT WebSocket (direct)
```

### **Production URLs (Path-Based Routing)**
```
http://robert108.mikrus.xyz:20108/grafana     # Grafana Dashboard
http://robert108.mikrus.xyz:20108/nodered     # Node-RED Editor
http://robert108.mikrus.xyz:20108/influxdb    # InfluxDB Admin
http://robert108.mikrus.xyz:20108/            # Default Homepage
robert108.mikrus.xyz:40098                    # MQTT Broker
```

---

## 🛠️ Development Workflow

### **Daily Development**
```powershell
# Start local development
.\scripts\dev-local.ps1

# Make changes to your code
# Test locally

# Stop local services
.\scripts\dev-local.ps1 -Stop

# Check service status
.\scripts\dev-local.ps1 -Status

# View logs
.\scripts\dev-local.ps1 -Logs

# Restart services
.\scripts\dev-local.ps1 -Restart
```

### **Production Deployment**
```powershell
# Prepare deployment package
.\scripts\deploy-production.ps1 -Prepare

# Transfer files to VPS
.\scripts\deploy-production.ps1 -Transfer

# Deploy on VPS
.\scripts\deploy-production.ps1 -Deploy

# Or run full process
.\scripts\deploy-production.ps1 -Full
```

---

## 🔐 Default Credentials

| Service | Username | Password | Notes |
|---------|----------|----------|-------|
| **Grafana** | `admin` | `admin` | Dashboard access |
| **Node-RED** | `admin` | `adminpassword` | Flow editor |
| **InfluxDB** | `admin` | `admin_password_123` | Database admin |
| **MQTT** | `admin` | `admin_password_456` | IoT device access |

---

## 📊 Port Usage Comparison

### **Traditional Approach (Multiple Ports)**
```
Port 40101: Grafana
Port 40102: Node-RED  
Port 40103: InfluxDB
Port 40104: Express API
Port 40105: React App
Port 40098: MQTT
Total: 6 ports used
```

### **Path-Based Routing Approach**
```
Port 20108: Nginx (All web services)
Port 40098: MQTT
Total: 2 ports used
Savings: 4 ports saved! 🎉
```

---

## 🔧 Nginx Reverse Proxy Configuration

The Nginx configuration (`nginx/nginx.conf`) provides:

- **Path-based routing** for all web services
- **WebSocket support** for real-time features
- **CORS headers** for API access
- **Rate limiting** for security
- **Gzip compression** for performance
- **Security headers** for protection
- **Health check endpoint** for monitoring

### **Key Features:**
```nginx
# Grafana routing
location /grafana/ {
    proxy_pass http://grafana_backend/;
    # WebSocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}

# (API routing removed while backend is under development)
```

---

## 🚀 Deployment Scripts

### **Local Development Script (`scripts/dev-local.ps1`)**
- ✅ Checks Docker availability
- ✅ Validates required files
- ✅ Sets up environment variables
- ✅ Starts local services
- ✅ Provides access information
- ✅ Supports stop/start/restart/logs

### **Production Deployment Script (`scripts/deploy-production.ps1`)**
- ✅ Prepares deployment package
- ✅ Transfers files to VPS
- ✅ Deploys services on VPS
- ✅ Provides deployment status
- ✅ Creates deployment documentation

---

## 🔍 Monitoring and Health Checks

### **Health Check Endpoints**
```
http://robert108.mikrus.xyz:20108/health    # Nginx health (production)
http://localhost:8080/health                # Nginx health (local)
http://localhost:8080/grafana/api/health    # Grafana health (via Nginx)
http://localhost:8080/nodered/              # Node-RED health (via Nginx)
http://localhost:8080/influxdb/health       # InfluxDB health (via Nginx)
# Express API health: n/a (under development)
```

### **Docker Health Checks**
All services include health checks:
```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

---

## 🔒 Security Features

### **Firewall Configuration**
- ✅ SSH access on custom port (10108)
- ✅ Web services via Nginx proxy (20108)
- ✅ MQTT broker access (40098)
- ✅ IPv6 support enabled
- ✅ Fail2ban intrusion prevention

### **Security Headers**
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

### **Rate Limiting**
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;
```

---

## 📈 Performance Optimization

### **Docker Optimizations**
- ✅ Multi-stage builds for smaller images
- ✅ Health checks for service monitoring
- ✅ Resource limits for stability
- ✅ Volume mounts for data persistence

### **Nginx Optimizations**
- ✅ Gzip compression for faster loading
- ✅ Connection pooling for efficiency
- ✅ Timeout configurations for reliability
- ✅ Buffer optimizations for performance

### **System Optimizations**
- ✅ Swap memory configuration
- ✅ Kernel parameter tuning
- ✅ File descriptor limits
- ✅ Memory management settings

---

## 🛠️ Troubleshooting

### **Common Issues**

**Local Development:**
```powershell
# Check Docker status
docker ps

# View service logs
.\scripts\dev-local.ps1 -Logs

# Restart services
.\scripts\dev-local.ps1 -Restart
```

**Production Deployment:**
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```

**Network Issues:**
```bash
# Test connectivity
ping robert108.mikrus.xyz

# Check ports
netstat -tlnp

# Test MQTT
mosquitto_pub -h robert108.mikrus.xyz -p 40098 -t test -m "hello"
```

### **Log Locations**
```
/var/log/nginx/access.log    # Nginx access logs
/var/log/nginx/error.log     # Nginx error logs
./mosquitto/log/             # MQTT logs
./influxdb/logs/             # InfluxDB logs
./node-red/logs/             # Node-RED logs
./grafana/logs/              # Grafana logs
```

---

## 🔄 Future Enhancements

### **SSL/HTTPS Implementation**
```nginx
# Future SSL configuration
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
ssl_protocols TLSv1.2 TLSv1.3;
```

### **Additional Services**
- 🔄 Traefik for automatic SSL
- 🔄 Prometheus for metrics
- 🔄 AlertManager for notifications
- 🔄 Backup automation
- 🔄 Monitoring dashboards

### **Scaling Options**
- 🔄 Load balancing
- 🔄 Database clustering
- 🔄 Microservices architecture
- 🔄 Kubernetes deployment

---

## 📚 Documentation

### **VPS Setup Documentation**
- 📄 `docs/prompts/deployment-vps/01-vps-setup-and-preparation.md`
- 📄 `docs/prompts/deployment-vps/02-application-deployment.md`
- 📄 `docs/prompts/deployment-vps/03-data-migration-testing.md`

### **Development Documentation**
- 📄 `docs/prompts/dev-vps-v2/01-vps-setup-and-preparation.md`
- 📄 `docs/prompts/dev-vps-v2/02-docker-compose-and-repo-setup.md`

### **Testing Documentation**
- 📄 `docs/prompts/tests/` - Comprehensive testing guides

---

## 🤝 Contributing

### **Development Guidelines**
1. Use the local development environment for testing
2. Follow the established directory structure
3. Update environment variables as needed
4. Test both local and production configurations
5. Update documentation for any changes

### **Deployment Process**
1. Test changes locally first
2. Update environment files if needed
3. Run deployment script
4. Verify production deployment
5. Update documentation

---

## 📞 Support

### **Getting Help**
- 📖 Check the documentation in `docs/`
- 🔍 Review troubleshooting section
- 📋 Check the deployment scripts
- 🐛 Review service logs

### **Useful Commands**
```bash
# System status
htop
df -h
free -h

# Docker management
docker ps
docker logs [container]
docker-compose logs

# Network troubleshooting
netstat -tlnp
ping [host]
nslookup [domain]
```

---

## 🎉 Benefits of This Setup

### **Port Efficiency**
- ✅ **4 ports saved** on Mikrus VPS
- ✅ **Professional URL structure**
- ✅ **Easy to remember URLs**
- ✅ **Scalable architecture**

### **Development Experience**
- ✅ **Dual environment support**
- ✅ **Easy switching between local/production**
- ✅ **Automated deployment scripts**
- ✅ **Comprehensive documentation**

### **Production Ready**
- ✅ **Security hardened**
- ✅ **Performance optimized**
- ✅ **Monitoring enabled**
- ✅ **SSL ready**

---

**🚀 Ready to deploy your renewable energy IoT monitoring system with professional path-based routing!**
