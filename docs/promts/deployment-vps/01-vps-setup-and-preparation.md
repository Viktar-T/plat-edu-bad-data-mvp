# 🚀 Phase 1: VPS Setup and Preparation

> **Complete server setup and preparation for renewable energy IoT monitoring system deployment on Mikrus 3.0 VPS**

## 📋 Overview

This phase covers the initial VPS setup, security configuration, and environment preparation for deploying your renewable energy IoT monitoring system on Mikrus 3.0 VPS.

**What is a VPS?** A VPS (Virtual Private Server) is like having your own computer that runs on the internet. It's not physically in your house, but you can control it from anywhere. Think of it like renting a room in a big building - you have your own space, but the building is shared with others.

### 🎯 Objectives
- ✅ Set up secure VPS environment
- ✅ Install and configure Docker
- ✅ Configure firewall and security
- ✅ Prepare environment variables
- ✅ Test basic connectivity

---

## 🔧 Prerequisites

### ✅ VPS Specifications (Mikrus 3.0)
- **RAM**: 2GB - Think of this as your computer's "working memory" - the more you have, the more things you can do at once
- **Storage**: 25GB SSD - This is like your computer's "hard drive" - where all your data and programs are stored
- **CPU**: 2 cores - These are like the "brains" of your computer - the more cores, the faster it can process information
- **Location**: Finland - Where your server is physically located (affects internet speed and data privacy laws)
- **Price**: 130.00zł/year - ZUT faktura

### ✅ Required Tools
- SSH client (PuTTY, OpenSSH, or terminal) - This is like a "remote control" for your server. It lets you connect to your server from your computer
- Text editor (VS Code with Remote SSH) - A program to edit files on your server (like a digital notepad)
- Git (for code deployment) - A tool that helps you manage and transfer your code files

---

## 🛠️ Step-by-Step Instructions

### **Step 1: Initial Server Access**

#### 1.1 Connect to VPS
```bash
# Connect via SSH (replace with your actual IP and credentials)
ssh root@YOUR_VPS_IP_ADDRESS

# Verify system information
uname -a
cat /etc/os-release
free -h
df -h
```

**What these commands do:**
- `ssh root@YOUR_VPS_IP_ADDRESS` - This connects you to your server (like dialing a phone number)
- `uname -a` - Shows you what operating system your server is running
- `cat /etc/os-release` - Shows detailed information about your server's operating system
- `free -h` - Shows how much memory (RAM) your server has and how much is being used
- `df -h` - Shows how much storage space your server has and how much is being used

#### 1.2 Update System
```bash
# Update package lists
apt update && apt upgrade -y

# Install essential tools
apt install -y curl wget git nano htop ufw fail2ban
```

**What these commands do:**
- `apt update` - Downloads a list of available software updates (like checking for app updates on your phone)
- `apt upgrade -y` - Installs the updates automatically (the `-y` means "yes, do it without asking")
- `apt install -y curl wget git nano htop ufw fail2ban` - Installs useful tools:
  - `curl` and `wget` - Tools to download files from the internet
  - `git` - A tool to manage and transfer code files
  - `nano` - A simple text editor (like Notepad)
  - `htop` - A tool to monitor your server's performance (like Task Manager on Windows)
  - `ufw` - A firewall (like a security guard for your server)
  - `fail2ban` - A tool that blocks suspicious activity (like an automatic security system)

### **Step 2: Security Configuration**

#### 2.1 Create Non-Root User
```bash
# Create new user
adduser iotadmin
usermod -aG sudo iotadmin

# Switch to new user
su - iotadmin
```

**What this does:**
- `adduser iotadmin` - Creates a new user account called "iotadmin" (like creating a new user account on your computer)
- `usermod -aG sudo iotadmin` - Gives this user permission to run administrative commands (like making someone an administrator)
- `su - iotadmin` - Switches to the new user account (like logging out and logging back in as a different user)

**Why we do this:** Running as "root" (the main administrator) is dangerous because if someone hacks your account, they have full control. Creating a separate user is safer.

#### 2.2 Configure SSH Security
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Add/modify these lines:
Port 2222                    # Change default port
PermitRootLogin no           # Disable root login
PasswordAuthentication no     # Disable password auth
PubkeyAuthentication yes     # Enable key auth
```

**What these settings do:**
- `Port 2222` - Changes the "door" that SSH uses from the standard port 22 to port 2222 (makes it harder for hackers to find)
- `PermitRootLogin no` - Prevents anyone from logging in as the main administrator (safer)
- `PasswordAuthentication no` - Disables password login (passwords can be guessed, keys are much more secure)
- `PubkeyAuthentication yes` - Enables key-based authentication (like using a special key instead of a password)

#### 2.3 Set Up SSH Keys
```bash
# On your local machine, generate SSH key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id -i ~/.ssh/id_rsa.pub iotadmin@YOUR_VPS_IP_ADDRESS -p 2222
```

**What this does:**
- `ssh-keygen` - Creates a special "key" that's much more secure than a password (like creating a special key for your house)
- `ssh-copy-id` - Copies your public key to the server (like giving the server a copy of your key so it knows you're authorized)

#### 2.4 Configure Firewall
```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 2222/tcp

