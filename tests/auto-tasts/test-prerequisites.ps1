#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Automated Prerequisites Check for Renewable Energy IoT Monitoring System

.DESCRIPTION
    This script performs comprehensive automated testing of all system prerequisites
    including Docker services, network connectivity, service health endpoints,
    and environment configuration.

.PARAMETER Verbose
    Enable verbose output for detailed debugging information

.PARAMETER SkipDockerCheck
    Skip Docker service health checks (useful for CI/CD environments)

.PARAMETER SkipNetworkCheck
    Skip network connectivity tests

.PARAMETER SkipEnvironmentCheck
    Skip environment variable validation

.EXAMPLE
    .\test-prerequisites.ps1

.EXAMPLE
    .\test-prerequisites.ps1 -Verbose -SkipDockerCheck

.NOTES
    Author: Renewable Energy IoT Monitoring System
    Version: 1.0
    Date: 2024
#>

param(
    [switch]$Verbose,
    [switch]$SkipDockerCheck,
    [switch]$SkipNetworkCheck,
    [switch]$SkipEnvironmentCheck
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Test configuration
$TestConfig = @{
    Services = @(
        @{ Name = "mosquitto"; Port = 1883; HealthEndpoint = $null; WebSocketPort = 9001 }
        @{ Name = "influxdb"; Port = 8086; HealthEndpoint = "http://localhost:8086/health" }
        @{ Name = "node-red"; Port = 1880; HealthEndpoint = "http://localhost:1880" }
        @{ Name = "grafana"; Port = 3000; HealthEndpoint = "http://localhost:3000/api/health" }
    )
    RequiredNodeVersion = "18.0.0"
    RequiredNpmVersion = "8.0.0"
    TimeoutSeconds = 30
    RetryAttempts = 3
}

# Test results tracking
$TestResults = @{
    Passed = 0
    Failed = 0
    Skipped = 0
    Details = @()
    StartTime = Get-Date
    EndTime = $null
}

# Logging functions
function Write-TestLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
    
    if ($Verbose) {
        Write-Verbose $logMessage
    }
}

function Add-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message,
        [object]$Details = $null
    )
    
    $result = @{
        TestName = $TestName
        Passed = $Passed
        Message = $Message
        Details = $Details
        Timestamp = Get-Date
    }
    
    $TestResults.Details += $result
    
    if ($Passed) {
        $TestResults.Passed++
        Write-TestLog "✓ $TestName - PASSED" "SUCCESS"
    } else {
        $TestResults.Failed++
        Write-TestLog "✗ $TestName - FAILED: $Message" "ERROR"
    }
}

function Add-SkipResult {
    param(
        [string]$TestName,
        [string]$Reason
    )
    
    $result = @{
        TestName = $TestName
        Passed = $null
        Message = "SKIPPED: $Reason"
        Details = $null
        Timestamp = Get-Date
    }
    
    $TestResults.Details += $result
    $TestResults.Skipped++
    Write-TestLog "- $TestName - SKIPPED: $Reason" "WARN"
}

