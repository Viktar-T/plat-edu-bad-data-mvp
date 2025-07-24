# Test Strategy Overview - Renewable Energy IoT Monitoring System

## Overview
This directory contains the comprehensive test suite for the renewable energy IoT monitoring system MVP. The testing framework is designed to validate the entire data flow: MQTT → Node-RED → InfluxDB → Grafana.

## Architecture
- **Data Flow**: MQTT → Node-RED → InfluxDB → Grafana
- **Containerization**: Docker with multi-stage builds
- **Test Languages**: JavaScript (Phase 1), Python (Phase 2), SQL (Phase 3), Shell (Phase 4)
- **Execution**: Sequential with unified reporting
- **Integration**: Tests against actual running services from main docker-compose.yml

## Test Phases

### Phase 1: JavaScript Foundation ✅
- MQTT connectivity and messaging tests
- Node-RED flow execution validation
- Grafana dashboard functionality tests
- Basic data transformation validation

### Phase 2: Python Addition (Planned)
- Data quality and business logic validation
- Device simulation accuracy tests
- Advanced analytics testing

### Phase 3: SQL Integration (Planned)
- InfluxDB schema validation
- Query performance testing
- Data integrity verification

### Phase 4: Shell Completion (Planned)
- System health checks
- Docker container validation
- Network connectivity tests

## Quick Start

### Prerequisites
1. Main system running: `docker-compose up -d`
2. All services healthy and accessible

### Running Tests
```bash
# Run all tests
docker-compose -f docker-compose.test.yml up --build

# Run specific phase
npm test                    # JavaScript tests only
python -m pytest python/   # Python tests only
```

### Test Results
- Individual results: `reports/javascript-results.json`
- Combined results: `reports/summary.html`
- Logs: `reports/test-logs/`

## Service Configuration
Tests connect to the following services from main docker-compose.yml:
- **MQTT**: mosquitto:1883
- **Node-RED**: node-red:1880
- **InfluxDB**: influxdb:8086
- **Grafana**: grafana:3000

## Environment Variables
Key test configuration variables:
- `MQTT_HOST`, `MQTT_PORT`: MQTT broker connection
- `NODE_RED_HOST`, `NODE_RED_PORT`: Node-RED instance
- `INFLUXDB_HOST`, `INFLUXDB_PORT`: InfluxDB connection
- `GRAFANA_HOST`, `GRAFANA_PORT`: Grafana instance

## Test Categories

### MQTT Tests
- Connection establishment
- Message publishing/subscribing
- Authentication and authorization
- Topic structure validation
- Message format validation

### Node-RED Tests
- Flow execution
- Data transformation
- Error handling
- MQTT to InfluxDB data flow
- Function node logic

### InfluxDB Tests
- Database connectivity
- Data insertion and retrieval
- Schema validation
- Query performance
- Data retention policies

### Grafana Tests
- Dashboard functionality
- Data source connectivity
- Visualization rendering
- Alert configuration
- User interface validation

## Reporting
- **JSON Reports**: Machine-readable test results
- **HTML Reports**: Human-readable summaries
- **Console Output**: Real-time test progress
- **Error Logs**: Detailed failure information

## Development Guidelines
- Add new tests incrementally
- Follow naming conventions
- Include proper error handling
- Use realistic test data
- Maintain test isolation
- Document test purposes

## Troubleshooting
1. Ensure main services are running and healthy
2. Check network connectivity between containers
3. Verify environment variables are set correctly
4. Review test logs for detailed error information
5. Validate test data format and content 