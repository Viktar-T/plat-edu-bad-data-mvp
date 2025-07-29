# Manual Test 04: InfluxDB Data Storage

## Overview
This test verifies that InfluxDB 3.x is properly receiving, storing, and managing time-series data from the renewable energy monitoring system.

## Test Objective
Ensure InfluxDB 3.x is correctly storing device data, maintaining data integrity, and providing proper query capabilities.

## Prerequisites
- Manual Test 01, 02, and 03 completed successfully
- InfluxDB 2.x accessible at http://localhost:8086
- Node-RED flows sending data to InfluxDB
- PowerShell available for API testing
- Docker containers running and healthy
- Testing framework available in `tests/scripts/` directory

## InfluxDB 2.x Setup and Configuration

### Note: Token-Based Authentication
Your InfluxDB 2.x instance is configured with token-based authentication using the static token `renewable_energy_admin_token_123` for the organization `renewable_energy_org`.

### Verify InfluxDB 2.x Setup
```powershell
# Check InfluxDB health
Invoke-WebRequest -Uri "http://localhost:8086/health" -Method GET -UseBasicParsing

# Check InfluxDB version and status with authentication
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/orgs" -Method GET -Headers $headers -UseBasicParsing
```

### Create Organization and Bucket (if needed)
Since authentication is enabled, you can create resources via API with proper authentication:

```powershell
# Create organization (if needed)
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}

$orgData = @{
    name = "renewable_energy_org"
    description = "Renewable Energy Monitoring Organization"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/orgs" -Method POST -Headers $headers -Body $orgData -UseBasicParsing

# Create bucket (if needed)
$bucketData = @{
    name = "renewable_energy"
    orgID = "renewable_energy_org"
    retentionRules = @(
        @{
            type = "expire"
            everySeconds = 2592000  # 30 days
        }
    )
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/buckets" -Method POST -Headers $headers -Body $bucketData -UseBasicParsing
```

### Set Environment Variables
```powershell
# Set environment variables for InfluxDB 2.x
$env:INFLUXDB_ORG = "renewable_energy_org"
$env:INFLUXDB_BUCKET = "renewable_energy"
$env:INFLUXDB_TOKEN = "renewable_energy_admin_token_123"
```

## Automated Testing Framework

### Quick Health Check
Before running manual tests, you can use the automated testing framework for quick validation:

```powershell
# Run comprehensive health check
.\tests\scripts\test-influxdb-health.ps1

# Run data flow test
.\tests\scripts\test-data-flow.ps1

# Run Flux query tests
.\tests\scripts\test-flux-queries.ps1

# Run all tests
.\tests\run-all-tests.ps1
```

### Test Framework Features
- **Health Check**: Service status, connectivity, authentication, organization/bucket access
- **Data Flow**: End-to-end testing from MQTT to Grafana
- **Flux Queries**: Query testing with performance validation
- **Integration**: Cross-component authentication and data consistency
- **Performance**: Load testing and benchmarking

## Test Steps

### Step 1: Verify InfluxDB Service Status

#### 1.1 Check InfluxDB Health
**Command:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8086/health" -Method GET -UseBasicParsing
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

