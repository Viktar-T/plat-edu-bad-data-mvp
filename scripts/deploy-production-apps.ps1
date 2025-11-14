#!/usr/bin/env pwsh
# Production Deployment Script for Frontend and API

param(
    [switch]$Build,
    [switch]$Deploy,
    [switch]$Restart,
    [switch]$Logs,
    [switch]$Status
)

$ErrorActionPreference = "Stop"

# Helper function to detect docker compose command
function Get-DockerComposeCmd {
    # Try docker compose (newer format) first
    try {
        $null = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return "docker compose"
        }
    } catch {
        # Continue to check docker-compose
    }
    
    # Try docker-compose (legacy format)
    try {
        $null = docker-compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return "docker-compose"
        }
    } catch {
        # Neither works
    }
    
    # Default to docker compose
    Write-Host "⚠️  Warning: Could not detect docker compose version, using 'docker compose' as default" -ForegroundColor Yellow
    return "docker compose"
}

$dockerComposeCmd = Get-DockerComposeCmd

Write-Host "`n🚀 Renewable Energy IoT - Production Deployment`n" -ForegroundColor Cyan
Write-Host "Using: $dockerComposeCmd`n" -ForegroundColor Gray

# Load production environment
$envFile = ".env.production"
if (Test-Path $envFile) {
    Write-Host "📋 Loading production environment from $envFile" -ForegroundColor Yellow
} else {
    Write-Host "❌ Production environment file not found: $envFile" -ForegroundColor Red
    exit 1
}

# Build services
if ($Build) {
    Write-Host "`n🔨 Building production images...`n" -ForegroundColor Cyan
    
    Write-Host "Building API..." -ForegroundColor Yellow
    Invoke-Expression "$dockerComposeCmd --env-file .env.production -f docker-compose.yml -f docker-compose.prod.yml build --no-cache api"
    
    Write-Host "`nBuilding Frontend..." -ForegroundColor Yellow
    Invoke-Expression "$dockerComposeCmd --env-file .env.production -f docker-compose.yml -f docker-compose.prod.yml build --no-cache frontend"
    
    Write-Host "`n✅ Build completed`n" -ForegroundColor Green
}

# Deploy services
if ($Deploy) {
    Write-Host "`n🚢 Deploying to production...`n" -ForegroundColor Cyan
    
    # Stop existing services
    Write-Host "Stopping existing services..." -ForegroundColor Yellow
    Invoke-Expression "$dockerComposeCmd --env-file .env.production stop api frontend"
    
    # Remove old containers
    Write-Host "Removing old containers..." -ForegroundColor Yellow
    Invoke-Expression "$dockerComposeCmd --env-file .env.production rm -f api frontend"
    
    # Start new services
    Write-Host "Starting new services..." -ForegroundColor Yellow
    Invoke-Expression "$dockerComposeCmd --env-file .env.production -f docker-compose.yml -f docker-compose.prod.yml up -d api frontend"
    
    Write-Host "`n✅ Deployment completed`n" -ForegroundColor Green
    
    # Show status
    Write-Host "Service Status:" -ForegroundColor Cyan
    Invoke-Expression "$dockerComposeCmd --env-file .env.production ps api frontend"
}

# Restart services
if ($Restart) {
    Write-Host "`n🔄 Restarting services...`n" -ForegroundColor Cyan
    
    Invoke-Expression "$dockerComposeCmd --env-file .env.production restart api frontend"
    
    Write-Host "`n✅ Services restarted`n" -ForegroundColor Green
}

# Show logs
if ($Logs) {
    Write-Host "`n📋 Showing logs (Ctrl+C to exit)...`n" -ForegroundColor Cyan
    
    Invoke-Expression "$dockerComposeCmd --env-file .env.production logs -f --tail=100 api frontend"
}

# Show status
if ($Status) {
    Write-Host "`n📊 Service Status`n" -ForegroundColor Cyan
    
    Invoke-Expression "$dockerComposeCmd --env-file .env.production ps"
    
    Write-Host "`n🔍 Health Checks`n" -ForegroundColor Cyan
    
    $apiPort = (Get-Content .env.production | Select-String "API_PORT=").ToString().Split("=")[1]
    $frontendPort = (Get-Content .env.production | Select-String "FRONTEND_PORT=").ToString().Split("=")[1]
    
    Write-Host "API Health:" -ForegroundColor Yellow
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$apiPort/health" -TimeoutSec 5
        Write-Host "   ✅ $($health | ConvertTo-Json)" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Not responding" -ForegroundColor Red
    }
    
    Write-Host "`nFrontend Health:" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$frontendPort/health" -TimeoutSec 5
        Write-Host "   ✅ Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Not responding" -ForegroundColor Red
    }
}

# Show help if no parameters
if (-not ($Build -or $Deploy -or $Restart -or $Logs -or $Status)) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\deploy-production-apps.ps1 -Build     # Build production images" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Deploy    # Deploy to production" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Restart   # Restart services" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Logs      # Show logs" -ForegroundColor Gray
    Write-Host "  .\deploy-production-apps.ps1 -Status    # Show status" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "✨ Done!`n" -ForegroundColor Cyan

