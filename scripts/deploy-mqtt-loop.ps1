# Deploy MQTT Loop Flow to Node-RED
# This script deploys the complete MQTT loop pattern for renewable energy monitoring

param(
    [string]$NodeRedUrl = "http://localhost:1880",
    [string]$FlowFile = "node-red/flows/mqtt-loop-simulation.json"
)

Write-Host "🚀 Deploying MQTT Loop Flow to Node-RED" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if Node-RED is running
Write-Host "Checking Node-RED status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$NodeRedUrl" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Node-RED is running" -ForegroundColor Green
    } else {
        Write-Host "❌ Node-RED returned status: $($response.StatusCode)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Cannot connect to Node-RED at $NodeRedUrl" -ForegroundColor Red
    Write-Host "Make sure Node-RED is running and accessible" -ForegroundColor Yellow
    exit 1
}

# Check if flow file exists
if (-not (Test-Path $FlowFile)) {
    Write-Host "❌ Flow file not found: $FlowFile" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flow file found: $FlowFile" -ForegroundColor Green

# Read the flow file
Write-Host "Reading flow configuration..." -ForegroundColor Yellow
try {
    $flowContent = Get-Content $FlowFile -Raw | ConvertFrom-Json
    Write-Host "✅ Flow configuration loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error reading flow file: $_" -ForegroundColor Red
    exit 1
}

# Deploy the flow to Node-RED
Write-Host "Deploying flow to Node-RED..." -ForegroundColor Yellow
try {
    $deployBody = @{
        flows = $flowContent
    } | ConvertTo-Json -Depth 10

    $headers = @{
        "Content-Type" = "application/json"
    }

    $response = Invoke-WebRequest -Uri "$NodeRedUrl/flows" -Method POST -Body $deployBody -Headers $headers -UseBasicParsing

    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Flow deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Deployment failed with status: $($response.StatusCode)" -ForegroundColor Red
        Write-Host "Response: $($response.Content)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error deploying flow: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 MQTT Loop Flow Deployment Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open Node-RED at: $NodeRedUrl" -ForegroundColor White
Write-Host "2. Verify the 'Photovoltaic Simulation' flow is active" -ForegroundColor White
Write-Host "3. Check that MQTT Input and Output nodes are connected" -ForegroundColor White
Write-Host "4. Monitor the debug output for data flow" -ForegroundColor White
Write-Host "5. Test with MQTT client: .\test-mqtt.ps1 -Subscribe -Topic 'devices/photovoltaic/+/telemetry'" -ForegroundColor White

Write-Host "`n🔍 Troubleshooting:" -ForegroundColor Cyan
Write-Host "- Check Node-RED logs for errors" -ForegroundColor White
Write-Host "- Verify MQTT broker connection" -ForegroundColor White
Write-Host "- Ensure InfluxDB is accessible" -ForegroundColor White
Write-Host "- Monitor debug nodes for data flow" -ForegroundColor White 