# =============================================================================
# Local Development Script
# Renewable Energy IoT Monitoring System
# =============================================================================
# This script sets up and starts the local development environment
# Uses standard ports for easy development and testing
# =============================================================================

param(
    [switch]$Stop,
    [switch]$Restart,
    [switch]$Logs,
    [switch]$Status
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

function Test-Docker {
    try {
        docker version | Out-Null
        return $true
    } catch {
        return $false
    }
}

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
    Write-ColorOutput "⚠️  Warning: Could not detect docker compose version, using 'docker compose' as default" $Yellow
    return "docker compose"
}

$dockerComposeCmd = Get-DockerComposeCmd

function Test-RequiredFiles {
    $requiredFiles = @(
        "docker-compose.local.yml",
        ".env.local"
    )

    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }

    return $missingFiles
}

function Setup-Environment {
    Write-ColorOutput "Setting up local development environment..." $Green

    # Ensure .env.local exists
    if (-not (Test-Path ".env.local")) {
        if (Test-Path "env.example") {
            Write-ColorOutput "Creating .env.local from env.example..." $Yellow
            Copy-Item "env.example" ".env.local"
            Write-ColorOutput "Created .env.local" $Green
        } else {
            Write-ColorOutput "env.example not found!" $Red
            exit 1
        }
    }

    # Copy .env.local to .env for docker-compose
    Write-ColorOutput "Configuring environment variables (.env)..." $Yellow
    Copy-Item ".env.local" ".env" -Force
    Write-ColorOutput "Environment configured" $Green
}

function Start-Services {
    Write-ColorOutput "Starting local development services..." $Green

    # Stop any existing containers
    Write-ColorOutput "Stopping any existing containers..." $Yellow
    Invoke-Expression "$dockerComposeCmd -f docker-compose.local.yml down" 2>$null

    # Start services
    Write-ColorOutput "Starting services with docker-compose.local.yml..." $Yellow
    Invoke-Expression "$dockerComposeCmd -f docker-compose.local.yml up -d"

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Services started successfully" $Green
    } else {
        Write-ColorOutput "Failed to start services" $Red
        exit 1
    }
}

function Stop-Services {
    Write-ColorOutput "Stopping local development services..." $Green
    Invoke-Expression "$dockerComposeCmd -f docker-compose.local.yml down"
    Write-ColorOutput "Services stopped" $Green
}

function Show-Status {
    Write-ColorOutput "Checking service status..." $Green
    Invoke-Expression "$dockerComposeCmd -f docker-compose.local.yml ps"
}

function Show-Logs {
    Write-ColorOutput "Showing service logs (Ctrl+C to stop)..." $Green
    Invoke-Expression "$dockerComposeCmd -f docker-compose.local.yml logs -f"
}

function Show-AccessInfo {
    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Local Development Access URLs:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  Grafana Dashboard:    http://localhost:3000" $Yellow
    Write-ColorOutput "  Node-RED Editor:      http://localhost:1880" $Yellow
    Write-ColorOutput "  InfluxDB Admin:       http://localhost:8086" $Yellow
    Write-ColorOutput "  Express Backend API:  http://localhost:3001" $Yellow
    Write-ColorOutput "  React Frontend:       http://localhost:3002" $Yellow
    Write-ColorOutput "  MQTT Broker:          localhost:1883" $Yellow
    Write-ColorOutput "  MQTT WebSocket:       localhost:9001" $Yellow
    Write-ColorOutput "================================================" $Cyan

    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Default Credentials:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  Grafana:     admin / admin" $Yellow
    Write-ColorOutput "  Node-RED:    admin / adminpassword" $Yellow
    Write-ColorOutput "  InfluxDB:    admin / admin_password_123" $Yellow
    Write-ColorOutput "  MQTT:        admin / admin_password_456" $Yellow
    Write-ColorOutput "================================================" $Cyan

    Write-ColorOutput "" $Cyan
    Write-ColorOutput "Tips:" $Cyan
    Write-ColorOutput "================================================" $Cyan
    Write-ColorOutput "  - Use '.\\scripts\\dev-local.ps1 -Logs' to view logs" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\dev-local.ps1 -Status' to check status" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\dev-local.ps1 -Stop' to stop services" $Yellow
    Write-ColorOutput "  - Use '.\\scripts\\dev-local.ps1 -Restart' to restart services" $Yellow
    Write-ColorOutput "================================================" $Cyan
}

# Main script logic
Write-ColorOutput "Renewable Energy IoT - Local Development Setup" $Green
Write-ColorOutput "================================================" $Green
Write-ColorOutput "Using: $dockerComposeCmd" $Cyan
Write-ColorOutput ""

# Check if Docker is running
if (-not (Test-Docker)) {
    Write-ColorOutput "Docker is not running. Please start Docker Desktop first." $Red
    exit 1
}

# Check for required files
$missingFiles = Test-RequiredFiles
if ($missingFiles.Count -gt 0) {
    Write-ColorOutput "Missing required files:" $Red
    foreach ($file in $missingFiles) {
        Write-ColorOutput "  - $file" $Red
    }
    exit 1
}

# Handle switches
if ($Stop) {
    Stop-Services
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

if ($Restart) {
    Write-ColorOutput "Restarting services..." $Green
    Stop-Services
    Start-Sleep -Seconds 2
    Start-Services
    Show-AccessInfo
    exit 0
}

# Default action: start services
Setup-Environment
Start-Services

Write-ColorOutput "Waiting for services to initialize..." $Yellow
Start-Sleep -Seconds 10

Show-Status
Show-AccessInfo

Write-ColorOutput "Local development environment is ready." $Green
