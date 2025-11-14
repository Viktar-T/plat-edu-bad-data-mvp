# Step 6: End-to-End Testing

## Context
Now that both frontend and api services are integrated into the Docker monorepo, you need to verify that the entire data flow works correctly:
- MQTT → Node-RED → InfluxDB → API → Frontend

## Testing Objectives
1. Verify all services are running and healthy
2. Test API connectivity to InfluxDB
3. Test frontend connectivity to API
4. Verify data flow from InfluxDB to frontend
5. Test all device types (photovoltaic, wind turbine, biogas, heat boiler, storage)
6. Validate real-time data updates

## Prerequisites
Ensure all services are running:
```powershell
docker-compose up -d
```

## Test Suite

### Test 1: Service Health Checks

**1.1 Check all service status:**
```powershell
docker-compose ps
```

Expected output: All services should be "Up" and "healthy"

**1.2 Verify individual health checks:**
```powershell
# Mosquitto
docker exec iot-mosquitto mosquitto_pub -h localhost -t test/health -m "ping"

# InfluxDB
curl http://localhost:40101/health

# Node-RED
curl http://localhost:40100

# Grafana
curl http://localhost:40099/api/health

# API
curl http://localhost:3001/health

# Frontend
curl http://localhost:5173/health
```

**1.3 Check service logs for errors:**
```powershell
docker-compose logs --tail=50 api
docker-compose logs --tail=50 frontend
```

### Test 2: API to InfluxDB Connection

**2.1 Test API connection to InfluxDB:**
```powershell
# Check API logs for successful InfluxDB connection
docker-compose logs api | Select-String "Ping"
docker-compose logs api | Select-String "Access confirmed"
```

Expected: "Ping ✔️ SUCCESS ✔️" and "✅ Access confirmed!"

**2.2 Test API query endpoint:**

Create a PowerShell script `tests/test-api-influxdb.ps1`:
```powershell
# Test API to InfluxDB connection

Write-Host "`n🧪 Testing API to InfluxDB Connection`n" -ForegroundColor Cyan

# Test 1: Health Check
Write-Host "1️⃣ API Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get
    Write-Host "   ✅ Health: $($health.health)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed: $_" -ForegroundColor Red
}

# Test 2: Photovoltaic Data
Write-Host "`n2️⃣ Fetching Photovoltaic Data..." -ForegroundColor Yellow
try {
    $pvData = Invoke-RestMethod -Uri "http://localhost:3001/api/summary/charger?start=5m" -Method Get
    Write-Host "   ✅ Data received: $($pvData.PSObject.Properties.Count) fields" -ForegroundColor Green
    Write-Host "   📊 Sample data:" -ForegroundColor Cyan
    $pvData | ConvertTo-Json -Depth 2 | Write-Host
} catch {
    Write-Host "   ❌ Failed: $_" -ForegroundColor Red
}

# Test 3: Wind Turbine Data
Write-Host "`n3️⃣ Fetching Wind Turbine Data..." -ForegroundColor Yellow
try {
    $windData = Invoke-RestMethod -Uri "http://localhost:3001/api/summary/big_turbine?start=5m" -Method Get
    Write-Host "   ✅ Data received: $($windData.PSObject.Properties.Count) fields" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed: $_" -ForegroundColor Red
}

# Test 4: Energy Storage Data
Write-Host "`n4️⃣ Fetching Energy Storage Data..." -ForegroundColor Yellow
try {
    $storageData = Invoke-RestMethod -Uri "http://localhost:3001/api/summary/storage?start=5m" -Method Get
    Write-Host "   ✅ Data received: $($storageData.PSObject.Properties.Count) fields" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed: $_" -ForegroundColor Red
}

# Test 5: Custom Query
Write-Host "`n5️⃣ Testing Custom Query..." -ForegroundColor Yellow
try {
    $query = @{
        fluxQuery = @"
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r["_measurement"] == "photovoltaic_data")
  |> last()
"@
    } | ConvertTo-Json

    $queryResult = Invoke-RestMethod -Uri "http://localhost:3001/api/query" `
        -Method Post `
        -ContentType "application/json" `
        -Body $query
    
    Write-Host "   ✅ Query executed successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed: $_" -ForegroundColor Red
}

Write-Host "`n✨ API to InfluxDB tests completed!`n" -ForegroundColor Cyan
```

Run the test:
```powershell
.\tests\test-api-influxdb.ps1
```

### Test 3: Frontend to API Connection

**3.1 Test frontend health:**
```powershell
curl http://localhost:5173/health
```

**3.2 Test frontend in browser:**

