#!/usr/bin/env pwsh
# Monitoring script for API and Frontend

Write-Host "`n📊 System Monitoring Dashboard`n" -ForegroundColor Cyan

# Read ports from .env.production if it exists
$apiPort = 40102
$frontendPort = 40103

if (Test-Path ".env.production") {
    $envContent = Get-Content ".env.production"
    $apiPortLine = $envContent | Select-String "API_PORT="
    $frontendPortLine = $envContent | Select-String "FRONTEND_PORT="
    
    if ($apiPortLine) {
        $apiPort = $apiPortLine.ToString().Split("=")[1].Trim()
    }
    if ($frontendPortLine) {
        $frontendPort = $frontendPortLine.ToString().Split("=")[1].Trim()
    }
}

while ($true) {
    Clear-Host
    Write-Host "🔄 Renewable Energy IoT - Live Monitoring" -ForegroundColor Cyan
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "Press Ctrl+C to exit`n" -ForegroundColor Yellow
    
    # API Health
    Write-Host "API Service:" -ForegroundColor Yellow
    try {
        $apiHealth = Invoke-RestMethod -Uri "http://localhost:$apiPort/health" -TimeoutSec 3
        Write-Host "   Status: ✅ Healthy" -ForegroundColor Green
        Write-Host "   Response: $($apiHealth | ConvertTo-Json)" -ForegroundColor Gray
    } catch {
        Write-Host "   Status: ❌ Unhealthy" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Red
    }
    
    # Frontend Health
    Write-Host "`nFrontend Service:" -ForegroundColor Yellow
    try {
        $frontendHealth = Invoke-WebRequest -Uri "http://localhost:$frontendPort/health" -TimeoutSec 3
        Write-Host "   Status: ✅ Healthy (HTTP $($frontendHealth.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "   Status: ❌ Unhealthy" -ForegroundColor Red
    }
    
    # Container Stats
    Write-Host "`nContainer Status:" -ForegroundColor Yellow
    $containers = docker ps --filter "name=iot-api" --filter "name=iot-frontend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>$null
    if ($containers) {
        Write-Host $containers -ForegroundColor Gray
    } else {
        Write-Host "   No containers found" -ForegroundColor Yellow
    }
    
    # Resource Usage
    Write-Host "`nResource Usage:" -ForegroundColor Yellow
    $stats = docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" iot-api iot-frontend 2>$null
    if ($stats) {
        Write-Host $stats -ForegroundColor Gray
    } else {
        Write-Host "   No stats available" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 5
}

