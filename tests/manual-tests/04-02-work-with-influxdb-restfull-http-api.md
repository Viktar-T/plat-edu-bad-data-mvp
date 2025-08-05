# Manual Test: Working with InfluxDB RESTful HTTP API

## Test Overview
This manual test covers how to use InfluxDB 2.x RESTful HTTP API to query and write data for external web applications.

## Prerequisites
- InfluxDB 2.x running on `http://localhost:8086`
- PowerShell or curl available
- Valid InfluxDB token: `renewable_energy_admin_token_123`
- Organization: `renewable_energy_org`

## Test Environment
- **InfluxDB URL**: `http://localhost:8086`
- **Organization**: `renewable_energy_org`
- **Token**: `renewable_energy_admin_token_123`
- **Bucket**: `renewable_energy`

## Test Cases

### Test Case 1: Basic API Health Check

#### Objective
Verify that the InfluxDB API is accessible and responding.

#### Steps
1. **Check API health endpoint**:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8086/health" -UseBasicParsing
   ```

#### Expected Results
- Status code: 200 OK
- Response contains InfluxDB version information
- Service status: "pass"

#### Status: ⏳ PENDING

### Test Case 2: Query Data via HTTP API

#### Objective
Test querying data from InfluxDB using the REST API.

#### Steps
1. **Query recent data**:
   ```powershell
   $headers = @{
       "Authorization" = "Token renewable_energy_admin_token_123"
       "Content-Type" = "application/json"
       "Accept" = "application/csv"
   }
   
   $body = @{
       query = 'from(bucket: "renewable_energy") |> range(start: -1h) |> limit(n: 10)'
       type = "flux"
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body
   ```

#### Expected Results
- Status code: 200 OK
- Response contains CSV data
- No authentication errors

#### Status: ⏳ PENDING

### Test Case 3: Write Data via HTTP API

#### Objective
Test writing data to InfluxDB using the REST API.

#### Steps
1. **Write test data**:
   ```powershell
   $headers = @{
       "Authorization" = "Token renewable_energy_admin_token_123"
       "Content-Type" = "text/plain; charset=utf-8"
   }
   
   $lineProtocol = "api_test,device_id=test001,device_type=photovoltaic power=1500,voltage=48.5,current=30.9"
   
   Invoke-WebRequest -Uri "http://localhost:8086/api/v2/write?org=renewable_energy_org&bucket=renewable_energy" -Method POST -Headers $headers -Body $lineProtocol
   ```

#### Expected Results
- Status code: 204 No Content (success)
- No error messages
- Data appears in InfluxDB

#### Status: ⏳ PENDING

### Test Case 4: Query Written Data

#### Objective
Verify that data written via API can be retrieved.

#### Steps
1. **Query the test data**:
   ```powershell
   $headers = @{
       "Authorization" = "Token renewable_energy_admin_token_123"
       "Content-Type" = "application/json"
       "Accept" = "application/csv"
   }
   
   $body = @{
       query = 'from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "api_test")'
       type = "flux"
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body
   ```

#### Expected Results
- Status code: 200 OK
- Response contains the test data
- Data matches what was written

#### Status: ⏳ PENDING

### Test Case 5: Error Handling

#### Objective
Test API error handling with invalid requests.

#### Steps
1. **Test invalid token**:
   ```powershell
   $headers = @{
       "Authorization" = "Token invalid_token"
       "Content-Type" = "application/json"
   }
   
   $body = @{
       query = 'from(bucket: "renewable_energy") |> range(start: -1h)'
       type = "flux"
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body
   ```

2. **Test invalid query**:
   ```powershell
   $headers = @{
       "Authorization" = "Token renewable_energy_admin_token_123"
       "Content-Type" = "application/json"
   }
   
   $body = @{
       query = 'invalid_flux_query'
       type = "flux"
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=renewable_energy_org" -Method POST -Headers $headers -Body $body
   ```

#### Expected Results
- Invalid token: 401 Unauthorized
- Invalid query: 400 Bad Request
- Proper error messages returned

#### Status: ⏳ PENDING

## PowerShell Helper Functions

### Basic Query Function
```powershell
function Invoke-InfluxDBQuery {
    param(
        [string]$Query,
        [string]$Org = "renewable_energy_org",
        [string]$Token = "renewable_energy_admin_token_123"
    )
    
    $headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
        "Accept" = "application/csv"
    }
    
    $body = @{
        query = $Query
        type = "flux"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:8086/api/v2/query?org=$Org" -Method POST -Headers $headers -Body $body
    return $response.Content
}

# Usage example:
# $data = Invoke-InfluxDBQuery -Query 'from(bucket: "renewable_energy") |> range(start: -1h)'
```

### Write Data Function
```powershell
function Write-InfluxDBData {
    param(
        [string]$LineProtocol,
        [string]$Org = "renewable_energy_org",
        [string]$Bucket = "renewable_energy",
        [string]$Token = "renewable_energy_admin_token_123"
    )
    
    $headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "text/plain; charset=utf-8"
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:8086/api/v2/write?org=$Org&bucket=$Bucket" -Method POST -Headers $headers -Body $LineProtocol
    return $response.StatusCode
}

# Usage example:
# $status = Write-InfluxDBData -LineProtocol "test_measurement,device_id=test001 value=100"
```

## Common API Endpoints

### Query Endpoint
```
POST /api/v2/query?org={org}
Headers:
  Authorization: Token {token}
  Content-Type: application/json
  Accept: application/csv

Body:
{
  "query": "flux_query_here",
  "type": "flux"
}
```

### Write Endpoint
```
POST /api/v2/write?org={org}&bucket={bucket}
Headers:
  Authorization: Token {token}
  Content-Type: text/plain; charset=utf-8

Body:
measurement,tag1=value1,tag2=value2 field1=value1,field2=value2 timestamp
```

### Health Check Endpoint
```
GET /health
No authentication required
```

## Test Data Examples

### Sample Line Protocol Data
```
# Photovoltaic data
photovoltaic_data,device_id=pv_001,location=site_a power_output=1500,voltage=48.5,current=30.9

# Wind turbine data
wind_turbine_data,device_id=wt_001,location=site_b power_output=2500,wind_speed=12.5,rpm=1800

# Energy storage data
energy_storage_data,device_id=es_001,location=site_a soc=85.5,voltage=400,current=10.2
```

### Sample Flux Queries
```flux
# Get all data from last hour
from(bucket: "renewable_energy") |> range(start: -1h)

# Get photovoltaic data only
from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "photovoltaic_data")

# Get power output for specific device
from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_id == "pv_001") |> filter(fn: (r) => r._field == "power_output")

# Aggregate data by hour
from(bucket: "renewable_energy") |> range(start: -24h) |> filter(fn: (r) => r._field == "power_output") |> aggregateWindow(every: 1h, fn: mean)
```

## Troubleshooting

### Common Issues
1. **401 Unauthorized**: Check token validity
2. **400 Bad Request**: Check query syntax
3. **404 Not Found**: Check bucket and organization names
4. **Connection refused**: Check if InfluxDB is running

### Debug Commands
```powershell
# Check if InfluxDB is running
Invoke-WebRequest -Uri "http://localhost:8086/health" -UseBasicParsing

# Check token validity
$headers = @{"Authorization" = "Token renewable_energy_admin_token_123"}
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/buckets?org=renewable_energy_org" -Headers $headers
```

## Test Completion Checklist

- [ ] Test Case 1: Basic API Health Check
- [ ] Test Case 2: Query Data via HTTP API
- [ ] Test Case 3: Write Data via HTTP API
- [ ] Test Case 4: Query Written Data
- [ ] Test Case 5: Error Handling

## Notes
- Use PowerShell's `Invoke-WebRequest` for API calls
- CSV format is easier to parse than JSON for query results
- Line protocol is the standard format for writing data
- Always include proper headers for authentication and content type
