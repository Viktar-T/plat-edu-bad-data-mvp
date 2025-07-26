# Node-RED Flow Files

This directory contains Node-RED flow files for the Renewable Energy IoT Monitoring System.

## File Structure

### Original Files (Custom Format - NOT for Node-RED Import)
These files use a custom format and should NOT be imported directly into Node-RED:
- `renewable-energy-simulation.json` - Complete simulation with all device types
- `energy-storage-simulation.json` - Energy storage system simulation
- `heat-boiler-simulation.json` - Heat boiler simulation
- `biogas-plant-simulation.json` - Biogas plant simulation
- `wind-turbine-simulation.json` - Wind turbine simulation
- `pv-simulation.json` - Photovoltaic panel simulation

### Converted Files (Proper Node-RED Format)
These files are properly formatted for Node-RED import:
- `renewable-energy-simulation-converted.json` - Complete simulation (44 nodes)
- `energy-storage-simulation-converted.json` - Energy storage simulation (9 nodes)
- `heat-boiler-simulation-converted.json` - Heat boiler simulation (9 nodes)
- `biogas-plant-simulation-converted.json` - Biogas plant simulation (9 nodes)
- `wind-turbine-simulation-converted.json` - Wind turbine simulation (9 nodes)
- `pv-simulation-converted.json` - Photovoltaic simulation (9 nodes)
- `renewable-energy-simulation-fixed.json` - Alternative complete simulation (341 lines)

## Import Instructions

### For Node-RED Import:
1. Use the `*-converted.json` files
2. In Node-RED, go to Menu → Import
3. Select "Clipboard" or "File"
4. Choose the converted file you want to import
5. Click "Import"

### Available Simulations:

#### 1. Complete System (`renewable-energy-simulation-converted.json`)
- **Nodes**: 44 total
- **Includes**: All 5 device types (photovoltaic, wind turbine, biogas plant, heat boiler, energy storage)
- **Features**: Data validation, error handling, MQTT publishing, InfluxDB storage
- **Use Case**: Full system simulation and testing

#### 2. Individual Device Simulations
Each individual simulation contains:
- **Nodes**: 9 total
- **Components**: Inject node, data generator function, MQTT output, validation, error handling, InfluxDB storage
- **Use Case**: Testing specific device types or development

**Available Individual Simulations:**
- **Photovoltaic (`pv-simulation.json`)**: Solar panel data with irradiance, temperature, voltage, current, power output, and efficiency calculations
- **Wind Turbine (`wind-turbine-simulation.json`)**: Wind turbine data with wind speed, direction, rotor speed, vibration, and power output
- **Biogas Plant (`biogas-plant-simulation.json`)**: Biogas plant data with gas flow, methane concentration, temperature, and power output
- **Heat Boiler (`heat-boiler-simulation.json`)**: Heat boiler data with temperature, pressure, flow rate, and efficiency
- **Energy Storage (`energy-storage-simulation.json`)**: Battery storage data with state of charge, voltage, current, and temperature

### Node Types Summary:
- **inject**: Timer nodes (30-second intervals)
- **function**: Data generation and validation logic
- **mqtt out**: MQTT message publishing
- **switch**: Error handling and routing
- **influxdb out**: Data storage to InfluxDB
- **debug**: Error logging
- **mqtt-broker**: MQTT broker configuration
- **influxdb**: InfluxDB connection configuration

## Configuration Requirements

Before importing, ensure you have:

1. **MQTT Broker** (Mosquitto) running on `mosquitto:1883`
2. **InfluxDB** running on `influxdb:8086`
3. **Organization**: `renewable_energy`
4. **Bucket**: `iot_data`
5. **Token**: Update the InfluxDB token in the configuration nodes

## Data Flow

```
Inject Node (30s) → Data Generator → MQTT Output
                           ↓
                    Data Validation → Error Check → InfluxDB Storage
                           ↓
                      Error Logging
```

## Troubleshooting

### Common Import Issues:
1. **"Input not a JSON Array"** - Make sure you're using the `*-converted.json` files
2. **Missing broker/config** - Configure MQTT broker and InfluxDB connections
3. **Connection errors** - Ensure Docker services are running

### Validation:
- All converted files start with `[` and end with `]`
- Each node has proper `id`, `type`, and `z` properties
- Wires arrays are properly formatted

## Conversion Script

If you need to convert additional flow files, use:
```bash
node scripts/convert-node-red-flows.js <input-file> [output-file]
```

This script converts the custom format to the proper Node-RED import format. 