# 🚀 Step 3 – Operations and Management

> **Comprehensive guide for managing and operating your renewable energy IoT monitoring system on Mikrus VPS**

## 📋 Overview

This guide provides detailed instructions for managing, monitoring, and operating your renewable energy IoT monitoring system on your Mikrus VPS server. The system includes MQTT broker, Node-RED data processing, InfluxDB time-series database, Grafana visualization, and Nginx reverse proxy with path-based routing.

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
- **Default HTTP Port**: `20108`
- **Default HTTPS Port**: `30108`
- **Custom IoT Ports**: `1883` (MQTT), `40098-40102` (additional IoT ports)

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

## 🚀 Step 1 – Service Status Verification

### **1.1 Check Container Status**

**🔰 Beginner Level:**
Think of containers like individual applications running on your server. Each container is like a separate program that does a specific job. Checking container status is like checking if all your apps are running properly on your phone.

**🔧 Intermediate Level:**
Docker containers are isolated environments that run your applications. Each container has its own filesystem, network, and process space. The status tells you if the container is running, stopped, restarting, or has crashed.

```bash
# SSH to your VPS
ssh root@robert108.mikrus.xyz -p10108

# Navigate to deployment directory
cd /root/renewable-energy-iot

# Check container status
docker-compose ps
```

**Expected Output:**
```
Name                    Command               State                    Ports
--------------------------------------------------------------------------------
iot-grafana            /run.sh                 Up       0.0.0.0:3000->3000/tcp
iot-influxdb2          /entrypoint.sh          Up       0.0.0.0:8086->8086/tcp
iot-mosquitto          /docker-entrypoint. ... Up       0.0.0.0:1883->1883/tcp
iot-nginx              /docker-entrypoint. ... Up       0.0.0.0:20108->80/tcp
iot-node-red           /usr/src/node-red/ ... Up       0.0.0.0:1880->1880/tcp
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
docker-compose up -d

# Stop all services (RECOMMENDED for daily operations)
# - Keeps containers in memory for fast restart
# - Preserves all data and configurations
# - Maintains network connections
docker-compose stop

# Stop and remove all services (use for major updates or troubleshooting)
# - Completely removes containers
# - Slower restart but cleaner state
# - Use only when needed for updates or troubleshooting
docker-compose down

# Restart all services (fast restart after 'stop')
docker-compose start

# Restart all services (full restart after 'down')
docker-compose up -d
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
docker-compose up -d grafana
docker-compose up -d nodered
docker-compose up -d influxdb
docker-compose up -d mosquitto
docker-compose up -d nginx

# Stop specific service (RECOMMENDED for routine operations)
docker-compose stop grafana
docker-compose stop nodered
docker-compose stop influxdb
docker-compose stop mosquitto
docker-compose stop nginx

# Restart specific service
docker-compose restart grafana
docker-compose restart nodered
docker-compose restart influxdb
docker-compose restart mosquitto
docker-compose restart nginx
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
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# View container logs in real-time (follow mode)
docker-compose logs -f grafana
docker-compose logs -f nodered
docker-compose logs -f influxdb
docker-compose logs -f mosquitto
docker-compose logs -f nginx

# Execute commands inside a running container
docker-compose exec grafana bash
docker-compose exec nodered bash
docker-compose exec influxdb bash

# View container resource usage
docker stats

# Remove stopped containers and unused images
docker system prune -f
```

#### **Practical Recommendations for Your IoT System**

**🔰 Beginner Level:**
Here are the most common scenarios you'll encounter and which commands to use:

**🔧 Intermediate Level:**
These recommendations are optimized for your renewable energy IoT monitoring system to ensure data safety and fast recovery times.

**Daily Operations (Use `stop`):**
```bash
# Quick maintenance - pause everything temporarily
docker-compose stop
# ... do your maintenance ...
docker-compose start

# Individual service updates
docker-compose stop grafana
docker-compose up -d grafana
```

**Major Updates (Use `down`):**
```bash
# When pulling new images
docker-compose down
docker-compose pull
docker-compose up -d

# When troubleshooting persistent issues
docker-compose down
docker-compose up -d
```

**Emergency Situations:**
```bash
# If services are stuck or corrupted
docker-compose down
docker-compose up -d

# If you need to reset everything (rare - WARNING: removes volumes too!)
docker-compose down -v  # ⚠️ This will delete your data!
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
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Check individual service health
docker-compose exec grafana pgrep grafana-server || echo "Grafana not running"
docker-compose exec nodered pgrep node-red || echo "Node-RED not running"
docker-compose exec influxdb pgrep influxd || echo "InfluxDB not running"
docker-compose exec mosquitto pgrep mosquitto || echo "Mosquitto not running"
docker-compose exec nginx pgrep nginx || echo "Nginx not running"
```

### **1.4 Test Service Connectivity**

