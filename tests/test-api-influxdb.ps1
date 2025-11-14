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

