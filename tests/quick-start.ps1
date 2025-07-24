# Quick Start Script for Renewable Energy IoT Test Suite (PowerShell)
# This script provides easy commands to run the test suite on Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("docker", "local", "check", "help")]
    [string]$Option = "docker"
)

# Colors for output
$Green = "Green"
$Blue = "Blue"
$Yellow = "Yellow"

Write-Host "Renewable Energy IoT Monitoring System - Test Suite" -ForegroundColor $Blue
Write-Host "==================================================" -ForegroundColor $Blue

# Check if main services are running
function Check-Services {
    Write-Host "Checking if main services are running..." -ForegroundColor $Yellow
    
    # Check if docker-compose is running
    $services = docker-compose ps 2>$null
    if ($services -match "Up") {
        Write-Host "Main services are already running." -ForegroundColor $Green
    } else {
        Write-Host "Main services are not running. Starting them..." -ForegroundColor $Yellow
        docker-compose up -d
        
        Write-Host "Waiting for services to be ready..." -ForegroundColor $Yellow
        Start-Sleep -Seconds 30
    }
}

# Run tests with Docker
function Run-DockerTests {
    Write-Host "Running tests with Docker..." -ForegroundColor $Blue
    docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
}

# Run tests locally
function Run-LocalTests {
    Write-Host "Running tests locally..." -ForegroundColor $Blue
    
    # Check if Node.js is installed
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "Node.js is not installed. Please install Node.js 18+ to run tests locally." -ForegroundColor $Yellow
        exit 1
    }
    
    # Install dependencies
    if (-not (Test-Path "node_modules")) {
        Write-Host "Installing dependencies..." -ForegroundColor $Yellow
        npm install
    }
    
    # Run tests
    Write-Host "Running JavaScript tests..." -ForegroundColor $Blue
    npm test
}

# Show help
function Show-Help {
    Write-Host "Usage: .\quick-start.ps1 [option]" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $Blue
    Write-Host "  docker    - Run tests using Docker (recommended)" -ForegroundColor $Blue
    Write-Host "  local     - Run tests locally (requires Node.js)" -ForegroundColor $Blue
    Write-Host "  check     - Check if main services are running" -ForegroundColor $Blue
    Write-Host "  help      - Show this help message" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Blue
    Write-Host "  .\quick-start.ps1 docker  # Run tests with Docker" -ForegroundColor $Blue
    Write-Host "  .\quick-start.ps1 local   # Run tests locally" -ForegroundColor $Blue
    Write-Host "  .\quick-start.ps1 check   # Check service status" -ForegroundColor $Blue
}

# Main script logic
switch ($Option) {
    "docker" {
        Check-Services
        Run-DockerTests
    }
    "local" {
        Run-LocalTests
    }
    "check" {
        Check-Services
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "No option specified. Running with Docker (recommended)..." -ForegroundColor $Yellow
        Check-Services
        Run-DockerTests
    }
} 