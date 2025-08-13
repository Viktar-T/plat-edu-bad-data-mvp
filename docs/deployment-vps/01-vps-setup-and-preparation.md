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

## 🚀 Step-by-Step Setup

## Step 1 – Initial Server Access

#### **1.1 Connect to Your VPS**
```bash
# Connect to your server (as viktar user)
ssh viktar@robert108.mikrus.xyz -p10108

# Connect to your server (as root user)
ssh root@robert108.mikrus.xyz -p10108

# Switch between users
su viktar

# First time connection (accept host key)
ssh -o StrictHostKeyChecking=no viktar@robert108.mikrus.xyz -p10108
```

**Expected Output:**
```
The authenticity of host '[robert108.mikrus.xyz]:10108' can't be established.
ED25519 key fingerprint is SHA256:gNoTnODLfmt4B0zsz5kfyrIEcKnRP839HNJh1L5L+is.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[robert108.mikrus.xyz]:10108' to the list of known hosts.
viktar@robert108.mikrus.xyz's password: [Enter your password]
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
viktar
/home/viktar
```

#### **1.3 Check System Resources**
```bash
# Check system information
free -h
df -h
cat /proc/cpuinfo | grep "model name" | head -1
```

**What this means:** You're checking how much memory, disk space, and what type of processor your server has. This helps you understand what your server can handle.

#### **1.4 Change User Password (Recommended)**
```bash
# Change the user password
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
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y

# Clean up package cache
sudo apt autoremove -y
sudo apt autoclean
```

**What this means:** You're updating your server's software to the latest versions, like updating apps on your phone. This includes security updates and bug fixes.

**Package Cache Cleanup Explained:**
- **`sudo apt autoremove -y`**: Removes packages that were automatically installed as dependencies but are no longer needed (like removing empty boxes after unpacking)
- **`sudo apt autoclean`**: Removes old package files from the cache directory to free up disk space (like clearing your browser cache)

#### **2.2 Install Essential Tools**
```bash
# Install essential packages
sudo apt install -y curl wget git htop nano vim ufw fail2ban
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
    sudo sh get-docker.sh
    
    # Add viktar user to docker group
    sudo usermod -aG docker viktar
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo "Docker installation completed!"
else
    echo "Docker is already installed!"
fi

# Verify Docker installation
docker --version

# Install Docker Compose (if not already installed)
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Verify Docker Compose installation
docker-compose --version
```

**Alternative Installation Method (if official script fails):**
```bash
# Install Docker using apt
sudo apt install -y docker.io docker-compose

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add viktar user to docker group
sudo usermod -aG docker viktar

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
ssh-copy-id -p 10108 viktar@robert108.mikrus.xyz

# Test key-based login
ssh -p 10108 viktar@robert108.mikrus.xyz
```

**SSH Configuration:**
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config
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
AllowUsers viktar

# Limit login attempts
MaxAuthTries 3

# Set idle timeout
ClientAliveInterval 300
ClientAliveCountMax 2
```

**Restart SSH service:**
```bash
# Restart SSH service to apply changes
sudo systemctl restart ssh

# Test SSH connection (in a new terminal)
ssh viktar@robert108.mikrus.xyz -p10108
```

### **3.3 Create Non-Root User (Already Done)**
```bash
# Verify current user and sudo access
whoami
sudo whoami

# Test sudo access
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
- **MQTT**: Port `1883` (IoT device communication)
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
# Allow rules first to avoid SSH lockout when enabling the firewall
# Allow SSH (your custom port)
sudo ufw allow 10108/tcp

# Allow HTTP web services (Nginx reverse proxy)
sudo ufw allow 20108/tcp

# Allow HTTPS (for future SSL)
sudo ufw allow 30108/tcp

# Allow MQTT (IoT device communication)
sudo ufw allow 1883/tcp

# Enable UFW firewall
sudo ufw enable

# Check firewall status
sudo ufw status numbered
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
[ 5] 1883/tcp                   ALLOW IN    Anywhere
[ 6] 22 (v6)                    ALLOW IN    Anywhere (v6)
[ 7] 10108/tcp (v6)             ALLOW IN    Anywhere (v6)
[ 8] 20108/tcp (v6)             ALLOW IN    Anywhere (v6)
[ 9] 30108/tcp (v6)             ALLOW IN    Anywhere (v6)
[10] 1883/tcp (v6)              ALLOW IN    Anywhere (v6)
```

**📝 Notes on Your Firewall Configuration:**
- **Port 22**: Standard SSH port is also open (normal for Mikrus VPS)
- **Port 10108**: Your custom SSH port (primary access method)
- **Port 20108**: Nginx reverse proxy for all web services
- **Port 30108**: HTTPS port for future SSL setup
- **Port 1883**: MQTT broker for IoT device communication
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
# First, ensure Fail2ban is properly installed and initialized
sudo apt install -y fail2ban

# Start and enable Fail2ban service (this creates necessary directories)
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Verify Fail2ban is running
sudo systemctl status fail2ban

# Now configure Fail2ban for SSH protection
sudo nano /etc/fail2ban/jail.local
```

