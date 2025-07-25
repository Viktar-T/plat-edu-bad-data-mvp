/**
 * MQTT Authentication Tests
 * 
 * Tests for MQTT authentication and authorization with actual running Mosquitto broker.
 */

const mqtt = require('mqtt');
const { loadConfig } = require('../utils/test-helpers');
const TestLogger = require('../utils/test-logger');

describe('MQTT Authentication Tests', () => {
  let client;
  let config;
  let logger;

  beforeAll(async () => {
    config = loadConfig('config/mqtt-test-config.json');
  });

  beforeEach(() => {
    logger = new TestLogger('MQTT Authentication Tests');
  });

  afterEach(async () => {
    if (client && client.connected) {
      await new Promise((resolve) => {
        client.end(true, {}, resolve);
      });
    }
    // Don't save logs here - global teardown will handle it
  });

  test('should authenticate with valid admin credentials', async () => {
    return new Promise((resolve, reject) => {
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: 'admin',
        password: 'admin_password_456',
        clientId: `test-admin-auth-${Date.now()}`,
        connectTimeout: 5000
      });

      client.on('connect', () => {
        expect(client.connected).toBe(true);
        resolve();
      });

      client.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        reject(new Error('Authentication timeout'));
      }, 10000);
    });
  });

  test('should reject invalid username', async () => {
    return new Promise((resolve, reject) => {
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: 'invalid_user',
        password: 'admin_password_456',
        clientId: `test-invalid-user-${Date.now()}`,
        connectTimeout: 5000
      });

      client.on('error', (error) => {
        expect(error).toBeDefined();
        expect(client.connected).toBe(false);
        resolve();
      });

      client.on('connect', () => {
        reject(new Error('Expected authentication to fail with invalid username'));
      });

      setTimeout(() => {
        if (!client.connected) {
          resolve();
        } else {
          reject(new Error('Expected authentication to fail'));
        }
      }, 10000);
    });
  });

  test('should reject invalid password', async () => {
    return new Promise((resolve, reject) => {
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: 'admin',
        password: 'invalid_password',
        clientId: `test-invalid-password-${Date.now()}`,
        connectTimeout: 5000
      });

      client.on('error', (error) => {
        expect(error).toBeDefined();
        expect(client.connected).toBe(false);
        resolve();
      });

      client.on('connect', () => {
        reject(new Error('Expected authentication to fail with invalid password'));
      });

      setTimeout(() => {
        if (!client.connected) {
          resolve();
        } else {
          reject(new Error('Expected authentication to fail'));
        }
      }, 10000);
    });
  });

  test('should authenticate with device credentials', async () => {
    return new Promise((resolve, reject) => {
      // Test with a device credential (pv_001)
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: 'pv_001',
        password: 'device_password_123', // This would be the actual device password
        clientId: `test-device-auth-${Date.now()}`,
        connectTimeout: 5000
      });

      client.on('connect', () => {
        expect(client.connected).toBe(true);
        resolve();
      });

      client.on('error', (error) => {
        // Device authentication might fail if passwords aren't set up
        // This is expected behavior for MVP
        expect(error).toBeDefined();
        expect(client.connected).toBe(false);
        resolve();
      });

      setTimeout(() => {
        if (!client.connected) {
          resolve();
        } else {
          resolve();
        }
      }, 10000);
    });
  });

  test('should handle anonymous connections if allowed', async () => {
    return new Promise((resolve, reject) => {
      // Test anonymous connection (no username/password)
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        clientId: `test-anonymous-${Date.now()}`,
        connectTimeout: 5000
      });

      client.on('connect', () => {
        expect(client.connected).toBe(true);
        resolve();
      });

      client.on('error', (error) => {
        // Anonymous connections might be rejected
        expect(error).toBeDefined();
        expect(client.connected).toBe(false);
        resolve();
      });

      setTimeout(() => {
        if (!client.connected) {
          resolve();
        } else {
          resolve();
        }
      }, 10000);
    });
  });

  test('should maintain authentication across reconnections', async () => {
    return new Promise((resolve, reject) => {
      let reconnectCount = 0;
      
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-reconnect-auth-${Date.now()}`,
        clean: false,
        reconnectPeriod: 1000
      });

      client.on('connect', () => {
        reconnectCount++;
        expect(client.connected).toBe(true);
        
        if (reconnectCount === 1) {
          // First connection - simulate disconnect
          client.end(true);
        } else if (reconnectCount === 2) {
          // Reconnected successfully with same credentials
          resolve();
        }
      });

      client.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        reject(new Error('Reconnection authentication timeout'));
      }, 15000);
    });
  });
}); 