# Utility functions
function Test-CommandExists {
    param([string]$Command)
    
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-ServiceHealth {
    param(
        [string]$ServiceName,
        [string]$HealthEndpoint,
        [int]$TimeoutSeconds = 30
    )
    
    if (-not $HealthEndpoint) {
        return $true  # Skip if no health endpoint defined
    }
    
    try {
        $response = Invoke-WebRequest -Uri $HealthEndpoint -UseBasicParsing -TimeoutSec $TimeoutSeconds
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Test-PortConnectivity {
    param(
        [string]$Host = "localhost",
        [int]$Port,
        [int]$TimeoutSeconds = 10
    )
    
    try {
        $connection = Test-NetConnection -ComputerName $Host -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
        return $connection.TcpTestSucceeded
    } catch {
        return $false
    }
}

function Test-DockerServiceStatus {
    param([string]$ServiceName)
    
    try {
        $status = docker-compose ps --format json | ConvertFrom-Json | Where-Object { $_.Service -eq $ServiceName }
        return $status.Status -like "*healthy*" -or $status.Status -like "*Up*"
    } catch {
        return $false
    }
}

function Test-NodeVersion {
    param([string]$RequiredVersion)
    
    try {
        $currentVersion = node --version
        $currentVersion = $currentVersion.TrimStart('v')
        
        $current = [Version]$currentVersion
        $required = [Version]$RequiredVersion
        
        return $current -ge $required
    } catch {
        return $false
    }
}

function Test-NpmVersion {
    param([string]$RequiredVersion)
    
    try {
        $currentVersion = npm --version
        $current = [Version]$currentVersion
        $required = [Version]$RequiredVersion
        
        return $current -ge $required
    } catch {
        return $false
    }
}

function Test-EnvironmentVariables {
    $requiredVars = @(
        "INFLUXDB_TOKEN",
        "INFLUXDB_ORG",
        "INFLUXDB_BUCKET",
        "GRAFANA_ADMIN_PASSWORD"
    )
    
    $missingVars = @()
    
    foreach ($var in $requiredVars) {
        if (-not (Get-Variable -Name $var -ErrorAction SilentlyContinue) -and 
            -not (Get-ChildItem -Path "env:$var" -ErrorAction SilentlyContinue)) {
            $missingVars += $var
        }
    }
    
    return @{
        Passed = $missingVars.Count -eq 0
        MissingVars = $missingVars
    }
}

function Test-MqttDependencies {
    $mqttTestPath = "tests\scripts\test-mqtt.ps1"
    
    if (-not (Test-Path $mqttTestPath)) {
        return @{ Passed = $false; Message = "MQTT test script not found" }
    }
    
    try {
        # Test basic MQTT connectivity
        $result = & $mqttTestPath -PublishTest -Topic "test/prerequisites/auto" -Message "automated_test" -ErrorAction Stop
        return @{ Passed = $true; Message = "MQTT connectivity verified" }
    } catch {
        return @{ Passed = $false; Message = "MQTT connectivity failed: $($_.Exception.Message)" }
    }
}

# Main test execution
function Start-PrerequisitesTest {
    Write-TestLog "Starting Automated Prerequisites Check" "INFO"
    Write-TestLog "Test Configuration:" "INFO"
    Write-TestLog "  - Skip Docker Check: $SkipDockerCheck" "INFO"
    Write-TestLog "  - Skip Network Check: $SkipNetworkCheck" "INFO"
    Write-TestLog "  - Skip Environment Check: $SkipEnvironmentCheck" "INFO"
    Write-TestLog "  - Verbose Output: $Verbose" "INFO"
    Write-TestLog ""

    # Test 1: Check Docker and Docker Compose availability
    Write-TestLog "=== Testing Docker Environment ===" "INFO"
    
    if (-not $SkipDockerCheck) {
        if (Test-CommandExists "docker") {
            Add-TestResult "Docker Command Available" $true "Docker command is available"
        } else {
            Add-TestResult "Docker Command Available" $false "Docker command not found"
        }
        
        if (Test-CommandExists "docker-compose") {
            Add-TestResult "Docker Compose Available" $true "Docker Compose command is available"
        } else {
            Add-TestResult "Docker Compose Available" $false "Docker Compose command not found"
        }
    } else {
        Add-SkipResult "Docker Command Available" "Skipped by parameter"
        Add-SkipResult "Docker Compose Available" "Skipped by parameter"
    }

    # Test 2: Check Docker services status
    if (-not $SkipDockerCheck) {
        Write-TestLog "=== Testing Docker Services Status ===" "INFO"
        
        foreach ($service in $TestConfig.Services) {
            $serviceName = $service.Name
            $isHealthy = Test-DockerServiceStatus -ServiceName $serviceName
            
            if ($isHealthy) {
                Add-TestResult "Docker Service: $serviceName" $true "Service is healthy and running"
            } else {
                Add-TestResult "Docker Service: $serviceName" $false "Service is not healthy or not running"
            }
        }
    } else {
        Add-SkipResult "Docker Services Status" "Skipped by parameter"
    }

    # Test 3: Check network connectivity
    if (-not $SkipNetworkCheck) {
        Write-TestLog "=== Testing Network Connectivity ===" "INFO"
        
        foreach ($service in $TestConfig.Services) {
            $serviceName = $service.Name
            $port = $service.Port
            
            $isPortOpen = Test-PortConnectivity -Port $port
            
            if ($isPortOpen) {
                Add-TestResult "Network Port: $serviceName ($port)" $true "Port is accessible"
            } else {
                Add-TestResult "Network Port: $serviceName ($port)" $false "Port is not accessible"
            }
            
            # Test WebSocket port for MQTT if applicable
            if ($service.WebSocketPort) {
                $wsPortOpen = Test-PortConnectivity -Port $service.WebSocketPort
                if ($wsPortOpen) {
                    Add-TestResult "Network Port: $serviceName WebSocket ($($service.WebSocketPort))" $true "WebSocket port is accessible"
                } else {
                    Add-TestResult "Network Port: $serviceName WebSocket ($($service.WebSocketPort))" $false "WebSocket port is not accessible"
                }
            }
        }
    } else {
        Add-SkipResult "Network Connectivity" "Skipped by parameter"
    }

    # Test 4: Check service health endpoints
    Write-TestLog "=== Testing Service Health Endpoints ===" "INFO"
    
    foreach ($service in $TestConfig.Services) {
        $serviceName = $service.Name
        $healthEndpoint = $service.HealthEndpoint
        
        if ($healthEndpoint) {
            $isHealthy = Test-ServiceHealth -ServiceName $serviceName -HealthEndpoint $healthEndpoint
            
            if ($isHealthy) {
                Add-TestResult "Health Endpoint: $serviceName" $true "Health endpoint is responding"
            } else {
                Add-TestResult "Health Endpoint: $serviceName" $false "Health endpoint is not responding"
            }
        } else {
            Add-SkipResult "Health Endpoint: $serviceName" "No health endpoint defined"
        }
    }

    # Test 5: Check Node.js and npm
    Write-TestLog "=== Testing Node.js Environment ===" "INFO"
    
    if (Test-CommandExists "node") {
        $nodeVersionOk = Test-NodeVersion -RequiredVersion $TestConfig.RequiredNodeVersion
        if ($nodeVersionOk) {
            Add-TestResult "Node.js Version" $true "Node.js version meets requirements"
        } else {
            Add-TestResult "Node.js Version" $false "Node.js version does not meet requirements"
        }
    } else {
        Add-TestResult "Node.js Installation" $false "Node.js is not installed"
    }
    
    if (Test-CommandExists "npm") {
        $npmVersionOk = Test-NpmVersion -RequiredVersion $TestConfig.RequiredNpmVersion
        if ($npmVersionOk) {
            Add-TestResult "NPM Version" $true "NPM version meets requirements"
        } else {
            Add-TestResult "NPM Version" $false "NPM version does not meet requirements"
        }
    } else {
        Add-TestResult "NPM Installation" $false "NPM is not installed"
    }

    # Test 6: Check environment variables
    if (-not $SkipEnvironmentCheck) {
        Write-TestLog "=== Testing Environment Configuration ===" "INFO"
        
        $envTest = Test-EnvironmentVariables
        if ($envTest.Passed) {
            Add-TestResult "Environment Variables" $true "All required environment variables are set"
        } else {
            Add-TestResult "Environment Variables" $false "Missing environment variables: $($envTest.MissingVars -join ', ')"
        }
    } else {
        Add-SkipResult "Environment Variables" "Skipped by parameter"
    }

    # Test 7: Check MQTT dependencies and connectivity
    Write-TestLog "=== Testing MQTT Dependencies ===" "INFO"
    
    $mqttTest = Test-MqttDependencies
    if ($mqttTest.Passed) {
        Add-TestResult "MQTT Dependencies" $true $mqttTest.Message
    } else {
        Add-TestResult "MQTT Dependencies" $false $mqttTest.Message
    }

    # Test 8: Check PowerShell execution policy
    Write-TestLog "=== Testing PowerShell Configuration ===" "INFO"
    
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Add-TestResult "PowerShell Execution Policy" $false "Execution policy is restricted. Set to RemoteSigned or Unrestricted"
    } else {
        Add-TestResult "PowerShell Execution Policy" $true "Execution policy allows script execution: $executionPolicy"
    }

    # Generate test summary
    $TestResults.EndTime = Get-Date
    $duration = $TestResults.EndTime - $TestResults.StartTime
    
    Write-TestLog ""
    Write-TestLog "=== Test Summary ===" "INFO"
    Write-TestLog "Total Tests: $($TestResults.Passed + $TestResults.Failed + $TestResults.Skipped)" "INFO"
    Write-TestLog "Passed: $($TestResults.Passed)" "INFO"
    Write-TestLog "Failed: $($TestResults.Failed)" "INFO"
    Write-TestLog "Skipped: $($TestResults.Skipped)" "INFO"
    Write-TestLog "Duration: $($duration.TotalSeconds.ToString('F2')) seconds" "INFO"
    
    if ($TestResults.Failed -eq 0) {
        Write-TestLog "Overall Status: PASSED" "SUCCESS"
        exit 0
    } else {
        Write-TestLog "Overall Status: FAILED" "ERROR"
        Write-TestLog ""
        Write-TestLog "Failed Tests:" "ERROR"
        foreach ($result in $TestResults.Details | Where-Object { $_.Passed -eq $false }) {
            Write-TestLog "  - $($result.TestName): $($result.Message)" "ERROR"
        }
        exit 1
    }
}

# Execute the test
try {
    Start-PrerequisitesTest
} catch {
    Write-TestLog "Test execution failed: $($_.Exception.Message)" "ERROR"
    exit 1
} 