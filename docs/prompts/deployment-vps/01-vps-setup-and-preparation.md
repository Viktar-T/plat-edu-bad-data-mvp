# 🚀 Phase 1: VPS Setup and Preparation

> **Prepare your Mikrus VPS for renewable energy IoT monitoring system deployment**

## 📋 Overview

This phase covers the complete setup and preparation of your Mikrus VPS server for deploying the renewable energy IoT monitoring system. The setup includes server security, Docker installation, firewall configuration, and environment preparation optimized for Mikrus VPS specifications.

### 🎯 What is VPS Setup and Preparation?
VPS setup is like preparing a new computer for your specific needs. Think of it like setting up a new phone - you need to install the operating system, set up security, install the apps you need, and configure everything to work together. In this case, we're setting up a server that will run your renewable energy monitoring system.

### ✅ Prerequisites
- ✅ Mikrus VPS account and server access
- ✅ SSH client on Windows (PowerShell, WSL, or PuTTY)
- ✅ Basic understanding of Linux commands
- ✅ Project files ready for deployment

### 📁 Required Files
- SSH client (PowerShell, WSL, or PuTTY)
- Your Mikrus VPS credentials
- Project deployment files (will be created in Phase 2)

---

## 🎯 Your Specific Server Details

**Server Information:**
- **Hostname**: `robert108.mikrus.xyz`
- **SSH Port**: `10108`
- **SSH Command**: `ssh root@robert108.mikrus.xyz -p10108`
- **Default HTTP Port**: `20108`
- **Default HTTPS Port**: `30108`
- **Custom IoT Ports**: `40098-40102`

**Connection Details:**
```bash
# Connect to your server
ssh root@robert108.mikrus.xyz -p10108

# Or with host key verification disabled (first time only)
ssh -o StrictHostKeyChecking=no root@robert108.mikrus.xyz -p10108
```

---

## 🚀 Step-by-Step Setup

## Step 1 – Initial Server Access

#### **1.1 Connect to Your VPS**
```bash
# Connect to your Mikrus VPS
ssh root@robert108.mikrus.xyz -p10108

# First time connection (accept host key)
ssh -o StrictHostKeyChecking=no root@robert108.mikrus.xyz -p10108
```

**Expected Output:**
```
The authenticity of host '[robert108.mikrus.xyz]:10108' can't be established.
ED25519 key fingerprint is SHA256:gNoTnODLfmt4B0zsz5kfyrIEcKnRP839HNJh1L5L+is.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[robert108.mikrus.xyz]:10108' to the list of known hosts.
root@robert108.mikrus.xyz's password: [Enter your password]
```

**What this means:** You're connecting to your server for the first time. The system is asking if you trust this server (like when you connect to a new WiFi network).

#### **1.2 Verify Server Information**
```bash
# Check server details
hostname
whoami
pwd
```

**Expected Output:**
```
robert108
root
/root
```

#### **1.3 Check System Resources**
```bash
# Check system information
free -h
df -h
cat /proc/cpuinfo | grep "model name" | head -1
```

**What this means:** You're checking how much memory, disk space, and what type of processor your server has. This helps you understand what your server can handle.

#### **1.4 Change Root Password (Recommended)**
```bash
# Change the root password
passwd
```

**Follow the prompts:**
- Enter current password
- Enter new password
- Confirm new password

**Security Tips:**
- Use a strong password (12+ characters, mix of letters, numbers, symbols)
- Don't use common words or patterns
- Consider using a password manager

---

## Step 2 – System Updates and Essential Tools

#### **2.1 Update System Packages**
```bash
# Update package list
apt update

# Upgrade installed packages
apt upgrade -y

# Clean up package cache
apt autoremove -y
apt autoclean
```

**What this means:** You're updating your server's software to the latest versions, like updating apps on your phone. This includes security updates and bug fixes.

#### **2.2 Install Essential Tools**
```bash
# Install essential packages
apt install -y curl wget git htop nano vim ufw fail2ban
```

