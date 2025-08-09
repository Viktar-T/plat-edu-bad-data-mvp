# Grafana Integration Update for InfluxDB 2.x

## Cursor IDE Agent Instructions

You are tasked with updating the Grafana integration to work with InfluxDB 2.x. This is a critical component of a renewable energy IoT monitoring system where Node-RED has already been migrated to use Flux queries and InfluxDB 2.x.

## Current System State

### ✅ Working Components
- **Node-RED**: Successfully migrated to InfluxDB 2.x with Flux queries
- **Node-RED Token**: Using `"renewable_energy_admin_token_123"`
- **Node-RED Organization**: Using `"renewable_energy_org"`
- **InfluxDB 2.x**: Running on port 8086 with proper configuration
- **Grafana Dashboards**: 6 comprehensive dashboards with Flux queries
- **Docker Compose**: All services properly configured

### 🔧 Current Grafana Configuration Issues
- **Data Source Name**: `"InfluxDB 3.x"` (incorrect - should be `"InfluxDB 2.x"`)
- **Organization**: `"renewable_energy"` (incorrect - should be `"renewable_energy_org"`)
- **Token**: `${INFLUXDB_TOKEN:-}` (environment variable - should be static token)
- **Dashboard References**: 67 total datasource references need updating

## Required Changes

### 1. Update Data Source Configuration
**File**: `grafana/provisioning/datasources/influxdb.yaml`

**Current Configuration**:
```yaml
apiVersion: 1

datasources:
  - name: InfluxDB 3.x
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    isDefault: true
    editable: true
    jsonData:
      version: Flux
      organization: renewable_energy
      defaultBucket: renewable_energy
      tlsSkipVerify: true
    secureJsonData:
      token: ${INFLUXDB_TOKEN:-}
```

**Required Configuration**:
```yaml
apiVersion: 1

datasources:
  - name: InfluxDB 2.x
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    isDefault: true
    editable: true
    jsonData:
      version: Flux
      organization: renewable_energy_org
      defaultBucket: renewable_energy
      tlsSkipVerify: true
    secureJsonData:
      token: renewable_energy_admin_token_123
```

### 2. Update Dashboard Datasource References
**Files to Update**:
1. `grafana/dashboards/renewable-energy-overview.json` (8 references)
2. `grafana/dashboards/photovoltaic-monitoring.json` (11 references)
3. `grafana/dashboards/wind-turbine-analytics.json` (12 references)
4. `grafana/dashboards/biogas-plant-metrics.json` (12 references)
5. `grafana/dashboards/heat-boiler-monitoring.json` (12 references)
6. `grafana/dashboards/energy-storage-monitoring.json` (12 references)

**Change Required**:
- **From**: `"datasource": "InfluxDB 3.x"`
- **To**: `"datasource": "InfluxDB 2.x"`

## Implementation Steps

### Step 1: Update Data Source Configuration
1. Open `grafana/provisioning/datasources/influxdb.yaml`
2. Change `name: InfluxDB 3.x` to `name: InfluxDB 2.x`
3. Change `organization: renewable_energy` to `organization: renewable_energy_org`
4. Change `token: ${INFLUXDB_TOKEN:-}` to `token: renewable_energy_admin_token_123`
5. Save the file

### Step 2: Update Dashboard Files
For each dashboard file, perform a search and replace:
- **Search for**: `"datasource": "InfluxDB 3.x"`
- **Replace with**: `"datasource": "InfluxDB 2.x"`

**Files to process**:
```
grafana/dashboards/renewable-energy-overview.json
grafana/dashboards/photovoltaic-monitoring.json
grafana/dashboards/wind-turbine-analytics.json
grafana/dashboards/biogas-plant-metrics.json
grafana/dashboards/heat-boiler-monitoring.json
grafana/dashboards/energy-storage-monitoring.json
```

### Step 3: Verify Changes
1. **Count total replacements**: Should be exactly 67 datasource references updated
2. **Validate JSON syntax**: Ensure all dashboard files remain valid JSON
3. **Check data source configuration**: Verify the YAML syntax is correct

