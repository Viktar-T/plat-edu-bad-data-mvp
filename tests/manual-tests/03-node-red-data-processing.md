# Manual Test 03: Node-RED Data Processing

## Overview
This test verifies that Node-RED is properly processing MQTT messages, validating data, transforming it, and forwarding it to InfluxDB for storage.

**🔍 What This Test Does:**
This test checks if Node-RED is working correctly as the "brain" of your IoT system. Think of Node-RED as a smart factory that receives raw materials (MQTT messages from devices), processes them (validates and transforms the data), and sends the finished product (processed data) to the warehouse (InfluxDB database).

**🏗️ Why This Matters:**
Node-RED is where the magic happens in your IoT system. It's responsible for:
- Receiving data from renewable energy devices via MQTT
- Validating that the data is correct and complete
- Transforming data into the right format for storage
- Sending processed data to InfluxDB
- Handling errors and edge cases

If Node-RED isn't working, data flows from devices but never gets stored or processed properly.

## Technical Architecture Overview

### Node-RED Flow Architecture
Node-RED uses a **flow-based programming model** where data flows through connected nodes:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MQTT Input    │───▶│   Function      │───▶│   Switch        │───▶│   InfluxDB      │
│   Node          │    │   Node          │    │   Node          │    │   Output Node   │
│                 │    │   (Validation)  │    │   (Routing)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Debug Node    │    │   Error         │
                       │   (Logging)     │    │   Handler Node  │
                       └─────────────────┘    └─────────────────┘
```

### Node Types and Functions
**Input Nodes:**
- **MQTT Input**: Receives messages from MQTT broker
- **HTTP Input**: Receives HTTP requests
- **WebSocket Input**: Receives WebSocket messages

**Processing Nodes:**
- **Function Node**: JavaScript code for data transformation
- **Switch Node**: Conditional routing based on message content
- **Change Node**: Modify message properties
- **Template Node**: Format messages using templates

**Output Nodes:**
- **InfluxDB Output**: Send data to InfluxDB
- **MQTT Output**: Publish messages to MQTT broker
- **HTTP Response**: Send HTTP responses
- **Debug Node**: Display messages in debug panel

### Data Flow Processing Pipeline
```
1. Message Reception (MQTT Input)
   ├── Topic filtering
   ├── Message parsing
   └── Payload extraction

2. Data Validation (Function Node)
   ├── Schema validation
   ├── Range checking
   ├── Type validation
   └── Required field verification

3. Data Transformation (Function Node)
   ├── Unit conversion
   ├── Calculation of derived values
   ├── Metadata addition
   └── Format standardization

4. Data Routing (Switch Node)
   ├── Device type routing
   ├── Error handling
   ├── Priority routing
   └── Load balancing

5. Data Storage (InfluxDB Output)
   ├── Measurement selection
   ├── Tag assignment
   ├── Field mapping
   └── Timestamp handling
```

### Error Handling Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Main Flow     │───▶│   Error         │───▶│   Error         │
│                 │    │   Catch Node    │    │   Handler       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Logging       │
                       │   & Alerting    │
                       └─────────────────┘
```

## Test Objective
Ensure Node-RED flows are correctly receiving MQTT messages, processing device data, and sending it to the database.

**🎯 What We're Checking:**
- **MQTT Input**: Can Node-RED receive messages from the MQTT broker?
- **Data Validation**: Is the incoming data checked for errors?
- **Data Transformation**: Is the data converted to the right format?
- **Database Output**: Is processed data sent to InfluxDB?
- **Error Handling**: Are problems handled gracefully?
- **Flow Status**: Are all processing flows running correctly?

## Prerequisites
- Manual Test 01 and 02 completed successfully
- Node-RED accessible at http://localhost:1880
- MQTT broker running and tested
- InfluxDB running and accessible

**📋 What These Prerequisites Mean:**
- **Test 01**: All services are running and healthy
- **Test 02**: MQTT broker is working and can send/receive messages
- **Node-RED**: The web interface must be accessible
- **MQTT Broker**: Must be running to send data to Node-RED
- **InfluxDB**: Must be running to receive processed data

