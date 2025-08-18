# 🔄 Server Restart Guide - Complete Beginner's Manual

> **Understanding what happens when you restart your VPS and how to do it safely**

## 📋 Overview

This guide explains everything you need to know about restarting your VPS (Virtual Private Server) safely. Whether you're troubleshooting issues, applying updates, or performing maintenance, understanding the restart process is crucial for maintaining your renewable energy IoT monitoring system.

### 🎯 What is a Server Restart?

Think of a server restart like rebooting your computer:
- **What it does**: Shuts down all programs and services, then starts them again
- **Why it helps**: Clears memory, stops stuck processes, and gives everything a fresh start
- **When to use it**: When services are not responding, after updates, or for troubleshooting

### ✅ Prerequisites
- ✅ Access to your Mikrus VPS control panel
- ✅ Basic understanding of your server setup
- ✅ Patience (restart takes 2-5 minutes)

---

## 🔍 Understanding Your Current Situation

### **Before You Restart - Know Your Status**

**Your VPS Status Check:**
```powershell
# Test if your server is reachable
ping robert108.mikrus.xyz

# Test SSH connection
ssh root@robert108.mikrus.xyz -p10108

# Test web services
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40099
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40100
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40101
```

**Common Scenarios:**
- ✅ **Ping works, services down** → Restart will likely help
- ❌ **Ping fails** → Server might be completely down
- ⚠️ **Some services work, others don't** → Selective restart needed

---

## 🔄 What a Restart Will Do

### **✅ Positive Effects**

#### **1. Fresh System State**
**What happens:** The operating system completely shuts down and starts fresh
**Why it helps:** 
- Clears any stuck processes that are consuming resources
- Frees up memory that might be locked by crashed applications
- Resets the system to a clean state

**Real-world analogy:** Like restarting your phone when it gets slow - everything starts fresh

#### **2. Service Restart**
**What happens:** All system services stop and start again
**Why it helps:**
- SSH service gets a fresh start (fixes connection issues)
- Docker daemon restarts (container management system)
- Network services reset (fixes connectivity problems)

**Real-world analogy:** Like turning off all the lights in your house and turning them back on

#### **3. Network Reset**
**What happens:** Network interfaces and configurations are reloaded
**Why it helps:**
- Clears any network configuration issues
- Resets firewall rules properly
- Fixes network interface problems

**Real-world analogy:** Like unplugging and plugging back in your internet router

#### **4. Docker Restart**
**What happens:** Docker daemon restarts and containers auto-start
**Why it helps:**
- All your IoT monitoring containers start fresh
- Grafana, Node-RED, InfluxDB, and MQTT services restart
- Container networking is reset

**Real-world analogy:** Like restarting all the apps on your phone at once

#### **5. Firewall Reset**
**What happens:** UFW (Uncomplicated Firewall) reloads with proper rules
**Why it helps:**
- Ensures all ports (10108, 40098, 40099, 40100, 40101) are properly open
- Clears any firewall rule conflicts
- Resets security policies

**Real-world analogy:** Like resetting the security system in your house

### **⚠️ Potential Risks**

#### **1. Data Loss**
**What could happen:** If there are underlying disk issues, restart might not help
**Risk level:** Low (if your server is healthy)
**Prevention:** 
- Regular backups of your data
- Check disk health before restart
- Use proper shutdown procedures

**Real-world analogy:** Like restarting a computer with a failing hard drive

#### **2. Configuration Loss**
**What could happen:** If config files are corrupted, they might not load properly
**Risk level:** Very Low (configs are usually stable)
**Prevention:**
- Keep backups of important configuration files
- Document your setup
- Use version control for configurations

**Real-world analogy:** Like losing your phone settings after a factory reset

#### **3. Service Dependency Issues**
**What could happen:** Some services might not start in the correct order
**Risk level:** Low (Docker handles dependencies well)
**Prevention:**
- Use Docker Compose for proper service ordering
- Check service logs after restart
- Have recovery procedures ready

**Real-world analogy:** Like starting your car but the radio doesn't work because it depends on the main system

---

## 🚀 Recommended Restart Process

### **Step 1: Prepare for Restart**

#### **1.1 Document Current State**
```bash
# If you can still SSH in, run these commands first
docker ps -a                    # List all containers
docker-compose ps              # Check service status
systemctl status docker        # Check Docker service
df -h                          # Check disk space
free -h                        # Check memory usage
```

#### **1.2 Backup Important Data (if possible)**
```bash
# Backup your configuration files
sudo tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  /root/renewable-energy-iot/ \
  /etc/docker/ \
  /var/lib/docker/
```

### **Step 2: Choose Restart Method**

#### **Method A: Mikrus Control Panel (Recommended)**
1. **Log into Mikrus control panel**
2. **Find your VPS** (robert108.mikrus.xyz)
3. **Click "Restart" button** (not "Stop" then "Start")
4. **Wait 3-5 minutes** for full boot process

