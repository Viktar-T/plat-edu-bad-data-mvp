# Node-RED Flow Testing (Phase 1 - JavaScript)

## Objective
Implement JavaScript-based Node-RED flow tests for the renewable energy IoT monitoring system MVP, focusing on flow logic validation, data transformation, and integration with MQTT and InfluxDB.

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with Docker containerization. Node-RED flows are critical for data processing between MQTT and InfluxDB.

## Scope
- Node-RED flow execution and logic validation
- Data transformation and format conversion
- Error handling and recovery mechanisms
- Integration with MQTT and InfluxDB
- Function node business logic testing
- Flow performance and reliability

## Approach
**Language**: JavaScript/Node.js
**Framework**: Node-RED testing utilities, Jest
**Containerization**: Docker with Node-RED instance
**Focus**: Unit testing of function nodes and integration testing of flows

## Success Criteria
- Flows process incoming MQTT messages correctly
- Data transformations maintain data integrity
- Error handling catches and processes exceptions properly
- Integration with InfluxDB writes data successfully
- Function nodes execute business logic accurately
- Flow performance meets real-time requirements
- Tests run consistently in Docker environment

## Implementation Strategy

### Test Structure
```
tests/javascript/node-red/
├── flow-execution.test.js     # Complete flow testing
├── data-transformation.test.js # Data processing validation
├── error-handling.test.js     # Error scenario testing
├── function-nodes.test.js     # Custom function logic
├── integration.test.js        # MQTT-InfluxDB integration
└── performance.test.js        # Flow performance testing
```

### Core Test Components

#### 1. Flow Execution Testing (`flow-execution.test.js`)
```javascript
// Test complete flow execution
describe('Node-RED Flow Execution', () => {
  test('should process photovoltaic data flow', async () => {
    // Complete flow test implementation
  });
  
  test('should process wind turbine data flow', async () => {
    // Wind turbine flow test
  });
});
```

#### 2. Data Transformation Testing (`data-transformation.test.js`)
```javascript
// Test data format conversions
describe('Data Transformation', () => {
  test('should transform MQTT message to InfluxDB format', async () => {
    // Data transformation test
  });
  
  test('should validate data schema compliance', async () => {
    // Schema validation test
  });
});
```

#### 3. Function Node Testing (`function-nodes.test.js`)
```javascript
// Test custom JavaScript logic in function nodes
describe('Function Node Logic', () => {
  test('should calculate device efficiency correctly', async () => {
    // Efficiency calculation test
  });
  
  test('should handle missing data gracefully', async () => {
    // Error handling test
  });
});
```

### Test Data Configuration

#### Node-RED Flow Test Data
```javascript
// Input MQTT message format
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

// Expected InfluxDB output format
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
// config/node-red-test-config.json
{
  "nodeRed": {
    "host": "node-red",
    "port": 1880,
    "adminAuth": {
      "type": "credentials",
      "users": [{
        "username": "test_user",
        "password": "test_password",
        "permissions": "*"
      }]
    }
  },
  "flows": {
    "photovoltaic": "flows/photovoltaic-flow.json",
    "wind_turbine": "flows/wind-turbine-flow.json",
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
  // Setup Node-RED test environment
  await NodeRedTestUtil.startNodeRed();
});

afterAll(async () => {
  // Cleanup Node-RED test environment
  await NodeRedTestUtil.stopNodeRed();
});
```

## Test Scenarios

### 1. Flow Execution
- Test complete photovoltaic data flow
- Test complete wind turbine data flow
- Validate flow input/output mapping

### 2. Data Transformation
- MQTT message to InfluxDB format conversion
- Data type validation and conversion
- Schema compliance checking

### 3. Error Handling
- Invalid data format handling
- Missing required fields
- Network connection failures

### 4. Function Node Logic
- Device efficiency calculations
- Data validation and filtering
- Business rule implementation

### 5. Integration Testing
- MQTT to Node-RED message flow
- Node-RED to InfluxDB data flow
- End-to-end data pipeline validation

### 6. Performance Testing
- Flow execution time measurement
- Memory usage monitoring
- Throughput testing

## MVP Considerations
- Focus on photovoltaic and wind turbine flows first
- Test with realistic but manageable data volumes
- Prioritize data accuracy over complex transformations
- Use simple error handling for MVP phase
- Keep function node logic testable and maintainable
- Use Docker for consistent test environment
- Implement basic logging for debugging

## Implementation Notes
- Use Node-RED test helper utilities
- Mock external dependencies (MQTT, InfluxDB) for unit tests
- Test with realistic renewable energy device data
- Validate data transformation accuracy
- Test error scenarios and recovery mechanisms
- Focus on critical data processing paths
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- Test function nodes in isolation when possible 