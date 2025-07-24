/**
 * Jest setup file for renewable energy IoT monitoring system tests
 */

// Set test timeout
jest.setTimeout(30000);

// Mock environment variables for testing
process.env.NODE_ENV = 'test';
process.env.MQTT_HOST = 'mosquitto';
process.env.MQTT_PORT = '1883';
process.env.MQTT_USERNAME = 'admin';
process.env.MQTT_PASSWORD = 'admin_password_456';
process.env.NODE_RED_HOST = 'node-red';
process.env.NODE_RED_PORT = '1880';
process.env.NODE_RED_USERNAME = 'admin';
process.env.NODE_RED_PASSWORD = 'adminpassword';
process.env.INFLUXDB_HOST = 'influxdb';
process.env.INFLUXDB_PORT = '8086';
process.env.INFLUXDB_TOKEN = '';
process.env.INFLUXDB_ORG = 'renewable-energy';
process.env.INFLUXDB_BUCKET = 'iot-data';
process.env.GRAFANA_HOST = 'grafana';
process.env.GRAFANA_PORT = '3000';
process.env.GRAFANA_USERNAME = 'admin';
process.env.GRAFANA_PASSWORD = 'admin';

// Global test utilities
global.testUtils = {
  // Wait for a specified amount of time
  wait: (ms) => new Promise(resolve => setTimeout(resolve, ms)),
  
  // Generate test data
  generateTestData: (deviceType, deviceId, overrides = {}) => {
    const baseData = {
      timestamp: new Date().toISOString(),
      device_id: deviceId,
      device_type: deviceType,
      ...overrides
    };
    
    switch (deviceType) {
      case 'photovoltaic':
        return {
          ...baseData,
          power_output: 2500.5,
          voltage: 48.2,
          current: 51.9,
          temperature: 45.3,
          efficiency: 18.5,
          irradiance: 850.2,
          status: 'generating'
        };
      case 'wind_turbine':
        return {
          ...baseData,
          power_output: 1800.0,
          wind_speed: 12.5,
          wind_direction: 180,
          rpm: 1200,
          temperature: 25.0,
          efficiency: 85.2,
          status: 'generating'
        };
      case 'biogas_plant':
        return {
          ...baseData,
          gas_flow_rate: 150.5,
          methane_concentration: 65.2,
          temperature: 38.0,
          pressure: 1.2,
          power_output: 3200.0,
          efficiency: 78.5,
          status: 'running'
        };
      case 'heat_boiler':
        return {
          ...baseData,
          temperature: 85.0,
          pressure: 2.5,
          fuel_consumption: 45.2,
          efficiency: 92.1,
          heat_output: 50000.0,
          status: 'running'
        };
      case 'energy_storage':
        return {
          ...baseData,
          state_of_charge: 75.5,
          voltage: 400.0,
          current: 25.0,
          temperature: 25.0,
          power_input: 10000.0,
          power_output: 0.0,
          status: 'charging'
        };
      default:
        return baseData;
    }
  },
  
  // Validate message format
  validateMessage: (message, requiredFields = ['timestamp', 'device_id', 'device_type']) => {
    const errors = [];
    
    for (const field of requiredFields) {
      if (!(field in message)) {
        errors.push(`Missing required field: ${field}`);
      }
    }
    
    if (message.timestamp) {
      const timestampRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z$/;
      if (!timestampRegex.test(message.timestamp)) {
        errors.push('Invalid timestamp format. Expected ISO 8601 format.');
      }
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  },
  
  // Retry function with exponential backoff
  retry: async (fn, maxRetries = 3, baseDelay = 1000) => {
    let lastError;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        
        if (attempt === maxRetries) {
          throw error;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await global.testUtils.wait(delay);
      }
    }
  }
};

// Console logging for tests
const originalConsoleLog = console.log;
const originalConsoleError = console.error;
const originalConsoleWarn = console.warn;

beforeEach(() => {
  // Suppress console output during tests unless explicitly enabled
  if (!process.env.TEST_VERBOSE) {
    console.log = jest.fn();
    console.error = jest.fn();
    console.warn = jest.fn();
  }
});

afterEach(() => {
  // Restore console output
  console.log = originalConsoleLog;
  console.error = originalConsoleError;
  console.warn = originalConsoleWarn;
});

// Global test cleanup
afterAll(async () => {
  // Clean up any remaining resources
  await global.testUtils.wait(100);
}); 