# Allow HTTP/HTTPS (for web interfaces)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow MQTT ports
sudo ufw allow 1883/tcp
sudo ufw allow 9001/tcp

# Allow application ports
sudo ufw allow 3000/tcp    # Grafana
sudo ufw allow 1880/tcp    # Node-RED
sudo ufw allow 8086/tcp    # InfluxDB
sudo ufw allow 3001/tcp    # Express Backend

# Check firewall status
sudo ufw status verbose
```

**What this does:**
- `ufw enable` - Turns on the firewall (like turning on a security system)
- `ufw allow [port]/tcp` - Opens specific "doors" in the firewall for your applications to work
- `ufw status verbose` - Shows you what doors are open and closed

**Why we do this:** A firewall is like a security guard that only allows authorized traffic. Without it, anyone on the internet could try to access your server.

#### 2.5 Install Fail2ban
```bash
# Configure fail2ban
sudo nano /etc/fail2ban/jail.local

# Add this configuration:
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 3
```

**What this does:**
- `fail2ban` is like an automatic security system that watches for suspicious activity
- If someone tries to log in incorrectly 3 times in 10 minutes, they get blocked for 1 hour
- This prevents hackers from trying to guess passwords

### **Step 3: Docker Installation**

#### 3.1 Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker iotadmin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker-compose --version
```

**What Docker is:** Docker is like a "container" system. Instead of installing programs directly on your server, you put them in "containers" that are isolated from each other. Think of it like putting each program in its own box - if one program has a problem, it doesn't affect the others.

**What these commands do:**
- `curl -fsSL https://get.docker.com -o get-docker.sh` - Downloads the Docker installation script
- `sudo sh get-docker.sh` - Runs the installation script
- `sudo usermod -aG docker iotadmin` - Gives your user permission to use Docker
- `sudo systemctl start docker` - Starts the Docker service
- `sudo systemctl enable docker` - Makes Docker start automatically when the server boots
- `docker --version` and `docker-compose --version` - Checks if Docker was installed correctly

#### 3.2 Configure Docker
```bash
# Create Docker daemon configuration
sudo nano /etc/docker/daemon.json

# Add optimization settings for limited resources:
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

# Restart Docker
sudo systemctl restart docker
```

**What this configuration does:**
- `log-driver` and `log-opts` - Limits how much disk space Docker logs can use (prevents logs from filling up your storage)
- `storage-driver` - Uses a more efficient way to store Docker data
- `default-ulimits` - Increases the number of files Docker can open at once (prevents errors)

### **Step 4: Environment Setup**

#### 4.1 Create Project Directory
```bash
# Create project directory
mkdir -p /home/iotadmin/renewable-energy-iot
cd /home/iotadmin/renewable-energy-iot

# Create subdirectories
mkdir -p {mosquitto,influxdb,node-red,grafana,web-app}
```

**What this does:**
- `mkdir -p` - Creates directories (folders) for your project
- `cd` - Changes to the project directory (like opening a folder on your computer)
- The subdirectories are where you'll store different parts of your system:
  - `mosquitto` - For your MQTT broker (the "post office")
  - `influxdb` - For your database (the "filing cabinet")
  - `node-red` - For your data processing (the "digital plumber")
  - `grafana` - For your dashboards (the "digital artist")
  - `web-app` - For your custom website

#### 4.2 Set Up Environment Variables
```bash
# Create environment file
nano .env

# Add your environment variables:
# MQTT Configuration
MQTT_PORT=1883
MQTT_WS_PORT=9001
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=secure_mqtt_password_123

# InfluxDB Configuration
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=secure_influxdb_password_123
INFLUXDB_ADMIN_TOKEN=renewable_energy_admin_token_456
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=7d

# Grafana Configuration
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=secure_grafana_password_123

# Node-RED Configuration
NODE_RED_USERNAME=admin
NODE_RED_PASSWORD=secure_nodered_password_123

# System Configuration
TZ=Europe/Helsinki
```

**What environment variables are:** Environment variables are like "settings" that your applications need to work properly. Think of them like the settings on your phone - they tell your apps how to behave.

