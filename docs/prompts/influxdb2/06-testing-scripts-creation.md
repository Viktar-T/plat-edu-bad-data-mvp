# Testing Scripts Creation for InfluxDB 2.x

## Cursor IDE Agent Instructions

You are tasked with creating comprehensive testing scripts for the InfluxDB 2.x setup in a renewable energy IoT monitoring system. This system has already been configured with Node-RED using Flux queries, Grafana dashboards, and unified authentication.

## Current System State

### ✅ Working Components
- **InfluxDB 2.x**: Running on port 8086 with proper configuration
- **Node-RED**: Successfully migrated to InfluxDB 2.x with Flux queries
- **Node-RED Token**: Using `"renewable_energy_admin_token_123"`
- **Node-RED Organization**: Using `"renewable_energy_org"`
- **Grafana**: Updated to use InfluxDB 2.x with 67 datasource references
- **Docker Compose**: All services properly configured and integrated
- **MQTT Broker**: Mosquitto running and configured

### 🔧 Current Configuration Details
- **InfluxDB URL**: `http://influxdb:8086` (container) / `http://localhost:8086` (host)
- **Organization**: `"renewable_energy_org"`
- **Bucket**: `"renewable_energy"`
- **Token**: `"renewable_energy_admin_token_123"`
- **Query Language**: Flux (standardized across all components)
- **Data Flow**: MQTT → Node-RED → InfluxDB 2.x → Grafana

### 📁 Existing Test Infrastructure
- **Manual Tests**: Located in `tests/manual-tests/`
- **Test Scripts**: `test-mqtt.ps1`, `simulate-devices.ps1`
- **Test Documentation**: 6 comprehensive manual test guides
- **Test Environment**: PowerShell-based testing framework

## Required Testing Scripts

### 1. InfluxDB 2.x Health Check Scripts
**Purpose**: Verify InfluxDB 2.x service status and connectivity

**Requirements**:
- **Service Status**: Check if InfluxDB container is running
- **HTTP Endpoint**: Test port 8086 accessibility
- **Authentication**: Test token-based authentication
- **Organization Access**: Verify organization exists
- **Bucket Access**: Verify bucket exists and is accessible

### 2. Data Flow Testing Scripts
**Purpose**: Test complete data flow from MQTT to Grafana

**Requirements**:
- **MQTT Message Publishing**: Send test messages to MQTT broker
- **Node-RED Processing**: Verify data transformation in Node-RED
- **InfluxDB Writing**: Confirm data is written to InfluxDB 2.x
- **Grafana Reading**: Verify data appears in Grafana dashboards
- **End-to-End Validation**: Complete flow verification

### 3. Flux Query Testing Scripts
**Purpose**: Test Flux query execution and data retrieval

**Requirements**:
- **Basic Queries**: Simple data retrieval from InfluxDB 2.x
- **Aggregation Queries**: Sum, mean, count operations
- **Time Range Queries**: Time-based filtering
- **Device-Specific Queries**: Filtering by device type
- **Performance Tests**: Query response time validation

### 4. Integration Testing Scripts
**Purpose**: Test component integration and data consistency

**Requirements**:
- **Node-RED to InfluxDB**: Test data writing with Flux
- **Grafana to InfluxDB**: Test data reading with Flux
- **Token Authentication**: Verify unified authentication
- **Organization Consistency**: Verify consistent organization usage
- **Data Format Validation**: Verify Flux-compatible data structure

## Script Requirements

### PowerShell Scripts (Primary - Windows Environment)
**File Structure**:
```
tests/
├── scripts/
│   ├── test-influxdb-health.ps1
│   ├── test-data-flow.ps1
│   ├── test-flux-queries.ps1
│   ├── test-integration.ps1
│   └── test-performance.ps1
├── data/
│   ├── test-messages/
│   └── expected-results/
└── logs/
    └── test-results/
```

**Script Features**:
- **Error Handling**: Comprehensive error handling and logging
- **Configuration**: Use existing system configuration (token, organization, bucket)
- **Reporting**: Generate detailed test reports
- **Validation**: Compare actual vs expected results
- **Cleanup**: Clean up test data after execution

### JavaScript Tests (Node.js - API Testing)
**File Structure**:
```
tests/
├── javascript/
│   ├── test-influxdb-api.js
│   ├── test-mqtt-connection.js
│   ├── test-nodered-flows.js
│   └── test-grafana-api.js
├── package.json
└── test-config.json
```

**Script Features**:
- **API Testing**: Direct InfluxDB 2.x API testing
- **MQTT Testing**: Message publishing and subscription
- **Node-RED Testing**: Flow execution validation
- **Grafana Testing**: Dashboard and datasource testing

## Test Data Requirements

