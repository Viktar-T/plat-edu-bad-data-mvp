# Master Test Runner - Run All End-to-End Tests

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host "  RENEWABLE ENERGY IoT MONITORING SYSTEM - END-TO-END TEST SUITE" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$testScripts = @(
    @{ name = "All Services Health Checks"; script = "test-all-services.ps1" }
    @{ name = "Network Connectivity"; script = "test-network-connectivity.ps1" }
    @{ name = "API to InfluxDB Connection"; script = "test-api-influxdb.ps1" }
    @{ name = "Complete Data Flow"; script = "test-complete-flow.ps1" }
    @{ name = "Performance Testing"; script = "test-performance.ps1" }
    @{ name = "Real-Time Updates"; script = "test-realtime-updates.ps1" }
)

$results = @()
$startTime = Get-Date

foreach ($test in $testScripts) {
    $testScriptPath = Join-Path $scriptPath $test.script
    
    if (Test-Path $testScriptPath) {
        Write-Host "`n" -NoNewline
        Write-Host ("─" * 80) -ForegroundColor Gray
        Write-Host "Running: $($test.name)" -ForegroundColor Yellow
        Write-Host ("─" * 80) -ForegroundColor Gray
        
        try {
            $testStartTime = Get-Date
            & $testScriptPath
            $testEndTime = Get-Date
            $duration = ($testEndTime - $testStartTime).TotalSeconds
            
            $results += @{
                Test = $test.name
                Status = "Completed"
                Duration = [math]::Round($duration, 2)
            }
        } catch {
            $results += @{
                Test = $test.name
                Status = "Failed"
                Error = $_.Exception.Message
            }
            Write-Host "`n❌ Test failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Test script not found: $($test.script)" -ForegroundColor Yellow
        $results += @{
            Test = $test.name
            Status = "Skipped"
            Reason = "Script not found"
        }
    }
}

$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

Write-Host "`n"
Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host "  TEST SUITE SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    $statusColor = switch ($result.Status) {
        "Completed" { "Green" }
        "Failed" { "Red" }
        "Skipped" { "Yellow" }
        default { "White" }
    }
    
    $statusIcon = switch ($result.Status) {
        "Completed" { "✅" }
        "Failed" { "❌" }
        "Skipped" { "⏭️ " }
        default { "❓" }
    }
    
    $durationText = if ($result.Duration) { " ($($result.Duration)s)" } else { "" }
    Write-Host "$statusIcon $($result.Test): $($result.Status)$durationText" -ForegroundColor $statusColor
}

Write-Host ""
Write-Host "Total Duration: $([math]::Round($totalDuration, 2)) seconds" -ForegroundColor Cyan
Write-Host ""

$completedCount = ($results | Where-Object { $_.Status -eq "Completed" }).Count
$failedCount = ($results | Where-Object { $_.Status -eq "Failed" }).Count
$totalCount = $results.Count

if ($failedCount -eq 0 -and $completedCount -eq $totalCount) {
    Write-Host "✨ All tests completed successfully! ($completedCount/$totalCount)`n" -ForegroundColor Green
    exit 0
} elseif ($failedCount -gt 0) {
    Write-Host "⚠️  Some tests failed ($failedCount/$totalCount failed)`n" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "ℹ️  Test suite completed with some skipped tests`n" -ForegroundColor Cyan
    exit 0
}

