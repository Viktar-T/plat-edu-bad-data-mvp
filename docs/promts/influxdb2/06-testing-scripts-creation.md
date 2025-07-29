# Testing Scripts Creation for InfluxDB 2.x

## Prompt for Cursor IDE

Create comprehensive testing scripts for my InfluxDB 2.x setup.

## Requirements

1. **Health check script** to verify InfluxDB is running
2. **Database connection test**
3. **Data writing test** (MQTT → Node-RED → InfluxDB)
4. **Query test** to verify data retrieval
5. **Dashboard test** to verify Grafana connectivity
6. **End-to-end data flow test**

## Testing Scenarios

### 1. Health Check Tests
- **InfluxDB service status**: Verify container is running
- **HTTP endpoint accessibility**: Test port 8086
- **GUI accessibility**: Test web interface
- **Authentication**: Test admin login
- **Database existence**: Verify 'renewable_energy' database exists

### 2. Connection Tests
- **Node-RED to InfluxDB**: Test Node-RED can connect and write data
- **Grafana to InfluxDB**: Test Grafana can read data
- **Network connectivity**: Test inter-container communication
- **Authentication**: Test with admin credentials

### 3. Data Flow Tests
- **MQTT message reception**: Test MQTT broker receives messages
- **Node-RED processing**: Test data transformation in Node-RED
- **InfluxDB writing**: Test data is written to InfluxDB
- **Data persistence**: Test data survives container restarts

### 4. Query Tests
- **Basic queries**: Test simple data retrieval
- **Aggregation queries**: Test sum, mean, count operations
- **Time range queries**: Test time-based filtering
- **Device-specific queries**: Test filtering by device type
- **Performance tests**: Test query response times

### 5. Dashboard Tests
- **Grafana accessibility**: Test Grafana web interface
- **Data source connectivity**: Test InfluxDB data source
- **Panel rendering**: Test dashboard panels display data
- **Real-time updates**: Test live data updates

## Script Requirements

### PowerShell Scripts (Windows)
- **Health checks**: Service status and connectivity
- **Data flow tests**: End-to-end testing
- **Query tests**: InfluxDB API testing
- **Dashboard tests**: Grafana integration testing

### Shell Scripts (Linux)
- **Docker commands**: Container management
- **API testing**: HTTP requests to InfluxDB
- **Data validation**: Verify data integrity
- **Performance monitoring**: Resource usage checks

### JavaScript Tests (Node.js)
- **MQTT testing**: Message publishing and subscription
- **Node-RED testing**: Flow execution testing
- **InfluxDB API**: Direct API testing
- **Data transformation**: Verify data format

## Test Data Requirements

### Device Simulation Data
- **Photovoltaic data**: Power output, temperature, voltage, current, irradiance
- **Wind turbine data**: Power output, wind speed, direction, rotor speed
- **Biogas plant data**: Gas flow, methane concentration, temperature, pressure
- **Heat boiler data**: Temperature, pressure, efficiency, fuel consumption
- **Energy storage data**: State of charge, voltage, current, temperature

### Test Scenarios
- **Normal operation**: Standard data flow
- **High load**: Multiple devices sending data simultaneously
- **Error conditions**: Invalid data, network issues, service failures
- **Recovery**: Service restart and data persistence

## Expected Output

### PowerShell Scripts
1. **test-influxdb-health.ps1** - Health check script
2. **test-data-flow.ps1** - End-to-end data flow test
3. **test-queries.ps1** - Query testing script
4. **test-dashboards.ps1** - Dashboard testing script

### Shell Scripts
1. **test-influxdb-health.sh** - Linux health checks
2. **test-data-flow.sh** - Linux data flow tests
3. **test-queries.sh** - Linux query tests
4. **test-dashboards.sh** - Linux dashboard tests

### JavaScript Tests
1. **test-mqtt.js** - MQTT testing
2. **test-nodered.js** - Node-RED testing
3. **test-influxdb.js** - InfluxDB API testing
4. **test-integration.js** - Full integration testing

### Documentation
1. **Test execution guide** - How to run all tests
2. **Expected results** - What each test should return
3. **Troubleshooting guide** - Common test failures and solutions
4. **Performance benchmarks** - Expected performance metrics

## Test Execution

### Automated Testing
- **Continuous integration**: Run tests on deployment
- **Health monitoring**: Regular health checks
- **Performance monitoring**: Track system performance
- **Alerting**: Notify on test failures

### Manual Testing
- **Setup verification**: Verify initial setup
- **Feature testing**: Test new features
- **Regression testing**: Ensure existing functionality works
- **Load testing**: Test under high load conditions

## Context

This is for a renewable energy monitoring system that requires:
- **Reliability**: System must be stable and reliable
- **Performance**: Fast response times for queries
- **Scalability**: Handle multiple devices and data points
- **Monitoring**: Comprehensive system monitoring

The testing scripts should provide confidence that the InfluxDB 2.x setup is working correctly and can handle the expected workload. 