**What each setting does:**
- **MQTT settings** - Tell your "post office" (MQTT broker) how to work
- **InfluxDB settings** - Tell your "filing cabinet" (database) how to store data
- **Grafana settings** - Tell your "digital artist" (dashboard) how to log in
- **Node-RED settings** - Tell your "digital plumber" (data processor) how to log in
- **System settings** - Tell your server what time zone to use

#### 4.3 Create Docker Compose File
```bash
# Copy your existing docker-compose.yml
# (You'll need to transfer this from your local machine)
```

### **Step 5: System Optimization**

#### 5.1 Configure Swap (if needed)
```bash
# Check current swap
free -h

# Create swap file if needed
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**What swap is:** Swap is like "virtual memory" - when your server runs out of real memory (RAM), it can use part of the hard drive as extra memory. Think of it like using a notebook when you run out of space in your main notebook.

**What these commands do:**
- `free -h` - Shows you how much memory you have and if you need swap
- `fallocate -l 1G /swapfile` - Creates a 1GB file on your hard drive to use as extra memory
- `chmod 600 /swapfile` - Makes the swap file secure (only the system can read it)
- `mkswap /swapfile` - Prepares the file to be used as swap memory
- `swapon /swapfile` - Turns on the swap memory
- The last command makes swap permanent (so it's still there after you restart the server)

#### 5.2 Optimize System Settings
```bash
# Edit sysctl configuration
sudo nano /etc/sysctl.conf

# Add these optimizations:
# Increase file descriptor limits
fs.file-max = 65536

# Optimize network settings
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000

# Optimize memory settings
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# Apply changes
sudo sysctl -p
```

**What sysctl is:** Sysctl is like the "control panel" for your server's operating system. These settings control how your server behaves - like the settings on your phone that control battery life, performance, etc.

**What these optimizations do:**
- `fs.file-max = 65536` - Allows your server to open more files at once (useful for databases)
- `net.core.somaxconn = 65535` - Allows more network connections (useful for web servers)
- `net.core.netdev_max_backlog = 5000` - Handles network traffic better
- `vm.swappiness = 10` - Makes your server use swap memory less aggressively
- `vm.dirty_ratio = 15` and `vm.dirty_background_ratio = 5` - Controls how often your server saves data to disk (better performance)

### **Step 6: Monitoring Setup**

#### 6.1 Install Monitoring Tools
```bash
# Install htop for process monitoring
sudo apt install -y htop iotop nethogs

# Create monitoring script
nano /home/iotadmin/monitor.sh
```

**What monitoring tools are:** Monitoring tools are like "dashboards" for your server - they show you what's happening inside your server, like how much memory is being used, which programs are running, etc.

**What these tools do:**
- `htop` - Shows you which programs are running and how much resources they're using (like Task Manager on Windows)
- `iotop` - Shows you which programs are reading/writing to the hard drive
- `nethogs` - Shows you which programs are using the internet

#### 6.2 Create Monitoring Script
```bash
#!/bin/bash
# Add to monitor.sh:

echo "=== System Resources ==="
echo "Memory Usage:"
free -h

echo -e "\nDisk Usage:"
df -h

echo -e "\nDocker Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\nTop Processes:"
ps aux --sort=-%mem | head -10
```

```bash
# Make script executable
chmod +x /home/iotadmin/monitor.sh
```

**What this script does:** This script is like a "health check" for your server. It shows you:
- How much memory is being used
- How much disk space is being used
- Which Docker containers are running
- Which programs are using the most memory

**What each command does:**
- `free -h` - Shows memory usage in a human-readable format
- `df -h` - Shows disk usage in a human-readable format
- `docker ps` - Shows which Docker containers are running
- `ps aux --sort=-%mem | head -10` - Shows the 10 programs using the most memory

---

## 🧪 Testing and Validation

### **Test 1: Docker Functionality**
```bash
# Test Docker installation
docker run hello-world

# Test Docker Compose
docker-compose --version
```

**What these tests do:**
- `docker run hello-world` - Tests if Docker is working by running a simple test program
- `docker-compose --version` - Checks if Docker Compose is installed (this is the tool that will run all your applications together)

### **Test 2: Network Connectivity**
```bash
# Test external connectivity
ping -c 3 google.com

# Test DNS resolution
nslookup github.com
```

**What these tests do:**
- `ping -c 3 google.com` - Tests if your server can connect to the internet (like testing if your phone can make calls)
- `nslookup github.com` - Tests if your server can find websites by their names (like testing if your phone can find websites)

### **Test 3: Security Configuration**
```bash
# Test SSH connection with new port
ssh -p 2222 iotadmin@YOUR_VPS_IP_ADDRESS