**Package Explanations:**
| Package | Purpose | Why You Need It |
|---------|---------|-----------------|
| **curl** | Download files from the internet | Download Docker and other tools |
| **wget** | Alternative file downloader | Backup option for downloading files |
| **git** | Version control system | Download code and manage your project |
| **htop** | System monitoring tool | See what's running on your server |
| **nano** | Simple text editor | Edit configuration files easily |
| **vim** | Advanced text editor | More powerful editing capabilities |
| **ufw** | Firewall management | Control which connections are allowed |
| **fail2ban** | Intrusion prevention | Block repeated failed login attempts |

**The `-y` flag:** This automatically answers "yes" to prompts, so the installation runs without stopping to ask questions.

#### **2.3 Install Docker (if not installed)**
```bash
# Check if Docker is already installed
docker --version

# If Docker is not found, install it using the official script
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    
    # Download and run Docker installation script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    
    # Add root user to docker group
    usermod -aG docker root
    
    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker
    
    echo "Docker installation completed!"
else
    echo "Docker is already installed!"
fi

# Verify Docker installation
docker --version
docker-compose --version
```

**Alternative Installation Method (if official script fails):**
```bash
# Install Docker using apt
apt install -y docker.io docker-compose

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Add root user to docker group
usermod -aG docker root

# Verify installation
docker --version
docker-compose --version
```

**What this means:** Docker is like a container system that packages your applications with everything they need to run. It's like having separate boxes for each application, so they don't interfere with each other.

---

## Step 3 – Security Configuration

### **3.1 Basic Security Concepts**

**Why Security Matters:**
Think of your server like your house. You want to:
- Lock the doors (SSH security)
- Install an alarm system (firewall)
- Have security cameras (monitoring)
- Keep valuables safe (data protection)

**Common Threats:**
- **Brute Force Attacks**: Hackers trying thousands of passwords
- **Port Scanning**: Automated tools looking for open doors
- **DDoS Attacks**: Overwhelming your server with traffic
- **Malware**: Malicious software trying to infect your system

### **3.2 SSH Security Configuration**

**What are SSH Keys?**
SSH keys are like a special key card for your server:
- **Public Key**: Goes on the server (like a lock)
- **Private Key**: Stays on your computer (like the actual key)
- **How it works**: Your computer proves it has the right key without sending a password
- **Why you need it**: Much more secure than passwords, can't be guessed or stolen

**SSH Key Setup (Optional for now):**
```bash
# Generate SSH key pair (run this on your Windows computer)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id -p 10108 root@robert108.mikrus.xyz

# Test key-based login
ssh -p 10108 root@robert108.mikrus.xyz
```

**SSH Configuration:**
```bash
# Edit SSH configuration
nano /etc/ssh/sshd_config
```

**Update these settings:**
```bash
# Change SSH port (optional - you're already using custom port)
Port 10108

# Disable root login with password (enable key-based only)
PermitRootLogin prohibit-password

# Disable password authentication (after setting up keys)
PasswordAuthentication no

# Allow only specific users (if you create a non-root user)
AllowUsers root

# Limit login attempts
MaxAuthTries 3

# Set idle timeout
ClientAliveInterval 300
ClientAliveCountMax 2
```

**Restart SSH service:**
```bash
# Restart SSH service to apply changes
systemctl restart ssh

# Test SSH connection (in a new terminal)
ssh root@robert108.mikrus.xyz -p10108
```

### **3.3 Create Non-Root User (Recommended)**
```bash
# Create a new user
adduser viktar

# Add user to sudo group
usermod -aG sudo viktar

# Add user to docker group
usermod -aG docker viktar

# Test sudo access
su - viktar
sudo whoami
```

**Benefits of Non-Root User:**
- **Security**: Reduces risk of accidental system damage
- **Audit Trail**: Better logging of who did what
- **Best Practice**: Industry standard for server management

### **3.4 Configure Firewall (UFW) - Path-Based Routing Setup**