**Why this method is best:**
- Controlled shutdown process
- Proper service termination
- Automatic startup sequence
- Less risk of data corruption

#### **Method B: Force Restart (Emergency Only)**
1. **Use "Force Restart"** in control panel
2. **Only use if normal restart fails**
3. **Higher risk of data issues**

#### **Method C: SSH Restart (if SSH works)**
```bash
# Only if you can still SSH in
sudo reboot
# or
sudo shutdown -r now
```

### **Step 3: Wait for Restart**

**Timeline:**
- **0-1 minute**: Server shutting down
- **1-2 minutes**: Server starting up
- **2-3 minutes**: Operating system loading
- **3-4 minutes**: Services starting
- **4-5 minutes**: Docker containers starting

**What to do during restart:**
- **Don't panic** if it takes longer than expected
- **Don't try to connect** until 5 minutes have passed
- **Be patient** - good things take time

---

## 🔍 Expected Post-Restart Behavior

### **✅ Successful Restart Indicators**

#### **1. SSH Access Restored**
```powershell
# Test SSH connection
ssh root@robert108.mikrus.xyz -p10108
```
**Expected result:** Successful login prompt

#### **2. Web Services Accessible**
```powershell
# Test web services
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40099  # Grafana
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40100  # Node-RED
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40101  # InfluxDB
```
**Expected result:** All ports responding

#### **3. Docker Containers Running**
```bash
# Check container status
docker ps
```
**Expected result:** All containers showing "Up" status

### **❌ Failed Restart Indicators**

#### **1. SSH Still Not Working**
- **Symptom**: Connection timeout or refused
- **Possible cause**: SSH service not starting
- **Solution**: Contact Mikrus support

#### **2. Web Services Not Responding**
- **Symptom**: Ports still blocked
- **Possible cause**: Docker containers not starting
- **Solution**: Check container logs and restart manually

#### **3. Partial Service Recovery**
- **Symptom**: Some services work, others don't
- **Possible cause**: Service dependency issues
- **Solution**: Manual service restart

---

## 🛠️ Post-Restart Recovery Commands

### **Step 1: Verify System Status**

#### **1.1 Check Basic System Health**
```bash
# Check system resources
free -h                    # Memory usage
df -h                      # Disk space
uptime                     # System uptime
```

#### **1.2 Check Service Status**
```bash
# Check Docker service
systemctl status docker

# Check SSH service
systemctl status ssh

# Check firewall status
sudo ufw status numbered
```

### **Step 2: Verify Docker and Containers**

#### **2.1 Check Docker Status**
```bash
# Check Docker daemon
docker --version
docker-compose --version

# Check running containers
docker ps

# Check all containers (including stopped ones)
docker ps -a
```

#### **2.2 Start Services if Needed**
```bash
# Navigate to your project directory
cd /root/renewable-energy-iot

# Check service status
docker-compose ps

# Start all services
docker-compose up -d

# Check service logs
docker-compose logs -f
```

### **Step 3: Verify Individual Services**

#### **3.1 Check Grafana (Port 40099)**
```bash
# Test Grafana health
curl -f http://localhost:3000/api/health

# Check Grafana container
docker logs iot-grafana
```

#### **3.2 Check Node-RED (Port 40100)**
```bash
# Check Node-RED container
docker logs iot-node-red

# Test Node-RED access
curl -f http://localhost:1880
```

#### **3.3 Check InfluxDB (Port 40101)**
```bash
# Check InfluxDB container
docker logs iot-influxdb2

# Test InfluxDB health
curl -f http://localhost:8086/health
```

#### **3.4 Check MQTT (Port 40098)**
```bash
# Check MQTT container
docker logs iot-mosquitto

# Test MQTT connection
mosquitto_pub -h localhost -p 1883 -t test/topic -m "test message"
```

### **Step 4: Test External Access**

#### **4.1 Test from Your Local Machine**
```powershell
# Test SSH
ssh root@robert108.mikrus.xyz -p10108

# Test web services
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40099
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40100
Test-NetConnection -ComputerName robert108.mikrus.xyz -Port 40101

# Test in browser
# http://robert108.mikrus.xyz:40099  (Grafana)
# http://robert108.mikrus.xyz:40100  (Node-RED)
# http://robert108.mikrus.xyz:40101  (InfluxDB)
```

### **Step 5: Troubleshoot Issues**

#### **5.1 If Containers Won't Start**
```bash
# Check Docker logs
docker-compose logs

# Check system resources
free -h
df -h

# Restart Docker service
sudo systemctl restart docker

# Try starting services again
docker-compose up -d
```

#### **5.2 If Services Are Slow**
```bash
# Check resource usage
htop

# Check container resource usage
docker stats

# Check disk I/O
iostat -x 1 5
```

