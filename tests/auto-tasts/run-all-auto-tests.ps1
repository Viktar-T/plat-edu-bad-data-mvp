#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Comprehensive Automated Test Suite for Renewable Energy IoT Monitoring System

.DESCRIPTION
    This script runs all automated tests in the correct sequence, starting with
    prerequisites check and proceeding through all system components.

.PARAMETER SkipPrerequisites
    Skip the prerequisites check (not recommended)

.PARAMETER SkipIntegration
    Skip integration tests

.PARAMETER SkipPerformance
    Skip performance tests

.PARAMETER Parallel
    Run tests in parallel where possible

.PARAMETER OutputFormat
    Output format for test results (Console, JSON, XML)

.PARAMETER SaveResults
    Save test results to file

.PARAMETER ResultsPath
    Path to save test results (default: tests/results/)

.EXAMPLE
    .\run-all-auto-tests.ps1

.EXAMPLE
    .\run-all-auto-tests.ps1 -SkipPerformance -SaveResults

.NOTES
    Author: Renewable Energy IoT Monitoring System
    Version: 1.0
    Date: 2024
#>

param(
    [switch]$SkipPrerequisites,
    [switch]$SkipIntegration,
    [switch]$SkipPerformance,
    [switch]$Parallel,
    [ValidateSet("Console", "JSON", "XML")]
    [string]$OutputFormat = "Console",
    [switch]$SaveResults,
    [string]$ResultsPath = "tests\results"
)

# Test suite configuration
$TestSuite = @{
    Prerequisites = @{
        Script = "test-prerequisites.ps1"
        Description = "System Prerequisites Check"
        Required = $true
        Skip = $SkipPrerequisites
    }
    Integration = @{
        Script = "..\scripts\test-integration.ps1"
        Description = "Integration Tests"
        Required = $false
        Skip = $SkipIntegration
    }
    DataFlow = @{
        Script = "..\scripts\test-data-flow.ps1"
        Description = "Data Flow Tests"
        Required = $false
        Skip = $false
    }
    Performance = @{
        Script = "..\scripts\test-performance.ps1"
        Description = "Performance Tests"
        Required = $false
        Skip = $SkipPerformance
    }
}

# Test results tracking
$TestResults = @{
    StartTime = Get-Date
    EndTime = $null
    Tests = @()
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
}

# Ensure results directory exists
if ($SaveResults -and -not (Test-Path $ResultsPath)) {
    New-Item -ItemType Directory -Path $ResultsPath -Force | Out-Null
}