## Expected Results

### After Implementation
- **Data Source**: Grafana will connect to InfluxDB 2.x using the correct organization and token
- **Dashboards**: All 6 dashboards will reference the updated data source
- **Authentication**: Unified token authentication across Node-RED and Grafana
- **Data Flow**: Complete end-to-end data flow from Node-RED → InfluxDB 2.x → Grafana

### Verification Checklist
- [ ] Data source configuration updated in `influxdb.yaml`
- [ ] All 6 dashboard files updated
- [ ] Exactly 67 datasource references changed
- [ ] All JSON files remain valid
- [ ] YAML configuration syntax is correct
- [ ] Token matches Node-RED configuration (`renewable_energy_admin_token_123`)
- [ ] Organization matches Node-RED configuration (`renewable_energy_org`)

## Technical Context

### System Architecture
```
Node-RED → InfluxDB 2.x → Grafana
   ↓           ↓           ↓
Flux Queries  Flux Queries  Flux Queries
   ↓           ↓           ↓
renewable_energy_admin_token_123
   ↓           ↓           ↓
renewable_energy_org organization
```

### Data Flow
1. **Node-RED** writes renewable energy data using Flux queries
2. **InfluxDB 2.x** stores data in `renewable_energy` bucket
3. **Grafana** reads and visualizes data using Flux queries
4. **Unified authentication** ensures consistent access across all components

### Renewable Energy Data Types
- **Photovoltaic**: Power output, temperature, voltage, current, irradiance, efficiency
- **Wind Turbines**: Power output, wind speed, direction, rotor speed, vibration, efficiency
- **Biogas Plants**: Gas flow, methane concentration, temperature, pressure, efficiency
- **Heat Boilers**: Temperature, pressure, efficiency, fuel consumption, flow rate, output power
- **Energy Storage**: State of charge, voltage, current, temperature, cycle count, health status

## Important Notes

### Do Not Change
- **Flux query syntax** - already correct for InfluxDB 2.x
- **Dashboard layouts** - preserve existing visualizations
- **Panel configurations** - keep existing styling and functionality
- **Data structure** - maintain current field names and measurements

### Critical Dependencies
- **Node-RED must be running** with InfluxDB 2.x configuration
- **InfluxDB 2.x must be accessible** on port 8086
- **Docker Compose services** must be properly started
- **Token authentication** must be consistent across all components

### Error Prevention
- **Backup files** before making changes
- **Validate JSON syntax** after each file update
- **Test data source connectivity** after configuration changes
- **Verify dashboard functionality** after all updates

## Success Criteria

### Primary Goals
1. **Grafana connects** to InfluxDB 2.x successfully
2. **All dashboards display** data correctly
3. **Authentication works** with static token
4. **Data flow is complete** from Node-RED to Grafana

### Secondary Goals
1. **Consistent naming** across all components
2. **Proper organization** structure in InfluxDB 2.x
3. **Unified authentication** method
4. **Future-proof configuration** for scalability

## Next Steps After Implementation

1. **Test data source connectivity** in Grafana UI
2. **Verify dashboard panels** display data
3. **Check query execution** in Grafana
4. **Validate data consistency** between Node-RED and Grafana
5. **Document configuration** for future reference

## Troubleshooting

### Common Issues
- **Connection refused**: Check if InfluxDB 2.x is running on port 8086
- **Authentication failed**: Verify token matches Node-RED configuration
- **No data displayed**: Check if Node-RED is writing data to InfluxDB 2.x
- **JSON syntax errors**: Validate dashboard files after updates

### Verification Commands
```bash
# Check InfluxDB 2.x connectivity
curl -f http://localhost:8086/health

# Check Grafana connectivity
curl -f http://localhost:3000/api/health

# Verify data source in Grafana
curl -f http://localhost:3000/api/datasources
```

This prompt provides clear, actionable instructions for updating Grafana integration to work with InfluxDB 2.x while maintaining system consistency and functionality. 