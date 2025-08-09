# 🚀 Renewable Energy IoT Monitoring System - Mikrus VPS Deployment Strategy

> **Complete deployment strategy for Mikrus VPS deployment of renewable energy IoT monitoring system**

## 📋 Overview

This comprehensive deployment strategy provides step-by-step instructions for deploying your renewable energy IoT monitoring system on Mikrus VPS. The strategy is designed specifically for Mikrus servers and optimized for Windows users connecting from a Windows PC.

### 🎯 System Architecture
- **MQTT Broker**: Eclipse Mosquitto (Port 1883) - Think of this as the "post office" for your IoT devices. It receives messages from sensors and distributes them to other parts of the system
- **Time-Series Database**: InfluxDB 2.7 (Port 8086) - This is like a specialized filing cabinet that stores data with timestamps (perfect for sensor readings that change over time)
- **Data Processing**: Node-RED (Port 1880) - A visual programming tool that connects different parts of your system and processes data (like a digital plumber connecting pipes)
- **Visualization**: Grafana (Port 3000) - Creates beautiful charts and dashboards from your data (like a digital artist that paints pictures with your data)
- **Custom Web App**: Express Backend (Port 3001) + React Frontend (Port 3002) - A custom website you can build to display your data in unique ways

### 🏗️ Mikrus VPS Specifications

#### **Mikrus 3.0 (Recommended Minimum)**
- **RAM**: 2GB - Think of this as your computer's "working memory" - the more you have, the more things you can do at once
- **Storage**: 25GB SSD - This is like your computer's "hard drive" - where all your data and programs are stored
- **CPU**: 2 cores - These are like the "brains" of your computer - the more cores, the faster it can process information
- **Location**: Finland - Where your server is physically located (affects internet speed and data privacy laws)
- **Price**: 130.00zł/year - ZUT faktura
- **Network**: 1Gbps - How fast your server can send and receive data over the internet

#### **Mikrus 3.5 (Optimal Choice)**
- **RAM**: 3GB - More memory for better performance
- **Storage**: 40GB SSD - More storage space for your data
- **CPU**: 3 cores - More processing power
- **Location**: Finland
- **Price**: 180.00zł/year
- **Network**: 1Gbps

#### **Mikrus Server Features**
- **Operating System**: Ubuntu 24.04 LTS (latest stable version)
- **Docker Support**: Pre-installed Docker and Docker Compose
- **SSH Access**: Secure shell access for remote management
- **Backup System**: Automatic daily backups included
- **Monitoring**: Built-in server monitoring tools
- **Control Panel**: Web-based control panel for easy management
- **IPv4/IPv6**: Dual stack networking support
- **DDoS Protection**: Basic DDoS protection included

---

## 📚 Deployment Phases

### **Phase 1: VPS Setup and Preparation**
**[📖 Complete Guide](./01-vps-setup-and-preparation.md)**

**Objectives:**
- ✅ Set up secure VPS environment
- ✅ Install and configure Docker
- ✅ Configure firewall and security
- ✅ Prepare environment variables
- ✅ Test basic connectivity

**Key Components:**
- Server security configuration - Making your server safe from hackers
- Docker installation and optimization - Installing the "container" system that will run your applications
- Environment setup - Preparing the basic settings your system needs
- System monitoring tools - Tools to watch how your system is performing
- Performance baseline establishment - Setting up a "starting point" to measure how well your system works

**Estimated Time:** 2-3 hours

---

### **Phase 2: Application Deployment**
**[📖 Complete Guide](./02-application-deployment.md)**

**Objectives:**
- ✅ Deploy all Docker containers
- ✅ Configure resource limits for Mikrus VPS
- ✅ Set up data persistence
- ✅ Configure networking between services
- ✅ Test basic functionality

**Key Components:**
- Optimized Docker Compose configuration - A "recipe" that tells Docker how to set up all your applications
- Web application components (Express + React) - Your custom website for viewing data
- Resource allocation for limited VPS - Making sure your applications don't use too much memory or CPU
- Service health monitoring - Checking that all parts of your system are working properly
- Performance optimization - Making your system run as fast as possible

**Estimated Time:** 3-4 hours

---

### **Phase 3: Data Migration and Testing**
**[📖 Complete Guide](./03-data-migration-testing.md)**

**Objectives:**
- ✅ Migrate existing data and configurations
- ✅ Test all system components and data flows
- ✅ Validate performance under load
- ✅ Verify data integrity and persistence
- ✅ Test backup and recovery procedures

