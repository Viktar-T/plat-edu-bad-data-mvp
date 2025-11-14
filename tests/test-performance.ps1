# API Performance Test

Write-Host "`n⚡ API Performance Test`n" -ForegroundColor Cyan

$endpoints = @(
    @{ name = "Health Check"; uri = "http://localhost:3001/health" }
    @{ name = "Photovoltaic"; uri = "http://localhost:3001/api/summary/charger?start=2m" }
    @{ name = "Wind Turbine"; uri = "http://localhost:3001/api/summary/big_turbine?start=2m" }
    @{ name = "Energy Storage"; uri = "http://localhost:3001/api/summary/storage?start=2m" }
)

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $($endpoint.name)" -ForegroundColor Yellow
    
    $times = @()
    $iterations = 5
    
    for ($i = 1; $i -le $iterations; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $null = Invoke-RestMethod -Uri $endpoint.uri -Method Get -TimeoutSec 10
            $sw.Stop()
            $times += $sw.ElapsedMilliseconds
        } catch {
            Write-Host "   ❌ Failed: $_" -ForegroundColor Red
            $sw.Stop()
        }
    }
    
    if ($times.Count -gt 0) {
        $avgTime = ($times | Measure-Object -Average).Average
        $minTime = ($times | Measure-Object -Minimum).Minimum
        $maxTime = ($times | Measure-Object -Maximum).Maximum
        
        Write-Host "   Average: $([math]::Round($avgTime, 2))ms" -ForegroundColor Green
        Write-Host "   Min: $([math]::Round($minTime, 2))ms | Max: $([math]::Round($maxTime, 2))ms" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "✅ Performance test completed`n" -ForegroundColor Cyan