Open http://localhost:5173 in your browser

Open Developer Console (F12) and run:
```javascript
// Test 1: Health Check
fetch('http://localhost:3001/health')
  .then(r => r.json())
  .then(data => console.log('✅ Health:', data))
  .catch(err => console.error('❌ Health check failed:', err));

// Test 2: Fetch Photovoltaic Data
fetch('http://localhost:3001/api/summary/charger?start=2m')
  .then(r => r.json())
  .then(data => console.log('✅ Photovoltaic Data:', data))
  .catch(err => console.error('❌ Failed:', err));

// Test 3: Fetch Wind Turbine Data
fetch('http://localhost:3001/api/summary/big_turbine?start=2m')
  .then(r => r.json())
  .then(data => console.log('✅ Wind Turbine Data:', data))
  .catch(err => console.error('❌ Failed:', err));

// Test 4: Test CORS
fetch('http://localhost:3001/health', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
  },
  mode: 'cors'
})
  .then(r => {
    console.log('✅ CORS Headers:', r.headers.get('access-control-allow-origin'));
    return r.json();
  })
  .then(data => console.log('✅ Data:', data))
  .catch(err => console.error('❌ CORS Error:', err));
```

**3.3 Check browser network tab:**
- All requests should return 200 status
- Check for CORS headers in response
- Verify data is being received

### Test 4: Complete Data Flow Test

Create `tests/test-complete-flow.ps1`:
```powershell
# Complete End-to-End Data Flow Test

Write-Host "`n🚀 Complete Data Flow Test: MQTT → Node-RED → InfluxDB → API → Frontend`n" -ForegroundColor Cyan

# Device types mapping
$devices = @{
    "photovoltaic" = @{
        name = "Photovoltaic Panel"
        api_name = "charger"
        measurement = "photovoltaic_data"
    }
    "wind_turbine" = @{
        name = "Wind Turbine"
        api_name = "big_turbine"
        measurement = "wind_turbine_data"
    }
    "biogas" = @{
        name = "Biogas Plant"
        api_name = "biogas"
        measurement = "biogas_plant_data"
    }
    "heat_boiler" = @{
        name = "Heat Boiler"
        api_name = "heat_boiler"
        measurement = "heat_boiler_data"
    }
    "storage" = @{
        name = "Energy Storage"
        api_name = "storage"
        measurement = "energy_storage_data"
    }
}

Write-Host "Testing all device types...`n" -ForegroundColor Yellow

