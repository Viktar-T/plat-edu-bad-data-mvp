# Manual Test 02: MQTT Broker Testing

## Overview
This test verifies the MQTT broker functionality, including authentication, topic publishing/subscribing, and message routing for the renewable energy monitoring system.

## Test Objective
Ensure MQTT broker (Mosquitto) is properly configured with authentication, access control, and can handle device communications.

## Prerequisites
- Manual Test 01 completed successfully
- Node.js installed (for PowerShell MQTT testing scripts)
- MQTT broker running on localhost:1883
- PowerShell execution policy set to allow script execution

## Test Steps

### Step 0: PowerShell MQTT Testing Setup

#### 0.1 Install Dependencies
**Command:**
```powershell
# Navigate to manual-tests directory
cd tests\manual-tests

# Install MQTT package for Node.js
npm install
```

**Expected Result:**
- MQTT package installed successfully
- No error messages

#### 0.1 MQTT Broker Health Check
**Command:**
```powershell
# Using PowerShell MQTT test script
.\test-mqtt.ps1 -PublishTest -Topic "system/health/mosquitto" -Message "health_check"
```

#### 0.2 example of Manual MQTT Communication
**Explanation**

**Command:**
```powershell
# Publish a message
.\test-mqtt.ps1 -PublishTest -MqttHost "localhost" -Topic "test/hello" -Message "Hello World!"

# Subscribe to a topic
.\test-mqtt.ps1 -Subscribe -MqttHost "localhost" -Topic "test/hello"
```

**Expected Result:**
Terminal 1 (Publisher): You published messages to the test/hello topic
Terminal 2 (Subscriber): You subscribed to the same topic and received all published messages
MQTT Broker: Your Mosquitto broker (running on localhost:1883) acted as the central message router

#### 0.2 Test PowerShell Scripts
**Command:**
```powershell
# Test basic MQTT connectivity
.\test-mqtt.ps1 -PublishTest -Topic "test/connectivity" -Message "Hello World!"

# Test device simulation
.\simulate-devices.ps1 -Photovoltaic -Duration 30
```

**Expected Result:**
- Both scripts run without errors
- MQTT messages are published successfully

### Step 1: Basic MQTT Connectivity Test

#### 1.1 Test Anonymous Connection (Should Fail)
**Command:**
```powershell
# Using PowerShell MQTT test script
.\test-mqtt.ps1 -PublishTest -Topic "test/anonymous" -Message "test message"
```

**Expected Result:**
- Connection should be rejected
- Error message about authentication required

#### 1.2 Test Admin Authentication
**Command:**
```powershell
# Using PowerShell MQTT test script
.\test-mqtt.ps1 -PublishTest -Topic "test/admin" -Message "admin test message"
```

**Expected Result:**
- Message published successfully
- No error messages

### Step 2: Device Authentication Testing

#### 2.1 Test Photovoltaic Device Authentication
**Command:**
```powershell
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"device_id":"pv_001","test":"authentication"}'
```

**Expected Result:**
- Message published successfully
- No authentication errors

#### 2.2 Test Wind Turbine Device Authentication
**Command:**
```powershell
mosquitto_pub -h localhost -p 1883 -u wt_001 -P device_password_123 -t devices/wind_turbine/wt_001/data -m '{"device_id":"wt_001","test":"authentication"}'
```

**Expected Result:**
- Message published successfully
- No authentication errors

#### 2.3 Test Biogas Plant Device Authentication
**Command:**
```powershell
mosquitto_pub -h localhost -p 1883 -u bg_001 -P device_password_123 -t devices/biogas_plant/bg_001/data -m '{"device_id":"bg_001","test":"authentication"}'
```

**Expected Result:**
- Message published successfully
- No authentication errors

### Step 3: Topic Structure and Access Control Testing

#### 3.1 Test Device-Specific Topic Access
**Command:**
```powershell
# Test photovoltaic device can only access its own topics
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"test":"own_topic"}'
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_002/data -m '{"test":"other_device_topic"}'
```

**Expected Result:**
- First command succeeds (own topic)
- Second command should fail (access denied to other device)

#### 3.2 Test Admin Access to All Topics
**Command:**
```powershell
# Admin should be able to publish to any topic
mosquitto_pub -h localhost -p 1883 -u admin -P admin_password_456 -t devices/photovoltaic/pv_001/data -m '{"test":"admin_access"}'
mosquitto_pub -h localhost -p 1883 -u admin -P admin_password_456 -t devices/wind_turbine/wt_001/data -m '{"test":"admin_access"}'
mosquitto_pub -h localhost -p 1883 -u admin -P admin_password_456 -t system/health/mosquitto -m '{"test":"admin_access"}'
```

