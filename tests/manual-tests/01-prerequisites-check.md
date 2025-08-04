# Manual Test 01: Prerequisites Check

## Overview
This test verifies that all required services are running and accessible before proceeding with data flow testing.

**🔍 What This Test Does:**
Think of this test as a "pre-flight checklist" for your IoT system. Just like pilots check their instruments before takeoff, we need to verify that all the software components of your renewable energy monitoring system are working properly before we start sending data through it.

**🏗️ Why This Matters:**
In IoT systems, data flows through multiple services (MQTT broker → Node-RED → InfluxDB → Grafana). If any one service is broken, the entire data pipeline fails. This test ensures everything is ready before we start testing the actual data flow.

## Technical Architecture Overview

### System Architecture Components
The IoT monitoring system follows a **microservices architecture** with the following key components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   MQTT Broker   │───▶│   Node-RED      │───▶│   InfluxDB      │
│                 │    │   (Mosquitto)   │    │   (Processing)  │    │   (Time Series) │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                                              │
                                                                              ▼
                                                                     ┌─────────────────┐
                                                                     │   Grafana       │
                                                                     │   (Visualization)│
                                                                     └─────────────────┘
```

### Network Topology
- **Container Network**: `plat-edu-bad-data-mvp_iot-network` (Docker bridge network)
- **Port Mappings**: Host-to-container port forwarding for external access
- **Service Discovery**: Internal container communication via service names
- **Load Balancing**: Single-instance deployment (scalable to multi-instance)

### Data Flow Architecture
1. **Ingestion Layer**: MQTT broker receives device telemetry
2. **Processing Layer**: Node-RED transforms and validates data
3. **Storage Layer**: InfluxDB stores time-series data with retention policies
4. **Presentation Layer**: Grafana provides real-time dashboards and analytics

## Test Objective
Ensure all Docker containers are healthy and all services are accessible on their respective ports.

**🎯 What We're Checking:**
- **Docker Containers**: Are all our software services running properly?
- **Network Ports**: Can we communicate with each service?
- **Health Endpoints**: Are the services responding to health checks?
- **Dependencies**: Do we have all the required software installed?

## Prerequisites
- Docker and Docker Compose installed
- Node.js installed (for PowerShell MQTT testing scripts)
- Project cloned and environment variables configured
- All services started with `docker-compose up -d`
- PowerShell execution policy set to allow script execution
- Testing framework available in `tests/scripts/` directory

**📋 What These Prerequisites Mean:**
- **Docker**: A tool that packages software into containers (like shipping containers for code)
- **Docker Compose**: A tool that manages multiple containers working together
- **Node.js**: A JavaScript runtime that our testing scripts need
- **Environment Variables**: Configuration settings stored in a `.env` file

## Technical Prerequisites

### System Requirements
- **Operating System**: Windows 10/11, Linux (Ubuntu 20.04+), macOS 10.15+
- **Docker Engine**: Version 20.10+ with Docker Compose v2.0+
- **Node.js**: Version 18.0+ (LTS recommended)
- **PowerShell**: Version 5.1+ (Windows) or PowerShell Core 7.0+ (cross-platform)
- **Memory**: Minimum 4GB RAM, 8GB recommended
- **Storage**: 10GB free space for containers and data
- **Network**: Local network access for container communication

### Security Considerations
- **Container Isolation**: Each service runs in isolated containers
- **Network Security**: Internal container communication via Docker network
- **Authentication**: MQTT broker requires username/password authentication
- **TLS/SSL**: Optional encryption for production deployments
- **Access Control**: Grafana and InfluxDB require proper authentication

### Performance Considerations
- **Resource Allocation**: Docker containers have memory and CPU limits
- **Data Retention**: InfluxDB configured with 30-day retention policy
- **Query Optimization**: Flux queries optimized for time-series data
- **Caching**: Grafana implements query result caching
- **Monitoring**: Container resource usage monitoring via Docker stats

## Automated Testing Framework

### Quick System Validation - ! tests don't work !
Before running manual tests, you can use the automated testing framework for quick validation:

```powershell
# Run comprehensive health checks 
.\tests\scripts\test-influxdb-health.ps1 

