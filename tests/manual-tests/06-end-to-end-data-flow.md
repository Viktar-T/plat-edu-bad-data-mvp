# Manual Test 06: End-to-End Data Flow

## Overview
This test verifies the complete data flow from MQTT message publishing through Node-RED processing, InfluxDB storage, and Grafana visualization in a single integrated test.

## Test Objective
Ensure the entire data pipeline works seamlessly from device data input to dashboard visualization, validating the complete renewable energy monitoring system.

## Prerequisites
- All previous manual tests (01-05) completed successfully
- All services running and healthy
- Test environment prepared with sample data
- Testing framework available in `tests/scripts/` directory

## Automated Testing Framework

### Quick End-to-End Test
Before running manual tests, you can use the automated testing framework for quick validation:

```powershell
# Run comprehensive end-to-end data flow test
.\tests\scripts\test-data-flow.ps1

# Run integration tests
.\tests\scripts\test-integration.ps1

# Run performance tests
.\tests\scripts\test-performance.ps1

# Run all tests
.\tests\run-all-tests.ps1
```

### Test Framework Features
- **Data Flow**: Complete end-to-end testing from MQTT to Grafana
- **Integration**: Cross-component authentication and data consistency
- **Performance**: Load testing and benchmarking
- **Error Recovery**: Service interruption and recovery testing

## Test Steps

### Step 1: Prepare Test Environment

#### 1.1 Verify All Services Status
**Command:**
```powershell
# Check all services are running
docker-compose ps

# Verify all services are healthy
docker-compose ps | Select-String "healthy"
```

**Expected Result:**
- All services show "Up (healthy)" status
- No services are down or unhealthy

