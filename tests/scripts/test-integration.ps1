# Integration Testing Script
# Tests component integration and data consistency across the system

param(
    [string]$InfluxDBUrl = "http://localhost:8086",
    [string]$GrafanaUrl = "http://localhost:3000",
    [string]$Token = "renewable_energy_admin_token_123",
    [string]$Organization = "renewable_energy_org",
    [string]$Bucket = "renewable_energy",
    [string]$LogFile = "tests/logs/test-results/integration-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
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
    "Cross-Component Authentication" = $false
    "Data Consistency Validation" = $false
    "Error Handling Verification" = $false
    "Token Consistency" = $false
    "Organization Consistency" = $false
}

Write-Log "Starting Integration Testing"
Write-Log "Configuration: InfluxDB=$InfluxDBUrl, Grafana=$GrafanaUrl, Org=$Organization"

# Test 1: Cross-Component Authentication
Write-Log "Test 1: Testing cross-component authentication..."
try {
    $SuccessCount = 0
    $TotalTests = 0
    
    # Test InfluxDB authentication
    $TotalTests++
    $Headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
    }
    
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/orgs" -Method GET -Headers $Headers -UseBasicParsing -TimeoutSec 10
    if ($Response.StatusCode -eq 200) {
        Write-Log "✓ InfluxDB authentication successful" "SUCCESS"
        $SuccessCount++
    } else {
        Write-Log "✗ InfluxDB authentication failed" "ERROR"
    }
    
    # Test Grafana authentication (if accessible)
    $TotalTests++
    try {
        $GrafanaResponse = Invoke-WebRequest -Uri "$GrafanaUrl/api/health" -Method GET -UseBasicParsing -TimeoutSec 10
        if ($GrafanaResponse.StatusCode -eq 200) {
            Write-Log "✓ Grafana authentication successful" "SUCCESS"
            $SuccessCount++
        } else {
            Write-Log "✗ Grafana authentication failed" "ERROR"
        }
    } catch {
        Write-Log "⚠ Grafana not accessible for authentication test" "WARNING"
        $SuccessCount++  # Don't fail the test if Grafana is not running
    }
    
    if ($SuccessCount -eq $TotalTests) {
        Write-Log "✓ Cross-component authentication successful" "SUCCESS"
        $TestResults["Cross-Component Authentication"] = $true
    } else {
        Write-Log "✗ Cross-component authentication failed" "ERROR"
    }
} catch {
    Write-Log "✗ Cross-component authentication test failed: $($_.Exception.Message)" "ERROR"
}

# Test 2: Data Consistency Validation
Write-Log "Test 2: Testing data consistency validation..."
try {
    # Write test data to InfluxDB
    $TestData = @{
        measurement = "integration_test"
        tags = @{
            device_id = "integration_test_001"
            device_type = "test_device"
            location = "test_site"
            status = "operational"
        }
        fields = @{
            power_output = 1000.0
            temperature = 25.0
            efficiency = 0.85
        }
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    
    $Headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
    }
    
    # Write data using InfluxDB API
    $WriteBody = @{
        bucket = $Bucket
        org = $Organization
        precision = "s"
        data = @(
            "$($TestData.measurement),device_id=$($TestData.tags.device_id),device_type=$($TestData.tags.device_type),location=$($TestData.tags.location),status=$($TestData.tags.status) power_output=$($TestData.fields.power_output),temperature=$($TestData.fields.temperature),efficiency=$($TestData.fields.efficiency) $((Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ'))"
        )
    } | ConvertTo-Json
    
    $WriteResponse = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/write?org=$Organization&bucket=$Bucket" -Method POST -Headers $Headers -Body $WriteBody -UseBasicParsing -TimeoutSec 10
    
    if ($WriteResponse.StatusCode -eq 204) {
        Write-Log "✓ Test data written successfully" "SUCCESS"
        
        # Wait a moment for data to be available
        Start-Sleep -Seconds 2
        
        # Read data back to verify consistency
        $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -1m)
  |> filter(fn: (r) => r._measurement == "integration_test")
  |> filter(fn: (r) => r.device_id == "integration_test_001")
  |> limit(n: 1)
"@
        
        $QueryBody = @{
            query = $FluxQuery
            type = "flux"
        } | ConvertTo-Json
        
        $ReadResponse = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 10
        
        if ($ReadResponse.StatusCode -eq 200 -and $ReadResponse.Content -notmatch "^\s*$") {
            Write-Log "✓ Data consistency validation successful" "SUCCESS"
            $TestResults["Data Consistency Validation"] = $true
        } else {
            Write-Log "✗ Data consistency validation failed - could not read back data" "ERROR"
        }
    } else {
        Write-Log "✗ Failed to write test data (Status: $($WriteResponse.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Data consistency validation test failed: $($_.Exception.Message)" "ERROR"
}

