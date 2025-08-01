# Manual Test 02: MQTT Broker Testing

## Overview
This test verifies the MQTT broker functionality, including authentication, topic publishing/subscribing, and message routing for the renewable energy monitoring system.

**🔍 What This Test Does:**
This test checks if the MQTT broker (Mosquitto) is working correctly. Think of MQTT as the "post office" for your IoT devices - it receives messages from devices (like solar panels, wind turbines) and delivers them to the right destinations (like Node-RED for processing).

**🏗️ Why This Matters:**
MQTT is the communication backbone of your IoT system. If the MQTT broker isn't working, your renewable energy devices can't send their data, and the entire monitoring system breaks down. This test ensures the communication layer is solid.

## Technical Architecture Overview

### MQTT Protocol Fundamentals
MQTT (Message Queuing Telemetry Transport) is a lightweight, publish-subscribe messaging protocol designed for IoT applications:

**Protocol Characteristics:**
- **Transport Layer**: TCP/IP (port 1883) or WebSocket (port 9001)
- **Message Format**: Binary protocol with minimal overhead
- **QoS Levels**: 0 (At most once), 1 (At least once), 2 (Exactly once)
- **Retained Messages**: Last known good value for new subscribers
- **Will Messages**: Final message sent when client disconnects unexpectedly

### MQTT Broker Architecture (Mosquitto)
```
┌─────────────────────────────────────────────────────────────┐
│                    MQTT Broker (Mosquitto)                  │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Client    │  │   Client    │  │   Client    │         │
│  │ Management  │  │ Authentication│  │ Authorization│       │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Message   │  │   Topic     │  │   Message   │         │
│  │   Router    │  │   Matching  │  │   Queue     │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   TCP       │  │   WebSocket │  │   TLS/SSL   │         │
│  │   (1883)    │  │   (9001)    │  │   (8883)    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Topic Structure and Hierarchy
The MQTT topic structure follows a hierarchical pattern optimized for renewable energy monitoring:

```
devices/
├── photovoltaic/
│   ├── panel001/
│   │   ├── telemetry
│   │   ├── status
│   │   └── alerts
│   └── panel002/
│       ├── telemetry
│       ├── status
│       └── alerts
├── wind_turbine/
│   ├── turbine001/
│   │   ├── telemetry
│   │   ├── status
│   │   └── alerts
│   └── turbine002/
│       ├── telemetry
│       ├── status
│       └── alerts
├── energy_storage/
│   ├── battery001/
│   │   ├── telemetry
│   │   ├── status
│   │   └── alerts
│   └── battery002/
│       ├── telemetry
│       ├── status
│       └── alerts
└── system/
    ├── health
    ├── alerts
    └── maintenance
```

### Security Model
- **Authentication**: Username/password-based authentication
- **Authorization**: Access Control Lists (ACL) for topic-level permissions
- **Encryption**: Optional TLS/SSL for data in transit
- **Client Certificates**: X.509 certificate-based authentication (advanced)

## Test Objective
Ensure MQTT broker (Mosquitto) is properly configured with authentication, access control, and can handle device communications.

**🎯 What We're Checking:**
- **Authentication**: Can devices log in with username/password?
- **Message Publishing**: Can devices send messages to the broker?
- **Message Subscribing**: Can applications receive messages from the broker?
- **Topic Routing**: Are messages delivered to the right destinations?
- **Security**: Is the system protected from unauthorized access?

## Prerequisites
- Manual Test 01 completed successfully
- Node.js installed (for PowerShell MQTT testing scripts)
- MQTT broker running on localhost:1883
- PowerShell execution policy set to allow script execution
- Testing framework available in `tests/scripts/` directory

**📋 What These Prerequisites Mean:**
- **Test 01**: We've already verified that all services are running
- **Node.js**: Required for our MQTT testing scripts
- **MQTT Broker**: The Mosquitto service must be running
- **PowerShell**: Our testing environment

## Automated Testing Framework

### Quick MQTT Validation
Before running manual tests, you can use the automated testing framework for quick validation:

```powershell
# Run comprehensive MQTT testing
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/automated" -Message "automated_test"

# Run data flow test (includes MQTT validation)
.\tests\scripts\test-data-flow.ps1

# Run integration tests (includes MQTT connectivity)
.\tests\scripts\test-integration.ps1