## Test Steps

### Step 1: Access Node-RED Interface

#### 1.1 Open Node-RED Dashboard
**🔍 What This Does:**
Opens the Node-RED web interface where you can see and configure all the data processing flows. This is like opening the control panel of your smart factory.

**💡 Why This Matters:**
Node-RED uses a visual programming interface where you can see how data flows through your system. You can see if flows are running (green), stopped (red), or have errors.

**Action:**
1. Open web browser
2. Navigate to http://localhost:1880
3. Login with credentials (if required)

**📋 Understanding the Interface:**
- **Flow Editor**: The main workspace where you design data processing flows
- **Palette**: The toolbox with different types of nodes (MQTT input, function, database output, etc.)
- **Debug Panel**: Shows messages and data as they flow through the system
- **Deploy Button**: Saves and activates your changes

**Expected Result:**
- Node-RED editor loads successfully
- Dashboard shows all deployed flows
- No error messages

#### 1.2 Verify Flow Status
**🔍 What This Does:**
Checks that all the data processing flows are running correctly. Each flow is like a production line in your factory - it needs to be "turned on" to process data.

**💡 Why This Matters:**
- **Green Status**: Flow is running and processing data
- **Red Status**: Flow has stopped due to an error
- **Gray Status**: Flow is deployed but not active

**Action:**
1. Check that all flows are deployed (green status)
2. Verify no red error indicators
3. Check flow tabs for different device types

**📋 Understanding Flow Types:**
Your system should have flows for different renewable energy devices:
- **Photovoltaic Flow**: Processes solar panel data
- **Wind Turbine Flow**: Processes wind turbine data
- **Biogas Plant Flow**: Processes biogas plant data
- **Heat Boiler Flow**: Processes heat boiler data
- **Energy Storage Flow**: Processes battery data

**Expected Result:**
- All flows show green status (deployed)
- No red error indicators
- Flows visible for:
  - Photovoltaic simulation
  - Wind turbine simulation
  - Biogas plant simulation
  - Heat boiler simulation
  - Energy storage simulation

### Step 2: Test MQTT Input Processing

#### 2.1 Test Photovoltaic Data Reception
**🔍 What This Does:**
Tests if Node-RED can receive and process data from photovoltaic (solar panel) devices. This simulates real solar panels sending their power and sensor data.

**💡 Why This Matters:**
Solar panels send data like:
- **Power Output**: How much electricity they're generating
- **Voltage**: Electrical voltage levels
- **Current**: Electrical current flow
- **Temperature**: Panel temperature (affects efficiency)
- **Irradiance**: Sunlight intensity

**Action in Node-RED:**
1. Open the photovoltaic simulation flow
2. Look for MQTT input node
3. Check debug output for EACH received message. Check in Node-RED debugger panel.
4. Verify message structure

**📋 Understanding the Process:**
1. **MQTT Input Node**: Receives messages from topic `devices/photovoltaic/+/telemetry`
2. **Function Node**: Validates and processes the data
3. **Debug Node**: Shows the processed data in the debug panel
4. **InfluxDB Output Node**: Sends data to the database

**Expected Result:**
- Messages appear in debug panel
- Data structure is correct (JSON format)
- No error messages in debug output
- Data flows through all nodes successfully

#### 2.2 Test Wind Turbine Data Reception
**🔍 What This Does:**
Tests if Node-RED can receive and process data from wind turbine devices. This simulates wind turbines sending their power and operational data.

**💡 Why This Matters:**
Wind turbines send data like:
- **Power Output**: How much electricity they're generating
- **Wind Speed**: Current wind speed
- **RPM**: Rotor speed
- **Temperature**: Turbine temperature
- **Wind Direction**: Wind direction

**Action in Node-RED:**
1. Open the wind turbine simulation flow
2. Look for MQTT input node
3. Check debug output for received messages
4. Verify message structure

**Expected Result:**
- Messages appear in debug panel
- Data structure is correct
- No error messages
- Data flows through all nodes