**🔰 Beginner Level:**
Connectivity tests are like checking if you can reach a website. They verify that your services can communicate with each other and that you can access them from outside.

**🔧 Intermediate Level:**
These tests verify network connectivity between containers and external accessibility. They help identify network configuration issues, firewall problems, and service communication failures.

```bash
# Test internal service communication
docker-compose exec nginx curl -s http://grafana:3000/api/health || echo "Grafana not reachable"
docker-compose exec nginx curl -s http://nodered:1880/ || echo "Node-RED not reachable"
docker-compose exec nginx curl -s http://influxdb:8086/health || echo "InfluxDB not reachable"

# Test external port accessibility
curl -s http://localhost:20108/grafana/ || echo "Grafana external access failed"
curl -s http://localhost:20108/nodered/ || echo "Node-RED external access failed"
curl -s http://localhost:20108/influxdb/ || echo "InfluxDB external access failed"
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
docker-compose logs --tail=100

# View specific service logs
docker-compose logs --tail=50 grafana
docker-compose logs --tail=50 nodered
docker-compose logs --tail=50 influxdb
docker-compose logs --tail=50 mosquitto
docker-compose logs --tail=50 nginx

# Follow logs in real-time (Ctrl+C to stop)
docker-compose logs -f grafana
docker-compose logs -f nodered
docker-compose logs -f influxdb
docker-compose logs -f mosquitto
docker-compose logs -f nginx

# View logs with timestamps
docker-compose logs --tail=50 --timestamps grafana
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

**Your Mikrus VPS uses path-based routing via Nginx:**

| Service | Internal Port | External URL | Default Credentials |
|---------|---------------|--------------|-------------------|
| **Grafana** | 3000 | `http://robert108.mikrus.xyz:20108/grafana/` | `admin` / `admin` |
| **Node-RED** | 1880 | `http://robert108.mikrus.xyz:20108/nodered/` | `admin` / `adminpassword` |
| **InfluxDB** | 8086 | `http://robert108.mikrus.xyz:20108/influxdb/` | `admin` / `admin_password_123` |
| **Homepage** | - | `http://robert108.mikrus.xyz:20108/` | Redirects to `/grafana/` |

### **4.2 IoT Service Access**

**🔰 Beginner Level:**
IoT services are for devices and applications that need to send and receive data. MQTT is like a messaging system for IoT devices.

**🔧 Intermediate Level:**
MQTT (Message Queuing Telemetry Transport) is a lightweight messaging protocol designed for IoT devices with limited bandwidth and processing power. It uses a publish/subscribe model for efficient data transmission.

| Service | Port | Access Method | Credentials |
|---------|------|---------------|-------------|
| **MQTT Broker** | 1883 | `robert108.mikrus.xyz:1883` | `admin` / `admin_password_456` |
| **MQTT WebSocket** | 9001 | `robert108.mikrus.xyz:9001` | `admin` / `admin_password_456` |

### **4.3 Service Testing Commands**

**🔰 Beginner Level:**
These commands test if your services are working properly. They're like checking if a light switch works by flipping it on and off.

**🔧 Intermediate Level:**
Service testing validates both connectivity and functionality. It ensures that services are not only reachable but also responding correctly to requests and maintaining proper authentication.

**Test Grafana Access:**
```bash
# Test Grafana homepage
curl -s http://robert108.mikrus.xyz:20108/grafana/ | head -20

# Test Grafana API
curl -s http://robert108.mikrus.xyz:20108/grafana/api/health
```

**Test Node-RED Access:**
```bash
# Test Node-RED homepage
curl -s http://robert108.mikrus.xyz:20108/nodered/ | head -20

# Test Node-RED admin API
curl -s http://robert108.mikrus.xyz:20108/nodered/admin/auth/token
```

**Test InfluxDB Access:**
```bash
# Test InfluxDB health
curl -s http://robert108.mikrus.xyz:20108/influxdb/health

# Test InfluxDB API
curl -s http://robert108.mikrus.xyz:20108/influxdb/api/v2/orgs
```

**Test MQTT Access:**
```bash
# Test MQTT connectivity
mosquitto_pub -h robert108.mikrus.xyz -p 1883 -t test/health -m "test" -u admin -P admin_password_456

# Test MQTT subscription
mosquitto_sub -h robert108.mikrus.xyz -p 1883 -t test/health -u admin -P admin_password_456 -C 1
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
docker-compose up -d

# Stop all services
docker-compose down

# Restart all services
docker-compose restart

# Start specific service
docker-compose up -d grafana
docker-compose up -d nodered
docker-compose up -d influxdb
docker-compose up -d mosquitto
docker-compose up -d nginx

# Stop specific service
docker-compose stop grafana
docker-compose stop nodered
docker-compose stop influxdb
docker-compose stop mosquitto
docker-compose stop nginx

# Restart specific service
docker-compose restart grafana
docker-compose restart nodered
docker-compose restart influxdb
docker-compose restart mosquitto
docker-compose restart nginx
```