# Run all tests
.\tests\run-all-tests.ps1
```

**🤖 What These Scripts Do:**
These automated scripts test MQTT functionality quickly and consistently. They're like having a robot that can send and receive messages to verify everything works.

### Test Framework Features
- **MQTT Connectivity**: Connection testing and message publishing
- **Data Flow**: End-to-end testing from MQTT to Grafana
- **Integration**: Cross-component connectivity validation
- **Performance**: Load testing and benchmarking

## Test Steps

### Step 0: PowerShell MQTT Testing Setup

#### 0.1 Install Dependencies
**🔍 What This Does:**
Installs the MQTT library that our PowerShell scripts need to communicate with the MQTT broker. Think of this as installing the "driver" for MQTT communication.

**Command:**
```powershell
# Navigate to scripts directory
cd tests\scripts

# Install MQTT package for Node.js
npm install
```

**📋 Understanding the Command:**
- `cd tests\scripts`: Changes to the directory containing our testing scripts
- `npm install`: Installs the MQTT library and other required packages

**Expected Result:**
- MQTT package installed successfully
- No error messages

#### 0.2 MQTT Broker Health Check
**🔍 What This Does:**
Tests if the MQTT broker is responding and can accept connections. This is like checking if the post office is open and ready to receive mail.

**Command:**
```powershell
# Using PowerShell MQTT test script
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "system/health/mosquitto" -Message "health_check"
```

**📋 Understanding the Command:**
- `-PublishTest`: We're testing if we can send a message
- `-Topic "system/health/mosquitto"`: The "mailbox" where we're sending the message
- `-Message "health_check"`: The actual message content

**Expected Result:**
- Command executes without errors
- Message is published successfully
- No connection refused messages

#### 0.3 Example of Manual MQTT Communication
**🔍 What This Demonstrates:**
This shows you how MQTT works in practice - one device sends a message (publishes) and another device receives it (subscribes). It's like having two people communicate through the post office.

**Explanation:**
MQTT uses a "publish/subscribe" model:
- **Publisher**: Sends messages to a specific "topic" (like a mailbox address)
- **Subscriber**: Receives messages from specific topics they're interested in
- **Broker**: Acts as the post office, routing messages between publishers and subscribers

**Command:**
```powershell
# Publish a message
.\tests\scripts\test-mqtt.ps1 -PublishTest -MqttHost "localhost" -Topic "test/hello" -Message "Hello World!"

# Subscribe to a topic
.\tests\scripts\test-mqtt.ps1 -Subscribe -MqttHost "localhost" -Topic "test/hello"
```

**📋 Understanding the Commands:**
- **Publisher**: Sends "Hello World!" to the "test/hello" topic
- **Subscriber**: Listens for any messages sent to "test/hello" topic
- **MqttHost "localhost"**: The address of our MQTT broker

**Expected Result:**
- **Terminal 1 (Publisher)**: Message "Hello World!" is sent successfully
- **Terminal 2 (Subscriber)**: Receives the "Hello World!" message
- **MQTT Broker**: Successfully routes the message from publisher to subscriber

#### 0.4 Test PowerShell Scripts
**🔍 What This Does:**
Verifies that our automated testing scripts can connect to the MQTT broker and perform basic operations.

**Command:**
```powershell
# Test basic MQTT connectivity
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/connectivity" -Message "Hello World!"

