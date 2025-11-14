# Test Network Connectivity Between Services

Write-Host "`n🌐 Testing Network Connectivity Between Services`n" -ForegroundColor Cyan

$networkTests = @(
    @{ from = "API"; to = "InfluxDB"; container = "iot-api"; target = "influxdb" }
    @{ from = "Frontend"; to = "API"; container = "iot-frontend"; target = "api" }
    @{ from = "API"; to = "Mosquitto"; container = "iot-api"; target = "mosquitto" }
    @{ from = "Node-RED"; to = "InfluxDB"; container = "iot-node-red"; target = "influxdb" }
    @{ from = "Node-RED"; to = "Mosquitto"; container = "iot-node-red"; target = "mosquitto" }
)

Write-Host "Testing inter-service communication...`n" -ForegroundColor Yellow

$results = @()

foreach ($test in $networkTests) {
    Write-Host "Testing: $($test.from) → $($test.to)..." -ForegroundColor Cyan
    try {
        $pingResult = docker exec $test.container ping $test.target -c 3 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Connection successful" -ForegroundColor Green
            $results += @{ 
                From = $test.from
                To = $test.to
                Status = "Success"
            }
        } else {
            Write-Host "   ❌ Connection failed" -ForegroundColor Red
            $results += @{ 
                From = $test.from
                To = $test.to
                Status = "Failed"
            }
        }
    } catch {
        Write-Host "   ❌ Error: $_" -ForegroundColor Red
        $results += @{ 
            From = $test.from
            To = $test.to
            Status = "Error"
            Error = $_.Exception.Message
        }
    }
    Write-Host ""
}

Write-Host "📊 Network Connectivity Summary:" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray
foreach ($result in $results) {
    $statusColor = if ($result.Status -eq "Success") { "Green" } else { "Red" }
    Write-Host "$($result.From) → $($result.To): $($result.Status)" -ForegroundColor $statusColor
}
Write-Host ("=" * 60) -ForegroundColor Gray
Write-Host ""

# Test network configuration
Write-Host "🔍 Checking Docker network configuration..." -ForegroundColor Cyan
try {
    $networkInfo = docker network inspect plat-edu-bad-data-mvp_iot-network 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Network 'iot-network' exists" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Network 'iot-network' not found or different name" -ForegroundColor Yellow
        Write-Host "   Run: docker network ls" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Error checking network: $_" -ForegroundColor Red
}

Write-Host ""

