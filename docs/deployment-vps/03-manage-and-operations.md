# 🚀 Step 3 – Operations and Management

> **Comprehensive guide for managing and operating your renewable energy IoT monitoring system on Mikrus VPS**

## 📋 Table of Contents

- [📋 Overview](#-overview)
- [🎯 Your Specific Server Details](#-your-specific-server-details)
- [🚀 Step 1 – Project Directory Exploration](#-step-1--project-directory-exploration)
- [🚀 Step 2 – Service Status Verification](#-step-2--service-status-verification)
- [🚀 Step 3 – Log Monitoring and Troubleshooting](#-step-3--log-monitoring-and-troubleshooting)
- [🚀 Step 4 – System Health Monitoring](#-step-4--system-health-monitoring)
- [🚀 Step 5 – Service Access and URLs](#-step-5--service-access-and-urls)
- [🚀 Step 6 – Service Management Operations](#-step-6--service-management-operations)
- [🚀 Step 7 – Performance Monitoring and Optimization](#-step-7--performance-monitoring-and-optimization)
- [🚀 Step 8 – Security Monitoring and Hardening](#-step-8--security-monitoring-and-hardening)
- [🚀 Step 9 – Troubleshooting Common Issues](#-step-9--troubleshooting-common-issues)
- [🚀 Step 10 – Maintenance and Updates](#-step-10--maintenance-and-updates)
- [🚀 Step 11 – Monitoring and Alerting](#-step-11--monitoring-and-alerting)
- [🚀 Step 12 – Custom Web Application Management](#-step-12--custom-web-application-management)
- [🚀 Step 13 – Linux Server Maintenance and Management](#-step-13--linux-server-maintenance-and-management)
- [🚀 Step 14 – Docker Environment Management](#-step-14--docker-environment-management)
- [🚀 Step 15 – Git Repository Management](#-step-15--git-repository-management)
- [✅ Completion Checklist](#-completion-checklist)
- [🎯 Access Your Deployed Services](#-access-your-deployed-services)

## 📋 Overview

This guide provides detailed instructions for managing, monitoring, and operating your renewable energy IoT monitoring system on your Mikrus VPS server. The system includes MQTT broker, Node-RED data processing, InfluxDB time-series database, and Grafana visualization with direct port access.

### 🎯 What You'll Learn
- How to verify all services are running correctly
- How to monitor system health and performance
- How to troubleshoot common issues
- How to manage updates and maintenance
- How to perform backups and recovery

### ✅ Prerequisites
- ✅ VPS setup completed (Step 1)
- ✅ Application deployed and running (Step 2)
- ✅ SSH access to your Mikrus VPS

---

## 🎯 Your Specific Server Details

**Server Information:**
- **Hostname**: `robert108.mikrus.xyz`
- **SSH Port**: `10108`
- **SSH Command**: `ssh viktar@robert108.mikrus.xyz -p10108`
- **Service Ports**: Direct access on dedicated ports
- **Custom IoT Ports**: `40098` (MQTT), `40099` (Grafana), `40100` (Node-RED), `40101` (InfluxDB)
- **Project Directory**: `/home/viktar/plat-edu-bad-data-mvp`

**Connection Details:**
```bash
# Connect to your server (as viktar user)
ssh viktar@robert108.mikrus.xyz -p10108

# Connect to your server (as root user)
ssh root@robert108.mikrus.xyz -p10108

# Or with host key verification disabled (first time only)
ssh -o StrictHostKeyChecking=no viktar@robert108.mikrus.xyz -p10108
```

---

## 🚀 Step 1 – Project Directory Exploration

### **1.1 Navigate to Project Directory**

**🔰 Beginner Level:**
Your project is located in a specific directory on the VPS. Think of this like opening a folder on your computer to access your files.

**🔧 Intermediate Level:**
The project directory contains all the configuration files, data, and application code for your renewable energy IoT monitoring system. Understanding the directory structure helps with troubleshooting and maintenance.

```bash
# SSH to your VPS as viktar user
ssh viktar@robert108.mikrus.xyz -p10108

# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Verify you're in the correct directory
pwd
ls -la

# 2) tree view (hidden files + sizes, 2 levels deep)
tree -ah -L 2
```

### **1.2 Explore Project Structure**


```bash
# Explore main configuration files
ls -la docker-compose.yml .env

# Explore service directories
ls -la mosquitto/
ls -la influxdb/
ls -la node-red/
ls -la grafana/

# Explore custom web application
ls -la web-app-for-testing/

# Explore documentation and scripts
ls -la docs/
ls -la scripts/
ls -la tests/
```

### **1.3 Check Environment Configuration**

**🔰 Beginner Level:**
Environment files contain settings that control how your applications behave. Think of them like the settings menu in an app.

**🔧 Intermediate Level:**
Environment variables control service configurations, authentication, ports, and other runtime parameters. They're essential for proper system operation and security.

```bash
# Check if environment file exists
ls -la .env

# View environment variables (be careful with sensitive data)
head -20 .env

# Check specific service configurations
grep -E "MQTT_|INFLUXDB_|GRAFANA_|NODE_RED_" .env

# Verify port configurations
grep -E "PORT=" .env
```

### **1.4 Verify Service Configurations**

**🔰 Beginner Level:**
Configuration files tell each service how to work. Checking them helps ensure everything is set up correctly.

**🔧 Intermediate Level:**
Service configurations define authentication, data storage, network settings, and performance parameters. Proper configuration is crucial for system reliability and security.

```bash
# Check MQTT configuration
ls -la mosquitto/config/
cat mosquitto/config/mosquitto.conf | head -20

# Check InfluxDB configuration
ls -la influxdb/config/
cat influxdb/config/influxdb.conf | head -20

# Check Node-RED configuration
ls -la node-red/
cat node-red/settings.js | head -20

# Check Grafana configuration
ls -la grafana/
ls -la grafana/dashboards/
```

### **1.5 Check Data Directories**

**🔰 Beginner Level:**
Data directories store your system's information. Think of them like folders where your applications save their files.

**🔧 Intermediate Level:**
Data directories contain persistent storage for databases, logs, configurations, and user data. Understanding their structure helps with backup and troubleshooting.

```bash
# Check data directories
ls -la mosquitto/data/
ls -la influxdb/data/
ls -la node-red/data/
ls -la grafana/data/

# Check log directories
ls -la mosquitto/log/
ls -la influxdb/log/ 2>/dev/null || echo "No InfluxDB logs directory"

# Check backup directories
ls -la influxdb/backups/
```

---

## 🚀 Step 2 – Service Status Verification

### **1.1 Check Container Status**

**🔰 Beginner Level:**
Think of containers like individual applications running on your server. Each container is like a separate program that does a specific job. Checking container status is like checking if all your apps are running properly on your phone.

**🔧 Intermediate Level:**
Docker containers are isolated environments that run your applications. Each container has its own filesystem, network, and process space. The status tells you if the container is running, stopped, restarting, or has crashed.

```bash
# SSH to your VPS as viktar user
ssh viktar@robert108.mikrus.xyz -p10108

# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Check container status (using sudo for Docker commands)
sudo docker-compose ps
```
```

**Expected Output:**
```
Name                    Command               State                    Ports
--------------------------------------------------------------------------------
iot-grafana            /run.sh                 Up       0.0.0.0:40099->3000/tcp
iot-influxdb2          /entrypoint.sh          Up       0.0.0.0:40101->8086/tcp
iot-mosquitto          /docker-entrypoint. ... Up       0.0.0.0:40098->1883/tcp
iot-node-red           /usr/src/node-red/ ... Up       0.0.0.0:40100->1880/tcp
```

**Status Indicators:**
- **Up**: Container is running normally
- **Restarting**: Container is having issues and restarting
- **Exited**: Container has stopped (check logs for errors)
- **healthy**: Container passed health checks
- **unhealthy**: Container failed health checks

### **1.2 Container Management Operations**

**🔰 Beginner Level:**
Just like you can start, stop, and restart apps on your phone, you can control your server applications. These commands let you manage your services without affecting the others.

**🔧 Intermediate Level:**
Docker Compose manages the lifecycle of your containers. You can control individual services or the entire stack. This is useful for maintenance, updates, and troubleshooting.

#### **Start, Stop, and Restart All Services**

```bash
# Start all services (brings up the entire stack)
cp .env.production .env
sudo docker-compose up -d

# Stop all services (RECOMMENDED for daily operations)
# - Keeps containers in memory for fast restart
# - Preserves all data and configurations
# - Maintains network connections
sudo docker-compose stop

# Stop and remove all services (use for major updates or troubleshooting)
# - Completely removes containers
# - Slower restart but cleaner state
# - Use only when needed for updates or troubleshooting
sudo docker-compose down

# Restart all services (fast restart after 'stop')
sudo docker-compose start

# Restart all services (full restart after 'down')
cp .env.production .env
sudo docker-compose up -d
```
```

**🔰 Beginner Level:**
- **`stop`** = Pause your applications (like putting your phone in sleep mode)
- **`down`** = Close your applications completely (like force-closing apps)

**🔧 Intermediate Level:**
- **`stop`** = Graceful shutdown preserving container state and networks
- **`down`** = Complete removal of containers and networks (volumes preserved)
- **`stop`** is preferred for routine operations due to faster restart times
- **`down`** is used for major updates or when containers are in an inconsistent state

#### **Manage Individual Services**

```bash
# Start specific service
cp .env.production .env
sudo docker-compose up -d grafana
sudo docker-compose up -d node-red
sudo docker-compose up -d influxdb
sudo docker-compose up -d mosquitto

# Stop specific service (RECOMMENDED for routine operations)
sudo docker-compose stop grafana
sudo docker-compose stop node-red
sudo docker-compose stop influxdb
sudo docker-compose stop mosquitto

# Restart specific service
sudo docker-compose restart grafana
sudo docker-compose restart node-red
sudo docker-compose restart influxdb
sudo docker-compose restart mosquitto
```
```

**🔰 Beginner Level:**
- Use `stop` for temporary pauses (like putting an app in the background)
- Use `restart` when a service is acting strangely
- Use `up -d` to start a service that was completely stopped

**🔧 Intermediate Level:**
- `stop` preserves container state and is faster for restarts
- `restart` forces a complete restart of the service process
- `up -d` recreates the container if it was removed

#### **Advanced Container Operations**

```bash
# View running containers with detailed information
sudo docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# View container logs in real-time (follow mode)
sudo docker-compose logs -f grafana
sudo docker-compose logs -f node-red
sudo docker-compose logs -f influxdb
sudo docker-compose logs -f mosquitto

# Execute commands inside a running container
sudo docker-compose exec grafana bash
sudo docker-compose exec node-red bash
sudo docker-compose exec influxdb bash

# View container resource usage
sudo docker stats

# Remove stopped containers and unused images
sudo docker system prune -f
```
```

#### **Practical Recommendations for Your IoT System**

**🔰 Beginner Level:**
Here are the most common scenarios you'll encounter and which commands to use:

**🔧 Intermediate Level:**
These recommendations are optimized for your renewable energy IoT monitoring system to ensure data safety and fast recovery times.

**Daily Operations (Use `stop`):**
```bash
# Quick maintenance - pause everything temporarily
sudo docker-compose stop
# ... do your maintenance ...
sudo docker-compose start

# Individual service updates
sudo docker-compose stop grafana
cp .env.production .env
sudo docker-compose up -d grafana
```

**Major Updates (Use `down`):**
```bash
# When pulling new images
sudo docker-compose down
sudo docker-compose pull
cp .env.production .env
sudo docker-compose up -d

# When troubleshooting persistent issues
sudo docker-compose down
cp .env.production .env
sudo docker-compose up -d
```

**Emergency Situations:**
```bash
# If services are stuck or corrupted
sudo docker-compose down
cp .env.production .env
sudo docker-compose up -d

# If you need to reset everything (rare - WARNING: removes volumes too!)
sudo docker-compose down -v  # ⚠️ This will delete your data!
```

**Summary for Your IoT System:**
- **Use `docker-compose stop`** for 90% of your operations
- **Use `docker-compose down`** only for major updates or troubleshooting
- **Use `docker-compose restart`** for individual service issues
- **Always backup before using `down`** to protect your IoT data

### **1.3 Verify Service Health**

**🔰 Beginner Level:**
Health checks are like a doctor's checkup for your applications. They tell you if each service is working properly and responding to requests.

**🔧 Intermediate Level:**
Health checks verify that services are not only running but also functioning correctly. They test internal processes and connectivity to ensure the service is ready to handle requests.

```bash
# Check container health status
sudo docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Check individual service health
sudo docker-compose exec grafana pgrep grafana-server || echo "Grafana not running"
sudo docker-compose exec node-red pgrep node-red || echo "Node-RED not running"
sudo docker-compose exec influxdb pgrep influxd || echo "InfluxDB not running"
sudo docker-compose exec mosquitto pgrep mosquitto || echo "Mosquitto not running"
```
```

### **1.4 Test Service Connectivity**

**🔰 Beginner Level:**
Connectivity tests are like checking if you can reach a website. They verify that your services can communicate with each other and that you can access them from outside.

**🔧 Intermediate Level:**
These tests verify network connectivity between containers and external accessibility. They help identify network configuration issues, firewall problems, and service communication failures.

```bash
# Test internal service communication
sudo docker-compose exec grafana curl -s http://influxdb:8086/health || echo "InfluxDB not reachable"
sudo docker-compose exec node-red curl -s http://influxdb:8086/health || echo "InfluxDB not reachable"

# Test external port accessibility
curl -s http://localhost:40099/api/health || echo "Grafana external access failed"
curl -s http://localhost:40100/ || echo "Node-RED external access failed"
curl -s http://localhost:40101/health || echo "InfluxDB external access failed"
```
```

---

## 🚀 Step 2 – Log Monitoring and Troubleshooting

### **2.1 View Service Logs**

**🔰 Beginner Level:**
Logs are like a diary that your applications write. They record what's happening, any errors, and important events. Reading logs helps you understand what's going wrong when something doesn't work.

**🔧 Intermediate Level:**
Logs provide detailed information about application behavior, errors, performance issues, and system events. They're essential for debugging, monitoring, and understanding system behavior over time.

```bash
# View all service logs (last 100 lines)
sudo docker-compose logs --tail=100

# View specific service logs
sudo docker-compose logs --tail=50 grafana
sudo docker-compose logs --tail=50 node-red
sudo docker-compose logs --tail=50 influxdb
sudo docker-compose logs --tail=50 mosquitto

# Follow logs in real-time (Ctrl+C to stop)
sudo docker-compose logs -f grafana
sudo docker-compose logs -f node-red
sudo docker-compose logs -f influxdb
sudo docker-compose logs -f mosquitto

# View logs with timestamps
sudo docker-compose logs --tail=50 --timestamps grafana
```
```

### **2.2 Common Log Patterns and Solutions**

**🔰 Beginner Level:**
When you see error messages in logs, they often follow common patterns. Learning these patterns helps you quickly identify and fix problems.

**🔧 Intermediate Level:**
Log analysis involves pattern recognition and understanding error hierarchies. Different services have different logging formats and error types, requiring specific troubleshooting approaches.

**Grafana Issues:**
```bash
# Permission denied errors
sudo chown -R 472:472 grafana/data

# Database connection issues
docker-compose logs grafana | grep -i "database\|connection\|error"
```

**Node-RED Issues:**
```bash
# Permission denied errors
sudo chown -R 1000:1000 node-red/data

# MQTT connection issues
docker-compose logs nodered | grep -i "mqtt\|connection\|error"
```

**InfluxDB Issues:**
```bash
# Database initialization issues
docker-compose logs influxdb | grep -i "init\|setup\|error"

# Memory issues
docker-compose logs influxdb | grep -i "memory\|oom\|error"
```

**Nginx Issues:**
```bash
# Configuration errors
docker-compose logs nginx | grep -i "error\|emerg\|alert"

# Upstream connection issues
docker-compose logs nginx | grep -i "upstream\|connection\|refused"
```

**Mosquitto Issues:**
```bash
# Authentication issues
docker-compose logs mosquitto | grep -i "auth\|password\|error"

# Port binding issues
docker-compose logs mosquitto | grep -i "bind\|port\|error"
```

### **2.3 Advanced Log Analysis**

**🔰 Beginner Level:**
Advanced log analysis uses tools to search through large amounts of log data to find specific information, like errors or patterns.

**🔧 Intermediate Level:**
Advanced log analysis involves filtering, parsing, and correlating log data across multiple services and time periods to identify root causes and performance patterns.

```bash
# Search for errors across all services
docker-compose logs | grep -i "error\|exception\|failed\|critical"

# Search for specific patterns
docker-compose logs | grep -i "mqtt\|influxdb\|grafana\|nodered"

# Count log entries by service
docker-compose logs --tail=1000 | grep "^[a-zA-Z]" | cut -d'|' -f1 | sort | uniq -c

# Monitor resource usage in logs
docker-compose logs | grep -i "memory\|cpu\|disk\|load"
```

---

## 🚀 Step 3 – System Health Monitoring

### **3.1 Resource Usage Monitoring**

**🔰 Beginner Level:**
Resource monitoring is like checking your phone's battery, storage, and memory usage. It tells you if your server has enough resources to run all your applications smoothly.

**🔧 Intermediate Level:**
Resource monitoring involves tracking CPU, memory, disk, and network utilization to identify bottlenecks, predict capacity needs, and optimize performance. It helps prevent resource exhaustion and service degradation.

```bash
# Check system resources
htop
df -h
free -h

# Check Docker resource usage
docker stats --no-stream

# Check container resource limits
docker-compose exec grafana cat /proc/1/limits
docker-compose exec nodered cat /proc/1/limits
docker-compose exec influxdb cat /proc/1/limits
```

### **3.2 Network Connectivity Testing**

**🔰 Beginner Level:**
Network testing is like checking if your internet connection works. It verifies that your services can communicate with each other and with the outside world.

**🔧 Intermediate Level:**
Network testing validates connectivity at multiple layers: container-to-container, host-to-container, and external-to-host. It helps identify network configuration issues, DNS problems, and firewall restrictions.

```bash
# Test internal network
docker-compose exec nginx ping -c 3 grafana
docker-compose exec nginx ping -c 3 nodered
docker-compose exec nginx ping -c 3 influxdb
docker-compose exec nginx ping -c 3 mosquitto

# Test external connectivity
ping -c 3 google.com
nslookup robert108.mikrus.xyz

# Check open ports
sudo netstat -tlnp | grep -E "(20108|1883|10108)"
```

### **3.3 Service-Specific Health Checks**

**🔰 Beginner Level:**
Each service has its own way of saying "I'm healthy." These checks verify that each application is working correctly and ready to handle requests.

**🔧 Intermediate Level:**
Service-specific health checks validate application-level functionality, including API endpoints, database connections, and business logic. They provide deeper insights than basic process checks.

**Grafana Health Check:**
```bash
# Check Grafana API health
curl -s http://localhost:20108/grafana/api/health | jq .

# Check Grafana database connection
docker-compose exec grafana grafana-cli --version
```

**Node-RED Health Check:**
```bash
# Check Node-RED admin API
curl -s http://localhost:20108/nodered/admin/auth/token

# Check Node-RED flows status
docker-compose exec nodered node-red admin list
```

**InfluxDB Health Check:**
```bash
# Check InfluxDB health endpoint
curl -s http://localhost:20108/influxdb/health

# Check InfluxDB version
docker-compose exec influxdb influx version
```

**Mosquitto Health Check:**
```bash
# Check Mosquitto version
docker-compose exec mosquitto mosquitto --version

# Test MQTT connectivity
mosquitto_pub -h localhost -p 1883 -t test/health -m "test" -u admin -P admin_password_456
```

**Nginx Health Check:**
```bash
# Check Nginx configuration
docker-compose exec nginx nginx -t

# Check Nginx version
docker-compose exec nginx nginx -v

# Test Nginx upstream connections
docker-compose exec nginx curl -s http://grafana:3000/api/health
```

---

## 🚀 Step 4 – Service Access and URLs

### **4.1 Web Service Access**

**🔰 Beginner Level:**
Your services are accessible through web browsers using specific URLs. Think of these like bookmarks to different applications on your server.

**🔧 Intermediate Level:**
The URL structure uses Nginx reverse proxy with path-based routing, which allows multiple services to share a single port while maintaining separate access paths. This is more efficient than using separate ports for each service.

**Your Mikrus VPS uses direct port access:**

| Service | Internal Port | External URL | Default Credentials |
|---------|---------------|--------------|-------------------|
| **Grafana** | 3000 | `http://robert108.mikrus.xyz:40099/` | `admin` / `admin` |
| **Node-RED** | 1880 | `http://robert108.mikrus.xyz:40100/` | `admin` / `adminpassword` |
| **InfluxDB** | 8086 | `http://robert108.mikrus.xyz:40101/` | `admin` / `admin_password_123` |

### **4.2 IoT Service Access**

**🔰 Beginner Level:**
IoT services are for devices and applications that need to send and receive data. MQTT is like a messaging system for IoT devices.

**🔧 Intermediate Level:**
MQTT (Message Queuing Telemetry Transport) is a lightweight messaging protocol designed for IoT devices with limited bandwidth and processing power. It uses a publish/subscribe model for efficient data transmission.

| Service | Port | Access Method | Credentials |
|---------|------|---------------|-------------|
| **MQTT Broker** | 40098 | `robert108.mikrus.xyz:40098` | `admin` / `admin_password_456` |
| **MQTT WebSocket** | 9001 | `robert108.mikrus.xyz:9001` | `admin` / `admin_password_456` |

### **4.3 Service Testing Commands**

**🔰 Beginner Level:**
These commands test if your services are working properly. They're like checking if a light switch works by flipping it on and off.

**🔧 Intermediate Level:**
Service testing validates both connectivity and functionality. It ensures that services are not only reachable but also responding correctly to requests and maintaining proper authentication.

**Test Grafana Access:**
```bash
# Test Grafana homepage
curl -s http://robert108.mikrus.xyz:40099/ | head -20

# Test Grafana API
curl -s http://robert108.mikrus.xyz:40099/api/health
```

**Test Node-RED Access:**
```bash
# Test Node-RED homepage
curl -s http://robert108.mikrus.xyz:40100/ | head -20

# Test Node-RED admin API
curl -s http://robert108.mikrus.xyz:40100/admin/auth/token
```

**Test InfluxDB Access:**
```bash
# Test InfluxDB health
curl -s http://robert108.mikrus.xyz:40101/health

# Test InfluxDB API
curl -s http://robert108.mikrus.xyz:40101/api/v2/orgs
```

**Test MQTT Access:**
```bash
# Test MQTT connectivity
mosquitto_pub -h robert108.mikrus.xyz -p 40098 -t test/health -m "test" -u admin -P admin_password_456

# Test MQTT subscription
mosquitto_sub -h robert108.mikrus.xyz -p 40098 -t test/health -u admin -P admin_password_456 -C 1
```

---

## 🚀 Step 5 – Service Management Operations

### **5.1 Start, Stop, and Restart Services**

**🔰 Beginner Level:**
These are the basic controls for your applications, like the power button on your computer. You can start, stop, or restart services as needed.

**🔧 Intermediate Level:**
Service lifecycle management involves understanding dependencies, startup order, and graceful shutdown procedures. Proper service management ensures data integrity and prevents corruption.

```bash
# Start all services
cp .env.production .env
sudo docker-compose up -d

# Stop all services
sudo docker-compose down

# Restart all services
sudo docker-compose restart

# Start specific service
cp .env.production .env
sudo docker-compose up -d grafana
sudo docker-compose up -d node-red
sudo docker-compose up -d influxdb
sudo docker-compose up -d mosquitto

# Stop specific service
sudo docker-compose stop grafana
sudo docker-compose stop node-red
sudo docker-compose stop influxdb
sudo docker-compose stop mosquitto

# Restart specific service
sudo docker-compose restart grafana
sudo docker-compose restart node-red
sudo docker-compose restart influxdb
sudo docker-compose restart mosquitto
```
```

### **5.2 Service Updates and Maintenance**

**🔰 Beginner Level:**
Updates keep your applications secure and add new features. Think of it like updating apps on your phone to get the latest version.

**🔧 Intermediate Level:**
Service updates involve version management, dependency resolution, and rollback strategies. Proper update procedures minimize downtime and ensure data consistency.

```bash
# Pull latest images
sudo docker-compose pull

# Rebuild and restart services
cp .env.production .env
sudo docker-compose up -d --build

# Update specific service
sudo docker-compose pull grafana
cp .env.production .env
sudo docker-compose up -d --no-deps grafana

# Check for image updates
sudo docker-compose images

# Clean up unused images
sudo docker image prune -f
```
```

### **5.3 Data Backup and Recovery**

**🔰 Beginner Level:**
Backups are like saving your work frequently. They create copies of your important data so you can restore it if something goes wrong.

**🔧 Intermediate Level:**
Backup strategies involve data consistency, incremental backups, and recovery time objectives. Proper backup procedures ensure business continuity and data protection.

```bash
# Create backup of all data
sudo tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  influxdb/data/ \
  grafana/data/ \
  node-red/data/ \
  mosquitto/data/

# List backups
ls -lh backup-*.tar.gz

# Restore from backup (if needed)
sudo tar -xzf backup-20240101-120000.tar.gz -C /home/viktar/plat-edu-bad-data-mvp/

# Backup specific service data
sudo tar -czf influxdb-backup-$(date +%Y%m%d).tar.gz influxdb/data/
sudo tar -czf grafana-backup-$(date +%Y%m%d).tar.gz grafana/data/
```
```

### **5.4 Configuration Management**

**🔰 Beginner Level:**
Configuration files are like settings for your applications. They control how your services behave and connect to each other.

**🔧 Intermediate Level:**
Configuration management involves version control, environment-specific settings, and configuration validation. It ensures consistency across deployments and environments.

```bash
# View current configuration
sudo docker-compose config

# Validate configuration
sudo docker-compose config --quiet

# Export configuration
sudo docker-compose config > docker-compose-exported.yml

# Edit configuration files
sudo nano docker-compose.yml
sudo nano mosquitto/config/mosquitto.conf
sudo nano influxdb/config/influxdb.conf
sudo nano node-red/settings.js
```
```

---

## 🚀 Step 6 – Performance Monitoring and Optimization

### **6.1 System Performance Monitoring**

**🔰 Beginner Level:**
Performance monitoring is like checking your car's dashboard for speed, fuel level, and engine temperature. It tells you how well your server is performing and if there are any problems.

**🔧 Intermediate Level:**
Performance monitoring involves tracking key metrics, identifying bottlenecks, and capacity planning. It helps optimize resource utilization and prevent performance degradation.

```bash
# Monitor system resources
htop
iotop
nethogs

# Monitor Docker resources
sudo docker stats

# Monitor disk usage
df -h
du -sh /home/viktar/plat-edu-bad-data-mvp/*/

# Monitor memory usage
free -h
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"
```
```

### **6.2 Service Performance Monitoring**

**🔰 Beginner Level:**
Service performance monitoring checks how fast your applications respond to requests. It's like timing how long it takes for a webpage to load.

**🔧 Intermediate Level:**
Service performance monitoring involves response time analysis, throughput measurement, and error rate tracking. It helps identify performance bottlenecks and optimize application behavior.

```bash
# Monitor container resource usage
sudo docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Check container logs for performance issues
sudo docker-compose logs | grep -i "slow\|timeout\|memory\|cpu"

# Monitor service response times
time curl -s http://robert108.mikrus.xyz:40099/api/health
time curl -s http://robert108.mikrus.xyz:40100/
time curl -s http://robert108.mikrus.xyz:40101/health
```

### **6.3 Performance Optimization**

**🔰 Beginner Level:**
Performance optimization is like tuning your car for better fuel efficiency and speed. It makes your applications run faster and use fewer resources.

**🔧 Intermediate Level:**
Performance optimization involves resource allocation, caching strategies, and code-level optimizations. It requires understanding the relationship between system resources and application performance.

```bash
# Optimize Docker daemon
sudo nano /etc/docker/daemon.json

# Add these optimizations:
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  }
}

# Restart Docker daemon
sudo systemctl restart docker
```

---

## 🚀 Step 7 – Security Monitoring and Hardening

### **7.1 Security Status Check**

**🔰 Beginner Level:**
Security checks are like checking if your doors and windows are locked. They verify that your server is protected from unauthorized access.

**🔧 Intermediate Level:**
Security monitoring involves threat detection, vulnerability assessment, and access control validation. It requires understanding attack vectors and security best practices.

```bash
# Check firewall status
sudo ufw status numbered

# Check fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Check SSH access logs
sudo tail -f /var/log/auth.log | grep -i "sshd"

# Check Docker security
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --severity HIGH,CRITICAL grafana/grafana:latest
```

### **7.2 Security Hardening**

**🔰 Beginner Level:**
Security hardening is like adding extra locks and alarms to your house. It makes your server more secure by changing default settings and adding protection.

**🔧 Intermediate Level:**
Security hardening involves implementing defense-in-depth strategies, reducing attack surfaces, and following security frameworks. It requires understanding security principles and threat modeling.

```bash
# Update default passwords
# Grafana: Change admin password via web interface
# Node-RED: Change admin password via web interface
# InfluxDB: Update token in environment variables
# Mosquitto: Update password in mosquitto/config/passwd

# Secure MQTT configuration
sudo nano mosquitto/config/mosquitto.conf

# Add security settings:
allow_anonymous false
password_file /mosquitto/config/passwd
acl_file /mosquitto/config/acl

# Create MQTT ACL file
sudo nano mosquitto/config/acl

# Add access control:
user admin
topic readwrite devices/#
topic read $SYS/#

# Restart Mosquitto
docker-compose restart mosquitto
```

### **7.3 Security Monitoring**

**🔰 Beginner Level:**
Security monitoring is like having security cameras that watch for suspicious activity. It alerts you when someone tries to break into your system.

**🔧 Intermediate Level:**
Security monitoring involves log analysis, intrusion detection, and incident response. It requires understanding attack patterns and security event correlation.

```bash
# Monitor failed login attempts
sudo tail -f /var/log/auth.log | grep -i "failed\|invalid"

# Monitor Docker security events
docker events --filter 'type=container' --filter 'event=die'

# Monitor network connections
sudo netstat -tuln | grep -E "(20108|1883|10108)"

# Check for suspicious processes
ps aux | grep -v grep | grep -E "(crypto\|miner\|scan)"
```

---

## 🚀 Step 8 – Troubleshooting Common Issues

### **8.1 Service Startup Issues**

**🔰 Beginner Level:**
When services won't start, it's like when your car won't start. You need to check what's wrong and fix it before you can use it.

**🔧 Intermediate Level:**
Service startup issues can be caused by configuration errors, resource constraints, dependency failures, or permission problems. Systematic troubleshooting involves checking logs, configurations, and system resources.

**Container Won't Start:**
```bash
# Check container logs
docker-compose logs <service_name>

# Check container configuration
docker-compose config

# Check resource availability
free -h
df -h

# Check port conflicts
sudo netstat -tlnp | grep -E "(20108|1883|3000|1880|8086)"
```

**Permission Issues:**
```bash
# Fix Grafana permissions
sudo chown -R 472:472 grafana/data/

# Fix Node-RED permissions
sudo chown -R 1000:1000 node-red/data/

# Fix InfluxDB permissions
sudo chown -R 472:472 influxdb/data/

# Fix Mosquitto permissions
sudo chown -R 1883:1883 mosquitto/data/
```

### **8.2 Network Connectivity Issues**

**🔰 Beginner Level:**
Network issues are like when your internet connection doesn't work. Services can't communicate with each other or with the outside world.

**🔧 Intermediate Level:**
Network issues can involve DNS resolution, firewall rules, routing problems, or service discovery failures. Troubleshooting requires understanding network layers and container networking.

**Service Not Accessible:**
```bash
# Check firewall rules
sudo ufw status numbered

# Check service is running
docker-compose ps

# Check service logs
docker-compose logs <service_name>

# Test internal connectivity
docker-compose exec nginx curl -s http://grafana:3000/api/health

# Test external connectivity
curl -s http://localhost:20108/grafana/api/health
```

**MQTT Connection Issues:**
```bash
# Check Mosquitto is running
docker-compose ps mosquitto

# Check Mosquitto logs
docker-compose logs mosquitto

# Test MQTT connectivity
mosquitto_pub -h localhost -p 1883 -t test/health -m "test" -u admin -P admin_password_456

# Check MQTT port
sudo netstat -tlnp | grep 1883
```

### **8.3 Data and Configuration Issues**

**🔰 Beginner Level:**
Data and configuration issues are like when your settings get corrupted or your files get damaged. The application can't work properly because of bad data or settings.

**🔧 Intermediate Level:**
Data issues can involve corruption, permission problems, or storage failures. Configuration issues can stem from syntax errors, validation failures, or environment-specific problems.

**Database Issues:**
```bash
# Check InfluxDB logs
docker-compose logs influxdb

# Test InfluxDB connectivity
curl -s http://localhost:20108/influxdb/health

# Check InfluxDB data directory
ls -la influxdb/data/

# Restart InfluxDB
docker-compose restart influxdb
```

**Configuration Issues:**
```bash
# Validate Docker Compose configuration
docker-compose config

# Check Nginx configuration
docker-compose exec nginx nginx -t

# Check service configurations
docker-compose exec grafana cat /etc/grafana/grafana.ini | head -20
docker-compose exec nodered cat /data/settings.js | head -20
docker-compose exec mosquitto cat /mosquitto/config/mosquitto.conf | head -20
```

### **8.4 Performance Issues**

**🔰 Beginner Level:**
Performance issues are like when your computer runs slowly. Applications take too long to respond or use too many resources.

**🔧 Intermediate Level:**
Performance issues can be caused by resource exhaustion, inefficient algorithms, network bottlenecks, or configuration problems. Diagnosis requires understanding resource utilization patterns and application behavior.

**High Resource Usage:**
```bash
# Check system resources
htop
free -h
df -h

# Check container resource usage
docker stats

# Check for resource limits
docker-compose exec grafana cat /proc/1/limits
docker-compose exec nodered cat /proc/1/limits
docker-compose exec influxdb cat /proc/1/limits

# Optimize resource usage
docker-compose down
docker system prune -f
docker-compose up -d
```

**Slow Response Times:**
```bash
# Check service response times
time curl -s http://robert108.mikrus.xyz:20108/grafana/api/health
time curl -s http://robert108.mikrus.xyz:20108/nodered/
time curl -s http://robert108.mikrus.xyz:20108/influxdb/health

# Check network latency
ping -c 10 robert108.mikrus.xyz

# Check service logs for performance issues
docker-compose logs | grep -i "slow\|timeout\|error"
```

---

## 🚀 Step 9 – Maintenance and Updates

### **9.1 Regular Maintenance Tasks**

**🔰 Beginner Level:**
Regular maintenance is like taking care of your car - you need to check it regularly, clean it, and keep it updated to keep it running well.

**🔧 Intermediate Level:**
Maintenance involves proactive monitoring, preventive measures, and systematic updates. It requires understanding system lifecycle management and change control procedures.

**Daily Tasks:**
```bash
# Check service status
sudo docker-compose ps

# Check system resources
htop
df -h
free -h

# Check recent logs
sudo docker-compose logs --tail=50
```

**Weekly Tasks:**
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean up Docker resources (safe cleanup)
sudo docker system prune -f
sudo docker image prune -a -f

# Check for image updates
sudo docker-compose pull

# Create backup
sudo tar -czf backup-$(date +%Y%m%d).tar.gz \
  influxdb/data/ grafana/data/ node-red/data/ mosquitto/data/

# Verify Docker environment is clean
sudo docker ps -a       # Should show only running containers
sudo docker images      # Should be minimal
sudo docker volume ls   # Should show only used volumes
```

**Monthly Tasks:**
```bash
# Review and rotate logs
sudo logrotate -f /etc/logrotate.conf

# Check security updates
sudo apt list --upgradable

# Review and update passwords
# Change default passwords for all services

# Performance review
sudo docker stats --no-stream
df -h
free -h

# Deep Docker cleanup (optional - removes unused volumes)
sudo docker volume prune -f
sudo docker network prune -f
```

### **9.2 Update Procedures**

**🔰 Beginner Level:**
Updates are like installing the latest version of an app. They add new features and fix security problems, but you need to be careful to avoid breaking things.

**🔧 Intermediate Level:**
Update procedures involve change management, testing strategies, and rollback planning. They require understanding dependency relationships and potential impact on system stability.

**Safe Update Process:**
```bash
# 1. Create backup
sudo tar -czf backup-before-update-$(date +%Y%m%d).tar.gz \
  influxdb/data/ grafana/data/ node-red/data/ mosquitto/data/

# 2. Stop services
sudo docker-compose down

# 3. Pull latest images
sudo docker-compose pull

# 4. Start services
cp .env.production .env
sudo docker-compose up -d

# 5. Verify services
sudo docker-compose ps
sudo docker-compose logs --tail=50

# 6. Test functionality
curl -s http://robert108.mikrus.xyz:40099/api/health
curl -s http://robert108.mikrus.xyz:40100/
curl -s http://robert108.mikrus.xyz:40101/health
```

**Rollback Procedure:**
```bash
# If update fails, rollback to previous version
sudo docker-compose down

# Restore from backup
sudo tar -xzf backup-before-update-20240101.tar.gz -C /home/viktar/plat-edu-bad-data-mvp/

# Restart with previous configuration
cp .env.production .env
sudo docker-compose up -d

# Verify rollback
docker-compose ps
docker-compose logs --tail=50
```

---

## 🚀 Step 10 – Monitoring and Alerting

### **10.1 Basic Monitoring Setup**

**🔰 Beginner Level:**
Monitoring is like having a dashboard that shows you the status of all your applications. It automatically checks if everything is working and alerts you if something goes wrong.

**🔧 Intermediate Level:**
Monitoring involves metric collection, threshold management, and alert correlation. It requires understanding system behavior patterns and establishing appropriate alerting rules.

**System Monitoring:**
```bash
# Create monitoring script
sudo nano /root/monitor.sh

# Add monitoring content:
#!/bin/bash
echo "=== System Status $(date) ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
echo "Memory Usage:"
free -h | grep Mem | awk '{print $3"/"$2}'
echo "Disk Usage:"
df -h / | tail -1 | awk '{print $5}'
echo "Docker Status:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}"
echo "Service Health:"
curl -s http://localhost:20108/grafana/api/health | jq .status 2>/dev/null || echo "Grafana: ERROR"
curl -s http://localhost:20108/nodered/ | grep -q "Node-RED" && echo "Node-RED: OK" || echo "Node-RED: ERROR"
curl -s http://localhost:20108/influxdb/health | jq .status 2>/dev/null || echo "InfluxDB: ERROR"
```

**Make script executable:**
```bash
chmod +x /root/monitor.sh
```

**Run monitoring:**
```bash
# Run manual check
/root/monitor.sh

# Set up cron job for regular monitoring
crontab -e

# Add this line for hourly monitoring:
0 * * * * /root/monitor.sh >> /var/log/monitoring.log 2>&1
```

### **10.2 Log Monitoring**

**🔰 Beginner Level:**
Log monitoring automatically checks your application logs for problems. It's like having someone read through all the logs and tell you when something important happens.

**🔧 Intermediate Level:**
Log monitoring involves log aggregation, pattern recognition, and event correlation. It requires understanding log formats, error patterns, and system behavior.

**Set up log monitoring:**
```bash
# Create log monitoring script
sudo nano /root/log-monitor.sh

# Add content:
#!/bin/bash
echo "=== Log Analysis $(date) ==="
echo "Recent Errors:"
docker-compose logs --tail=100 | grep -i "error\|exception\|failed" | tail -10
echo "Service Restarts:"
docker-compose logs --tail=100 | grep -i "restart\|exit" | tail -10
echo "Authentication Failures:"
sudo tail -50 /var/log/auth.log | grep -i "failed\|invalid" | tail -10
```

**Make executable and schedule:**
```bash
chmod +x /root/log-monitor.sh
crontab -e

# Add for daily log analysis:
0 6 * * * /root/log-monitor.sh >> /var/log/log-analysis.log 2>&1
```

---

## ✅ Completion Checklist

### **Operations Verification**
- [ ] ✅ All containers are running (Up status)
- [ ] ✅ All services are accessible via web URLs
- [ ] ✅ MQTT broker is accepting connections
- [ ] ✅ Nginx reverse proxy is working correctly
- [ ] ✅ All default credentials are working

### **Health Monitoring**
- [ ] ✅ System resources are within acceptable limits
- [ ] ✅ Service logs show no critical errors
- [ ] ✅ Network connectivity is stable
- [ ] ✅ Performance is acceptable

### **Security Verification**
- [ ] ✅ Firewall is properly configured
- [ ] ✅ Fail2ban is monitoring SSH access
- [ ] ✅ Default passwords have been changed
- [ ] ✅ Services are not exposed unnecessarily

### **Maintenance Setup**
- [ ] ✅ Backup procedures are in place
- [ ] ✅ Monitoring scripts are configured
- [ ] ✅ Update procedures are documented
- [ ] ✅ Troubleshooting guides are available

---

## 🎯 Access Your Deployed Services

**🌐 Web Services (Direct Port Access):**
- **Grafana Dashboard**: `http://robert108.mikrus.xyz:40099/`
- **Node-RED Editor**: `http://robert108.mikrus.xyz:40100/`
- **InfluxDB Admin**: `http://robert108.mikrus.xyz:40101/`

**📡 IoT Services:**
- **MQTT Broker**: `robert108.mikrus.xyz:40098`
- **MQTT WebSocket**: `robert108.mikrus.xyz:9001`

**🖥️ Custom Web Application:**
- **Frontend**: `http://robert108.mikrus.xyz:3000/` (if deployed)
- **Backend API**: `http://robert108.mikrus.xyz:3001/` (if deployed)
- **Location**: `/home/viktar/plat-edu-bad-data-mvp/web-app-for-testing/`

**🔑 Default Credentials:**
- **Grafana**: `admin` / `admin`
- **Node-RED**: `admin` / `adminpassword`
- **InfluxDB**: `admin` / `admin_password_123`
- **MQTT**: `admin` / `admin_password_456`

**⚠️ Security Note:** Change these default passwords immediately after deployment!

---

## 🚀 Step 11 – Custom Web Application Management

### **11.1 Explore Custom Web Application**

**🔰 Beginner Level:**
Your project includes a custom web application for specialized analytics and user interfaces. This is separate from the main IoT monitoring system.

**🔧 Intermediate Level:**
The custom web application consists of a React frontend and Express backend, providing specialized data visualization and analytics capabilities beyond what Grafana offers.

```bash
# Navigate to web application directory
cd ~/plat-edu-bad-data-mvp/web-app-for-testing/

# Explore the structure
ls -la

# Check frontend and backend directories
ls -la frontend/
ls -la backend/
```

**Expected Structure:**
```bash
web-app-for-testing/
├── frontend/                 # React application
│   ├── package.json
│   ├── server.js
│   └── src/
├── backend/                  # Express.js server
│   ├── package.json
│   └── server.js
├── README.md
└── diagrams-visualization-grafana-custom-react.md
```

### **11.2 Manage Custom Web Application**

**🔰 Beginner Level:**
The custom web application can be started and stopped independently of the main IoT system. This allows you to run specialized analytics when needed.

**🔧 Intermediate Level:**
The custom application provides additional data processing capabilities and specialized visualizations that complement the main Grafana dashboards.

```bash
# Navigate to web application
cd ~/plat-edu-bad-data-mvp/web-app-for-testing/

# Check if Node.js is available
node --version
npm --version

# Install dependencies (if needed)
cd frontend && npm install
cd ../backend && npm install

# Start backend server (Express API)
cd backend
npm start
# or
node server.js

# Start frontend server (React app)
cd frontend
npm start
# or
node server.js
```

### **11.3 Custom Application Configuration**

**🔰 Beginner Level:**
The custom application has its own configuration files that control how it connects to your IoT data and displays information.

**🔧 Intermediate Level:**
Configuration includes API endpoints, database connections, and visualization settings specific to the custom application's requirements.

```bash
# Check backend configuration
cat backend/server.js | head -30

# Check frontend configuration
cat frontend/server.js | head -30

# Check package.json files for dependencies
cat frontend/package.json
cat backend/package.json
```

### **11.4 Custom Application Monitoring**

**🔰 Beginner Level:**
Monitor the custom application to ensure it's running properly and responding to requests.

**🔧 Intermediate Level:**
Custom application monitoring involves checking process status, log files, and API responsiveness.

```bash
# Check if custom application processes are running
ps aux | grep -E "(node|npm)" | grep -v grep

# Check custom application logs
# (Logs will be in the terminal where you started the applications)

# Test custom application endpoints
curl -s http://localhost:3001/api/health || echo "Backend not running"
curl -s http://localhost:3000/ | head -20 || echo "Frontend not running"
```

---

## 🚀 Step 13 – Linux Server Maintenance and Management

### **13.1 System Information and Status**

**🔰 Beginner Level:**
Understanding your server's basic information helps you know what you're working with and identify potential issues.

**🔧 Intermediate Level:**
System information provides insights into hardware capabilities, resource utilization, and system health. This information is crucial for capacity planning and troubleshooting.

```bash
# SSH to your VPS
ssh viktar@robert108.mikrus.xyz -p10108

# Check system information
uname -a
cat /etc/os-release
lsb_release -a

# Check system resources
free -h
df -h
top -bn1

# Check system uptime and load
uptime
w
who

# Check CPU information
lscpu
cat /proc/cpuinfo | grep "model name" | head -1

# Check memory information
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"
```

### **13.2 System Updates and Package Management**

**🔰 Beginner Level:**
Keeping your system updated is like updating your phone - it gets new features and security fixes.

**🔧 Intermediate Level:**
Regular system updates ensure security patches, bug fixes, and performance improvements. Proper update management prevents system vulnerabilities and compatibility issues.

```bash
# Update package lists
sudo apt update

# Check for available updates
sudo apt list --upgradable

# Install security updates only (recommended for production)
sudo apt upgrade -y

# Install all updates (use with caution)
sudo apt full-upgrade -y

# Clean up package cache
sudo apt autoremove -y
sudo apt autoclean

# Check for broken packages
sudo apt check

# Update specific packages
sudo apt install --only-upgrade package-name
```

### **13.3 System Monitoring and Performance**

**🔰 Beginner Level:**
System monitoring is like checking your car's dashboard - it tells you if everything is working properly.

**🔧 Intermediate Level:**
System monitoring involves tracking resource utilization, identifying bottlenecks, and predicting capacity needs. It helps prevent performance degradation and system failures.

```bash
# Real-time system monitoring
htop
iotop
nethogs

# Check disk usage
df -h
du -sh /home/viktar/plat-edu-bad-data-mvp/*/

# Check memory usage
free -h
cat /proc/meminfo

# Check CPU usage
top -bn1 | grep "Cpu(s)"
mpstat 1 5

# Check network usage
ss -tuln
netstat -i
ip addr show

# Check system load
cat /proc/loadavg
uptime
```

### **13.4 Process Management**

**🔰 Beginner Level:**
Processes are like programs running on your computer. Managing them helps you control what's running and fix problems.

**🔧 Intermediate Level:**
Process management involves monitoring running processes, identifying resource-intensive tasks, and managing system services. It's essential for system stability and performance optimization.

```bash
# View running processes
ps aux
ps aux | grep -E "(docker|node|nginx|mosquitto)"

# Check specific process
ps aux | grep process-name

# Kill a process (use with caution)
sudo kill -9 process-id

# Check system services
sudo systemctl list-units --type=service --state=running

# Check service status
sudo systemctl status service-name

# Start/stop/restart services
sudo systemctl start service-name
sudo systemctl stop service-name
sudo systemctl restart service-name
```

### **13.5 Log Management and Analysis**

**🔰 Beginner Level:**
Logs are like a diary that your system writes. Reading them helps you understand what's happening and fix problems.

**🔧 Intermediate Level:**
Log analysis involves monitoring system events, identifying patterns, and troubleshooting issues. Proper log management is crucial for security monitoring and system maintenance.

```bash
# View system logs
sudo journalctl -f
sudo journalctl --since "1 hour ago"
sudo journalctl -u service-name

# Check specific log files
sudo tail -f /var/log/syslog
sudo tail -f /var/log/auth.log
sudo tail -f /var/log/dmesg

# Search logs for specific patterns
sudo journalctl | grep -i "error\|warning\|failed"
sudo grep -i "error\|warning\|failed" /var/log/syslog

# Check log file sizes
sudo du -sh /var/log/*
ls -lh /var/log/

# Rotate logs (if needed)
sudo logrotate -f /etc/logrotate.conf
```

### **13.6 Network Configuration and Troubleshooting**

**🔰 Beginner Level:**
Network configuration controls how your server connects to the internet and other services.

**🔧 Intermediate Level:**
Network troubleshooting involves diagnosing connectivity issues, checking firewall rules, and verifying network configurations. It's essential for service accessibility and security.

```bash
# Check network interfaces
ip addr show
ifconfig -a

# Check network connectivity
ping -c 4 google.com
ping -c 4 robert108.mikrus.xyz

# Check DNS resolution
nslookup google.com
dig google.com

# Check open ports
sudo netstat -tlnp
sudo ss -tuln

# Check firewall status
sudo ufw status
sudo iptables -L

# Test specific ports
telnet robert108.mikrus.xyz 40098
telnet robert108.mikrus.xyz 40099
telnet robert108.mikrus.xyz 40100
telnet robert108.mikrus.xyz 40101
```

### **13.7 Security Management**

**🔰 Beginner Level:**
Security management protects your server from unauthorized access and attacks.

**🔧 Intermediate Level:**
Security management involves monitoring access attempts, managing user accounts, and implementing security best practices. It's crucial for protecting sensitive data and maintaining system integrity.

```bash
# Check failed login attempts
sudo tail -f /var/log/auth.log | grep -i "failed\|invalid"

# Check current users
who
w

# Check user accounts
cat /etc/passwd | grep -E "(viktar|root)"
sudo id viktar

# Check SSH configuration
sudo cat /etc/ssh/sshd_config | grep -E "(Port|PermitRootLogin|PasswordAuthentication)"

# Check fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Check for suspicious processes
ps aux | grep -v grep | grep -E "(crypto\|miner\|scan\|backdoor)"

# Check file permissions
ls -la /home/viktar/plat-edu-bad-data-mvp/
```

### **13.8 Backup and Recovery**

**🔰 Beginner Level:**
Backups are like insurance for your data - they protect you from losing important information.

**🔧 Intermediate Level:**
Backup strategies involve data consistency, incremental backups, and recovery time objectives. Proper backup procedures ensure business continuity and data protection.

```bash
# Create system backup
sudo tar -czf system-backup-$(date +%Y%m%d).tar.gz /home/viktar/plat-edu-bad-data-mvp/

# Create configuration backup
sudo tar -czf config-backup-$(date +%Y%m%d).tar.gz /etc/

# List backups
ls -lh *backup*.tar.gz

# Check backup integrity
tar -tzf backup-file.tar.gz | head -10

# Create automated backup script
sudo nano /home/viktar/backup-script.sh
```

**Backup Script Example:**
```bash
#!/bin/bash
# Automated backup script for renewable energy IoT system

BACKUP_DIR="/home/viktar/backups"
PROJECT_DIR="/home/viktar/plat-edu-bad-data-mvp"
DATE=$(date +%Y%m%d-%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Create project backup
tar -czf $BACKUP_DIR/project-backup-$DATE.tar.gz $PROJECT_DIR/

# Create system configuration backup
sudo tar -czf $BACKUP_DIR/config-backup-$DATE.tar.gz /etc/

# Remove old backups (keep last 7 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

---

## 🚀 Step 14 – Docker Environment Management

### **14.1 Docker Installation and Configuration**

**🔰 Beginner Level:**
Docker is like a container system that packages your applications with everything they need to run. It makes deployment easier and more reliable.

**🔧 Intermediate Level:**
Docker provides containerization technology that isolates applications and their dependencies. Proper Docker management ensures consistent deployments and efficient resource utilization.

```bash
# Check Docker installation
docker --version
docker-compose --version
docker info

# Check Docker daemon status
sudo systemctl status docker

# Start/stop Docker daemon
sudo systemctl start docker
sudo systemctl stop docker
sudo systemctl restart docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check Docker configuration
sudo cat /etc/docker/daemon.json
```

### **14.2 Docker Images Management**

**🔰 Beginner Level:**
Docker images are like templates for your applications. Managing them helps you keep your system organized and up-to-date.

**🔧 Intermediate Level:**
Image management involves version control, security scanning, and storage optimization. Proper image management ensures security, performance, and resource efficiency.

```bash
# List all Docker images
sudo docker images
sudo docker image ls

# Search for images
sudo docker search image-name

# Pull specific image
sudo docker pull image-name:tag

# Remove unused images
sudo docker image prune -f

# Remove specific image
sudo docker rmi image-name:tag

# Check image details
sudo docker inspect image-name:tag

# Save image to file
sudo docker save image-name:tag > image-name.tar

# Load image from file
sudo docker load < image-name.tar
```

### **14.3 Docker Containers Management**

**🔰 Beginner Level:**
Containers are running instances of your applications. Managing them helps you control what's running and fix problems.

**🔧 Intermediate Level:**
Container management involves lifecycle control, resource allocation, and performance monitoring. It's essential for system stability and application availability.

```bash
# List running containers
sudo docker ps
sudo docker container ls

# List all containers (including stopped)
sudo docker ps -a

# Start/stop/restart containers
sudo docker start container-name
sudo docker stop container-name
sudo docker restart container-name

# Remove containers
sudo docker rm container-name
sudo docker container prune -f

# Execute commands in running container
sudo docker exec -it container-name bash
sudo docker exec -it container-name sh

# View container logs
sudo docker logs container-name
sudo docker logs -f container-name

# Check container resource usage
sudo docker stats container-name
```

### **14.4 Docker Compose Management**

**🔰 Beginner Level:**
Docker Compose is like a manager that runs multiple containers together. It makes it easier to run your entire application stack.

**🔧 Intermediate Level:**
Docker Compose manages multi-container applications with defined dependencies and configurations. Proper Compose management ensures consistent deployments and service orchestration.

```bash
# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Check Docker Compose configuration
sudo docker-compose config

# Validate configuration
sudo docker-compose config --quiet

# Start all services
cp .env.production .env
sudo docker-compose up -d

# Stop all services
sudo docker-compose down

# Restart all services
sudo docker-compose restart

# View service logs
sudo docker-compose logs
sudo docker-compose logs -f service-name

# Scale services
sudo docker-compose up -d --scale service-name=2

# Pull latest images
sudo docker-compose pull

# Rebuild services
sudo docker-compose build
cp .env.production .env
sudo docker-compose up -d --build
```

### **14.5 Docker Networks Management**

**🔰 Beginner Level:**
Docker networks allow containers to communicate with each other. Managing them helps you control how your applications connect.

**🔧 Intermediate Level:**
Network management involves creating isolated networks, configuring communication between containers, and ensuring proper service discovery. It's crucial for application architecture and security.

```bash
# List Docker networks
sudo docker network ls

# Inspect network
sudo docker network inspect network-name

# Create custom network
sudo docker network create network-name

# Connect container to network
sudo docker network connect network-name container-name

# Disconnect container from network
sudo docker network disconnect network-name container-name

# Remove network
sudo docker network rm network-name

# Check network connectivity
sudo docker exec container-name ping other-container
```

### **14.6 Docker Volumes Management**

**🔰 Beginner Level:**
Docker volumes are like external storage for your containers. They help you save data even when containers are removed.

**🔧 Intermediate Level:**
Volume management involves persistent data storage, backup strategies, and data consistency. Proper volume management ensures data persistence and application reliability.

```bash
# List Docker volumes
sudo docker volume ls

# Create volume
sudo docker volume create volume-name

# Inspect volume
sudo docker volume inspect volume-name

# Remove volume
sudo docker volume rm volume-name

# Remove unused volumes
sudo docker volume prune -f

# Backup volume data
sudo docker run --rm -v volume-name:/data -v $(pwd):/backup alpine tar czf /backup/volume-backup.tar.gz -C /data .

# Restore volume data
sudo docker run --rm -v volume-name:/data -v $(pwd):/backup alpine tar xzf /backup/volume-backup.tar.gz -C /data
```

### **14.7 Docker System Maintenance**

**🔰 Beginner Level:**
Docker system maintenance keeps your Docker environment clean and efficient.

**🔧 Intermediate Level:**
System maintenance involves cleaning up unused resources, optimizing storage, and monitoring system health. It's essential for performance and resource management.

```bash
# Check Docker system info
sudo docker system df
sudo docker system info

# Clean up unused resources
sudo docker system prune -f

# Clean up everything (use with caution)
sudo docker system prune -a -f

# Check Docker daemon logs
sudo journalctl -u docker.service -f

# Restart Docker daemon
sudo systemctl restart docker

# Check Docker storage driver
sudo docker info | grep "Storage Driver"

# Monitor Docker daemon
sudo docker events --filter 'type=container'
```

### **14.7.1 Docker Environment Cleanup**

**🔰 Beginner Level:**
Docker environment cleanup removes unused containers, images, volumes, and networks to free up disk space and keep your system organized.

**🔧 Intermediate Level:**
Regular cleanup prevents disk space issues, improves performance, and maintains a clean Docker environment. It's essential for long-term system maintenance.

#### **Check Current Docker State**

```bash
# List all containers (including stopped ones) - should be empty if cleaned
sudo docker ps -a

# List all Docker images - should be minimal after cleanup
sudo docker images

# List all Docker volumes - should be empty if pruned
sudo docker volume ls

# List all Docker networks - should show only default networks
sudo docker network ls

# Check Docker disk usage
sudo docker system df
```

#### **Cleanup Commands**

```bash
# Remove all stopped containers, unused networks, dangling images, and build cache
sudo docker system prune -f

# Remove all unused images (not just dangling ones)
sudo docker image prune -a -f

# Remove all unused volumes (⚠️ WARNING: This will delete data!)
sudo docker volume prune -f

# Remove all unused networks
sudo docker network prune -f

# Complete cleanup - remove everything unused including volumes (⚠️ WARNING: This will delete all data!)
sudo docker system prune -a --volumes -f

# Remove specific unused resources
sudo docker container prune -f    # Remove stopped containers
sudo docker image prune -f        # Remove dangling images
sudo docker volume prune -f       # Remove unused volumes
sudo docker network prune -f      # Remove unused networks
```

#### **Cleanup Verification**

```bash
# Verify cleanup was successful
sudo docker ps -a       # Should show no containers
sudo docker images      # Should be empty or minimal
sudo docker volume ls   # Should be empty if pruned
sudo docker network ls  # Should show only default networks

# Check disk space freed
df -h
sudo docker system df
```

#### **Safe Cleanup Workflow**

```bash
# 1. Stop all running containers first
sudo docker-compose down

# 2. Check what will be removed (dry run)
sudo docker system prune --dry-run

# 3. Perform safe cleanup (keeps volumes)
sudo docker system prune -f

# 4. Remove unused images
sudo docker image prune -a -f

# 5. Restart services
cp .env.production .env
sudo docker-compose up -d

# 6. Verify services are running
sudo docker-compose ps
```

#### **Emergency Cleanup (Use with Extreme Caution)**

```bash
# ⚠️ WARNING: This will delete ALL Docker data including volumes!
# Only use when you need to completely reset Docker environment

# Stop all containers
sudo docker stop $(sudo docker ps -aq)

# Remove all containers
sudo docker rm $(sudo docker ps -aq)

# Remove all images
sudo docker rmi $(sudo docker images -q)

# Remove all volumes
sudo docker volume rm $(sudo docker volume ls -q)

# Remove all networks (except default ones)
sudo docker network prune -f

# Complete system cleanup
sudo docker system prune -a --volumes -f

# Verify complete cleanup
sudo docker ps -a       # Should be empty
sudo docker images      # Should be empty
sudo docker volume ls   # Should be empty
sudo docker network ls  # Should show only defaults
```

### **14.8 Docker Security Management**

**🔰 Beginner Level:**
Docker security protects your containers from attacks and unauthorized access.

**🔧 Intermediate Level:**
Security management involves image scanning, access control, and vulnerability assessment. It's crucial for protecting applications and data in containerized environments.

```bash
# Scan images for vulnerabilities
sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image image-name:tag

# Check container security
sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy container container-name

# Run container with security options
sudo docker run --security-opt no-new-privileges --read-only -d image-name

# Check container capabilities
sudo docker inspect container-name | grep -A 10 "SecurityOpt"

# Update Docker to latest version
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

### **14.9 Docker Performance Optimization**

**🔰 Beginner Level:**
Performance optimization makes your Docker applications run faster and use fewer resources.

**🔧 Intermediate Level:**
Performance optimization involves resource allocation, caching strategies, and monitoring. It helps maximize efficiency and minimize resource consumption.

```bash
# Monitor container performance
sudo docker stats --no-stream

# Set resource limits
sudo docker run -d --memory=512m --cpus=1.0 image-name

# Optimize Docker daemon
sudo nano /etc/docker/daemon.json
```

**Docker Daemon Optimization Example:**
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5
}
```

---

## 🚀 Step 15 – Git Repository Management

### **15.1 Git Repository Setup and Configuration**

**🔰 Beginner Level:**
Git is like a version control system that tracks changes to your code. It helps you keep track of what you've changed and collaborate with others.

**🔧 Intermediate Level:**
Git provides distributed version control for tracking code changes, managing branches, and enabling collaboration. Proper Git management ensures code safety, change tracking, and deployment consistency.

```bash
# Check Git installation
git --version

# Configure Git user (if not already set)
git config --global user.name "Viktar T"
git config --global user.email "your-email@example.com"

# Check Git configuration
git config --list
git config --global --list

# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Check repository status
git status
git remote -v
```

### **15.1.1 SSH Key Configuration for GitHub**

**🔰 Beginner Level:**
SSH keys are like a secure password that allows you to connect to GitHub without typing your password every time.

**🔧 Intermediate Level:**
SSH keys provide secure, passwordless authentication to GitHub. They use public-key cryptography to establish secure connections and are more secure than password authentication.

```bash
# Check existing SSH keys
ls -la ~/.ssh/

# Generate new SSH key (if needed)
ssh-keygen -t ed25519 -C "your-email@example.com"
# or for older systems:
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519
# or for RSA:
ssh-add ~/.ssh/id_rsa

# Display public key to copy to GitHub
cat ~/.ssh/id_ed25519.pub
# or for RSA:
cat ~/.ssh/id_rsa.pub

# Test SSH connection to GitHub
ssh -T git@github.com
```

**Add SSH Key to GitHub:**
1. Copy the public key output from `cat ~/.ssh/id_ed25519.pub`
2. Go to GitHub.com → Settings → SSH and GPG keys
3. Click "New SSH key"
4. Paste the public key and save

**Configure Git to use SSH:**
```bash
# Change remote URL from HTTPS to SSH
git remote set-url origin git@github.com:Viktar-T/plat-edu-bad-data-mvp.git

# Verify the change
git remote -v

# Test the connection
ssh -T git@github.com
```

**Expected output for successful SSH connection:**
```
Hi Viktar-T! You've successfully authenticated, but GitHub does not provide shell access.
```

### **15.2 Repository Information**

**🔰 Beginner Level:**
Your project is stored in a Git repository that tracks all changes and allows you to work with different versions of your code.

**🔧 Intermediate Level:**
The repository contains the complete project history, configuration files, and deployment scripts. Understanding the repository structure helps with maintenance and updates.

**Repository Details:**
- **Repository URL (SSH)**: `git@github.com:Viktar-T/plat-edu-bad-data-mvp.git`
- **Repository URL (HTTPS)**: `https://github.com/Viktar-T/plat-edu-bad-data-mvp.git`
- **Local Path**: `/home/viktar/plat-edu-bad-data-mvp`
- **Branch**: `main` (or current branch)
- **Remote**: `origin`
- **Authentication**: SSH Keys (recommended)

```bash
# Check repository information
git remote -v
git branch -a
git log --oneline -10

# Check current branch
git branch
git status

# View repository details
git remote show origin
```

### **15.3 Basic Git Operations**

**🔰 Beginner Level:**
Basic Git operations help you save changes, check what's different, and update your code.

**🔧 Intermediate Level:**
Basic operations involve staging changes, committing updates, and managing the working directory. These operations are fundamental to version control workflows.

```bash
# Check current status
git status

# View changes
git diff
git diff --staged

# Add files to staging area
git add .
git add specific-file.txt

# Commit changes
git commit -m "Description of changes"

# View commit history
git log --oneline
git log --graph --oneline --all

# Check specific commit
git show commit-hash
```

### **15.4 Working with Remote Repository**

**🔰 Beginner Level:**
The remote repository is like a backup of your code stored on GitHub. You can download updates and upload your changes.

**🔧 Intermediate Level:**
Remote repository management involves synchronizing local and remote changes, handling conflicts, and maintaining code consistency across environments.

```bash
# Fetch latest changes from remote
git fetch origin

# Pull latest changes
git pull origin main

# Push changes to remote
git push origin main

# Check remote branches
git branch -r

# Create and push new branch
git checkout -b new-feature
git push -u origin new-feature

# Delete remote branch
git push origin --delete branch-name
```

**SSH-Specific Operations:**
```bash
# Verify SSH connection before operations
ssh -T git@github.com

# Clone repository using SSH
git clone git@github.com:Viktar-T/plat-edu-bad-data-mvp.git

# Add remote using SSH URL
git remote add origin git@github.com:Viktar-T/plat-edu-bad-data-mvp.git

# Change existing remote from HTTPS to SSH
git remote set-url origin git@github.com:Viktar-T/plat-edu-bad-data-mvp.git

# Test SSH connection with verbose output
ssh -vT git@github.com
```

### **15.5 Branch Management**

**🔰 Beginner Level:**
Branches are like separate copies of your code where you can make changes without affecting the main version.

**🔧 Intermediate Level:**
Branch management involves creating feature branches, merging changes, and maintaining a clean repository structure. It enables parallel development and safe experimentation.

```bash
# List all branches
git branch -a

# Create new branch
git checkout -b feature-name

# Switch between branches
git checkout branch-name
git switch branch-name

# Merge branch into main
git checkout main
git merge feature-name

# Delete local branch
git branch -d branch-name
git branch -D branch-name  # Force delete

# View branch history
git log --graph --oneline --all
```

### **15.6 Stashing and Temporary Changes**

**🔰 Beginner Level:**
Stashing is like putting your changes on hold temporarily so you can work on something else.

**🔧 Intermediate Level:**
Stashing allows you to save uncommitted changes temporarily, switch contexts, and return to work later. It's useful for managing multiple tasks and maintaining a clean working directory.

```bash
# Stash current changes
git stash

# Stash with description
git stash push -m "Work in progress"

# List stashes
git stash list

# Apply latest stash
git stash pop

# Apply specific stash
git stash apply stash@{n}

# View stash contents
git stash show stash@{n}

# Drop stash
git stash drop stash@{n}

# Clear all stashes
git stash clear
```

### **15.7 Repository Maintenance and Cleanup**

**🔰 Beginner Level:**
Repository maintenance keeps your Git history clean and organized.

**🔧 Intermediate Level:**
Maintenance involves cleaning up old branches, optimizing repository size, and maintaining a clean commit history. It improves performance and collaboration.

```bash
# Clean untracked files
git clean -n  # Preview what will be deleted
git clean -f  # Delete untracked files
git clean -fd # Delete untracked files and directories

# Remove files from Git tracking
git rm file-name
git rm --cached file-name  # Keep file but stop tracking

# Reset to previous commit
git reset --soft HEAD~1    # Keep changes staged
git reset --mixed HEAD~1   # Keep changes unstaged
git reset --hard HEAD~1    # Discard changes

# Rebase to clean history
git rebase -i HEAD~5
```

### **15.8 Deployment and Production Updates**

**🔰 Beginner Level:**
Deployment updates involve getting the latest code from GitHub and applying it to your server.

**🔧 Intermediate Level:**
Deployment management involves pulling updates, testing changes, and safely applying them to production. It requires careful coordination to avoid service disruption.

```bash
# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Check current status
git status
git log --oneline -5

# Fetch latest changes
git fetch origin

# Check what's new
git log HEAD..origin/main --oneline

# Pull latest changes
git pull origin main

# Check for conflicts
git status

# If conflicts exist, resolve them
git add resolved-file.txt
git commit -m "Resolve merge conflicts"

# Restart services after update
sudo docker-compose down
cp .env.production .env
sudo docker-compose up -d

# Verify services are running
sudo docker-compose ps
```

### **15.9 Backup and Recovery with Git**

**🔰 Beginner Level:**
Git provides built-in backup for your code. You can always recover previous versions if something goes wrong.

**🔧 Intermediate Level:**
Git backup strategies involve remote repositories, local backups, and recovery procedures. They ensure code safety and enable disaster recovery.

```bash
# Create backup of current state
git bundle create backup-$(date +%Y%m%d).bundle HEAD main

# Restore from backup
git clone backup-20240101.bundle backup-restore

# Create patch for specific changes
git format-patch -1 commit-hash

# Apply patch
git apply patch-file.patch

# Export specific version
git archive --format=tar --output=version-1.0.tar HEAD

# Clone repository to backup location (using SSH)
git clone --mirror git@github.com:Viktar-T/plat-edu-bad-data-mvp.git backup-repo

# Backup SSH keys (important for repository access)
cp -r ~/.ssh ~/.ssh-backup-$(date +%Y%m%d)
tar -czf ssh-keys-backup-$(date +%Y%m%d).tar.gz ~/.ssh/

# Restore SSH keys if needed
tar -xzf ssh-keys-backup-20240101.tar.gz -C ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### **15.10 Git Hooks and Automation**

**🔰 Beginner Level:**
Git hooks are like automatic actions that happen when you make changes to your repository.

**🔧 Intermediate Level:**
Git hooks enable automation of deployment, testing, and validation processes. They ensure code quality and consistent deployment procedures.

```bash
# Check existing hooks
ls -la .git/hooks/

# Create pre-commit hook
nano .git/hooks/pre-commit
```

**Pre-commit Hook Example:**
```bash
#!/bin/bash
# Pre-commit hook for renewable energy IoT project

echo "Running pre-commit checks..."

# Check Docker Compose syntax
if ! sudo docker-compose config --quiet; then
    echo "ERROR: Docker Compose configuration is invalid"
    exit 1
fi

# Check for sensitive data in commits
if git diff --cached | grep -i "password\|secret\|token"; then
    echo "WARNING: Potential sensitive data detected"
    echo "Please review before committing"
fi

echo "Pre-commit checks passed"
```

### **15.11 Troubleshooting Git Issues**

**🔰 Beginner Level:**
Git issues can be confusing, but there are common solutions for most problems.

**🔧 Intermediate Level:**
Troubleshooting involves understanding Git's internal structure, resolving conflicts, and recovering from common mistakes. It requires knowledge of Git's workflow and commands.

```bash
# Fix detached HEAD state
git checkout main

# Recover deleted branch
git reflog
git checkout -b recovered-branch commit-hash

# Fix merge conflicts
git status
# Edit conflicted files
git add resolved-file.txt
git commit -m "Resolve conflicts"

# Reset to remote state
git fetch origin
git reset --hard origin/main

# Clean up repository
git gc
git prune
```

### **15.12 Troubleshooting SSH Issues**

**🔰 Beginner Level:**
SSH issues can prevent you from connecting to GitHub. These commands help you identify and fix connection problems.

**🔧 Intermediate Level:**
SSH troubleshooting involves checking key permissions, agent status, and network connectivity. It requires understanding SSH configuration and GitHub's authentication requirements.

```bash
# Check SSH agent status
eval "$(ssh-agent -s)"
ssh-add -l

# Check SSH key permissions (should be 600)
ls -la ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Test SSH connection with verbose output
ssh -vT git@github.com

# Check if SSH key is loaded in agent
ssh-add -l

# Remove and re-add SSH key to agent
ssh-add -d ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519

# Check SSH configuration
cat ~/.ssh/config

# Create SSH config file for GitHub
nano ~/.ssh/config
```

**SSH Config File Example:**
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

**Common SSH Issues and Solutions:**
```bash
# Issue: Permission denied (publickey)
# Solution: Check if key is added to GitHub and agent
ssh-add -l
ssh -T git@github.com

# Issue: SSH key not found
# Solution: Generate new key or check path
ls -la ~/.ssh/
ssh-keygen -t ed25519 -C "your-email@example.com"

# Issue: SSH agent not running
# Solution: Start agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Issue: Wrong permissions on SSH files
# Solution: Fix permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

---

## 🧩 Use in Cursor (prompt)
```text
Verify that all services are Up/healthy on the VPS. If any container is Restarting or Exited, fetch its last 200 log lines and propose a fix with concrete steps. Check system resources, network connectivity, and service accessibility.
```