**Expected Result:**
- All commands succeed
- No access denied errors

### Step 4: Message Publishing and Subscription Testing

#### 4.1 Test Message Publishing with QoS Levels
**Command:**
```powershell
# Test QoS 0 (At most once)
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"qos":"0","test":"qos_test"}' -q 0

# Test QoS 1 (At least once)
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"qos":"1","test":"qos_test"}' -q 1

# Test QoS 2 (Exactly once)
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"qos":"2","test":"qos_test"}' -q 2
```

**Expected Result:**
- All QoS levels work correctly
- No connection errors

#### 4.2 Test Message Subscription
Open a new PowerShell window and run:

**Command:**
```powershell
# Subscribe to photovoltaic device data
mosquitto_sub -h localhost -p 1883 -u pv_001 -P device_password_123 -t "devices/photovoltaic/pv_001/data" -v
```

**Expected Result:**
- Subscription established successfully
- Ready to receive messages

**In the original window, publish a test message:**
```powershell
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"test":"subscription","timestamp":"2024-01-15T10:30:00Z"}'
```

**Expected Result:**
- Message appears in the subscription window
- Message content is correct

### Step 5: Realistic Device Data Testing

#### 5.1 Test Photovoltaic Device Data Format
**Command:**
```powershell
$pvData = @{
    device_id = "pv_001"
    device_type = "photovoltaic"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        irradiance = 850.5
        temperature = 45.2
        voltage = 48.3
        current = 12.1
        power_output = 584.43
    }
    status = "operational"
    location = "site_a"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $pvData
```

**Expected Result:**
- Message published successfully
- JSON format is valid

#### 5.2 Test Wind Turbine Device Data Format
**Command:**
```powershell
$wtData = @{
    device_id = "wt_001"
    device_type = "wind_turbine"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        wind_speed = 12.5
        power_output = 850.2
        rpm = 1200
        temperature = 35.1
    }
    status = "operational"
    location = "site_b"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u wt_001 -P device_password_123 -t devices/wind_turbine/wt_001/data -m $wtData
```

**Expected Result:**
- Message published successfully
- JSON format is valid

#### 5.3 Test Biogas Plant Device Data Format
**Command:**
```powershell
$bgData = @{
    device_id = "bg_001"
    device_type = "biogas_plant"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        gas_flow = 25.5
        methane_concentration = 65.2
        temperature = 38.5
        pressure = 1.2
    }
    status = "operational"
    location = "site_c"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u bg_001 -P device_password_123 -t devices/biogas_plant/bg_001/data -m $bgData
```

**Expected Result:**
- Message published successfully
- JSON format is valid

### Step 6: System Topics Testing

#### 6.1 Test System Health Topic
**Command:**
```powershell
mosquitto_pub -h localhost -p 1883 -u admin -P admin_password_456 -t system/health/mosquitto -m '{"service":"mosquitto","status":"healthy","timestamp":"2024-01-15T10:30:00Z"}'
```

**Expected Result:**
- Message published successfully
- System health monitoring works

#### 6.2 Test System Alerts Topic
**Command:**
```powershell
mosquitto_pub -h localhost -p 1883 -u admin -P admin_password_456 -t system/alerts/warning -m '{"alert":"test_warning","message":"Test alert message","timestamp":"2024-01-15T10:30:00Z"}'
```

**Expected Result:**
- Message published successfully
- Alert system works

### Step 7: WebSocket Connectivity Testing

#### 7.1 Test WebSocket Port
**Command:**
```powershell
Test-NetConnection -ComputerName localhost -Port 9001
```

**Expected Result:**
- TcpTestSucceeded: True
- WebSocket port is accessible

#### 7.2 Test WebSocket MQTT Connection
**Command:**
```powershell
# Test WebSocket connection (requires WebSocket client)
# This can be tested using a browser-based MQTT client or WebSocket testing tool
```

**Expected Result:**
- WebSocket connection established
- MQTT over WebSocket works

### Step 8: Performance and Load Testing

