# Quick Grafana-InfluxDB Diagnostic Script
# Renewable Energy IoT Monitoring System

Write-Host "=== Grafana-InfluxDB Connection Diagnostic ===" -ForegroundColor Cyan

# Function to print status
function Write-Status {
    param([string]$Status, [string]$Message)
    switch ($Status) {
        "SUCCESS" { Write-Host "✓ $Message" -ForegroundColor Green }
        "ERROR" { Write-Host "✗ $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "! $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host "i $Message" -ForegroundColor Blue }
    }
}

# 1. Check Docker
Write-Host "`n1. Checking Docker..." -ForegroundColor White
try {
    $dockerInfo = docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "Docker is running"
    } else {
        Write-Status "ERROR" "Docker is not running"
        exit 1
    }
} catch {
    Write-Status "ERROR" "Docker is not available"
    exit 1
}

# 2. Check containers
Write-Host "`n2. Checking containers..." -ForegroundColor White
$containers = @("iot-mosquitto", "iot-influxdb2", "iot-node-red", "iot-grafana")
foreach ($container in $containers) {
    $running = docker ps --format "table {{.Names}}" 2>$null | Select-String "^$container$"
    if ($running) {
        Write-Status "SUCCESS" "Container $container is running"
    } else {
        Write-Status "ERROR" "Container $container is not running"
    }
}

# 3. Check InfluxDB health
Write-Host "`n3. Checking InfluxDB..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8086/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "InfluxDB is healthy"
    } else {
        Write-Status "ERROR" "InfluxDB returned status: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "InfluxDB is not responding: $($_.Exception.Message)"
}

# 4. Check Grafana health
Write-Host "`n4. Checking Grafana..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "Grafana is healthy"
    } else {
        Write-Status "ERROR" "Grafana returned status: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "Grafana is not responding: $($_.Exception.Message)"
}

# 5. Check Node-RED
Write-Host "`n5. Checking Node-RED..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:1880" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "Node-RED is accessible"
    } else {
        Write-Status "ERROR" "Node-RED returned status: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "Node-RED is not responding: $($_.Exception.Message)"
}

# 6. Check InfluxDB data
Write-Host "`n6. Checking InfluxDB data..." -ForegroundColor White
try {
    $query = "from(bucket:`"renewable_energy`")|>range(start:-1h)|>count()"
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($query)
    $url = "http://localhost:8086/query?org=renewable_energy_org&q=$encodedQuery"
    
    $headers = @{
        "Authorization" = "Token renewable_energy_admin_token_123"
    }
    
    $response = Invoke-WebRequest -Uri $url -Headers $headers -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.Content -match "result") {
        Write-Status "SUCCESS" "Data exists in InfluxDB"
    } else {
        Write-Status "WARNING" "No data found in InfluxDB"
        Write-Host "   Tip: Check Node-RED flows at http://localhost:1880" -ForegroundColor Gray
    }
} catch {
    Write-Status "WARNING" "Could not check InfluxDB data: $($_.Exception.Message)"
}

# 7. Check Grafana data source
Write-Host "`n7. Checking Grafana data source..." -ForegroundColor White
try {
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    $headers = @{
        "Authorization" = "Basic $auth"
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method GET -TimeoutSec 10 -ErrorAction Stop
    $datasources = $response.Content | ConvertFrom-Json
    
    $influxDS = $datasources | Where-Object { $_.type -eq "influxdb" }
    if ($influxDS) {
        Write-Status "SUCCESS" "InfluxDB data source found: $($influxDS.name)"
        Write-Host "   URL: $($influxDS.url)" -ForegroundColor Gray
        Write-Host "   Organization: $($influxDS.jsonData.organization)" -ForegroundColor Gray
        Write-Host "   Bucket: $($influxDS.jsonData.defaultBucket)" -ForegroundColor Gray
    } else {
        Write-Status "ERROR" "InfluxDB data source not found"
    }
} catch {
    Write-Status "ERROR" "Could not check Grafana data source: $($_.Exception.Message)"
}

Write-Host "`n=== Diagnostic Summary ===" -ForegroundColor Cyan
Write-Host "If you see errors above, try these steps:" -ForegroundColor Yellow
Write-Host "1. Start services: docker-compose up -d" -ForegroundColor White
Write-Host "2. Check Node-RED flows: http://localhost:1880" -ForegroundColor White
Write-Host "3. Check Grafana data source: http://localhost:3000" -ForegroundColor White
Write-Host "4. Check InfluxDB: http://localhost:8086" -ForegroundColor White
Write-Host "`nFor detailed troubleshooting, see: docs/grafana-influxdb-troubleshooting.md" -ForegroundColor Blue 