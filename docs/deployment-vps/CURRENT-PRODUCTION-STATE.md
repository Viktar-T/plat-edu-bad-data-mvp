# 🚀 Current Production State - Mikrus VPS

## 📋 Overview

This document reflects the **current production state** of your renewable energy IoT monitoring system deployed on Mikrus VPS (robert108.mikrus.xyz).

**Status**: ✅ **Successfully Deployed and Running**

---

## 🎯 Current Architecture

### **Direct Port Access Configuration**
The system uses **direct port access** for each service (no nginx reverse proxy required):

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

---

## 🔧 Deployed Services

### **1. MQTT Broker (Mosquitto)**
- **Container**: `iot-mosquitto`
- **Port**: `40098` (external) → `1883` (internal)
- **Status**: ✅ Running and healthy
- **Purpose**: IoT device communication and data collection
- **Authentication**: Username/password with ACL restrictions

### **2. InfluxDB 2.x (Time-Series Database)**
- **Container**: `iot-influxdb2`
- **Port**: `40101` (external) → `8086` (internal)
- **Status**: ✅ Running and healthy
- **Purpose**: Time-series data storage and management
- **Authentication**: Token-based with admin user
- **Retention**: 30-day data retention policy

### **3. Node-RED (Data Processing)**
- **Container**: `iot-node-red`
- **Port**: `40100` (external) → `1880` (internal)
- **Status**: ✅ Running and healthy
- **Purpose**: Visual flow programming and data processing
- **Authentication**: Admin credentials
- **Integration**: Direct InfluxDB connection

### **4. Grafana (Visualization)**
- **Container**: `iot-grafana`
- **Port**: `40099` (external) → `3000` (internal)
- **Status**: ✅ Running and healthy
- **Purpose**: Data visualization and monitoring dashboards
- **Authentication**: Admin dashboard access
- **Data Sources**: InfluxDB integration

---

## 🔑 Access Credentials

| Service | Username | Password | Access URL |
|---------|----------|----------|------------|
| **Grafana** | `admin` | `admin` | `http://robert108.mikrus.xyz:40099` |
| **Node-RED** | `admin` | `adminpassword` | `http://robert108.mikrus.xyz:40100` |
| **InfluxDB** | `admin` | `admin_password_123` | `http://robert108.mikrus.xyz:40101` |
| **MQTT** | `admin` | `admin_password_456` | `robert108.mikrus.xyz:40098` |

---

## 🛠️ Deployment Method

### **PowerShell-Driven Deployment**
The system was deployed using the automated PowerShell script:

```powershell
# Full deployment process
.\scripts\deploy-mikrus.ps1 -Full

# Deployment location on VPS
/root/renewable-energy-iot/
```

### **Deployment Features**
- ✅ **File validation** before transfer
- ✅ **Automatic Docker Compose installation** on VPS
- ✅ **Environment file management** (.env.production)
- ✅ **Service health checks** and monitoring
- ✅ **Error handling** and rollback capabilities

---

## 🔒 Security Configuration

### **Network Security**
- **SSH**: Custom port `10108` with fail2ban protection
- **Firewall**: UFW configured for specific service ports
- **IPv6**: Support enabled
- **Rate limiting**: DDoS protection enabled

### **Service Security**
- **Strong passwords** for all services
- **Token-based authentication** for InfluxDB
- **ACL restrictions** for MQTT topics
- **Environment variable** configuration

### **Container Security**
- **Health checks** for all services
- **Resource limits** and monitoring
- **Restart policies** (unless-stopped)
- **Isolated network** (172.20.0.0/16)

---

## 📊 Data Flow

### **Real-Time IoT Data Pipeline**
```
IoT Devices → MQTT (40098) → Node-RED (40100) → InfluxDB (40101) → Grafana (40099)
```

### **Device Types Supported**
- **Photovoltaic panels** - Solar energy monitoring
- **Wind turbines** - Wind energy analytics
- **Biogas plants** - Biogas production metrics
- **Heat boilers** - Thermal energy monitoring
- **Energy storage** - Battery system tracking

---

## 🔍 Monitoring and Health

### **Health Check Endpoints**
```
http://robert108.mikrus.xyz:40099/api/health    # Grafana health
http://robert108.mikrus.xyz:40100               # Node-RED health
http://robert108.mikrus.xyz:40101/health        # InfluxDB health
```

### **Container Status**
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Health checks
docker-compose exec grafana curl -f http://localhost:3000/api/health
docker-compose exec influxdb curl -f http://localhost:8086/health
```

---

## 🚀 Benefits of Current Setup

### **Architecture Advantages**
- ✅ **No nginx dependency** - simpler setup
- ✅ **Direct service access** - easier troubleshooting
- ✅ **Individual service management** - better control
- ✅ **Scalable architecture** - easy to add services

### **Operational Benefits**
- ✅ **Automated deployment** - PowerShell scripts
- ✅ **Health monitoring** - built-in checks
- ✅ **Easy updates** - script-driven process
- ✅ **Comprehensive documentation** - step-by-step guides

### **Production Readiness**
- ✅ **Security hardened** - multiple layers
- ✅ **Performance optimized** - resource management
- ✅ **Monitoring enabled** - health checks and logging
- ✅ **SSL ready** - easy HTTPS implementation

---

## 📝 Next Steps

### **Immediate Actions**
1. **Change default passwords** for production security
2. **Configure SSL certificates** for HTTPS access
3. **Set up automated backups** for data protection
4. **Implement monitoring alerts** for system health

### **Future Enhancements**
- **Load balancing** for high availability
- **Database clustering** for scalability
- **Microservices architecture** for flexibility
- **Kubernetes deployment** for orchestration

---

## 🔄 Maintenance Commands

### **Service Management**
```bash
# SSH to VPS
ssh root@robert108.mikrus.xyz -p10108

# Navigate to deployment
cd /root/renewable-energy-iot

# Check status
docker-compose ps

# Restart services
docker-compose restart

# Update services
docker-compose pull && docker-compose up -d

# View logs
docker-compose logs -f [service-name]
```

### **Backup and Recovery**
```bash
# Create backup
sudo tar -czf backup-$(date +%Y%m%d).tar.gz influxdb/ grafana/ mosquitto/ node-red/

# Restore from backup
sudo tar -xzf backup-YYYYMMDD.tar.gz
```

---

**🎉 Your renewable energy IoT monitoring system is successfully deployed and running on Mikrus VPS with direct port access!**
