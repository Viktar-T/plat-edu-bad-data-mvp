/**
 * Jest setup file for renewable energy IoT monitoring system tests
 */

// Jest setup file for MQTT tests
const TestLogger = require('./javascript/utils/test-logger');

// Increase timeout for MQTT operations
jest.setTimeout(60000);

// Mock environment variables for testing
process.env.MQTT_HOST = process.env.MQTT_HOST || 'mosquitto';
process.env.MQTT_PORT = process.env.MQTT_PORT || '1883';
process.env.MQTT_USERNAME = process.env.MQTT_USERNAME || 'admin';
process.env.MQTT_PASSWORD = process.env.MQTT_PASSWORD || 'admin_password_456';

// Global test utilities
global.wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

global.generateTestData = (type) => {
  const baseData = {
    timestamp: new Date().toISOString(),
    deviceId: `test-device-${Math.random().toString(36).substr(2, 9)}`,
    location: 'test-location'
  };

  switch (type) {
    case 'photovoltaic':
      return {
        ...baseData,
        powerOutput: Math.random() * 1000,
        voltage: 200 + Math.random() * 50,
        current: Math.random() * 5,
        temperature: 20 + Math.random() * 30,
        irradiance: Math.random() * 1000
      };
    case 'wind':
      return {
        ...baseData,
        windSpeed: Math.random() * 25,
        powerOutput: Math.random() * 2000,
        rotorSpeed: Math.random() * 20,
        bladeAngle: Math.random() * 90
      };
    case 'biogas':
      return {
        ...baseData,
        gasFlow: Math.random() * 100,
        methaneConcentration: 50 + Math.random() * 30,
        temperature: 30 + Math.random() * 20,
        pressure: 1 + Math.random() * 2
      };
    default:
      return baseData;
  }
};

global.validateMessage = (message, schema) => {
  // Basic message validation
  if (!message || typeof message !== 'object') {
    return false;
  }
  
  if (schema.required) {
    for (const field of schema.required) {
      if (!(field in message)) {
        return false;
      }
    }
  }
  
  return true;
};

global.retry = async (fn, maxAttempts = 3, delay = 1000) => {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxAttempts) {
        throw error;
      }
      await wait(delay * attempt);
    }
  }
};

// Suppress console output during tests
beforeEach(() => {
  jest.spyOn(console, 'log').mockImplementation(() => {});
  jest.spyOn(console, 'warn').mockImplementation(() => {});
  jest.spyOn(console, 'error').mockImplementation(() => {});
});

// Restore console output after tests
afterEach(() => {
  jest.restoreAllMocks();
});

// Global teardown to save all logs at the end of test suite
// This will only run once per test process
afterAll(async () => {
  // Add a small delay to ensure all tests are complete
  await new Promise(resolve => setTimeout(resolve, 100));
  
  // Save all logs from the shared logger
  console.log('📄 Saving all test logs...');
  TestLogger.saveAllLogs();
}); 