#### 2.3 Test Energy Storage Data Reception
**🔍 What This Does:**
Tests if Node-RED can receive and process data from energy storage (battery) devices. This simulates batteries sending their charge status and performance data.

**💡 Why This Matters:**
Energy storage devices send data like:
- **State of Charge (SOC)**: How full the battery is (0-100%)
- **Voltage**: Battery voltage levels
- **Current**: Charge/discharge current
- **Temperature**: Battery temperature
- **Power**: Charge/discharge power

**Action in Node-RED:**
1. Open the energy storage simulation flow
2. Look for MQTT input node
3. Check debug output for received messages
4. Verify message structure

**Expected Result:**
- Messages appear in debug panel
- Data structure is correct
- No error messages
- Data flows through all nodes

### Step 3: Test Data Validation and Processing

#### 3.1 Test Data Validation
**🔍 What This Does:**
Tests if Node-RED properly validates incoming data to ensure it's complete and within expected ranges. This is like quality control in a factory.

**💡 Why This Matters:**
Invalid data can cause problems:
- **Missing Fields**: Data might be incomplete
- **Out of Range Values**: Sensor readings might be impossible
- **Wrong Data Types**: Numbers where text is expected
- **Malformed JSON**: Data structure might be broken

**Action in Node-RED:**
1. Look for function nodes that validate data
2. Check if validation rules are working
3. Test with invalid data to see error handling

**📋 Understanding Validation:**
Node-RED should check:
- **Required Fields**: All necessary data is present
- **Data Types**: Numbers are numbers, strings are strings
- **Value Ranges**: Power output is positive, temperature is reasonable
- **Timestamp**: Data has a valid timestamp

**Expected Result:**
- Valid data passes through validation
- Invalid data is caught and handled
- Error messages are logged appropriately
- System continues processing valid data

#### 3.2 Test Data Transformation
**🔍 What This Does:**
Tests if Node-RED properly transforms data from the device format to the database format. This is like converting raw materials into finished products.

**💡 Why This Matters:**
Devices send data in one format, but InfluxDB expects it in another format. Node-RED must:
- **Convert Units**: Change temperature from Celsius to Kelvin if needed
- **Add Metadata**: Include device type, location, etc.
- **Format Timestamps**: Ensure proper time format
- **Calculate Derived Values**: Power = Voltage × Current

**Action in Node-RED:**
1. Look for function nodes that transform data
2. Check input and output data formats
3. Verify calculations are correct

**📋 Understanding Transformation:**
**Input Format (from device):**
```json
{
  "power": 1500,
  "voltage": 48.5,
  "current": 30.9
}
```