**Important: Mikrus VPS Port Strategy with Nginx Reverse Proxy**

Your Mikrus VPS uses a **path-based routing approach** with Nginx reverse proxy, which saves 4 ports and provides a more professional setup:

**Port Strategy:**
- **SSH**: Port `10108` (your custom SSH port)
- **Web Services**: Port `20108` (all web apps via Nginx proxy)
- **MQTT**: Port `40098` (IoT device communication)
- **HTTPS**: Port `30108` (for future SSL setup)

**URL Structure (current):**
```
http://robert108.mikrus.xyz:20108/grafana     -> Grafana Dashboard
http://robert108.mikrus.xyz:20108/nodered     -> Node-RED Editor  
http://robert108.mikrus.xyz:20108/influxdb    -> InfluxDB Admin
http://robert108.mikrus.xyz:20108/            -> Redirects to /grafana/
```

Note: Express Backend API (/api) and React Frontend (/app) are under development and not deployed yet.

**Firewall Configuration:**
```bash
# Enable UFW firewall
ufw enable

# Allow SSH (your custom port)
ufw allow 10108/tcp

# Allow HTTP web services (Nginx reverse proxy)
ufw allow 20108/tcp

# Allow HTTPS (for future SSL)
ufw allow 30108/tcp

# Allow MQTT (IoT device communication)
ufw allow 40098/tcp

# Check firewall status
ufw status numbered
```

**Expected Firewall Status Output:**
```bash
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22                         ALLOW IN    Anywhere
[ 2] 10108/tcp                  ALLOW IN    Anywhere
[ 3] 20108/tcp                  ALLOW IN    Anywhere
[ 4] 30108/tcp                  ALLOW IN    Anywhere
[ 5] 40098/tcp                  ALLOW IN    Anywhere
[ 6] 22 (v6)                    ALLOW IN    Anywhere (v6)
[ 7] 10108/tcp (v6)             ALLOW IN    Anywhere (v6)
[ 8] 20108/tcp (v6)             ALLOW IN    Anywhere (v6)
[ 9] 30108/tcp (v6)             ALLOW IN    Anywhere (v6)
[10] 40098/tcp (v6)             ALLOW IN    Anywhere (v6)
```

**📝 Notes on Your Firewall Configuration:**
- **Port 22**: Standard SSH port is also open (normal for Mikrus VPS)
- **Port 10108**: Your custom SSH port (primary access method)
- **Port 20108**: Nginx reverse proxy for all web services
- **Port 30108**: HTTPS port for future SSL setup
- **Port 40098**: MQTT broker for IoT device communication
- **IPv6 Support**: All ports are also open for IPv6 (modern networking)
- **Port Efficiency**: Only 4 ports needed instead of 8+ with separate ports

**Benefits of Path-Based Routing:**
1. **Port Efficiency**: Uses only 1 Mikrus port for all web services
2. **Professional URLs**: Clean, organized URL structure
3. **Better Security**: Single entry point for all web traffic
4. **SSL Ready**: Easy to add HTTPS for all services
5. **Scalable**: Easy to add new services

### **3.5 Configure Fail2ban**
```bash
# Configure Fail2ban for SSH protection
nano /etc/fail2ban/jail.local
```

**Add this configuration:**
```ini
[sshd]
enabled = true
port = 10108
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

**Start and enable Fail2ban:**
```bash
# Start Fail2ban service
systemctl start fail2ban
systemctl enable fail2ban

# Check Fail2ban status
fail2ban-client status
fail2ban-client status sshd
```

**What this means:** Fail2ban monitors login attempts and automatically blocks IP addresses that try to guess passwords too many times. It's like having a security guard that locks out suspicious visitors.

---

## Step 4 – System Optimization

#### **4.1 Configure Swap Memory**
```bash
# Check current swap
free -h

