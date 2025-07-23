# Convert all Node-RED flow files to proper import format
Write-Host "Converting all Node-RED flow files to proper import format..." -ForegroundColor Green
Write-Host ""

# Change to project root directory
Set-Location $PSScriptRoot/..

$flowFiles = @(
    "node-red/flows/energy-storage-simulation.json",
    "node-red/flows/heat-boiler-simulation.json", 
    "node-red/flows/biogas-plant-simulation.json",
    "node-red/flows/wind-turbine-simulation.json",
    "node-red/flows/renewable-energy-simulation.json"
)

foreach ($file in $flowFiles) {
    if (Test-Path $file) {
        Write-Host "Converting $file..." -ForegroundColor Yellow
        node scripts/convert-node-red-flows.js $file
        Write-Host ""
    } else {
        Write-Host "⚠️  File not found: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ All flow files have been converted!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Converted files are available in node-red/flows/ with '-converted.json' suffix" -ForegroundColor Cyan
Write-Host "📖 See node-red/flows/README.md for import instructions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 