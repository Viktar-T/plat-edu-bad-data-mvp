@echo off
echo Converting all Node-RED flow files to proper import format...
echo.

cd /d "%~dp0.."

echo Converting energy-storage-simulation.json...
node scripts/convert-node-red-flows.js node-red/flows/energy-storage-simulation.json
echo.

echo Converting heat-boiler-simulation.json...
node scripts/convert-node-red-flows.js node-red/flows/heat-boiler-simulation.json
echo.

echo Converting biogas-plant-simulation.json...
node scripts/convert-node-red-flows.js node-red/flows/biogas-plant-simulation.json
echo.

echo Converting wind-turbine-simulation.json...
node scripts/convert-node-red-flows.js node-red/flows/wind-turbine-simulation.json
echo.

echo Converting renewable-energy-simulation.json...
node scripts/convert-node-red-flows.js node-red/flows/renewable-energy-simulation.json
echo.

echo.
echo ✅ All flow files have been converted!
echo.
echo 📁 Converted files are available in node-red/flows/ with "-converted.json" suffix
echo 📖 See node-red/flows/README.md for import instructions
echo.
pause 