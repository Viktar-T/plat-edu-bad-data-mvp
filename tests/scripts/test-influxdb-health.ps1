# InfluxDB 2.x Health Check Script
# Tests service status, connectivity, authentication, and access

param(
    [string]$InfluxDBUrl = "http://localhost:8086",
    [string]$Token = "renewable_energy_admin_token_123",
    [string]$Organization = "renewable_energy_org",
    [string]$Bucket = "renewable_energy",
    [string]$LogFile = "tests/logs/test-results/health-check-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
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
    "Service Status" = $false
    "HTTP Endpoint" = $false
    "Authentication" = $false
    "Organization Access" = $false
    "Bucket Access" = $false
}

Write-Log "Starting InfluxDB 2.x Health Check"
Write-Log "Configuration: URL=$InfluxDBUrl, Org=$Organization, Bucket=$Bucket"

# Test 1: Service Status
Write-Log "Test 1: Checking InfluxDB service status..."
try {
    $ContainerStatus = docker ps --filter "name=iot-influxdb2" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>$null
    if ($ContainerStatus -and $ContainerStatus -match "iot-influxdb2") {
        Write-Log "✓ InfluxDB container is running" "SUCCESS"
        $TestResults["Service Status"] = $true
    } else {
        Write-Log "✗ InfluxDB container is not running" "ERROR"
    }
} catch {
    Write-Log "✗ Error checking container status: $($_.Exception.Message)" "ERROR"
}

# Test 2: HTTP Endpoint Accessibility
Write-Log "Test 2: Testing HTTP endpoint accessibility..."
try {
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/health" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($Response.StatusCode -eq 200) {
        Write-Log "✓ HTTP endpoint is accessible (Status: $($Response.StatusCode))" "SUCCESS"
        $TestResults["HTTP Endpoint"] = $true
    } else {
        Write-Log "✗ HTTP endpoint returned status: $($Response.StatusCode)" "ERROR"
    }
} catch {
    Write-Log "✗ HTTP endpoint is not accessible: $($_.Exception.Message)" "ERROR"
}

# Test 3: Authentication
Write-Log "Test 3: Testing token-based authentication..."
try {
    $Headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
    }
    
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/orgs" -Method GET -Headers $Headers -UseBasicParsing -TimeoutSec 10
    if ($Response.StatusCode -eq 200) {
        Write-Log "✓ Authentication successful" "SUCCESS"
        $TestResults["Authentication"] = $true
    } else {
        Write-Log "✗ Authentication failed (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Authentication test failed: $($_.Exception.Message)" "ERROR"
}

# Test 4: Organization Access
Write-Log "Test 4: Testing organization access..."
try {
    $Headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
    }
    
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/orgs" -Method GET -Headers $Headers -UseBasicParsing -TimeoutSec 10
    if ($Response.StatusCode -eq 200) {
        $Orgs = $Response.Content | ConvertFrom-Json
        $TargetOrg = $Orgs.orgs | Where-Object { $_.name -eq $Organization }
        
        if ($TargetOrg) {
            Write-Log "✓ Organization '$Organization' exists and is accessible" "SUCCESS"
            $TestResults["Organization Access"] = $true
        } else {
            Write-Log "✗ Organization '$Organization' not found" "ERROR"
        }
    } else {
        Write-Log "✗ Failed to retrieve organizations (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Organization access test failed: $($_.Exception.Message)" "ERROR"
}

# Test 5: Bucket Access
Write-Log "Test 5: Testing bucket access..."
try {
    $Headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
    }
    
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/buckets?org=$Organization" -Method GET -Headers $Headers -UseBasicParsing -TimeoutSec 10
    if ($Response.StatusCode -eq 200) {
        $Buckets = $Response.Content | ConvertFrom-Json
        $TargetBucket = $Buckets.buckets | Where-Object { $_.name -eq $Bucket }
        
        if ($TargetBucket) {
            Write-Log "✓ Bucket '$Bucket' exists and is accessible" "SUCCESS"
            $TestResults["Bucket Access"] = $true
        } else {
            Write-Log "✗ Bucket '$Bucket' not found" "ERROR"
        }
    } else {
        Write-Log "✗ Failed to retrieve buckets (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ Bucket access test failed: $($_.Exception.Message)" "ERROR"
}

# Summary Report
Write-Log "=== Health Check Summary ==="
$PassedTests = ($TestResults.Values | Where-Object { $_ -eq $true }).Count
$TotalTests = $TestResults.Count

foreach ($Test in $TestResults.GetEnumerator()) {
    $Status = if ($Test.Value) { "PASS" } else { "FAIL" }
    Write-Log "$($Test.Key): $Status"
}

Write-Log "Overall Result: $PassedTests/$TotalTests tests passed"

if ($PassedTests -eq $TotalTests) {
    Write-Log "✓ All health checks passed - InfluxDB 2.x is healthy" "SUCCESS"
    exit 0
} else {
    Write-Log "✗ Some health checks failed - InfluxDB 2.x needs attention" "ERROR"
    exit 1
} 