#### 1.2 Clear Previous Test Data (Optional)
**Command:**
```powershell
# Clear previous test data from InfluxDB 2.x (if needed)
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}

# Delete photovoltaic data
$fluxQuery = "from(bucket: `"renewable_energy`") |> range(start: -1h) |> filter(fn: (r) => r._measurement == `"photovoltaic_data`") |> drop()"
$body = @{
    query = $fluxQuery
    type = "flux"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Delete wind turbine data
$fluxQuery = "from(bucket: `"renewable_energy`") |> range(start: -1h) |> filter(fn: (r) => r._measurement == `"wind_turbine_data`") |> drop()"
$body = @{
    query = $fluxQuery
    type = "flux"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Delete biogas plant data
$fluxQuery = "from(bucket: `"renewable_energy`") |> range(start: -1h) |> filter(fn: (r) => r._measurement == `"biogas_plant_data`") |> drop()"
$body = @{
    query = $fluxQuery
    type = "flux"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Previous test data is cleared (if executed)
- No errors in deletion queries

### Step 2: Test Complete Photovoltaic Data Flow

#### 2.1 Send Photovoltaic Test Data
**Command:**
```powershell
# Option 1: Using the automated MQTT test script
Write-Host "Sending photovoltaic test data..." -ForegroundColor Yellow
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/photovoltaic/pv_001/data" -Message '{"device_id":"pv_001","device_type":"photovoltaic","timestamp":"2024-01-15T10:30:00Z","data":{"irradiance":850.5,"temperature":45.2,"voltage":48.3,"current":12.1,"power_output":584.43},"status":"operational","location":"site_a","test_id":"e2e_test_001"}'
Write-Host "✓ Photovoltaic data sent via MQTT" -ForegroundColor Green

# Option 2: Using Docker exec to run mosquitto_pub inside the container
$pvTestData = @{
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
    test_id = "e2e_test_001"
} | ConvertTo-Json -Depth 3

docker exec -it iot-mosquitto mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $pvTestData
```

**Expected Result:**
- Message published successfully
- No MQTT errors
- Confirmation message displayed

#### 2.2 Verify Node-RED Processing
**Action:**
1. Open Node-RED at http://localhost:1880
2. Check photovoltaic simulation flow
3. Verify message received and processed
4. Check debug output

**Expected Result:**
- Message appears in Node-RED debug
- Data validation passes
- Transformation completed successfully
- InfluxDB write confirmed

#### 2.3 Verify InfluxDB Storage
**Command:**
```powershell
# Wait for processing
Start-Sleep -Seconds 3

# Query InfluxDB 2.x for the test data
Write-Host "Checking InfluxDB storage..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}

$fluxQuery = "from(bucket: `"renewable_energy`") |> range(start: -5m) |> filter(fn: (r) => r.device_id == `"pv_001`") |> last()"
$body = @{
    query = $fluxQuery
    type = "flux"
} | ConvertTo-Json

$influxResult = Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body -UseBasicParsing

if ($influxResult.Content -match "e2e_test_001") {
    Write-Host "✓ Data stored in InfluxDB" -ForegroundColor Green
} else {
    Write-Host "✗ Data not found in InfluxDB" -ForegroundColor Red
}
```

**Expected Result:**
- Data is found in InfluxDB
- All fields are preserved
- Timestamp is correct

#### 2.4 Verify Grafana Visualization
**Action:**
1. Open Grafana at http://localhost:3000
2. Navigate to Photovoltaic Monitoring dashboard
3. Check if new data appears
4. Verify data values are correct

**Expected Result:**
- New data appears in dashboard
- Values match the sent data
- Real-time update works

### Step 3: Test Complete Wind Turbine Data Flow

#### 3.1 Send Wind Turbine Test Data
**Command:**
```powershell
# Create comprehensive wind turbine test data
$wtTestData = @{
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
    test_id = "e2e_test_002"
} | ConvertTo-Json -Depth 3

Write-Host "Sending wind turbine test data..." -ForegroundColor Yellow
mosquitto_pub -h localhost -p 1883 -u wt_001 -P device_password_123 -t devices/wind_turbine/wt_001/data -m $wtTestData
Write-Host "✓ Wind turbine data sent via MQTT" -ForegroundColor Green
```

**Expected Result:**
- Message published successfully
- No MQTT errors
- Confirmation message displayed

#### 3.2 Verify Complete Wind Turbine Flow
**Action:**
1. Check Node-RED wind turbine flow
2. Verify InfluxDB storage
3. Check Grafana Wind Turbine Analytics dashboard

**Expected Result:**
- Complete flow works for wind turbine data
- Data appears in all components
- Values are consistent across the pipeline

### Step 4: Test Complete Biogas Plant Data Flow

#### 4.1 Send Biogas Plant Test Data
**Command:**
```powershell
# Create comprehensive biogas plant test data
$bgTestData = @{
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
    test_id = "e2e_test_003"
} | ConvertTo-Json -Depth 3

Write-Host "Sending biogas plant test data..." -ForegroundColor Yellow
mosquitto_pub -h localhost -p 1883 -u bg_001 -P device_password_123 -t devices/biogas_plant/bg_001/data -m $bgTestData
Write-Host "✓ Biogas plant data sent via MQTT" -ForegroundColor Green
```

**Expected Result:**
- Message published successfully
- No MQTT errors
- Confirmation message displayed

#### 4.2 Verify Complete Biogas Plant Flow
**Action:**
1. Check Node-RED biogas plant flow
2. Verify InfluxDB storage
3. Check Grafana Biogas Plant Metrics dashboard

**Expected Result:**
- Complete flow works for biogas plant data
- Data appears in all components
- Values are consistent across the pipeline

### Step 5: Test Multiple Device Simultaneous Flow

#### 5.1 Send Multiple Device Data Simultaneously
**Command:**
```powershell
# Send data from multiple devices simultaneously
Write-Host "Testing simultaneous multi-device data flow..." -ForegroundColor Yellow

# Start background jobs for simultaneous sending
$jobs = @()

# Job 1: Photovoltaic data
$jobs += Start-Job -ScriptBlock {
    $data = @{
        device_id = "pv_002"
        device_type = "photovoltaic"
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        data = @{
            irradiance = 920.3
            temperature = 47.8
            voltage = 49.1
            current = 13.2
            power_output = 648.12
        }
        status = "operational"
        location = "site_a"
        test_id = "simultaneous_test_001"
    } | ConvertTo-Json -Depth 3
    
    mosquitto_pub -h localhost -p 1883 -u pv_002 -P device_password_123 -t devices/photovoltaic/pv_002/data -m $data
}

# Job 2: Wind turbine data
$jobs += Start-Job -ScriptBlock {
    $data = @{
        device_id = "wt_002"
        device_type = "wind_turbine"
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        data = @{
            wind_speed = 15.2
            power_output = 1200.5
            rpm = 1400
            temperature = 32.8
        }
        status = "operational"
        location = "site_b"
        test_id = "simultaneous_test_002"
    } | ConvertTo-Json -Depth 3
    
    mosquitto_pub -h localhost -p 1883 -u wt_002 -P device_password_123 -t devices/wind_turbine/wt_002/data -m $data
}

# Job 3: Biogas plant data
$jobs += Start-Job -ScriptBlock {
    $data = @{
        device_id = "bg_002"
        device_type = "biogas_plant"
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        data = @{
            gas_flow = 30.1
            methane_concentration = 68.5
            temperature = 40.2
            pressure = 1.4
        }
        status = "operational"
        location = "site_c"
        test_id = "simultaneous_test_003"
    } | ConvertTo-Json -Depth 3
    
    mosquitto_pub -h localhost -p 1883 -u bg_002 -P device_password_123 -t devices/biogas_plant/bg_002/data -m $data
}

# Wait for all jobs to complete
Get-Job | Wait-Job
Get-Job | Receive-Job
Get-Job | Remove-Job

Write-Host "✓ Simultaneous multi-device data sent" -ForegroundColor Green
```

**Expected Result:**
- All jobs complete successfully
- No conflicts or errors
- All devices send data simultaneously

#### 5.2 Verify Simultaneous Processing
**Action:**
1. Check Node-RED flows for all device types
2. Verify InfluxDB storage for all devices
3. Check Grafana dashboards for all device types

**Expected Result:**
- All data flows process simultaneously
- No data loss or corruption
- All dashboards update correctly

### Step 6: Test Data Flow Performance

#### 6.1 Test High-Volume Data Flow
**Command:**
```powershell
# Test high-volume data processing
Write-Host "Testing high-volume data flow..." -ForegroundColor Yellow

$startTime = Get-Date

# Send 100 messages rapidly
for ($i = 1; $i -le 100; $i++) {
    $data = @{
        device_id = "pv_003"
        device_type = "photovoltaic"
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        data = @{
            irradiance = 850.5 + $i
            temperature = 45.2 + ($i * 0.1)
            voltage = 48.3
            current = 12.1
            power_output = 584.43 + ($i * 5)
        }
        status = "operational"
        location = "site_a"
        message_id = $i
    } | ConvertTo-Json -Depth 3

    mosquitto_pub -h localhost -p 1883 -u pv_003 -P device_password_123 -t devices/photovoltaic/pv_003/data -m $data
    Start-Sleep -Milliseconds 50
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "✓ High-volume test completed in $($duration.TotalSeconds) seconds" -ForegroundColor Green
```

**Expected Result:**
- All messages are processed
- No significant delays
- System remains stable

#### 6.2 Verify High-Volume Data Storage
**Command:**
```powershell
# Verify all messages were stored
Start-Sleep -Seconds 5

$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM photovoltaic_data WHERE device_id='pv_003' AND time > now() - 5m"
}
$count = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

if ($count.Content -match "100") {
    Write-Host "✓ All 100 messages stored successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Not all messages were stored" -ForegroundColor Red
}
```

**Expected Result:**
- All messages are stored in InfluxDB
- Count matches expected number
- No data loss

### Step 7: Test Error Recovery

#### 7.1 Test Service Interruption Recovery
**Command:**
```powershell
# Test recovery from service interruption
Write-Host "Testing error recovery..." -ForegroundColor Yellow

# Temporarily stop InfluxDB
Write-Host "Stopping InfluxDB..." -ForegroundColor Yellow
docker-compose stop influxdb

# Send test data during interruption
$recoveryData = @{
    device_id = "pv_004"
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
    test_id = "recovery_test"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u pv_004 -P device_password_123 -t devices/photovoltaic/pv_004/data -m $recoveryData

# Restart InfluxDB
Write-Host "Restarting InfluxDB..." -ForegroundColor Yellow
docker-compose start influxdb

# Wait for service to be healthy
Start-Sleep -Seconds 30

# Check if data was eventually stored
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE test_id='recovery_test'"
}
$recoveryResult = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

if ($recoveryResult.Content -match "recovery_test") {
    Write-Host "✓ Recovery test successful - data was stored after service restart" -ForegroundColor Green
} else {
    Write-Host "✗ Recovery test failed - data was not stored" -ForegroundColor Red
}
```

**Expected Result:**
- System handles service interruption gracefully
- Data is eventually stored after recovery
- No permanent data loss

### Step 8: Test Data Consistency

#### 8.1 Verify Data Integrity Across Pipeline
**Command:**
```powershell
# Test data consistency across the entire pipeline
Write-Host "Testing data consistency..." -ForegroundColor Yellow

$consistencyData = @{
    device_id = "pv_005"
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
    test_id = "consistency_test"
} | ConvertTo-Json -Depth 3

# Send data
mosquitto_pub -h localhost -p 1883 -u pv_005 -P device_password_123 -t devices/photovoltaic/pv_005/data -m $consistencyData

# Wait for processing
Start-Sleep -Seconds 5

# Query InfluxDB for the data
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE test_id='consistency_test' ORDER BY time DESC LIMIT 1"
}
$storedData = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Compare sent vs stored data
if ($storedData.Content -match "850.5" -and $storedData.Content -match "45.2" -and $storedData.Content -match "584.43") {
    Write-Host "✓ Data consistency verified - values match across pipeline" -ForegroundColor Green
} else {
    Write-Host "✗ Data consistency failed - values do not match" -ForegroundColor Red
}
```

**Expected Result:**
- Data values are consistent across the pipeline
- No data corruption or modification
- All fields are preserved

### Step 9: Test Real-time Dashboard Updates

#### 9.1 Test Live Dashboard Updates
**Action:**
1. Open Grafana Renewable Energy Overview dashboard
2. Set time range to "Last 1 hour"
3. Send new test data
4. Watch for real-time updates

**Command:**
```powershell
# Send data for live dashboard test
$liveData = @{
    device_id = "pv_006"
    device_type = "photovoltaic"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        irradiance = 950.0
        temperature = 50.0
        voltage = 49.0
        current = 13.0
        power_output = 637.0
    }
    status = "operational"
    location = "site_a"
    test_id = "live_dashboard_test"
} | ConvertTo-Json -Depth 3

