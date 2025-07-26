# Manual Test 03: Node-RED Data Processing

## Overview
This test verifies that Node-RED is properly processing MQTT messages, validating data, transforming it, and forwarding it to InfluxDB for storage.

## Test Objective
Ensure Node-RED flows are correctly receiving MQTT messages, processing device data, and sending it to the database.

## Prerequisites
- Manual Test 01 and 02 completed successfully
- Node-RED accessible at http://localhost:1880
- MQTT broker running and tested
- InfluxDB running and accessible

## Test Steps

### Step 1: Access Node-RED Interface

#### 1.1 Open Node-RED Dashboard
**Action:**
1. Open web browser
2. Navigate to http://localhost:1880
3. Login with credentials (if required)

**Expected Result:**
- Node-RED editor loads successfully
- Dashboard shows all deployed flows
- No error messages

#### 1.2 Verify Flow Status
**Action:**
1. Check that all flows are deployed (green status)
2. Verify no red error indicators
3. Check flow tabs for different device types

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
**Command:**
```powershell
# Send test photovoltaic data via MQTT
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

**Action in Node-RED:**
1. Open the photovoltaic simulation flow
2. Look for MQTT input node
3. Check debug output for received message
4. Verify message structure

**Expected Result:**
- Message appears in debug output
- JSON structure is preserved
- All fields are present and correct

#### 2.2 Test Wind Turbine Data Reception
**Command:**
```powershell
# Send test wind turbine data via MQTT
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

**Action in Node-RED:**
1. Open the wind turbine simulation flow
2. Check debug output for received message
3. Verify data structure

**Expected Result:**
- Message received and processed
- Data structure is correct
- No parsing errors

### Step 3: Test Data Validation

#### 3.1 Test Valid Data Processing
**Command:**
```powershell
# Send valid photovoltaic data
$validData = @{
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

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $validData
```

**Action in Node-RED:**
1. Check validation function node output
2. Verify data passes validation
3. Check for any validation errors

**Expected Result:**
- Data passes validation
- No validation errors
- Status shows "valid"

#### 3.2 Test Invalid Data Rejection
**Command:**
```powershell
# Send invalid data (out of range values)
$invalidData = @{
    device_id = "pv_001"
    device_type = "photovoltaic"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        irradiance = 2000  # Out of range (>1200)
        temperature = 150   # Out of range (>100)
        voltage = 48.3
        current = 12.1
        power_output = 584.43
    }
    status = "operational"
    location = "site_a"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $invalidData
```

**Action in Node-RED:**
1. Check validation function node output
2. Verify data is rejected
3. Check error handling

**Expected Result:**
- Data fails validation
- Validation errors are logged
- Status shows "invalid"

### Step 4: Test Data Transformation

#### 4.1 Test Data Format Conversion
**Action in Node-RED:**
1. Check transformation function nodes
2. Verify data format conversion
3. Check InfluxDB output format

**Expected Result:**
- Data is properly transformed
- InfluxDB format is correct
- All required fields are present

#### 4.2 Test Data Enrichment
**Action in Node-RED:**
1. Check if additional fields are added
2. Verify calculated fields (efficiency, etc.)
3. Check timestamp formatting

**Expected Result:**
- Additional fields are calculated
- Timestamps are properly formatted
- Data is enriched correctly

### Step 5: Test InfluxDB Output

#### 5.1 Test Database Connection
**Action in Node-RED:**
1. Check InfluxDB output node status
2. Verify connection to database
3. Check for connection errors

**Expected Result:**
- InfluxDB connection is active
- No connection errors
- Output node shows green status

#### 5.2 Test Data Writing
**Command:**
```powershell
# Send test data and verify it reaches InfluxDB
$testData = @{
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

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $testData
```

**Action in Node-RED:**
1. Check InfluxDB output node for successful writes
2. Verify no write errors
3. Check debug output for confirmation

**Expected Result:**
- Data is written to InfluxDB successfully
- No write errors
- Confirmation messages in debug

### Step 6: Test Error Handling