# Test device simulation (if available)
# .\tests\scripts\simulate-devices.ps1 -Photovoltaic -Duration 30
```

**Expected Result:**
- Both scripts run without errors
- MQTT messages are published successfully
- No authentication or connection errors

### Step 1: Basic MQTT Connectivity Test

#### 1.1 Test Anonymous Connection (Should Fail)
**🔍 What This Does:**
Tests that the MQTT broker properly rejects connections from devices that don't provide a username and password. This is a security test - we want to make sure unauthorized devices can't connect.

**💡 Why This Matters:**
In a real IoT system, you don't want just any device connecting to your MQTT broker. Authentication ensures only authorized devices (like your solar panels and wind turbines) can send data.

**Command:**
```powershell
# Test connection without authentication (should fail)
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/anonymous" -Message "anonymous_test" -NoAuth
```

**📋 Understanding the Command:**
- `-NoAuth`: Tells the script to try connecting without username/password
- This should fail because our MQTT broker requires authentication

**Expected Result:**
- Connection should be rejected
- Error message about authentication failure
- This is actually a "good" failure - it means security is working

#### 1.2 Test Authenticated Connection (Should Succeed)
**🔍 What This Does:**
Tests that the MQTT broker accepts connections from devices that provide the correct username and password.

**Command:**
```powershell
# Test connection with authentication (should succeed)
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/authenticated" -Message "authenticated_test"
```

**📋 Understanding the Command:**
- Uses the default username/password from our configuration
- Should successfully connect and publish a message

**Expected Result:**
- Connection successful
- Message published without errors
- No authentication errors

### Step 2: Topic Publishing and Subscribing Test

#### 2.1 Test Device Topic Publishing
**🔍 What This Does:**
Tests publishing messages to topics that simulate real renewable energy devices. This mimics how actual solar panels, wind turbines, etc. would send their data.

**💡 Why This Matters:**
In your IoT system, each device type has its own topic structure. For example:
- Solar panels: `devices/photovoltaic/panel001/telemetry`
- Wind turbines: `devices/wind_turbine/turbine001/telemetry`
- Energy storage: `devices/energy_storage/battery001/telemetry`

**Command:**
```powershell
# Test photovoltaic device topic
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/photovoltaic/panel001/telemetry" -Message '{"power": 1500, "voltage": 48.5, "current": 30.9}'

# Test wind turbine device topic
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/wind_turbine/turbine001/telemetry" -Message '{"power": 2000, "wind_speed": 12.5, "rpm": 1800}'

# Test energy storage device topic
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/energy_storage/battery001/telemetry" -Message '{"soc": 85.2, "voltage": 52.1, "temperature": 25.3}'
```

**📋 Understanding the Commands:**
- Each command publishes realistic device data to different topics
- The JSON messages contain actual sensor readings that devices would send
- Topics follow the pattern: `devices/{device_type}/{device_id}/telemetry`

**Expected Result:**
- All messages published successfully
- No connection or authentication errors
- Messages appear in MQTT broker logs

#### 2.2 Test Topic Subscribing
**🔍 What This Does:**
Tests that applications can subscribe to topics and receive messages. This simulates how Node-RED would listen for device data.

**Command:**
```powershell
# Subscribe to all device telemetry topics
.\tests\scripts\test-mqtt.ps1 -Subscribe -Topic "devices/+/+/telemetry"

# Subscribe to specific device type
.\tests\scripts\test-mqtt.ps1 -Subscribe -Topic "devices/photovoltaic/+/telemetry"

# Subscribe to specific device
.\tests\scripts\test-mqtt.ps1 -Subscribe -Topic "devices/photovoltaic/panel001/telemetry"
```

**📋 Understanding the Commands:**
- `+` is a wildcard that matches any single level in the topic
- `devices/+/+/telemetry` matches all device telemetry topics
- `devices/photovoltaic/+/telemetry` matches only photovoltaic device topics
- `devices/photovoltaic/panel001/telemetry` matches only the specific panel

**Expected Result:**
- Subscription successful
- Messages received when published to matching topics
- No connection errors

### Step 3: Message Quality of Service (QoS) Test

#### 3.1 Test QoS Levels
**🔍 What This Does:**
Tests different Quality of Service levels for message delivery. QoS determines how reliable message delivery should be.

**💡 Why This Matters:**
- **QoS 0**: "At most once" - Fast but may lose messages
- **QoS 1**: "At least once" - Reliable but may duplicate messages
- **QoS 2**: "Exactly once" - Most reliable but slowest

**Command:**
```powershell
# Test QoS 0 (fire and forget)
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/qos0" -Message "QoS 0 test" -QoS 0

# Test QoS 1 (at least once)
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/qos1" -Message "QoS 1 test" -QoS 1

# Test QoS 2 (exactly once)
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/qos2" -Message "QoS 2 test" -QoS 2
```

**Expected Result:**
- All QoS levels work correctly
- No connection errors
- Messages delivered according to QoS level

### Step 4: Retained Messages Test

#### 4.1 Test Retained Messages
**🔍 What This Does:**
Tests retained messages, which are stored by the MQTT broker and sent to new subscribers. This is useful for device status information.

**💡 Why This Matters:**
Retained messages are like "sticky notes" on the MQTT broker. When a new device connects and subscribes to a topic, it immediately gets the last retained message. This is useful for:
- Device status (online/offline)
- Current sensor readings
- Configuration information

**Command:**
```powershell
# Publish a retained message
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/photovoltaic/panel001/status" -Message '{"status": "online", "last_seen": "2024-01-15T10:30:00Z"}' -Retain

