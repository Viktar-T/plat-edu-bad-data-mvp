# 🚀 Phase 1: VPS Setup and Preparation

> **Complete server setup and preparation for renewable energy IoT monitoring system deployment on Mikrus VPS**

## 📋 Overview

This phase focuses on setting up your Mikrus VPS with proper security, Docker installation, and environment preparation. The setup is optimized for Mikrus servers running Ubuntu 24.04 LTS and includes Windows-specific instructions for connecting from your Windows PC.

### 🎯 What is a VPS?
A VPS (Virtual Private Server) is like having your own computer that runs on the internet. Think of it as renting a small part of a big computer that's always connected to the internet. You can install programs on it, store files, and access it from anywhere - just like your home computer, but it's always running and accessible from the internet.

### ✅ VPS Specifications (Mikrus 3.0)
- **RAM**: 2GB - Think of this as your computer's "working memory" - the more you have, the more things you can do at once
- **Storage**: 25GB SSD - This is like your computer's "hard drive" - where all your data and programs are stored
- **CPU**: 2 cores - These are like the "brains" of your computer - the more cores, the faster it can process information
- **Location**: Finland - Where your server is physically located (affects internet speed and data privacy laws)
- **Price**: 130.00zł/year - ZUT faktura
- **Network**: 1Gbps - How fast your server can send and receive data over the internet
- **Operating System**: Ubuntu 24.04 LTS - The latest LTS release of Ubuntu Linux

### 🏗️ Mikrus Server Features
- **Pre-installed Docker**: Docker and Docker Compose are already installed
- **Backup System**: Automatic daily backups included
- **Monitoring**: Built-in server monitoring tools
- **Control Panel**: Web-based control panel for easy management
- **DDoS Protection**: Basic DDoS protection included
- **IPv4/IPv6**: Dual stack networking support

---

## 🛠️ Prerequisites

### **Required Tools:**
- **Mikrus VPS account** - Your virtual server account (you need to buy this first)
- **SSH client for Windows** - A secure way to connect to your server from your Windows computer
  - **Windows Terminal** (recommended) - Built into Windows 10/11
  - **PuTTY** - Popular SSH client for Windows
  - **WSL (Windows Subsystem for Linux)** - Linux environment on Windows
- **Text editor** - VS Code with Remote SSH extension (recommended for Windows users)
- **File transfer tool** - To copy files between your Windows PC and the server
  - **WinSCP** - GUI file transfer tool
  - **FileZilla** - Cross-platform FTP client
  - **WSL** - Use Linux commands like `scp` and `rsync`
- **Basic Linux command line knowledge** - Knowing how to type commands to control your server
- **Git** - For downloading and managing your project files

