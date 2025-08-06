# Simple Grafana-InfluxDB Check
Write-Host "=== Basic Service Check ===" -ForegroundColor Cyan

# Check Docker
Write-Host "`n1. Checking Docker..." -ForegroundColor White
try {
    docker info | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running" -ForegroundColor Red
    exit 1
}

# Check containers
Write-Host "`n2. Checking containers..." -ForegroundColor White
$containers = @("iot-mosquitto", "iot-influxdb2", "iot-node-red", "iot-grafana")
foreach ($container in $containers) {
    $running = docker ps --format "{{.Names}}" | Select-String "^$container$"
    if ($running) {
        Write-Host "✓ $container is running" -ForegroundColor Green
    } else {
        Write-Host "✗ $container is not running" -ForegroundColor Red
    }
}

# Check InfluxDB
Write-Host "`n3. Checking InfluxDB..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8086/health" -Method GET -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ InfluxDB is healthy" -ForegroundColor Green
    } else {
        Write-Host "✗ InfluxDB returned status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ InfluxDB is not responding" -ForegroundColor Red
}

# Check Grafana
Write-Host "`n4. Checking Grafana..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Grafana is healthy" -ForegroundColor Green
    } else {
        Write-Host "✗ Grafana returned status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Grafana is not responding" -ForegroundColor Red
}

# Check Node-RED
Write-Host "`n5. Checking Node-RED..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:1880" -Method GET -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Node-RED is accessible" -ForegroundColor Green
    } else {
        Write-Host "✗ Node-RED returned status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Node-RED is not responding" -ForegroundColor Red
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "If you see errors above:" -ForegroundColor Yellow
Write-Host "1. Start services: docker-compose up -d" -ForegroundColor White
Write-Host "2. Check Grafana: http://localhost:3000" -ForegroundColor White
Write-Host "3. Check InfluxDB: http://localhost:8086" -ForegroundColor White
Write-Host "4. Check Node-RED: http://localhost:1880" -ForegroundColor White 