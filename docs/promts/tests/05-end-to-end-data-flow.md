# End-to-End Data Flow Testing (Phase 2 - Integration)

## Objective
Implement comprehensive end-to-end data flow tests for the renewable energy IoT monitoring system MVP, validating the complete pipeline from device simulation through MQTT, Node-RED, InfluxDB, to Grafana visualization. **Test against the actual running services from your main docker-compose.yml.**

## Context
This is Phase 2 of our incremental testing approach. We're building on the foundation of Phase 1 (JavaScript tests) and adding integration testing to validate the complete data pipeline. **The main docker-compose.yml should be carefully analyzed to understand the actual service configurations, ports, volumes, and network settings for all components.**

## Pre-Implementation Analysis
**Before writing tests, thoroughly analyze the relevant folders in your project to understand:**

### **mosquitto/ folder:**
- **Configuration files** (`mosquitto/config/mosquitto.conf`) - Authentication, ports, logging, security settings
- **Access Control Lists** (`mosquitto/config/acl`) - Topic permissions and user access rights
- **Password files** (`mosquitto/config/passwd`) - User credentials and authentication methods
- **Data and log directories** (`mosquitto/data/`, `mosquitto/log/`) - Message persistence and debugging information

### **node-red/ folder:**
- **Flow files** (`node-red/flows/`) - Actual deployed flows for photovoltaic, wind turbine, energy storage, etc.
- **Data directory** (`node-red/data/`) - Node-RED runtime data, flow history, and configuration
- **Package configuration** (`node-red/package.json`) - Custom nodes, dependencies, and scripts
- **Startup scripts** (`node-red/startup.sh`) - Initialization logic and environment setup
- **Settings configuration** (`node-red/settings.js`) - Node-RED runtime settings and authentication

### **influxdb/ folder:**
- **Configuration files** (`influxdb/config/`) - InfluxDB 3.x configuration settings and parameters
- **Schema definitions** (`influxdb/config/schemas/`) - JSON schema files for photovoltaic, wind turbine, energy storage data
- **Scripts directory** (`influxdb/scripts/`) - Database initialization and setup scripts
- **Data directory** (`influxdb/data/`) - Database storage and persistence configuration

### **grafana/ folder:**
- **Dashboard configurations** (`grafana/dashboards/`) - JSON dashboard definitions for renewable energy monitoring
- **Data source configuration** (`grafana/provisioning/datasources/`) - InfluxDB data source setup
- **Dashboard provisioning** (`grafana/provisioning/dashboards/`) - Dashboard deployment configuration
- **Data directory** (`grafana/data/`) - Grafana runtime data and configuration

### **scripts/ folder:**
- **Device simulation scripts** (`scripts/simulate-devices.sh`, `scripts/generate-data.js`) - Data generation utilities
- **Setup and configuration scripts** (`scripts/setup-mqtt.sh`, `scripts/influx3-setup.sh`) - System initialization
- **Testing utilities** (`scripts/check-data.js`, `scripts/mqtt-test.sh`) - Existing test scripts

## Scope
- Complete data flow: Device Simulation → MQTT → Node-RED → InfluxDB → Grafana with actual running services
- Data integrity throughout the pipeline with real services
- Real-time data processing and visualization with actual instances
- Error propagation and handling with real services
- System integration and coordination with actual containers
- End-to-end performance validation with real data flow
- **Integration with actual running services from main docker-compose.yml**

## Approach
**Primary Language**: JavaScript/Node.js (orchestration and validation)
**Secondary Languages**: Python (device simulation), SQL (data verification)
**Containerization**: Docker with all services
**Focus**: Complete system integration and data flow validation
**Integration**: **Test against actual running services from main docker-compose.yml**

## Success Criteria
- Data flows seamlessly from device simulation to visualization through actual services
- Data integrity is maintained throughout the pipeline with real services
- Real-time processing meets performance requirements with actual instances
- Errors are handled gracefully at each stage with real services
- System components coordinate effectively with actual containers
- End-to-end latency is within acceptable limits with real data flow
- Data accuracy is preserved across all transformations with actual services
- **Successfully tests complete data pipeline with actual running services**

## Implementation Strategy

### Test Structure
```
tests/integration/end-to-end/
├── data-pipeline.test.js      # Complete pipeline validation with actual services
├── real-time-processing.test.js # Real-time flow testing with actual instances
├── error-propagation.test.js  # Error handling validation with real services
├── performance.test.js        # End-to-end performance with actual services
└── utils/
    ├── pipeline-orchestrator.js # Test orchestration with actual services
    └── data-validator.js       # Data validation utilities for real services
```

### Core Test Components

#### 1. Complete Data Pipeline (`data-pipeline.test.js`)
```javascript
// Test complete data flow with actual running services
describe('End-to-End Data Pipeline', () => {
  test('should process photovoltaic data from simulation to visualization through actual services', async () => {
    // Complete pipeline test implementation using actual running services
  });
  
  test('should process wind turbine data end-to-end through actual services', async () => {
    // Wind turbine pipeline test using actual running services
  });
});
```

