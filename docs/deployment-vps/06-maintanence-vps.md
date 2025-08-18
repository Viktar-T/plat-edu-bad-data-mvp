# 🚀 Step 6 – VPS Maintenance Guide

> **Comprehensive maintenance schedule for your renewable energy IoT monitoring system on Mikrus VPS**

## 📋 Table of Contents

- [📋 Overview](#-overview)
- [🎯 Your Specific Server Details](#-your-specific-server-details)
- [📅 Daily Maintenance Tasks](#-daily-maintenance-tasks)
- [📅 Weekly Maintenance Tasks](#-weekly-maintenance-tasks)
- [📅 Monthly Maintenance Tasks](#-monthly-maintenance-tasks)
- [📅 Quarterly Maintenance Tasks](#-quarterly-maintenance-tasks)
- [📅 Annual Maintenance Tasks](#-annual-maintenance-tasks)
- [🔧 Automated Maintenance Scripts](#-automated-maintenance-scripts)
- [📊 Monitoring and Alerting](#-monitoring-and-alerting)
- [🛠️ Troubleshooting Common Issues](#-troubleshooting-common-issues)
- [✅ Maintenance Checklist](#-maintenance-checklist)

---

## 📋 Overview

This guide provides a structured maintenance schedule for your renewable energy IoT monitoring system on the Mikrus VPS. Regular maintenance ensures system reliability, security, and optimal performance.

### 🎯 What You'll Learn
- Daily health checks and monitoring
- Weekly system updates and cleanup
- Monthly security reviews and optimization
- Quarterly performance analysis
- Annual comprehensive maintenance
- Automated maintenance scripts

### ✅ Prerequisites
- ✅ VPS setup completed
- ✅ Application deployed and running
- ✅ SSH access to your Mikrus VPS
- ✅ Basic Linux command knowledge

---

## 🎯 Your Specific Server Details

**Server Information:**
- **Hostname**: `robert108.mikrus.xyz`
- **SSH Port**: `10108`
- **SSH Command**: `ssh viktar@robert108.mikrus.xyz -p10108`
- **Project Directory**: `/home/viktar/plat-edu-bad-data-mvp`
- **Service Ports**: `40098` (MQTT), `40099` (Grafana), `40100` (Node-RED), `40101` (InfluxDB)

---

## 📅 Daily Maintenance Tasks

### **🔰 Beginner Level:**
Daily maintenance takes 5-10 minutes and ensures your system is running properly.

### **🔧 Intermediate Level:**
Daily tasks focus on health monitoring, quick status checks, and early problem detection.

### **6.1 Service Status Check**

```bash
# SSH to your VPS
ssh viktar@robert108.mikrus.xyz -p10108

# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Check Docker container status
sudo docker-compose ps

# Expected output should show all services as "Up (healthy)"
```

### **6.2 System Resource Monitoring**

```bash
# Check system resources
htop
# Look for:
# - CPU usage (should be < 80%)
# - Memory usage (should be < 90%)
# - Load average (should be < number of CPU cores)

# Check disk usage
df -h
# Look for:
# - Root partition usage (should be < 90%)
# - Available space (should be > 1GB)

# Check memory usage
free -h
# Look for:
# - Available memory (should be > 100MB)
```

### **6.3 Service Health Verification**

```bash
# Test service accessibility
curl -s http://localhost:40099/api/health | jq .status
curl -s http://localhost:40100/ | head -20
curl -s http://localhost:40101/health

# Check recent logs for errors
sudo docker-compose logs --tail=20 | grep -i "error\|exception\|failed"
```

### **6.4 Quick Backup Check**

```bash
# Check if backup directory exists and has recent files
ls -la ~/backups/ 2>/dev/null || echo "No backup directory found"

# Check backup file sizes
du -sh ~/backups/* 2>/dev/null || echo "No backup files found"
```

### **6.5 Security Quick Check**

```bash
# Check failed login attempts
sudo tail -20 /var/log/auth.log | grep -i "failed\|invalid"

# Check for suspicious processes
ps aux | grep -v grep | grep -E "(crypto\|miner\|scan)" || echo "No suspicious processes found"
```

---

## 📅 Weekly Maintenance Tasks

### **🔰 Beginner Level:**
Weekly maintenance takes 15-30 minutes and includes updates and cleanup.

### **🔧 Intermediate Level:**
Weekly tasks focus on system updates, data cleanup, and preventive maintenance.

### **6.6 System Package Updates**

```bash
# Update package lists
sudo apt update

# Check for available updates
sudo apt list --upgradable

# Install security updates only (recommended for production)
sudo apt upgrade -y

# Clean up package cache
sudo apt autoremove -y
sudo apt autoclean
```

### **6.7 Docker Environment Cleanup**

```bash
# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Stop services for maintenance
sudo docker-compose stop

# Clean up unused Docker resources
sudo docker system prune -f
sudo docker image prune -a -f

# Restart services
cp .env.production .env
sudo docker-compose up -d

# Verify services are running
sudo docker-compose ps
```

### **6.8 Log Cleanup and Rotation**

```bash
# Clean old MQTT logs (older than 7 days)
find ./mosquitto/log/ -name "*.log" -mtime +7 -delete 2>/dev/null || echo "No old MQTT logs found"

# Clean old Node-RED logs (older than 7 days)
find ./node-red/data/ -name "*.log" -mtime +7 -delete 2>/dev/null || echo "No old Node-RED logs found"

# Clean old Grafana logs (older than 7 days)
find ./grafana/data/ -name "*.log" -mtime +7 -delete 2>/dev/null || echo "No old Grafana logs found"

# Force log rotation
sudo logrotate -f /etc/logrotate.conf
```

### **6.9 Data Backup Creation**

```bash
# Create weekly backup
BACKUP_DIR="/home/viktar/backups"
DATE=$(date +%Y%m%d-%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create project backup
tar -czf $BACKUP_DIR/weekly-backup-$DATE.tar.gz \
  influxdb/data/ grafana/data/ node-red/data/ mosquitto/data/

# Create configuration backup
tar -czf $BACKUP_DIR/config-backup-$DATE.tar.gz \
  docker-compose.yml .env.production \
  mosquitto/config/ influxdb/config/

echo "Weekly backup completed: $DATE"
```

### **6.10 Performance Monitoring**

```bash
# Check container resource usage
sudo docker stats --no-stream

# Check disk usage by service
du -sh ./influxdb/data/ ./grafana/data/ ./node-red/data/ ./mosquitto/data/

# Check for any performance issues in logs
sudo docker-compose logs --tail=100 | grep -i "slow\|timeout\|memory\|cpu"
```

---

## 📅 Monthly Maintenance Tasks

### **🔰 Beginner Level:**
Monthly maintenance takes 30-60 minutes and includes comprehensive system review.

### **🔧 Intermediate Level:**
Monthly tasks focus on security reviews, performance optimization, and system health assessment.

### **6.11 Security Review and Hardening**

```bash
# Check for security updates
sudo apt list --upgradable | grep -i "security"

# Review SSH access logs
sudo grep -i "sshd" /var/log/auth.log | tail -50

# Check fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Review user accounts
cat /etc/passwd | grep -E "(viktar|root)"

# Check file permissions
ls -la /home/viktar/plat-edu-bad-data-mvp/
```

### **6.12 Password and Credential Updates**

```bash
# Update default passwords (if not already done)
echo "Remember to update these default passwords:"
echo "- Grafana: admin/admin"
echo "- Node-RED: admin/adminpassword"
echo "- InfluxDB: admin/admin_password_123"
echo "- MQTT: admin/admin_password_456"

# Check for password changes in configuration files
grep -r "password" .env* 2>/dev/null | grep -v "admin_password"
```

### **6.13 Comprehensive System Health Check**

```bash
# Check system uptime and load
uptime
cat /proc/loadavg

# Check memory and swap usage
free -h
swapon --show

# Check disk health
sudo smartctl -a /dev/sda 2>/dev/null || echo "SMART not available"

# Check network connectivity
ping -c 4 google.com
ping -c 4 robert108.mikrus.xyz

# Check open ports
sudo netstat -tlnp | grep -E "(40098|40099|40100|40101)"
```

### **6.14 Data Retention and Storage Analysis**

```bash
# Check InfluxDB data retention
echo "InfluxDB retention policy: 30 days"
echo "Data older than 30 days is automatically deleted"

# Check current data size
du -sh ./influxdb/data/

# Check for any data anomalies
sudo docker-compose exec influxdb influx query \
  --org renewable_energy_org \
  --token renewable_energy_admin_token_123 \
  "from(bucket: \"renewable_energy\") |> range(start: -1d) |> count()" 2>/dev/null || echo "Query failed"
```

### **6.15 Performance Optimization**

```bash
# Optimize Docker daemon (if needed)
sudo nano /etc/docker/daemon.json

# Add these optimizations if not present:
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}

# Restart Docker daemon
sudo systemctl restart docker

# Restart services
cd ~/plat-edu-bad-data-mvp
cp .env.production .env
sudo docker-compose up -d
```

---

## 📅 Quarterly Maintenance Tasks

### **🔰 Beginner Level:**
Quarterly maintenance takes 1-2 hours and includes deep system analysis.

### **🔧 Intermediate Level:**
Quarterly tasks focus on capacity planning, performance analysis, and system optimization.

### **6.16 Capacity Planning and Analysis**

```bash
# Analyze disk usage trends
echo "=== Disk Usage Analysis ==="
df -h
du -sh /home/viktar/plat-edu-bad-data-mvp/*/

# Analyze memory usage patterns
echo "=== Memory Usage Analysis ==="
free -h
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"

# Analyze CPU usage patterns
echo "=== CPU Usage Analysis ==="
top -bn1 | grep "Cpu(s)"
nproc
```

### **6.17 Performance Benchmarking**

```bash
# Test service response times
echo "=== Service Response Time Test ==="
time curl -s http://localhost:40099/api/health > /dev/null
time curl -s http://localhost:40100/ > /dev/null
time curl -s http://localhost:40101/health > /dev/null

# Test MQTT performance
echo "=== MQTT Performance Test ==="
mosquitto_pub -h localhost -p 1883 -t test/performance -m "test" -u admin -P admin_password_456
```

### **6.18 Security Audit**

```bash
# Check for open ports and services
sudo netstat -tlnp
sudo ss -tuln

# Check for unauthorized access attempts
sudo grep -i "failed\|invalid" /var/log/auth.log | wc -l

# Check for suspicious files
find /home/viktar -name ".*" -type f -exec ls -la {} \; 2>/dev/null

# Check for large files that might indicate issues
find /home/viktar -size +100M -type f 2>/dev/null
```

### **6.19 Backup Strategy Review**

```bash
# Review backup retention policy
echo "=== Backup Review ==="
ls -la ~/backups/

# Check backup integrity
echo "=== Backup Integrity Check ==="
for backup in ~/backups/*.tar.gz; do
    echo "Checking $backup..."
    tar -tzf "$backup" > /dev/null && echo "✅ Valid" || echo "❌ Corrupted"
done

# Test backup restoration (optional - in test environment)
echo "Consider testing backup restoration in a test environment"
```

---

## 📅 Annual Maintenance Tasks

### **🔰 Beginner Level:**
Annual maintenance takes 2-4 hours and includes comprehensive system overhaul.

### **🔧 Intermediate Level:**
Annual tasks focus on major updates, security reviews, and long-term planning.

### **6.20 Major System Updates**

```bash
# Update to latest LTS Ubuntu version (if available)
sudo do-release-upgrade -d

# Update Docker to latest version
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Update all application images
cd ~/plat-edu-bad-data-mvp
sudo docker-compose pull
sudo docker-compose down
cp .env.production .env
sudo docker-compose up -d
```

### **6.21 Comprehensive Security Review**

```bash
# Run security audit tools
sudo apt install lynis
sudo lynis audit system

# Check for known vulnerabilities
sudo apt install debian-goodies
checkrestart

# Review and update firewall rules
sudo ufw status numbered
sudo ufw app list
```

### **6.22 Infrastructure Assessment**

```bash
# Assess current infrastructure needs
echo "=== Infrastructure Assessment ==="
echo "Current disk usage:"
df -h

echo "Current memory usage:"
free -h

echo "Current CPU usage:"
top -bn1 | grep "Cpu(s)"

echo "Service performance:"
sudo docker stats --no-stream
```

### **6.23 Disaster Recovery Testing**

```bash
# Test complete system restoration
echo "=== Disaster Recovery Test ==="
echo "1. Create test environment"
echo "2. Restore from backup"
echo "3. Verify all services work"
echo "4. Test data integrity"
echo "5. Document any issues"

# Create disaster recovery documentation
cat > ~/disaster-recovery-plan.md << 'EOF'
# Disaster Recovery Plan

## Recovery Steps:
1. Restore from latest backup
2. Verify service connectivity
3. Test data integrity
4. Update DNS if needed
5. Notify stakeholders

## Contact Information:
- VPS Provider: Mikrus
- Emergency Contact: [Your Contact]
EOF
```

---

## 🔧 Automated Maintenance Scripts

### **6.24 Daily Maintenance Script**

```bash
# Create daily maintenance script
sudo nano /home/viktar/daily-maintenance.sh
```

**Script Content:**
```bash
#!/bin/bash
# Daily Maintenance Script for Renewable Energy IoT System

echo "=== Daily Maintenance $(date) ==="

# Navigate to project directory
cd /home/viktar/plat-edu-bad-data-mvp

# Check service status
echo "Checking service status..."
sudo docker-compose ps

# Check system resources
echo "Checking system resources..."
df -h | grep -E "(Filesystem|/dev/)"
free -h | grep -E "(Mem|Swap)"

# Check for errors in logs
echo "Checking for errors..."
sudo docker-compose logs --tail=50 | grep -i "error\|exception\|failed" | tail -5

# Check security
echo "Checking security..."
sudo tail -10 /var/log/auth.log | grep -i "failed\|invalid" | wc -l

echo "Daily maintenance completed: $(date)"
```

### **6.25 Weekly Maintenance Script**

```bash
# Create weekly maintenance script
sudo nano /home/viktar/weekly-maintenance.sh
```

**Script Content:**
```bash
#!/bin/bash
# Weekly Maintenance Script for Renewable Energy IoT System

echo "=== Weekly Maintenance $(date) ==="

# Navigate to project directory
cd /home/viktar/plat-edu-bad-data-mvp

# Update system packages
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Clean up Docker
echo "Cleaning up Docker..."
sudo docker system prune -f
sudo docker image prune -a -f

# Create backup
echo "Creating backup..."
BACKUP_DIR="/home/viktar/backups"
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/weekly-backup-$DATE.tar.gz \
  influxdb/data/ grafana/data/ node-red/data/ mosquitto/data/

# Clean old backups (keep last 4 weeks)
find $BACKUP_DIR -name "weekly-backup-*.tar.gz" -mtime +28 -delete

# Clean old logs
echo "Cleaning old logs..."
find ./mosquitto/log/ -name "*.log" -mtime +7 -delete 2>/dev/null
find ./node-red/data/ -name "*.log" -mtime +7 -delete 2>/dev/null
find ./grafana/data/ -name "*.log" -mtime +7 -delete 2>/dev/null

echo "Weekly maintenance completed: $(date)"
```

### **6.26 Setup Automated Execution**

```bash
# Make scripts executable
chmod +x /home/viktar/daily-maintenance.sh
chmod +x /home/viktar/weekly-maintenance.sh

# Set up cron jobs
crontab -e

# Add these lines:
# Daily maintenance at 6:00 AM
0 6 * * * /home/viktar/daily-maintenance.sh >> /var/log/daily-maintenance.log 2>&1

# Weekly maintenance on Sundays at 2:00 AM
0 2 * * 0 /home/viktar/weekly-maintenance.sh >> /var/log/weekly-maintenance.log 2>&1
```

---

## 📊 Monitoring and Alerting

### **6.27 System Monitoring Setup**

```bash
# Create monitoring script
sudo nano /home/viktar/system-monitor.sh
```

**Script Content:**
```bash
#!/bin/bash
# System Monitoring Script

THRESHOLD_CPU=80
THRESHOLD_MEMORY=90
THRESHOLD_DISK=90

# Check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l) )); then
    echo "WARNING: High CPU usage: ${CPU_USAGE}%"
fi

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $MEMORY_USAGE -gt $THRESHOLD_MEMORY ]; then
    echo "WARNING: High memory usage: ${MEMORY_USAGE}%"
fi

# Check disk usage
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
if [ $DISK_USAGE -gt $THRESHOLD_DISK ]; then
    echo "WARNING: High disk usage: ${DISK_USAGE}%"
fi

# Check service status
cd /home/viktar/plat-edu-bad-data-mvp
if ! sudo docker-compose ps | grep -q "Up"; then
    echo "ERROR: Some services are not running"
fi
```

### **6.28 Alert Configuration**

```bash
# Set up email alerts (if email service is configured)
echo "To set up email alerts, configure postfix or use a service like mailgun"

# Set up log monitoring
echo "Monitoring critical logs..."
sudo tail -f /var/log/auth.log | grep -i "failed\|invalid" &
sudo docker-compose logs -f | grep -i "error\|exception" &
```

---

## 🛠️ Troubleshooting Common Issues

### **6.29 High Disk Usage**

```bash
# Find large files
sudo find /home/viktar -size +100M -type f 2>/dev/null

# Clean up Docker
sudo docker system prune -a -f

# Clean up logs
sudo find /var/log -name "*.log" -mtime +7 -delete
sudo find /var/log -name "*.gz" -mtime +30 -delete
```

### **6.30 High Memory Usage**

```bash
# Check memory usage by process
ps aux --sort=-%mem | head -10

# Check Docker memory usage
sudo docker stats --no-stream

# Restart services if needed
cd /home/viktar/plat-edu-bad-data-mvp
sudo docker-compose restart
```

### **6.31 Service Failures**

```bash
# Check service logs
sudo docker-compose logs --tail=100

# Check service status
sudo docker-compose ps

# Restart failed services
sudo docker-compose restart [service-name]

# Check system resources
htop
df -h
free -h
```

---

## ✅ Maintenance Checklist

### **Daily Tasks**
- [ ] Check service status (`sudo docker-compose ps`)
- [ ] Monitor system resources (`htop`, `df -h`, `free -h`)
- [ ] Check for errors in logs
- [ ] Verify service accessibility

### **Weekly Tasks**
- [ ] Update system packages
- [ ] Clean up Docker environment
- [ ] Rotate and clean logs
- [ ] Create backup
- [ ] Monitor performance

### **Monthly Tasks**
- [ ] Security review and updates
- [ ] Update passwords and credentials
- [ ] Comprehensive health check
- [ ] Data retention analysis
- [ ] Performance optimization

### **Quarterly Tasks**
- [ ] Capacity planning analysis
- [ ] Performance benchmarking
- [ ] Security audit
- [ ] Backup strategy review

### **Annual Tasks**
- [ ] Major system updates
- [ ] Comprehensive security review
- [ ] Infrastructure assessment
- [ ] Disaster recovery testing

---

## 🎯 Quick Reference Commands

### **Essential Commands**
```bash
# Check service status
sudo docker-compose ps

# Check system resources
htop
df -h
free -h

# Check logs
sudo docker-compose logs --tail=50

# Restart services
sudo docker-compose restart

# Create backup
tar -czf backup-$(date +%Y%m%d).tar.gz influxdb/data/ grafana/data/ node-red/data/ mosquitto/data/

# Clean up Docker
sudo docker system prune -f
```

### **Emergency Commands**
```bash
# Stop all services
sudo docker-compose down

# Start all services
cp .env.production .env
sudo docker-compose up -d

# Check for errors
sudo docker-compose logs | grep -i "error\|exception\|failed"

# Restore from backup
tar -xzf backup-20240101.tar.gz -C /home/viktar/plat-edu-bad-data-mvp/
```

---

## 📞 Support and Resources

### **Documentation**
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [InfluxDB Documentation](https://docs.influxdata.com/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node-RED Documentation](https://nodered.org/docs/)

### **Monitoring Tools**
- **System Monitoring**: `htop`, `iotop`, `nethogs`
- **Log Monitoring**: `journalctl`, `tail -f`
- **Network Monitoring**: `netstat`, `ss`, `ping`
- **Disk Monitoring**: `df`, `du`, `iostat`

### **Maintenance Schedule Summary**
- **Daily**: 5-10 minutes (health checks)
- **Weekly**: 15-30 minutes (updates and cleanup)
- **Monthly**: 30-60 minutes (security and optimization)
- **Quarterly**: 1-2 hours (analysis and planning)
- **Annual**: 2-4 hours (major updates and review)

---

**🎯 Remember**: Regular maintenance prevents problems before they occur. Set up automated scripts and monitoring to make maintenance easier and more reliable.