# Create swap file (if needed)
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # Make swap permanent
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Verify swap
free -h
```

**What this means:** Swap memory is like using your hard drive as extra RAM when your server runs out of memory. It's slower than real RAM but prevents your system from crashing.

#### **4.2 Optimize Kernel Parameters**
```bash
# Edit sysctl configuration
nano /etc/sysctl.conf
```

**Add these optimizations:**
```bash
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# File descriptor limits
fs.file-max = 2097152

# Memory management
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
```

**Apply changes:**
```bash
# Apply sysctl changes
sysctl -p
```

**What this means:** These settings optimize how your server handles network connections, file operations, and memory management. It's like tuning a car for better performance.

---

## Step 5 – Environment Variables Setup

#### **5.1 Create Environment File**
```bash
# Create environment file
nano .env
```

**Production Environment Configuration:**
```bash
# =============================================================================
# PRODUCTION ENVIRONMENT VARIABLES
# Renewable Energy IoT Monitoring System - Mikrus VPS
# =============================================================================

# Server Configuration
SERVER_IP=robert108.mikrus.xyz
SERVER_PORT=10108

# MQTT Configuration (Custom Port for Mikrus VPS)
MQTT_PORT=40098          # Custom port instead of 1883
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=admin_password_456

# InfluxDB Configuration (Custom Port for Mikrus VPS)
INFLUXDB_PORT=40100      # Custom port instead of 8086
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=admin_password_123
INFLUXDB_ADMIN_TOKEN=renewable_energy_admin_token_123
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=7d

# Node-RED Configuration (Custom Port for Mikrus VPS)
NODE_RED_PORT=40099      # Custom port instead of 1880
NODE_RED_USERNAME=admin
NODE_RED_PASSWORD=adminpassword
NODE_RED_OPTIONS=--max-old-space-size=256

# Grafana Configuration (Custom Port for Mikrus VPS)
GRAFANA_PORT=40101       # Custom port instead of 3000
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
GF_SERVER_ROOT_URL=http://robert108.mikrus.xyz:40101
GF_SERVER_MAX_CONCURRENT_REQUESTS=100
GF_SERVER_MAX_CONCURRENT_REQUESTS_PER_USER=10

# Web Application Configuration (Custom Port for Mikrus VPS)
EXPRESS_PORT=40102       # Custom port instead of 3001
REACT_APP_API_URL=http://robert108.mikrus.xyz:20113

# HTTP/HTTPS Configuration (Using Default Mikrus Ports)
HTTP_PORT=20108          # Default Mikrus HTTP port
HTTPS_PORT=30108         # Default Mikrus HTTPS port

# Nginx Reverse Proxy Configuration
NGINX_HTTP_PORT=20108    # Nginx HTTP port (Mikrus default)
NGINX_HTTPS_PORT=30108   # Nginx HTTPS port (Mikrus default)

# Network Configuration
DOCKER_NETWORK_NAME=iot-network
DOCKER_NETWORK_SUBNET=172.20.0.0/16

# Security Settings
SSL_ENABLED=false
API_RATE_LIMIT=1000
API_RATE_LIMIT_WINDOW=1m

# Performance Settings
HEALTH_CHECK_INTERVAL=30s
HEALTH_CHECK_TIMEOUT=10s
HEALTH_CHECK_RETRIES=3

# Logging Settings
LOG_LEVEL=info
LOG_MAX_SIZE=100m
LOG_MAX_FILES=5
```

**Environment Variables Explained:**
Think of environment variables like the settings on your phone:
- **Phone Settings**: Control how your phone behaves (brightness, volume, WiFi)
- **Environment Variables**: Control how your applications behave (database connection, passwords, URLs)

**Key Variables for Your IoT System:**

| Variable | Purpose | Value | Notes |
|----------|---------|-------|-------|
| **SERVER_IP** | Your server's address | robert108.mikrus.xyz | Your Mikrus hostname |
| **MQTT_PORT** | MQTT broker port | 40098 | IoT device communication |
| **NGINX_HTTP_PORT** | Web services port | 20108 | All web apps via proxy |
| **NGINX_HTTPS_PORT** | Secure web port | 30108 | Future SSL setup |
| **INFLUXDB_PORT** | Database port | 40100 | Data storage |
| **GRAFANA_PORT** | Dashboard port | 40101 | Data visualization |
| **EXPRESS_PORT** | Web app port | 40102 | Custom application |

**Path-Based Routing Benefits:**
- **Single Entry Point**: All web services accessible via port 20108
- **Professional URLs**: Clean, organized structure
- **Port Efficiency**: Saves 4 Mikrus ports
- **SSL Ready**: Easy to add HTTPS for all services
- **Scalable**: Easy to add new services

---

## Step 6 – Project Directory Structure

#### **6.1 Create Project Directory**
```bash
# Create project directory
mkdir -p /root/renewable-energy-iot
cd /root/renewable-energy-iot

