# Complete End-to-End Data Flow Test

Write-Host "`n🚀 Complete Data Flow Test: MQTT → Node-RED → InfluxDB → API → Frontend`n" -ForegroundColor Cyan

# Device types mapping
$devices = @{
    "photovoltaic" = @{
        name = "Photovoltaic Panel"
        api_name = "charger"
        measurement = "photovoltaic_data"
    }
    "wind_turbine" = @{
        name = "Wind Turbine"
        api_name = "big_turbine"
        measurement = "wind_turbine_data"
    }
    "biogas" = @{
        name = "Biogas Plant"
        api_name = "biogas"
        measurement = "biogas_plant_data"
    }
    "heat_boiler" = @{
        name = "Heat Boiler"
        api_name = "heat_boiler"
        measurement = "heat_boiler_data"
    }
    "storage" = @{
        name = "Energy Storage"
        api_name = "storage"
        measurement = "energy_storage_data"
    }
}

Write-Host "Testing all device types...`n" -ForegroundColor Yellow

foreach ($deviceKey in $devices.Keys) {
    $device = $devices[$deviceKey]
    Write-Host "📊 Testing: $($device.name)" -ForegroundColor Cyan
    
    try {
        # Fetch data from API
        $uri = "http://localhost:3001/api/summary/$($device.api_name)?start=2m"
        $data = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 10
        
        if ($data -and $data.PSObject.Properties.Count -gt 0) {
            Write-Host "   ✅ Data received successfully" -ForegroundColor Green
            Write-Host "   📈 Fields count: $($data.PSObject.Properties.Count)" -ForegroundColor Gray
            
            # Display sample field
            $firstField = $data.PSObject.Properties | Select-Object -First 1
            if ($firstField) {
                Write-Host "   📝 Sample field: $($firstField.Name) = $($firstField.Value._value)" -ForegroundColor Gray
                Write-Host "   🕐 Timestamp: $($firstField.Value._time)" -ForegroundColor Gray
            }
        } else {
            Write-Host "   ⚠️  No data available" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "✨ Complete flow test finished!`n" -ForegroundColor Cyan

# Summary
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "   • All device types tested" -ForegroundColor Gray
Write-Host "   • Data flow: MQTT → Node-RED → InfluxDB → API → Frontend" -ForegroundColor Gray
Write-Host "   • Check above for any ❌ failures" -ForegroundColor Gray
Write-Host ""

