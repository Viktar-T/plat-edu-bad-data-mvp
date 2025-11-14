#!/usr/bin/env pwsh
# Backup script for API and Frontend configurations

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "backups/apps-$timestamp"

Write-Host "`n💾 Creating backup...`n" -ForegroundColor Cyan

# Create backup directory
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

# Backup API
Write-Host "Backing up API..." -ForegroundColor Yellow
if (Test-Path "api/src") {
    Copy-Item -Recurse "api/src" "$backupDir/api-src"
}
if (Test-Path "api/package.json") {
    Copy-Item "api/package.json" "$backupDir/api-package.json"
}
if (Test-Path "api/Dockerfile") {
    Copy-Item "api/Dockerfile" "$backupDir/api-Dockerfile"
}

# Backup Frontend
Write-Host "Backing up Frontend..." -ForegroundColor Yellow
if (Test-Path "frontend/src") {
    Copy-Item -Recurse "frontend/src" "$backupDir/frontend-src"
}
if (Test-Path "frontend/package.json") {
    Copy-Item "frontend/package.json" "$backupDir/frontend-package.json"
}
if (Test-Path "frontend/Dockerfile") {
    Copy-Item "frontend/Dockerfile" "$backupDir/frontend-Dockerfile"
}
if (Test-Path "frontend/nginx.conf") {
    Copy-Item "frontend/nginx.conf" "$backupDir/frontend-nginx.conf"
}

# Backup configurations
Write-Host "Backing up configurations..." -ForegroundColor Yellow
if (Test-Path ".env.production") {
    Copy-Item ".env.production" "$backupDir/.env.production"
}
if (Test-Path "docker-compose.yml") {
    Copy-Item "docker-compose.yml" "$backupDir/docker-compose.yml"
}
if (Test-Path "docker-compose.prod.yml") {
    Copy-Item "docker-compose.prod.yml" "$backupDir/docker-compose.prod.yml"
}

# Create archive
Write-Host "Creating archive..." -ForegroundColor Yellow
Compress-Archive -Path $backupDir -DestinationPath "$backupDir.zip"
Remove-Item -Recurse -Force $backupDir

Write-Host "`n✅ Backup created: $backupDir.zip`n" -ForegroundColor Green

