# Development Proxy Server for InfluxDB Web Interface
# Solves CORS issues during development

Write-Host "🚀 Starting InfluxDB Development Proxy Server..." -ForegroundColor Green

# Change to scripts directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    Write-Host "   Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if npm dependencies are installed
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing npm dependencies..." -ForegroundColor Yellow
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
}

# Check if InfluxDB is running
Write-Host "🔍 Checking InfluxDB connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8086/health" -Method GET -TimeoutSec 5
    Write-Host "✅ InfluxDB is running and accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ InfluxDB is not accessible on localhost:8086" -ForegroundColor Red
    Write-Host "   Please ensure InfluxDB container is running:" -ForegroundColor Yellow
    Write-Host "   docker-compose up -d influxdb" -ForegroundColor Cyan
    exit 1
}

# Start the proxy server
Write-Host ""
Write-Host "🌐 Starting development proxy server..." -ForegroundColor Green
Write-Host "   Web Interface: http://localhost:5000" -ForegroundColor Cyan
Write-Host "   Proxy Target: http://localhost:8086" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Run the development proxy
try {
    node dev-proxy.js
} catch {
    Write-Host "❌ Failed to start proxy server" -ForegroundColor Red
    exit 1
} 