# Run data flow test (includes all component validation)
.\tests\scripts\test-data-flow.ps1

# Run integration tests (includes connectivity validation)
.\tests\scripts\test-integration.ps1

# Run all tests
.\tests\run-all-tests.ps1
```

**🤖 What These Scripts Do:**
These are automated test scripts that do the same checks we'll do manually, but faster and more consistently. They're like having a robot assistant that can quickly check if everything is working.

### Test Framework Features
- **Health Checks**: Service status, connectivity, authentication
- **Data Flow**: End-to-end testing from MQTT to Grafana
- **Integration**: Cross-component connectivity validation
- **Performance**: Load testing and benchmarking

## Test Steps

### Step 1: Verify Docker Compose Services Status

**🔍 What This Step Does:**
This step checks if all our software services are running properly. Think of Docker containers as individual computers running specific software - we need to make sure they're all "turned on" and working.

**💡 Why This Matters:**
If any service isn't running, data can't flow through the system. For example, if the MQTT broker isn't running, devices can't send their data.

**Command:**
```powershell
docker-compose ps
```

**📊 What This Command Does:**
- `docker-compose`: Manages multiple containers
- `ps`: Shows the status of all containers (like "process status")

**Expected Output:**
```
NAME                COMMAND                  SERVICE             STATUS              PORTS
iot-mosquitto       "/docker-entrypoint.…"   mosquitto           Up (healthy)        0.0.0.0:1883->1883/tcp, 0.0.0.0:9001->9001/tcp
iot-influxdb2       "/entrypoint.sh /usr…"   influxdb            Up (healthy)        0.0.0.0:8086->8086/tcp
iot-node-red        "/bin/bash /startup.…"   node-red            Up (healthy)        0.0.0.0:1880->1880/tcp
iot-grafana         "/run.sh"                grafana             Up (healthy)        0.0.0.0:3000->3000/tcp
```

**📋 Understanding the Output:**
- **NAME**: The name of each container
- **STATUS**: "Up (healthy)" means the service is running and responding to health checks
- **PORTS**: Shows which ports are mapped (e.g., 1883:1883 means port 1883 on your computer connects to port 1883 in the container)

**Success Criteria:**
- All services show "Up (healthy)" status
- All ports are correctly mapped
- No error messages in the output

### Step 2: Check Service Health Endpoints

**🔍 What This Step Does:**
Each service has a special URL (called a "health endpoint") that tells us if it's working properly. It's like checking if a car's engine is running by listening to it.

#### 2.1 MQTT Broker Health Check
**🔍 What This Does:**
Tests if the MQTT broker (Mosquitto) can receive and process messages. The MQTT broker is like a post office for IoT devices - it receives messages from devices and delivers them to the right destinations.

**Command:**
```powershell
# Using PowerShell MQTT test script
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "system/health/mosquitto" -Message "health_check"
```

**📋 Understanding the Command:**
- `-PublishTest`: We're testing if we can send a message
- `-Topic`: The "address" where we're sending the message (like a mailbox)
- `-Message`: The actual message we're sending

**Expected Result:**
- Command executes without errors
- No connection refused messages
- MQTT package installs successfully

#### 2.2 InfluxDB Health Check
**🔍 What This Does:**
Tests if the InfluxDB database is ready to store data. InfluxDB is like a specialized filing cabinet for time-series data (data that changes over time, like temperature readings).

**Command:**
```powershell
# Option 1: Using automated health check script (automated test don't work)
.\tests\scripts\test-influxdb-health.ps1

# Option 2: Manual health check
Invoke-WebRequest -Uri http://localhost:8086/health -UseBasicParsing
```

**📋 Understanding the Command:**
- `Invoke-WebRequest`: PowerShell command to make an HTTP request
- `http://localhost:8086/health`: The health check URL for InfluxDB
- `localhost:8086`: The address where InfluxDB is running

