# Monitor real-time data updates

Write-Host "`n⏱️  Monitoring Real-Time Data Updates`n" -ForegroundColor Cyan
Write-Host "Fetching photovoltaic data every 5 seconds for 30 seconds...`n" -ForegroundColor Yellow

$iterations = 6
$delay = 5

for ($i = 1; $i -le $iterations; $i++) {
    Write-Host "[$i/$iterations] $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    
    try {
        $data = Invoke-RestMethod -Uri "http://localhost:3001/api/summary/charger?start=1m" -Method Get
        
        if ($data.power_output) {
            $power = [math]::Round($data.power_output._value, 2)
            $timestamp = $data.power_output._time
            Write-Host "   Power Output: $power W" -ForegroundColor Green
            Write-Host "   Timestamp: $timestamp" -ForegroundColor Gray
        } elseif ($data.PSObject.Properties.Count -gt 0) {
            # Try to find any numeric field
            $firstNumericField = $data.PSObject.Properties | Where-Object { 
                $_.Value._value -is [double] -or $_.Value._value -is [int] 
            } | Select-Object -First 1
            
            if ($firstNumericField) {
                $value = [math]::Round($firstNumericField.Value._value, 2)
                $timestamp = $firstNumericField.Value._time
                Write-Host "   $($firstNumericField.Name): $value" -ForegroundColor Green
                Write-Host "   Timestamp: $timestamp" -ForegroundColor Gray
            } else {
                Write-Host "   ⚠️  No numeric data found" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ⚠️  No data available" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Error: $_" -ForegroundColor Red
    }
    
    if ($i -lt $iterations) {
        Start-Sleep -Seconds $delay
    }
}

Write-Host "`n✅ Real-time monitoring completed`n" -ForegroundColor Green