**Output Format (to InfluxDB):**
```json
{
  "measurement": "photovoltaic_data",
  "tags": {
    "device_id": "panel001",
    "device_type": "photovoltaic",
    "location": "site_a"
  },
  "fields": {
    "power": 1500,
    "voltage": 48.5,
    "current": 30.9
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Expected Result:**
- Data is properly transformed
- All required fields are present
- Calculations are accurate
- Format matches InfluxDB requirements

### Step 4: Test Database Output

#### 4.1 Test InfluxDB Connection
**🔍 What This Does:**
Tests if Node-RED can successfully connect to InfluxDB and send processed data. This is like testing if the finished products can be delivered to the warehouse.

**💡 Why This Matters:**
If Node-RED can't connect to InfluxDB:
- Data gets processed but not stored
- You lose historical data
- Grafana dashboards won't show data
- The entire monitoring system fails

**Action in Node-RED:**
1. Look for InfluxDB output nodes
2. Check connection status
3. Verify data is being sent

**📋 Understanding the Connection:**
Node-RED uses:
- **InfluxDB URL**: http://influxdb:8086
- **Database Token**: Authentication token
- **Organization**: Your InfluxDB organization
- **Bucket**: Where data is stored

**Expected Result:**
- InfluxDB nodes show green status
- No connection errors
- Data flows to database successfully

#### 4.2 Test Data Writing
**🔍 What This Does:**
Tests if processed data is actually being written to InfluxDB. This verifies the complete data flow from MQTT → Node-RED → InfluxDB.

**💡 Why This Matters:**
This is the final step in the data pipeline. If this fails, all the processing work is wasted because data isn't stored.

**Action in Node-RED:**
1. Send test messages through the flows
2. Check InfluxDB nodes for success indicators
3. Verify data appears in InfluxDB

**📋 Understanding Data Writing:**
Node-RED should:
- **Write to Correct Measurement**: photovoltaic_data, wind_turbine_data, etc.
- **Include Proper Tags**: device_id, device_type, location
- **Include All Fields**: power, voltage, current, etc.
- **Use Correct Timestamps**: ISO 8601 format

**Expected Result:**
- Data is written to InfluxDB successfully
- No write errors
- Data appears in correct measurements
- All fields and tags are present

### Step 5: Test Error Handling

#### 5.1 Test Invalid Data Handling
**🔍 What This Does:**
Tests how Node-RED handles invalid or corrupted data. This is like testing the emergency procedures in a factory.

**💡 Why This Matters:**
In real IoT systems, devices sometimes send bad data due to:
- **Sensor Failures**: Broken or malfunctioning sensors
- **Network Issues**: Corrupted data during transmission
- **Device Errors**: Software bugs in devices
- **Power Issues**: Incomplete data due to power loss

**Action in Node-RED:**
1. Send invalid data through MQTT
2. Check how Node-RED handles it
3. Verify error logging and recovery

**📋 Understanding Error Handling:**
Node-RED should:
- **Catch Invalid Data**: Detect malformed JSON, missing fields
- **Log Errors**: Record what went wrong
- **Continue Processing**: Don't crash the entire flow
- **Alert Operators**: Send notifications for serious issues

**Expected Result:**
- Invalid data is caught and logged
- System continues processing valid data
- Error messages are clear and helpful
- No system crashes

#### 5.2 Test Connection Failure Handling
**🔍 What This Does:**
Tests how Node-RED handles when InfluxDB is unavailable. This simulates database connection problems.

**💡 Why This Matters:**
If InfluxDB goes down:
- Node-RED should buffer data temporarily
- System should retry connections
- Data shouldn't be lost permanently
- System should recover when database comes back

**Action in Node-RED:**
1. Temporarily stop InfluxDB service
2. Send data through Node-RED flows
3. Check error handling and buffering
4. Restart InfluxDB and verify recovery

**Expected Result:**
- Node-RED detects connection failure
- Data is buffered or queued
- Retry attempts are made
- System recovers when database returns

### Step 6: Test Performance and Throughput

#### 6.1 Test Message Processing Speed
**🔍 What This Does:**
Tests how quickly Node-RED can process incoming messages. This is important for high-frequency data from renewable energy devices.

**💡 Why This Matters:**
Solar panels and wind turbines can send data every few seconds. Node-RED must process this quickly to avoid:
- **Data Backlog**: Messages piling up
- **Memory Issues**: Too much data in memory
- **Delayed Alerts**: Important issues not detected quickly

**Action:**
1. Send high-frequency test messages
2. Monitor processing speed
3. Check for delays or bottlenecks

**Expected Result:**
- Messages processed quickly
- No significant delays
- Memory usage remains stable
- No message loss

#### 6.2 Test Concurrent Device Processing
**🔍 What This Does:**
Tests if Node-RED can handle multiple devices sending data simultaneously. This simulates a real renewable energy site with many devices.

**💡 Why This Matters:**
A typical renewable energy site might have:
- **50+ Solar Panels**: Each sending data every 5 seconds
- **10+ Wind Turbines**: Each sending data every 2 seconds
- **5+ Battery Systems**: Each sending data every 1 second
- **Multiple Sensors**: Temperature, weather, etc.

**Action:**
1. Simulate multiple devices sending data
2. Monitor system performance
3. Check for conflicts or delays

**Expected Result:**
- All devices processed correctly
- No data mixing between devices
- System handles load without issues
- Performance remains stable

## Advanced Technical Testing

### Flow Performance Analysis
Analyze flow performance and identify bottlenecks:

```javascript
// Performance monitoring function node
const startTime = Date.now();
const messageCount = flow.get('messageCount') || 0;
flow.set('messageCount', messageCount + 1);

