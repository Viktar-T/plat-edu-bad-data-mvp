# Test Grafana Data Source
Write-Host "Testing Grafana Data Source..." -ForegroundColor Cyan

# Test 1: Check if Grafana is accessible
Write-Host "`n1. Testing Grafana accessibility..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET
    Write-Host "✓ Grafana is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Grafana is not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Check data sources
Write-Host "`n2. Checking data sources..." -ForegroundColor White
try {
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    $headers = @{
        "Authorization" = "Basic $auth"
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method GET
    $datasources = $response.Content | ConvertFrom-Json
    
    Write-Host "✓ Found $($datasources.Count) data source(s)" -ForegroundColor Green
    
    $influxDS = $datasources | Where-Object { $_.type -eq "influxdb" }
    if ($influxDS) {
        Write-Host "✓ InfluxDB data source found: $($influxDS.name)" -ForegroundColor Green
        Write-Host "  URL: $($influxDS.url)" -ForegroundColor Gray
        Write-Host "  Organization: $($influxDS.jsonData.organization)" -ForegroundColor Gray
        Write-Host "  Bucket: $($influxDS.jsonData.defaultBucket)" -ForegroundColor Gray
    } else {
        Write-Host "✗ No InfluxDB data source found" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Error checking data sources: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test data source connection
Write-Host "`n3. Testing data source connection..." -ForegroundColor White
if ($influxDS) {
    try {
        $testBody = @{
            query = 'from(bucket: "renewable_energy") |> range(start: -1h) |> limit(n: 1)'
        } | ConvertTo-Json
        
        $testResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/datasources/proxy/$($influxDS.id)/query?org=renewable_energy_org" -Headers $headers -Method POST -Body $testBody -ContentType "application/json"
        
        if ($testResponse.StatusCode -eq 200) {
            Write-Host "✓ Data source connection successful" -ForegroundColor Green
            if ($testResponse.Content -match "result") {
                Write-Host "✓ Query returned data" -ForegroundColor Green
            } else {
                Write-Host "! Query returned no data (this might be normal)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "✗ Data source connection failed (Status: $($testResponse.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Error testing data source: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "If data source is configured but dashboards show no data:" -ForegroundColor Yellow
Write-Host "1. Check time range in Grafana dashboards" -ForegroundColor White
Write-Host "2. Verify dashboard queries use correct bucket name" -ForegroundColor White
Write-Host "3. Check if dashboards are using the correct data source" -ForegroundColor White
Write-Host "4. Try refreshing the dashboard" -ForegroundColor White 