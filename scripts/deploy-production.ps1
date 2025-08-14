# =============================================================================
# Production Deployment Script (Simplified)
# Renewable Energy IoT Monitoring System - Mikrus VPS
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

function Test-RequiredFiles {
    $required = @(
        "docker-compose.yml",
        "mosquitto/",
        "influxdb/",
        "node-red/",
        "grafana/"
    )
    $missing = @()
    foreach ($item in $required) {
        if (-not (Test-Path $item)) { $missing += $item }
    }
    return $missing
}

function Ensure-EnvProductionExists {
    if (-not (Test-Path ".env.production")) {
        if (Test-Path "env.example") {
            Write-Host "Creating .env.production from env.example..." -ForegroundColor Yellow
            Copy-Item "env.example" ".env.production"
            Write-Host "Created .env.production (review and adjust for production)." -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Missing .env.production and env.example; cannot proceed." -ForegroundColor Red
            exit 1
        }
    }
}

function Prepare-Production {
    Write-Host "Preparing production deployment..." -ForegroundColor Green

    $missing = Test-RequiredFiles
    if ($missing.Count -gt 0) {
        Write-Host "Missing required files:" -ForegroundColor Red
        foreach ($m in $missing) { Write-Host "  - $m" -ForegroundColor Red }
        exit 1
    }

    Ensure-EnvProductionExists

    Write-Host "Production files validated. Ready to transfer." -ForegroundColor Green
}

function Get-RemoteDir {
    if ($VpsUser -eq "root") { return "/root/renewable-energy-iot" }
    return "/home/$VpsUser/renewable-energy-iot"
}

function Transfer-ToVps {
    Write-Host ("Connecting to VPS: {0}@{1}:{2}" -f $VpsUser, $VpsHost, $VpsPort) -ForegroundColor Yellow

    Ensure-EnvProductionExists

    $remoteDir = Get-RemoteDir

    Write-Host "Creating remote directory..." -ForegroundColor Yellow
    & ssh -p $VpsPort "$VpsUser@$VpsHost" "mkdir -p $remoteDir/mosquitto $remoteDir/influxdb $remoteDir/node-red $remoteDir/grafana"

    Write-Host "Transferring compose and service configurations..." -ForegroundColor Yellow
    & scp -P $VpsPort docker-compose.yml             "${VpsUser}@${VpsHost}:$remoteDir/"
    & scp -P $VpsPort -r mosquitto/*                 "${VpsUser}@${VpsHost}:$remoteDir/mosquitto/"
    & scp -P $VpsPort -r influxdb/*                  "${VpsUser}@${VpsHost}:$remoteDir/influxdb/"
    & scp -P $VpsPort -r node-red/*                  "${VpsUser}@${VpsHost}:$remoteDir/node-red/"
    & scp -P $VpsPort -r grafana/*                   "${VpsUser}@${VpsHost}:$remoteDir/grafana/"

    Write-Host "Transferring production environment (.env)..." -ForegroundColor Yellow
    & scp -P $VpsPort .env.production                "${VpsUser}@${VpsHost}:$remoteDir/.env"

    Write-Host "[OK] Files transferred to $remoteDir" -ForegroundColor Green
}

function Deploy-OnVps {
    Write-Host "Deploying on VPS..." -ForegroundColor Green
    $remoteDir = Get-RemoteDir

    # First, ensure Docker Compose is available
    $checkCmd = "if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then echo 'Docker Compose not found'; else echo 'Docker Compose available'; fi"
    $composeStatus = & ssh -p $VpsPort "$VpsUser@$VpsHost" $checkCmd
    
    if ($composeStatus -like "*not found*") {
        Write-Host "Installing Docker Compose..." -ForegroundColor Yellow
        $installCmd = @"
            if ! command -v docker-compose &> /dev/null; then
                curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
                ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
            fi
"@
        & ssh -p $VpsPort "$VpsUser@$VpsHost" $installCmd
    }

    # Use docker-compose (older syntax) for compatibility
    $remoteCmd = "set -e; cd $remoteDir; docker-compose pull; docker-compose up -d; docker-compose ps"
    & ssh -p $VpsPort "$VpsUser@$VpsHost" $remoteCmd

    Write-Host "[OK] Deployment complete. Use docker-compose ps to verify status." -ForegroundColor Green
}

# Main
Write-Host "Renewable Energy IoT - Production Deployment" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

$missingFiles = Test-RequiredFiles
if ($missingFiles.Count -gt 0) {
    Write-Host "Missing required files:" -ForegroundColor Red
    foreach ($file in $missingFiles) { Write-Host "   - $file" -ForegroundColor Red }
    Write-Host "Please ensure all required files exist before deployment." -ForegroundColor Red
}

if ($Prepare) { Prepare-Production; exit 0 }
if ($Transfer) { Transfer-ToVps; exit 0 }
if ($Deploy) { Deploy-OnVps; exit 0 }

if ($Full) {
    Prepare-Production
    Transfer-ToVps
    Deploy-OnVps
    exit 0
}

# Default action
Prepare-Production
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "1. Transfer files: .\scripts\deploy-production.ps1 -Transfer" -ForegroundColor Yellow
Write-Host "2. Deploy on VPS: .\scripts\deploy-production.ps1 -Deploy" -ForegroundColor Yellow
Write-Host "3. Or run full process: .\scripts\deploy-production.ps1 -Full" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