# Logging functions
function Write-TestSuiteLog {
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
        "HEADER" { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
}

function Add-TestResult {
    param(
        [string]$TestName,
        [string]$Description,
        [bool]$Passed,
        [string]$Message,
        [int]$ExitCode,
        [object]$Details = $null
    )
    
    $result = @{
        TestName = $TestName
        Description = $Description
        Passed = $Passed
        Message = $Message
        ExitCode = $ExitCode
        Details = $Details
        Timestamp = Get-Date
        Duration = $null  # Will be calculated later
    }
    
    $TestResults.Tests += $result
    $TestResults.TotalTests++
    
    if ($Passed) {
        $TestResults.PassedTests++
        Write-TestSuiteLog "✓ $TestName - PASSED" "SUCCESS"
    } else {
        $TestResults.FailedTests++
        Write-TestSuiteLog "✗ $TestName - FAILED: $Message" "ERROR"
    }
}

function Add-SkipResult {
    param(
        [string]$TestName,
        [string]$Description,
        [string]$Reason
    )
    
    $result = @{
        TestName = $TestName
        Description = $Description
        Passed = $null
        Message = "SKIPPED: $Reason"
        ExitCode = 0
        Details = $null
        Timestamp = Get-Date
        Duration = $null
    }
    
    $TestResults.Tests += $result
    $TestResults.TotalTests++
    $TestResults.SkippedTests++
    Write-TestSuiteLog "- $TestName - SKIPPED: $Reason" "WARN"
}

function Run-SingleTest {
    param(
        [string]$TestName,
        [string]$ScriptPath,
        [string]$Description
    )
    
    $startTime = Get-Date
    Write-TestSuiteLog "Starting: $Description" "INFO"
    
    try {
        # Check if script exists
        if (-not (Test-Path $ScriptPath)) {
            Add-TestResult -TestName $TestName -Description $Description -Passed $false -Message "Test script not found: $ScriptPath" -ExitCode 1
            return
        }
        
        # Run the test script
        $output = & $ScriptPath 2>&1
        $exitCode = $LASTEXITCODE
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        if ($exitCode -eq 0) {
            Add-TestResult -TestName $TestName -Description $Description -Passed $true -Message "Test completed successfully" -ExitCode $exitCode -Details @{ Duration = $duration; Output = $output }
        } else {
            Add-TestResult -TestName $TestName -Description $Description -Passed $false -Message "Test failed with exit code $exitCode" -ExitCode $exitCode -Details @{ Duration = $duration; Output = $output }
        }
        
    } catch {
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Add-TestResult -TestName $TestName -Description $Description -Passed $false -Message "Test execution failed: $($_.Exception.Message)" -ExitCode 1 -Details @{ Duration = $duration; Error = $_.Exception }
    }
}

function Save-TestResults {
    param([string]$FilePath)
    
    try {
        $TestResults.EndTime = Get-Date
        $TestResults.Duration = $TestResults.EndTime - $TestResults.StartTime
        
        # Calculate durations for individual tests
        foreach ($test in $TestResults.Tests) {
            if ($test.Details -and $test.Details.Duration) {
                $test.Duration = $test.Details.Duration
            }
        }
        
        $TestResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath -Encoding UTF8
        Write-TestSuiteLog "Test results saved to: $FilePath" "INFO"
    } catch {
        Write-TestSuiteLog "Failed to save test results: $($_.Exception.Message)" "ERROR"
    }
}

# Main test execution
function Start-TestSuite {
    Write-TestSuiteLog "=== Renewable Energy IoT Monitoring System - Automated Test Suite ===" "HEADER"
    Write-TestSuiteLog "Start Time: $($TestResults.StartTime)" "INFO"
    Write-TestSuiteLog "Configuration:" "INFO"
    Write-TestSuiteLog "  - Skip Prerequisites: $SkipPrerequisites" "INFO"
    Write-TestSuiteLog "  - Skip Integration: $SkipIntegration" "INFO"
    Write-TestSuiteLog "  - Skip Performance: $SkipPerformance" "INFO"
    Write-TestSuiteLog "  - Parallel Execution: $Parallel" "INFO"
    Write-TestSuiteLog "  - Output Format: $OutputFormat" "INFO"
    Write-TestSuiteLog "  - Save Results: $SaveResults" "INFO"
    Write-TestSuiteLog ""
    
    # Run tests in sequence (prerequisites must be first)
    foreach ($testKey in $TestSuite.Keys) {
        $test = $TestSuite[$testKey]
        
        if ($test.Skip) {
            Add-SkipResult -TestName $testKey -Description $test.Description -Reason "Skipped by parameter"
            continue
        }
        
        $scriptPath = Join-Path $PSScriptRoot $test.Script
        
        # Check if this is a required test that failed
        if ($test.Required -and $TestResults.FailedTests -gt 0) {
            Add-SkipResult -TestName $testKey -Description $test.Description -Reason "Prerequisites failed, skipping required test"
            continue
        }
        
        Run-SingleTest -TestName $testKey -ScriptPath $scriptPath -Description $test.Description
        
        # If this is a required test and it failed, stop execution
        if ($test.Required -and $TestResults.Tests[-1].Passed -eq $false) {
            Write-TestSuiteLog "Required test failed, stopping test suite execution" "ERROR"
            break
        }
    }
    
    # Generate summary
    $TestResults.EndTime = Get-Date
    $duration = $TestResults.EndTime - $TestResults.StartTime
    
    Write-TestSuiteLog ""
    Write-TestSuiteLog "=== Test Suite Summary ===" "HEADER"
    Write-TestSuiteLog "Total Tests: $($TestResults.TotalTests)" "INFO"
    Write-TestSuiteLog "Passed: $($TestResults.PassedTests)" "INFO"
    Write-TestSuiteLog "Failed: $($TestResults.FailedTests)" "INFO"
    Write-TestSuiteLog "Skipped: $($TestResults.SkippedTests)" "INFO"
    Write-TestSuiteLog "Duration: $($duration.TotalSeconds.ToString('F2')) seconds" "INFO"
    
    if ($TestResults.FailedTests -eq 0) {
        Write-TestSuiteLog "Overall Status: PASSED" "SUCCESS"
        $overallExitCode = 0
    } else {
        Write-TestSuiteLog "Overall Status: FAILED" "ERROR"
        Write-TestSuiteLog ""
        Write-TestSuiteLog "Failed Tests:" "ERROR"
        foreach ($test in $TestResults.Tests | Where-Object { $_.Passed -eq $false }) {
            Write-TestSuiteLog "  - $($test.TestName): $($test.Message)" "ERROR"
        }
        $overallExitCode = 1
    }
    
    # Save results if requested
    if ($SaveResults) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $resultsFile = Join-Path $ResultsPath "auto-test-suite-results-$timestamp.json"
        Save-TestResults -FilePath $resultsFile
    }
    
    return $overallExitCode
}

# Execute the test suite
try {
    $exitCode = Start-TestSuite
    exit $exitCode
} catch {
    Write-TestSuiteLog "Test suite execution failed: $($_.Exception.Message)" "ERROR"
    exit 1
} 