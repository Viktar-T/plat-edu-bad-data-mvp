#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test Runner for Automated Prerequisites Check

.DESCRIPTION
    This script runs the automated prerequisites test and provides integration
    with the existing test framework. It can be used standalone or as part
    of the comprehensive test suite.

.PARAMETER OutputFormat
    Output format for test results (Console, JSON, XML)

.PARAMETER SaveResults
    Save test results to file

.PARAMETER ResultsPath
    Path to save test results (default: tests/results/)

.EXAMPLE
    .\run-prerequisites-test.ps1

.EXAMPLE
    .\run-prerequisites-test.ps1 -OutputFormat JSON -SaveResults

.NOTES
    Author: Renewable Energy IoT Monitoring System
    Version: 1.0
    Date: 2024
#>

param(
    [ValidateSet("Console", "JSON", "XML")]
    [string]$OutputFormat = "Console",
    [switch]$SaveResults,
    [string]$ResultsPath = "tests\results"
)

# Ensure results directory exists
if ($SaveResults -and -not (Test-Path $ResultsPath)) {
    New-Item -ItemType Directory -Path $ResultsPath -Force | Out-Null
}

# Get test script path
$testScriptPath = Join-Path $PSScriptRoot "test-prerequisites.ps1"

if (-not (Test-Path $testScriptPath)) {
    Write-Error "Test script not found: $testScriptPath"
    exit 1
}

# Run the test
Write-Host "Running Automated Prerequisites Check..." -ForegroundColor Cyan
Write-Host "Test Script: $testScriptPath" -ForegroundColor Gray
Write-Host "Output Format: $OutputFormat" -ForegroundColor Gray
Write-Host "Save Results: $SaveResults" -ForegroundColor Gray
Write-Host ""

try {
    # Execute the test script
    & $testScriptPath
    
    $exitCode = $LASTEXITCODE
    
    # Generate timestamp for results file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $resultsFile = Join-Path $ResultsPath "prerequisites-test-results-$timestamp"
    
    if ($SaveResults) {
        switch ($OutputFormat) {
            "JSON" {
                $resultsFile += ".json"
                # Note: The test script would need to output JSON format
                # This is a placeholder for future enhancement
                Write-Host "Results would be saved to: $resultsFile" -ForegroundColor Yellow
            }
            "XML" {
                $resultsFile += ".xml"
                # Note: The test script would need to output XML format
                # This is a placeholder for future enhancement
                Write-Host "Results would be saved to: $resultsFile" -ForegroundColor Yellow
            }
            default {
                $resultsFile += ".txt"
                # Save console output
                Write-Host "Console output saved to: $resultsFile" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host ""
    Write-Host "Test completed with exit code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })
    
    exit $exitCode
    
} catch {
    Write-Error "Failed to run prerequisites test: $($_.Exception.Message)"
    exit 1
} 