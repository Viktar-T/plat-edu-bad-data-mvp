# Node-RED Flows Analysis Summary

## Overview
This document provides a comprehensive analysis of the Node-RED flows folder for the Renewable Energy IoT Monitoring System MVP.

## File Structure Analysis

### Current Files
1. **`renewable-energy-simulation.json`** (47KB, 845 lines)
   - **Type**: Complete system simulation
   - **Nodes**: 44 total nodes
   - **Scope**: All 5 device types (photovoltaic, wind turbine, biogas plant, heat boiler, energy storage)
   - **Status**: Main simulation file, contains all device simulations

2. **`wind-turbine-simulation.json`** (11KB, 196 lines)
   - **Type**: Individual device simulation
   - **Nodes**: 9 total nodes
   - **Scope**: Wind turbine only
   - **Status**: Standalone simulation

3. **`biogas-plant-simulation.json`** (9.7KB, 196 lines)
   - **Type**: Individual device simulation
   - **Nodes**: 9 total nodes
   - **Scope**: Biogas plant only
   - **Status**: Standalone simulation

4. **`heat-boiler-simulation.json`** (9.0KB, 196 lines)
   - **Type**: Individual device simulation
   - **Nodes**: 9 total nodes
   - **Scope**: Heat boiler only
   - **Status**: Standalone simulation

5. **`energy-storage-simulation.json`** (11KB, 196 lines)
   - **Type**: Individual device simulation
   - **Nodes**: 9 total nodes
   - **Scope**: Energy storage only
   - **Status**: Standalone simulation

6. **`pv-simulation.json`** (NEW - 12KB, 196 lines)
   - **Type**: Individual device simulation
   - **Nodes**: 9 total nodes
   - **Scope**: Photovoltaic panels only
   - **Status**: NEW - Standalone simulation with enhanced features

## Photovoltaic Simulation Analysis

### New File: `pv-simulation.json`

#### Key Features
- **Enhanced Mathematical Models**: More realistic solar irradiance, temperature, and efficiency calculations
- **Efficiency Calculation**: Includes panel efficiency with temperature, aging, and dirt effects
- **Cloud Cover Simulation**: Random cloud cover effects on irradiance
- **Enhanced Fault Scenarios**: 5 different fault types (shading, temperature, connection, microcrack, inverter)
- **Improved Validation**: Comprehensive data validation including efficiency consistency checks

#### Data Fields Generated
1. **`irradiance`** (W/m²): Solar irradiance with seasonal, daily, and cloud cover variations
2. **`temperature`** (°C): Panel temperature with ambient, seasonal, and operational effects
3. **`voltage`** (V): Voltage with temperature coefficient and irradiance effects
4. **`current`** (A): Current based on irradiance and temperature
5. **`power_output`** (W): Power output considering efficiency
6. **`efficiency`** (%): Panel efficiency with multiple degradation factors

#### Mathematical Models

##### Solar Irradiance Model
```javascript
// Seasonal variation (peak in summer)
const seasonalFactor = 0.5 + 0.5 * Math.cos(2 * Math.PI * (dayOfYear - 172) / 365);

// Daily variation (peak at solar noon)
const dailyFactor = Math.max(0, Math.cos(Math.PI * (hour - solarNoon) / 12));

// Cloud cover effect (random)
const cloudCover = Math.random() < 0.3 ? (0.3 + Math.random() * 0.4) : 1.0;
```

##### Efficiency Model
```javascript
// Base efficiency (typical for modern panels)
const baseEfficiency = 20.0; // 20% efficiency

// Temperature effect (efficiency decreases with temperature)
const tempEffect = -0.004 * (temp - 25); // -0.4% per °C above 25°C

// Aging effect (gradual degradation over time)
const agingEffect = -0.5 * (daysSinceInstallation / 365); // -0.5% per year

// Dirt effect (random)
const dirtEffect = Math.random() < 0.1 ? -Math.random() * 0.05 : 0; // 10% chance of dirt
```