**Key Components:**
- Data migration from local environment - Moving your existing data from your computer to the server
- Comprehensive system testing - Making sure everything works together properly
- Load testing and performance validation - Testing how your system performs when lots of data is flowing through it
- Data integrity verification - Making sure your data doesn't get corrupted or lost
- Backup and recovery testing - Testing your backup system to make sure you can recover your data if something goes wrong

**Estimated Time:** 2-3 hours

---

### **Phase 4: Production Optimization**
**[📖 Complete Guide](./04-production-optimization.md)**

**Objectives:**
- ✅ Optimize system performance for production
- ✅ Implement advanced monitoring and alerting
- ✅ Configure automated maintenance tasks
- ✅ Optimize resource usage for Mikrus VPS
- ✅ Implement production-grade security measures

**Key Components:**
- Production-optimized Docker configurations - Making your applications more secure and efficient for real-world use
- Advanced monitoring and alerting - Systems that watch your server and send you messages if something goes wrong
- Automated maintenance procedures - Tasks that run automatically to keep your system healthy
- Performance tuning and optimization - Fine-tuning your system to run as efficiently as possible
- Resource usage optimization - Making sure your system uses the limited resources (RAM, CPU) as efficiently as possible

**Estimated Time:** 3-4 hours

---

## 🛠️ Quick Start Guide

### **Prerequisites for Windows Users**
- Mikrus VPS account - Your virtual server account
- SSH client for Windows (PuTTY, Windows Terminal, or WSL) - A secure way to connect to your server from your Windows computer
- Local development environment with project files - Your project files on your Windows computer
- Basic Linux command line knowledge - Knowing how to type commands to control your server
- File transfer tool (WinSCP, FileZilla, or WSL) - To copy files between your Windows PC and the server

### **Windows-Specific Tools**
- **SSH Client Options:**
  - **Windows Terminal** (recommended) - Built into Windows 10/11
  - **PuTTY** - Popular SSH client for Windows
  - **WSL (Windows Subsystem for Linux)** - Linux environment on Windows
  - **VS Code with Remote SSH extension** - For editing files directly on the server

- **File Transfer Options:**
  - **WinSCP** - GUI file transfer tool
  - **FileZilla** - Cross-platform FTP client
  - **WSL** - Use Linux commands like `scp` and `rsync`
  - **VS Code Remote SSH** - Edit files directly on the server

### **Deployment Checklist**

#### **Before Starting:**
- [ ] VPS purchased and accessible - You've bought your server and can connect to it
- [ ] SSH keys configured - Setting up a secure way to log into your server
- [ ] Project files ready for transfer - Your code and configuration files are ready
- [ ] Environment variables prepared - The settings your applications need are ready
- [ ] Backup strategy planned - You know how you'll backup your data
- [ ] Windows SSH client installed - You have a way to connect to your server from Windows

#### **Phase 1 - VPS Setup:**
- [ ] Connect to VPS via SSH - Log into your server from Windows
- [ ] Update system packages - Install the latest security updates
- [ ] Configure security (firewall, SSH) - Make your server secure
- [ ] Install Docker and Docker Compose - Install the container system
- [ ] Set up monitoring tools - Install tools to watch your server
- [ ] Test basic connectivity - Make sure you can connect to all parts of your system

#### **Phase 2 - Application Deployment:**
- [ ] Transfer project files to VPS - Copy your code to the server using Windows tools
- [ ] Configure Docker Compose for Mikrus VPS - Set up your applications for your specific server
- [ ] Deploy all services - Start all your applications
- [ ] Configure web applications - Set up your custom website
- [ ] Test service connectivity - Make sure all parts can talk to each other
- [ ] Verify data persistence - Make sure your data is being saved properly

#### **Phase 3 - Testing and Validation:**
- [ ] Migrate existing data (if applicable) - Move your existing data to the server
- [ ] Run comprehensive system tests - Test everything thoroughly
- [ ] Perform load testing - Test how your system handles lots of data
- [ ] Validate data integrity - Make sure your data is accurate and complete
- [ ] Test backup procedures - Test your backup system
- [ ] Establish performance baseline - Set up a way to measure how well your system performs

#### **Phase 4 - Production Optimization:**
- [ ] Implement production configurations - Set up your system for real-world use
- [ ] Set up advanced monitoring - Install systems to watch your server
- [ ] Configure automated maintenance - Set up automatic tasks to keep your system healthy
- [ ] Optimize performance - Make your system run as fast as possible
- [ ] Validate production readiness - Make sure everything is ready for real use