#### 6.1 Test Network Disconnection
**Action:**
1. Temporarily stop InfluxDB service
2. Send test data via MQTT
3. Check Node-RED error handling
4. Restart InfluxDB service

**Command:**
```powershell
# Stop InfluxDB
docker-compose stop influxdb

# Send test data
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"test":"error_handling"}'

# Restart InfluxDB
docker-compose start influxdb
```

**Expected Result:**
- Node-RED handles disconnection gracefully
- Error messages are logged
- Service recovers when InfluxDB restarts

#### 6.2 Test Invalid JSON Handling
**Command:**
```powershell
# Send invalid JSON
mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m '{"invalid":"json",'
```

**Expected Result:**
- Node-RED handles invalid JSON gracefully
- Error is logged
- Flow continues processing other messages

### Step 7: Test Flow Performance

#### 7.1 Test Message Throughput
**Command:**
```powershell
# Send multiple messages rapidly
for ($i = 1; $i -le 50; $i++) {
    $data = @{
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
        message_id = $i
    } | ConvertTo-Json -Depth 3

    mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $data
    Start-Sleep -Milliseconds 100
}
```

**Action in Node-RED:**
1. Monitor flow performance
2. Check for message processing delays
3. Verify no message loss

**Expected Result:**
- All messages are processed
- No significant delays
- No message loss

#### 7.2 Test Memory Usage
**Action in Node-RED:**
1. Check Node-RED memory usage
2. Monitor for memory leaks
3. Verify stable performance

**Expected Result:**
- Memory usage remains stable
- No memory leaks
- Performance is consistent

### Step 8: Test Flow Monitoring

#### 8.1 Check Flow Statistics
**Action in Node-RED:**
1. Access flow statistics
2. Check message counts
3. Verify error rates

**Expected Result:**
- Statistics are available
- Message counts are accurate
- Error rates are low or zero

#### 8.2 Test Flow Logging
**Action in Node-RED:**
1. Check debug output
2. Verify logging configuration
3. Test log levels

**Expected Result:**
- Debug output is working
- Logging is properly configured
- Log levels are appropriate

## Test Results Documentation

### Pass Criteria
- Node-RED interface is accessible
- All flows are deployed and active
- MQTT messages are received correctly
- Data validation works properly
- Data transformation is correct
- InfluxDB writes are successful
- Error handling works as expected
- Performance is acceptable
- Monitoring and logging work

### Fail Criteria
- Node-RED interface is not accessible
- Flows are not deployed or show errors
- MQTT messages are not received
- Data validation fails
- Data transformation errors
- InfluxDB write failures
- Poor error handling
- Performance issues
- Monitoring/logging problems

## Troubleshooting

### Common Issues

#### 1. Node-RED Not Accessible
**Problem:** Cannot access http://localhost:1880
**Solution:**
```powershell
# Check Node-RED container status
docker-compose ps node-red

# Check Node-RED logs
docker-compose logs node-red

# Restart Node-RED service
docker-compose restart node-red
```

#### 2. Flows Not Deployed
**Problem:** Flows show red status or are not deployed
**Solution:**
```powershell
# Check Node-RED logs for deployment errors
docker-compose logs node-red

# Redeploy flows manually in Node-RED interface
# Check flow configuration files
```

#### 3. MQTT Connection Issues
**Problem:** Node-RED cannot connect to MQTT broker
**Solution:**
```powershell
# Check MQTT broker status
docker-compose ps mosquitto

# Verify MQTT configuration in Node-RED
# Check network connectivity between containers
```

#### 4. InfluxDB Write Failures
**Problem:** Data not being written to InfluxDB
**Solution:**
```powershell
# Check InfluxDB status
docker-compose ps influxdb

# Verify InfluxDB connection settings in Node-RED
# Check InfluxDB logs for errors
docker-compose logs influxdb
```

## Next Steps
If Node-RED data processing testing passes, proceed to:
- [Manual Test 04: InfluxDB Data Storage](./04-influxdb-data-storage.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ Node-RED interface accessible
□ All flows deployed
□ MQTT message reception
□ Data validation
□ Data transformation
□ InfluxDB output
□ Error handling
□ Performance
□ Monitoring/logging

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 