**Add this configuration:**
```ini
[sshd]
enabled = true
port = 10108,22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

**Restart Fail2ban to apply configuration:**
```bash
# Restart Fail2ban to load new configuration
sudo systemctl restart fail2ban

# Check Fail2ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

**Alternative method if you get permission errors:**
```bash
# Check if fail2ban directory exists
sudo ls -la /etc/fail2ban/

# If directory doesn't exist, create it
sudo mkdir -p /etc/fail2ban

# Set proper permissions
sudo chown -R root:root /etc/fail2ban
sudo chmod 755 /etc/fail2ban

# Then try editing the configuration again
sudo nano /etc/fail2ban/jail.local
```

**What this means:** Fail2ban monitors login attempts and automatically blocks IP addresses that try to guess passwords too many times. It's like having a security guard that locks out suspicious visitors.

---

## Step 4 – System Optimization

#### **4.1 Configure Swap Memory**
```bash
# Check current swap
free -h

# Create swap file (if needed) - Single-line format (easier to copy-paste)
if [ ! -f /swapfile ]; then sudo fallocate -l 2G /swapfile; sudo chmod 600 /swapfile; sudo mkswap /swapfile; sudo swapon /swapfile; echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; fi

# Alternative: Multi-line format (easier to read)
# if [ ! -f /swapfile ]; then
#     sudo fallocate -l 2G /swapfile
#     sudo chmod 600 /swapfile
#     sudo mkswap /swapfile
#     sudo swapon /swapfile
#     echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
# fi

# Verify swap
free -h
```

**What this means:** Swap memory is like using your hard drive as extra RAM when your server runs out of memory. It's slower than real RAM but prevents your system from crashing.

#### **4.2 Optimize Kernel Parameters**
```bash
# Edit sysctl configuration
sudo nano /etc/sysctl.conf
```

**Add these optimizations:**
```bash
# Network optimizations (TCP buffers)
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Network security and ephemeral ports
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_syncookies = 1

# Note: Some parameters may be read-only or not available on all systems
# These will be applied if available, ignored if not:
fs.file-max = 2097152
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
```

**Apply changes:**
```bash
# Apply sysctl changes
sudo sysctl -p
```

**What this means:** These settings optimize how your server handles network connections, file operations, and memory management. It's like tuning a car for better performance.

**Kernel Parameter Optimizations Explained:**

**Network Optimizations:**
- **`net.ipv4.tcp_rmem = 4096 87380 16777216`**: TCP receive buffer sizes (min, default, max) - optimizes TCP connections
- **`net.ipv4.tcp_wmem = 4096 65536 16777216`**: TCP send buffer sizes (min, default, max) - optimizes TCP data sending
- **`net.ipv4.ip_local_port_range = 1024 65000`**: Wider ephemeral port range for many outbound connections
- **`net.ipv4.tcp_syncookies = 1`**: Enables SYN cookies to mitigate SYN flood attacks

**File System Optimizations:**
- **`fs.file-max = 2097152`**: Maximum number of open files (2 million) - prevents "too many open files" errors

**Memory Management Optimizations:**
- **`vm.swappiness = 10`**: How aggressively to use swap (0-100, lower = less swap usage) - keeps more data in RAM
- **`vm.dirty_ratio = 15`**: Percentage of memory that can be dirty before forcing writes - balances performance and data safety
- **`vm.dirty_background_ratio = 5`**: Percentage of memory that can be dirty before background writes start - prevents memory buildup

**Benefits for Your IoT System:**
- **Better Network Performance**: Handles multiple IoT device connections efficiently
- **Improved Data Processing**: Faster file operations for time-series data
- **Memory Efficiency**: Optimized RAM usage for database operations
- **System Stability**: Prevents common resource exhaustion issues

**Verify applied values (optional):**
```bash
sudo sysctl net.ipv4.tcp_rmem net.ipv4.tcp_wmem \
  net.ipv4.ip_local_port_range net.ipv4.tcp_syncookies
```

**Optional: Modern TCP congestion control (BBR)**
BBR can improve throughput and latency on many networks. Check support before enabling:
```bash
sysctl net.ipv4.tcp_available_congestion_control
lsmod | grep bbr || true
```
If `bbr` is available, you can add the following to `/etc/sysctl.conf` and re-apply:
```bash
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
```
Then verify:
```bash
sysctl net.ipv4.tcp_congestion_control
```

**Note on per-service limits:**
Some parameters like `fs.file-max`, `vm.swappiness`, etc. may be read-only on your system. If you encounter "too many open files" errors in services, you can raise per-process limits in Docker Compose:
```yaml
ulimits:
  nofile:
    soft: 1048576
    hard: 1048576
```

---



## Step 5 – Environment Variables Setup

**✅ Environment variables are handled automatically by your deployment scripts:**

