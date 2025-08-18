# 🚀 Renewable Energy IoT Monitoring System - Dual Development/Deployment Setup

> **Professional IoT monitoring system with separate ports and dual environment support**

## 📋 Overview

This project implements a comprehensive renewable energy IoT monitoring system with **dual environment support** and **separate ports** for each service. The system provides direct access to each service without nginx dependency, offering a simpler and more straightforward architecture.

### 🎯 Key Features
- **Dual Environment**: Local development + Production deployment
- **Separate Ports**: Direct access to each service on dedicated ports
- **No Nginx Dependency**: Simpler architecture without reverse proxy
- **Professional URLs**: Clean, direct service URLs
- **SSL Ready**: Easy HTTPS implementation per service
- **Scalable Architecture**: Easy to add new services
- **Complete IoT Pipeline**: MQTT → Node-RED → InfluxDB → Grafana
- **Device Simulation**: Realistic renewable energy device data simulation
- **Comprehensive Dashboards**: 7 specialized Grafana dashboards
- **Data Retention**: 30-day automatic data retention with cleanup

### 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MIKRUS VPS (Production)                  │
├─────────────────────────────────────────────────────────────┤
│  Port 10108: SSH Access                                     │
│  Port 40098: MQTT Broker (IoT Devices)                      │
│  Port 40099: Grafana Dashboard                              │
│  Port 40100: Node-RED Editor                                │
│  Port 40101: InfluxDB Admin                                 │
│  Port 40102: Reserved for future use                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DIRECT SERVICE ACCESS                     │
├─────────────────────────────────────────────────────────────┐
│  Grafana:     http://robert108.mikrus.xyz:40099            │
│  Node-RED:    http://robert108.mikrus.xyz:40100            │
│  InfluxDB:    http://robert108.mikrus.xyz:40101            │
│  MQTT:        robert108.mikrus.xyz:40098                   │
└─────────────────────────────────────────────────────────────┘
```

### 🔄 Data Flow Pipeline

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   MQTT Broker   │───▶│   Node-RED      │───▶│   InfluxDB 2.x  │
│   (Simulated)   │    │   (Mosquitto)   │    │   (Processing)  │    │   (Database)    │
│                 │    │                 │    │                 │    │                 │
│ • Photovoltaic  │    │ • Topic Routing │    │ • Data Validation│    │ • Time-series   │
│ • Wind Turbine  │    │ • Authentication│    │ • Transformation│    │ • Measurements  │
│ • Biogas Plant  │    │ • QoS Management│    │ • Aggregation   │    │ • Retention     │
│ • Heat Boiler   │    │ • Message Retain│    │ • Error Handling│    │ • Flux Queries  │
│ • Energy Storage│    │                 │    │ • Device Sim.   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                                              │
                                                                              ▼
                                                                   ┌─────────────────┐
                                                                   │   Grafana       │
                                                                   │ (Visualization) │
                                                                   │                 │
                                                                   │ • 7 Dashboards  │
                                                                   │ • Alerts        │
                                                                   │ • Analytics     │
                                                                   │ • Reports       │
                                                                   └─────────────────┘
```

---

## 🚀 Quick Start

### **Local Development (Windows)**
```powershell
# Start local development environment
.\scripts\dev-local.ps1

# Access your services:
# - Grafana: http://localhost:3000
# - Node-RED: http://localhost:1880
# - InfluxDB: http://localhost:8086
# - MQTT: localhost:1883
```

### **Production Deployment (Mikrus VPS)**
```bash
# SSH to VPS and manage directly
ssh viktar@robert108.mikrus.xyz -p10108
cd ~/plat-edu-bad-data-mvp

# Update and restart services
git pull --ff-only
cp .env.production .env
sudo docker-compose up -d

# Access your services:
# - Grafana: http://robert108.mikrus.xyz:40099
# - Node-RED: http://robert108.mikrus.xyz:40100
# - InfluxDB: http://robert108.mikrus.xyz:40101
# - MQTT: robert108.mikrus.xyz:40098
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
├── 📁 scripts/
│   ├── 📄 dev-local.ps1               # Local development script
│   └── 📄 deploy-production.ps1       # Production deployment script
├── 📁 mosquitto/                      # MQTT broker configuration
│   ├── 📁 config/                     # Mosquitto configuration
│   ├── 📁 data/                       # MQTT data storage
│   └── 📁 log/                        # MQTT logs
├── 📁 influxdb/                       # InfluxDB configuration
│   ├── 📁 config/                     # InfluxDB configuration
│   ├── 📁 data/                       # Time-series data
│   └── 📁 backups/                    # Database backups
├── 📁 node-red/                       # Node-RED configuration
│   ├── 📁 data/                       # Node-RED data
│   └── 📁 flows/                      # IoT device simulation flows
│       ├── 📄 v2.0-pv-simulation.json
│       ├── 📄 v2.0-wind-turbine-simulation.json
│       ├── 📄 v2.0-biogas-plant-simulation.json
│       ├── 📄 v2.0-heat-boiler-simulation.json
│       └── 📄 v2.0-energy-storage-simulation.json
├── 📁 grafana/                        # Grafana configuration
│   ├── 📁 data/                       # Grafana data
│   ├── 📁 dashboards/                 # 7 specialized dashboards
│   │   ├── 📄 renewable-energy-overview.json
│   │   ├── 📄 photovoltaic-monitoring.json
│   │   ├── 📄 wind-turbine-analytics.json
│   │   ├── 📄 biogas-plant-metrics.json
│   │   ├── 📄 heat-boiler-monitoring.json
│   │   ├── 📄 energy-storage-monitoring.json
│   │   └── 📄 simple.json
│   └── 📁 provisioning/               # Auto-provisioning config
├── 📁 web-app-for-testing/            # Custom web application (Under Development)
│   ├── 📁 backend/                    # Express.js backend (Basic)
│   └── 📁 frontend/                   # React frontend (Basic)
├── 📁 docs/                           # Comprehensive documentation
│   └── 📁 deployment-vps/             # VPS deployment guides
└── 📁 tests/                          # Testing framework
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

# Mikrus custom ports - separate ports for each service
MQTT_PORT=40098                    # MQTT broker
GRAFANA_PORT=40099                 # Grafana dashboard
NODE_RED_PORT=40100                # Node-RED editor
INFLUXDB_PORT=40101                # InfluxDB admin

# Production URLs
GF_SERVER_ROOT_URL=http://robert108.mikrus.xyz:40099
```