### **What You Need to Know:**
- **RAM**: Random Access Memory - like your computer's "thinking space" where it stores information it's currently working with
- **Storage**: Where your files and programs are permanently stored (like your computer's hard drive)
- **CPU**: Central Processing Unit - the "brain" that does all the calculations and runs your programs
- **SSH**: Secure Shell - a secure way to connect to your server over the internet
- **Docker**: A system that packages your applications in "containers" (like shipping containers for software)

---

## 🚀 Step-by-Step Setup

## Step 1 – Initial Server Access

#### **1.1 Get Your Server Information**
After purchasing your Mikrus VPS, you'll receive:
- **Server IP address** - Like a phone number for your server (e.g., 192.168.1.100)
- **Username** - Usually `root` or `ubuntu`
- **Password** - Your login password
- **SSH port** - Usually 22 (the "door" number for SSH)

#### **1.2 Connect from Windows**

**Option A: Windows Terminal (Recommended)**
```powershell
# Open Windows Terminal and connect
ssh username@your-server-ip

# Example:
ssh root@192.168.1.100
```

**Option B: PuTTY**
1. Download PuTTY from https://www.putty.org/
2. Open PuTTY
3. Enter your server IP in "Host Name"
4. Set port to 22 (or your custom port)
5. Click "Open"
6. Enter your username and password when prompted

**Option C: WSL (Windows Subsystem for Linux)**
```bash
# Open WSL and connect
ssh username@your-server-ip

# Example:
ssh root@192.168.1.100
```

#### **1.3 Verify Connection**
Once connected, run these commands to check your server:

```bash
# Check system information
uname -a

# Check operating system
cat /etc/os-release

# Check available memory
free -h

# Check available storage
df -h

# Check CPU information
lscpu
```

**What these commands do:**
- `uname -a` - Shows what type of computer and operating system you're using
- `cat /etc/os-release` - Shows detailed information about your operating system
- `free -h` - Shows how much memory (RAM) your server has and how much is being used
- `df -h` - Shows how much storage space you have and how much is being used
- `lscpu` - Shows information about your CPU (the "brain" of your computer)

---

## Step 2 – System Updates and Basic Setup

#### **2.1 Update System Packages**
```bash
# Update package list
apt update

# Upgrade installed packages
apt upgrade -y

# Install essential tools
apt install -y curl wget git htop nano vim ufw fail2ban
```

**What these commands do:**
- `apt update` - Downloads the latest list of available software packages
- `apt upgrade -y` - Installs the latest versions of all your software
- `apt install -y` - Installs new software packages (the `-y` means "yes" to all questions)

#### **2.2 Check Docker Installation**
Since Mikrus servers come with Docker pre-installed:

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Check if Docker service is running
systemctl status docker
```

**What this means:** Docker is like a "container system" that packages your applications in isolated environments. It's already installed on Mikrus servers, so you don't need to install it yourself.

---

## Step 3 – Security Configuration

#### **3.1 Create Non-Root User**
```bash
# Create a new user (replace 'yourusername' with your preferred username)
adduser yourusername

# Add user to sudo group (gives administrative privileges)
usermod -aG sudo yourusername

# Switch to the new user
su - yourusername

# Test sudo access
sudo whoami
```

**What this means:** Running as "root" (the administrator) is like driving a car without a seatbelt - it's dangerous. Creating a regular user account is safer and follows security best practices.

#### **3.2 Configure SSH Security**
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config
```

**Add or modify these lines:**
```bash
# Change SSH port (optional but recommended)
Port 2222

# Disable root login
PermitRootLogin no

# Disable password authentication (use keys instead)
PasswordAuthentication no

# Enable public key authentication
PubkeyAuthentication yes
```

**What these settings do:**
- `Port 2222` - Changes the "door number" from the standard 22 to 2222 (makes it harder for hackers to find)
- `PermitRootLogin no` - Prevents logging in as the administrator (safer)
- `PasswordAuthentication no` - Disables password login (forces you to use SSH keys)
- `PubkeyAuthentication yes` - Enables SSH key authentication (more secure than passwords)

#### **3.3 Generate SSH Keys on Windows**

**Option A: Windows Terminal**
```powershell
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy public key to server
ssh-copy-id yourusername@your-server-ip
```

**Option B: PuTTYgen**
1. Download PuTTYgen from https://www.putty.org/
2. Generate a new key pair
3. Save the private key
4. Copy the public key to your server

#### **3.4 Configure Firewall (UFW)**
```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH (use your custom port if you changed it)
sudo ufw allow 2222/tcp

# Allow HTTP and HTTPS (for web applications)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check firewall status
sudo ufw status
```

**What this means:** A firewall is like a security guard that only allows authorized connections. UFW (Uncomplicated Firewall) is a simple firewall for Ubuntu.

#### **3.5 Configure Fail2ban**
```bash
# Install Fail2ban (if not already installed)
sudo apt install -y fail2ban

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local
```

**Add these settings:**
```bash
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
```

**What this means:** Fail2ban is like an automatic security guard that blocks suspicious activity. If someone tries to log in with the wrong password too many times, it automatically blocks them.

---

## Step 4 – Docker Configuration

#### **4.1 Optimize Docker for Mikrus VPS**
```bash
# Create Docker daemon configuration
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

**Add this configuration:**
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
  }
}
```

**What this configuration does:**
- `log-driver`: Controls how Docker stores log files
- `max-size`: Limits log file size to 10MB
- `max-file`: Keeps only 3 log files (prevents disk space issues)
- `storage-driver`: Uses the most efficient storage system
- `default-ulimits`: Increases file descriptor limits (prevents "too many open files" errors)

#### **4.2 Restart Docker Service**
```bash
# Restart Docker to apply new configuration
sudo systemctl restart docker

# Verify Docker is running
sudo systemctl status docker
```

---

## Step 5 – Environment Setup

#### **5.1 Create Project Directory**
```bash
# Create project directory
mkdir -p ~/renewable-energy-iot
cd ~/renewable-energy-iot

# Create subdirectories
mkdir -p {mosquitto,influxdb,node-red,grafana,web-app,scripts,backups}
```

**What this means:** This creates a folder structure on your server to organize all your project files. Think of it like creating folders on your Windows computer to organize your documents.

#### **5.2 Set Up Environment Variables**
```bash
# Create environment file
nano .env
```

**Add these variables:**
```bash
# Server Configuration
SERVER_IP=your-server-ip
SERVER_PORT=2222

# MQTT Configuration
MQTT_PORT=1883
MQTT_WS_PORT=9001
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=admin_password_456

# InfluxDB Configuration
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=admin_password_123
INFLUXDB_ADMIN_TOKEN=renewable_energy_admin_token_123
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=7d

# Node-RED Configuration
NODE_RED_USERNAME=admin
NODE_RED_PASSWORD=adminpassword
NODE_RED_OPTIONS=--max-old-space-size=256

# Grafana Configuration
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
GF_SERVER_ROOT_URL=http://your-server-ip:3000
GF_SERVER_MAX_CONCURRENT_REQUESTS=100
GF_SERVER_MAX_CONCURRENT_REQUESTS_PER_USER=10

# Web Application Configuration
REACT_APP_API_URL=http://your-server-ip:3001
```

**What this means:** Environment variables are like settings that tell your applications how to behave. They're stored in a file called `.env` and contain things like passwords, URLs, and configuration options.

---

## Step 6 – System Optimization

#### **6.1 Configure Swap Memory**
```bash
# Check current swap
free -h

# Create swap file (if needed)
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**What this means:** Swap memory is like using your hard drive as extra RAM when your computer runs out of memory. It's slower than real RAM but prevents your system from crashing.

#### **6.2 Optimize Kernel Parameters**
```bash
# Edit sysctl configuration
sudo nano /etc/sysctl.conf
```

**Add these optimizations:**
```bash
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# File descriptor limits
fs.file-max = 65536

# Memory management
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
```

**What this means:** These are like "tuning knobs" for your operating system that make it work better for your specific needs.

#### **6.3 Apply Changes**
```bash
# Apply kernel parameters
sudo sysctl -p

# Restart system to ensure all changes take effect
sudo reboot
```

---

## Step 7 – Monitoring Setup

#### **7.1 Install Monitoring Tools**
```bash
# Install monitoring tools
sudo apt install -y htop iotop nethogs

# Create monitoring script
nano ~/monitor.sh
```

**Create monitoring script:**
```bash
#!/bin/bash

echo "=== System Resource Monitor ==="
echo "Date: $(date)"
echo ""

echo "=== Memory Usage ==="
free -h
echo ""

echo "=== Disk Usage ==="
df -h
echo ""

echo "=== CPU Load ==="
uptime
echo ""

echo "=== Docker Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "=== Network Usage ==="
nethogs -t
echo ""

echo "=== Top Processes ==="
ps aux --sort=-%mem | head -10
```

**Make script executable:**
```bash
chmod +x ~/monitor.sh
```

**What this means:** This script is like a "health check" for your server. It shows you how much memory, disk space, and CPU your server is using, and whether all your applications are running properly.

---

## Step 8 – Testing and Validation

#### **8.1 Test Docker Functionality**
```bash
# Test Docker installation
docker run hello-world

# Test Docker Compose
docker-compose --version

# Check Docker system info
docker system info
```

#### **8.2 Test Network Connectivity**
```bash
# Test internet connectivity
ping -c 4 google.com

# Test DNS resolution
nslookup google.com

# Test port availability
netstat -tlnp
```

#### **8.3 Test Security Configuration**
```bash
# Test SSH configuration
sudo sshd -t

# Test firewall status
sudo ufw status verbose

# Test Fail2ban status
sudo fail2ban-client status
```

#### **8.4 Test Resource Monitoring**
```bash
# Run monitoring script
./monitor.sh

# Check system performance
htop
```

---

## Step 9 – Performance Baseline

#### **9.1 Establish Performance Baseline**
```bash
# Create performance baseline script
nano ~/performance-baseline.sh
```

**Create baseline script:**
```bash
#!/bin/bash

echo "=== Performance Baseline ==="
echo "Date: $(date)"
echo ""

echo "=== System Information ==="
echo "CPU: $(nproc) cores"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Storage: $(df -h / | tail -1 | awk '{print $2}')"
echo ""

echo "=== Current Performance ==="
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
echo ""

echo "=== Docker Performance ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
```

**Make script executable:**
```bash
chmod +x ~/performance-baseline.sh

# Run baseline
./performance-baseline.sh
```

#### **9.2 Expected Performance on Mikrus 3.0:**

| Metric | Expected Value | What This Means |
|--------|----------------|-----------------|
| **CPU Load** | < 0.5 | Your server should not be working too hard |
| **Memory Usage** | < 1GB | You should have plenty of memory left |
| **Disk Usage** | < 5GB | You should have plenty of storage space left |
| **Network** | 1Gbps | Your server has fast internet connection |
| **Docker Status** | All containers running | All your applications should be working |

---

## ⚠️ Troubleshooting

### **Common Issues and Solutions:**

#### **Issue 1: Docker Installation Failures**
```bash
# Symptoms: Docker commands not working
# Solution: Reinstall Docker
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install docker.io docker-compose
```

**What this means:** Sometimes Docker doesn't install properly. This command removes the old installation and installs it fresh.

#### **Issue 2: Memory Issues**
```bash
# Symptoms: System slow, out of memory errors
# Solution: Check memory usage and optimize
free -h
htop
# Consider reducing Docker memory limits
```

**What this means:** Your server is running out of memory. This can happen if you try to run too many applications at once.

#### **Issue 3: SSH Connection Issues**
```bash
# Symptoms: Can't connect to server
# Solution: Check SSH configuration
sudo systemctl status ssh
sudo journalctl -u ssh
```

**What this means:** You can't connect to your server from your Windows computer. This could be due to network issues or incorrect SSH settings.

#### **Issue 4: Firewall Blocking Connections**
```bash
# Symptoms: Can't access services
# Solution: Check firewall rules
sudo ufw status
sudo ufw allow [port-number]
```

**What this means:** Your firewall is blocking connections to your applications. You need to tell the firewall which "doors" to leave open.

---

## ✅ Completion Checklist

### **Phase 1 Completion Criteria:**

#### **✅ Server Access:**
- [ ] Successfully connected to Mikrus VPS via SSH from Windows - You can log into your server from your Windows computer
- [ ] Verified server specifications match Mikrus 3.0 - Your server has the right amount of RAM, CPU, and storage
- [ ] Confirmed Ubuntu 24.04 LTS installation - Your server is running the latest LTS version of Ubuntu

#### **✅ System Updates:**
- [ ] Updated all system packages - Your server has the latest security updates
- [ ] Installed essential tools (curl, wget, git, htop, nano, vim, ufw, fail2ban) - You have all the tools you need to manage your server
- [ ] Verified Docker and Docker Compose installation - Docker is working properly

#### **✅ Security Configuration:**
- [ ] Created non-root user account - You have a safe user account to work with
- [ ] Configured SSH security settings - Your server is protected from unauthorized access
- [ ] Generated and configured SSH keys - You can connect securely without passwords
- [ ] Enabled and configured UFW firewall - Your server has a security guard
- [ ] Installed and configured Fail2ban - Your server automatically blocks suspicious activity

#### **✅ Docker Optimization:**
- [ ] Optimized Docker daemon configuration - Docker is configured for your specific server
- [ ] Configured log rotation and storage limits - Docker won't fill up your disk space
- [ ] Set appropriate file descriptor limits - Docker can handle many connections
- [ ] Verified Docker service is running - Docker is ready to run your applications

#### **✅ Environment Setup:**
- [ ] Created project directory structure - You have organized folders for your project
- [ ] Configured environment variables - Your applications know how to behave
- [ ] Set up monitoring scripts - You can watch your server's performance
- [ ] Established performance baseline - You know how your server performs normally

#### **✅ System Optimization:**
- [ ] Configured swap memory (if needed) - Your server has extra memory when needed
- [ ] Optimized kernel parameters - Your server is tuned for performance
- [ ] Applied system optimizations - All changes are active
- [ ] Verified system stability - Your server is running smoothly

#### **✅ Testing and Validation:**
- [ ] Tested Docker functionality - Docker can run applications
- [ ] Verified network connectivity - Your server can connect to the internet
- [ ] Confirmed security configuration - Your server is secure
- [ ] Validated resource monitoring - You can watch your server's performance
- [ ] Established performance baseline - You have a reference point for performance

---

## 🤖 AI Prompts for Phase 1

### **When You Need Help:**

#### **For Server Setup Issues:**
```
I'm setting up a Mikrus VPS (Ubuntu 24.04, 2GB RAM, 25GB storage) for my renewable energy IoT monitoring system.
I'm connecting from Windows using [Windows Terminal/PuTTY/WSL].
I'm having trouble with [specific issue].
Please help me resolve this issue and continue with the setup.
```

#### **For Security Configuration:**
```
I need to secure my Mikrus VPS running Ubuntu 24.04.
I want to configure SSH keys, firewall (UFW), and Fail2ban.
I'm connecting from a Windows PC.
Please help me implement proper security measures for my IoT monitoring system.
```

#### **For Docker Optimization:**
```
I need to optimize Docker for my Mikrus VPS with 2GB RAM.
I want to configure resource limits, log rotation, and performance settings.
Please help me configure Docker for optimal performance on limited hardware.
```

#### **For Performance Issues:**
```
My Mikrus VPS (2GB RAM, 2 cores) is experiencing performance issues.
I need to optimize memory usage, CPU load, and disk space.
Please help me identify and resolve performance bottlenecks.
```

---

## 🎯 Next Steps

After completing Phase 1:

1. **Verify All Services**: Ensure Docker and all tools are working properly
2. **Test Connectivity**: Confirm you can connect from Windows consistently
3. **Document Settings**: Keep notes of your configuration for future reference
4. **Proceed to Phase 2**: Move on to application deployment
5. **Monitor Performance**: Use the monitoring scripts to watch your server

---

**✅ Phase 1 Complete! Your Mikrus VPS is now ready for application deployment.**

---

*This setup is optimized for Mikrus VPS servers with Ubuntu 24.04 LTS and Windows users connecting from a Windows PC environment.*

## Use in Cursor – Environment and connectivity validation
```text
You are helping me validate my setup for Mikrus (Ubuntu 24.04) from Windows PowerShell.
Goals:
- On Windows PowerShell, print versions: $PSVersionTable.PSVersion, git --version, docker --version, docker compose version.
- Test outbound SSH to <VPS_IP> on port 2222: Test-NetConnection -ComputerName <VPS_IP> -Port 2222.
- Generate commands to create an SSH config entry named "mikrus" using $HOME\ .ssh\ id_rsa and port 2222.
- Provide remote bash checks to verify OS, memory, disk, CPU and Docker service on VPS.
- For each command, show expected output and what to do if the check fails.
Deliver results grouped by: Windows PowerShell vs Remote VPS bash.
```
