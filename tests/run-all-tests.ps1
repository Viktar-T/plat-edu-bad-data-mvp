# Comprehensive Test Runner Script
# Runs all InfluxDB 2.x testing scripts and generates a report

param(
    [string]$LogFile = "tests/logs/test-results/comprehensive-test-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
)

# Create log directory if it doesn't exist
$LogDir = Split-Path $LogFile -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Initialize logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

# Test results tracking
$TestResults = @{
    "Prerequisites" = $false
    "Health Check" = $false
    "Data Flow" = $false
    "Flux Queries" = $false
    "Integration" = $false
    "Performance" = $false
}

Write-Log "=== Starting Comprehensive InfluxDB 2.x Testing ==="
Write-Log "Test execution started at: $(Get-Date)"

# Test 1: Prerequisites Check
Write-Log "Running Prerequisites Check..."
try {
    $PrerequisitesResult = & "tests/auto-tasts/test-prerequisites.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Prerequisites check passed" "SUCCESS"
        $TestResults["Prerequisites"] = $true
    } else {
        Write-Log "✗ Prerequisites check failed" "ERROR"
        Write-Log "Skipping remaining tests due to prerequisites failure" "WARNING"
        # Skip remaining tests if prerequisites fail
        goto Summary
    }
} catch {
    Write-Log "✗ Prerequisites check execution failed: $($_.Exception.Message)" "ERROR"
    Write-Log "Skipping remaining tests due to prerequisites failure" "WARNING"
    goto Summary
}

# Test 2: Health Check
Write-Log "Running Health Check Tests..."
try {
    $HealthResult = & "tests/scripts/test-influxdb-health.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Health check tests passed" "SUCCESS"
        $TestResults["Health Check"] = $true
    } else {
        Write-Log "✗ Health check tests failed" "ERROR"
    }
} catch {
    Write-Log "✗ Health check test execution failed: $($_.Exception.Message)" "ERROR"
}

# Test 2: Data Flow
Write-Log "Running Data Flow Tests..."
try {
    $DataFlowResult = & "tests/scripts/test-data-flow.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Data flow tests passed" "SUCCESS"
        $TestResults["Data Flow"] = $true
    } else {
        Write-Log "✗ Data flow tests failed" "ERROR"
    }
} catch {
    Write-Log "✗ Data flow test execution failed: $($_.Exception.Message)" "ERROR"
}

# Test 3: Flux Queries
Write-Log "Running Flux Query Tests..."
try {
    $FluxResult = & "tests/scripts/test-flux-queries.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Flux query tests passed" "SUCCESS"
        $TestResults["Flux Queries"] = $true
    } else {
        Write-Log "✗ Flux query tests failed" "ERROR"
    }
} catch {
    Write-Log "✗ Flux query test execution failed: $($_.Exception.Message)" "ERROR"
}

# Test 4: Integration
Write-Log "Running Integration Tests..."
try {
    $IntegrationResult = & "tests/scripts/test-integration.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Integration tests passed" "SUCCESS"
        $TestResults["Integration"] = $true
    } else {
        Write-Log "✗ Integration tests failed" "ERROR"
    }
} catch {
    Write-Log "✗ Integration test execution failed: $($_.Exception.Message)" "ERROR"
}

# Test 5: Performance
Write-Log "Running Performance Tests..."
try {
    $PerformanceResult = & "tests/scripts/test-performance.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Performance tests passed" "SUCCESS"
        $TestResults["Performance"] = $true
    } else {
        Write-Log "✗ Performance tests failed" "ERROR"
    }
} catch {
    Write-Log "✗ Performance test execution failed: $($_.Exception.Message)" "ERROR"
}

# Comprehensive Summary Report
Summary:
Write-Log "=== Comprehensive Test Summary ==="
$PassedTests = ($TestResults.Values | Where-Object { $_ -eq $true }).Count
$TotalTests = $TestResults.Count
$PassRate = [math]::Round(($PassedTests / $TotalTests) * 100, 2)

Write-Log "Test execution completed at: $(Get-Date)"
Write-Log ""

foreach ($Test in $TestResults.GetEnumerator()) {
    $Status = if ($Test.Value) { "PASS" } else { "FAIL" }
    Write-Log "$($Test.Key): $Status"
}

Write-Log ""
Write-Log "Overall Statistics:"
Write-Log "- Total Tests: $TotalTests"
Write-Log "- Passed Tests: $PassedTests"
Write-Log "- Failed Tests: $($TotalTests - $PassedTests)"
Write-Log "- Pass Rate: ${PassRate}%"

# Generate detailed report
$ReportFile = "tests/logs/test-results/detailed-report-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').md"
$ReportContent = @"
# InfluxDB 2.x Comprehensive Test Report

## Test Execution Summary
- **Execution Date**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **Total Tests**: $TotalTests
- **Passed Tests**: $PassedTests
- **Failed Tests**: $($TotalTests - $PassedTests)
- **Pass Rate**: ${PassRate}%

## Test Results

| Test Category | Status | Details |
|---------------|--------|---------|
"@

foreach ($Test in $TestResults.GetEnumerator()) {
    $Status = if ($Test.Value) { "✅ PASS" } else { "❌ FAIL" }
    $ReportContent += "`n| $($Test.Key) | $Status | $(if ($Test.Value) { 'All tests passed' } else { 'Some tests failed' }) |"
}

$ReportContent += @"

## System Configuration
- **InfluxDB URL**: http://localhost:8086
- **Organization**: renewable_energy_org
- **Bucket**: renewable_energy
- **Token**: renewable_energy_admin_token_123
- **Query Language**: Flux

## Recommendations

"@

if ($PassRate -eq 100) {
    $ReportContent += @"
✅ **All tests passed successfully!**
- The InfluxDB 2.x system is working correctly
- All components are properly integrated
- Performance meets expected benchmarks
- System is ready for production use
"@
} elseif ($PassRate -ge 80) {
    $ReportContent += @"
⚠️ **Most tests passed with some issues**
- System is mostly functional
- Review failed tests for specific issues
- Consider addressing performance concerns
- System may need minor adjustments
"@
} else {
    $ReportContent += @"
❌ **Multiple test failures detected**
- System requires immediate attention
- Review all failed test categories
- Check system configuration and connectivity
- Address issues before production use
"@
}

$ReportContent += @"

## Next Steps
1. Review individual test logs for detailed information
2. Address any failed tests
3. Re-run tests after fixes
4. Monitor system performance in production

---
*Report generated by InfluxDB 2.x Testing Suite*
"@

# Save detailed report
$ReportContent | Out-File -FilePath $ReportFile -Encoding UTF8

Write-Log ""
Write-Log "Detailed report saved to: $ReportFile"

# Final result
if ($PassRate -eq 100) {
    Write-Log "🎉 All tests passed! InfluxDB 2.x system is fully operational." "SUCCESS"
    exit 0
} elseif ($PassRate -ge 80) {
    Write-Log "⚠️ Most tests passed. System is mostly operational but needs attention." "WARNING"
    exit 1
} else {
    Write-Log "❌ Multiple test failures. System requires immediate attention." "ERROR"
    exit 1
} 