---

## 📊 Performance Expectations

### **Resource Usage on Mikrus VPS:**

| Service | Memory | CPU | Storage | Status | Explanation |
|---------|--------|-----|---------|--------|-------------|
| **MQTT Broker** | 50-100MB | 0.1-0.2 cores | 100MB | ✅ Lightweight | The "post office" - very efficient |
| **InfluxDB** | 512MB-1GB | 0.5-1.0 cores | 5-10GB | ⚠️ Resource-intensive | The "filing cabinet" - uses more resources but stores all your data |
| **Node-RED** | 200-400MB | 0.2-0.5 cores | 500MB | ✅ Moderate | The "digital plumber" - moderate resource usage |
| **Grafana** | 150-300MB | 0.1-0.3 cores | 1GB | ✅ Moderate | The "digital artist" - moderate resource usage |
| **Express Backend** | 100-200MB | 0.1-0.3 cores | 100MB | ✅ Lightweight | Your custom website's "brain" - very efficient |
| **React Frontend** | 75-150MB | 0.1-0.2 cores | 200MB | ✅ Lightweight | Your custom website's "face" - very efficient |
| **System Overhead** | 200-400MB | 0.5 core | 2GB | ✅ Acceptable | The operating system and basic tools |

**Total Expected Usage:**
- **Memory**: 1.2-2.2GB (within 2GB limit for Mikrus 3.0) - You're using most of your available memory, but it should work
- **CPU**: 1.1-2.5 cores (within 2 core limit for Mikrus 3.0) - You're using most of your available CPU power, but it should work
- **Storage**: 8-14GB (within 25GB limit for Mikrus 3.0) - You have plenty of storage space left

**Mikrus 3.5 Advantages:**
- **Memory**: 3GB available - More headroom for better performance
- **CPU**: 3 cores available - Better multitasking and responsiveness
- **Storage**: 40GB available - More space for data retention and backups

---

## 🔧 Configuration Files

### **Essential Files for Deployment:**

#### **Docker Compose Configuration:**
- `docker-compose.yml` - Basic deployment - This is like a "recipe" that tells Docker how to set up all your applications
- `docker-compose.prod.yml` - Production optimized - A more advanced "recipe" for real-world use

#### **Environment Variables:**
- `.env` - All system configuration - This file contains all the settings your applications need (like passwords, URLs, etc.)

#### **Application Components:**
- `web-app-for-testing/backend/` - Express backend - The "brain" of your custom website
- `web-app-for-testing/frontend/` - React frontend - The "face" of your custom website
- `mosquitto/config/` - MQTT configuration - Settings for your "post office"
- `influxdb/config/` - Database configuration - Settings for your "filing cabinet"
- `node-red/flows/` - Node-RED flows - The "plumbing" that connects everything together
- `grafana/dashboards/` - Grafana dashboards - The "paintings" that show your data

#### **Monitoring Scripts:**
- `performance-monitor.sh` - Basic monitoring - A simple tool to watch your system
- `advanced-monitor.sh` - Advanced monitoring - A more detailed tool to watch your system
- `system-cleanup.sh` - Maintenance - A tool to clean up old files and optimize your system
- `backup-system.sh` - Backup procedures - A tool to backup your data

---

## 🧪 Testing and Validation

### **Automated Testing Scripts:**

#### **System Health Check:**
```bash
# Run comprehensive system test
./system-test.sh

# Expected output: All tests passed
```

#### **Performance Monitoring:**
```bash
# Monitor system performance
./performance-monitor.sh

# Expected metrics within acceptable ranges
```

#### **Load Testing:**
```bash
# Run load test
./load-test.sh

# Validate system under stress
```

### **Manual Testing Checklist:**

#### **Service Connectivity:**
- [ ] MQTT Broker accessible (Port 1883) - Can your "post office" receive messages?
- [ ] InfluxDB health check (Port 8086) - Is your "filing cabinet" working properly?
- [ ] Node-RED interface (Port 1880) - Can you access your "digital plumber"?
- [ ] Grafana dashboard (Port 3000) - Can you see your "digital paintings"?
- [ ] Express API (Port 3001) - Is your custom website's "brain" working?
- [ ] React frontend (Port 3002) - Can you see your custom website's "face"?

#### **Data Flow Validation:**
- [ ] MQTT message publishing - Are messages flowing through your "post office"?
- [ ] InfluxDB data writing - Is data being stored in your "filing cabinet"?
- [ ] Node-RED flow processing - Is your "digital plumber" connecting everything properly?
- [ ] Grafana data visualization - Are your "digital paintings" showing the right data?
- [ ] API data retrieval - Can your custom website get data from the database?
- [ ] Frontend data display - Can your custom website show the data properly?

