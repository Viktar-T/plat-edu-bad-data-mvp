# =============================================================================
# Production Deployment Script for edubad.zut.edu.pl
# Renewable Energy IoT Monitoring System
# =============================================================================
# This script handles production deployment to edubad.zut.edu.pl VPS
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
    [string]$VpsHost = "edubad.zut.edu.pl",
    [string]$VpsUser = "admin"
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

function Get-RemoteDir {
    return "/home/$VpsUser/plat-edu-bad-data-mvp"
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
    
    $composeCmd = (ssh "${VpsUser}@${VpsHost}" $detectCmd).Trim()
    
    if ($composeCmd -eq "not-found") {
        Write-ColorOutput "Docker Compose not found on server" $Red
        Write-ColorOutput "Please install Docker Compose on the server" $Yellow
        return $null
    }
    
    return $composeCmd
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

function Generate-SecurePassword {
    param([int]$Length = 20)
    # Generate secure random password using base64 encoding
    $bytes = New-Object byte[] $Length
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    return [Convert]::ToBase64String($bytes).Substring(0, [Math]::Min($Length, [Convert]::ToBase64String($bytes).Length))
}

function Generate-SecureToken {
    param([int]$Length = 32)
    # Generate secure random hex token
    $chars = "0123456789abcdef"
    $token = ""
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    for ($i = 0; $i -lt $Length; $i++) {
        $bytes = New-Object byte[] 1
        $rng.GetBytes($bytes)
        $token += $chars[$bytes[0] % 16]
    }
    return $token
}

function Generate-SecureSecrets {
    Write-ColorOutput "🔐 Generating secure passwords and tokens..." $Yellow
    
    # Generate secure passwords (20 characters base64)
    $mqttPassword = Generate-SecurePassword -Length 20
    $influxPassword = Generate-SecurePassword -Length 20
    $noderedPassword = Generate-SecurePassword -Length 20
    $grafanaPassword = Generate-SecurePassword -Length 20
    
    # Generate secure tokens (32 hex characters)
    $influxToken = Generate-SecureToken -Length 32
    $noderedSecret = Generate-SecureToken -Length 32
    
    # Read secrets file
    $secretsContent = Get-Content ".env.secrets" -Raw
    
    # Replace all placeholders with generated values
    $secretsContent = $secretsContent -replace 'your_mqtt_password_here', $mqttPassword
    $secretsContent = $secretsContent -replace 'your_influxdb_password_here', $influxPassword
    $secretsContent = $secretsContent -replace 'your_nodered_password_here', $noderedPassword
    $secretsContent = $secretsContent -replace 'your_grafana_password_here', $grafanaPassword
    $secretsContent = $secretsContent -replace 'your_influxdb_token_here', $influxToken
    $secretsContent = $secretsContent -replace 'your_nodered_secret_here', $noderedSecret
    
    # Write back to file
    Set-Content ".env.secrets" -Value $secretsContent -NoNewline
    
    Write-ColorOutput "✅ Generated secure secrets:" $Green
    Write-ColorOutput "   - MQTT Password: Generated" $Cyan
    Write-ColorOutput "   - InfluxDB Password: Generated" $Cyan
    Write-ColorOutput "   - InfluxDB Token: Generated" $Cyan
    Write-ColorOutput "   - Node-RED Password: Generated" $Cyan
    Write-ColorOutput "   - Node-RED Secret: Generated" $Cyan
    Write-ColorOutput "   - Grafana Password: Generated" $Cyan
}

function Setup-EnvironmentFiles {
    Write-ColorOutput "Setting up production environment files..." $Green
    
    $hasConfig = Test-Path ".env.production"
    $hasSecrets = Test-Path ".env.secrets"
    $hasConfigTemplate = Test-Path ".env.production.template"
    $hasSecretsTemplate = Test-Path ".env.secrets.template"
    $needsSetup = $false
    
    # Auto-create .env.production from template if missing
    if (-not $hasConfig) {
        if ($hasConfigTemplate) {
            Copy-Item ".env.production.template" ".env.production"
            Write-ColorOutput "✅ Created .env.production from template" $Green
            Write-ColorOutput "   ⚠️  Please review and update: SERVER_IP, ports, URLs for your server" $Yellow
            $needsSetup = $true
        } elseif (Test-Path "env.example") {
            Copy-Item "env.example" ".env.production"
            Write-ColorOutput "✅ Created .env.production from env.example" $Green
            Write-ColorOutput "   ⚠️  Please review and update: SERVER_IP, ports, URLs, passwords" $Yellow
            $needsSetup = $true
        }
    }
    
    # Auto-create .env.secrets from template if missing
    if (-not $hasSecrets) {
        if ($hasSecretsTemplate) {
            Copy-Item ".env.secrets.template" ".env.secrets"
            Write-ColorOutput "✅ Created .env.secrets from template" $Green
            
            # Auto-generate secure passwords and tokens
            Generate-SecureSecrets
            Write-ColorOutput "💾 Secrets saved to .env.secrets" $Cyan
            $needsSetup = $true
        }
    }
    
    if ($needsSetup) {
        Write-ColorOutput "" $Cyan
        Write-ColorOutput "📝 Next steps:" $Cyan
        Write-ColorOutput "   1. Review .env.production and update server-specific values:" $Yellow
        Write-ColorOutput "      - SERVER_IP (e.g., edubad.zut.edu.pl)" $Yellow
        Write-ColorOutput "      - Ports (if different from defaults)" $Yellow
        Write-ColorOutput "      - URLs (if different from defaults)" $Yellow
        Write-ColorOutput "   2. Review .env.secrets (passwords/tokens are auto-generated)" $Yellow
        Write-ColorOutput "   3. Run deployment again: .\scripts\deploy-edubad.ps1 -Full" $Yellow
        Write-ColorOutput "" $Cyan
    }
    
    return $needsSetup
}

function Ensure-EnvProductionExists {
    # Hybrid approach: Check for separate config and secrets files
    $hasConfig = Test-Path ".env.production"
    $hasSecrets = Test-Path ".env.secrets"
    $hasConfigTemplate = Test-Path ".env.production.template"
    $hasSecretsTemplate = Test-Path ".env.secrets.template"
    
    # Auto-setup files if they don't exist
    if ((-not $hasConfig) -or (-not $hasSecrets)) {
        $needsSetup = Setup-EnvironmentFiles
        if ($needsSetup) {
            return $false
        }
    }
    
    # If both .env.production and .env.secrets exist, use hybrid approach
    if ($hasConfig -and $hasSecrets) {
        Write-ColorOutput "Using hybrid approach: separate config and secrets files" $Green
        
        # Check for placeholders in secrets file
        $secretsContent = Get-Content ".env.secrets" -Raw
        if ($secretsContent -match 'your_.*_here') {
            Write-ColorOutput "⚠️  Found placeholders in .env.secrets!" $Red
            Write-ColorOutput "   Auto-generating secure secrets..." $Yellow
            Generate-SecureSecrets
            Write-ColorOutput "✅ Secrets generated successfully" $Green
        }
        
        return $true
    }
    
    # Legacy approach: single .env.production file
    if ($hasConfig -and -not $hasSecrets) {
        Write-ColorOutput "Using legacy approach: single .env.production file" $Yellow
        
        # Check for placeholders
        $envContent = Get-Content ".env.production" -Raw
        $placeholders = @()
        
        if ($envContent -match '\[CHANGE_ME') {
            $placeholders += "Passwords/Tokens need to be updated"
        }
        if ($envContent -match '\[PLACEHOLDER\]') {
            $placeholders += "Port placeholders need to be updated"
        }
        if ($envContent -match 'your_.*_here') {
            $placeholders += "Password/token placeholders need to be updated"
        }
        
        if ($placeholders.Count -gt 0) {
            Write-ColorOutput "Found placeholders in .env.production:" $Yellow
            foreach ($ph in $placeholders) {
                Write-ColorOutput "  - $ph" $Yellow
            }
            Write-ColorOutput "Please update .env.production before deployment" $Yellow
            return $false
        }
        
        return $true
    }
    
    Write-ColorOutput ".env.production or .env.secrets not found and no templates available!" $Red
    Write-ColorOutput "Please create .env.production and .env.secrets files" $Yellow
    return $false
}

function Prepare-Production {
    Write-ColorOutput "Preparing production deployment..." $Green
    
    $missing = Test-RequiredFiles
    if ($missing.Count -gt 0) {
        Write-ColorOutput "Missing required files:" $Red
        foreach ($m in $missing) {
            Write-ColorOutput "  - $m" $Red
        }
        return $false
    }
    
    if (-not (Ensure-EnvProductionExists)) {
        Write-ColorOutput "Environment configuration needs attention" $Red
        return $false
    }
    
    Write-ColorOutput "Production files validated. Ready to transfer." $Green
    return $true
}

function Transfer-ToVps {
    Write-ColorOutput ("Connecting to VPS: {0}@{1}" -f $VpsUser, $VpsHost) $Yellow
    
    if (-not (Ensure-EnvProductionExists)) {
        Write-ColorOutput "Environment configuration needs attention" $Red
        return $false
    }
    
    $remoteDir = Get-RemoteDir
    
    Write-ColorOutput "Testing SSH connection..." $Yellow
    try {
        ssh "${VpsUser}@${VpsHost}" "echo 'Connection successful'" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "SSH connection failed" $Red
            Write-ColorOutput "Make sure you can connect: ssh ${VpsUser}@${VpsHost}" $Yellow
            return $false
        }
        Write-ColorOutput "SSH connection successful" $Green
    } catch {
        Write-ColorOutput "Failed to connect via SSH: $_" $Red
        return $false
    }
    
    Write-ColorOutput "Creating remote directory structure..." $Yellow
    $createDirsCmd = "mkdir -p $remoteDir/mosquitto $remoteDir/influxdb $remoteDir/node-red $remoteDir/grafana $remoteDir/api $remoteDir/frontend $remoteDir/nginx"
    ssh "${VpsUser}@${VpsHost}" $createDirsCmd
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[ERROR] Failed to create remote directories" $Red
        return $false
    }
    
    Write-ColorOutput "Transferring Docker Compose configuration..." $Yellow
    scp docker-compose.yml "${VpsUser}@${VpsHost}:${remoteDir}/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[ERROR] Failed to transfer docker-compose.yml" $Red
        return $false
    }
    
    if (Test-Path "docker-compose.prod.yml") {
        scp docker-compose.prod.yml "${VpsUser}@${VpsHost}:${remoteDir}/"
    }
    
    Write-ColorOutput "Transferring service configurations..." $Yellow
    scp -r mosquitto/* "${VpsUser}@${VpsHost}:${remoteDir}/mosquitto/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer mosquitto config" $Yellow
    }
    
    scp -r influxdb/* "${VpsUser}@${VpsHost}:${remoteDir}/influxdb/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer influxdb config" $Yellow
    }
    
    scp -r node-red/* "${VpsUser}@${VpsHost}:${remoteDir}/node-red/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer node-red config" $Yellow
    }
    
    scp -r grafana/* "${VpsUser}@${VpsHost}:${remoteDir}/grafana/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer grafana config" $Yellow
    }
    
    Write-ColorOutput "Transferring application code..." $Yellow
    scp -r api/* "${VpsUser}@${VpsHost}:${remoteDir}/api/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer api code" $Yellow
    }
    
    scp -r frontend/* "${VpsUser}@${VpsHost}:${remoteDir}/frontend/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer frontend code" $Yellow
    }
    
    scp -r nginx/* "${VpsUser}@${VpsHost}:${remoteDir}/nginx/"
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "[WARNING] Failed to transfer nginx config" $Yellow
    }
    
    # Hybrid approach: Transfer config and secrets separately
    if (Test-Path ".env.secrets") {
        Write-ColorOutput "Transferring production environment files (hybrid approach)..." $Yellow
        
        # Transfer non-sensitive config
        scp .env.production "${VpsUser}@${VpsHost}:${remoteDir}/.env.production"
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "[ERROR] Failed to transfer .env.production" $Red
            return $false
        }
        
        # Transfer secrets separately
        scp .env.secrets "${VpsUser}@${VpsHost}:${remoteDir}/.env.secrets"
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "[ERROR] Failed to transfer .env.secrets" $Red
            return $false
        }
        
        # Combine files on remote server and set secure permissions
        Write-ColorOutput "Combining environment files on remote server..." $Yellow
        $combineCmd = @"
cd $remoteDir
cat .env.production .env.secrets > .env
chmod 600 .env .env.secrets
chown ${VpsUser}:${VpsUser} .env .env.secrets
rm -f .env.production .env.secrets
"@
        ssh "${VpsUser}@${VpsHost}" $combineCmd
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "[WARNING] Failed to combine environment files on remote" $Yellow
            Write-ColorOutput "You may need to combine them manually on the server" $Yellow
        } else {
            Write-ColorOutput "Environment files combined and secured on remote server" $Green
        }
    } else {
        # Legacy approach: single .env.production file
        Write-ColorOutput "Transferring production environment (.env)..." $Yellow
        scp .env.production "${VpsUser}@${VpsHost}:${remoteDir}/.env"
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "[ERROR] Failed to transfer .env file" $Red
            return $false
        }
        
        # Set secure permissions on remote
        ssh "${VpsUser}@${VpsHost}" "chmod 600 ${remoteDir}/.env && chown ${VpsUser}:${VpsUser} ${remoteDir}/.env"
    }
    
    Write-ColorOutput "[OK] Files transferred to $remoteDir" $Green
    return $true
}

function Deploy-OnVps {
    param(
        [bool]$shouldRebuild = $true,
        [bool]$useNoCache = $false
    )
    
    Write-ColorOutput "Deploying on VPS..." $Green
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    if (-not $composeCmd) {
        return $false
    }
    
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
    ssh "${VpsUser}@${VpsHost}" $fixPermsCmd
    
    # Stop any existing containers
    Write-ColorOutput "Stopping any existing containers..." $Yellow
    $stopCmd = "cd $remoteDir; sudo $composeCmd down 2>/dev/null || true"
    ssh "${VpsUser}@${VpsHost}" $stopCmd
    
    # Deploy with optional rebuild
    if ($shouldRebuild) {
        if ($useNoCache) {
            Write-ColorOutput "Rebuilding services with --no-cache (fresh build)..." $Yellow
            $buildCmd = "cd $remoteDir; sudo $composeCmd build --no-cache"
            ssh "${VpsUser}@${VpsHost}" $buildCmd
            if ($LASTEXITCODE -ne 0) {
                Write-ColorOutput "[ERROR] Failed to build services" $Red
                return $false
            }
            Write-ColorOutput "Starting services..." $Yellow
            $startCmd = "cd $remoteDir; sudo $composeCmd up -d"
            ssh "${VpsUser}@${VpsHost}" $startCmd
        } else {
            Write-ColorOutput "Pulling latest images and rebuilding services..." $Yellow
            $deployCmd = "cd $remoteDir; sudo $composeCmd pull; sudo $composeCmd build api frontend; sudo $composeCmd up -d"
            ssh "${VpsUser}@${VpsHost}" $deployCmd
        }
    } else {
        Write-ColorOutput "Starting services (no rebuild)..." $Yellow
        $startCmd = "cd $remoteDir; sudo $composeCmd pull; sudo $composeCmd up -d"
        ssh "${VpsUser}@${VpsHost}" $startCmd
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Services started successfully" $Green
        
        # Wait a bit for services to initialize
        Write-ColorOutput "Waiting for services to initialize..." $Yellow
        Start-Sleep -Seconds 5
        
        # Show status
        Show-RemoteStatus
        return $true
    } else {
        Write-ColorOutput "[ERROR] Failed to start services" $Red
        return $false
    }
}

function Stop-RemoteServices {
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    if (-not $composeCmd) {
        return $false
    }
    
    Write-ColorOutput "Stopping production services on VPS..." $Green
    $stopCmd = "cd $remoteDir; sudo $composeCmd down"
    ssh "${VpsUser}@${VpsHost}" $stopCmd
    Write-ColorOutput "Services stopped" $Green
    return $true
}

function Restart-RemoteServices {
    param(
        [bool]$shouldRebuild = $true,
        [bool]$useNoCache = $false
    )
    
    Write-ColorOutput "Restarting production services on VPS..." $Green
    Stop-RemoteServices
    Start-Sleep -Seconds 2
    return Deploy-OnVps -shouldRebuild $shouldRebuild -useNoCache $useNoCache
}

function Show-RemoteStatus {
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    if (-not $composeCmd) {
        return
    }
    
    Write-ColorOutput "Checking service status on VPS..." $Green
    $statusCmd = "cd $remoteDir; sudo $composeCmd ps"
    ssh "${VpsUser}@${VpsHost}" $statusCmd
    
    Write-ColorOutput "`nChecking container health..." $Cyan
    $checkCmd = @"
cd $remoteDir
for container in \$(sudo docker ps --format '{{.Names}}' | grep iot-); do
    echo "Container: \$container"
    sudo docker inspect --format='{{.State.Health.Status}}' \$container 2>/dev/null || echo "No health check"
    echo ""
done
"@
    ssh "${VpsUser}@${VpsHost}" $checkCmd
}

function Show-RemoteLogs {
    $remoteDir = Get-RemoteDir
    $composeCmd = Get-RemoteDockerComposeCmd -RemoteDir $remoteDir
    
    if (-not $composeCmd) {
        return
    }
    
    Write-ColorOutput "Showing service logs (Ctrl+C to stop)..." $Green
    $logsCmd = "cd $remoteDir; sudo $composeCmd logs -f --tail=50"
    ssh "${VpsUser}@${VpsHost}" $logsCmd
}

function Show-AccessInfo {
    # Try to read server info from .env.production file
    $nginxPort = "8080"
    $mqttPort = "1883"
    
    if (Test-Path ".env.production") {
        $envContent = Get-Content ".env.production" -Raw
        if ($envContent -match "NGINX_PORT=([^\r\n]+)") {
            $nginxPort = $matches[1].Trim()
        }
        if ($envContent -match "MQTT_PORT=([^\r\n]+)") {
            $mqttPort = $matches[1].Trim()
        }
    }
    
    $baseUrl = "http://$VpsHost"
    if ($nginxPort -ne "80") {
        $baseUrl = "http://$VpsHost`:$nginxPort"
    }
    
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Production Access URLs (edubad.zut.edu.pl):" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  Server: $VpsHost" $Yellow
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "  Path-Based Routing (via Nginx):" $Cyan
    Write-ColorOutput "  - Nginx Entry Point:     $baseUrl" $Yellow
    Write-ColorOutput "  - Grafana Dashboard:     $baseUrl/grafana/" $Yellow
    Write-ColorOutput "  - Node-RED Editor:       $baseUrl/nodered/" $Yellow
    Write-ColorOutput "  - InfluxDB Admin:        $baseUrl/influxdb/" $Yellow
    Write-ColorOutput "  - Express Backend API:   $baseUrl/api/" $Yellow
    Write-ColorOutput "  - React Frontend:        $baseUrl/app/" $Yellow
    Write-ColorOutput "  - Health Check:         $baseUrl/health" $Yellow
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "  Direct Access (MQTT only):" $Cyan
    Write-ColorOutput "  - MQTT Broker:         $VpsHost`:$mqttPort" $Yellow
    Write-ColorOutput "  - MQTT WebSocket:       $VpsHost`:9001" $Yellow
    Write-ColorOutput "================================================" $Cyan

    Write-ColorOutput "" $Cyan
    Write-ColorOutput "⚠️  Production Credentials:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  Check your .env.production file for credentials" $Yellow
    Write-ColorOutput "  Ensure all default passwords have been changed!" $Red
    Write-ColorOutput "================================================" $Cyan

    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Usage Tips:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  - All HTTP services are accessible via nginx" $Yellow
    Write-ColorOutput "  - Use path-based routing: /grafana/, /nodered/, /influxdb/, /api/, /app/" $Yellow
    Write-ColorOutput "  - MQTT remains accessible directly on port $mqttPort and 9001" $Yellow
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "  Script Commands:" $Cyan
    Write-ColorOutput "  - .\scripts\deploy-edubad.ps1 -Logs          # View all logs" $Yellow
    Write-ColorOutput "  - .\scripts\deploy-edubad.ps1 -Status          # Check service status" $Yellow
    Write-ColorOutput "  - .\scripts\deploy-edubad.ps1 -Stop            # Stop services" $Yellow
    Write-ColorOutput "  - .\scripts\deploy-edubad.ps1 -Restart        # Restart & rebuild services" $Yellow
    Write-ColorOutput "  - .\scripts\deploy-edubad.ps1 -Restart -NoRebuild  # Restart without rebuild" $Yellow
    Write-ColorOutput "  - .\scripts\deploy-edubad.ps1 -Deploy -NoRebuild  # Deploy without rebuild" $Yellow
    Write-ColorOutput "================================================" $Cyan
}

# Main script logic
Write-ColorOutput "Renewable Energy IoT - edubad.zut.edu.pl Deployment" $Green
Write-ColorOutput "================================================" $Green
Write-ColorOutput "VPS: $VpsUser@$VpsHost" $Cyan
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
    if (Stop-RemoteServices) {
        exit 0
    } else {
        exit 1
    }
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
    if (Restart-RemoteServices -shouldRebuild $shouldRebuild -useNoCache $true) {
        Show-AccessInfo
        exit 0
    } else {
        exit 1
    }
}

if ($Prepare) {
    if (Prepare-Production) {
        Write-ColorOutput "`nReady for deployment!" $Green
        Write-ColorOutput "" $Cyan
        Write-ColorOutput "Next steps:" $Cyan
        Write-ColorOutput "1. Transfer: .\scripts\deploy-edubad.ps1 -Transfer" $Yellow
        Write-ColorOutput "2. Deploy: .\scripts\deploy-edubad.ps1 -Deploy" $Yellow
        Write-ColorOutput "Or: .\scripts\deploy-edubad.ps1 -Full" $Yellow
    } else {
        Write-ColorOutput "`nPreparation failed - please fix issues above" $Red
        exit 1
    }
    exit 0
}

if ($Transfer) {
    if (Transfer-ToVps) {
        Write-ColorOutput "`nFiles transferred successfully!" $Green
        Write-ColorOutput "" $Cyan
        Write-ColorOutput "Next step:" $Cyan
        Write-ColorOutput ".\scripts\deploy-edubad.ps1 -Deploy" $Yellow
    } else {
        Write-ColorOutput "`nTransfer failed" $Red
        exit 1
    }
    exit 0
}

if ($Deploy) {
    $shouldRebuild = -not $NoRebuild
    if (Deploy-OnVps -shouldRebuild $shouldRebuild) {
        Write-ColorOutput "`nDeployment completed successfully!" $Green
        Show-AccessInfo
        exit 0
    } else {
        Write-ColorOutput "`nDeployment failed" $Red
        exit 1
    }
}

if ($Full) {
    Write-ColorOutput "Running full deployment process..." $Green
    
    if (-not (Prepare-Production)) {
        Write-ColorOutput "Preparation failed" $Red
        exit 1
    }
    
    if (-not (Transfer-ToVps)) {
        Write-ColorOutput "Transfer failed" $Red
        exit 1
    }
    
    $shouldRebuild = -not $NoRebuild
    if (-not (Deploy-OnVps -shouldRebuild $shouldRebuild)) {
        Write-ColorOutput "Deployment failed" $Red
        exit 1
    }
    
    Write-ColorOutput "`n✨ Full deployment completed successfully!" $Green
    Show-AccessInfo
    exit 0
}

# Default: Show help
Write-ColorOutput "Usage:" $Yellow
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Prepare   # Prepare and validate files" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Transfer  # Transfer files to server" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Deploy    # Deploy on server" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Full      # Run complete process" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Status    # Check service status" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Logs      # View service logs" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Stop       # Stop services" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Restart   # Restart & rebuild services" $Cyan
Write-ColorOutput "  .\scripts\deploy-edubad.ps1 -Restart -NoRebuild  # Restart without rebuild" $Cyan
Write-ColorOutput ""


