# Node-RED Flow Updates for InfluxDB 2.x

## Prompt for Cursor IDE

Update the existing Node-RED flow files to work with InfluxDB 2.x configuration, focusing only on the InfluxDB node configurations within the flows.

## Current State Analysis

### ✅ What's Already Working
- **Node-RED flows are already configured for InfluxDB 2.x** (not 3.x as initially assumed)
- **InfluxDB 2.x configuration exists** in all flow files with proper settings
- **Docker Compose integration** is already set up with InfluxDB 2.x service
- **MQTT to InfluxDB data flow** is established in all device simulations

### 🔧 Current Configuration Status
- **InfluxDB nodes**: Already using `influxdbVersion: "2.0"` and `url: "http://influxdb:8086"`
- **Authentication**: Currently using empty token (needs simple static token for MVP)
- **Organization**: Set to `"renewable_energy"` (needs update to `"renewable_energy_org"`)
- **Bucket**: Set to `"renewable_energy"` (correct)
- **Database**: Set to `"renewable_energy"` (correct for InfluxDB 2.x)

### 📁 Existing Flow Files
1. **`v2.0-pv-mqtt-loop-simulation.json`** - PV simulation v2.0 (9.1KB, 216 lines)
2. **`v2.1-pv-mqtt-loop-simulation.json`** - PV simulation v2.1 (11KB, 274 lines)

## Requirements

1. **Update InfluxDB node configurations** to use simple static token authentication
2. **Fix organization name** from `"renewable_energy"` to `"renewable_energy_org"`
3. **Add simple static token** for MVP simplicity
4. **Migrate from InfluxQL to Flux** for future-proof standardization
5. **Keep changes minimal** - focus only on InfluxDB node configurations

## Node-RED Flow Updates Needed

### 1. Simple Static Token Authentication
For MVP simplicity, use a simple static token instead of complex environment variables:

**Simple Token Approach:**
```json
{
  "token": "renewable_energy_admin_token_123"
}
```

### 2. InfluxDB Node Configuration Updates
Update all InfluxDB configuration nodes in flow files:

**Current Configuration:**
```json
{
  "id": "influxdb-config",
  "type": "influxdb",
  "hostname": "influxdb",
  "port": "8086",
  "protocol": "http",
  "database": "renewable_energy",
  "name": "InfluxDB",
  "usetls": false,
  "tls": "",
  "influxdbVersion": "2.0",
  "url": "http://influxdb:8086",
  "rejectUnauthorized": false,
  "token": "", // NEEDS UPDATE - Add simple static token
  "organization": "renewable_energy", // NEEDS UPDATE - Change to "renewable_energy_org"
  "bucket": "renewable_energy"
}
```

**Required Updates:**
- **Token**: Add simple static token `"renewable_energy_admin_token_123"`
- **Organization**: Change from `"renewable_energy"` to `"renewable_energy_org"`
- **Query Language**: Update to use Flux instead of InfluxQL
- **Keep everything else unchanged** for MVP simplicity

### 3. Flux Query Language Migration
Update Node-RED InfluxDB nodes to use Flux queries:

**Current InfluxQL Approach:**
```javascript
// Node-RED currently uses InfluxQL (deprecated in InfluxDB 2.x)
// Example: SELECT * FROM photovoltaic_data WHERE time > now() - 1h
```

**New Flux Approach:**
```javascript
// Node-RED should use Flux (native to InfluxDB 2.x)
// Example: from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "photovoltaic_data")
```

**Flux Query Examples for Node-RED:**
```javascript
// Write data with Flux
const fluxQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -1h)
    |> filter(fn: (r) => r.device_type == "photovoltaic")
    |> filter(fn: (r) => r._field == "power_output")
    |> sum()
`;

// Read data with Flux
const readQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -5m)
    |> filter(fn: (r) => r.device_type == "photovoltaic")
    |> filter(fn: (r) => r._field == "power_output" or r._field == "efficiency")
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
`;
```

### 4. Flow-Specific Updates Required

#### Update All Flow Files:
1. **`v2.0-pv-mqtt-loop-simulation.json`** - 1 InfluxDB node
2. **`v2.1-pv-mqtt-loop-simulation.json`** - 1 InfluxDB node

### 5. Data Structure Validation
Current data structure is already correct for InfluxDB 2.x (no changes needed):

```json
{
  "device_id": "wt_001",
  "device_type": "wind_turbine",
  "location": "site_a",
  "status": "operational",
  "data": {
    "power_output": 1250.5,
    "wind_speed": 12.3,
    "wind_direction": 180,
    "rotor_speed": 15.2,
    "vibration": 0.05,
    "efficiency": 85.2
  }
}
```

## Expected Output

### 1. Updated Flow Files
- **All flow JSON files** - Updated InfluxDB configurations with simple static token

