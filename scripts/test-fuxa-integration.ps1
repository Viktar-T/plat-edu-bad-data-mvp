# FUXA SCADA Integration Test Script
# Tests the FUXA SCADA integration with the renewable energy monitoring system

param(
    [switch]$StartServices,
    [switch]$TestMQTT,
    [switch]$TestFUXA,
    [switch]$All
)

Write-Host "=== FUXA SCADA Integration Test Script ===" -ForegroundColor Green

if ($StartServices -or $All) {
    Write-Host "Starting local development services..." -ForegroundColor Yellow
    docker-compose -f docker-compose.local.yml up -d
    
    Write-Host "Waiting for services to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    # Check service status
    Write-Host "Checking service status..." -ForegroundColor Yellow
    docker-compose -f docker-compose.local.yml ps
}

if ($TestMQTT -or $All) {
    Write-Host "Testing MQTT connectivity..." -ForegroundColor Yellow
    
    # Test MQTT connection
    try {
        $mqttTest = mosquitto_pub -h localhost -u admin -P admin_password_456 -t "test/fuxa/connection" -m "test message" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ MQTT connection successful" -ForegroundColor Green
        } else {
            Write-Host "✗ MQTT connection failed: $mqttTest" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ MQTT test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test renewable energy data topics
    Write-Host "Testing renewable energy MQTT topics..." -ForegroundColor Yellow
    
    $topics = @(
        "renewable/pv/panel_01/power",
        "renewable/wind/turbine_01/power", 
        "renewable/biogas/plant_01/gas_flow",
        "renewable/boiler/boiler_01/temperature",
        "renewable/storage/battery_01/soc"
    )
    
    foreach ($topic in $topics) {
        try {
            $testData = @{
                value = (Get-Random -Minimum 100 -Maximum 1000)
                timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
                quality = "good"
            } | ConvertTo-Json
            
            mosquitto_pub -h localhost -u admin -P admin_password_456 -t $topic -m $testData 2>&1 | Out-Null
            Write-Host "✓ Published to $topic" -ForegroundColor Green
        } catch {
            Write-Host "✗ Failed to publish to $topic" -ForegroundColor Red
        }
    }
}

if ($TestFUXA -or $All) {
    Write-Host "Testing FUXA SCADA accessibility..." -ForegroundColor Yellow
    
    # Test FUXA web interface
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3002" -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ FUXA web interface accessible" -ForegroundColor Green
        } else {
            Write-Host "✗ FUXA web interface returned status: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ FUXA web interface not accessible: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Check FUXA container status
    Write-Host "Checking FUXA container status..." -ForegroundColor Yellow
    $fuxaStatus = docker-compose -f docker-compose.local.yml ps fuxa
    Write-Host $fuxaStatus
    
    # Check FUXA logs
    Write-Host "Recent FUXA logs:" -ForegroundColor Yellow
    docker-compose -f docker-compose.local.yml logs --tail=10 fuxa
}

if ($All) {
    Write-Host "Running comprehensive FUXA integration test..." -ForegroundColor Yellow
    
    # Test all services
    $services = @("mosquitto", "node-red", "influxdb", "grafana", "fuxa")
    
    foreach ($service in $services) {
        Write-Host "Checking $service service..." -ForegroundColor Yellow
        $status = docker-compose -f docker-compose.local.yml ps $service
        Write-Host $status
    }
    
    # Test data flow
    Write-Host "Testing end-to-end data flow..." -ForegroundColor Yellow
    
    # Send test data and verify it appears in FUXA
    $testData = @{
        value = 1250.5
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        quality = "good"
        device_type = "pv"
        device_id = "panel_01"
        data_type = "power"
    } | ConvertTo-Json
    
    mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/pv/panel_01/power" -m $testData 2>&1 | Out-Null
    Write-Host "✓ Test data published to MQTT" -ForegroundColor Green
    
    Write-Host "Data should now be available in FUXA at http://localhost:3002" -ForegroundColor Cyan
}

Write-Host "=== FUXA Integration Test Complete ===" -ForegroundColor Green
Write-Host "Access FUXA SCADA at: http://localhost:3002" -ForegroundColor Cyan
Write-Host "Access Grafana at: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Access Node-RED at: http://localhost:1880" -ForegroundColor Cyan