#### **5.3 If Network Issues Persist**
```bash
# Check firewall rules
sudo ufw status numbered

# Check network interfaces
ip addr show

# Check routing
ip route show
```

---

## 🚨 Emergency Procedures

### **When Restart Doesn't Help**

#### **1. Contact Mikrus Support**
**When to contact:**
- SSH still not working after restart
- Server not responding to ping
- Multiple restart attempts failed

**Information to provide:**
- VPS hostname: `robert108.mikrus.xyz`
- IP address: `135.181.138.229`
- Issue description: "All services down after restart"
- Steps already taken

#### **2. Use Mikrus Console Access**
**If available:**
- Use web console in control panel
- Check system logs: `journalctl -xe`
- Check service status manually
- Try manual service restart

#### **3. Consider Data Recovery**
**If data is critical:**
- Contact support about backup options
- Consider mounting disk in rescue mode
- Document what data needs to be recovered

---

## 📚 Best Practices

### **Before Restart**
- ✅ **Document current state** - Take screenshots or notes
- ✅ **Backup important data** - If possible
- ✅ **Choose the right time** - Avoid peak usage hours
- ✅ **Notify users** - If others use the system

### **During Restart**
- ✅ **Be patient** - Don't interrupt the process
- ✅ **Don't panic** - Restarts can take longer than expected
- ✅ **Wait full time** - Give it 5 minutes minimum

### **After Restart**
- ✅ **Verify all services** - Check each service individually
- ✅ **Test functionality** - Make sure everything works
- ✅ **Document issues** - Note any problems for future reference
- ✅ **Update monitoring** - Ensure monitoring systems are working

### **Prevention**
- ✅ **Regular maintenance** - Don't wait for problems
- ✅ **Monitor resources** - Watch for resource exhaustion
- ✅ **Keep backups** - Regular automated backups
- ✅ **Update regularly** - Keep system and software updated

---

## 🔧 Advanced Troubleshooting

### **Service-Specific Issues**

#### **Docker Issues**
```bash
# Reset Docker completely
sudo systemctl stop docker
sudo rm -rf /var/lib/docker
sudo systemctl start docker

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

#### **Network Issues**
```bash
# Reset network configuration
sudo systemctl restart networking

# Check DNS resolution
nslookup robert108.mikrus.xyz

# Test external connectivity
ping google.com
```

#### **Firewall Issues**
```bash
# Reset firewall
sudo ufw reset
sudo ufw enable

# Re-add rules
sudo ufw allow 10108/tcp
sudo ufw allow 40098/tcp
sudo ufw allow 40099/tcp
sudo ufw allow 40100/tcp
sudo ufw allow 40101/tcp
```

### **Performance Issues**
```bash
# Check system load
uptime

# Check memory usage
free -h

# Check disk usage
df -h

# Check running processes
ps aux --sort=-%mem | head -10
```

---

## 📋 Restart Checklist

### **Pre-Restart Checklist**
- [ ] **Document current issues**
- [ ] **Backup important data** (if possible)
- [ ] **Note current time** for tracking restart duration
- [ ] **Prepare recovery commands** for post-restart

### **Post-Restart Checklist**
- [ ] **Wait 5 minutes** before testing
- [ ] **Test SSH connection**
- [ ] **Check Docker containers**
- [ ] **Verify web services**
- [ ] **Test IoT functionality**
- [ ] **Check system resources**
- [ ] **Update documentation**

### **Success Indicators**
- [ ] ✅ SSH access restored
- [ ] ✅ All web services responding
- [ ] ✅ Docker containers running
- [ ] ✅ IoT data flowing
- [ ] ✅ System resources normal

---

## 🎯 Summary

### **Key Takeaways**

1. **Restart is usually the solution** - Most service issues are fixed by restart
2. **Use control panel restart** - Safest method for VPS restart
3. **Be patient** - Restart takes 3-5 minutes minimum
4. **Verify everything** - Don't assume it's working until you test it
5. **Document issues** - Keep notes for future troubleshooting

### **When to Restart**
- ✅ Services not responding
- ✅ SSH connection issues
- ✅ After system updates
- ✅ Performance problems
- ✅ Network connectivity issues

### **When NOT to Restart**
- ❌ During critical operations
- ❌ Without proper preparation
- ❌ If you suspect hardware issues
- ❌ Without backup (if possible)

---

## 🆘 Getting Help

### **If Restart Doesn't Work**
1. **Contact Mikrus support** - They can help with server-level issues
2. **Use console access** - If available in control panel
3. **Check documentation** - Review setup guides
4. **Community support** - Online forums and communities

### **Emergency Contacts**
- **Mikrus Support**: Through your control panel
- **Documentation**: Check the deployment guides
- **Backup Access**: If you have alternative access methods

---

**🎉 Remember: Restart is often the simplest and most effective solution to server issues. With proper preparation and patience, you can successfully restore your renewable energy IoT monitoring system!**