**Expected Result:**
- Returns HTTP 200 OK
- JSON response indicating service is healthy

#### 2.3 Node-RED Health Check
**🔍 What This Does:**
Tests if Node-RED is accessible. Node-RED is like a smart router that processes data - it receives data from the MQTT broker, processes it, and sends it to InfluxDB.

**Command:**
```powershell
Invoke-WebRequest -Uri http://localhost:1880 -UseBasicParsing
```

**📋 Understanding the Command:**
- `http://localhost:1880`: The web interface for Node-RED
- Port 1880 is where Node-RED's web interface runs

**Expected Result:**
- Returns HTTP 200 OK
- Node-RED interface loads successfully

#### 2.4 Grafana Health Check
**🔍 What This Does:**
Tests if Grafana is accessible. Grafana is like a dashboard that displays charts and graphs of your data - it reads data from InfluxDB and shows it in a visual format.

**Command:**
```powershell
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
```

**📋 Understanding the Command:**
- `http://localhost:3000/api/health`: The health check URL for Grafana
- Port 3000 is where Grafana runs

**Expected Result:**
- Returns HTTP 200 OK
- JSON response with "ok" status

### Step 3: Verify Network Connectivity

**🔍 What This Step Does:**
Tests if we can actually connect to each service over the network at the TCP/IP level. This is like checking if the electrical wiring in a building is working - it's a more fundamental test than checking if the lights turn on.

**💡 Why This Is Different From Health Checks:**
- **Health Checks (Step 2)**: Test if the service is running and responding to HTTP requests (like checking if a light bulb works)
- **Network Connectivity (Step 3)**: Test if the network connection itself is working (like checking if electricity is flowing to the socket)

**🏗️ Why This Matters:**
Network connectivity tests are more basic and fundamental than health checks. They help you identify:
- **Network Issues**: Problems with the network layer (TCP/IP)
- **Port Conflicts**: Other applications using the same ports
- **Firewall Problems**: Security software blocking connections
- **Service Startup Issues**: Services that aren't listening on their ports

**📋 Understanding the Difference:**

| Test Type | What It Tests | Example | When It Fails |
|-----------|---------------|---------|---------------|
| **Health Check** | Service is running and responding | `Invoke-WebRequest -Uri http://localhost:8086/health` | Service is down, misconfigured, or overloaded |
| **Network Connectivity** | Network connection is possible | `Test-NetConnection -ComputerName localhost -Port 8086` | Port is blocked, service not listening, network issues |

#### 3.1 Test MQTT Port (1883)
**🔍 What This Does:**
Tests if port 1883 (where MQTT broker listens) is accessible at the network level. This is the main communication port for IoT devices.

**💡 Why This Matters:**
MQTT port 1883 is critical because:
- **Device Communication**: All your renewable energy devices connect here
- **Data Flow**: This is where the data pipeline starts
- **Real-time Monitoring**: Devices send data every few seconds

**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 1883
```

**📋 Understanding the Command:**
- `Test-NetConnection`: PowerShell command that tests TCP connectivity (like a network cable tester)
- `localhost`: Your own computer (127.0.0.1)
- `Port 1883`: The specific port where MQTT broker should be listening

**📊 What This Command Does:**
1. **Attempts TCP Connection**: Tries to establish a TCP connection to port 1883
2. **Checks Port Status**: Verifies if something is listening on that port
3. **Reports Results**: Tells you if the connection succeeded or failed

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors
- Port is open and listening

#### 3.2 Test MQTT WebSocket Port (9001)
**🔍 What This Does:**
Tests if port 9001 (MQTT WebSocket) is accessible. WebSocket allows web browsers to connect to MQTT for web-based monitoring.

**💡 Why This Matters:**
WebSocket port 9001 enables:
- **Web-based MQTT Clients**: Browser-based tools can connect to MQTT
- **Real-time Web Dashboards**: Web applications can receive live data
- **Development Tools**: Web-based MQTT testing and debugging

**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 9001
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors
- Port is open and listening

#### 3.3 Test InfluxDB Port (8086)
**🔍 What This Does:**
Tests if port 8086 (InfluxDB API) is accessible at the network level. This is where applications send data to be stored.

**💡 Why This Matters:**
InfluxDB port 8086 is critical because:
- **Data Storage**: All processed data gets sent here
- **API Access**: Node-RED and other applications connect here
- **Query Interface**: Grafana and other tools query data from here

**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 8086
```