# Test firewall
sudo ufw status
```

**What these tests do:**
- `ssh -p 2222 iotadmin@YOUR_VPS_IP_ADDRESS` - Tests if you can still connect to your server with the new security settings
- `sudo ufw status` - Shows you what doors are open/closed in your firewall (security guard)

### **Test 4: Resource Monitoring**
```bash
# Run monitoring script
./monitor.sh

# Check system load
uptime
```

**What these tests do:**
- `./monitor.sh` - Runs your monitoring script to see how your server is performing
- `uptime` - Shows you how long your server has been running and how busy it is

---

## 📊 Performance Baseline

### **Expected Performance on Mikrus 3.0:**

| Metric | Expected Value | Monitoring Command | What This Means |
|--------|----------------|-------------------|-----------------|
| **Memory Usage** | < 1.5GB total | `free -h` | Your server should use less than 1.5GB of memory |
| **Disk Usage** | < 15GB total | `df -h` | Your server should use less than 15GB of storage |
| **CPU Load** | < 70% average | `uptime` | Your server should not be working too hard |
| **Docker Containers** | 5-6 running | `docker ps` | You should have 5-6 applications running |
| **Network** | Stable connection | `ping` | Your server should have a stable internet connection |

---

## ⚠️ Troubleshooting

### **Common Issues:**

#### **Issue 1: Docker Installation Fails**
```bash
# Solution: Manual Docker installation
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

**What this does:** If the automatic Docker installation doesn't work, this manually installs Docker using the official method. It's like manually installing an app on your phone when the automatic installation fails.

#### **Issue 2: Memory Issues**
```bash
# Solution: Optimize memory usage
# Add swap file (see Step 5.1)
# Reduce Docker memory limits in docker-compose.yml
```

**What this means:** If your server runs out of memory, you can:
1. Add swap memory (like using a notebook when you run out of space in your main notebook)
2. Reduce how much memory each application is allowed to use

#### **Issue 3: SSH Connection Issues**
```bash
# Solution: Check SSH configuration
sudo systemctl status ssh
sudo journalctl -u ssh -f
```

**What this does:** If you can't connect to your server, these commands help you figure out what's wrong:
- `sudo systemctl status ssh` - Shows if the SSH service is running
- `sudo journalctl -u ssh -f` - Shows the SSH service logs (like reading the diary of your SSH connection)

---

## ✅ Phase 1 Completion Checklist

- [ ] **VPS accessed and updated** - You can connect to your server and it has the latest security updates
- [ ] **Non-root user created** - You have a safe user account (not the main administrator account)
- [ ] **SSH security configured** - Your server is protected with secure login methods
- [ ] **Firewall configured** - Your server has a security guard that only allows authorized connections
- [ ] **Docker installed and configured** - The container system is ready to run your applications
- [ ] **Environment variables set** - Your applications have the settings they need to work properly
- [ ] **System optimized** - Your server is tuned for the best performance
- [ ] **Monitoring tools installed** - You have tools to watch how your server is performing
- [ ] **All tests passed** - Everything is working correctly
- [ ] **Performance baseline established** - You know how your server should perform normally

---

## 🎯 Next Steps

After completing Phase 1, proceed to:
- **[Phase 2: Application Deployment](./02-application-deployment.md)**
- **[Phase 3: Data Migration and Testing](./03-data-migration-testing.md)**
- **[Phase 4: Production Optimization](./04-production-optimization.md)**

---

## 🤖 AI Prompts for This Phase

**What are AI prompts?** These are questions you can ask AI (like ChatGPT or Claude) to get help with specific problems. Copy and paste these prompts when you need help with this phase.

### **Prompt 1: VPS Security Audit**
```
I need to audit the security configuration of my Mikrus 3.0 VPS running Ubuntu. 
Please check my SSH configuration, firewall rules, and user permissions. 
Current setup: non-root user 'iotadmin', SSH on port 2222, UFW firewall enabled.
Provide recommendations for additional security measures.
```

**When to use this:** If you want to make sure your server is secure or if you're having security problems.

### **Prompt 2: Docker Optimization**
```
I'm deploying a renewable energy IoT monitoring system on a VPS with 2GB RAM and 25GB storage.
Components: MQTT broker, InfluxDB 2.7, Node-RED, Grafana, Express backend, React frontend.
Please help optimize Docker daemon settings and container resource limits for this hardware.
```

**When to use this:** If Docker is running slowly or using too much memory.

### **Prompt 3: System Monitoring**
```
I need to set up comprehensive monitoring for my VPS running Docker containers.
Requirements: monitor CPU, memory, disk usage, Docker container health, and network connectivity.
Please provide a monitoring script and alerting configuration for a 2GB RAM VPS.
```

**When to use this:** If you want to set up better monitoring tools or if your current monitoring isn't working well.

---

**🎉 Phase 1 Complete! Your VPS is now ready for application deployment.**
