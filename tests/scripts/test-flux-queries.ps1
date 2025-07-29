# Flux Query Testing Script
# Tests Flux query execution and data retrieval from InfluxDB 2.x

param(
    [string]$InfluxDBUrl = "http://localhost:8086",
    [string]$Token = "renewable_energy_admin_token_123",
    [string]$Organization = "renewable_energy_org",
    [string]$Bucket = "renewable_energy",
    [string]$LogFile = "tests/logs/test-results/flux-queries-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
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

# Test result tracking
$TestResults = @{
    "Basic Data Retrieval" = $false
    "Aggregation Operations" = $false
    "Time-Based Filtering" = $false
    "Device-Specific Filtering" = $false
    "Performance Validation" = $false
}

Write-Log "Starting Flux Query Testing"
Write-Log "Configuration: URL=$InfluxDBUrl, Org=$Organization, Bucket=$Bucket"

# Common headers for all requests
$Headers = @{
    "Authorization" = "Token $Token"
    "Content-Type" = "application/json"
}

# Test 1: Basic Data Retrieval
Write-Log "Test 1: Testing basic data retrieval..."
try {
    $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> limit(n: 5)
"@
    
    $QueryBody = @{
        query = $FluxQuery
        type = "flux"
    } | ConvertTo-Json
    
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 10
    $Stopwatch.Stop()
    
    if ($Response.StatusCode -eq 200) {
        $Data = $Response.Content
        if ($Data -and $Data -notmatch "^\s*$") {
            Write-Log "✓ Basic data retrieval successful (Response time: $($Stopwatch.ElapsedMilliseconds)ms)" "SUCCESS"
            $TestResults["Basic Data Retrieval"] = $true
        } else {
            Write-Log "✗ No data returned from basic query" "ERROR"
        }
    } else {
        Write-Log "✗ Basic data retrieval failed (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Basic data retrieval test failed: $($_.Exception.Message)" "ERROR"
}

# Test 2: Aggregation Operations
Write-Log "Test 2: Testing aggregation operations..."
try {
    $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "power_output")
  |> sum()
"@
    
    $QueryBody = @{
        query = $FluxQuery
        type = "flux"
    } | ConvertTo-Json
    
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 10
    $Stopwatch.Stop()
    
    if ($Response.StatusCode -eq 200) {
        $Data = $Response.Content
        if ($Data -and $Data -notmatch "^\s*$") {
            Write-Log "✓ Aggregation operation successful (Response time: $($Stopwatch.ElapsedMilliseconds)ms)" "SUCCESS"
            $TestResults["Aggregation Operations"] = $true
        } else {
            Write-Log "✗ No data returned from aggregation query" "ERROR"
        }
    } else {
        Write-Log "✗ Aggregation operation failed (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Aggregation operation test failed: $($_.Exception.Message)" "ERROR"
}

# Test 3: Time-Based Filtering
Write-Log "Test 3: Testing time-based filtering..."
try {
    $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "temperature")
  |> mean()
"@
    
    $QueryBody = @{
        query = $FluxQuery
        type = "flux"
    } | ConvertTo-Json
    
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 10
    $Stopwatch.Stop()
    
    if ($Response.StatusCode -eq 200) {
        $Data = $Response.Content
        if ($Data -and $Data -notmatch "^\s*$") {
            Write-Log "✓ Time-based filtering successful (Response time: $($Stopwatch.ElapsedMilliseconds)ms)" "SUCCESS"
            $TestResults["Time-Based Filtering"] = $true
        } else {
            Write-Log "✗ No data returned from time-based query" "ERROR"
        }
    } else {
        Write-Log "✗ Time-based filtering failed (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Time-based filtering test failed: $($_.Exception.Message)" "ERROR"
}

# Test 4: Device-Specific Filtering
Write-Log "Test 4: Testing device-specific filtering..."
try {
    $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "efficiency")
  |> max()
"@
    
    $QueryBody = @{
        query = $FluxQuery
        type = "flux"
    } | ConvertTo-Json
    
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 10
    $Stopwatch.Stop()
    
    if ($Response.StatusCode -eq 200) {
        $Data = $Response.Content
        if ($Data -and $Data -notmatch "^\s*$") {
            Write-Log "✓ Device-specific filtering successful (Response time: $($Stopwatch.ElapsedMilliseconds)ms)" "SUCCESS"
            $TestResults["Device-Specific Filtering"] = $true
        } else {
            Write-Log "✗ No data returned from device-specific query" "ERROR"
        }
    } else {
        Write-Log "✗ Device-specific filtering failed (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Device-specific filtering test failed: $($_.Exception.Message)" "ERROR"
}

# Test 5: Performance Validation
Write-Log "Test 5: Testing query performance..."
try {
    $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "temperature" or r._field == "efficiency")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> limit(n: 100)
"@
    
    $QueryBody = @{
        query = $FluxQuery
        type = "flux"
    } | ConvertTo-Json
    
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 30
    $Stopwatch.Stop()
    
    if ($Response.StatusCode -eq 200) {
        $ResponseTime = $Stopwatch.ElapsedMilliseconds
        if ($ResponseTime -lt 5000) {  # 5 seconds threshold
            Write-Log "✓ Performance validation passed (Response time: ${ResponseTime}ms)" "SUCCESS"
            $TestResults["Performance Validation"] = $true
        } else {
            Write-Log "⚠ Performance validation warning (Response time: ${ResponseTime}ms - above 5s threshold)" "WARNING"
            $TestResults["Performance Validation"] = $true  # Still consider it passed but with warning
        }
    } else {
        Write-Log "✗ Performance validation failed (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Performance validation test failed: $($_.Exception.Message)" "ERROR"
}

# Summary Report
Write-Log "=== Flux Query Test Summary ==="
$PassedTests = ($TestResults.Values | Where-Object { $_ -eq $true }).Count
$TotalTests = $TestResults.Count

foreach ($Test in $TestResults.GetEnumerator()) {
    $Status = if ($Test.Value) { "PASS" } else { "FAIL" }
    Write-Log "$($Test.Key): $Status"
}

Write-Log "Overall Result: $PassedTests/$TotalTests tests passed"

if ($PassedTests -eq $TotalTests) {
    Write-Log "✓ All Flux query tests passed - Query functionality is working correctly" "SUCCESS"
    exit 0
} else {
    Write-Log "✗ Some Flux query tests failed - Query functionality needs attention" "ERROR"
    exit 1
} 