# 🚀 Phase 1: VPS Setup and Preparation

> **Complete server setup and preparation for renewable energy IoT monitoring system deployment on Mikrus VPS**

## 📋 Overview

This phase focuses on setting up your Mikrus VPS with proper security, Docker installation, and environment preparation. The setup is optimized for Mikrus servers running Ubuntu 24.04 LTS and includes Windows-specific instructions for connecting from your Windows PC.

### 🎯 What is a VPS?
A VPS (Virtual Private Server) is like having your own computer that runs on the internet. Think of it as renting a small part of a big computer that's always connected to the internet. You can install programs on it, store files, and access it from anywhere - just like your home computer, but it's always running and accessible from the internet.

**Think of it like this:**
- **Your home computer** = A house you own (you control everything, but it's only available when you're home)
- **A VPS** = An apartment you rent in a building (you control your space, it's always available, and you can access it from anywhere)
- **The internet** = The city where your apartment is located (everyone can reach it if they know the address)

**Why use a VPS instead of your home computer?**
- **Always On**: Your VPS never sleeps - it runs 24/7
- **Always Accessible**: You can reach it from anywhere in the world
- **No Power Bills**: You don't pay for electricity to keep it running
- **Professional Setup**: It's designed for running web services and applications
- **Backup & Security**: The hosting company handles basic infrastructure security

### ✅ VPS Specifications (Mikrus 3.0)
- **RAM**: 2GB - Think of this as your computer's "working memory" - the more you have, the more things you can do at once
- **Storage**: 25GB SSD - This is like your computer's "hard drive" - where all your data and programs are stored
- **CPU**: 2 cores - These are like the "brains" of your computer - the more cores, the faster it can process information
- **Location**: Finland - Where your server is physically located (affects internet speed and data privacy laws)
- **Price**: 130.00zł/year - ZUT faktura
- **Network**: 1Gbps - How fast your server can send and receive data over the internet
- **Operating System**: Ubuntu 24.04 LTS - The latest LTS release of Ubuntu Linux

**What do these specifications mean for your project?**

| Component | What It Does | For Your IoT System |
|-----------|-------------|-------------------|
| **2GB RAM** | Temporary storage for running programs | Can handle multiple services (MQTT, database, web apps) simultaneously |
| **25GB Storage** | Permanent storage for files and data | Plenty of space for your application, logs, and data storage |
| **2 CPU Cores** | Processing power for calculations | Can run your monitoring system and handle data processing |
| **1Gbps Network** | Internet connection speed | Fast enough to handle real-time data from multiple IoT devices |
| **Finland Location** | Server's physical location | Good for European users, follows EU data protection laws |

**Is this enough for your project?**
✅ **Yes!** This configuration is perfect for a renewable energy IoT monitoring system. You can run:
- MQTT broker (for device communication)
- Database (for storing sensor data)
- Web applications (for viewing dashboards)
- Data processing tools

### 🏗️ Mikrus Server Features
- **Docker Ready**: Docker can be easily installed (not pre-installed)
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

**Essential Concepts for Beginners:**

| Concept | Simple Explanation | Real-World Analogy |
|---------|-------------------|-------------------|
| **SSH** | A secure "tunnel" to connect to your server | Like a secure phone call to your server - only you can hear what's being said |
| **Docker** | A way to package applications in isolated "boxes" | Like shipping containers - each application runs in its own container, separate from others |
| **Port** | A "door number" for different services | Like apartment numbers - SSH uses door 10108, web services use door 80, etc. |
| **Firewall** | A security guard that controls who can access your server | Like a bouncer at a club - only allows authorized people in |
| **Root User** | The administrator account with full control | Like being the owner of a building - you can do anything, but it's dangerous if misused |

---

## 🚀 Step-by-Step Setup

## Step 1 – Initial Server Access

#### **1.1 Get Your Server Information**
After purchasing your Mikrus VPS, you'll receive:
- **Server IP address** - Like a phone number for your server (e.g., 192.168.1.100)
- **Username** - Usually `root` or `ubuntu`
- **Password** - Your login password
- **SSH port** - Usually 22 (the "door" number for SSH)

**Understanding Server Addresses:**
- **IP Address**: Like a street address for your server (e.g., 192.168.1.100)
- **Hostname**: Like a friendly name for your server (e.g., robert108.mikrus.xyz)
- **Port**: Like a specific door number in a building (e.g., 10108 for SSH)
- **Username**: Like your name badge to enter the building
- **Password**: Like your secret code to unlock the door

**Think of it like visiting a building:**
- **Hostname** = Building name (robert108.mikrus.xyz)
- **Port** = Door number (10108)
- **Username** = Your name badge (root)
- **Password** = Your access code

**Your Specific Server Details:**
- **Server Hostname**: `robert108.mikrus.xyz`
- **Username**: `root`
- **SSH Port**: `10108` (custom port)
- **Connection Command**: `ssh root@robert108.mikrus.xyz -p10108`

#### **1.2 Connect from Windows**

**Option A: Windows Terminal (Recommended)**
```powershell
# Open Windows Terminal and connect
ssh username@your-server-ip

# Example:
ssh root@192.168.1.100

# Your specific connection:
ssh root@robert108.mikrus.xyz -p10108
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

# Your specific connection:
ssh root@robert108.mikrus.xyz -p10108
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

#### **1.4 Change Root Password (Recommended)**
After your first login, it's highly recommended to change the default root password:

```bash
# Change root password
passwd
```

**What happens when you run this command:**
1. You'll be prompted to enter your new password

**What these commands do:**
- `uname -a` - Shows what type of computer and operating system you're using
- `cat /etc/os-release` - Shows detailed information about your operating system
- `free -h` - Shows how much memory (RAM) your server has and how much is being used
- `df -h` - Shows how much storage space you have and how much is being used
- `lscpu` - Shows information about your CPU (the "brain" of your computer)

**Understanding the Output:**

| Command | What You'll See | What It Means |
|---------|----------------|---------------|
| `uname -a` | Linux robert108 5.15.0... | Your server is running Linux with kernel version 5.15 |
| `cat /etc/os-release` | Ubuntu 24.04.1 LTS | You're running Ubuntu 24.04 (latest stable version) |
| `free -h` | Mem: 2.0Gi total, 1.2Gi used | You have 2GB RAM, 1.2GB is currently being used |
| `df -h` | /dev/sda1 25G 5.2G 18G 23% | You have 25GB storage, 5.2GB used, 18GB free |
| `lscpu` | CPU(s): 2, Model: Intel... | You have 2 CPU cores |

**What to look for:**
- ✅ **RAM**: Should show around 2GB total
- ✅ **Storage**: Should show around 25GB total
- ✅ **CPU**: Should show 2 cores
- ✅ **OS**: Should show Ubuntu 24.04

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

**What each tool does:**

| Tool | Purpose | Why You Need It |
|------|---------|-----------------|
| **curl** | Downloads files from the internet | Download scripts, check web services, test APIs |
| **wget** | Another tool to download files | Alternative to curl, good for downloading large files |
| **git** | Version control system | Download and manage your project code from GitHub |
| **htop** | Interactive process viewer | Monitor CPU, memory usage, and running processes in real-time |
| **nano** | Simple text editor | Edit configuration files easily (beginner-friendly) |
| **vim** | Advanced text editor | More powerful editor for complex file editing |
| **ufw** | Uncomplicated Firewall | Simple firewall to protect your server from unauthorized access |
| **fail2ban** | Intrusion prevention | Automatically blocks IP addresses that try to hack your server |

**The `-y` flag:** This automatically answers "yes" to all installation prompts, so you don't have to manually confirm each package installation.

#### **2.2 Check Docker Installation**
Let's check if Docker is installed on your Mikrus server:

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Check if Docker service is running
systemctl status docker
```

**If Docker is not installed, you'll see:**
```
Command 'docker' not found, but can be installed with:
snap install docker         # version 28.1.1+1, or
apt  install docker.io      # version 26.1.3-0ubuntu1~24.04.1
apt  install podman-docker  # version 4.9.3+ds1-1ubuntu0.2
```

**What this means:** Docker is like a "container system" that packages your applications in isolated environments. If it's not installed, we'll need to install it.

**Docker Explained Simply:**
Think of Docker like a shipping container system for software:
- **Traditional Installation**: Like building a house directly on the ground - it's tied to that specific location
- **Docker Container**: Like putting a house in a shipping container - you can move it anywhere and it works the same way

**Benefits of Docker:**
- **Consistency**: Your application runs the same way on any server
- **Isolation**: Each application runs in its own "container" - they don't interfere with each other
- **Easy Management**: Start, stop, and update applications with simple commands
- **Resource Efficiency**: Multiple applications can share the same server efficiently

**For Your IoT Project:**
Docker will help you run:
- MQTT broker (for device communication)
- Database (for storing sensor data)
- Web applications (for dashboards)
- All in separate, isolated containers

#### **2.3 Install Docker (if not installed)**

If Docker is not found, install it using the official Docker installation method:

```bash
# Install Docker using the official installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add your user to the docker group (if you created a non-root user)
# usermod -aG docker yourusername

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Verify Docker installation
docker --version
docker-compose --version

# Test Docker with a simple container
docker run hello-world
```

**Alternative Installation Methods:**
```bash
# Option 1: Using apt (Ubuntu package manager)
apt update
apt install -y docker.io docker-compose

# Option 2: Using snap (if you prefer snap packages)
snap install docker
```

**What to expect after installation:**
- Docker service will be running
- You can run `docker --version` successfully
- The `hello-world` container will run and show a welcome message

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

**Why Create a Non-Root User?**
Think of it like this:
- **Root User** = Being the owner of a building with master keys to everything
- **Regular User** = Being a tenant with keys only to your own apartment

**Security Benefits:**
- **Limited Damage**: If something goes wrong, it only affects your user account
- **Accident Prevention**: You can't accidentally delete system files
- **Better Practices**: Forces you to think before running powerful commands
- **Audit Trail**: System logs show which user performed which actions

**When to Use Root vs Regular User:**
- **Regular User**: Daily work, editing files, running applications
- **Root User**: System administration, installing software, configuring services

**Note**: For this tutorial, we'll continue using root for simplicity, but in production, you should use a regular user account.

### **3.2 Configure SSH Security**
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config
```

**Add or modify these lines:**
```bash
# Change SSH port (optional but recommended)
# Note: Your server already uses custom port 10108
Port 10108

# Disable root login
PermitRootLogin no

# Disable password authentication (use keys instead)
PasswordAuthentication no

# Enable public key authentication
PubkeyAuthentication yes
```

**What these settings do:**
- `Port 10108` - Uses your custom "door number" instead of the standard 22 (makes it harder for hackers to find)
- `PermitRootLogin no` - Prevents logging in as the administrator (safer)
- `PasswordAuthentication no` - Disables password login (forces you to use SSH keys)
- `PubkeyAuthentication yes` - Enables SSH key authentication (more secure than passwords)

**Security Explained Simply:**

| Setting | What It Does | Why It's Better |
|---------|-------------|-----------------|
| **Custom Port** | Changes the "door number" from 22 to 10108 | Hackers try door 22 first - your door is hidden |
| **No Root Login** | Prevents administrator login via SSH | Even if someone gets in, they can't be the admin |
| **No Password** | Disables password-based login | Passwords can be guessed or stolen |
| **SSH Keys** | Uses cryptographic keys instead of passwords | Keys are much harder to crack than passwords |

**Think of SSH Keys Like This:**
- **Password**: Like a secret word that anyone can try to guess
- **SSH Key**: Like a unique fingerprint that only you have - impossible to copy or guess

**Important Note**: Since you're already using port 10108, you don't need to change the port setting.

### **3.3 Generate SSH Keys on Windows**

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

### **3.4 Configure Firewall (UFW) - Mikrus VPS Port Limitations**

**⚠️ Important: Mikrus VPS Port Restrictions**

Before configuring the firewall, you need to understand Mikrus VPS port limitations:

**Your Mikrus VPS Port Allocation:**
- **Default Ports (TCP/UDP)**: 3 ports automatically assigned
  - **10108** = 10000 + 108 (SSH - already configured)
  - **20108** = 20000 + 108 (General purpose)
  - **30108** = 30000 + 108 (General purpose)
- **Additional Ports**: Up to 7 more TCP ports (free to add in control panel)

**Why Standard Ports Are Blocked:**
- **Security**: Prevents conflicts between multiple VPS instances
- **Resource Management**: Better isolation and traffic control
- **Network Segmentation**: Each VPS has unique port ranges
- **Attack Prevention**: Reduces automated attacks on common ports

**❌ Standard Ports You CANNOT Use:**
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Port 1883 (MQTT)
- Port 1880 (Node-RED)
- Port 8086 (InfluxDB)
- Port 3000 (Grafana)
- Port 3001 (Express Backend)

**✅ Custom Port Strategy for Your IoT System:**

```bash
# Check current firewall status
sudo ufw status

# Enable UFW firewall
sudo ufw enable

# Allow SSH (your default port)
sudo ufw allow 10108/tcp

# Allow HTTP and HTTPS (using your default ports)
sudo ufw allow 20108/tcp    # HTTP (instead of 80)
sudo ufw allow 30108/tcp    # HTTPS (instead of 443)

# Allow IoT monitoring system ports (using your actual Mikrus ports)
sudo ufw allow 40098/tcp    # MQTT (IoT device communication)
sudo ufw allow 40099/tcp    # Node-RED (data processing)
sudo ufw allow 40100/tcp    # InfluxDB (database)
sudo ufw allow 40101/tcp    # Grafana (dashboards)
sudo ufw allow 40102/tcp    # Express Backend (web app)

# Check firewall status with numbered rules
sudo ufw status numbered
```

**What this means:** A firewall is like a security guard that only allows authorized connections. UFW (Uncomplicated Firewall) is a simple firewall for Ubuntu.

**Firewall Explained Simply:**
Think of a firewall like a security guard at a building entrance:
- **No Firewall**: Anyone can walk in through any door
- **With Firewall**: Only people with proper authorization can enter through specific doors

**What UFW Does:**
- **Blocks Unwanted Traffic**: Stops hackers from trying to access your server
- **Allows Specific Services**: Only opens the "doors" you need (SSH, web services, IoT services)
- **Logs Attempts**: Keeps a record of who tried to access your server
- **Easy Management**: Simple commands to allow or block access

**Mikrus VPS Port Strategy Explained:**

| Service | Standard Port | Your Custom Port | Purpose | Why You Need It |
|---------|---------------|------------------|---------|-----------------|
| **SSH** | 22 | **10108** | Secure server access | Your main entrance to the server |
| **HTTP** | 80 | **20108** | Web traffic | Standard web access (using custom port) |
| **HTTPS** | 443 | **30108** | Secure web traffic | Encrypted web access (using custom port) |
| **MQTT** | 1883 | **40098** | IoT device communication | Your renewable energy devices send data here |
| **Node-RED** | 1880 | **40099** | Data processing flows | Processes and routes your IoT data |
| **InfluxDB** | 8086 | **40100** | Time-series database | Stores your sensor data |
| **Grafana** | 3000 | **40101** | Data visualization | View dashboards and charts |
| **Express Backend** | 3001 | **40102** | Custom web application | Your React app backend |

**How to Access Your Services:**

**Instead of standard URLs like:**
- `http://robert108.mikrus.xyz` (port 80)
- `https://robert108.mikrus.xyz` (port 443)

**You'll use:**
- `http://robert108.mikrus.xyz:20108` (HTTP)
- `https://robert108.mikrus.xyz:30108` (HTTPS)
- `http://robert108.mikrus.xyz:40101` (Grafana)
- `http://robert108.mikrus.xyz:40102` (Express Backend)
- `http://robert108.mikrus.xyz:40099` (Node-RED)
- `http://robert108.mikrus.xyz:40100` (InfluxDB)

**Why This Matters for Your IoT System:**
Your renewable energy devices need to send data to your server, but you don't want unauthorized access. The firewall ensures only your devices and authorized users can connect.

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
[ 6] 40099/tcp                  ALLOW IN    Anywhere
[ 7] 40100/tcp                  ALLOW IN    Anywhere
[ 8] 40101/tcp                  ALLOW IN    Anywhere
[ 9] 40102/tcp                  ALLOW IN    Anywhere
[10] 22 (v6)                    ALLOW IN    Anywhere (v6)
[11] 10108/tcp (v6)             ALLOW IN    Anywhere (v6)
[12] 20108/tcp (v6)             ALLOW IN    Anywhere (v6)
[13] 30108/tcp (v6)             ALLOW IN    Anywhere (v6)
[14] 40098/tcp (v6)             ALLOW IN    Anywhere (v6)
[15] 40099/tcp (v6)             ALLOW IN    Anywhere (v6)
[16] 40100/tcp (v6)             ALLOW IN    Anywhere (v6)
[17] 40101/tcp (v6)             ALLOW IN    Anywhere (v6)
[18] 40102/tcp (v6)             ALLOW IN    Anywhere (v6)
```

**📝 Notes on Your Firewall Configuration:**
- **Port 22**: Standard SSH port is also open (normal for Mikrus VPS)
- **Port 10108**: Your custom SSH port (primary access method)
- **Ports 20108, 30108**: Your default Mikrus HTTP/HTTPS ports
- **Ports 40098-40102**: Your IoT system ports (MQTT, Node-RED, InfluxDB, Grafana, Express)
- **IPv6 Support**: All ports are also open for IPv6 (modern networking)
- **Complete Coverage**: You have all necessary ports for your renewable energy IoT system

**Steps to Configure Your Ports:**

1. **Add Additional Ports in Mikrus Panel:**
   - Log into your Mikrus control panel
   - Add up to 7 additional ports (20109, 20110, 20111, 20112, 20113, etc.)
   - These are free and TCP-only

2. **Update Environment Variables:**
   ```bash
   # Update your .env file with custom ports
   MQTT_PORT=40098
   NODE_RED_PORT=40099
   INFLUXDB_PORT=40100
   GRAFANA_PORT=40101
   EXPRESS_PORT=40102
   ```

3. **Update Docker Compose Configuration:**
   - Modify your docker-compose.yml to use custom ports
   - Map internal container ports to your custom external ports

**What to do if a port is missing:**
```bash
# If you need to add a missing port later
sudo ufw allow [PORT_NUMBER]/tcp

# Example: Add port 40102 for Express Backend
sudo ufw allow 40102/tcp

# Check the updated status
sudo ufw status numbered
```

**Benefits of Mikrus Port Restrictions:**
- **Better Security**: Non-standard ports reduce automated attacks
- **No Conflicts**: Each VPS has unique port ranges
- **Scalability**: Mikrus can manage resources better
- **Isolation**: Your services are isolated from other VPS instances

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
port = 10108
logpath = /var/log/auth.log
```

**What this means:** Fail2ban is like an automatic security guard that blocks suspicious activity. If someone tries to log in with the wrong password too many times, it automatically blocks them.

**Fail2ban Explained Simply:**
Think of Fail2ban like a smart security system:
- **Normal Behavior**: You enter the correct password, you get in
- **Suspicious Behavior**: Someone tries wrong passwords repeatedly
- **Automatic Response**: Fail2ban blocks that person's IP address temporarily

**How It Works:**
1. **Monitors Logs**: Watches for failed login attempts
2. **Detects Patterns**: Identifies when someone is trying to hack in
3. **Takes Action**: Automatically blocks the suspicious IP address
4. **Releases Later**: Unblocks after a set time (usually 1 hour)

**Real-World Example:**
- **Hacker**: Tries password "123456" → Fails
- **Hacker**: Tries password "password" → Fails  
- **Hacker**: Tries password "admin" → Fails
- **Fail2ban**: "This looks suspicious!" → Blocks the IP address
- **You**: Safe from further attempts

**Benefits for Your IoT System:**
- **Protects Your Data**: Keeps your renewable energy data safe
- **Reduces Server Load**: Stops hackers from wasting your server's resources
- **Automatic Protection**: Works 24/7 without you needing to monitor it
- **Configurable**: You can adjust how sensitive it is

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

**Docker Configuration Explained Simply:**

| Setting | What It Does | Why It's Important |
|---------|-------------|-------------------|
| **Log Driver** | Controls how Docker saves log files | Prevents logs from filling up your disk |
| **Max Size (10MB)** | Limits each log file to 10MB | Keeps log files manageable |
| **Max Files (3)** | Keeps only 3 log files | Automatically deletes old logs to save space |
| **Storage Driver** | How Docker stores data | Uses the most efficient method for your system |
| **File Limits** | Increases how many files Docker can open | Prevents "too many open files" errors |

**Why This Matters for Your VPS:**
- **Limited Storage**: Your VPS has 25GB - logs can fill this up quickly
- **Performance**: Efficient storage means faster application startup
- **Reliability**: Proper file limits prevent crashes
- **Maintenance**: Automatic log rotation means less manual cleanup

**Real-World Analogy:**
Think of it like managing a filing cabinet:
- **Without Limits**: Files keep piling up until the cabinet is full
- **With Limits**: Old files are automatically archived, keeping the cabinet organized

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

**Project Structure Explained:**

| Folder | Purpose | What Goes Here |
|--------|---------|----------------|
| **mosquitto/** | MQTT broker configuration | Settings for device communication |
| **influxdb/** | Database configuration | Settings for storing sensor data |
| **node-red/** | Data processing flows | Logic for processing IoT device data |
| **grafana/** | Dashboard configuration | Settings for data visualization |
| **web-app/** | Custom web application | Your React/Express application files |
| **scripts/** | Utility scripts | Helper scripts for maintenance |
| **backups/** | Backup files | Automatic backups of your data |

**Why This Organization Matters:**
- **Separation of Concerns**: Each service has its own folder
- **Easy Maintenance**: You know exactly where to find things
- **Backup Strategy**: You can backup specific components
- **Troubleshooting**: Easier to identify which service has issues

**Think of it like organizing a house:**
- **Kitchen** (mosquitto) - Where devices send their data
- **Storage Room** (influxdb) - Where data is kept
- **Control Room** (node-red) - Where data is processed
- **Living Room** (grafana) - Where you view dashboards
- **Office** (web-app) - Where you manage everything
- **Utility Room** (scripts) - Where you keep tools
- **Safe** (backups) - Where you keep copies

#### **5.2 Set Up Environment Variables**
```bash
# Create environment file
nano .env
```

**Add these variables (Updated for Mikrus VPS Custom Ports):**
```bash
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
```

**What this means:** Environment variables are like settings that tell your applications how to behave. They're stored in a file called `.env` and contain things like passwords, URLs, and configuration options.

**Environment Variables Explained Simply:**
Think of environment variables like the settings on your phone:
- **Phone Settings**: Control how your phone behaves (brightness, volume, WiFi)
- **Environment Variables**: Control how your applications behave (database connection, passwords, URLs)

**Why Use Environment Variables?**
- **Security**: Passwords aren't hardcoded in your application files
- **Flexibility**: You can change settings without modifying code
- **Portability**: Same application works on different servers
- **Organization**: All settings are in one place

**Mikrus VPS Port Mapping Explained:**

| Service | Standard Port | Mikrus Custom Port | Environment Variable | Purpose |
|---------|---------------|-------------------|---------------------|---------|
| **SSH** | 22 | **10108** | `SERVER_PORT` | Secure server access |
| **HTTP** | 80 | **20108** | `HTTP_PORT` | Web traffic |
| **HTTPS** | 443 | **30108** | `HTTPS_PORT` | Secure web traffic |
| **MQTT** | 1883 | **20109** | `MQTT_PORT` | IoT device communication |
| **MQTT WebSocket** | 9001 | **20114** | `MQTT_WS_PORT` | WebSocket MQTT access |
| **Node-RED** | 1880 | **20110** | `NODE_RED_PORT` | Data processing flows |
| **InfluxDB** | 8086 | **20111** | `INFLUXDB_PORT` | Time-series database |
| **Grafana** | 3000 | **20112** | `GRAFANA_PORT` | Data visualization |
| **Express Backend** | 3001 | **20113** | `EXPRESS_PORT` | Custom web application |

**Key Variables for Your IoT System:**

| Variable | Purpose | Example | Notes |
|----------|---------|---------|-------|
| **SERVER_IP** | Your server's address | robert108.mikrus.xyz | Your Mikrus hostname |
| **MQTT_PORT** | MQTT broker port | 20109 | Custom port for IoT devices |
| **INFLUXDB_PORT** | Database port | 20111 | Custom port for data storage |
| **GRAFANA_PORT** | Dashboard port | 20112 | Custom port for visualization |
| **EXPRESS_PORT** | Web app port | 20113 | Custom port for your application |

**Security Best Practices:**
- **Never commit .env files** to version control
- **Use strong, unique passwords** for each service
- **Keep backups** of your .env file in a secure location
- **Change default passwords** immediately after setup
- **Use custom ports** to reduce automated attacks

**Real-World Analogy:**
Think of it like a restaurant's recipe book:
- **Recipe** (application code) = How to make the dish
- **Ingredients List** (environment variables) = What ingredients to use
- **Chef's Notes** (configuration) = Special instructions for this kitchen
- **Kitchen Layout** (port mapping) = Where each station is located

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

**Swap Memory Explained Simply:**
Think of swap memory like a backup plan for your computer's memory:
- **RAM**: Like your desk - fast and easy to access
- **Swap**: Like a filing cabinet - slower but holds more
- **When RAM is full**: Your computer moves less important things to the filing cabinet

**Why Your VPS Needs Swap:**
- **Limited RAM**: Your VPS has only 2GB of RAM
- **Multiple Services**: You'll be running several applications
- **Safety Net**: Prevents crashes when memory runs low
- **Performance**: Keeps your system running smoothly

**How It Works:**
1. **Normal Operation**: Applications use RAM (fast)
2. **High Memory Usage**: System moves inactive data to swap (slower)
3. **Memory Available**: System moves data back to RAM when needed
4. **Automatic Management**: You don't need to manage this manually

**For Your IoT System:**
- **MQTT Broker**: Needs memory for device connections
- **Database**: Needs memory for data processing
- **Web Applications**: Need memory for user sessions
- **Swap**: Provides extra space when all services are running

**Real-World Analogy:**
Think of it like a restaurant kitchen:
- **Counter Space** (RAM) = Where you prepare food (fast access)
- **Storage Room** (Swap) = Where you keep extra ingredients (slower access)
- **When counter is full**: Move less-used items to storage
- **When you need something**: Bring it back to the counter

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

**Kernel Parameters Explained Simply:**
Think of kernel parameters like the settings on your car:
- **Engine Settings**: Control how the engine performs
- **Kernel Parameters**: Control how your operating system performs

**What These Settings Do:**

| Parameter | What It Controls | Why It's Important |
|-----------|-----------------|-------------------|
| **Network Memory** | How much memory is used for network connections | Handles multiple IoT device connections |
| **File Descriptors** | How many files your system can open at once | Prevents "too many open files" errors |
| **Memory Management** | How the system manages RAM and swap | Optimizes performance for your 2GB RAM |

**Why Optimize for Your VPS:**
- **Limited Resources**: Your VPS has limited RAM and CPU
- **IoT Workload**: Multiple devices sending data simultaneously
- **Web Services**: Multiple users accessing dashboards
- **Performance**: Every optimization helps with limited hardware

**Real-World Analogy:**
Think of it like tuning a car for a specific race:
- **Stock Settings**: Works for general driving
- **Optimized Settings**: Works better for your specific needs (IoT monitoring)
- **Performance Gains**: Better handling, fuel efficiency, and speed

**Benefits for Your IoT System:**
- **Better Network Performance**: Handles more device connections
- **Improved Memory Usage**: More efficient use of your 2GB RAM
- **Reduced Errors**: Fewer "out of resources" problems
- **Smoother Operation**: Better overall system performance

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
# Solution: Reinstall Docker using official method
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Alternative: Using apt package manager
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

**What this means:** Sometimes Docker doesn't install properly. The official installation script is the most reliable method, but apt installation also works well on Ubuntu.

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
- Test outbound SSH to robert108.mikrus.xyz on port 10108: Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 10108.
- Generate commands to create an SSH config entry named "mikrus" using $HOME\ .ssh\ id_rsa and port 10108.
- Provide remote bash checks to verify OS, memory, disk, CPU and Docker service on VPS.
- For each command, show expected output and what to do if the check fails.
Deliver results grouped by: Windows PowerShell vs Remote VPS bash.
```