---

## ⚠️ Troubleshooting

### **Common Issues and Solutions:**

#### **Issue 1: Memory Exhaustion**
```bash
# Symptoms: Container restarts, slow performance
# Solution: Optimize resource limits
docker-compose -f docker-compose.prod.yml up -d
```
**What this means:** Your server is running out of memory (RAM). This happens when your applications try to use more memory than your server has available.

#### **Issue 2: Service Startup Failures**
```bash
# Symptoms: Services not starting
# Solution: Check logs and dependencies
docker-compose logs [service-name]
docker-compose ps
```
**What this means:** One or more of your applications isn't starting properly. This could be due to configuration errors, missing files, or resource issues.

#### **Issue 3: Data Persistence Issues**
```bash
# Symptoms: Data loss after restart
# Solution: Verify volume mounts
docker volume ls
docker volume inspect [volume-name]
```
**What this means:** Your data is disappearing when you restart your applications. This usually means your data isn't being saved to the right place.

#### **Issue 4: Network Connectivity**
```bash
# Symptoms: Services can't communicate
# Solution: Check Docker network
docker network ls
docker network inspect iot-network
```
**What this means:** Your applications can't talk to each other. This is like having a broken phone line between different parts of your system.

#### **Issue 5: Windows SSH Connection Problems**
```bash
# Symptoms: Can't connect from Windows
# Solution: Check SSH client configuration
# For PuTTY: Verify hostname, port, and key settings
# For Windows Terminal: Use ssh username@server-ip
```
**What this means:** You can't connect to your server from your Windows computer. This could be due to incorrect SSH settings or network issues.

---

## 🔒 Security Considerations

### **Security Measures Implemented:**

#### **Network Security:**
- SSH key-based authentication - Using a special "key" to log into your server (more secure than passwords)
- Firewall configuration (UFW) - A "security guard" that only allows authorized connections
- Non-standard SSH port (2222) - Using a different "door" than the standard one (makes it harder for hackers to find)
- Fail2ban protection - A system that automatically blocks suspicious activity

#### **Application Security:**
- Non-root Docker containers - Running your applications with limited permissions (safer)
- Environment variable protection - Keeping sensitive information (like passwords) in secure files
- Secure token management - Using secure "keys" for accessing your data
- HTTPS headers (when applicable) - Encrypting data when it travels over the internet

#### **Data Security:**
- Regular backup procedures - Making copies of your data regularly
- Data encryption at rest - Encrypting your data when it's stored on the server
- Access control implementation - Controlling who can access your data
- Audit logging - Keeping records of who accessed what and when

#### **Mikrus-Specific Security:**
- **DDoS Protection**: Basic DDoS protection included with Mikrus servers
- **Backup System**: Automatic daily backups included
- **Monitoring**: Built-in server monitoring tools
- **Control Panel**: Web-based control panel for easy management

---

## 📈 Monitoring and Maintenance

### **Automated Monitoring:**

#### **Resource Monitoring:**
- Memory usage tracking - Watching how much memory your applications are using
- CPU load monitoring - Watching how much work your server is doing
- Disk space monitoring - Watching how much storage space you have left
- Network connectivity checks - Making sure your server can communicate with the internet

#### **Service Health Checks:**
- Container status monitoring - Checking if all your applications are running
- Service endpoint health checks - Testing if your applications are responding to requests
- Data flow validation - Making sure data is flowing through your system properly
- Performance metrics collection - Gathering information about how well your system is performing

#### **Alerting System:**
- High resource usage alerts - Getting notified when your server is using too much memory or CPU
- Service failure notifications - Getting notified when an application stops working
- Performance degradation warnings - Getting notified when your system starts running slowly
- Security incident alerts - Getting notified when someone tries to access your system without permission

### **Maintenance Procedures:**

#### **Daily Tasks:**
- Performance monitoring - Checking how well your system is performing
- Log review - Reading the "diary" of your system to look for problems
- Backup verification - Making sure your backups are working properly

#### **Weekly Tasks:**
- System cleanup - Removing old files and optimizing your system
- Performance optimization - Making your system run faster
- Security updates - Installing the latest security patches

#### **Monthly Tasks:**
- Comprehensive backup - Making a complete copy of all your data
- Performance analysis - Analyzing how well your system has been performing
- Security audit - Checking your system for security vulnerabilities