# Create subdirectories
mkdir -p {mosquitto,influxdb,node-red,grafana,nginx,web-app-for-testing}/{config,data,logs}
```

**Directory Structure:**
```
/root/renewable-energy-iot/
├── docker-compose.yml          # Main deployment configuration
├── .env                        # Environment variables
├── mosquitto/                  # MQTT broker configuration
│   ├── config/                 # MQTT configuration files
│   ├── data/                   # MQTT data storage
│   └── logs/                   # MQTT log files
├── influxdb/                   # Time-series database
│   ├── config/                 # InfluxDB configuration
│   ├── data/                   # Database files
│   └── logs/                   # Database logs
├── node-red/                   # Data processing flows
│   ├── config/                 # Node-RED configuration
│   ├── data/                   # Flow data
│   └── logs/                   # Processing logs
├── grafana/                    # Data visualization
│   ├── config/                 # Grafana configuration
│   ├── data/                   # Dashboard data
│   └── logs/                   # Visualization logs
├── nginx/                      # Reverse proxy configuration
│   ├── nginx.conf              # Nginx configuration
│   └── ssl/                    # SSL certificates (future)
└── web-app-for-testing/        # Custom web application
    ├── backend/                # Express.js backend
    └── frontend/               # React frontend
```

**What this means:** This is like organizing your house into different rooms. Each service has its own space with its own files and settings.

---

## Step 7 – Validation and Testing

#### **7.1 Test Docker Installation**
```bash
# Test Docker
docker --version
docker-compose --version

# Test Docker functionality
docker run hello-world
```

#### **7.2 Test Network Connectivity**
```bash
# Test internet connectivity
ping -c 4 google.com

# Test DNS resolution
nslookup robert108.mikrus.xyz

# Check open ports
netstat -tlnp
```

#### **7.3 Test Firewall Configuration**
```bash
# Check firewall status
ufw status numbered

# Test port accessibility (from your local machine)
# Use nmap or telnet to test ports
```

#### **7.4 System Health Check**
```bash
# Check system resources
htop
df -h
free -h

# Check service status
systemctl status docker
systemctl status ssh
systemctl status fail2ban
```

---

## ✅ Phase 1 Completion Checklist

### **Server Setup**
- [ ] ✅ SSH connection established
- [ ] ✅ Root password changed
- [ ] ✅ System packages updated
- [ ] ✅ Essential tools installed
- [ ] ✅ Docker installed and configured

### **Security Configuration**
- [ ] ✅ SSH security configured
- [ ] ✅ Firewall (UFW) configured with path-based routing
- [ ] ✅ Fail2ban installed and configured
- [ ] ✅ Non-root user created (optional)

### **System Optimization**
- [ ] ✅ Swap memory configured
- [ ] ✅ Kernel parameters optimized
- [ ] ✅ System resources verified

### **Environment Setup**
- [ ] ✅ Environment variables configured
- [ ] ✅ Project directory structure created
- [ ] ✅ Path-based routing strategy implemented

### **Validation**
- [ ] ✅ Docker functionality tested
- [ ] ✅ Network connectivity verified
- [ ] ✅ Firewall configuration tested
- [ ] ✅ System health confirmed

---

## 🎯 Next Steps

### **Ready for Phase 2: Application Deployment**
Your VPS is now prepared for deploying the renewable energy IoT monitoring system. The next phase will cover:

1. **File Transfer**: Upload project files to VPS
2. **Docker Compose**: Deploy all services with path-based routing
3. **Service Configuration**: Configure each component
4. **Testing**: Verify all services are working
5. **Monitoring**: Set up health checks and logging

### **Access Your Services (After Deployment)**
Once deployed, you'll access your services at:

**🌐 Web Services (via Nginx Reverse Proxy):**
- **Grafana Dashboard**: `http://robert108.mikrus.xyz:20108/grafana`
- **Node-RED Editor**: `http://robert108.mikrus.xyz:20108/nodered`
- **InfluxDB Admin**: `http://robert108.mikrus.xyz:20108/influxdb`
- **Default Homepage** (redirects): `http://robert108.mikrus.xyz:20108/` → `/grafana/`