**📋 Understanding the Command:**
- Tests if InfluxDB is listening for connections on port 8086
- Verifies the network path to the database is open
- Ensures no firewall or security software is blocking the connection

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors
- Port is open and listening

#### 3.4 Test Node-RED Port (1880)
**🔍 What This Does:**
Tests if port 1880 (Node-RED web interface) is accessible at the network level. This is where you configure data processing flows.

**💡 Why This Matters:**
Node-RED port 1880 is important because:
- **Flow Configuration**: You need this to set up data processing
- **Debugging**: Monitor data flow and troubleshoot issues
- **Development**: Create and modify data processing logic

**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 1880
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors
- Port is open and listening

#### 3.5 Test Grafana Port (3000)
**🔍 What This Does:**
Tests if port 3000 (Grafana web interface) is accessible at the network level. This is where you view dashboards and charts.

**💡 Why This Matters:**
Grafana port 3000 is essential because:
- **Data Visualization**: This is where you see your monitoring data
- **Dashboard Access**: All your charts and graphs are displayed here
- **User Interface**: Primary way to interact with your monitoring system

**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 3000
```

**Expected Result:**
- TcpTestSucceeded: True
- No connection errors
- Port is open and listening

**🔧 Troubleshooting Network Connectivity Issues:**

If any of these tests fail, here's what it might mean:

| Symptom | Possible Cause | Solution |
|---------|---------------|----------|
| **TcpTestSucceeded: False** | Service not running | Start the service with `docker-compose up -d` |
| **Connection Refused** | Port not listening | Check if service started properly |
| **Connection Timed Out** | Firewall blocking | Check Windows Firewall settings |
| **Address Already in Use** | Port conflict | Find what's using the port with `netstat -ano \| findstr :1883` |

### Step 4: Check Service Logs for Errors

**🔍 What This Step Does:**
Looks at the "log files" of each service to see if there are any error messages. Logs are like a diary that each service keeps - they record what the service is doing and any problems it encounters.

#### 🤖 Automated Alternative: Use the Automated Script

**💡 Quick Option:**
Instead of manually checking each service's logs, you can use the automated script that does all the checking for you:

```powershell
# Navigate to auto-tests directory
cd tests\auto-tests

# Run the automated logs check script
.\01-step-4-docker-logs.ps1


# Run from project root
cd tests\auto-tests\01-step-4-docker-logs.ps1

```

**🎯 What the Automated Script Does:**
- ✅ **Checks all 4 services** automatically (Mosquitto, InfluxDB, Node-RED, Grafana)
- ✅ **Searches for error patterns** in log files (error, failed, exception, fatal, panic)
- ✅ **Provides colored output** for easy reading
- ✅ **Generates a summary report** of all services
- ✅ **Exits with proper codes** (0 for success, 1 for failures)

**📋 Usage Examples:**
```powershell
# Basic usage (checks last 20 lines of each service)
.\01-step-4-docker-logs.ps1

# Check more log lines (e.g., last 50 lines)
.\01-step-4-docker-logs.ps1 -LogLines 50

# Show all logs (not just last N lines)
.\01-step-4-docker-logs.ps1 -ShowAllLogs
```

**📊 Expected Output:**
```
🚀 Starting Docker Logs Check (Step 4 from Prerequisites Test)
===============================================================

🔍 Checking MQTT Broker (Mosquitto) logs...
✅ MQTT Broker (Mosquitto) logs retrieved successfully
✅ No errors found in MQTT Broker (Mosquitto) logs

🔍 Checking InfluxDB Database logs...
✅ InfluxDB Database logs retrieved successfully
✅ No errors found in InfluxDB Database logs

