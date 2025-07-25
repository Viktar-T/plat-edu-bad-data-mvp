# MQTT Test Logging Implementation

## Overview
Comprehensive logging has been implemented for all MQTT tests to provide detailed execution tracking, error analysis, and performance metrics. Each test run generates a separate markdown log file in the `tests/javascript/mqtt/test-results/` directory.

## Logging Features

### ✅ **Comprehensive Log Capture**
- **Test Steps**: Detailed step-by-step execution tracking
- **MQTT Events**: Connection, disconnection, publish, subscribe events
- **Authentication**: Success/failure logging with credential details
- **Performance Metrics**: Response times, throughput measurements
- **Error Tracking**: Full error details with stack traces
- **Assertions**: Pass/fail logging with expected vs actual values

### ✅ **Structured Log Output**
- **Markdown Format**: Human-readable log files with tables and sections
- **Timestamped Entries**: Precise timing for all events
- **Log Levels**: INFO, WARN, ERROR categorization
- **Data Context**: Relevant data attached to log entries
- **Metrics Summary**: Connection counts, message counts, error counts

### ✅ **File Organization**
- **Directory**: `tests/javascript/mqtt/test-results/`
- **Naming**: `{TestName}_{Timestamp}.md`
- **Automatic Creation**: Directory created if not exists
- **Separate Files**: Each test run gets its own log file

## TestLogger Class

### **Core Methods**

#### **Basic Logging**
```javascript
logger.info(message, data)           // Information messages
logger.warn(message, data)           // Warning messages  
logger.error(message, error)         // Error messages with stack traces
```

#### **MQTT-Specific Logging**
```javascript
logger.logConnection(clientId, host, port, success)     // Connection events
logger.logDisconnection(clientId, reason)               // Disconnection events
logger.logMessagePublish(topic, payload, qos, success)  // Message publishing
logger.logMessageReceive(topic, payload, qos)           // Message reception
logger.logSubscription(topic, qos, success)             // Subscription events
logger.logAuthentication(username, success, error)      // Authentication events
```

#### **Test-Specific Logging**
```javascript
logger.logStep(step, details)        // Test step tracking
logger.logAssertion(desc, passed, expected, actual)     // Assertion results
logger.logPerformance(metric, value, unit)              // Performance metrics
```

### **Metrics Tracking**
```javascript
{
  messagesSent: 0,        // Number of messages published
  messagesReceived: 0,    // Number of messages received
  connections: 0,         // Number of connections established
  disconnections: 0,      // Number of disconnections
  errors: 0,             // Number of errors encountered
  warnings: 0            // Number of warnings generated
}
```

## Log File Structure

### **1. Test Summary**
```markdown
## Test Summary
- **Test Name**: MQTT Connection Tests
- **Start Time**: 2024-01-15T10:30:00.000Z
- **End Time**: 2024-01-15T10:30:45.000Z
- **Duration**: 45000ms
- **Status**: ✅ PASSED
- **Total Logs**: 25
- **Errors**: 0
- **Warnings**: 2
```

### **2. Metrics Section**
```markdown
## Metrics
- **Connections**: 3
- **Disconnections**: 3
- **Messages Sent**: 5
- **Messages Received**: 2
- **Errors**: 0
- **Warnings**: 2
```

### **3. Errors Section** (if any)
```markdown
## Errors
### Error 1
- **Time**: 2024-01-15T10:30:15.000Z
- **Message**: MQTT connection error
- **Error Name**: ConnectionError
- **Error Message**: Connection refused
- **Stack Trace**: 
```
Error: Connection refused
    at MqttClient.connect...