Write-Host "Sending data for live dashboard test..." -ForegroundColor Yellow
mosquitto_pub -h localhost -p 1883 -u pv_006 -P device_password_123 -t devices/photovoltaic/pv_006/data -m $liveData
```

**Expected Result:**
- Dashboard updates in real-time
- New data appears immediately
- All panels reflect the changes

### Step 10: Final System Validation

#### 10.1 Comprehensive System Check
**Command:**
```powershell
# Final comprehensive system validation
Write-Host "Performing final system validation..." -ForegroundColor Yellow

# Check all services
$services = docker-compose ps
Write-Host "Service Status:" -ForegroundColor Cyan
$services

# Check recent data in all device types
Write-Host "`nRecent Data Counts:" -ForegroundColor Cyan
$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM photovoltaic_data WHERE time > now() - 1h"
}
$pvCount = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM wind_turbine_data WHERE time > now() - 1h"
}
$wtCount = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM biogas_plant_data WHERE time > now() - 1h"
}
$bgCount = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

Write-Host "Photovoltaic: $pvCount"
Write-Host "Wind Turbine: $wtCount"
Write-Host "Biogas Plant: $bgCount"

# Test final data flow
$finalData = @{
    device_id = "final_test"
    device_type = "photovoltaic"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        irradiance = 1000.0
        temperature = 55.0
        voltage = 50.0
        current = 15.0
        power_output = 750.0
    }
    status = "operational"
    location = "final_test"
    test_id = "final_validation"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/final_test/data -m $finalData

