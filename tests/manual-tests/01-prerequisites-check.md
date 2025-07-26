# Manual Test 01: Prerequisites Check

## Overview
This test verifies that all required services are running and accessible before proceeding with data flow testing.

## Test Objective
Ensure all Docker containers are healthy and all services are accessible on their respective ports.

## Prerequisites
- Docker and Docker Compose installed
- Node.js installed (for PowerShell MQTT testing scripts)
- Project cloned and environment variables configured
- All services started with `docker-compose up -d`
- PowerShell execution policy set to allow script execution

## Test Steps

### Step 1: Verify Docker Compose Services Status

**Command:**
```powershell
docker-compose ps
```

**Expected Output:**
```
NAME                COMMAND                  SERVICE             STATUS              PORTS
iot-mosquitto       "/docker-entrypoint.…"   mosquitto           Up (healthy)        0.0.0.0:1883->1883/tcp, 0.0.0.0:9001->9001/tcp
iot-influxdb3       "/entrypoint.sh --ob…"   influxdb            Up (healthy)        0.0.0.0:8086->8086/tcp
iot-node-red        "/bin/bash /startup.…"   node-red            Up (healthy)        0.0.0.0:1880->1880/tcp
iot-grafana         "/run.sh"                grafana             Up (healthy)        0.0.0.0:3000->3000/tcp
```

**Success Criteria:**
- All services show "Up (healthy)" status
- All ports are correctly mapped
- No error messages in the output

### Step 2: Check Service Health Endpoints

#### 2.1 MQTT Broker Health Check
**Command:**
```powershell
# Using PowerShell MQTT test script
.\test-mqtt.ps1 -PublishTest -Topic "system/health/mosquitto" -Message "health_check"
```

**Expected Result:**
- Command executes without errors
- No connection refused messages
- MQTT package installs successfully

#### 2.2 InfluxDB Health Check
**Command:**
```powershell
Invoke-WebRequest -Uri http://localhost:8086/health -UseBasicParsing
```

**Expected Result:**
- Returns HTTP 200 OK
- JSON response indicating service is healthy

#### 2.3 Node-RED Health Check
**Command:**
```powershell
Invoke-WebRequest -Uri http://localhost:1880 -UseBasicParsing
```

**Expected Result:**
- Returns HTTP 200 OK
- Node-RED interface loads successfully

#### 2.4 Grafana Health Check
**Command:**
```powershell
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
```

**Expected Result:**
- Returns HTTP 200 OK
- JSON response with "ok" status

### Step 3: Verify Network Connectivity

#### 3.1 Test MQTT Port (1883)
**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 1883
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors

#### 3.2 Test MQTT WebSocket Port (9001)
**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 9001
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors

#### 3.3 Test InfluxDB Port (8086)
**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 8086
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors

#### 3.4 Test Node-RED Port (1880)
**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 1880
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors

#### 3.5 Test Grafana Port (3000)
**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 3000
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors

### Step 4: Check Service Logs for Errors

#### 4.1 MQTT Broker Logs
**Command:**
```powershell
docker-compose logs mosquitto --tail=20
```

**Expected Result:**
- No error messages
- Service started successfully
- Authentication configured properly

#### 4.2 InfluxDB Logs
**Command:**
```powershell
docker-compose logs influxdb --tail=20
```

**Expected Result:**
- No error messages
- Database initialized successfully
- Ready to accept connections

#### 4.3 Node-RED Logs
**Command:**
```powershell
docker-compose logs node-red --tail=20
```

**Expected Result:**
- No error messages
- Flows deployed successfully
- Ready to process messages
- Service started successfully

#### 4.4 Grafana Logs
**Command:**
```powershell
docker-compose logs grafana --tail=20
```

**Expected Result:**
- No error messages
- Service started successfully
- Ready to serve dashboards

### Step 5: Verify PowerShell Testing Setup

#### 5.1 Check Node.js Installation
**Command:**
```powershell
node --version
npm --version
```

