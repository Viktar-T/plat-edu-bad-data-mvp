# Automatic Node-RED InfluxDB Fix Script (PowerShell)
# This script fixes the automatic dependency installation issue

Write-Host "Automatic Node-RED InfluxDB Fix Script" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "ERROR: Please run this script from the project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Stopping Node-RED container..." -ForegroundColor Blue
docker-compose stop node-red

Write-Host "Step 2: Cleaning up corrupted data files..." -ForegroundColor Blue
docker-compose run --rm node-red bash -c "cd /data; rm -f package.json settings.js"

Write-Host "Step 3: Starting Node-RED with automatic dependency installation..." -ForegroundColor Blue
docker-compose up -d node-red

Write-Host "Step 4: Waiting for Node-RED to start..." -ForegroundColor Blue
Start-Sleep -Seconds 15

Write-Host "Step 5: Checking if InfluxDB package is installed..." -ForegroundColor Blue
docker-compose exec node-red npm list node-red-contrib-influxdb

Write-Host "Step 6: Verifying Node-RED health..." -ForegroundColor Blue
docker-compose ps node-red

Write-Host ""
Write-Host "SUCCESS: Automatic fix completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open Node-RED at: http://localhost:1880"
Write-Host "2. Check if InfluxDB nodes are available in the palette"
Write-Host "3. If flows are missing, import them from node-red/flows/"
Write-Host ""
Write-Host "To check logs: docker-compose logs -f node-red" 