#### 2. Real-time Processing (`real-time-processing.test.js`)
```javascript
// Test real-time data flow with actual services
describe('Real-time Processing', () => {
  test('should maintain real-time data flow under load with actual services', async () => {
    // Real-time processing test using actual running services
  });
});
```

### Test Data Configuration

#### End-to-End Test Data
```javascript
// Complete test scenario data for actual services
const endToEndTestScenario = {
  deviceType: "photovoltaic",
  deviceId: "pv_001",
  simulationData: {
    power_output: 584.43,
    voltage: 48.3,
    current: 12.1,
    temperature: 45.2,
    irradiance: 850.5
  },
  expectedMQTTMessage: {
    topic: "devices/photovoltaic/pv_001/data",
    payload: { /* expected MQTT format for actual Mosquitto */ }
  },
  expectedInfluxDBRecord: {
    measurement: "photovoltaic_data",
    tags: { /* expected tags for actual InfluxDB */ },
    fields: { /* expected fields for actual InfluxDB */ }
  },
  expectedGrafanaData: {
    /* expected visualization data for actual Grafana */
  }
};
```

### Docker Integration

#### End-to-End Test Configuration
```javascript
// config/e2e-test-config.json - Based on actual docker-compose.yml
{
  "services": {
    "deviceSimulator": {
      "host": "device-simulator",
      "port": 3000
    },
    "mqtt": {
      "host": "mosquitto",  // Actual service name from docker-compose.yml
      "port": 1883          // Actual port from docker-compose.yml
    },
    "nodeRed": {
      "host": "node-red",   // Actual service name from docker-compose.yml
      "port": 1880          // Actual port from docker-compose.yml
    },
    "influxdb": {
      "host": "influxdb",   // Actual service name from docker-compose.yml
      "port": 8086          // Actual port from docker-compose.yml
    },
    "grafana": {
      "host": "grafana",    // Actual service name from docker-compose.yml
      "port": 3000          // Actual port from docker-compose.yml
    }
  },
  "testScenarios": {
    "photovoltaic": "scenarios/photovoltaic-e2e.json",
    "windTurbine": "scenarios/wind-turbine-e2e.json"
  }
}
```

### Test Execution

#### End-to-End Test Setup
```javascript
// tests/integration/utils/pipeline-orchestrator.js
class PipelineOrchestrator {
  async runEndToEndTest(scenario) {
    // 1. Start device simulation with actual service
    // 2. Monitor MQTT messages with actual Mosquitto broker
    // 3. Validate Node-RED processing with actual Node-RED instance
    // 4. Check InfluxDB storage with actual InfluxDB instance
    // 5. Verify Grafana visualization with actual Grafana instance
  }
}
```

## Test Scenarios

### 1. Complete Data Flow
- Device simulation generates realistic data for actual services
- MQTT broker receives and distributes messages through actual Mosquitto
- Node-RED processes and transforms data through actual Node-RED instance
- InfluxDB stores data with correct schema through actual InfluxDB instance
- Grafana displays data in real-time through actual Grafana instance

### 2. Data Integrity
- Data accuracy maintained through all stages with actual services
- No data loss or corruption in pipeline with real services
- Timestamp consistency across components with actual instances
- Schema compliance at each stage with real services

### 3. Real-time Processing
- Latency within acceptable limits with actual services
- Throughput meets requirements with real instances
- Real-time visualization updates with actual Grafana
- Concurrent data processing with real services

### 4. Error Handling
- Graceful error propagation with actual services
- System recovery from failures with real instances
- Data consistency during errors with actual services
- Error reporting and logging with real services

### 5. Performance Testing
- End-to-end latency measurement with actual services
- System throughput validation with real instances
- Resource usage monitoring with actual containers
- Performance under load with real services

## MVP Considerations
- Focus on photovoltaic and wind turbine data flows first
- Test with realistic but manageable data volumes
- Prioritize data accuracy over complex optimizations
- Use simple error handling for MVP phase
- Ensure basic end-to-end functionality works reliably
- Keep performance requirements reasonable for MVP
- Use Docker for consistent test environment
- **Test against actual running services from main docker-compose.yml**

## Implementation Notes
- Use device simulation scripts to generate realistic data for actual services
- Monitor data at each stage of the pipeline with real services
- Validate data transformations and format changes with actual instances
- Test error scenarios and recovery mechanisms with real services
- Measure end-to-end performance metrics with actual services
- Focus on critical data paths for MVP
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- **Carefully analyze main docker-compose.yml for all service configurations**
- **Use actual service names, ports, volumes, and network settings from docker-compose.yml**
- **Test real end-to-end data flow, not mocked services**
- **Analyze all relevant project folders (mosquitto/, node-red/, influxdb/, grafana/, scripts/) before implementing tests** 