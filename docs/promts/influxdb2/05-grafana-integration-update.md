# Grafana Integration Update for InfluxDB 2.x

## Prompt for Cursor IDE

Update my Grafana configuration to work with InfluxDB 2.x.

## Requirements

1. **Update data source configuration**
2. **Modify query syntax** in dashboards
3. **Update connection settings**
4. **Fix any broken panels**
5. **Update environment variables** for InfluxDB connection

## Current Setup

The dashboards should display renewable energy data from:
- Photovoltaic systems
- Wind turbines
- Biogas plants
- Heat boilers
- Energy storage systems

## Grafana Configuration Updates

### Data Source Configuration
- **Type**: InfluxDB
- **Version**: Flux (InfluxDB 2.x)
- **URL**: `http://influxdb:8086`
- **Database**: `renewable_energy`
- **Organization**: `renewable_energy_org`
- **Authentication**: Admin token or username/password

### Dashboard Updates Required

#### 1. Data Source Settings
- **Connection**: Update to InfluxDB 2.x data source
- **Authentication**: Configure admin credentials or token
- **Database**: Set to `renewable_energy`
- **Organization**: Set to `renewable_energy_org`

#### 2. Query Updates
- **Query language**: Convert from InfluxQL to Flux
- **Measurement names**: Update to match InfluxDB 2.x structure
- **Field names**: Update to match new data structure
- **Tag names**: Update device_id, location, status tags

#### 3. Panel Configuration
- **Time series panels**: Update for InfluxDB 2.x data format
- **Stat panels**: Update for new field structure
- **Table panels**: Update column mappings
- **Graph panels**: Update series and legend configuration

### Environment Variables

Update Grafana environment variables:
- **GF_INSTALL_PLUGINS**: Ensure InfluxDB plugin is installed
- **GF_SECURITY_ADMIN_USER**: Grafana admin user
- **GF_SECURITY_ADMIN_PASSWORD**: Grafana admin password
- **INFLUXDB_URL**: `http://influxdb:8086`
- **INFLUXDB_DB**: `renewable_energy`
- **INFLUXDB_ORG**: `renewable_energy_org`
- **INFLUXDB_TOKEN**: Admin token

## Dashboard-Specific Updates

### 1. Renewable Energy Overview Dashboard
- **Total power output**: Sum across all device types
- **Device status**: Count of operational vs. offline devices
- **Energy production**: Daily/weekly/monthly totals
- **System efficiency**: Average efficiency across all devices

### 2. Photovoltaic Monitoring Dashboard
- **Power output**: Real-time and historical power generation
- **Temperature**: Panel temperature monitoring
- **Efficiency**: Conversion efficiency over time
- **Irradiance**: Solar irradiance correlation

### 3. Wind Turbine Analytics Dashboard
- **Power curve**: Power output vs. wind speed
- **Rotor speed**: RPM monitoring and trends
- **Direction**: Wind direction analysis
- **Vibration**: Vibration monitoring for maintenance

### 4. Biogas Plant Metrics Dashboard
- **Gas flow**: Methane production rates
- **Concentration**: Methane concentration monitoring
- **Temperature**: Process temperature control
- **Pressure**: System pressure monitoring

### 5. Heat Boiler Monitoring Dashboard
- **Temperature**: Boiler temperature monitoring
- **Efficiency**: Thermal efficiency calculations
- **Fuel consumption**: Fuel usage tracking
- **Pressure**: System pressure monitoring

### 6. Energy Storage Monitoring Dashboard
- **State of charge**: Battery charge level
- **Voltage/Current**: Electrical parameters
- **Temperature**: Battery temperature monitoring
- **Cycle count**: Charge/discharge cycles

## Query Examples

### Flux Query Examples
Provide updated Flux queries for:
1. **Device power output**: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "device_data" and r.device_type == "photovoltaic")`
2. **System efficiency**: `from(bucket: "renewable_energy") |> range(start: -24h) |> filter(fn: (r) => r._field == "efficiency") |> mean()`
3. **Device status**: `from(bucket: "renewable_energy") |> range(start: -5m) |> filter(fn: (r) => r._field == "status") |> group(columns: ["device_type"]) |> count()`

## Expected Output

### Updated Grafana Configuration
1. **Data source configuration** - Updated InfluxDB 2.x data source
2. **Dashboard JSON exports** - Updated dashboard configurations
3. **Provisioning files** - Data source and dashboard provisioning
4. **Environment variables** - Updated environment configuration

### Documentation
1. **Migration guide** - Step-by-step migration instructions
2. **Query reference** - Flux query examples and syntax
3. **Dashboard configuration** - Panel and query configuration
4. **Troubleshooting guide** - Common issues and solutions

## Context

This is for a renewable energy monitoring system that requires:
- **Real-time monitoring**: Live data display
- **Historical analysis**: Trend analysis and reporting
- **Alerting**: Threshold-based alerts
- **Performance optimization**: Efficient queries for large datasets

The Grafana dashboards should provide comprehensive visualization of all renewable energy systems with proper InfluxDB 2.x integration. 