#### Fault Scenarios
1. **Shading Fault**: Reduces irradiance and current by 70%, efficiency by 20%
2. **Temperature Fault**: Increases temperature by 30°C, reduces voltage and efficiency
3. **Connection Fault**: Reduces voltage and current by 50%, efficiency by 40%
4. **Microcrack Fault**: Reduces efficiency by 50%, voltage by 10%
5. **Inverter Fault**: Reduces efficiency by 70%, power output by 70%

#### Validation Features
- **Range Validation**: All parameters within realistic bounds
- **Physical Consistency**: Power output vs. voltage/current relationship
- **Efficiency Consistency**: Calculated vs. reported efficiency comparison
- **Logical Checks**: Irradiance vs. power output relationship

## Comparison with Existing Photovoltaic Simulation

### Original (in renewable-energy-simulation.json)
- Basic irradiance and temperature models
- Simple fault scenarios (3 types)
- No efficiency calculation
- Basic validation

### New Standalone (pv-simulation.json)
- Enhanced mathematical models with cloud cover
- Comprehensive efficiency calculation
- Extended fault scenarios (5 types)
- Advanced validation with efficiency consistency
- Better documentation and comments

## Node Structure Analysis

### Common Node Pattern (All Individual Simulations)
1. **Inject Node**: 30-second timer trigger
2. **Function Node**: Data generation with realistic models
3. **MQTT Output**: Publish to MQTT broker
4. **Validation Function**: Data validation and error checking
5. **Switch Node**: Route valid/invalid data
6. **InfluxDB Output**: Store valid data
7. **Debug Node**: Log validation errors
8. **MQTT Broker Config**: Connection configuration
9. **InfluxDB Config**: Database connection configuration

### Node Count Summary
- **Individual Simulations**: 9 nodes each
- **Complete Simulation**: 44 nodes (all devices + shared configs)
- **Total Files**: 6 simulation files

## Data Flow Architecture

```
Timer (30s) → Data Generator → MQTT Output
                    ↓
              Data Validation → Error Check → InfluxDB Storage
                    ↓
                  Error Logging
```

## MQTT Topic Structure
- **Format**: `devices/{device_type}/{device_id}/telemetry`
- **Example**: `devices/photovoltaic/pv_001/telemetry`
- **QoS**: Level 1 (reliable delivery)
- **Retain**: false (real-time data)

## InfluxDB Integration
- **Measurement**: `photovoltaic_data`
- **Organization**: `renewable_energy`
- **Bucket**: `iot_data`
- **Tags**: device_id, location, device_type, status
- **Fields**: All sensor data (irradiance, temperature, voltage, current, power_output, efficiency)

## Recommendations

### Immediate Actions
1. **Convert to Node-RED Format**: Use the conversion script to create `pv-simulation-converted.json`
2. **Update Documentation**: Include the new simulation in all relevant documentation
3. **Test Integration**: Verify MQTT and InfluxDB connectivity

### Future Enhancements
1. **Add More Fault Types**: Include more realistic photovoltaic fault scenarios
2. **Enhance Models**: Add more sophisticated solar position calculations
3. **Add Weather Integration**: Real weather data integration for more realistic simulation
4. **Performance Optimization**: Batch processing for high-frequency data

### Quality Assurance
1. **Data Validation**: All simulations include comprehensive validation
2. **Error Handling**: Proper error logging and handling
3. **Documentation**: Well-documented mathematical models
4. **Consistency**: Follows established patterns and conventions

## Conclusion

The Node-RED flows folder now contains a complete set of renewable energy device simulations, with the new `pv-simulation.json` providing enhanced photovoltaic simulation capabilities. The standalone photovoltaic simulation offers more realistic data generation, comprehensive fault scenarios, and improved validation compared to the version included in the main simulation file.

All simulations follow consistent patterns and are ready for integration with the MQTT broker and InfluxDB database. The modular approach allows for individual testing and development of specific device types while maintaining the option to run the complete system simulation. 