- **Local Development**: `scripts/dev-local.ps1` creates `.env.local` from `env.example`
- **Production Deployment**: `scripts/deploy-production.ps1` uses `.env.production`

**No manual environment setup required!** Your scripts handle everything automatically.

---

## Step 6 – Validation and Testing

#### **6.1 Test Docker Installation**
```bash
# Test Docker
docker --version
docker-compose --version

# Test Docker functionality
docker run hello-world
```

#### **6.2 Test Network Connectivity**
```bash
# Test internet connectivity
ping -c 4 google.com

# Test DNS resolution
nslookup robert108.mikrus.xyz

# Check open ports
sudo netstat -tlnp
```

#### **6.3 Test Firewall Configuration**
```bash
# Check firewall status
sudo ufw status numbered

# Test port accessibility (from your local machine)
# Use nmap or telnet to test ports
```

#### **6.4 System Health Check**
```bash
# Check system resources
htop
df -h
free -h

# Check service status
sudo systemctl status docker
sudo systemctl status ssh
sudo systemctl status fail2ban
```

---

## ✅ Phase 1 Completion Checklist

### **Server Setup**
- [ ] ✅ SSH connection established
- [ ] ✅ User password changed
- [ ] ✅ System packages updated
- [ ] ✅ Essential tools installed
- [ ] ✅ Docker installed and configured

### **Security Configuration**
- [ ] ✅ SSH security configured
- [ ] ✅ Firewall (UFW) configured with path-based routing
- [ ] ✅ Fail2ban installed and configured
- [ ] ✅ Non-root user created and configured

### **System Optimization**
- [ ] ✅ Swap memory configured
- [ ] ✅ Kernel parameters optimized
- [ ] ✅ System resources verified

### **Environment Setup**
- [ ] ✅ Environment variables configured (handled automatically)
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
- **MQTT Broker**: `robert108.mikrus.xyz:1883`

**🔑 Default Credentials:**
- **Grafana**: `admin` / `admin`
- **Node-RED**: `admin` / `adminpassword`
- **InfluxDB**: `admin` / `admin_password_123`
- **MQTT**: `admin` / `admin_password_456`

**⚠️ Security Note:** Change these default passwords immediately after deployment!

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
sudo systemctl status   # Service status

# Docker management
docker ps               # Running containers
docker logs [container] # Container logs
docker-compose logs     # All service logs

# Network troubleshooting
sudo netstat -tlnp      # Open ports
ping [host]             # Network connectivity
nslookup [domain]       # DNS resolution
```

### **Security Best Practices**
- ✅ Change default passwords immediately after deployment
- ✅ Use SSH keys instead of passwords for better security
- ✅ Keep system packages updated regularly
- ✅ Monitor system logs for suspicious activity
- ✅ Use firewall to restrict access to necessary ports only
- ✅ Enable fail2ban for intrusion prevention
- ✅ Regularly backup configuration files and data

### **Performance Optimization**
- ✅ Configure appropriate swap memory for your workload
- ✅ Optimize kernel parameters for IoT data processing
- ✅ Monitor resource usage with htop and system tools
- ✅ Use Docker resource limits to prevent resource exhaustion
- ✅ Implement proper logging rotation to manage disk space
- ✅ Use time-series database best practices for InfluxDB

---

## 🆘 Troubleshooting

### **Common Issues**

**SSH Connection Problems:**
```bash
# Check SSH service status
sudo systemctl status ssh

# Check SSH configuration
sudo nano /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart ssh
```

**Docker Issues:**
```bash
# Check Docker service
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check Docker daemon logs
sudo journalctl -u docker
```

**Firewall Problems:**
```bash
# Check UFW status
sudo ufw status numbered

# Reset UFW (if needed)
sudo ufw reset

# Reconfigure firewall
sudo ufw enable
sudo ufw allow 10108/tcp
sudo ufw allow 20108/tcp
sudo ufw allow 30108/tcp
sudo ufw allow 1883/tcp
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
- Check system logs: `sudo journalctl -xe`
- Check service logs: `sudo systemctl status [service]`
- Review configuration files for syntax errors
- Test connectivity step by step
- Consult Mikrus documentation and support
- Check Docker container logs: `docker logs [container_name]`

---

**🎉 Congratulations!** Your Mikrus VPS is now prepared for the renewable energy IoT monitoring system deployment. The path-based routing setup with Nginx reverse proxy provides a professional, efficient, and scalable solution that maximizes your Mikrus port usage.

**📋 Summary of What You've Accomplished:**
- ✅ Secured SSH access with custom port and fail2ban protection
- ✅ Configured firewall with optimized port strategy
- ✅ Installed and configured Docker for containerized deployment
- ✅ Optimized system performance for IoT data processing
- ✅ Set up path-based routing for efficient port usage
- ✅ Prepared environment for automated deployment scripts

**🚀 You're now ready to proceed to Phase 2: Application Deployment!**
