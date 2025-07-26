# Manual Testing Guide

## Overview
This directory contains comprehensive manual testing procedures for the Renewable Energy IoT Monitoring System. Each test file provides step-by-step instructions for testing specific components of the data flow pipeline.

## Test Structure

The manual tests are organized in a logical sequence that follows the data flow:

```
MQTT → Node-RED → InfluxDB → Grafana
```

### Test Files

1. **[01-prerequisites-check.md](./01-prerequisites-check.md)**
   - Verifies all services are running and healthy
   - Checks network connectivity
   - Validates environment configuration

2. **[02-mqtt-broker-testing.md](./02-mqtt-broker-testing.md)**
   - Tests MQTT broker authentication
   - Validates topic structure and access control
   - Verifies message publishing and subscription
   - Tests device data formats

3. **[03-node-red-data-processing.md](./03-node-red-data-processing.md)**
   - Tests Node-RED flow functionality
   - Validates data processing and transformation
   - Verifies error handling and performance
   - Tests InfluxDB output

4. **[04-influxdb-data-storage.md](./04-influxdb-data-storage.md)**
   - Tests InfluxDB data storage
   - Validates query performance
   - Verifies data integrity and retention
   - Tests backup and recovery

5. **[05-grafana-data-visualization.md](./05-grafana-data-visualization.md)**
   - Tests Grafana dashboard functionality
   - Validates real-time data display
   - Verifies visualization types and performance
   - Tests alerting and export features

6. **[06-end-to-end-data-flow.md](./06-end-to-end-data-flow.md)**
   - Tests complete data flow pipeline
   - Validates system integration
   - Verifies performance under load
   - Tests error recovery and data consistency

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Project services running (`docker-compose up -d`)
- Node.js installed (for MQTT testing scripts)
- PowerShell or bash terminal
- Web browser for UI testing

### PowerShell MQTT Testing Scripts

This directory includes PowerShell scripts for MQTT testing that work on Windows systems:

- **`test-mqtt.ps1`**: Basic MQTT connectivity and message testing
- **`simulate-devices.ps1`**: Realistic renewable energy device simulation
- **`package.json`**: Node.js dependencies for MQTT testing

#### Setup PowerShell Testing
```powershell
# Navigate to manual-tests directory
cd tests\manual-tests

# Install dependencies
npm install

# Test basic MQTT connectivity
.\test-mqtt.ps1 -PublishTest -Topic "test/hello" -Message "Hello World!"

# Simulate photovoltaic devices
.\simulate-devices.ps1 -Photovoltaic -Duration 60
```

### Running Tests

1. **Start all services:**
   ```powershell
   docker-compose up -d
   ```

2. **Run tests in sequence:**
   ```powershell
   # Follow each test file in order
   # Start with 01-prerequisites-check.md
   # Complete each test before moving to the next
   ```

3. **Document results:**
   - Use the test report template in each file
   - Record any issues or observations
   - Note performance metrics

## Test Environment Setup

### Required Tools
- **Node.js**: For MQTT testing scripts
- **PowerShell**: For Windows command execution and MQTT testing
- **PowerShell**: For HTTP API testing
- **Web Browser**: For UI testing

### Installation Commands

#### Windows (PowerShell)
```powershell
# Install Node.js (if not already installed)
# Download from: https://nodejs.org/

# Verify installation
node --version
npm --version

# Install MQTT testing dependencies
cd tests\manual-tests
npm install
```

#### Linux/macOS
```bash
# Install mosquitto-clients
sudo apt-get install mosquitto-clients  # Ubuntu/Debian
brew install mosquitto                  # macOS

# Verify installation
mosquitto_pub --help
mosquitto_sub --help
```

## Test Data

### Device Credentials
The tests use the following device credentials:

- **Admin**: `admin` / `admin_password_456`
- **Photovoltaic**: `pv_001` / `device_password_123`
- **Wind Turbine**: `wt_001` / `device_password_123`
- **Biogas Plant**: `bg_001` / `device_password_123`
- **Heat Boiler**: `hb_001` / `device_password_123`
- **Energy Storage**: `es_001` / `device_password_123`