### Device Simulation Data
**Photovoltaic Data**:
```json
{
  "device_id": "pv_test_001",
  "device_type": "photovoltaic",
  "location": "test_site",
  "status": "operational",
  "data": {
    "power_output": 2500.5,
    "temperature": 45.2,
    "voltage": 48.5,
    "current": 51.5,
    "irradiance": 850.0,
    "efficiency": 0.18
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Wind Turbine Data**:
```json
{
  "device_id": "wt_test_001",
  "device_type": "wind_turbine",
  "location": "test_site",
  "status": "operational",
  "data": {
    "power_output": 1800.0,
    "wind_speed": 12.5,
    "wind_direction": 180,
    "rotor_speed": 15.2,
    "vibration": 0.05,
    "efficiency": 0.35
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Test Scenarios
1. **Normal Operation**: Standard data flow with valid data
2. **High Load**: Multiple devices sending data simultaneously
3. **Error Conditions**: Invalid data, network issues, service failures
4. **Recovery**: Service restart and data persistence
5. **Performance**: Load testing with high-frequency data

## Expected Output

### PowerShell Scripts
1. **`test-influxdb-health.ps1`** - Comprehensive health check script
   - Service status verification
   - HTTP endpoint testing
   - Authentication validation
   - Organization and bucket verification

2. **`test-data-flow.ps1`** - End-to-end data flow testing
   - MQTT message publishing
   - Node-RED flow execution
   - InfluxDB data writing
   - Grafana data reading

3. **`test-flux-queries.ps1`** - Flux query testing
   - Basic data retrieval
   - Aggregation operations
   - Time-based filtering
   - Performance validation

4. **`test-integration.ps1`** - Component integration testing
   - Cross-component authentication
   - Data consistency validation
   - Error handling verification

5. **`test-performance.ps1`** - Performance and load testing
   - Query response times
   - Data throughput testing
   - Resource usage monitoring

### JavaScript Tests
1. **`test-influxdb-api.js`** - Direct InfluxDB 2.x API testing
2. **`test-mqtt-connection.js`** - MQTT connectivity testing
3. **`test-nodered-flows.js`** - Node-RED flow validation
4. **`test-grafana-api.js`** - Grafana API testing

### Test Configuration
1. **`test-config.json`** - Test configuration file
2. **`package.json`** - Node.js dependencies
3. **Test data files** - Sample data for testing
4. **Expected results** - Baseline results for validation

## Implementation Strategy

### Phase 1: Health Check Scripts
1. **Create PowerShell health check script**
2. **Test InfluxDB 2.x service status**
3. **Verify HTTP endpoint accessibility**
4. **Validate authentication and permissions**

### Phase 2: Data Flow Testing
1. **Create end-to-end data flow script**
2. **Test MQTT to InfluxDB 2.x flow**
3. **Verify Node-RED data transformation**
4. **Validate Grafana data display**

### Phase 3: Query Testing
1. **Create Flux query testing script**
2. **Test basic data retrieval**
3. **Validate aggregation operations**
4. **Verify performance metrics**

### Phase 4: Integration Testing
1. **Create integration testing script**
2. **Test cross-component authentication**
3. **Validate data consistency**
4. **Verify error handling**

## Success Criteria

### Primary Goals
1. **All services accessible** and responding correctly
2. **Data flow complete** from MQTT to Grafana
3. **Flux queries execute** successfully
4. **Authentication works** across all components
5. **Performance meets** expected benchmarks

### Secondary Goals
1. **Comprehensive error handling** in all scripts
2. **Detailed test reporting** with clear results
3. **Automated test execution** capability
4. **Easy test maintenance** and updates
5. **Integration with existing** test infrastructure

## Context

This testing framework is for a renewable energy monitoring system that requires:
- **Reliability**: System must be stable and reliable
- **Performance**: Fast response times for queries and data processing
- **Scalability**: Handle multiple devices and high-frequency data
- **Monitoring**: Comprehensive system monitoring and alerting
- **Integration**: Seamless integration between all components

The testing scripts should provide confidence that the InfluxDB 2.x setup is working correctly and can handle the expected workload while maintaining data integrity and system performance.

## Integration with Existing Infrastructure

### Leverage Existing Components
- **Use existing token**: `"renewable_energy_admin_token_123"`
- **Use existing organization**: `"renewable_energy_org"`
- **Use existing bucket**: `"renewable_energy"`
- **Use existing test data**: Leverage existing device simulation data
- **Use existing test framework**: Extend current PowerShell testing approach

### Avoid Duplication
- **Don't recreate** Docker Compose configuration (covered by prompt 01)
- **Don't recreate** InfluxDB configuration files (covered by prompt 02)
- **Don't recreate** environment variables (covered by prompt 03)
- **Don't recreate** Node-RED integration (covered by prompt 04)
- **Don't recreate** Grafana integration (covered by prompt 05)
- **Don't recreate** documentation (covered by prompt 07)

### Focus on Testing
- **Create comprehensive** testing scripts
- **Validate system** functionality
- **Ensure data** integrity and flow
- **Verify performance** and reliability
- **Provide confidence** in system operation 