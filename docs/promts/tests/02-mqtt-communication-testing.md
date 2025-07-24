# MQTT Communication Testing (Phase 1 - JavaScript)

## Objective
Implement JavaScript-based MQTT communication tests for the renewable energy IoT monitoring system MVP, focusing on core connectivity, message validation, and topic structure compliance. **Test against the actual running Mosquitto broker from your main docker-compose.yml.**

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with Docker containerization. MQTT tests are foundational for the entire data pipeline. **The main docker-compose.yml should be carefully analyzed to understand the actual Mosquitto configuration, ports, authentication, and network settings.**

## Pre-Implementation Analysis
**Before writing tests, thoroughly analyze the `mosquitto/` folder in your project to understand:**
- **Configuration files** (`mosquitto/config/mosquitto.conf`) - Authentication, ports, logging, security settings
- **Access Control Lists** (`mosquitto/config/acl`) - Topic permissions and user access rights
- **Password files** (`mosquitto/config/passwd`) - User credentials and authentication methods
- **Data and log directories** (`mosquitto/data/`, `mosquitto/log/`) - Message persistence and debugging information
- **Network configuration** - How Mosquitto integrates with other services
- **Environment variables** - Configuration overrides and runtime settings

## Scope
- MQTT broker connectivity and authentication with actual running Mosquitto
- Message publishing/subscribing validation using real topics
- Topic structure compliance (`devices/{device_type}/{device_id}/{data_type}`)
- QoS level verification with actual message delivery
- Error handling and connection resilience
- Realistic renewable energy device data testing
- **Integration with actual MQTT broker from main docker-compose.yml**

## Approach
**Language**: JavaScript/Node.js
**Framework**: MQTT.js, Jest
**Containerization**: Docker with Mosquitto broker
**Focus**: Unit and integration testing of MQTT communication
**Integration**: **Test against actual running Mosquitto service**

## Success Criteria
- MQTT broker accepts connections from authorized clients
- Messages are published to correct topics with proper JSON format
- Subscribers receive messages with expected QoS levels
- Topic structure follows hierarchical pattern
- Authentication tokens are validated correctly
- Connection resilience works during network interruptions
- Tests run consistently in Docker environment
- **Successfully connects to and communicates with actual Mosquitto broker**

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
// Test MQTT broker connectivity with actual Mosquitto
describe('MQTT Connection', () => {
  test('should connect to actual Mosquitto broker successfully', async () => {
    // Connection test implementation using actual broker
  });
  
  test('should handle connection failures gracefully', async () => {
    // Error handling test
  });
});
```

#### 2. Message Validation (`messaging.test.js`)
```javascript
// Test message publishing and subscribing with real topics
describe('MQTT Messaging', () => {
  test('should publish photovoltaic data to actual broker', async () => {
    // Message publishing test using real topics
  });
  
  test('should receive messages with correct format from actual broker', async () => {
    // Message subscription test
  });
});
```

#### 3. Topic Structure (`topics.test.js`)
```javascript
// Test hierarchical topic structure with actual broker
describe('Topic Structure', () => {
  test('should follow device topic pattern in actual broker', () => {
    // Topic validation test using real broker
  });
});
```

### Test Data Configuration

#### MQTT Test Messages
```javascript
// Realistic renewable energy device data for actual testing
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
// config/mqtt-test-config.json - Based on actual docker-compose.yml
{
  "broker": {
    "host": "mosquitto",  // Actual service name from docker-compose.yml
    "port": 1883,         // Actual port from docker-compose.yml
    "username": "admin",  // From docker-compose.yml environment variables
    "password": "admin_password_456"  // From docker-compose.yml
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

#### MQTT Test Setup
```javascript
// tests/javascript/utils/setup.js
const mqtt = require('mqtt');

beforeAll(async () => {
  // Setup MQTT test environment with actual Mosquitto broker
  // Use configuration from docker-compose.yml
});

afterAll(async () => {
  // Cleanup MQTT connections to actual broker
});
```

## Test Scenarios

### 1. Basic Connectivity
- Connect to actual Mosquitto broker with valid credentials
- Handle connection failures and timeouts
- Test reconnection logic with real broker

### 2. Message Publishing
- Publish photovoltaic device data to actual topics
- Publish wind turbine device data to actual topics
- Validate message format and content with real broker

### 3. Message Subscribing
- Subscribe to device topics on actual broker
- Receive and validate incoming messages from real broker
- Handle message parsing errors with actual data

### 4. Topic Structure
- Validate hierarchical topic naming with actual broker
- Test wildcard subscriptions on real topics
- Verify topic permissions with actual authentication

### 5. QoS Levels
- Test different QoS levels (0, 1, 2) with actual broker
- Verify message delivery guarantees with real communication
- Test QoS level mismatches with actual broker

### 6. Error Handling
- Test invalid message formats with actual broker
- Handle network interruptions with real Mosquitto
- Test authentication failures with actual credentials

## MVP Considerations
- Focus on photovoltaic and wind turbine data first
- Use simple authentication for MVP phase
- Test with 2-3 device types initially
- Prioritize message delivery reliability
- Keep test data realistic but manageable
- Use Docker for consistent test environment
- Implement basic error handling and logging
- **Test against actual running Mosquitto broker from main docker-compose.yml**

## Implementation Notes
- Use MQTT.js client for testing actual broker
- Mock external dependencies when possible
- Test with realistic renewable energy device data
- Validate JSON payload structure against schemas
- Test both successful and failure scenarios
- Focus on critical communication paths
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- **Carefully analyze main docker-compose.yml for Mosquitto configuration**
- **Use actual service names, ports, and authentication from docker-compose.yml**
- **Test real MQTT communication, not mocked services**
- **Analyze mosquitto/ folder structure and configuration before implementing tests** 