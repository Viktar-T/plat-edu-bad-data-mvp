# PowerShell script for testing InfluxDB API
# Renewable Energy IoT Monitoring System - Production API Test
# Tests the InfluxDB 2.7 API deployed on Mikrus VPS

function Test-InfluxDBConnection {
    param(
        [string]$BaseUrl = "http://robert108.mikrus.xyz:40101",
        [string]$Token = "renewable_energy_admin_token_123",
        [string]$Org = "renewable_energy_org"
    )
    
    $headers = @{
        "Authorization" = "Token $Token"
    }
    
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "INFLUXDB API CONNECTION TEST" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "Target URL: $BaseUrl" -ForegroundColor White
    Write-Host "Organization: $Org" -ForegroundColor White
    Write-Host "Token: $($Token.Substring(0, 10))..." -ForegroundColor White
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host ""
    
    $testResults = @()
    
    try {
        # Test 1: Health endpoint
        Write-Host "TEST 1: Health Endpoint Check" -ForegroundColor Yellow
        Write-Host "Endpoint: $BaseUrl/health" -ForegroundColor Gray
        Write-Host "Purpose: Verify InfluxDB service is running and responsive" -ForegroundColor Gray
        
        $healthResponse = Invoke-WebRequest -Uri "$BaseUrl/health" -Method GET
        $healthStatus = if ($healthResponse.StatusCode -eq 200) { "PASSED" } else { "FAILED" }
        Write-Host "Status: $healthStatus" -ForegroundColor $(if ($healthResponse.StatusCode -eq 200) { "Green" } else { "Red" })
        Write-Host "Response Code: $($healthResponse.StatusCode)" -ForegroundColor White
        Write-Host "Response Size: $($healthResponse.Content.Length) bytes" -ForegroundColor White
        Write-Host ""
        
        $testResults += @{
            Test = "Health Check"
            Status = $healthStatus
            Code = $healthResponse.StatusCode
            Details = "Service is running and responsive"
        }
        
        # Test 2: Buckets endpoint
        Write-Host "TEST 2: Buckets API Endpoint" -ForegroundColor Yellow
        Write-Host "Endpoint: $BaseUrl/api/v2/buckets?org=$Org" -ForegroundColor Gray
        Write-Host "Purpose: Verify authentication and retrieve bucket list" -ForegroundColor Gray
        
        $bucketsResponse = Invoke-WebRequest -Uri "$BaseUrl/api/v2/buckets?org=$Org" -Headers $headers
        $buckets = $bucketsResponse.Content | ConvertFrom-Json
        
        $bucketsStatus = if ($bucketsResponse.StatusCode -eq 200) { "PASSED" } else { "FAILED" }
        Write-Host "Status: $bucketsStatus" -ForegroundColor $(if ($bucketsResponse.StatusCode -eq 200) { "Green" } else { "Red" })
        Write-Host "Response Code: $($bucketsResponse.StatusCode)" -ForegroundColor White
        Write-Host "Buckets Found: $($buckets.buckets.Count)" -ForegroundColor White
        
        if ($buckets.buckets.Count -gt 0) {
            Write-Host "Bucket Names:" -ForegroundColor White
            foreach ($bucket in $buckets.buckets) {
                Write-Host "  - $($bucket.name)" -ForegroundColor Gray
            }
        }
        Write-Host ""
        
        $testResults += @{
            Test = "Buckets API"
            Status = $bucketsStatus
            Code = $bucketsResponse.StatusCode
            Details = "Found $($buckets.buckets.Count) buckets"
        }
        
        # Test 3: Query endpoint
        Write-Host "TEST 3: Query API Endpoint" -ForegroundColor Yellow
        Write-Host "Endpoint: $BaseUrl/api/v2/query?org=$Org" -ForegroundColor Gray
        Write-Host "Purpose: Test Flux query execution and data retrieval" -ForegroundColor Gray
        
        $queryHeaders = @{
            "Authorization" = "Token $Token"
            "Content-Type" = "application/vnd.flux"
        }
        $queryBody = 'from(bucket:"renewable_energy") |> range(start: -1h) |> limit(n:5)'
        
        Write-Host "Query: $queryBody" -ForegroundColor Gray
        
        $queryResponse = Invoke-WebRequest -Uri "$BaseUrl/api/v2/query?org=$Org" -Method POST -Headers $queryHeaders -Body $queryBody
        
        $queryStatus = if ($queryResponse.StatusCode -eq 200) { "PASSED" } else { "FAILED" }
        Write-Host "Status: $queryStatus" -ForegroundColor $(if ($queryResponse.StatusCode -eq 200) { "Green" } else { "Red" })
        Write-Host "Response Code: $($queryResponse.StatusCode)" -ForegroundColor White
        Write-Host "Response Size: $($queryResponse.Content.Length) bytes" -ForegroundColor White
        
        # Parse CSV response to count data points
        $dataPoints = 0
        if ($queryResponse.StatusCode -eq 200) {
            $csvLines = $queryResponse.Content.Trim().Split("`n")
            $dataPoints = $csvLines.Count - 1  # Subtract header line
            Write-Host "Data Points Retrieved: $dataPoints" -ForegroundColor White
            
            if ($dataPoints -gt 0) {
                Write-Host "Sample Data (first 3 lines):" -ForegroundColor White
                $csvLines[0..2] | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            }
        }
        Write-Host ""
        
        $testResults += @{
            Test = "Query API"
            Status = $queryStatus
            Code = $queryResponse.StatusCode
            Details = "Retrieved $dataPoints data points"
        }
        
        # Test 4: Organizations endpoint
        Write-Host "TEST 4: Organizations API Endpoint" -ForegroundColor Yellow
        Write-Host "Endpoint: $BaseUrl/api/v2/orgs" -ForegroundColor Gray
        Write-Host "Purpose: Verify organization access and list available orgs" -ForegroundColor Gray
        
        $orgsResponse = Invoke-WebRequest -Uri "$BaseUrl/api/v2/orgs" -Headers $headers
        $orgs = $orgsResponse.Content | ConvertFrom-Json
        
        $orgsStatus = if ($orgsResponse.StatusCode -eq 200) { "PASSED" } else { "FAILED" }
        Write-Host "Status: $orgsStatus" -ForegroundColor $(if ($orgsResponse.StatusCode -eq 200) { "Green" } else { "Red" })
        Write-Host "Response Code: $($orgsResponse.StatusCode)" -ForegroundColor White
        Write-Host "Organizations Found: $($orgs.orgs.Count)" -ForegroundColor White
        
        if ($orgs.orgs.Count -gt 0) {
            Write-Host "Organization Names:" -ForegroundColor White
            foreach ($org in $orgs.orgs) {
                Write-Host "  - $($org.name)" -ForegroundColor Gray
            }
        }
        Write-Host ""
        
        $testResults += @{
            Test = "Organizations API"
            Status = $orgsStatus
            Code = $orgsResponse.StatusCode
            Details = "Found $($orgs.orgs.Count) organizations"
        }
        
        # Summary Report
        Write-Host ("=" * 80) -ForegroundColor Cyan
        Write-Host "TEST SUMMARY REPORT" -ForegroundColor Cyan
        Write-Host ("=" * 80) -ForegroundColor Cyan
        
        $passedTests = ($testResults | Where-Object { $_.Status -eq "PASSED" }).Count
        $totalTests = $testResults.Count
        
        Write-Host "Total Tests: $totalTests" -ForegroundColor White
        Write-Host "Passed: $passedTests" -ForegroundColor Green
        Write-Host "Failed: $($totalTests - $passedTests)" -ForegroundColor Red
        Write-Host "Success Rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })
        Write-Host ""
        
        Write-Host "Detailed Results:" -ForegroundColor White
        foreach ($result in $testResults) {
            $color = if ($result.Status -eq "PASSED") { "Green" } else { "Red" }
            Write-Host "  $($result.Test): $($result.Status) (Code: $($result.Code)) - $($result.Details)" -ForegroundColor $color
        }
        Write-Host ""
        
        # Overall result
        if ($passedTests -eq $totalTests) {
            Write-Host "ALL TESTS PASSED! InfluxDB API is fully operational." -ForegroundColor Green
            Write-Host "Your production InfluxDB is ready for integration." -ForegroundColor Green
            return $true
        } else {
            Write-Host "SOME TESTS FAILED. Please check the configuration and try again." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host ("=" * 80) -ForegroundColor Red
        Write-Host "TEST EXECUTION ERROR" -ForegroundColor Red
        Write-Host ("=" * 80) -ForegroundColor Red
        Write-Host "Error Type: $($_.Exception.GetType().Name)" -ForegroundColor Red
        Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.InnerException) {
            Write-Host "Error Details: $($_.Exception.InnerException.Message)" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "Troubleshooting Tips:" -ForegroundColor Yellow
        Write-Host "1. Check if the VPS is accessible: ping robert108.mikrus.xyz" -ForegroundColor Gray
        Write-Host "2. Verify the port is open: telnet robert108.mikrus.xyz 40101" -ForegroundColor Gray
        Write-Host "3. Check if InfluxDB service is running on the VPS" -ForegroundColor Gray
        Write-Host "4. Verify the token and organization are correct" -ForegroundColor Gray
        Write-Host "5. Check firewall settings on the VPS" -ForegroundColor Gray
        return $false
    }
}

# Run the test with enhanced output
Write-Host "Starting InfluxDB API Connection Test..." -ForegroundColor Green
Write-Host "This test will verify connectivity to your production InfluxDB instance." -ForegroundColor Gray
Write-Host ""

$result = Test-InfluxDBConnection

Write-Host ""
Write-Host "Test completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "Exit code: $(if ($result) { 0 } else { 1 })" -ForegroundColor Gray