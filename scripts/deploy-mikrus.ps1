# =============================================================================
# Production Deployment Script
# Renewable Energy IoT Monitoring System - Mikrus VPS
# =============================================================================
# This script handles production deployment to VPS
# Supports prepare, transfer, deploy, status, logs, stop, restart operations
# =============================================================================

param(
    [switch]$Prepare,
    [switch]$Transfer,
    [switch]$Deploy,
    [switch]$Full,
    [switch]$Status,
    [switch]$Logs,
    [switch]$Stop,
    [switch]$Restart,
    [switch]$NoRebuild,
    [string]$VpsHost = "robert108.mikrus.xyz",
    [string]$VpsPort = "10108",
    [string]$VpsUser = "root"
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Red = "Red"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-RequiredFiles {
    $required = @(
        "docker-compose.yml",
        "mosquitto/",
        "influxdb/",
        "node-red/",
        "grafana/",
        "api/",
        "frontend/",
        "nginx/"
    )
    $missing = @()
    foreach ($item in $required) {
        if (-not (Test-Path $item)) { 
            $missing += $item 
        }
    }
    return $missing
}

function Ensure-EnvProductionExists {
    if (-not (Test-Path ".env.production")) {
        if (Test-Path "env.example") {
            Write-ColorOutput "Creating .env.production from env.example..." $Yellow
            Copy-Item "env.example" ".env.production"
            Write-ColorOutput "Created .env.production (review and adjust for production)." $Green
        } else {
            Write-ColorOutput "[ERROR] Missing .env.production and env.example; cannot proceed." $Red
            exit 1
        }
    }
}

function Get-RemoteDir {
    if ($VpsUser -eq "root") { 
        return "/root/renewable-energy-iot" 
    }
    return "/home/$VpsUser/renewable-energy-iot"
}

function Get-RemoteDockerComposeCmd {
    param([string]$RemoteDir)
    
    # Detect which docker compose command to use on remote
    $detectCmd = @"
        if docker compose version &> /dev/null 2>&1; then
            echo "docker compose"
        elif command -v docker-compose &> /dev/null; then
            echo "docker-compose"
        else
            echo "not-found"
        fi
"@
    
    $composeCmd = (& ssh -p $VpsPort "$VpsUser@$VpsHost" $detectCmd).Trim()
    
    if ($composeCmd -eq "not-found") {
        Write-ColorOutput "Docker Compose not found. Installing..." $Yellow
        $installCmd = @"
            if ! docker compose version &> /dev/null 2>&1 && ! command -v docker-compose &> /dev/null; then
                curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
                ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
                echo "docker-compose"
            else
                if docker compose version &> /dev/null 2>&1; then
                    echo "docker compose"
                else
                    echo "docker-compose"
                fi
            fi
"@
        $composeCmd = (& ssh -p $VpsPort "$VpsUser@$VpsHost" $installCmd).Trim()
        
        if ($composeCmd -eq "not-found") {
            Write-ColorOutput "[ERROR] Failed to install Docker Compose" $Red
            exit 1
        }
    }
    
    return $composeCmd
}

function Prepare-Production {
    Write-ColorOutput "Preparing production deployment..." $Green

    $missing = Test-RequiredFiles
    if ($missing.Count -gt 0) {
        Write-ColorOutput "Missing required files:" $Red
        foreach ($m in $missing) { 
            Write-ColorOutput "  - $m" $Red 
        }
        exit 1
    }

    Ensure-EnvProductionExists

    Write-ColorOutput "Production files validated. Ready to transfer." $Green
}

function Transfer-ToVps {
    Write-ColorOutput ("Connecting to VPS: {0}@{1}:{2}" -f $VpsUser, $VpsHost, $VpsPort) $Yellow

    Ensure-EnvProductionExists

    $remoteDir = Get-RemoteDir

    Write-ColorOutput "Creating remote directory structure..." $Yellow
    $createDirsCmd = "mkdir -p $remoteDir/mosquitto $remoteDir/influxdb $remoteDir/node-red $remoteDir/grafana $remoteDir/api $remoteDir/frontend $remoteDir/nginx"
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $createDirsCmd
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[ERROR] Failed to create remote directories" $Red
        exit 1
    }

    Write-ColorOutput "Transferring Docker Compose configuration..." $Yellow
    & scp -P $VpsPort docker-compose.yml "${VpsUser}@${VpsHost}:$remoteDir/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[ERROR] Failed to transfer docker-compose.yml" $Red
        exit 1
    }

    Write-ColorOutput "Transferring service configurations..." $Yellow
    & scp -P $VpsPort -r mosquitto/* "${VpsUser}@${VpsHost}:$remoteDir/mosquitto/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer mosquitto config" $Yellow
    }
    
    & scp -P $VpsPort -r influxdb/* "${VpsUser}@${VpsHost}:$remoteDir/influxdb/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer influxdb config" $Yellow
    }
    
    & scp -P $VpsPort -r node-red/* "${VpsUser}@${VpsHost}:$remoteDir/node-red/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer node-red config" $Yellow
    }
    
    & scp -P $VpsPort -r grafana/* "${VpsUser}@${VpsHost}:$remoteDir/grafana/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer grafana config" $Yellow
    }

    Write-ColorOutput "Transferring application code..." $Yellow
    & scp -P $VpsPort -r api/* "${VpsUser}@${VpsHost}:$remoteDir/api/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer api code" $Yellow
    }
    
    & scp -P $VpsPort -r frontend/* "${VpsUser}@${VpsHost}:$remoteDir/frontend/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer frontend code" $Yellow
    }
    
    & scp -P $VpsPort -r nginx/* "${VpsUser}@${VpsHost}:$remoteDir/nginx/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer nginx config" $Yellow
    }

    Write-ColorOutput "Transferring production environment (.env)..." $Yellow
    & scp -P $VpsPort .env.production "${VpsUser}@${VpsHost}:$remoteDir/.env"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[ERROR] Failed to transfer .env file" $Red
        exit 1
    }

    Write-ColorOutput "[OK] Files transferred to $remoteDir" $Green
}

function Deploy-OnVps {
    param(
        [bool]$shouldRebuild = $true,
        [bool]$useNoCache = $false
    )
    
    Write-ColorOutput "Deploying on VPS..." $Green
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    Write-ColorOutput "Using: $composeCmd" $Cyan

    # Fix permissions on remote (important for VPS deployment)
    Write-ColorOutput "Fixing Docker volume permissions..." $Yellow
    $fixPermsCmd = @"
        cd $remoteDir
        sudo chown -R 472:472 ./grafana/data ./grafana/plugins 2>/dev/null || true
        sudo chown -R 1000:1000 ./node-red/data 2>/dev/null || true
        sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log 2>/dev/null || true
        sudo chown -R 472:472 ./influxdb/data 2>/dev/null || true
        sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data 2>/dev/null || true
"@
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $fixPermsCmd

    # Stop any existing containers
    Write-ColorOutput "Stopping any existing containers..." $Yellow
    $stopCmd = "cd $remoteDir; $composeCmd down 2>/dev/null || true"
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $stopCmd

    # Deploy with optional rebuild
    if ($shouldRebuild) {
        if ($useNoCache) {
            Write-ColorOutput "Rebuilding services with --no-cache (fresh build)..." $Yellow
            $buildCmd = "cd $remoteDir; $composeCmd build --no-cache"
            & ssh -p $VpsPort "$VpsUser@$VpsHost" $buildCmd
            if ($LASTEXITCODE -ne 0) {
                Write-ColorOutput "[ERROR] Failed to build services" $Red
                exit 1
            }
            Write-ColorOutput "Starting services..." $Yellow
            $startCmd = "cd $remoteDir; $composeCmd up -d"
            & ssh -p $VpsPort "$VpsUser@$VpsHost" $startCmd
        } else {
            Write-ColorOutput "Pulling latest images and rebuilding services..." $Yellow
            $deployCmd = "cd $remoteDir; $composeCmd pull; $composeCmd up -d --build"
            & ssh -p $VpsPort "$VpsUser@$VpsHost" $deployCmd
        }
    } else {
        Write-ColorOutput "Starting services (no rebuild)..." $Yellow
        $startCmd = "cd $remoteDir; $composeCmd pull; $composeCmd up -d"
        & ssh -p $VpsPort "$VpsUser@$VpsHost" $startCmd
    }

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Services started successfully" $Green
        
        # Wait a bit for services to initialize
        Write-ColorOutput "Waiting for services to initialize..." $Yellow
        Start-Sleep -Seconds 5
        
        # Show status
        Show-RemoteStatus
    } else {
        Write-ColorOutput "[ERROR] Failed to start services" $Red
        exit 1
    }
}

function Show-RemoteStatus {
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    Write-ColorOutput "Checking service status on VPS..." $Green
    $statusCmd = "cd $remoteDir; $composeCmd ps"
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $statusCmd
}

function Show-RemoteLogs {
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    Write-ColorOutput "Showing service logs (Ctrl+C to stop)..." $Green
    $logsCmd = "cd $remoteDir; $composeCmd logs -f"
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $logsCmd
}

function Stop-RemoteServices {
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    Write-ColorOutput "Stopping production services on VPS..." $Green
    $stopCmd = "cd $remoteDir; $composeCmd down"
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $stopCmd
    Write-ColorOutput "Services stopped" $Green
}

function Restart-RemoteServices {
    param(
        [bool]$shouldRebuild = $true,
        [bool]$useNoCache = $false
    )
    
    Write-ColorOutput "Restarting production services on VPS..." $Green
    Stop-RemoteServices
    Start-Sleep -Seconds 2
    Deploy-OnVps -shouldRebuild $shouldRebuild -useNoCache $useNoCache
}

function Show-AccessInfo {
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Production Access URLs:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  Server: $VpsHost" $Yellow
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "  Services:" $Cyan
    Write-ColorOutput "  - Grafana Dashboard:   http://$VpsHost:40099" $Yellow
    Write-ColorOutput "  - Node-RED Editor:     http://$VpsHost:40100" $Yellow
    Write-ColorOutput "  - InfluxDB Admin:      http://$VpsHost:40101" $Yellow
    Write-ColorOutput "  - MQTT Broker:         $VpsHost:40098" $Yellow
    Write-ColorOutput "  - MQTT WebSocket:       $VpsHost:9001" $Yellow
    Write-ColorOutput "================================================" $Cyan

    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Tips:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  - Use '.\\scripts\\deploy-mikrus.ps1 -Status' to check status" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\deploy-mikrus.ps1 -Logs' to view logs" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\deploy-mikrus.ps1 -Stop' to stop services" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\deploy-mikrus.ps1 -Restart' to restart & rebuild services" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\deploy-mikrus.ps1 -Restart -NoRebuild' to restart without rebuild" $Yellow
    Write-ColorOutput "================================================" $Cyan
}

# Main script logic
Write-ColorOutput "Renewable Energy IoT - Production Deployment" $Green
Write-ColorOutput "================================================" $Green
Write-ColorOutput "VPS: $VpsUser@$VpsHost:$VpsPort" $Cyan
Write-ColorOutput ""

# Check for required files
$missingFiles = Test-RequiredFiles
if ($missingFiles.Count -gt 0) {
    Write-ColorOutput "Missing required files:" $Red
    foreach ($file in $missingFiles) { 
        Write-ColorOutput "  - $file" $Red 
    }
    if (-not ($Prepare -or $Status -or $Logs -or $Stop -or $Restart)) {
        Write-ColorOutput "Please ensure all required files exist before deployment." $Red
        exit 1
    }
}

# Handle switches
if ($Stop) {
    Stop-RemoteServices
    exit 0
}

if ($Status) {
    Show-RemoteStatus
    exit 0
}

if ($Logs) {
    Show-RemoteLogs
    exit 0
}

if ($Restart) {
    $shouldRebuild = -not $NoRebuild
    Restart-RemoteServices -shouldRebuild $shouldRebuild -useNoCache $true
    Show-AccessInfo
    exit 0
}

if ($Prepare) { 
    Prepare-Production
    exit 0 
}

if ($Transfer) { 
    Transfer-ToVps
    exit 0 
}

if ($Deploy) { 
    $shouldRebuild = -not $NoRebuild
    Deploy-OnVps -shouldRebuild $shouldRebuild
    Show-AccessInfo
    exit 0 
}

if ($Full) {
    Prepare-Production
    Transfer-ToVps
    $shouldRebuild = -not $NoRebuild
    Deploy-OnVps -shouldRebuild $shouldRebuild
    Show-AccessInfo
    exit 0
}

# Default action
Prepare-Production
Write-ColorOutput "" $Cyan
Write-ColorOutput "Next Steps:" $Cyan
Write-ColorOutput "================================================" $Cyan
Write-ColorOutput "1. Transfer files: .\scripts\deploy-mikrus.ps1 -Transfer" $Yellow
Write-ColorOutput "2. Deploy on VPS: .\scripts\deploy-mikrus.ps1 -Deploy" $Yellow
Write-ColorOutput "3. Or run full process: .\scripts\deploy-mikrus.ps1 -Full" $Yellow
Write-ColorOutput "" $Cyan
Write-ColorOutput "Additional Commands:" $Cyan
Write-ColorOutput "  - Status:  .\scripts\deploy-mikrus.ps1 -Status" $Yellow
Write-ColorOutput "  - Logs:    .\scripts\deploy-mikrus.ps1 -Logs" $Yellow
Write-ColorOutput "  - Stop:    .\scripts\deploy-mikrus.ps1 -Stop" $Yellow
Write-ColorOutput "  - Restart: .\scripts\deploy-mikrus.ps1 -Restart" $Yellow
Write-ColorOutput "================================================" $Cyan
