# Test All Services Health Checks

Write-Host "`n🏥 Testing All Services Health Checks`n" -ForegroundColor Cyan

$services = @(
    @{ name = "Mosquitto (MQTT)"; test = { docker exec iot-mosquitto mosquitto_pub -h localhost -t test/health -m "ping" 2>&1 } }
    @{ name = "InfluxDB"; test = { Invoke-RestMethod -Uri "http://localhost:40101/health" -Method Get -ErrorAction Stop } }
    @{ name = "Node-RED"; test = { Invoke-WebRequest -Uri "http://localhost:40100" -Method Get -ErrorAction Stop } }
    @{ name = "Grafana"; test = { Invoke-RestMethod -Uri "http://localhost:40099/api/health" -Method Get -ErrorAction Stop } }
    @{ name = "API"; test = { Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -ErrorAction Stop } }
    @{ name = "Frontend"; test = { Invoke-WebRequest -Uri "http://localhost:5173/health" -Method Get -ErrorAction Stop } }
)

$results = @()

foreach ($service in $services) {
    Write-Host "Testing: $($service.name)..." -ForegroundColor Yellow
    try {
        $result = & $service.test
        Write-Host "   ✅ $($service.name) is healthy" -ForegroundColor Green
        $results += @{ Service = $service.name; Status = "Healthy" }
    } catch {
        Write-Host "   ❌ $($service.name) failed: $_" -ForegroundColor Red
        $results += @{ Service = $service.name; Status = "Failed"; Error = $_.Exception.Message }
    }
    Write-Host ""
}

Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray
foreach ($result in $results) {
    $statusColor = if ($result.Status -eq "Healthy") { "Green" } else { "Red" }
    Write-Host "$($result.Service): $($result.Status)" -ForegroundColor $statusColor
}
Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host ""

$healthyCount = ($results | Where-Object { $_.Status -eq "Healthy" }).Count
$totalCount = $results.Count

if ($healthyCount -eq $totalCount) {
    Write-Host "✨ All services are healthy! ($healthyCount/$totalCount)`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services are not healthy ($healthyCount/$totalCount)`n" -ForegroundColor Yellow
}