---

## 🌐 URL Structure

### **Local Development URLs**
```
http://localhost:3000          # Grafana Dashboard
http://localhost:1880          # Node-RED Editor
http://localhost:8086          # InfluxDB Admin
localhost:1883                 # MQTT Broker
```

### **Production URLs (Separate Ports)**
```
http://robert108.mikrus.xyz:40099     # Grafana Dashboard
http://robert108.mikrus.xyz:40100     # Node-RED Editor
http://robert108.mikrus.xyz:40101     # InfluxDB Admin
robert108.mikrus.xyz:40098            # MQTT Broker
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
```bash
# SSH to VPS and manage directly
ssh viktar@robert108.mikrus.xyz -p10108
cd ~/plat-edu-bad-data-mvp

# Update and restart services
git pull --ff-only
cp .env.production .env
sudo docker-compose up -d

# Check status
sudo docker-compose ps
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

### **Separate Ports Approach (Current)**
```
Port 40098: MQTT Broker
Port 40099: Grafana Dashboard
Port 40100: Node-RED Editor
Port 40101: InfluxDB Admin
Port 40102: Reserved for future use
Total: 4 ports used
Benefits: No nginx dependency, direct access, simpler configuration
```

---

## 🔧 Direct Service Access Configuration

The system now provides direct access to each service without nginx dependency:

- **Direct port access** for each service
- **Simplified architecture** without reverse proxy
- **Easier troubleshooting** with direct service access
- **Individual service management** and monitoring
- **Direct WebSocket support** for real-time features
- **Service-specific security** and configuration

### **Service Ports:**
```
Grafana:     Port 40099 (Dashboard)
Node-RED:    Port 40100 (Flow Editor)
InfluxDB:    Port 40101 (Admin Interface)
MQTT:        Port 40098 (IoT Broker)
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

### **Production Deployment (Direct Git)**
- ✅ Direct Git repository on VPS
- ✅ Manual Docker management
- ✅ Direct service control
- ✅ Git-based updates
- ✅ Environment file management

---

## 🔍 Monitoring and Health Checks

### **Health Check Endpoints**
```
http://robert108.mikrus.xyz:40099/api/health    # Grafana health
http://robert108.mikrus.xyz:40100               # Node-RED health
http://robert108.mikrus.xyz:40101/health        # InfluxDB health
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
- ✅ Grafana dashboard access (40099)
- ✅ Node-RED editor access (40100)
- ✅ InfluxDB admin access (40101)
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

### **Service Optimizations**
- ✅ Individual service monitoring and health checks
- ✅ Service-specific resource allocation
- ✅ Direct connection handling for each service
- ✅ Optimized container configurations

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
sudo docker-compose ps

# View logs
sudo docker-compose logs -f

# Restart services
sudo docker-compose restart

# Update services
git pull --ff-only
cp .env.production .env
sudo docker-compose up -d
```

**Network Issues:**
```bash
# Test connectivity
ping robert108.mikrus.xyz

# Check ports
netstat -tlnp

# Test individual services
curl http://robert108.mikrus.xyz:40099/api/health  # Grafana
curl http://robert108.mikrus.xyz:40100             # Node-RED
curl http://robert108.mikrus.xyz:40101/health      # InfluxDB
mosquitto_pub -h robert108.mikrus.xyz -p 40098 -t test -m "hello"  # MQTT
```

### **Log Locations**
```
./mosquitto/log/             # MQTT logs
./influxdb/logs/             # InfluxDB logs
./node-red/logs/             # Node-RED logs
./grafana/logs/              # Grafana logs
```

---

## 🔄 Future Enhancements

### **SSL/HTTPS Implementation**
```bash
# Future SSL configuration per service
# Each service can have its own SSL certificate
# Grafana: SSL on port 40099
# Node-RED: SSL on port 40100
# InfluxDB: SSL on port 40101
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
- 📄 `docs/deployment-vps/01-vps-setup-and-preparation.md`
- 📄 `docs/deployment-vps/02-docker-compose-and-repo-setup.md`
- 📄 `docs/deployment-vps/03-manage-and-operations.md`
- 📄 `docs/deployment-vps/06-maintanence-vps.md`

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
3. Push changes to Git repository
4. SSH to VPS and update: `git pull --ff-only && cp .env.production .env && sudo docker-compose up -d`
5. Verify production deployment
6. Update documentation

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

### **Architecture Benefits**
- ✅ **No nginx dependency** - simpler setup
- ✅ **Direct service access** - easier troubleshooting
- ✅ **Individual service management** - better control
- ✅ **Scalable architecture** - easy to add services

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

**🚀 Ready to deploy your renewable energy IoT monitoring system with direct service access!**