#### 8.1 Test Multiple Concurrent Connections
**Command:**
```powershell
# Test multiple devices publishing simultaneously
Start-Job -ScriptBlock {
    for ($i = 1; $i -le 10; $i++) {
        mosquitto_pub -h localhost -p 1883 -u "pv_00$i" -P device_password_123 -t "devices/photovoltaic/pv_00$i/data" -m "test_message_$i"
        Start-Sleep -Milliseconds 100
    }
}

# Wait for jobs to complete
Get-Job | Wait-Job
Get-Job | Receive-Job
Get-Job | Remove-Job
```

**Expected Result:**
- All messages published successfully
- No connection errors or timeouts

#### 8.2 Test Message Throughput
**Command:**
```powershell
# Test rapid message publishing using PowerShell script
.\test-mqtt.ps1 -PublishTest -Topic "test/throughput" -Message "test_message"
```

**Expected Result:**
- All messages published successfully
- No performance degradation

### Step 9: Device Simulation Testing

#### 9.1 Test Photovoltaic Device Simulation
**Command:**
```powershell
# Simulate photovoltaic devices for 60 seconds
.\simulate-devices.ps1 -Photovoltaic -Duration 60 -Interval 2000
```

**Expected Result:**
- Realistic photovoltaic data published
- Data includes irradiance, temperature, voltage, current, power_output
- Messages sent every 2 seconds for 60 seconds

#### 9.2 Test Wind Turbine Device Simulation
**Command:**
```powershell
# Simulate wind turbine devices for 60 seconds
.\simulate-devices.ps1 -WindTurbine -Duration 60 -Interval 2000
```

**Expected Result:**
- Realistic wind turbine data published
- Data includes wind_speed, wind_direction, rotor_speed, power_output, temperature
- Messages sent every 2 seconds for 60 seconds

#### 9.3 Test All Device Types Simulation
**Command:**
```powershell
# Simulate all device types for 120 seconds
.\simulate-devices.ps1 -AllDevices -Duration 120 -Interval 5000
```

**Expected Result:**
- All device types simulated (photovoltaic, wind_turbine, biogas_plant, heat_boiler, energy_storage)
- Realistic data for each device type
- Messages sent every 5 seconds for 120 seconds
- Statistics displayed during and after simulation

#### 9.4 Test Device Simulation with Custom Parameters
**Command:**
```powershell
# Test with custom host and credentials
.\simulate-devices.ps1 -Host "192.168.1.100" -Port 1883 -Username "custom_user" -Password "custom_password" -Photovoltaic -Duration 30
```

**Expected Result:**
- Simulation connects to custom MQTT broker
- Uses custom authentication credentials
- Runs for specified duration

## Test Results Documentation

### Pass Criteria
- All authentication tests pass
- Topic access control works correctly
- Message publishing and subscription work
- All device data formats are accepted
- System topics work properly
- WebSocket connectivity is available
- Performance tests complete successfully

### Fail Criteria
- Any authentication test fails
- Topic access control violations
- Message publishing/subscription errors
- Invalid data format rejections
- System topic failures
- WebSocket connectivity issues
- Performance degradation or timeouts

## Troubleshooting

### Common Issues

#### 1. Authentication Failures
**Problem:** "Connection refused" or "Not authorized" errors
**Solution:**
```powershell
# Check password file
docker-compose exec mosquitto cat /mosquitto/config/passwd

# Regenerate password
docker-compose exec mosquitto mosquitto_passwd -b /mosquitto/config/passwd pv_001 device_password_123
```

#### 2. Topic Access Denied
**Problem:** "Topic not allowed" errors
**Solution:**
```powershell
# Check ACL file
docker-compose exec mosquitto cat /mosquitto/config/acl

# Restart mosquitto service
docker-compose restart mosquitto
```

#### 3. Connection Timeouts
**Problem:** Slow or failed connections
**Solution:**
```powershell
# Check mosquitto logs
docker-compose logs mosquitto

# Check system resources
docker stats
```

## Next Steps
If MQTT broker testing passes, proceed to:
- [Manual Test 03: Node-RED Data Processing](./03-node-red-data-processing.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ PowerShell MQTT testing setup
□ Basic connectivity
□ Authentication (admin)
□ Authentication (devices)
□ Topic access control
□ Message publishing
□ Message subscription
□ Device data formats
□ System topics
□ WebSocket connectivity
□ Performance tests
□ Photovoltaic device simulation
□ Wind turbine device simulation
□ All device types simulation
□ Custom parameter testing

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 