Start-Sleep -Seconds 3

$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE test_id='final_validation'"
}
$finalResult = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

if ($finalResult.Content -match "final_validation") {
    Write-Host "`n✓ Final validation successful - complete data flow working" -ForegroundColor Green
} else {
    Write-Host "`n✗ Final validation failed" -ForegroundColor Red
}
```

**Expected Result:**
- All services are healthy
- Data is being stored for all device types
- Final data flow test passes
- System is fully operational

## Test Results Documentation

### Pass Criteria
- All individual device flows work correctly
- Simultaneous multi-device processing works
- High-volume data processing is successful
- Error recovery mechanisms work
- Data consistency is maintained
- Real-time dashboard updates work
- Final system validation passes
- No data loss or corruption
- Performance is acceptable

### Fail Criteria
- Any individual device flow fails
- Simultaneous processing causes issues
- High-volume processing fails
- Error recovery doesn't work
- Data inconsistency detected
- Real-time updates don't work
- Final validation fails
- Data loss or corruption occurs
- Performance issues

## Troubleshooting

### Common Issues

#### 1. Data Not Appearing in Grafana
**Problem:** Data sent via MQTT doesn't appear in dashboards
**Solution:**
```powershell
# Run automated data flow tests for diagnostics
.\tests\scripts\test-data-flow.ps1

# Check if data reached InfluxDB 2.x
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}

$fluxQuery = "from(bucket: `"renewable_energy`") |> range(start: -5m) |> filter(fn: (r) => r._measurement == `"photovoltaic_data`") |> count()"
$body = @{
    query = $fluxQuery
    type = "flux"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Check Node-RED flows
# Verify Grafana data source configuration
```

#### 2. Performance Issues
**Problem:** Slow data processing or dashboard loading
**Solution:**
```powershell
# Run automated performance tests
.\tests\scripts\test-performance.ps1

# Check system resources
docker stats

# Check service logs for bottlenecks
docker-compose logs node-red
docker-compose logs influxdb
docker-compose logs grafana
```

#### 3. Data Loss
**Problem:** Some data points are missing
**Solution:**
```powershell
# Check MQTT message delivery
# Verify Node-RED flow processing
# Check InfluxDB write operations
# Review error logs
```

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ Individual device flows
□ Simultaneous processing
□ High-volume processing
□ Error recovery
□ Data consistency
□ Real-time updates
□ Final validation
□ Performance
□ Data integrity

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]

Performance Metrics:
- Total test duration: [X] minutes
- Messages processed: [X]
- Average processing time: [X] ms
- Data loss rate: [X]%
``` 