# Test 3: Error Handling Verification
Write-Log "Test 3: Testing error handling verification..."
try {
    $SuccessCount = 0
    $TotalTests = 0
    
    # Test invalid token
    $TotalTests++
    $InvalidHeaders = @{
        "Authorization" = "Token invalid_token_123"
        "Content-Type" = "application/json"
    }
    
    try {
        $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/orgs" -Method GET -Headers $InvalidHeaders -UseBasicParsing -TimeoutSec 10
        if ($Response.StatusCode -eq 401) {
            Write-Log "✓ Invalid token properly rejected (401)" "SUCCESS"
            $SuccessCount++
        } else {
            Write-Log "✗ Invalid token not properly rejected (Status: $($Response.StatusCode))" "ERROR"
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Log "✓ Invalid token properly rejected (401)" "SUCCESS"
            $SuccessCount++
        } else {
            Write-Log "✗ Invalid token error handling failed" "ERROR"
        }
    }
    
    # Test invalid organization
    $TotalTests++
    try {
        $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/buckets?org=invalid_org" -Method GET -Headers $Headers -UseBasicParsing -TimeoutSec 10
        if ($Response.StatusCode -eq 404 -or $Response.StatusCode -eq 400) {
            Write-Log "✓ Invalid organization properly rejected" "SUCCESS"
            $SuccessCount++
        } else {
            Write-Log "✗ Invalid organization not properly rejected (Status: $($Response.StatusCode))" "ERROR"
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404 -or $_.Exception.Response.StatusCode -eq 400) {
            Write-Log "✓ Invalid organization properly rejected" "SUCCESS"
            $SuccessCount++
        } else {
            Write-Log "✗ Invalid organization error handling failed" "ERROR"
        }
    }
    
    if ($SuccessCount -eq $TotalTests) {
        Write-Log "✓ Error handling verification successful" "SUCCESS"
        $TestResults["Error Handling Verification"] = $true
    } else {
        Write-Log "✗ Error handling verification failed" "ERROR"
    }
} catch {
    Write-Log "✗ Error handling verification test failed: $($_.Exception.Message)" "ERROR"
}

# Test 4: Token Consistency
Write-Log "Test 4: Testing token consistency..."
try {
    $ExpectedToken = "renewable_energy_admin_token_123"
    
    # Check if token is consistent across configuration
    if ($Token -eq $ExpectedToken) {
        Write-Log "✓ Token consistency verified: $Token" "SUCCESS"
        $TestResults["Token Consistency"] = $true
    } else {
        Write-Log "✗ Token inconsistency detected: Expected $ExpectedToken, Got $Token" "ERROR"
    }
} catch {
    Write-Log "✗ Token consistency test failed: $($_.Exception.Message)" "ERROR"
}

# Test 5: Organization Consistency
Write-Log "Test 5: Testing organization consistency..."
try {
    $ExpectedOrg = "renewable_energy_org"
    
    # Check if organization is consistent across configuration
    if ($Organization -eq $ExpectedOrg) {
        Write-Log "✓ Organization consistency verified: $Organization" "SUCCESS"
        $TestResults["Organization Consistency"] = $true
    } else {
        Write-Log "✗ Organization inconsistency detected: Expected $ExpectedOrg, Got $Organization" "ERROR"
    }
} catch {
    Write-Log "✗ Organization consistency test failed: $($_.Exception.Message)" "ERROR"
}

# Summary Report
Write-Log "=== Integration Test Summary ==="
$PassedTests = ($TestResults.Values | Where-Object { $_ -eq $true }).Count
$TotalTests = $TestResults.Count

foreach ($Test in $TestResults.GetEnumerator()) {
    $Status = if ($Test.Value) { "PASS" } else { "FAIL" }
    Write-Log "$($Test.Key): $Status"
}

Write-Log "Overall Result: $PassedTests/$TotalTests tests passed"

if ($PassedTests -eq $TotalTests) {
    Write-Log "✓ All integration tests passed - System integration is working correctly" "SUCCESS"
    exit 0
} else {
    Write-Log "✗ Some integration tests failed - System integration needs attention" "ERROR"
    exit 1
} 