# Manual Test 04: InfluxDB Data Storage

## Overview
This test verifies that InfluxDB is properly receiving, storing, and managing time-series data from the renewable energy monitoring system.

## Test Objective
Ensure InfluxDB is correctly storing device data, maintaining data integrity, and providing proper query capabilities.

## Prerequisites
- Manual Test 01, 02, and 03 completed successfully
- InfluxDB accessible at http://localhost:8086
- Node-RED flows sending data to InfluxDB
- PowerShell available for API testing

## Test Steps

### Step 1: Verify InfluxDB Service Status

#### 1.1 Check InfluxDB Health
**Command:**
```powershell
curl -f http://localhost:8086/health
```

**Expected Result:**
- Returns HTTP 200 OK
- JSON response indicating service is healthy
- No error messages

#### 1.2 Check InfluxDB Container Status
**Command:**
```powershell
docker-compose ps influxdb
```

**Expected Result:**
- Container shows "Up (healthy)" status
- No error messages
- Port 8086 is properly mapped

### Step 2: Test Database Schema and Buckets

#### 2.1 Check Available Measurements
**Command:**
```powershell
# List all measurements in the database (InfluxQL syntax for InfluxDB 3.x)
$params = @{
    db = "renewable_energy"
    q = "SHOW MEASUREMENTS"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Returns list of available buckets
- Should include buckets for different device types
- No error messages

#### 2.2 Verify Schema Structure
**Command:**
```powershell
# Check photovoltaic data schema (InfluxQL syntax for InfluxDB 3.x)
$params = @{
    db = "renewable_energy"
    q = "SHOW MEASUREMENTS"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Check field keys for photovoltaic data
$params = @{
    db = "renewable_energy"
    q = "SHOW FIELD KEYS FROM photovoltaic_data"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Check tag keys for photovoltaic data
$params = @{
    db = "renewable_energy"
    q = "SHOW TAG KEYS FROM photovoltaic_data"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Measurements list includes device types
- Field keys match expected schema
- Tag keys include device_id, location, status, etc.

### Step 3: Test Data Writing

#### 3.1 Send Test Data via MQTT and Verify Storage
**Command:**
```powershell
# Send test photovoltaic data
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

# Wait for processing
Start-Sleep -Seconds 5

# Query the data to verify it was stored
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE device_id='pv_001' ORDER BY time DESC LIMIT 1"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Data is written to InfluxDB successfully
- Query returns the stored data
- All fields are present and correct

#### 3.2 Test Multiple Device Types
**Command:**
```powershell
# Send wind turbine data
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

# Send biogas plant data
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

# Wait for processing
Start-Sleep -Seconds 5

# Query all device types
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM wind_turbine_data WHERE device_id='wt_001' ORDER BY time DESC LIMIT 1"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM biogas_plant_data WHERE device_id='bg_001' ORDER BY time DESC LIMIT 1"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- All device types are stored correctly
- Data is properly categorized by device type
- All fields are preserved

### Step 4: Test Data Querying

#### 4.1 Test Basic Queries
**Command:**
```powershell
# Query recent photovoltaic data
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data ORDER BY time DESC LIMIT 10"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Query data for specific device
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE device_id='pv_001' ORDER BY time DESC LIMIT 5"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Query data for specific time range
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE time > now() - 1h ORDER BY time DESC"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Queries execute successfully
- Data is returned in correct format
- Time filtering works properly

#### 4.2 Test Aggregation Queries
**Command:**
```powershell
# Calculate average power output
$params = @{
    db = "renewable_energy"
    q = "SELECT MEAN(power_output) FROM photovoltaic_data WHERE time > now() - 1h"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Calculate maximum temperature
$params = @{
    db = "renewable_energy"
    q = "SELECT MAX(temperature) FROM photovoltaic_data WHERE time > now() - 1h"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Count total records
$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM photovoltaic_data WHERE time > now() - 1h"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Aggregation functions work correctly
- Results are mathematically accurate
- No calculation errors

#### 4.3 Test Group By Queries
**Command:**
```powershell
# Group by device_id
$params = @{
    db = "renewable_energy"
    q = "SELECT MEAN(power_output) FROM photovoltaic_data WHERE time > now() - 1h GROUP BY device_id"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Group by location
$params = @{
    db = "renewable_energy"
    q = "SELECT MEAN(power_output) FROM photovoltaic_data WHERE time > now() - 1h GROUP BY location"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Grouping works correctly
- Results are properly categorized
- No grouping errors

### Step 5: Test Data Retention and Performance

#### 5.1 Test Data Retention Policies
**Command:**
```powershell
# Check data age (InfluxQL syntax for InfluxDB 3.x)
$params = @{
    db = "renewable_energy"
    q = "SELECT MIN(time), MAX(time) FROM photovoltaic_data"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Check measurements information
$params = @{
    db = "renewable_energy"
    q = "SHOW MEASUREMENTS"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Retention policies are configured
- Data age is within expected range
- No retention policy errors

#### 5.2 Test Query Performance
**Command:**
```powershell
# Test query execution time
$startTime = Get-Date
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE time > now() - 1h ORDER BY time DESC"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing | Out-Null
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Query execution time: $($duration.TotalMilliseconds) ms"
```

**Expected Result:**
- Query execution time is reasonable (< 1000ms for simple queries)
- No timeout errors
- Performance is consistent

### Step 6: Test Data Integrity

#### 6.1 Test Data Consistency
**Command:**
```powershell
# Send multiple data points and verify consistency
for ($i = 1; $i -le 10; $i++) {
    $data = @{
        device_id = "pv_001"
        device_type = "photovoltaic"
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        data = @{
            irradiance = 850.5 + $i
            temperature = 45.2 + ($i * 0.1)
            voltage = 48.3
            current = 12.1
            power_output = 584.43 + ($i * 10)
        }
        status = "operational"
        location = "site_a"
        test_id = $i
    } | ConvertTo-Json -Depth 3

    mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $data
    Start-Sleep -Milliseconds 100
}

# Wait for processing
Start-Sleep -Seconds 5

# Verify all data points were stored
$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM photovoltaic_data WHERE device_id='pv_001' AND time > now() - 5m"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- All data points are stored
- No data loss
- Count matches expected number

#### 6.2 Test Data Validation
**Command:**
```powershell
# Check for data type consistency
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE power_output < 0 OR temperature < -50 OR temperature > 100"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Check for missing required fields
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE device_id = '' OR location = ''"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- No invalid data types
- No missing required fields
- Data quality is maintained

### Step 7: Test Error Handling

#### 7.1 Test Invalid Query Handling
**Command:**
```powershell
# Test invalid SQL syntax
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM invalid_table"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Test invalid field names
$params = @{
    db = "renewable_energy"
    q = "SELECT invalid_field FROM photovoltaic_data LIMIT 1"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

**Expected Result:**
- Proper error messages returned
- No system crashes
- Error handling works correctly

#### 7.2 Test Connection Resilience
**Command:**
```powershell
# Test connection under load
for ($i = 1; $i -le 50; $i++) {
    $params = @{
        db = "renewable_energy"
        q = "SELECT COUNT(*) FROM photovoltaic_data"
    }
    Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing | Out-Null
    Start-Sleep -Milliseconds 50
}
```

**Expected Result:**
- All queries complete successfully
- No connection errors
- System remains stable

### Step 8: Test Backup and Recovery

#### 8.1 Test Data Export
**Command:**
```powershell
# Export recent data
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data WHERE time > now() - 1h"
}
$response = Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
$response.Content | Out-File -FilePath "backup_data.json" -Encoding UTF8
```

**Expected Result:**
- Data export completes successfully
- Export file is created
- Data format is correct

#### 8.2 Test Data Import (if needed)
**Command:**
```powershell
# This would be used for testing data import functionality
# curl -X POST "http://localhost:8086/write?db=renewable_energy" --data-binary @backup_data.json
```

**Expected Result:**
- Import functionality works (if implemented)
- No data corruption
- Import completes successfully

## Test Results Documentation

### Pass Criteria
- InfluxDB service is healthy and accessible
- Database schema is properly configured
- Data writing works correctly for all device types
- Queries execute successfully and return accurate results
- Data integrity is maintained
- Performance is acceptable
- Error handling works properly
- Backup/export functionality works

### Fail Criteria
- InfluxDB service is not accessible
- Database schema is incorrect or missing
- Data writing fails
- Queries return errors or incorrect results
- Data integrity issues
- Performance problems
- Poor error handling
- Backup/export failures

## Troubleshooting

### Common Issues

#### 1. InfluxDB Not Accessible
**Problem:** Cannot connect to InfluxDB on port 8086
**Solution:**
```powershell
# Check container status
docker-compose ps influxdb

# Check logs
docker-compose logs influxdb

# Restart service
docker-compose restart influxdb
```

#### 2. Database Schema Issues
**Problem:** Missing tables or incorrect schema
**Solution:**
```powershell
# Check database initialization
docker-compose logs influxdb

# Verify schema files
Get-Content influxdb/config/schemas/*.json

# Reinitialize database if needed
docker-compose down
docker-compose up -d
```

#### 3. Data Writing Failures
**Problem:** Data not being written to InfluxDB
**Solution:**
```powershell
# Check Node-RED connection to InfluxDB
# Verify InfluxDB write permissions
# Check network connectivity between containers
```

#### 4. Query Performance Issues
**Problem:** Slow query execution
**Solution:**
```powershell
# Check InfluxDB resource usage
docker stats influxdb

# Optimize queries
# Check for proper indexing
```

## Next Steps
If InfluxDB data storage testing passes, proceed to:
- [Manual Test 05: Grafana Data Visualization](./05-grafana-data-visualization.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ InfluxDB service healthy
□ Database schema correct
□ Data writing functional
□ Query execution successful
□ Data integrity maintained
□ Performance acceptable
□ Error handling working
□ Backup/export functional

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 