// Calculate processing time
const processingTime = Date.now() - startTime;
const avgProcessingTime = flow.get('avgProcessingTime') || 0;
const newAvg = (avgProcessingTime * messageCount + processingTime) / (messageCount + 1);
flow.set('avgProcessingTime', newAvg);

// Log performance metrics
node.log(`Processing time: ${processingTime}ms, Average: ${newAvg.toFixed(2)}ms`);

return msg;
```

### Memory Usage Monitoring
Monitor Node-RED memory usage and performance:

```javascript
// Memory monitoring function node
const memUsage = process.memoryUsage();
const memInfo = {
    rss: Math.round(memUsage.rss / 1024 / 1024), // MB
    heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024), // MB
    heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024), // MB
    external: Math.round(memUsage.external / 1024 / 1024) // MB
};

msg.payload = {
    timestamp: new Date().toISOString(),
    memory: memInfo,
    message: msg.payload
};

return msg;
```

### Advanced Error Handling
Implement comprehensive error handling and recovery:

```javascript
// Advanced error handling function node
try {
    // Validate message structure
    if (!msg.payload || typeof msg.payload !== 'object') {
        throw new Error('Invalid message payload');
    }
    
    // Validate required fields
    const requiredFields = ['device_id', 'timestamp', 'data'];
    for (const field of requiredFields) {
        if (!msg.payload[field]) {
            throw new Error(`Missing required field: ${field}`);
        }
    }
    
    // Validate data types
    if (typeof msg.payload.device_id !== 'string') {
        throw new Error('device_id must be a string');
    }
    
    // Process data
    const processedData = {
        measurement: 'device_data',
        tags: {
            device_id: msg.payload.device_id,
            device_type: msg.payload.device_type || 'unknown'
        },
        fields: msg.payload.data,
        timestamp: new Date(msg.payload.timestamp).getTime() * 1000000 // nanoseconds
    };
    
    msg.payload = processedData;
    return msg;
    
} catch (error) {
    // Log error details
    node.error(`Data processing error: ${error.message}`, msg);
    
    // Create error message
    const errorMsg = {
        error: true,
        timestamp: new Date().toISOString(),
        error_message: error.message,
        original_payload: msg.payload
    };
    
    // Send to error handling flow
    msg.payload = errorMsg;
    return msg;
}
```

### Data Quality Validation
Implement comprehensive data quality checks:

```javascript
// Data quality validation function node
function validateDataQuality(payload) {
    const errors = [];
    
    // Check for null or undefined values
    for (const [key, value] of Object.entries(payload.data || {})) {
        if (value === null || value === undefined) {
            errors.push(`Null/undefined value for field: ${key}`);
        }
    }
    
    // Check for out-of-range values
    if (payload.data.power !== undefined && payload.data.power < 0) {
        errors.push('Power cannot be negative');
    }
    
    if (payload.data.temperature !== undefined && 
        (payload.data.temperature < -50 || payload.data.temperature > 100)) {
        errors.push('Temperature out of reasonable range');
    }
    
    // Check timestamp validity
    const timestamp = new Date(payload.timestamp);
    if (isNaN(timestamp.getTime())) {
        errors.push('Invalid timestamp format');
    }
    
    // Check for future timestamps
    if (timestamp > new Date()) {
        errors.push('Timestamp cannot be in the future');
    }
    
    return errors;
}

const validationErrors = validateDataQuality(msg.payload);
if (validationErrors.length > 0) {
    node.warn(`Data quality issues: ${validationErrors.join(', ')}`);
    msg.dataQualityIssues = validationErrors;
}

