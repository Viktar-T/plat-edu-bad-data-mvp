# Node-RED Integration Update for InfluxDB 2.x

## Prompt for Cursor IDE

Update my Node-RED configuration to work with InfluxDB 2.x instead of 3.x.

## Requirements

1. **Update InfluxDB node configurations**
2. **Modify connection settings** (URL, database, authentication)
3. **Update query syntax** from Flux to InfluxQL
4. **Fix any broken flows**
5. **Update environment variables** for InfluxDB connection

## Current Setup

The current setup uses MQTT to receive data and should write to InfluxDB 2.x. Data flows from:
- **MQTT Broker** → **Node-RED** → **InfluxDB 2.x**

## Node-RED Configuration Updates

### InfluxDB Node Settings
- **Server URL**: `http://influxdb:8086` (Docker service name)
- **Database**: `renewable_energy`
- **Organization**: `renewable_energy_org`
- **Authentication**: Admin token or username/password
- **Measurement**: Device-specific measurements

### Flow Updates Required

#### 1. InfluxDB Out Nodes
- **Connection settings**: Update to InfluxDB 2.x format
- **Authentication**: Use admin credentials or token
- **Measurement mapping**: Map device data to measurements
- **Tag configuration**: Set device_id, location, status as tags
- **Field configuration**: Set sensor values as fields

#### 2. InfluxDB In Nodes (if any)
- **Query syntax**: Convert from Flux to InfluxQL
- **Connection settings**: Update to InfluxDB 2.x format
- **Authentication**: Use admin credentials or token

#### 3. Function Nodes
- **Data transformation**: Update for InfluxDB 2.x data format
- **Error handling**: Add proper error handling for InfluxDB 2.x
- **Data validation**: Validate data before writing

### Environment Variables

Update Node-RED environment variables:
- **INFLUXDB_URL**: `http://influxdb:8086`
- **INFLUXDB_DB**: `renewable_energy`
- **INFLUXDB_ORG**: `renewable_energy_org`
- **INFLUXDB_TOKEN**: Admin token
- **INFLUXDB_USERNAME**: Admin username
- **INFLUXDB_PASSWORD**: Admin password

## Data Structure Mapping

### Device Data Structure
Map incoming MQTT data to InfluxDB 2.x format:

```json
{
  "device_id": "pv_001",
  "device_type": "photovoltaic",
  "location": "site_a",
  "status": "operational",
  "data": {
    "power_output": 584.43,
    "temperature": 45.2,
    "voltage": 48.3,
    "current": 12.1,
    "irradiance": 850.5
  }
}
```

### InfluxDB 2.x Format
Convert to InfluxDB 2.x line protocol or JSON format for the InfluxDB node.

## Expected Output

### Updated Node-RED Flows
Provide updated flow configurations for:
1. **Photovoltaic data processing**
2. **Wind turbine data processing**
3. **Biogas plant data processing**
4. **Heat boiler data processing**
5. **Energy storage data processing**

### Configuration Files
1. **settings.js updates** - Environment variables
2. **Flow JSON exports** - Updated flow configurations
3. **Function node code** - Updated JavaScript functions
4. **Error handling** - Proper error handling for InfluxDB 2.x

### Documentation
1. **Migration guide** - Step-by-step migration instructions
2. **Configuration reference** - All settings and options
3. **Troubleshooting guide** - Common issues and solutions
4. **Testing procedures** - How to verify the integration

## Context

This is for a renewable energy monitoring system that processes data from:
- **Photovoltaic panels**: Power output, temperature, voltage, current, irradiance
- **Wind turbines**: Power output, wind speed, direction, rotor speed
- **Biogas plants**: Gas flow, methane concentration, temperature, pressure
- **Heat boilers**: Temperature, pressure, efficiency, fuel consumption
- **Energy storage**: State of charge, voltage, current, temperature

The Node-RED flows should handle data validation, transformation, and reliable writing to InfluxDB 2.x. 