**Expected Result:**
- Node.js version 18.0.0 or higher
- npm version 8.0.0 or higher
- No "command not found" errors

#### 5.2 Install MQTT Testing Dependencies
**Command:**
```powershell
cd tests\manual-tests
npm install
```

**Expected Result:**
- MQTT package installed successfully
- No error messages during installation
- `node_modules` directory created

#### 5.3 Test PowerShell Scripts
**Command:**
```powershell
# Test basic MQTT connectivity
.\test-mqtt.ps1 -PublishTest -Topic "test/prerequisites" -Message "prerequisites_check"
```

**Expected Result:**
- Script executes without errors
- MQTT message published successfully
- No authentication or connection errors

### Step 6: Verify Environment Variables

**Command:**
```powershell
Get-Content .env
```

**Expected Result:**
- All required environment variables are set
- No empty or undefined values
- Credentials are properly configured

## Test Results Documentation

### Pass Criteria
- All services show "Up (healthy)" status
- All health endpoints return 200 OK
- All network ports are accessible
- No error messages in service logs
- Node.js and npm are properly installed
- MQTT testing dependencies installed successfully
- PowerShell scripts execute without errors
- Environment variables are properly configured

### Fail Criteria
- Any service shows "unhealthy" or "exited" status
- Any health endpoint returns error
- Any network port is not accessible
- Error messages in service logs
- Node.js or npm not installed or wrong version
- MQTT testing dependencies fail to install
- PowerShell scripts fail to execute
- Missing or incorrect environment variables

## Troubleshooting

### Common Issues

#### 1. Services Not Starting
**Problem:** Services fail to start or show "unhealthy" status
**Solution:**
```powershell
# Restart all services
docker-compose down
docker-compose up -d

# Check logs for specific errors
docker-compose logs [service-name]
```

#### 2. Port Conflicts
**Problem:** Port already in use error
**Solution:**
```powershell
# Check what's using the port
netstat -ano | findstr :1883

# Stop conflicting service or change port in docker-compose.yml
```

#### 3. Authentication Issues
**Problem:** MQTT authentication failures
**Solution:**
```powershell
# Regenerate password file
docker-compose exec mosquitto mosquitto_passwd -b /mosquitto/config/passwd admin admin_password_456
```

#### 4. Node-RED Health Check Issues
**Problem:** Node-RED health endpoint not available
**Solution:**
```powershell
# Check if Node-RED is accessible via main interface
Invoke-WebRequest -Uri http://localhost:1880 -UseBasicParsing

# Check Node-RED logs for startup issues
docker-compose logs node-red

# Restart Node-RED if needed
docker-compose restart node-red
```

#### 4. PowerShell Script Issues
**Problem:** PowerShell scripts fail to execute
**Solution:**
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set execution policy if needed (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify Node.js installation
node --version
npm --version

# Reinstall MQTT dependencies
cd tests\manual-tests
Remove-Item node_modules -Recurse -Force
npm install
```

#### 5. MQTT Package Installation Issues
**Problem:** npm install fails for MQTT package
**Solution:**
```powershell
# Clear npm cache
npm cache clean --force

# Update npm
npm install -g npm@latest

# Try installing with verbose output
npm install --verbose
```

## Next Steps
If all prerequisites pass, proceed to:
- [Manual Test 02: MQTT Broker Testing](./02-mqtt-broker-testing.md)
- [Manual Test 03: Node-RED Data Processing](./03-node-red-data-processing.md)
- [Manual Test 04: InfluxDB Data Storage](./04-influxdb-data-storage.md)
- [Manual Test 05: Grafana Data Visualization](./05-grafana-data-visualization.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ All services healthy
□ All ports accessible
□ All health endpoints responding (InfluxDB, Grafana)
□ Node-RED interface accessible
□ No errors in logs
□ Node.js and npm installed
□ MQTT testing dependencies installed
□ PowerShell scripts working
□ Environment variables configured

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 