```

### **4. Warnings Section** (if any)
```markdown
## Warnings
### Warning 1
- **Time**: 2024-01-15T10:30:10.000Z
- **Message**: Unexpected successful connection to non-existent broker
- **Data**: {"host": "non-existent-broker", "port": 1883}
```

### **5. Detailed Logs Table**
```markdown
## Detailed Logs
| Time | Level | Message | Data |
|------|-------|---------|------|
| 10:30:00 | INFO | Creating MQTT client | {"host": "mosquitto", "port": 1883, "clientId": "test-connection-123"} |
| 10:30:01 | INFO | MQTT Connection established | {"clientId": "test-connection-123", "host": "mosquitto", "port": 1883, "success": true} |
| 10:30:01 | INFO | Performance: Connection Response Time | {"value": 1250, "unit": "ms"} |
| 10:30:01 | INFO | [PASS] Client should be connected | {"passed": true, "expected": true, "actual": true} |
```

## Implementation Examples

### **Connection Test Logging**
```javascript
test('should connect to actual Mosquitto broker successfully', async () => {
  const startTime = Date.now();
  logger.logStep('Starting connection test to actual Mosquitto broker');
  
  return new Promise((resolve, reject) => {
    const clientId = `test-connection-${Date.now()}`;
    logger.info('Creating MQTT client', {
      host: config.mqtt.connection.host,
      port: config.mqtt.connection.port,
      clientId,
      username: config.mqtt.connection.username
    });

    client = mqtt.connect({...});

    client.on('connect', () => {
      const responseTime = Date.now() - startTime;
      logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, true);
      logger.logPerformance('Connection Response Time', responseTime);
      
      logger.logAssertion('Client should be connected', client.connected, true, client.connected);
      logger.logAssertion('Response time should be less than 5000ms', responseTime < 5000, '< 5000ms', `${responseTime}ms`);
      
      expect(client.connected).toBe(true);
      expect(responseTime).toBeLessThan(5000);
      resolve();
    });

    client.on('error', (error) => {
      logger.error('MQTT connection error', error);
      reject(error);
    });
  });
});
```

### **Messaging Test Logging**
```javascript
test('should publish photovoltaic data to actual broker', async () => {
  logger.logStep('Testing photovoltaic data publishing to actual broker');
  
  return new Promise((resolve, reject) => {
    const testData = {
      timestamp: new Date().toISOString(),
      device_id: 'pv_001',
      device_type: 'photovoltaic',
      power_output: 2500.5,
      // ... more data
    };

    const topic = 'devices/photovoltaic/pv_001/data';
    const clientId = `test-publisher-${Date.now()}`;

    logger.info('Creating publisher client', {
      host: config.mqtt.connection.host,
      port: config.mqtt.connection.port,
      clientId,
      topic
    });

    logger.info('Test data prepared', testData);

    publisher = mqtt.connect({...});

    publisher.on('connect', () => {
      logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, true);
      logger.logStep('Publisher connected, publishing message');
      
      publisher.publish(topic, JSON.stringify(testData), { qos: 1 }, (error) => {
        if (error) {
          logger.error('Publish error', error);
          reject(error);
        } else {
          logger.logMessagePublish(topic, testData, 1, true);
          logger.logAssertion('Publisher should be connected', publisher.connected, true, publisher.connected);
          expect(publisher.connected).toBe(true);
          resolve();
        }
      });
    });
  });
});
```

## Usage Instructions

### **Running Tests with Logging**
```bash
# Run all MQTT tests (logs automatically generated)
cd tests
npm test mqtt/

# Run specific test file
npm test mqtt/connection.test.js

# Run with Docker (logs saved to container volume)
docker-compose -f docker-compose.test.yml up --build
```

### **Viewing Log Files**
```bash
# List all log files
ls tests/javascript/mqtt/test-results/

# View latest log file
ls -t tests/javascript/mqtt/test-results/ | head -1 | xargs cat

# Search for errors in logs
grep -r "ERROR" tests/javascript/mqtt/test-results/
```

### **Log File Analysis**
```bash
# Count total test runs
ls tests/javascript/mqtt/test-results/*.md | wc -l

# Find failed tests
grep -l "❌ FAILED" tests/javascript/mqtt/test-results/*.md

# Find slow tests (>30 seconds)
grep -B 5 "Duration.*[3-9][0-9][0-9][0-9][0-9]ms" tests/javascript/mqtt/test-results/*.md
```

## Benefits

### **Debugging & Troubleshooting**
- **Detailed Error Context**: Full stack traces and error details
- **Step-by-Step Execution**: Complete test flow tracking
- **Performance Analysis**: Response times and throughput metrics
- **Data Validation**: Expected vs actual value comparisons

### **Monitoring & Analytics**
- **Test Success Rates**: Track pass/fail ratios over time
- **Performance Trends**: Monitor response time changes
- **Error Patterns**: Identify recurring issues
- **System Health**: Connection stability and message delivery rates

### **Development & Testing**
- **Regression Detection**: Compare test results across runs
- **Issue Reproduction**: Detailed logs for bug reproduction
- **Performance Optimization**: Identify bottlenecks and slow operations
- **Documentation**: Self-documenting test execution

## File Locations

### **Source Files**
- **Logger Class**: `tests/javascript/utils/test-logger.js`
- **Test Files**: `tests/javascript/mqtt/*.test.js`
- **Configuration**: `tests/config/mqtt-test-config.json`

### **Output Files**
- **Log Directory**: `tests/javascript/mqtt/test-results/`
- **Log Files**: `{TestName}_{Timestamp}.md`
- **Example**: `MQTT_Connection_Tests_1705312200000.md`

## Integration

### **Jest Integration**
- **Automatic Logging**: Each test automatically logs to file
- **Error Capture**: Jest errors captured and logged
- **Timeout Handling**: Test timeouts logged with context
- **Cleanup**: Logs saved even if test fails

### **Docker Integration**
- **Volume Mounting**: Logs persisted across container restarts
- **File Permissions**: Proper file ownership and permissions
- **Network Logging**: Docker network events captured
- **Service Dependencies**: Service health logged

## Future Enhancements

### **Advanced Logging**
- **Log Rotation**: Automatic cleanup of old log files
- **Log Compression**: Compress old logs to save space
- **Log Aggregation**: Combine logs from multiple test runs
- **Real-time Logging**: Stream logs during test execution

### **Analytics & Reporting**
- **Dashboard Integration**: Web-based log viewing
- **Trend Analysis**: Performance trend visualization
- **Alert System**: Automated alerts for test failures
- **Metrics Export**: Export metrics to monitoring systems

## Conclusion

The comprehensive logging implementation provides complete visibility into MQTT test execution, enabling effective debugging, monitoring, and analysis of the renewable energy IoT monitoring system's messaging infrastructure.

**Status**: ✅ **Complete and Production Ready** 