# MQTT Communication Testing (Phase 1 - JavaScript)

## Objective
Implement JavaScript-based MQTT communication tests for the renewable energy IoT monitoring system MVP, focusing on core connectivity, message validation, and topic structure compliance.

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with Docker containerization. MQTT tests are foundational for the entire data pipeline.

## Scope
- MQTT broker connectivity and authentication
- Message publishing/subscribing validation
- Topic structure compliance (`devices/{device_type}/{device_id}/{data_type}`)
- QoS level verification
- Error handling and connection resilience
- Realistic renewable energy device data testing

## Approach
**Language**: JavaScript/Node.js
**Framework**: MQTT.js, Jest
**Containerization**: Docker with Mosquitto broker
**Focus**: Unit and integration testing of MQTT communication

## Success Criteria
- MQTT broker accepts connections from authorized clients
- Messages are published to correct topics with proper JSON format
- Subscribers receive messages with expected QoS levels
- Topic structure follows hierarchical pattern
- Authentication tokens are validated correctly
- Connection resilience works during network interruptions
- Tests run consistently in Docker environment

## Implementation Strategy

### Test Structure
```
tests/javascript/mqtt/
├── connection.test.js         # Broker connectivity tests
├── messaging.test.js          # Message validation tests
├── authentication.test.js     # Auth and security tests
├── topics.test.js            # Topic structure validation
├── qos.test.js               # Quality of service tests
└── resilience.test.js        # Error handling and recovery
```

### Core Test Components

#### 1. Connection Testing (`connection.test.js`)
```javascript
// Test MQTT broker connectivity
describe('MQTT Connection', () => {
  test('should connect to broker successfully', async () => {
    // Connection test implementation
  });
  
  test('should handle connection failures gracefully', async () => {
    // Error handling test
  });
});
```

#### 2. Message Validation (`messaging.test.js`)
```javascript
// Test message publishing and subscribing
describe('MQTT Messaging', () => {
  test('should publish photovoltaic data correctly', async () => {
    // Message publishing test
  });
  
  test('should receive messages with correct format', async () => {
    // Message subscription test
  });
});
```

#### 3. Topic Structure (`topics.test.js`)
```javascript
// Test hierarchical topic structure
describe('Topic Structure', () => {
  test('should follow device topic pattern', () => {
    // Topic validation test
  });
});
```

### Test Data Configuration

#### MQTT Test Messages
```javascript
// Realistic renewable energy device data
const photovoltaicData = {
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
};

const windTurbineData = {
  timestamp: "2024-01-15T10:30:00Z",
  device_id: "wt_001",
  device_type: "wind_turbine",
  location: "site_b",
  power_output: 1250.75,
  wind_speed: 12.5,
  wind_direction: 180,
  rotor_speed: 15.2,
  efficiency: 85.3
};
```

### Docker Integration

#### MQTT Test Configuration
```javascript
// config/mqtt-test-config.json
{
  "broker": {
    "host": "mosquitto",
    "port": 1883,
    "username": "test_user",
    "password": "test_password"
  },
  "topics": {
    "photovoltaic": "devices/photovoltaic/+/data",
    "wind_turbine": "devices/wind_turbine/+/data",
    "energy_storage": "devices/energy_storage/+/data"
  },
  "qos": {
    "default": 1,
    "critical": 2
  }
}
```

### Test Execution

#### Jest Configuration
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/javascript/utils/setup.js'],
  testTimeout: 10000,
  collectCoverageFrom: [
    'tests/javascript/mqtt/**/*.js'
  ]
};
```

#### Test Setup
```javascript
// tests/javascript/utils/setup.js
const mqtt = require('mqtt');

beforeAll(async () => {
  // Setup MQTT test environment
});

afterAll(async () => {
  // Cleanup MQTT connections
});
```

## Test Scenarios

### 1. Basic Connectivity
- Connect to MQTT broker with valid credentials
- Handle connection failures and timeouts
- Test reconnection logic

### 2. Message Publishing
- Publish photovoltaic device data
- Publish wind turbine device data
- Validate message format and content

### 3. Message Subscribing
- Subscribe to device topics
- Receive and validate incoming messages
- Handle message parsing errors

### 4. Topic Structure
- Validate hierarchical topic naming
- Test wildcard subscriptions
- Verify topic permissions

### 5. QoS Levels
- Test different QoS levels (0, 1, 2)
- Verify message delivery guarantees
- Test QoS level mismatches

### 6. Error Handling
- Test invalid message formats
- Handle network interruptions
- Test authentication failures

## MVP Considerations
- Focus on photovoltaic and wind turbine data first
- Use simple authentication for MVP phase
- Test with 2-3 device types initially
- Prioritize message delivery reliability
- Keep test data realistic but manageable
- Use Docker for consistent test environment
- Implement basic error handling and logging

## Implementation Notes
- Use MQTT.js client for testing
- Mock external dependencies when possible
- Test with realistic renewable energy device data
- Validate JSON payload structure against schemas
- Test both successful and failure scenarios
- Focus on critical communication paths
- Use environment variables for configuration
- Implement proper cleanup in test teardown 