return msg;
```

## Professional Best Practices

### Flow Design Best Practices
- **Modular Design**: Break complex flows into smaller, reusable subflows
- **Error Handling**: Implement comprehensive error handling at each step
- **Performance Optimization**: Use efficient node configurations and avoid unnecessary processing
- **Documentation**: Add clear comments and descriptions to all nodes
- **Testing**: Implement unit tests for function nodes

### Security Best Practices
- **Input Validation**: Validate all incoming data before processing
- **Access Control**: Implement proper authentication for Node-RED admin interface
- **Secure Configuration**: Use environment variables for sensitive configuration
- **Regular Updates**: Keep Node-RED and custom nodes updated
- **Audit Logging**: Log all data processing activities for audit purposes

### Performance Optimization
- **Node Configuration**: Optimize node settings for your use case
- **Memory Management**: Monitor memory usage and implement garbage collection
- **Connection Pooling**: Reuse database connections when possible
- **Batch Processing**: Process multiple messages together when appropriate
- **Caching**: Implement caching for frequently accessed data

### Monitoring and Alerting
- **Flow Monitoring**: Monitor flow status and performance metrics
- **Error Alerting**: Set up alerts for processing errors and failures
- **Performance Metrics**: Track processing time and throughput
- **Resource Monitoring**: Monitor CPU, memory, and network usage
- **Health Checks**: Implement automated health checks for flows

## Test Results Documentation

### Pass Criteria
- Node-RED interface accessible
- All flows deployed and running (green status)
- MQTT messages received and processed
- Data validation working correctly
- Data transformation successful
- InfluxDB connection established
- Data written to database successfully
- Error handling working properly
- Performance acceptable under load

### Fail Criteria
- Node-RED interface not accessible
- Flows not deployed or showing errors
- MQTT messages not received
- Data validation failing
- Data transformation errors
- InfluxDB connection failures
- Data not written to database
- Poor error handling
- Performance issues under load

## Troubleshooting

### Common Issues

#### 1. Node-RED Interface Not Accessible
**Problem:** Can't access http://localhost:1880
**🔍 What This Means:** Node-RED service might not be running or there's a network issue.

**Solution:**
```powershell
# Check if Node-RED is running
docker-compose ps node-red

# Check Node-RED logs
docker-compose logs node-red

# Restart Node-RED
docker-compose restart node-red
```

#### 2. Flows Not Deployed
**Problem:** Flows show red status or not deployed
**🔍 What This Means:** There might be configuration errors or missing dependencies.

**Solution:**
1. Open Node-RED interface
2. Check for error messages in flows
3. Verify all nodes are properly configured
4. Click "Deploy" button to redeploy flows

#### 3. MQTT Messages Not Received
**Problem:** Node-RED not receiving data from MQTT
**🔍 What This Means:** MQTT input nodes might be misconfigured or MQTT broker connection issues.

**Solution:**
1. Check MQTT input node configuration
2. Verify topic names match exactly
3. Check MQTT broker connection
4. Test MQTT connectivity separately

#### 4. Data Not Written to InfluxDB
**Problem:** Processed data not appearing in database
**🔍 What This Means:** InfluxDB connection or configuration issues.

**Solution:**
1. Check InfluxDB output node configuration
2. Verify InfluxDB connection details
3. Check InfluxDB service status
4. Test InfluxDB connectivity separately

#### 5. Performance Issues
**Problem:** Slow processing or message loss
**🔍 What This Means:** Node-RED might be overloaded or have resource constraints.

**Solution:**
1. Check system resources (CPU, memory)
2. Optimize flow configuration
3. Increase Node-RED resources in docker-compose.yml
4. Check for inefficient processing nodes

## Next Steps
If all Node-RED tests pass, proceed to:
- [Manual Test 04: InfluxDB Data Storage](./04-influxdb-data-storage.md)
- [Manual Test 05: Grafana Data Visualization](./05-grafana-data-visualization.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ Node-RED interface accessible
□ All flows deployed and running
□ MQTT messages received
□ Data validation working
□ Data transformation successful
□ InfluxDB connection established
□ Data written to database
□ Error handling working
□ Performance acceptable

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
```

