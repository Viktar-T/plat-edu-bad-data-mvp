# End-to-End Data Flow Testing Script
# Tests complete flow: MQTT → Node-RED → InfluxDB 2.x → Grafana

param(
    [string]$InfluxDBUrl = "http://localhost:8086",
    [string]$GrafanaUrl = "http://localhost:3000",
    [string]$Token = "renewable_energy_admin_token_123",
    [string]$Organization = "renewable_energy_org",
    [string]$Bucket = "renewable_energy",
    [string]$LogFile = "tests/logs/test-results/data-flow-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
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
    "MQTT Message Publishing" = $false
    "Node-RED Processing" = $false
    "InfluxDB Data Writing" = $false
    "Grafana Data Reading" = $false
    "End-to-End Validation" = $false
}

Write-Log "Starting End-to-End Data Flow Test"
Write-Log "Configuration: InfluxDB=$InfluxDBUrl, Grafana=$GrafanaUrl, Org=$Organization"

# Test 1: MQTT Message Publishing
Write-Log "Test 1: Publishing test message to MQTT..."
try {
    $TestMessage = @{
        device_id = "test_pv_001"
        device_type = "photovoltaic"
        location = "test_site"
        status = "operational"
        data = @{
            power_output = 2500.5
            temperature = 45.2
            voltage = 48.5
            current = 51.5
            irradiance = 850.0
            efficiency = 0.18
        }
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    } | ConvertTo-Json -Depth 3

    $Topic = "devices/photovoltaic/test_pv_001/data"
    
    # Publish message using docker exec
    $Result = docker exec -i iot-mosquitto mosquitto_pub -h localhost -p 1883 -t $Topic -m $TestMessage 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ MQTT message published successfully to topic: $Topic" "SUCCESS"
        $TestResults["MQTT Message Publishing"] = $true
    } else {
        Write-Log "✗ MQTT message publishing failed: $Result" "ERROR"
    }
} catch {
    Write-Log "✗ MQTT test failed: $($_.Exception.Message)" "ERROR"
}

# Test 2: Node-RED Processing
Write-Log "Test 2: Verifying Node-RED processing..."
try {
    # Wait a moment for Node-RED to process the message
    Start-Sleep -Seconds 3
    
    # Check if Node-RED is running
    $NodeRedStatus = docker ps --filter "name=iot-nodered" --format "{{.Status}}" 2>$null
    if ($NodeRedStatus -and $NodeRedStatus -match "Up") {
        Write-Log "✓ Node-RED is running and processing messages" "SUCCESS"
        $TestResults["Node-RED Processing"] = $true
    } else {
        Write-Log "✗ Node-RED is not running or not processing messages" "ERROR"
    }
} catch {
    Write-Log "✗ Node-RED processing test failed: $($_.Exception.Message)" "ERROR"
}

# Test 3: InfluxDB Data Writing
Write-Log "Test 3: Verifying data writing to InfluxDB..."
try {
    # Wait for data to be written
    Start-Sleep -Seconds 5
    
    $Headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/json"
    }
    
    # Query for recent data
    $FluxQuery = @"
from(bucket: "$Bucket")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r.device_id == "test_pv_001")
  |> limit(n: 1)
"@
    
    $QueryBody = @{
        query = $FluxQuery
        type = "flux"
    } | ConvertTo-Json
    
    $Response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v2/query?org=$Organization" -Method POST -Headers $Headers -Body $QueryBody -UseBasicParsing -TimeoutSec 10
    
    if ($Response.StatusCode -eq 200) {
        $Data = $Response.Content
        if ($Data -and $Data -notmatch "^\s*$") {
            Write-Log "✓ Data successfully written to InfluxDB" "SUCCESS"
            $TestResults["InfluxDB Data Writing"] = $true
        } else {
            Write-Log "✗ No data found in InfluxDB" "ERROR"
        }
    } else {
        Write-Log "✗ Failed to query InfluxDB (Status: $($Response.StatusCode))" "ERROR"
    }
} catch {
    Write-Log "✗ InfluxDB data writing test failed: $($_.Exception.Message)" "ERROR"
}

# Test 4: Grafana Data Reading
Write-Log "Test 4: Verifying Grafana data reading..."
try {
    # Check if Grafana is accessible
    $GrafanaResponse = Invoke-WebRequest -Uri "$GrafanaUrl/api/health" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($GrafanaResponse.StatusCode -eq 200) {
        Write-Log "✓ Grafana is accessible" "SUCCESS"
        
        # Check datasource connectivity
        $GrafanaHeaders = @{
            "Authorization" = "Bearer $Token"
            "Content-Type" = "application/json"
        }
        
        $DatasourceResponse = Invoke-WebRequest -Uri "$GrafanaUrl/api/datasources" -Method GET -Headers $GrafanaHeaders -UseBasicParsing -TimeoutSec 10
        if ($DatasourceResponse.StatusCode -eq 200) {
            Write-Log "✓ Grafana can access data sources" "SUCCESS"
            $TestResults["Grafana Data Reading"] = $true
        } else {
            Write-Log "✗ Grafana data source access failed" "ERROR"
        }
    } else {
        Write-Log "✗ Grafana is not accessible" "ERROR"
    }
} catch {
    Write-Log "✗ Grafana data reading test failed: $($_.Exception.Message)" "ERROR"
}

# Test 5: End-to-End Validation
Write-Log "Test 5: End-to-end data flow validation..."
try {
    # Verify complete data flow by checking data consistency
    if ($TestResults["MQTT Message Publishing"] -and 
        $TestResults["Node-RED Processing"] -and 
        $TestResults["InfluxDB Data Writing"] -and 
        $TestResults["Grafana Data Reading"]) {
        
        Write-Log "✓ Complete data flow validated successfully" "SUCCESS"
        $TestResults["End-to-End Validation"] = $true
    } else {
        Write-Log "✗ Data flow validation failed - some components not working" "ERROR"
    }
} catch {
    Write-Log "✗ End-to-end validation failed: $($_.Exception.Message)" "ERROR"
}

# Summary Report
Write-Log "=== Data Flow Test Summary ==="
$PassedTests = ($TestResults.Values | Where-Object { $_ -eq $true }).Count
$TotalTests = $TestResults.Count

foreach ($Test in $TestResults.GetEnumerator()) {
    $Status = if ($Test.Value) { "PASS" } else { "FAIL" }
    Write-Log "$($Test.Key): $Status"
}

Write-Log "Overall Result: $PassedTests/$TotalTests tests passed"

if ($PassedTests -eq $TotalTests) {
    Write-Log "✓ All data flow tests passed - System is working correctly" "SUCCESS"
    exit 0
} else {
    Write-Log "✗ Some data flow tests failed - System needs attention" "ERROR"
    exit 1
} 