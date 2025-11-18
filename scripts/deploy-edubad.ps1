#!/usr/bin/env pwsh
# =============================================================================
# Deployment Script for edubad.zut.edu.pl
# Renewable Energy IoT Monitoring System
# =============================================================================

param(
    [switch]$Prepare,
    [switch]$Transfer,
    [switch]$Deploy,
    [switch]$Full,
    [switch]$Status,
    [switch]$Logs,
    [string]$VpsHost = "edubad.zut.edu.pl",
    [string]$VpsUser = "admin"
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Header($message) {
    Write-Host "`n================================================" -ForegroundColor Cyan
    Write-Host $message -ForegroundColor Cyan
    Write-Host "================================================`n" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

function Write-Info($message) {
    Write-Host "ℹ️  $message" -ForegroundColor Blue
}

# =============================================================================
# STEP 1: Prepare for Deployment
# =============================================================================

function Test-RequiredFiles {
    Write-Header "Checking Required Files"
    
    $required = @(
        "docker-compose.yml",
        ".env.production",
        "mosquitto/",
        "influxdb/",
        "node-red/",
        "grafana/",
        "api/",
        "frontend/"
    )
    
    $missing = @()
    foreach ($item in $required) {
        if (Test-Path $item) {
            Write-Success "Found: $item"
        } else {
            Write-Error "Missing: $item"
            $missing += $item
        }
    }
    
    return $missing
}

function Test-EnvConfiguration {
    Write-Header "Validating Environment Configuration"
    
    if (-not (Test-Path ".env.production")) {
        Write-Error ".env.production not found"
        Write-Info "Creating from template..."
        
        if (Test-Path ".env.edubad.template") {
            Copy-Item ".env.edubad.template" ".env.production"
            Write-Warning "Created .env.production from template"
            Write-Warning "IMPORTANT: Update placeholders before deployment!"
            return $false
        } else {
            Write-Error "Template not found: .env.edubad.template"
            return $false
        }
    }
    
    # Check for placeholders in .env.production
    $envContent = Get-Content ".env.production" -Raw
    $placeholders = @()
    
    if ($envContent -match '\[CHANGE_ME') {
        $placeholders += "Passwords/Tokens need to be updated"
    }
    if ($envContent -match '\[PLACEHOLDER\]') {
        $placeholders += "Port placeholders need to be updated"
    }
    
    if ($placeholders.Count -gt 0) {
        Write-Warning "Found placeholders in .env.production:"
        foreach ($ph in $placeholders) {
            Write-Warning "  - $ph"
        }
        Write-Warning "Please update .env.production before deployment"
        return $false
    }
    
    Write-Success "Environment configuration validated"
    return $true
}

function Test-DockerCompose {
    Write-Header "Validating Docker Compose Configuration"
    
    try {
        $null = docker compose version 2>&1
        $composeCmd = "docker compose"
    } catch {
        try {
            $null = docker-compose version 2>&1
            $composeCmd = "docker-compose"
        } catch {
            Write-Error "Docker Compose not found"
            return $false
        }
    }
    
    Write-Success "Found: $composeCmd"
    
    Write-Info "Validating compose file syntax..."
    try {
        $result = Invoke-Expression "$composeCmd -f docker-compose.yml --env-file .env.production config" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker Compose configuration is valid"
            return $true
        } else {
            Write-Error "Docker Compose validation failed"
            Write-Host $result
            return $false
        }
    } catch {
        Write-Error "Failed to validate Docker Compose: $_"
        return $false
    }
}

function Prepare-Deployment {
    Write-Header "Preparing Deployment to edubad.zut.edu.pl"
    
    $missing = Test-RequiredFiles
    if ($missing.Count -gt 0) {
        Write-Error "Cannot proceed: missing required files"
        return $false
    }
    
    if (-not (Test-EnvConfiguration)) {
        Write-Error "Environment configuration needs attention"
        return $false
    }
    
    if (-not (Test-DockerCompose)) {
        Write-Error "Docker Compose validation failed"
        return $false
    }
    
    Write-Success "Preparation complete - ready for deployment"
    return $true
}

# =============================================================================
# STEP 2: Transfer Files to Server
# =============================================================================

function Transfer-ToServer {
    Write-Header "Transferring Files to $VpsHost"
    
    $remoteDir = "/home/$VpsUser/plat-edu-bad-data-mvp"
    
    Write-Info "Testing SSH connection..."
    try {
        ssh "${VpsUser}@${VpsHost}" "echo 'Connection successful'" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "SSH connection failed"
            Write-Info "Make sure you can connect: ssh ${VpsUser}@${VpsHost}"
            return $false
        }
        Write-Success "SSH connection successful"
    } catch {
        Write-Error "Failed to connect via SSH: $_"
        return $false
    }
    
    Write-Info "Creating remote directory structure..."
    $mkdirCmd = @"
mkdir -p $remoteDir && \
mkdir -p $remoteDir/mosquitto/config $remoteDir/mosquitto/data $remoteDir/mosquitto/log && \
mkdir -p $remoteDir/influxdb/data $remoteDir/influxdb/config $remoteDir/influxdb/backups && \
mkdir -p $remoteDir/node-red/data $remoteDir/node-red/flows && \
mkdir -p $remoteDir/grafana/data $remoteDir/grafana/dashboards $remoteDir/grafana/provisioning && \
mkdir -p $remoteDir/api $remoteDir/frontend
"@
    
    ssh "${VpsUser}@${VpsHost}" $mkdirCmd
    Write-Success "Remote directories created"
    
    Write-Info "Transferring Docker Compose configuration..."
    scp docker-compose.yml "${VpsUser}@${VpsHost}:${remoteDir}/"
    if (Test-Path "docker-compose.prod.yml") {
        scp docker-compose.prod.yml "${VpsUser}@${VpsHost}:${remoteDir}/"
    }
    
    Write-Info "Transferring environment configuration..."
    scp .env.production "${VpsUser}@${VpsHost}:${remoteDir}/.env"
    
    Write-Info "Transferring service configurations..."
    scp -r mosquitto/* "${VpsUser}@${VpsHost}:${remoteDir}/mosquitto/"
    scp -r influxdb/* "${VpsUser}@${VpsHost}:${remoteDir}/influxdb/"
    scp -r node-red/* "${VpsUser}@${VpsHost}:${remoteDir}/node-red/"
    scp -r grafana/* "${VpsUser}@${VpsHost}:${remoteDir}/grafana/"
    
    Write-Info "Transferring application code..."
    scp -r api/* "${VpsUser}@${VpsHost}:${remoteDir}/api/"
    scp -r frontend/* "${VpsUser}@${VpsHost}:${remoteDir}/frontend/"
    
    Write-Success "Files transferred successfully to $remoteDir"
    return $true
}

# =============================================================================
# STEP 3: Deploy on Server
# =============================================================================

function Deploy-OnServer {
    Write-Header "Deploying on $VpsHost"
    
    $remoteDir = "/home/$VpsUser/plat-edu-bad-data-mvp"
    
    # Fix permissions
    Write-Info "Fixing directory permissions..."
    $permCmd = @"
cd $remoteDir && \
sudo chown -R 472:472 ./grafana/data ./grafana/plugins 2>/dev/null || true && \
sudo chown -R 1000:1000 ./node-red/data 2>/dev/null || true && \
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log 2>/dev/null || true && \
sudo chown -R 472:472 ./influxdb/data 2>/dev/null || true && \
sudo chmod -R 755 ./grafana/data ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data 2>/dev/null || true
"@
    
    ssh "${VpsUser}@${VpsHost}" $permCmd
    Write-Success "Permissions fixed"
    
    # Detect docker compose command
    Write-Info "Detecting Docker Compose command..."
    $detectCmd = @"
if docker compose version &> /dev/null 2>&1; then
    echo "docker compose"
elif command -v docker-compose &> /dev/null; then
    echo "docker-compose"
else
    echo "not-found"
fi
"@
    
    $composeCmd = (ssh "${VpsUser}@${VpsHost}" $detectCmd).Trim()
    
    if ($composeCmd -eq "not-found") {
        Write-Error "Docker Compose not found on server"
        Write-Info "Please install Docker Compose on the server"
        return $false
    }
    
    Write-Success "Using: $composeCmd"
    
    # Pull images and build
    Write-Info "Pulling Docker images..."
    ssh "${VpsUser}@${VpsHost}" "cd $remoteDir && sudo $composeCmd pull"
    
    Write-Info "Building custom images..."
    ssh "${VpsUser}@${VpsHost}" "cd $remoteDir && sudo $composeCmd build --no-cache api frontend"
    
    # Start services
    Write-Info "Starting services..."
    ssh "${VpsUser}@${VpsHost}" "cd $remoteDir && sudo $composeCmd up -d"
    
    Write-Success "Services deployed"
    
    # Show status
    Write-Info "Service status:"
    ssh "${VpsUser}@${VpsHost}" "cd $remoteDir && sudo $composeCmd ps"
    
    Write-Success "Deployment complete!"
    return $true
}

# =============================================================================
# STATUS and LOGS
# =============================================================================

function Show-Status {
    Write-Header "Service Status on $VpsHost"
    
    $remoteDir = "/home/$VpsUser/plat-edu-bad-data-mvp"
    
    ssh "${VpsUser}@${VpsHost}" "cd $remoteDir && sudo docker-compose ps"
    
    Write-Info "`nChecking health..."
    $checkCmd = @"
cd $remoteDir && \
for container in \$(sudo docker ps --format '{{.Names}}' | grep iot-); do
    echo "Container: \$container"
    sudo docker inspect --format='{{.State.Health.Status}}' \$container 2>/dev/null || echo "No health check"
    echo ""
done
"@
    
    ssh "${VpsUser}@${VpsHost}" $checkCmd
}

function Show-Logs {
    Write-Header "Service Logs on $VpsHost"
    
    $remoteDir = "/home/$VpsUser/plat-edu-bad-data-mvp"
    
    Write-Info "Showing last 50 lines of logs (Ctrl+C to exit)..."
    ssh "${VpsUser}@${VpsHost}" "cd $remoteDir && sudo docker-compose logs -f --tail=50"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Write-Header "Renewable Energy IoT - edubad.zut.edu.pl Deployment"

if ($Prepare) {
    if (Prepare-Deployment) {
        Write-Success "`nReady for deployment!"
        Write-Info "`nNext steps:"
        Write-Info "1. Transfer: .\scripts\deploy-edubad.ps1 -Transfer"
        Write-Info "2. Deploy: .\scripts\deploy-edubad.ps1 -Deploy"
        Write-Info "Or: .\scripts\deploy-edubad.ps1 -Full"
    } else {
        Write-Error "`nPreparation failed - please fix issues above"
        exit 1
    }
    exit 0
}

if ($Transfer) {
    if (Transfer-ToServer) {
        Write-Success "`nFiles transferred successfully!"
        Write-Info "`nNext step:"
        Write-Info ".\scripts\deploy-edubad.ps1 -Deploy"
    } else {
        Write-Error "`nTransfer failed"
        exit 1
    }
    exit 0
}

if ($Deploy) {
    if (Deploy-OnServer) {
        Write-Success "`nDeployment completed successfully!"
        Write-Info "`nAccess your services at:"
        Write-Info "- Frontend: http://edubad.zut.edu.pl:[FRONTEND_PORT]/"
        Write-Info "- Grafana: http://edubad.zut.edu.pl:[GRAFANA_PORT]/"
        Write-Info "- Node-RED: http://edubad.zut.edu.pl:[NODE_RED_PORT]/"
        Write-Info "- InfluxDB: http://edubad.zut.edu.pl:[INFLUXDB_PORT]/"
        Write-Info "`nReplace [PORT] with your actual port numbers from .env"
    } else {
        Write-Error "`nDeployment failed"
        exit 1
    }
    exit 0
}

if ($Full) {
    Write-Info "Running full deployment process..."
    
    if (-not (Prepare-Deployment)) {
        Write-Error "Preparation failed"
        exit 1
    }
    
    if (-not (Transfer-ToServer)) {
        Write-Error "Transfer failed"
        exit 1
    }
    
    if (-not (Deploy-OnServer)) {
        Write-Error "Deployment failed"
        exit 1
    }
    
    Write-Success "`n✨ Full deployment completed successfully!"
    exit 0
}

if ($Status) {
    Show-Status
    exit 0
}

if ($Logs) {
    Show-Logs
    exit 0
}

# Default: Show help
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  .\scripts\deploy-edubad.ps1 -Prepare   # Prepare and validate files" -ForegroundColor Gray
Write-Host "  .\scripts\deploy-edubad.ps1 -Transfer  # Transfer files to server" -ForegroundColor Gray
Write-Host "  .\scripts\deploy-edubad.ps1 -Deploy    # Deploy on server" -ForegroundColor Gray
Write-Host "  .\scripts\deploy-edubad.ps1 -Full      # Run complete process" -ForegroundColor Gray
Write-Host "  .\scripts\deploy-edubad.ps1 -Status    # Check service status" -ForegroundColor Gray
Write-Host "  .\scripts\deploy-edubad.ps1 -Logs      # View service logs" -ForegroundColor Gray
Write-Host ""