### 2. Simple Static Token Configuration
For each flow file, update the InfluxDB configuration node:
```json
{
  "id": "influxdb-config",
  "type": "influxdb",
  "hostname": "influxdb",
  "port": "8086",
  "protocol": "http",
  "database": "renewable_energy",
  "name": "InfluxDB",
  "usetls": false,
  "tls": "",
  "influxdbVersion": "2.0",
  "url": "http://influxdb:8086",
  "rejectUnauthorized": false,
  "token": "renewable_energy_admin_token_123",
  "organization": "renewable_energy_org",
  "bucket": "renewable_energy"
}
```

### 3. Flux Query Configuration
Update Node-RED function nodes to use Flux queries for data operations:

**Example Flux Query for Data Writing:**
```javascript
// In Node-RED function node
const fluxWriteQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -1h)
    |> filter(fn: (r) => r.device_type == "photovoltaic")
    |> filter(fn: (r) => r._field == "power_output")
    |> sum()
`;

// Send to InfluxDB node
msg.payload = {
  query: fluxWriteQuery,
  params: {
    bucket: "renewable_energy",
    org: "renewable_energy_org"
  }
};
```

**Example Flux Query for Data Reading:**
```javascript
// In Node-RED function node
const fluxReadQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -5m)
    |> filter(fn: (r) => r.device_type == "photovoltaic")
    |> filter(fn: (r) => r._field == "power_output" or r._field == "efficiency")
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
`;

// Send to InfluxDB query node
msg.payload = {
  query: fluxReadQuery,
  params: {
    bucket: "renewable_energy",
    org: "renewable_energy_org"
  }
};
```

## Implementation Strategy

### Phase 1: Preparation
1. **Test current configuration** to establish baseline

### Phase 2: Simple Configuration Updates
1. **Update InfluxDB configuration nodes** in all flow files
2. **Add simple static token** `"renewable_energy_admin_token_123"`
3. **Fix organization names** from "renewable_energy" to "renewable_energy_org"

### Phase 3: Flux Migration
1. **Update Node-RED function nodes** to use Flux queries
2. **Replace InfluxQL queries** with Flux syntax
3. **Test Flux query execution** in Node-RED flows

### Phase 4: Testing and Validation
1. **Test each device simulation** individually
2. **Verify data writing** to InfluxDB 2.x using Flux
3. **Validate token authentication** is working
4. **Test Flux query execution** in Node-RED
5. **Verify data consistency** between Node-RED and Grafana

## Context

This is for a renewable energy monitoring system that processes data from:
- **Photovoltaic panels**: Power output, temperature, voltage, current, irradiance, efficiency
- **Wind turbines**: Power output, wind speed, direction, rotor speed, vibration, efficiency
- **Biogas plants**: Gas flow, methane concentration, temperature, pressure, efficiency
- **Heat boilers**: Temperature, pressure, efficiency, fuel consumption, flow rate, output power
- **Energy storage**: State of charge, voltage, current, temperature, cycle count, health status

The Node-RED flows already have sophisticated mathematical models and data validation. The main updates needed are:
1. **Authentication configuration** (currently using empty tokens)
2. **Organization name correction** (currently "renewable_energy" should be "renewable_energy_org")
3. **Query language migration** (currently using InfluxQL, should use Flux)

## MVP Approach

### Simple Static Token Strategy
- **Use simple static token** `"renewable_energy_admin_token_123"` for all flows
- **No complex environment variables** - keep it simple for MVP
- **Single authentication method** across all device simulations
- **Easy to configure** and maintain

### Minimal Changes Philosophy
- **Only change what's necessary** for functionality
- **Keep existing sophisticated logic** unchanged
- **Focus on MVP simplicity** over production complexity
- **Preserve working data structures** and flow logic

## Migration Notes

### Key Differences from Initial Assumption
- **Not migrating from InfluxDB 3.x to 2.x** - already using 2.x
- **Flows are already configured** for InfluxDB 2.x
- **Data structure is correct** for InfluxDB 2.x
- **Main issue is authentication** and organization naming

### Minimal Changes Required
- Update organization name in all InfluxDB config nodes
- Add simple static token authentication
- Migrate from InfluxQL to Flux queries

### No Changes Needed
- Data structure and format (already correct)
- Flow logic and mathematical models (already sophisticated)
- MQTT integration (already working)
- Device simulation logic (already comprehensive)
- Environment variables (keep simple for MVP)
- Docker Compose configuration (covered by prompt 01)
- InfluxDB configuration files (covered by prompt 02)
- Environment variables setup (covered by prompt 03)
- Grafana integration (covered by prompt 05)
- Testing scripts (covered by prompt 06)
- Documentation creation (covered by prompt 07) 