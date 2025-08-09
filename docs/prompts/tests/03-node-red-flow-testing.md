# Node-RED Flow Testing (Phase 1 - JavaScript)

## Objective
Implement JavaScript-based Node-RED flow tests for the renewable energy IoT monitoring system MVP, focusing on flow logic validation, data transformation, and integration with MQTT and InfluxDB. **Test against the actual running Node-RED instance from your main docker-compose.yml.**

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with Docker containerization. Node-RED flows are critical for data processing between MQTT and InfluxDB. **The main docker-compose.yml should be carefully analyzed to understand the actual Node-RED configuration, ports, authentication, volumes, and flow deployments.**

## Pre-Implementation Analysis
**Before writing tests, thoroughly analyze the `node-red/` folder in your project to understand:**
- **Flow files** (`node-red/flows/`) - Actual deployed flows for photovoltaic, wind turbine, energy storage, etc.
- **Data directory** (`node-red/data/`) - Node-RED runtime data, flow history, and configuration
- **Package configuration** (`node-red/package.json`) - Custom nodes, dependencies, and scripts
- **Startup scripts** (`node-red/startup.sh`) - Initialization logic and environment setup
- **Settings configuration** (`node-red/settings.js`) - Node-RED runtime settings and authentication
- **Test utilities** (`node-red/test-mqtt.js`) - Existing test scripts and utilities
- **Flow structure** - How flows are organized and interconnected
- **Custom function nodes** - Business logic implementation in JavaScript

## Scope
- Node-RED flow execution and logic validation with actual running instance
- Data transformation and format conversion using real flows
- Error handling and recovery mechanisms with actual Node-RED
- Integration with MQTT and InfluxDB using real connections
- Function node business logic testing with actual deployed flows
- Flow performance and reliability with real data processing
- **Integration with actual Node-RED service from main docker-compose.yml**

## Approach
**Language**: JavaScript/Node.js
**Framework**: Node-RED testing utilities, Jest
**Containerization**: Docker with Node-RED instance
**Focus**: Unit testing of function nodes and integration testing of flows
**Integration**: **Test against actual running Node-RED service**

## Success Criteria
- Flows process incoming MQTT messages correctly with actual Node-RED
- Data transformations maintain data integrity with real flows
- Error handling catches and processes exceptions properly
- Integration with InfluxDB writes data successfully through actual flows
- Function nodes execute business logic accurately with real data
- Flow performance meets real-time requirements
- Tests run consistently in Docker environment
- **Successfully tests actual Node-RED flows deployed in main container**

## Implementation Strategy

### Test Structure
```
tests/javascript/node-red/
├── flow-execution.test.js     # Complete flow testing with actual Node-RED
├── data-transformation.test.js # Data processing validation with real flows
├── error-handling.test.js     # Error scenario testing with actual instance
├── function-nodes.test.js     # Custom function logic with real flows
├── integration.test.js        # MQTT-InfluxDB integration through actual flows
└── performance.test.js        # Flow performance testing with real data
```

### Core Test Components

#### 1. Flow Execution Testing (`flow-execution.test.js`)
```javascript
// Test complete flow execution with actual Node-RED
describe('Node-RED Flow Execution', () => {
  test('should process photovoltaic data flow in actual Node-RED', async () => {
    // Complete flow test implementation using actual Node-RED instance
  });
  
  test('should process wind turbine data flow in actual Node-RED', async () => {
    // Wind turbine flow test using real Node-RED
  });
});
```

#### 2. Data Transformation Testing (`data-transformation.test.js`)
```javascript
// Test data format conversions with actual flows
describe('Data Transformation', () => {
  test('should transform MQTT message to InfluxDB format in actual Node-RED', async () => {
    // Data transformation test using real flows
  });
  
  test('should validate data schema compliance in actual Node-RED', async () => {
    // Schema validation test with real flows
  });
});
```

#### 3. Function Node Testing (`function-nodes.test.js`)
```javascript
// Test custom JavaScript logic in function nodes with actual Node-RED
describe('Function Node Logic', () => {
  test('should calculate device efficiency correctly in actual Node-RED', async () => {
    // Efficiency calculation test using real function nodes
  });
  
  test('should handle missing data gracefully in actual Node-RED', async () => {
    // Error handling test with real flows
  });
});
```

### Test Data Configuration

