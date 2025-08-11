# =============================================================================
# Production Deployment Script
# Renewable Energy IoT Monitoring System - Mikrus VPS
# =============================================================================
# 
# This script prepares files for production deployment on Mikrus VPS
# Uses path-based routing with Nginx reverse proxy
# =============================================================================

param(
    [switch]$Prepare,
    [switch]$Transfer,
    [switch]$Deploy,
    [switch]$Full,
    [string]$VpsHost = "robert108.mikrus.xyz",
    [string]$VpsPort = "10108",
    [string]$VpsUser = "root"
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Red = "Red"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if required files exist
function Test-RequiredFiles {
    $requiredFiles = @(
        "docker-compose.yml",
        ".env.production",
        "nginx/nginx.conf"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    
    return $missingFiles
}

# Function to prepare deployment package
function Prepare-Deployment {
    Write-ColorOutput "Preparing production deployment package..." $Green
    
    # Create deployment directory
    $deploymentDir = "deployment"
    if (Test-Path $deploymentDir) {
        Write-ColorOutput "Cleaning existing deployment directory..." $Yellow
        Remove-Item $deploymentDir -Recurse -Force
    }
    
    Write-ColorOutput "Creating deployment directory..." $Yellow
    New-Item -ItemType Directory -Path $deploymentDir -Force | Out-Null
    
    # Copy production environment file
    Write-ColorOutput "Setting up production environment..." $Yellow
    Copy-Item ".env.production" "$deploymentDir/.env"
    
    # Copy Docker Compose file
    Write-ColorOutput "Copying Docker Compose configuration..." $Yellow
    Copy-Item "docker-compose.yml" "$deploymentDir/"
    
    # Copy Nginx configuration
    Write-ColorOutput "Copying Nginx configuration..." $Yellow
    New-Item -ItemType Directory -Path "$deploymentDir/nginx" -Force | Out-Null
    Copy-Item "nginx/nginx.conf" "$deploymentDir/nginx/"
    
    # Copy service configurations
    $serviceDirs = @("mosquitto", "influxdb", "node-red", "grafana")
    foreach ($dir in $serviceDirs) {
        if (Test-Path $dir) {
            Write-ColorOutput "Copying $dir configuration..." $Yellow
            Copy-Item -Recurse $dir "$deploymentDir/"
        }
    }
    
    # Copy web application files
    if (Test-Path "web-app-for-testing") {
        Write-ColorOutput "Copying web application files..." $Yellow
        Copy-Item -Recurse "web-app-for-testing" "$deploymentDir/"
    }
    
    # Create deployment script
    Write-ColorOutput "Creating deployment script..." $Yellow
    $deployScript = @"
#!/bin/bash
# =============================================================================
# Production Deployment Script for Mikrus VPS
# =============================================================================

echo "🚀 Starting production deployment..."

# Stop any existing containers
echo "Stopping existing containers..."
docker-compose down

# Pull latest images
echo "Pulling latest Docker images..."
docker-compose pull

# Start services
echo "Starting production services..."
docker-compose up -d

# Wait for services to start
echo "Waiting for services to initialize..."
sleep 30

# Check service status
echo "Checking service status..."
docker-compose ps

echo "✅ Production deployment completed!"
echo ""
echo "🌐 Access URLs:"
echo "  📊 Grafana Dashboard:    http://$VpsHost:20108/grafana"
echo "  🔧 Node-RED Editor:      http://$VpsHost:20108/nodered"
echo "  🗄️  InfluxDB Admin:       http://$VpsHost:20108/influxdb"
echo "  ⚡ Express Backend API:  http://$VpsHost:20108/api"
echo "  🎨 React Frontend:       http://$VpsHost:20108/app"
echo "  🏠 Default Homepage:     http://$VpsHost:20108/"
echo ""
echo "📡 MQTT Broker: $VpsHost:40098"
echo ""
echo "🔑 Default Credentials:"
echo "  Grafana:     admin / admin"
echo "  Node-RED:    admin / adminpassword"
echo "  InfluxDB:    admin / admin_password_123"
echo "  MQTT:        admin / admin_password_456"
"@
    
    Set-Content -Path "$deploymentDir/deploy.sh" -Value $deployScript
    Set-Content -Path "$deploymentDir/deploy.sh" -Value $deployScript.Replace("`r`n", "`n")
    
    # Create README for deployment
    $readmeContent = @"
# Production Deployment Package

This package contains all files needed to deploy the Renewable Energy IoT Monitoring System on Mikrus VPS.

## Files Included:
- `docker-compose.yml` - Production Docker Compose configuration
- `.env` - Production environment variables
- `nginx/nginx.conf` - Nginx reverse proxy configuration
- `mosquitto/` - MQTT broker configuration
- `influxdb/` - InfluxDB configuration
- `node-red/` - Node-RED configuration
- `grafana/` - Grafana configuration
- `web-app-for-testing/` - Web application files
- `deploy.sh` - Deployment script

## Deployment Steps:
1. Upload this package to your Mikrus VPS
2. SSH into your VPS: `ssh root@robert108.mikrus.xyz -p10108`
3. Navigate to the deployment directory
4. Run: `chmod +x deploy.sh && ./deploy.sh`

## Access URLs:
- Grafana Dashboard: http://robert108.mikrus.xyz:20108/grafana
- Node-RED Editor: http://robert108.mikrus.xyz:20108/nodered
- InfluxDB Admin: http://robert108.mikrus.xyz:20108/influxdb
- Express Backend API: http://robert108.mikrus.xyz:20108/api
- React Frontend: http://robert108.mikrus.xyz:20108/app
- Default Homepage: http://robert108.mikrus.xyz:20108/

## MQTT Broker:
- Host: robert108.mikrus.xyz
- Port: 40098
- Username: admin
- Password: admin_password_456

## Default Credentials:
- Grafana: admin / admin
- Node-RED: admin / adminpassword
- InfluxDB: admin / admin_password_123
- MQTT: admin / admin_password_456
"@
    
    Set-Content -Path "$deploymentDir/README.md" -Value $readmeContent
    
    Write-ColorOutput "✅ Deployment package prepared in '$deploymentDir' directory" $Green
    Write-ColorOutput "📦 Package size: $((Get-ChildItem $deploymentDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB) MB" $Cyan
}

# Function to transfer files to VPS
function Transfer-ToVps {
    Write-ColorOutput "Transferring files to VPS..." $Green
    
    $deploymentDir = "deployment"
    if (-not (Test-Path $deploymentDir)) {
        Write-ColorOutput "❌ Deployment package not found! Run with -Prepare first." $Red
        exit 1
    }
    
    Write-ColorOutput "Connecting to VPS: $VpsUser@$VpsHost:$VpsPort" $Yellow
    
    # Create remote directory
    $remoteDir = "/root/renewable-energy-iot"
    $sshCommand = "ssh -p $VpsPort $VpsUser@$VpsHost"
    
    Write-ColorOutput "Creating remote directory..." $Yellow
    Invoke-Expression "$sshCommand 'mkdir -p $remoteDir'"
    
    # Transfer files using scp
    Write-ColorOutput "Transferring deployment package..." $Yellow
    $scpCommand = "scp -P $VpsPort -r $deploymentDir/* $VpsUser@$VpsHost:$remoteDir/"
    
    try {
        Invoke-Expression $scpCommand
        Write-ColorOutput "✅ Files transferred successfully!" $Green
    }
    catch {
        Write-ColorOutput "❌ File transfer failed!" $Red
        Write-ColorOutput "Error: $_" $Red
        exit 1
    }
}

# Function to deploy on VPS
function Deploy-OnVps {
    Write-ColorOutput "Deploying on VPS..." $Green
    
    $remoteDir = "/root/renewable-energy-iot"
    $sshCommand = "ssh -p $VpsPort $VpsUser@$VpsHost"
    
    Write-ColorOutput "Connecting to VPS and running deployment..." $Yellow
    
    $deployCommands = @"
cd $remoteDir
chmod +x deploy.sh
./deploy.sh
"@
    
    try {
        Invoke-Expression "$sshCommand '$deployCommands'"
        Write-ColorOutput "✅ Deployment completed successfully!" $Green
    }
    catch {
        Write-ColorOutput "❌ Deployment failed!" $Red
        Write-ColorOutput "Error: $_" $Red
        exit 1
    }
}

# Main script logic
Write-ColorOutput "🚀 Renewable Energy IoT - Production Deployment" $Green
Write-ColorOutput "================================================" $Green

# Check for required files
$missingFiles = Test-RequiredFiles
if ($missingFiles.Count -gt 0) {
    Write-ColorOutput "❌ Missing required files:" $Red
    foreach ($file in $missingFiles) {
        Write-ColorOutput "   - $file" $Red
    }
    Write-ColorOutput "Please ensure all required files exist before deployment." $Red
    exit 1
}

# Handle different command options
if ($Prepare) {
    Prepare-Deployment
    exit 0
}

if ($Transfer) {
    Transfer-ToVps
    exit 0
}

if ($Deploy) {
    Deploy-OnVps
    exit 0
}

if ($Full) {
    Write-ColorOutput "Running full deployment process..." $Green
    Prepare-Deployment
    Transfer-ToVps
    Deploy-OnVps
    exit 0
}

# Default action: prepare deployment
Write-ColorOutput "No action specified. Preparing deployment package..." $Yellow
Prepare-Deployment

Write-ColorOutput "`n📋 Next Steps:" $Cyan
Write-ColorOutput "================================================" $Cyan
Write-ColorOutput "1. Review the deployment package in 'deployment/' directory" $Yellow
Write-ColorOutput "2. Transfer files: .\scripts\deploy-production.ps1 -Transfer" $Yellow
Write-ColorOutput "3. Deploy on VPS: .\scripts\deploy-production.ps1 -Deploy" $Yellow
Write-ColorOutput "4. Or run full process: .\scripts\deploy-production.ps1 -Full" $Yellow
Write-ColorOutput "================================================" $Cyan