foreach ($deviceKey in $devices.Keys) {
    $device = $devices[$deviceKey]
    Write-Host "📊 Testing: $($device.name)" -ForegroundColor Cyan
    
    try {
        # Fetch data from API
        $uri = "http://localhost:3001/api/summary/$($device.api_name)?start=2m"
        $data = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 10
        
        if ($data -and $data.PSObject.Properties.Count -gt 0) {
            Write-Host "   ✅ Data received successfully" -ForegroundColor Green
            Write-Host "   📈 Fields count: $($data.PSObject.Properties.Count)" -ForegroundColor Gray
            
            # Display sample field
            $firstField = $data.PSObject.Properties | Select-Object -First 1
            if ($firstField) {
                Write-Host "   📝 Sample field: $($firstField.Name) = $($firstField.Value._value)" -ForegroundColor Gray
                Write-Host "   🕐 Timestamp: $($firstField.Value._time)" -ForegroundColor Gray
            }
        } else {
            Write-Host "   ⚠️  No data available" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "✨ Complete flow test finished!`n" -ForegroundColor Cyan

# Summary
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "   • All device types tested" -ForegroundColor Gray
Write-Host "   • Data flow: MQTT → Node-RED → InfluxDB → API → Frontend" -ForegroundColor Gray
Write-Host "   • Check above for any ❌ failures" -ForegroundColor Gray
Write-Host ""
```

Run the test:
```powershell
.\tests\test-complete-flow.ps1
```

### Test 5: Real-Time Data Updates

**5.1 Monitor data in real-time:**

Create `tests/test-realtime-updates.ps1`:
```powershell
# Monitor real-time data updates

Write-Host "`n⏱️  Monitoring Real-Time Data Updates`n" -ForegroundColor Cyan
Write-Host "Fetching photovoltaic data every 5 seconds for 30 seconds...`n" -ForegroundColor Yellow

$iterations = 6
$delay = 5

for ($i = 1; $i -le $iterations; $i++) {
    Write-Host "[$i/$iterations] $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    
    try {
        $data = Invoke-RestMethod -Uri "http://localhost:3001/api/summary/charger?start=1m" -Method Get
        
        if ($data.power_output) {
            $power = [math]::Round($data.power_output._value, 2)
            $timestamp = $data.power_output._time
            Write-Host "   Power Output: $power W" -ForegroundColor Green
            Write-Host "   Timestamp: $timestamp" -ForegroundColor Gray
        } else {
            Write-Host "   ⚠️  No power_output data" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Error: $_" -ForegroundColor Red
    }
    
    if ($i -lt $iterations) {
        Start-Sleep -Seconds $delay
    }
}

Write-Host "`n✅ Real-time monitoring completed`n" -ForegroundColor Green
```

Run the test:
```powershell
.\tests\test-realtime-updates.ps1
```

### Test 6: Network Connectivity

**6.1 Test inter-service communication:**
```powershell
# API to InfluxDB
docker exec iot-api ping influxdb -c 3

# Frontend to API
docker exec iot-frontend ping api -c 3

# API to Mosquitto
docker exec iot-api ping mosquitto -c 3

# Node-RED to InfluxDB
docker exec iot-node-red ping influxdb -c 3
```

**6.2 Verify network configuration:**
```powershell
docker network inspect plat-edu-bad-data-mvp_iot-network
```

### Test 7: Performance Testing

**7.1 Test API response times:**

Create `tests/test-performance.ps1`:
```powershell
# API Performance Test

Write-Host "`n⚡ API Performance Test`n" -ForegroundColor Cyan

$endpoints = @(
    @{ name = "Health Check"; uri = "http://localhost:3001/health" }
    @{ name = "Photovoltaic"; uri = "http://localhost:3001/api/summary/charger?start=2m" }
    @{ name = "Wind Turbine"; uri = "http://localhost:3001/api/summary/big_turbine?start=2m" }
    @{ name = "Energy Storage"; uri = "http://localhost:3001/api/summary/storage?start=2m" }
)

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $($endpoint.name)" -ForegroundColor Yellow
    
    $times = @()
    $iterations = 5
    
    for ($i = 1; $i -le $iterations; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $null = Invoke-RestMethod -Uri $endpoint.uri -Method Get -TimeoutSec 10
            $sw.Stop()
            $times += $sw.ElapsedMilliseconds
        } catch {
            Write-Host "   ❌ Failed: $_" -ForegroundColor Red
            $sw.Stop()
        }
    }
    
    if ($times.Count -gt 0) {
        $avgTime = ($times | Measure-Object -Average).Average
        $minTime = ($times | Measure-Object -Minimum).Minimum
        $maxTime = ($times | Measure-Object -Maximum).Maximum
        
        Write-Host "   Average: $([math]::Round($avgTime, 2))ms" -ForegroundColor Green
        Write-Host "   Min: $([math]::Round($minTime, 2))ms | Max: $([math]::Round($maxTime, 2))ms" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "✅ Performance test completed`n" -ForegroundColor Cyan
```

Run the test:
```powershell
.\tests\test-performance.ps1
```

## Expected Results

### Healthy System Indicators:
- ✅ All services show "healthy" status in `docker-compose ps`
- ✅ API connects to InfluxDB without errors
- ✅ Frontend can fetch data from API
- ✅ Data is recent (within last few minutes)
- ✅ All device types return data
- ✅ No CORS errors in browser console
- ✅ Response times < 500ms for most queries
- ✅ Real-time data updates every 30-60 seconds

## Troubleshooting

### No Data Available
```powershell
# Check if Node-RED is sending data
docker-compose logs node-red | Select-String "success"

# Check InfluxDB for recent data
curl -X POST "http://localhost:40101/api/v2/query?org=renewable_energy_org" `
  -H "Authorization: Token renewable_energy_admin_token_123" `
  -H "Content-Type: application/vnd.flux" `
  -d 'from(bucket: "renewable_energy") |> range(start: -5m) |> limit(n: 10)'
```

### API Errors
```powershell
# Check API logs
docker-compose logs --tail=100 api

# Restart API
docker-compose restart api

# Check API environment
docker exec iot-api env | Select-String "INFLUX"
```

### Frontend Issues
```powershell
# Rebuild frontend with correct env vars
docker-compose build frontend
docker-compose up -d frontend

# Check frontend logs
docker-compose logs frontend

# Clear browser cache and reload
```

## Next Steps
- Proceed to Step 7: Documentation and Deployment Guide
- Create production deployment configuration
- Set up monitoring and logging

## Notes
- Run these tests after any configuration changes
- Monitor logs during testing for detailed error information
- Performance may vary based on system resources
- Ensure all simulations are running (Node-RED flows)
- Test regularly to catch integration issues early