📊 Test Summary
===============
✅ Mosquitto: PASSED
✅ InfluxDB: PASSED
✅ Node-RED: PASSED
✅ Grafana: PASSED

📈 Overall Results:
   Passed: 4 service(s)
   Failed: 0 service(s)

🎉 All services are healthy! No errors found in logs.
```

**🔧 Manual Alternative:**
If you prefer to check logs manually or need to see specific details, continue with the manual steps below.

#### 4.1 MQTT Broker Logs
**🔍 What This Does:**
Checks the MQTT broker's log for any startup errors or authentication issues.

**Command:**
```powershell
docker-compose logs mosquitto --tail=20
```

**📋 Understanding the Command:**
- `docker-compose logs`: Shows log files from containers
- `mosquitto`: The specific service we want logs from
- `--tail=20`: Shows only the last 20 lines of logs

**Expected Result:**
- No error messages
- Service started successfully
- Authentication configured properly

#### 4.2 InfluxDB Logs
**🔍 What This Does:**
Checks if InfluxDB started properly and is ready to accept data.

**Command:**
```powershell
docker-compose logs influxdb --tail=20
```

**Expected Result:**
- No error messages
- Database initialized successfully
- Ready to accept connections

#### 4.3 Node-RED Logs
**🔍 What This Does:**
Checks if Node-RED started properly and deployed all the data processing flows.

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
**🔍 What This Does:**
Checks if Grafana started properly and is ready to serve dashboards.

**Command:**
```powershell
docker-compose logs grafana --tail=20
```

**Expected Result:**
- No error messages
- Service started successfully
- Ready to serve dashboards

### Step 5: Verify PowerShell Testing Setup

**🔍 What This Step Does:**
Ensures that PowerShell and Node.js are properly installed and configured for running our automated tests.

#### 5.1 Check Node.js Installation
**🔍 What This Does:**
Verifies that Node.js (JavaScript runtime) is installed and working. Our testing scripts need Node.js to run.

**Command:**
```powershell
node --version
npm --version
```

**📋 Understanding the Command:**
- `node --version`: Shows the version of Node.js installed
- `npm --version`: Shows the version of npm (Node Package Manager) installed

**Expected Result:**
- Node.js version 18.0.0 or higher
- npm version 8.0.0 or higher
- No "command not found" errors

#### 5.2 Install MQTT Testing Dependencies
**🔍 What This Does:**
Installs the MQTT library that our PowerShell testing scripts need to communicate with the MQTT broker.

**Command:**
```powershell
cd tests\manual-tests
npm install
```

**📋 Understanding the Command:**
- `cd tests\manual-tests`: Changes directory to the testing folder
- `npm install`: Installs all the required packages listed in package.json

**Expected Result:**
- MQTT package installed successfully
- No error messages during installation
- `node_modules` directory created

#### 5.3 Test PowerShell Scripts
**🔍 What This Does:**
Tests if our automated testing scripts can actually connect to the MQTT broker and send messages.

**Command:**
```powershell
# Test basic MQTT connectivity
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/prerequisites" -Message "prerequisites_check"

# Test automated health checks
.\tests\scripts\test-influxdb-health.ps1
```

**Expected Result:**
- Script executes without errors
- MQTT message published successfully
- No authentication or connection errors

### Step 6: Verify Environment Variables

**🔍 What This Step Does:**
Checks if all the configuration settings (like passwords, database names, etc.) are properly set up.

**Command:**
```powershell
Get-Content .env
```

**📋 Understanding the Command:**
- `Get-Content`: Reads the contents of a file
- `.env`: The environment variables file that contains configuration settings

**Expected Result:**
- All required environment variables are set
- No empty or undefined values
- Credentials are properly configured

## Advanced Technical Validation

### Container Resource Monitoring
Monitor container resource usage to ensure optimal performance:

```powershell
# Check container resource usage
docker stats --no-stream

# Check container disk usage
docker system df