### **5.2 Service Updates and Maintenance**

**🔰 Beginner Level:**
Updates keep your applications secure and add new features. Think of it like updating apps on your phone to get the latest version.

**🔧 Intermediate Level:**
Service updates involve version management, dependency resolution, and rollback strategies. Proper update procedures minimize downtime and ensure data consistency.

```bash
# Pull latest images
docker-compose pull

# Rebuild and restart services
docker-compose up -d --build

# Update specific service
docker-compose pull grafana
docker-compose up -d --no-deps grafana

# Check for image updates
docker-compose images

# Clean up unused images
docker image prune -f
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
sudo tar -xzf backup-20240101-120000.tar.gz -C /root/renewable-energy-iot/

# Backup specific service data
sudo tar -czf influxdb-backup-$(date +%Y%m%d).tar.gz influxdb/data/
sudo tar -czf grafana-backup-$(date +%Y%m%d).tar.gz grafana/data/
```

### **5.4 Configuration Management**

**🔰 Beginner Level:**
Configuration files are like settings for your applications. They control how your services behave and connect to each other.

**🔧 Intermediate Level:**
Configuration management involves version control, environment-specific settings, and configuration validation. It ensures consistency across deployments and environments.

```bash
# View current configuration
docker-compose config

# Validate configuration
docker-compose config --quiet

# Export configuration
docker-compose config > docker-compose-exported.yml

# Edit configuration files
sudo nano docker-compose.yml
sudo nano nginx/nginx.conf
sudo nano mosquitto/config/mosquitto.conf
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
docker stats

# Monitor disk usage
df -h
du -sh /root/renewable-energy-iot/*/

# Monitor memory usage
free -h
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"
```

### **6.2 Service Performance Monitoring**

**🔰 Beginner Level:**
Service performance monitoring checks how fast your applications respond to requests. It's like timing how long it takes for a webpage to load.

**🔧 Intermediate Level:**
Service performance monitoring involves response time analysis, throughput measurement, and error rate tracking. It helps identify performance bottlenecks and optimize application behavior.

```bash
# Monitor container resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Check container logs for performance issues
docker-compose logs | grep -i "slow\|timeout\|memory\|cpu"

# Monitor service response times
time curl -s http://robert108.mikrus.xyz:20108/grafana/api/health
time curl -s http://robert108.mikrus.xyz:20108/nodered/
time curl -s http://robert108.mikrus.xyz:20108/influxdb/health
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
docker-compose ps

# Check system resources
htop
df -h
free -h

# Check recent logs
docker-compose logs --tail=50
```

**Weekly Tasks:**
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean up Docker resources
docker system prune -f

# Check for image updates
docker-compose pull

# Create backup
sudo tar -czf backup-$(date +%Y%m%d).tar.gz \
  influxdb/data/ grafana/data/ node-red/data/ mosquitto/data/
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
docker stats --no-stream
df -h
free -h
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
docker-compose down

# 3. Pull latest images
docker-compose pull

# 4. Start services
docker-compose up -d

# 5. Verify services
docker-compose ps
docker-compose logs --tail=50

# 6. Test functionality
curl -s http://robert108.mikrus.xyz:20108/grafana/api/health
curl -s http://robert108.mikrus.xyz:20108/nodered/
curl -s http://robert108.mikrus.xyz:20108/influxdb/health
```

**Rollback Procedure:**
```bash
# If update fails, rollback to previous version
docker-compose down

# Restore from backup
sudo tar -xzf backup-before-update-20240101.tar.gz -C /root/renewable-energy-iot/

# Restart with previous configuration
docker-compose up -d

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

**🌐 Web Services (via Nginx Reverse Proxy):**
- **Grafana Dashboard**: `http://robert108.mikrus.xyz:20108/grafana/`
- **Node-RED Editor**: `http://robert108.mikrus.xyz:20108/nodered/`
- **InfluxDB Admin**: `http://robert108.mikrus.xyz:20108/influxdb/`
- **Default Homepage**: `http://robert108.mikrus.xyz:20108/` → `/grafana/`

**📡 IoT Services:**
- **MQTT Broker**: `robert108.mikrus.xyz:1883`
- **MQTT WebSocket**: `robert108.mikrus.xyz:9001`

**🔑 Default Credentials:**
- **Grafana**: `admin` / `admin`
- **Node-RED**: `admin` / `adminpassword`
- **InfluxDB**: `admin` / `admin_password_123`
- **MQTT**: `admin` / `admin_password_456`

**⚠️ Security Note:** Change these default passwords immediately after deployment!

---

## 🧩 Use in Cursor (prompt)
```text
Verify that all services are Up/healthy on the VPS. If any container is Restarting or Exited, fetch its last 200 log lines and propose a fix with concrete steps. Check system resources, network connectivity, and service accessibility.
```


