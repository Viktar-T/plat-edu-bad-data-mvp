# Fix Dashboard Queries - Replace device_type with _measurement
# This script updates all Grafana dashboard files to use the correct data structure

Write-Host "🔧 Fixing Grafana Dashboard Queries..." -ForegroundColor Green

# Define the mapping of device_type to _measurement
$mappings = @{
    "wind_turbine" = "wind_turbine_data"
    "photovoltaic" = "photovoltaic_data"
    "biogas_plant" = "biogas_plant_data"
    "energy_storage" = "energy_storage_data"
    "heat_boiler" = "heat_boiler_data"
}

# Dashboard files to update
$dashboardFiles = @(
    "grafana/dashboards/wind-turbine-analytics.json",
    "grafana/dashboards/photovoltaic-monitoring.json",
    "grafana/dashboards/renewable-energy-overview.json",
    "grafana/dashboards/energy-storage-monitoring.json",
    "grafana/dashboards/heat-boiler-monitoring.json",
    "grafana/dashboards/biogas-plant-metrics.json"
)

$totalChanges = 0

foreach ($file in $dashboardFiles) {
    if (Test-Path $file) {
        Write-Host "📁 Processing: $file" -ForegroundColor Yellow
        
        $content = Get-Content $file -Raw
        $originalContent = $content
        $fileChanges = 0
        
        # Replace each device_type mapping
        foreach ($deviceType in $mappings.Keys) {
            $measurement = $mappings[$deviceType]
            
            # Replace device_type == "device_type" with _measurement == "measurement_name"
            $pattern = "device_type == `"$deviceType`""
            $replacement = "_measurement == `"$measurement`""
            
            $newContent = $content -replace $pattern, $replacement
            if ($newContent -ne $content) {
                $content = $newContent
                $fileChanges++
                Write-Host "  ✅ Replaced: $pattern -> $replacement" -ForegroundColor Green
            }
            
            # Replace group(columns: ["device_type"]) with group(columns: ["_measurement"])
            $pattern = 'group\(columns: \["device_type"\]\)'
            $replacement = 'group(columns: ["_measurement"])'
            
            $newContent = $content -replace $pattern, $replacement
            if ($newContent -ne $content) {
                $content = $newContent
                $fileChanges++
                Write-Host "  ✅ Replaced: group(columns: [\"device_type\"]) -> group(columns: [\"_measurement\"])" -ForegroundColor Green
            }
            
            # Replace distinct(column: "device_type") with distinct(column: "_measurement")
            $pattern = 'distinct\(column: "device_type"\)'
            $replacement = 'distinct(column: "_measurement")'
            
            $newContent = $content -replace $pattern, $replacement
            if ($newContent -ne $content) {
                $content = $newContent
                $fileChanges++
                Write-Host "  ✅ Replaced: distinct(column: \"device_type\") -> distinct(column: \"_measurement\")" -ForegroundColor Green
            }
        }
        
        # Replace any remaining device_type references in group clauses
        $pattern = 'group\(columns: \["device_id", "device_type"\]\)'
        $replacement = 'group(columns: ["device_id", "_measurement"])'
        
        $newContent = $content -replace $pattern, $replacement
        if ($newContent -ne $content) {
            $content = $newContent
            $fileChanges++
            Write-Host "  ✅ Replaced: group(columns: [\"device_id\", \"device_type\"]) -> group(columns: [\"device_id\", \"_measurement\"])" -ForegroundColor Green
        }
        
        # Replace device_type in renameByName transformations
        $pattern = '"device_type": "Device Type"'
        $replacement = '"_measurement": "Device Type"'
        
        $newContent = $content -replace $pattern, $replacement
        if ($newContent -ne $content) {
            $content = $newContent
            $fileChanges++
            Write-Host "  ✅ Replaced: \"device_type\": \"Device Type\" -> \"_measurement\": \"Device Type\"" -ForegroundColor Green
        }
        
        if ($fileChanges -gt 0) {
            # Write the updated content back to the file
            Set-Content -Path $file -Value $content -Encoding UTF8
            Write-Host "  💾 Saved $fileChanges changes to $file" -ForegroundColor Cyan
            $totalChanges += $fileChanges
        } else {
            Write-Host "  ⚠️  No changes needed for $file" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ File not found: $file" -ForegroundColor Red
    }
}

Write-Host "`n🎉 Dashboard Query Fix Complete!" -ForegroundColor Green
Write-Host "📊 Total changes made: $totalChanges" -ForegroundColor Cyan
Write-Host "`n📋 Summary of changes:" -ForegroundColor White
Write-Host "  • Replaced device_type == \"device_name\" with _measurement == \"device_name_data\"" -ForegroundColor White
Write-Host "  • Updated group(columns: [\"device_type\"]) to group(columns: [\"_measurement\"])" -ForegroundColor White
Write-Host "  • Updated distinct(column: \"device_type\") to distinct(column: \"_measurement\")" -ForegroundColor White
Write-Host "  • Fixed multi-column groupings and transformations" -ForegroundColor White

Write-Host "`n🔄 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Grafana container to reload dashboards" -ForegroundColor White
Write-Host "  2. Check that dashboards now display data correctly" -ForegroundColor White
Write-Host "  3. Verify that all panels are working with the new query structure" -ForegroundColor White 