# Monitor specific container
docker stats iot-influxdb2 --no-stream
```

### Network Performance Testing
Test network latency and throughput between containers:

```powershell
# Test network connectivity between containers
docker exec iot-node-red ping -c 4 iot-influxdb2

# Test MQTT broker performance
docker exec iot-mosquitto mosquitto_sub -h localhost -t test/performance -v
```

### Database Performance Validation
Validate InfluxDB performance and configuration:

```powershell
# Check InfluxDB configuration
docker exec iot-influxdb2 influx config

# Test InfluxDB write performance
docker exec iot-influxdb2 influx write -b renewable_energy -o renewable_energy_org -p ns "test,host=server1 value=1"
```

### Security Validation
Verify security configurations and access controls:

```powershell
# Check MQTT authentication
docker exec iot-mosquitto mosquitto_passwd -U /mosquitto/config/passwd

# Verify InfluxDB authentication
curl -H "Authorization: Token $env:INFLUXDB_TOKEN" http://localhost:8086/api/v2/users
```

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
**🔍 What This Means:** One or more Docker containers couldn't start properly, usually due to configuration issues or resource problems.

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
**🔍 What This Means:** Another application is already using the port that our service needs (like port 1883 for MQTT).

**Solution:**
```powershell
# Check what's using the port
netstat -ano | findstr :1883

# Stop conflicting service or change port in docker-compose.yml
```

#### 3. Authentication Issues
**Problem:** MQTT authentication failures
**🔍 What This Means:** The MQTT broker can't verify the username/password, usually due to incorrect configuration.

**Solution:**
```powershell
# Regenerate password file
docker-compose exec mosquitto mosquitto_passwd -b /mosquitto/config/passwd admin admin_password_456
```

#### 4. Node-RED Health Check Issues
**Problem:** Node-RED health endpoint not available
**🔍 What This Means:** Node-RED might not be fully started or there's a configuration issue.

**Solution:**
```powershell
# Run automated integration tests for diagnostics
.\tests\scripts\test-integration.ps1

# Check if Node-RED is accessible via main interface
Invoke-WebRequest -Uri http://localhost:1880 -UseBasicParsing

# Check Node-RED logs for startup issues
docker-compose logs node-red

# Restart Node-RED if needed
docker-compose restart node-red
```

#### 4. PowerShell Script Issues
**Problem:** PowerShell scripts fail to execute
**🔍 What This Means:** PowerShell execution policy might be blocking scripts, or Node.js isn't properly installed.

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
cd tests\scripts
Remove-Item node_modules -Recurse -Force
npm install
```

#### 5. MQTT Package Installation Issues
**Problem:** npm install fails for MQTT package
**🔍 What This Means:** There might be network issues, npm cache problems, or version conflicts.

**Solution:**
```powershell
# Clear npm cache
npm cache clean --force

# Update npm
npm install -g npm@latest

# Try installing with verbose output
npm install --verbose
```

## Professional Best Practices

### Monitoring and Alerting
- **Health Check Automation**: Implement automated health checks with alerting
- **Log Aggregation**: Centralize logs for better troubleshooting
- **Metrics Collection**: Monitor system performance and resource usage
- **Backup Strategies**: Implement regular backups of configuration and data

### Security Best Practices
- **Network Segmentation**: Isolate IoT devices from critical infrastructure
- **Access Control**: Implement proper authentication and authorization
- **Encryption**: Use TLS/SSL for data in transit
- **Regular Updates**: Keep containers and dependencies updated

### Performance Optimization
- **Resource Limits**: Set appropriate memory and CPU limits for containers
- **Data Retention**: Configure optimal retention policies for time-series data
- **Query Optimization**: Optimize Flux queries for better performance
- **Caching**: Implement appropriate caching strategies

### Disaster Recovery
- **Backup Procedures**: Regular backups of InfluxDB data and configurations
- **Recovery Testing**: Test recovery procedures regularly
- **Documentation**: Maintain up-to-date documentation of procedures
- **Incident Response**: Have procedures for handling system failures

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