# Subscribe to the topic (should receive the retained message)
.\tests\scripts\test-mqtt.ps1 -Subscribe -Topic "devices/photovoltaic/panel001/status"
```

**📋 Understanding the Commands:**
- `-Retain`: Tells the broker to keep this message and send it to new subscribers
- The status message contains device information that new subscribers need

**Expected Result:**
- Retained message published successfully
- New subscribers receive the retained message immediately
- Message persists until a new retained message is published

### Step 5: Load Testing

#### 5.1 Test Multiple Concurrent Connections
**🔍 What This Does:**
Tests how the MQTT broker handles multiple devices connecting simultaneously. This simulates a real IoT environment with many devices.

**💡 Why This Matters:**
In a real renewable energy system, you might have hundreds of devices (solar panels, wind turbines, batteries) all sending data at the same time. The MQTT broker needs to handle this load.

**Command:**
```powershell
# Test multiple concurrent publishers
.\tests\scripts\test-mqtt.ps1 -LoadTest -Publishers 10 -Messages 100 -Topic "test/load"
```

**📋 Understanding the Command:**
- `-LoadTest`: Runs a load test
- `-Publishers 10`: Creates 10 simulated devices
- `-Messages 100`: Each device sends 100 messages
- `-Topic "test/load"`: All messages go to this topic

**Expected Result:**
- All connections successful
- All messages delivered
- No performance degradation
- Broker handles load without errors

#### 5.2 Test Message Throughput
**🔍 What This Does:**
Tests how many messages per second the MQTT broker can handle. This is important for high-frequency data from renewable energy devices.

**Command:**
```powershell
# Test high message throughput
.\tests\scripts\test-mqtt.ps1 -ThroughputTest -Messages 1000 -Rate 100
```

**📋 Understanding the Command:**
- `-ThroughputTest`: Tests message throughput
- `-Messages 1000`: Sends 1000 messages
- `-Rate 100`: Sends 100 messages per second

**Expected Result:**
- All messages delivered successfully
- No message loss
- Consistent delivery rate
- No performance issues

### Step 6: Security Testing

#### 6.1 Test Invalid Credentials
**🔍 What This Does:**
Tests that the MQTT broker properly rejects connections with wrong username/password combinations.

**Command:**
```powershell
# Test with wrong username
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/security" -Message "wrong_user" -Username "wronguser" -Password "wrongpass"
```

**Expected Result:**
- Connection rejected
- Authentication error
- No message published

#### 6.2 Test Access Control Lists (ACL)
**🔍 What This Does:**
Tests that the MQTT broker enforces access control rules. Different users should have different permissions.

**💡 Why This Matters:**
In a real system, you might have:
- **Device users**: Can only publish to their own topics
- **Monitoring users**: Can subscribe to all topics but not publish
- **Admin users**: Can publish and subscribe to everything

**Command:**
```powershell
# Test device user permissions
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/photovoltaic/panel001/telemetry" -Username "device_user" -Password "device_pass"

# Test monitoring user permissions
.\tests\scripts\test-mqtt.ps1 -Subscribe -Topic "devices/+/+/telemetry" -Username "monitor_user" -Password "monitor_pass"
```

**Expected Result:**
- Device users can publish to their topics
- Monitoring users can subscribe to topics
- Access denied for unauthorized operations

## Advanced Technical Testing

### MQTT Protocol Compliance Testing
Test MQTT protocol compliance and edge cases:

```powershell
# Test MQTT 3.1.1 protocol compliance
.\tests\scripts\test-mqtt.ps1 -ProtocolTest -Version "3.1.1"

# Test MQTT 5.0 protocol features (if supported)
.\tests\scripts\test-mqtt.ps1 -ProtocolTest -Version "5.0"
```

### Message Payload Validation
Test different message payload formats and sizes:

```powershell
# Test JSON payload validation
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/payload" -Message '{"timestamp":"2024-01-15T10:30:00Z","value":123.45}'

# Test large payload handling
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/large" -Message $(1..1000 | ForEach-Object { "data" } | ConvertTo-Json)
```

### Connection Resilience Testing
Test connection stability and recovery:

```powershell
# Test connection interruption and recovery
.\tests\scripts\test-mqtt.ps1 -ResilienceTest -Duration 300 -InterruptInterval 30