---

## 🤖 AI Integration

### **AI Prompts for Each Phase:**

#### **Phase 1 - Setup:**
```
I need to set up a secure Mikrus VPS environment for my renewable energy IoT monitoring system.
VPS specs: 2GB RAM, 25GB storage, 2 cores, Ubuntu 24.04.
Please help configure security, Docker, and monitoring tools for optimal performance on Mikrus servers.
```

#### **Phase 2 - Deployment:**
```
I'm deploying a renewable energy IoT system on a Mikrus VPS with 2GB RAM.
Services: MQTT, InfluxDB 2.7, Node-RED, Grafana, Express, React.
Please help optimize Docker configurations and resource allocation for Mikrus hardware.
```

#### **Phase 3 - Testing:**
```
I need to test my IoT monitoring system deployed on a Mikrus VPS.
Components: Docker containers, time-series database, web applications.
Please help create comprehensive testing procedures and validation scripts for Mikrus environment.
```

#### **Phase 4 - Optimization:**
```
My renewable energy IoT system needs production optimization on Mikrus VPS.
Current issues: performance tuning, monitoring, maintenance automation.
Please help implement production-grade configurations and monitoring for Mikrus servers.
```

---

## 📞 Support and Resources

### **Documentation:**
- [Phase 1: VPS Setup](./01-vps-setup-and-preparation.md)
- [Phase 2: Application Deployment](./02-application-deployment.md)
- [Phase 3: Data Migration and Testing](./03-data-migration-testing.md)
- [Phase 4: Production Optimization](./04-production-optimization.md)

### **Useful Commands:**
```bash
# Check system status
docker-compose ps
./performance-monitor.sh

# View logs
docker-compose logs [service-name]

# Restart services
docker-compose restart [service-name]

# Backup system
./backup-system.sh

# Clean up system
./system-cleanup.sh
```

### **Windows-Specific Commands:**
```powershell
# Connect via Windows Terminal
ssh username@your-mikrus-server-ip

# Transfer files using WSL
scp -r ./project-folder username@server-ip:/home/username/

# Use WinSCP for GUI file transfer
# Download from: https://winscp.net/
```

### **Emergency Procedures:**
```bash
# Emergency restart
docker-compose down && docker-compose up -d

# Emergency backup
./backup-system.sh

# Emergency monitoring
./advanced-monitor.sh
```

---

## 🎯 Success Metrics

### **Deployment Success Criteria:**

#### **Performance Metrics:**
- Memory usage < 1.8GB (Mikrus 3.0) / < 2.5GB (Mikrus 3.5) - Your system should use less memory than available
- CPU load < 1.5 (Mikrus 3.0) / < 2.5 (Mikrus 3.5) - Your server should not be working too hard
- Response time < 2s - Your system should respond to requests quickly
- Disk usage < 20GB (Mikrus 3.0) / < 35GB (Mikrus 3.5) - You should have plenty of storage space left

#### **Reliability Metrics:**
- 99% uptime - Your system should be available 99% of the time
- Zero data loss - You shouldn't lose any of your data
- Automatic recovery - Your system should fix itself when problems occur
- Regular backups - You should have regular copies of your data

#### **Security Metrics:**
- No unauthorized access - Only authorized users should be able to access your system
- Encrypted data transmission - Data should be encrypted when it travels over the internet
- Regular security updates - Your system should be updated regularly with security patches
- Audit trail maintenance - You should keep records of who accessed your system

---

## 🚀 Next Steps

After completing the deployment:

1. **Monitor Performance**: Use the provided monitoring scripts
2. **Optimize Further**: Based on usage patterns
3. **Scale if Needed**: Consider upgrading to Mikrus 3.5 or higher
4. **Maintain Regularly**: Follow maintenance procedures
5. **Update Security**: Keep systems patched and secure

---

**🎉 Your renewable energy IoT monitoring system is now ready for production deployment on Mikrus VPS!**

---

*This deployment strategy is designed specifically for Mikrus VPS servers with Ubuntu 24.04 LTS. The strategy is optimized for Windows users connecting from a Windows PC environment.*

## Use in Cursor – Quick start validation
```text
Be my assistant to validate readiness across phases 1–2:
- List the five most critical checks to run now and produce Windows PowerShell and remote bash commands for each.
- Verify ports 1883, 1880, 8086, 3000 are listening, containers are healthy, and disk/memory are within limits.
- If any check fails, output the exact remediation command.
Keep it concise and copy-pasteable.
```
