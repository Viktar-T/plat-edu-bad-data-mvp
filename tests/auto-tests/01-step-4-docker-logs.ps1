#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Automated script to check Docker service logs for errors.
    
.DESCRIPTION
    This script checks the logs of all IoT monitoring system services (Mosquitto, InfluxDB, Node-RED, Grafana)
    for any error messages or startup issues. It's based on Step 4 from the manual prerequisites test.
    
.PARAMETER LogLines
    Number of log lines to check for each service. Default is 20.
    
.EXAMPLE
    .\01-step-4-docker-logs.ps1
    
.EXAMPLE
    .\01-step-4-docker-logs.ps1 -LogLines 50
    
.NOTES
    Author: IoT Monitoring System Team
    Version: 1.0
    Date: 2024-01-15
#>

param(
    [int]$LogLines = 20
)

# Set error action preference
$ErrorActionPreference = "Continue"

Write-Host "Starting Docker Logs Check (Step 4 from Prerequisites Test)" -ForegroundColor Magenta
Write-Host "===============================================================" -ForegroundColor Magenta

# Check if Docker Compose is available
try {
    $null = docker-compose --version
    Write-Host "Docker Compose is available" -ForegroundColor Green
} catch {
    Write-Host "Docker Compose is not available. Please install Docker and Docker Compose." -ForegroundColor Red
    exit 1
}

# Check if services are running
try {
    $services = docker-compose ps --format json | ConvertFrom-Json
    $runningServices = $services | Where-Object { $_.State -eq "Up" }
    
    if ($runningServices.Count -eq 0) {
        Write-Host "No services are currently running. Please start services with: docker-compose up -d" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Found $($runningServices.Count) running service(s)" -ForegroundColor Green
} catch {
    Write-Host "Error checking service status: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nChecking Service Logs..." -ForegroundColor Cyan

# Initialize results
$allServicesHealthy = $true
$results = @{}

# Check each service
$servicesToCheck = @(
    @{Name="mosquitto"; Display="MQTT Broker (Mosquitto)"},
    @{Name="influxdb"; Display="InfluxDB Database"},
    @{Name="node-red"; Display="Node-RED Processing"},
    @{Name="grafana"; Display="Grafana Visualization"}
)

foreach ($service in $servicesToCheck) {
    Write-Host "`nChecking $($service.Display) logs..." -ForegroundColor Cyan
    Write-Host "Service: $($service.Name)" -ForegroundColor Gray
    
    try {
        $logs = docker-compose logs $service.Name --tail=$LogLines
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Logs retrieved successfully" -ForegroundColor Green
            
            # Check for error patterns
            $errorPatterns = @("error", "Error", "ERROR", "failed", "Failed", "FAILED", "exception", "Exception", "EXCEPTION", "fatal", "Fatal", "FATAL", "panic", "Panic", "PANIC")
            $errorLines = @()
            
            foreach ($line in $logs) {
                foreach ($pattern in $errorPatterns) {
                    if ($line -match $pattern) {
                        $errorLines += $line
                        break
                    }
                }
            }
            
            if ($errorLines.Count -gt 0) {
                Write-Host "Found $($errorLines.Count) potential error(s):" -ForegroundColor Yellow
                foreach ($errorLine in $errorLines) {
                    Write-Host "   $errorLine" -ForegroundColor Yellow
                }
                $results[$service.Display] = $false
                $allServicesHealthy = $false
            } else {
                Write-Host "No errors found" -ForegroundColor Green
                $results[$service.Display] = $true
            }
        } else {
            Write-Host "Failed to retrieve logs" -ForegroundColor Red
            $results[$service.Display] = $false
            $allServicesHealthy = $false
        }
    } catch {
        Write-Host "Error checking logs: $($_.Exception.Message)" -ForegroundColor Red
        $results[$service.Display] = $false
        $allServicesHealthy = $false
    }
}

# Summary
Write-Host "`nTest Summary" -ForegroundColor Magenta
Write-Host "===============" -ForegroundColor Magenta

$passedServices = 0
$failedServices = 0

foreach ($service in $results.Keys) {
    if ($results[$service]) {
        Write-Host "$service - PASSED" -ForegroundColor Green
        $passedServices++
    } else {
        Write-Host "$service - FAILED" -ForegroundColor Red
        $failedServices++
    }
}

Write-Host "`nOverall Results:" -ForegroundColor Magenta
Write-Host "   Passed: $passedServices service(s)" -ForegroundColor Green
Write-Host "   Failed: $failedServices service(s)" -ForegroundColor $(if ($failedServices -gt 0) { "Red" } else { "Green" })

if ($allServicesHealthy) {
    Write-Host "`nAll services are healthy! No errors found in logs." -ForegroundColor Green
    Write-Host "You can proceed to the next test step." -ForegroundColor Gray
    exit 0
} else {
    Write-Host "`nSome services have issues. Please check the logs above." -ForegroundColor Yellow
    Write-Host "Consider restarting services: docker-compose restart" -ForegroundColor Gray
    exit 1
} 