Planned (not yet deployed):
- Express Backend API at `/api`
- React Frontend at `/app`

**📡 IoT Services:**
- **MQTT Broker**: `robert108.mikrus.xyz:40098`

**🔑 Default Credentials:**
- **Grafana**: `admin` / `admin`
- **Node-RED**: `admin` / `adminpassword`
- **InfluxDB**: `admin` / `admin_password_123`
- **MQTT**: `admin` / `admin_password_456`

### **Development Workflow**
For local development, use the provided scripts:
```powershell
# Start local development
.\scripts\dev-local.ps1

# Prepare production deployment
.\scripts\deploy-production.ps1 -Prepare

# Full deployment to VPS
.\scripts\deploy-production.ps1 -Full
```

---

## 📚 Additional Resources

### **Useful Commands**
```bash
# Check system status
htop                    # System monitoring
df -h                   # Disk usage
free -h                 # Memory usage
systemctl status        # Service status

# Docker management
docker ps               # Running containers
docker logs [container] # Container logs
docker-compose logs     # All service logs

# Network troubleshooting
netstat -tlnp           # Open ports
ping [host]             # Network connectivity
nslookup [domain]       # DNS resolution
```

### **Security Best Practices**
- ✅ Change default passwords immediately
- ✅ Use SSH keys instead of passwords
- ✅ Keep system packages updated
- ✅ Monitor system logs regularly
- ✅ Use firewall to restrict access
- ✅ Enable fail2ban for intrusion prevention

### **Performance Optimization**
- ✅ Configure appropriate swap memory
- ✅ Optimize kernel parameters
- ✅ Monitor resource usage
- ✅ Use Docker resource limits
- ✅ Implement proper logging rotation

---

## 🆘 Troubleshooting

### **Common Issues**

**SSH Connection Problems:**
```bash
# Check SSH service status
systemctl status ssh

# Check SSH configuration
nano /etc/ssh/sshd_config

# Restart SSH service
systemctl restart ssh
```

**Docker Issues:**
```bash
# Check Docker service
systemctl status docker

# Restart Docker
systemctl restart docker

# Check Docker daemon logs
journalctl -u docker
```

**Firewall Problems:**
```bash
# Check UFW status
ufw status numbered

# Reset UFW (if needed)
ufw reset

# Reconfigure firewall
ufw enable
ufw allow 10108/tcp
ufw allow 20108/tcp
ufw allow 30108/tcp
ufw allow 40098/tcp
```

**Network Issues:**
```bash
# Check network interfaces
ip addr show

# Test connectivity
ping google.com

# Check DNS
nslookup robert108.mikrus.xyz
```

### **Getting Help**
- Check system logs: `journalctl -xe`
- Check service logs: `systemctl status [service]`
- Review configuration files
- Test connectivity step by step
- Consult Mikrus documentation

---

**🎉 Congratulations!** Your Mikrus VPS is now prepared for the renewable energy IoT monitoring system deployment. The path-based routing setup with Nginx reverse proxy provides a professional, efficient, and scalable solution that maximizes your Mikrus port usage.