#### Node-RED Flow Test Data
```javascript
// Input MQTT message format for actual Node-RED testing
const mqttInputMessage = {
  topic: "devices/photovoltaic/pv_001/data",
  payload: {
    timestamp: "2024-01-15T10:30:00Z",
    device_id: "pv_001",
    device_type: "photovoltaic",
    location: "site_a",
    power_output: 584.43,
    voltage: 48.3,
    current: 12.1,
    temperature: 45.2,
    irradiance: 850.5,
    efficiency: 18.5
  }
};

// Expected InfluxDB output format from actual Node-RED flows
const expectedInfluxDBOutput = {
  measurement: "photovoltaic_data",
  tags: {
    device_id: "pv_001",
    location: "site_a",
    device_type: "photovoltaic"
  },
  fields: {
    power_output: 584.43,
    voltage: 48.3,
    current: 12.1,
    temperature: 45.2,
    irradiance: 850.5,
    efficiency: 18.5
  },
  timestamp: "2024-01-15T10:30:00Z"
};
```

### Docker Integration

#### Node-RED Test Configuration
```javascript
// config/node-red-test-config.json - Based on actual docker-compose.yml
{
  "nodeRed": {
    "host": "node-red",  // Actual service name from docker-compose.yml
    "port": 1880,        // Actual port from docker-compose.yml
    "adminAuth": {
      "type": "credentials",
      "users": [{
        "username": "admin",  // From docker-compose.yml environment variables
        "password": "adminpassword",  // From docker-compose.yml
        "permissions": "*"
      }]
    }
  },
  "flows": {
    "photovoltaic": "flows/photovoltaic-flow.json",  // Actual flow files
    "wind_turbine": "flows/wind-turbine-flow.json",  // From docker-compose.yml volumes
    "energy_storage": "flows/energy-storage-flow.json"
  },
  "testData": {
    "mqttMessages": "data/mqtt-messages/",
    "expectedResults": "data/expected-results/"
  }
}
```

### Test Execution

#### Jest Configuration for Node-RED
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/javascript/utils/node-red-setup.js'],
  testTimeout: 15000,
  collectCoverageFrom: [
    'tests/javascript/node-red/**/*.js'
  ]
};
```

#### Node-RED Test Setup
```javascript
// tests/javascript/utils/node-red-setup.js
const NodeRedTestUtil = require('node-red-test-helper');

beforeAll(async () => {
  // Setup Node-RED test environment with actual running instance
  // Use configuration from docker-compose.yml
  await NodeRedTestUtil.startNodeRed();
});

afterAll(async () => {
  // Cleanup Node-RED test environment with actual instance
  await NodeRedTestUtil.stopNodeRed();
});
```

## Test Scenarios

### 1. Flow Execution
- Test complete photovoltaic data flow in actual Node-RED
- Test complete wind turbine data flow in actual Node-RED
- Validate flow input/output mapping with real flows

### 2. Data Transformation
- MQTT message to InfluxDB format conversion in actual Node-RED
- Data type validation and conversion with real flows
- Schema compliance checking with actual deployed flows

### 3. Error Handling
- Invalid data format handling in actual Node-RED
- Missing required fields handling with real flows
- Network connection failures with actual Node-RED

### 4. Function Node Logic
- Device efficiency calculations in actual Node-RED
- Data validation and filtering with real function nodes
- Business rule implementation with actual flows

### 5. Integration Testing
- MQTT to Node-RED message flow with actual services
- Node-RED to InfluxDB data flow with real connections
- End-to-end data pipeline validation with actual services

### 6. Performance Testing
- Flow execution time measurement with actual Node-RED
- Memory usage monitoring with real flows
- Throughput testing with actual data processing

## MVP Considerations
- Focus on photovoltaic and wind turbine flows first
- Test with realistic but manageable data volumes
- Prioritize data accuracy over complex transformations
- Use simple error handling for MVP phase
- Keep function node logic testable and maintainable
- Use Docker for consistent test environment
- Implement basic logging for debugging
- **Test against actual running Node-RED instance from main docker-compose.yml**

## Implementation Notes
- Use Node-RED test helper utilities for actual instance testing
- Mock external dependencies when possible
- Test with realistic renewable energy device data
- Validate data transformation accuracy with real flows
- Test error scenarios and recovery mechanisms with actual Node-RED
- Focus on critical data processing paths
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- Test function nodes in isolation when possible
- **Carefully analyze main docker-compose.yml for Node-RED configuration**
- **Use actual service names, ports, authentication, and volumes from docker-compose.yml**
- **Test real Node-RED flows, not mocked services**
- **Analyze node-red/ folder structure and deployed flows before implementing tests** 