### Test Data Formats
Each test includes realistic device data formats:

#### Photovoltaic Data
```json
{
  "device_id": "pv_001",
  "device_type": "photovoltaic",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "irradiance": 850.5,
    "temperature": 45.2,
    "voltage": 48.3,
    "current": 12.1,
    "power_output": 584.43
  },
  "status": "operational",
  "location": "site_a"
}
```

#### Wind Turbine Data
```json
{
  "device_id": "wt_001",
  "device_type": "wind_turbine",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "wind_speed": 12.5,
    "power_output": 850.2,
    "rpm": 1200,
    "temperature": 35.1
  },
  "status": "operational",
  "location": "site_b"
}
```

#### Biogas Plant Data
```json
{
  "device_id": "bg_001",
  "device_type": "biogas_plant",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "gas_flow": 25.5,
    "methane_concentration": 65.2,
    "temperature": 38.5,
    "pressure": 1.2
  },
  "status": "operational",
  "location": "site_c"
}
```

## Service URLs

- **MQTT Broker**: `localhost:1883` (MQTT), `localhost:9001` (WebSocket)
- **Node-RED**: http://localhost:1880
- **InfluxDB**: http://localhost:8086
- **Grafana**: http://localhost:3000 (admin/admin)

## Troubleshooting

### Common Issues

#### 1. Services Not Starting
```powershell
# Check service status
docker-compose ps

# Check logs
docker-compose logs [service-name]

# Restart services
docker-compose down
docker-compose up -d
```

#### 2. MQTT Connection Issues
```powershell
# Test MQTT connectivity
mosquitto_pub -h localhost -p 1883 -u admin -P admin_password_456 -t test/topic -m "test"

# Check MQTT logs
docker-compose logs mosquitto
```

#### 3. Data Not Appearing in Grafana
```powershell
# Check if data exists in InfluxDB (InfluxDB 3.x syntax)
$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM photovoltaic_data"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Check Grafana data source
# Verify dashboard queries
```

#### 4. Performance Issues
```powershell
# Check system resources
docker stats

# Check service logs for bottlenecks
docker-compose logs
```

## Test Reporting

### Report Template
Each test file includes a report template. Use it to document:

- Test date and environment
- Pass/fail status for each test step
- Performance metrics
- Issues encountered
- Recommendations

### Example Report
```
Test Date: 2024-01-15
Tester: John Doe
Environment: Windows 10

Results:
□ Prerequisites check: PASS
□ MQTT broker testing: PASS
□ Node-RED processing: PASS
□ InfluxDB storage: PASS
□ Grafana visualization: PASS
□ End-to-end flow: PASS

Overall Status: PASS

Notes:
- All tests completed successfully
- Performance within acceptable limits
- No issues encountered
```

## Best Practices

### Test Execution
1. **Follow the sequence**: Complete tests in order
2. **Document everything**: Record all results and observations
3. **Test thoroughly**: Don't skip test steps
4. **Verify results**: Confirm expected outcomes
5. **Report issues**: Document any problems encountered

### Environment Management
1. **Clean environment**: Start with fresh services
2. **Consistent setup**: Use same environment for all tests
3. **Resource monitoring**: Watch system resources during tests
4. **Backup data**: Save important test results

### Performance Testing
1. **Baseline measurements**: Establish performance baselines
2. **Load testing**: Test under various load conditions
3. **Stress testing**: Push system to limits
4. **Recovery testing**: Test error recovery mechanisms

## Support

For issues with manual testing:

1. Check the troubleshooting section in each test file
2. Review service logs for error messages
3. Verify environment configuration
4. Consult the main project documentation
5. Open an issue in the project repository

## Contributing

To improve the manual testing procedures:

1. Follow the existing format and structure
2. Include clear step-by-step instructions
3. Provide expected results for each step
4. Include troubleshooting information
5. Update this README if adding new tests 