#### 2.1 Check Available Buckets (InfluxDB 3.x)
**Command:**
```powershell
# For InfluxDB 3.x, we need to use the InfluxDB CLI or API with proper authentication
# Option 1: Using API to list buckets
$headers = @{"Content-Type"="application/json"}
$body = @{query="buckets()"; org=$env:INFLUXDB_ORG} | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Option 2: Using InfluxDB 3.x API (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# List buckets using InfluxDB 3.x API
$body = @{
    query = "buckets()"
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Returns list of available buckets
- Should include buckets for different device types
- No error messages

#### 2.2 Verify Schema Structure (InfluxDB 3.x)
**Command:**
```powershell
# For InfluxDB 3.x, we need to use Flux query language
# Option 1: Using API with Flux
$headers = @{"Content-Type"="application/json"}
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> keys()"
$body = @{query=$fluxQuery; org=$env:INFLUXDB_ORG} | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Option 2: Using API with Flux (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Query to get measurement names (using Flux)
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> keys()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Query to get field keys for photovoltaic data
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> keys()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Buckets list includes device types
- Field keys match expected schema
- Tag keys include device_id, location, status, etc.

### Step 3: Test Data Writing

#### 3.1 Send Test Data via MQTT and Verify Storage
**Command:**
```powershell
# Option 1: Using the automated MQTT test script
.\tests\scripts\test-mqtt.ps1 -PublishTest -Topic "devices/photovoltaic/pv_001/data" -Message '{"device_id":"pv_001","device_type":"photovoltaic","timestamp":"2024-01-15T10:30:00Z","data":{"irradiance":850.5,"temperature":45.2,"voltage":48.3,"current":12.1,"power_output":584.43},"status":"operational","location":"site_a"}'

# Option 2: Using Docker exec to run mosquitto_pub inside the container
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

docker exec -it iot-mosquitto mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $testData

# Wait for processing
Start-Sleep -Seconds 5

# Query the data to verify it was stored (InfluxDB 2.x with Flux)
$headers = @{
    "Authorization" = "Token $env:INFLUXDB_TOKEN"
    "Content-Type" = "application/json"
}

$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -5m) |> filter(fn: (r) => r.device_id == `pv_001`) |> last()"
$body = @{
    query = $fluxQuery
    type = "flux"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=$env:INFLUXDB_ORG" -Method POST -Headers $headers -Body $body -UseBasicParsing
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

docker exec -it iot-mosquitto mosquitto_pub -h localhost -p 1883 -u wt_001 -P device_password_123 -t devices/wind_turbine/wt_001/data -m $wtData

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

docker exec -it iot-mosquitto mosquitto_pub -h localhost -p 1883 -u bg_001 -P device_password_123 -t devices/biogas_plant/bg_001/data -m $bgData

# Wait for processing
Start-Sleep -Seconds 5

# Query all device types (InfluxDB 3.x with Flux)
$headers = @{
    "Content-Type" = "application/json"
}

# Query wind turbine data
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -5m) |> filter(fn: (r) => r.device_id == `wt_001`) |> last()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Query biogas plant data
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -5m) |> filter(fn: (r) => r.device_id == `bg_001`) |> last()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- All device types are stored correctly
- Data is properly categorized by device type
- All fields are preserved

### Step 4: Test Data Querying

#### 4.1 Test Basic Queries (InfluxDB 3.x with Flux)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Query recent photovoltaic data
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> limit(n: 10)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Query data for specific device
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r.device_id == `pv_001`) |> limit(n: 5)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Query data for specific time range
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Queries execute successfully
- Data is returned in correct format
- Time filtering works properly

#### 4.2 Test Aggregation Queries (InfluxDB 3.x with Flux)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Calculate average power output
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> filter(fn: (r) => r._field == `power_output`) |> mean()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Calculate maximum temperature
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> filter(fn: (r) => r._field == `temperature`) |> max()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Count total records
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> count()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Aggregation functions work correctly
- Results are mathematically accurate
- No calculation errors

#### 4.3 Test Group By Queries (InfluxDB 3.x with Flux)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Group by device_id
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> filter(fn: (r) => r._field == `power_output`) |> group(columns: [`device_id`]) |> mean()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Group by location
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> filter(fn: (r) => r._field == `power_output`) |> group(columns: [`location`]) |> mean()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Grouping works correctly
- Results are properly categorized
- No grouping errors

### Step 5: Test Data Retention and Performance

#### 5.1 Test Data Retention Policies (InfluxDB 3.x)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Check data age using Flux
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -30d) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> first() |> yield(name: `first`) |> from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -30d) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> last() |> yield(name: `last`)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Check bucket information using API
$bucketQuery = "buckets()"
$body = @{
    query = $bucketQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Retention policies are configured
- Data age is within expected range
- No retention policy errors

#### 5.2 Test Query Performance (InfluxDB 3.x)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Test query execution time
$startTime = Get-Date
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing | Out-Null
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

    docker exec -it iot-mosquitto mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $data
    Start-Sleep -Milliseconds 100
}

# Wait for processing
Start-Sleep -Seconds 5

# Verify all data points were stored (InfluxDB 3.x with Flux)
$headers = @{
    "Content-Type" = "application/json"
}

$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -5m) |> filter(fn: (r) => r.device_id == `pv_001`) |> count()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- All data points are stored
- No data loss
- Count matches expected number

#### 6.2 Test Data Validation (InfluxDB 3.x)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Check for data type consistency
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> filter(fn: (r) => r._field == `power_output` and r._value < 0 or r._field == `temperature` and (r._value < -50 or r._value > 100))"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Check for missing required fields
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> filter(fn: (r) => r.device_id == `` or r.location == ``)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- No invalid data types
- No missing required fields
- Data quality is maintained

### Step 7: Test Error Handling

#### 7.1 Test Invalid Query Handling (InfluxDB 3.x)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Test invalid Flux syntax
$fluxQuery = "from(bucket: `invalid_bucket`) |> range(start: -1h)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Test invalid field names
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._field == `invalid_field`)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
```

**Expected Result:**
- Proper error messages returned
- No system crashes
- Error handling works correctly

#### 7.2 Test Connection Resilience (InfluxDB 3.x)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Test connection under load
for ($i = 1; $i -le 50; $i++) {
    $fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`) |> count()"
    $body = @{
        query = $fluxQuery
        org = $env:INFLUXDB_ORG
    } | ConvertTo-Json

    Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing | Out-Null
    Start-Sleep -Milliseconds 50
}
```

**Expected Result:**
- All queries complete successfully
- No connection errors
- System remains stable

### Step 8: Test Backup and Recovery

#### 8.1 Test Data Export (InfluxDB 3.x)
**Command:**
```powershell
# Set up headers for InfluxDB 3.x (no authentication required)
$headers = @{
    "Content-Type" = "application/json"
}

# Export recent data using Flux
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> filter(fn: (r) => r._measurement == `photovoltaic_data`)"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
$response.Content | Out-File -FilePath "backup_data.json" -Encoding UTF8

# Alternative: Use API for CSV export
$fluxQuery = "from(bucket: `$env:INFLUXDB_BUCKET`) |> range(start: -1h) |> toCSV()"
$body = @{
    query = $fluxQuery
    org = $env:INFLUXDB_ORG
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query" -Method POST -Headers $headers -Body $body -UseBasicParsing
$response.Content | Out-File -FilePath "backup_data.csv" -Encoding UTF8
```

**Expected Result:**
- Data export completes successfully
- Export file is created
- Data format is correct

#### 8.2 Test Data Import (InfluxDB 3.x)
**Command:**
```powershell
# For InfluxDB 3.x, data import is typically done through the write API
# Example: Write data points using the InfluxDB 3.x write API
$writeData = "photovoltaic_data,device_id=pv_001,location=site_a power_output=584.43,temperature=45.2,irradiance=850.5 $(Get-Date -UFormat %s)000000000"

$headers = @{
    "Content-Type" = "text/plain; charset=utf-8"
}

Invoke-WebRequest -Uri "http://localhost:8086/api/v2/write?bucket=$env:INFLUXDB_BUCKET&org=$env:INFLUXDB_ORG" -Method POST -Headers $headers -Body $writeData
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

#### 1. InfluxDB 2.x Not Accessible
**Problem:** Cannot connect to InfluxDB 2.x on port 8086
**Solution:**
```powershell
# Run automated health check
.\tests\scripts\test-influxdb-health.ps1

# Check container status
docker-compose ps influxdb

# Check logs
docker-compose logs influxdb

# Restart service
docker-compose restart influxdb

# Verify InfluxDB 2.x is running
docker exec -it iot-influxdb2 influx ping
```

#### 2. Organization/Bucket Issues
**Problem:** Organization or bucket not found
**Solution:**
```powershell
# Run automated health check for detailed diagnostics
.\tests\scripts\test-influxdb-health.ps1

# List organizations using API
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/orgs" -Method GET -Headers $headers -UseBasicParsing

# Create organization if missing
$orgData = @{
    name = "renewable_energy_org"
    description = "Renewable Energy Monitoring Organization"
} | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/orgs" -Method POST -Headers $headers -Body $orgData -UseBasicParsing

# List buckets using API
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/buckets?org=renewable_energy_org" -Method GET -Headers $headers -UseBasicParsing

# Create bucket if missing
$bucketData = @{
    name = "renewable_energy"
    orgID = "renewable_energy_org"
    retentionRules = @(
        @{
            type = "expire"
            everySeconds = 2592000  # 30 days
        }
    )
} | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/buckets" -Method POST -Headers $headers -Body $bucketData -UseBasicParsing
```

#### 3. Data Writing Failures
**Problem:** Data not being written to InfluxDB 2.x
**Solution:**
```powershell
# Run automated data flow test for diagnostics
.\tests\scripts\test-data-flow.ps1

# Check Node-RED connection to InfluxDB 2.x
# Verify InfluxDB write permissions
# Check network connectivity between containers

# Test write API directly
$writeData = "test_measurement,device_id=test value=123 $(Get-Date -UFormat %s)000000000"
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "text/plain; charset=utf-8"
}
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/write?bucket=renewable_energy&org=renewable_energy_org" -Method POST -Headers $headers -Body $writeData
```

#### 4. Query Performance Issues
**Problem:** Slow Flux query execution
**Solution:**
```powershell
# Run automated performance tests
.\tests\scripts\test-performance.ps1

# Check InfluxDB resource usage
docker stats influxdb

# Optimize Flux queries
# Check for proper time range filters
# Use appropriate aggregation functions

# Test query performance
$startTime = Get-Date
# Run your query here
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Query execution time: $($duration.TotalMilliseconds) ms"
```

#### 5. Flux Query Syntax Issues
**Problem:** Flux queries return errors
**Solution:**
```powershell
# Run automated Flux query tests
.\tests\scripts\test-flux-queries.ps1

# Test simple Flux query first
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/json"
}
$body = @{
    query = "buckets()"
    type = "flux"
} | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body -UseBasicParsing

# Check Flux syntax documentation
# Use InfluxDB UI for query testing
# Verify bucket and measurement names
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