# Test automatic reconnection
.\tests\scripts\test-mqtt.ps1 -ReconnectTest -MaxReconnects 5
```

### Performance Benchmarking
Measure MQTT broker performance metrics:

```powershell
# Benchmark message latency
.\tests\scripts\test-mqtt.ps1 -LatencyTest -Messages 1000 -Interval 10

# Benchmark throughput
.\tests\scripts\test-mqtt.ps1 -ThroughputBenchmark -Duration 60 -Rate 1000
```

## Professional Best Practices

### MQTT Security Best Practices
- **Strong Authentication**: Use complex usernames and passwords
- **Access Control**: Implement topic-level permissions via ACL
- **Encryption**: Use TLS/SSL for production deployments
- **Certificate Authentication**: Implement client certificate validation
- **Regular Updates**: Keep Mosquitto broker updated

### Performance Optimization
- **Connection Pooling**: Reuse connections when possible
- **Message Batching**: Batch multiple messages when appropriate
- **QoS Selection**: Choose appropriate QoS levels for your use case
- **Topic Design**: Optimize topic structure for efficient routing
- **Resource Monitoring**: Monitor broker resource usage

### Monitoring and Alerting
- **Connection Monitoring**: Track active connections and disconnections
- **Message Rate Monitoring**: Monitor messages per second
- **Error Rate Tracking**: Track authentication and authorization failures
- **Performance Metrics**: Monitor latency and throughput
- **Health Checks**: Implement automated health check scripts

### Disaster Recovery
- **Configuration Backup**: Backup Mosquitto configuration files
- **User Database Backup**: Backup user and ACL databases
- **Recovery Procedures**: Document recovery procedures
- **Testing**: Regularly test recovery procedures
- **Documentation**: Maintain up-to-date documentation

## Test Results Documentation

### Pass Criteria
- All authentication tests pass
- All topic publishing/subscribing works correctly
- QoS levels function properly
- Retained messages work as expected
- Load testing shows good performance
- Security measures are enforced
- No connection errors or message loss

### Fail Criteria
- Authentication failures with correct credentials
- Topic publishing/subscribing failures
- QoS not working correctly
- Retained messages not functioning
- Performance issues under load
- Security bypasses possible
- Connection errors or message loss

## Troubleshooting

### Common Issues

#### 1. Authentication Failures
**Problem:** Valid credentials rejected
**🔍 What This Means:** The MQTT broker's user database might be corrupted or misconfigured.

**Solution:**
```powershell
# Regenerate password file
docker-compose exec mosquitto mosquitto_passwd -b /mosquitto/config/passwd admin admin_password_456

# Restart MQTT broker
docker-compose restart mosquitto
```

#### 2. Connection Refused
**Problem:** Can't connect to MQTT broker
**🔍 What This Means:** The MQTT broker might not be running or there's a network issue.

**Solution:**
```powershell
# Check if MQTT broker is running
docker-compose ps mosquitto

# Check MQTT broker logs
docker-compose logs mosquitto

# Restart MQTT broker
docker-compose restart mosquitto
```

#### 3. Message Not Received
**Problem:** Published messages not received by subscribers
**🔍 What This Means:** There might be a topic mismatch or subscription issue.

**Solution:**
```powershell
# Check topic structure
# Make sure publisher and subscriber use exact same topic

# Test with simple topic
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "test/simple" -Message "test"
.\tests\scripts\test-mqtt.ps1 -Subscribe -Topic "test/simple"
```

#### 4. Performance Issues
**Problem:** Slow message delivery or connection failures under load
**🔍 What This Means:** The MQTT broker might be overloaded or have resource constraints.

**Solution:**
```powershell
# Check system resources
docker stats

# Increase MQTT broker resources in docker-compose.yml
# Restart with more memory/CPU allocation
```

## Next Steps
If all MQTT tests pass, proceed to:
- [Manual Test 03: Node-RED Data Processing](./03-node-red-data-processing.md)
- [Manual Test 04: InfluxDB Data Storage](./04-influxdb-data-storage.md)
- [Manual Test 05: Grafana Data Visualization](./05-grafana-data-visualization.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ Authentication working correctly
□ Topic publishing/subscribing functional
□ QoS levels working
□ Retained messages functional
□ Load testing passed
□ Security measures enforced
□ No connection errors
□ No message loss

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 