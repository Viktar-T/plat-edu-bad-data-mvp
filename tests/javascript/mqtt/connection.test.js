/**
 * MQTT Connection Tests
 * 
 * Tests for MQTT broker connectivity with actual running Mosquitto broker.
 */

const mqtt = require('mqtt');
const { loadConfig } = require('../utils/test-helpers');
const TestLogger = require('../utils/test-logger');

describe('MQTT Connection Tests', () => {
  let client;
  let config;
  let logger;

  beforeAll(async () => {
    config = loadConfig('config/mqtt-test-config.json');
  });

  beforeEach(() => {
    logger = new TestLogger('MQTT Connection Tests');
  });

  afterEach(async () => {
    if (client && client.connected) {
      await new Promise((resolve) => {
        client.end(true, {}, resolve);
      });
    }
    // Don't save logs here - global teardown will handle it
  });

  afterEach(async () => {
    if (client && client.connected) {
      await new Promise((resolve) => {
        client.end(true, {}, resolve);
      });
    }
  });

  test('should connect to actual Mosquitto broker successfully', async () => {
    const startTime = Date.now();
    logger.logStep('Starting connection test to actual Mosquitto broker');
    
    return new Promise((resolve, reject) => {
      const clientId = `test-connection-${Date.now()}`;
      logger.info('Creating MQTT client', {
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        clientId,
        username: config.mqtt.connection.username
      });

      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: clientId,
        clean: config.mqtt.connection.clean,
        connectTimeout: config.mqtt.connection.connectTimeout,
        keepalive: config.mqtt.connection.keepalive
      });

      client.on('connect', () => {
        const responseTime = Date.now() - startTime;
        logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, true);
        logger.logPerformance('Connection Response Time', responseTime);
        
        logger.logAssertion('Client should be connected', client.connected, true, client.connected);
        logger.logAssertion('Response time should be less than 5000ms', responseTime < 5000, '< 5000ms', `${responseTime}ms`);
        
        expect(client.connected).toBe(true);
        expect(responseTime).toBeLessThan(5000); // Should connect within 5 seconds
        resolve();
      });

      client.on('error', (error) => {
        logger.error('MQTT connection error', error);
        reject(error);
      });

      client.on('disconnect', () => {
        logger.logDisconnection(clientId, 'Test completed');
      });

      // Timeout after 10 seconds
      setTimeout(() => {
        const error = new Error('Connection timeout');
        logger.error('Connection test timeout', error);
        reject(error);
      }, 10000);
    });
  });

  test('should handle connection failures gracefully', async () => {
    logger.logStep('Testing connection failure handling with non-existent broker');
    
    return new Promise((resolve, reject) => {
      const clientId = `test-failure-${Date.now()}`;
      logger.info('Attempting connection to non-existent broker', {
        host: 'non-existent-broker',
        port: 1883,
        clientId
      });

      // Try to connect to non-existent broker
      client = mqtt.connect({
        host: 'non-existent-broker',
        port: 1883,
        connectTimeout: 3000
      });

      client.on('error', (error) => {
        logger.error('Expected connection error', error);
        logger.logConnection(clientId, 'non-existent-broker', 1883, false);
        
        logger.logAssertion('Error should be defined', !!error, true, !!error);
        logger.logAssertion('Client should not be connected', !client.connected, false, client.connected);
        
        expect(error).toBeDefined();
        expect(client.connected).toBe(false);
        resolve();
      });

      client.on('connect', () => {
        logger.warn('Unexpected successful connection to non-existent broker');
      });

      // Should fail within 5 seconds
      setTimeout(() => {
        if (!client.connected) {
          logger.info('Connection failed as expected');
          resolve();
        } else {
          const error = new Error('Expected connection to fail');
          logger.error('Connection should have failed', error);
          reject(error);
        }
      }, 5000);
    });
  });

  test('should reconnect after connection loss', async () => {
    logger.logStep('Testing reconnection after connection loss');
    
    return new Promise((resolve, reject) => {
      let reconnectCount = 0;
      const clientId = `test-reconnect-${Date.now()}`;
      
      logger.info('Creating MQTT client with reconnection enabled', {
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        clientId,
        clean: false,
        reconnectPeriod: 1000
      });
      
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: clientId,
        clean: false, // Don't clean session to test reconnection
        reconnectPeriod: 1000
      });

      client.on('connect', () => {
        reconnectCount++;
        logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, true);
        logger.info(`Connection attempt ${reconnectCount} successful`);
        
        if (reconnectCount === 1) {
          // First connection - simulate disconnect
          logger.logStep('Simulating connection loss by calling client.end()');
          client.end(true);
        } else if (reconnectCount === 2) {
          // Reconnected successfully
          logger.logAssertion('Client should be connected after reconnection', client.connected, true, client.connected);
          logger.logAssertion('Reconnection count should be 2', reconnectCount, 2, reconnectCount);
          expect(client.connected).toBe(true);
          resolve();
        }
      });

      client.on('disconnect', () => {
        logger.logDisconnection(clientId, 'Simulated disconnect for reconnection test');
      });

      client.on('error', (error) => {
        logger.error('MQTT reconnection error', error);
        reject(error);
      });

      // Timeout after 15 seconds
      setTimeout(() => {
        const error = new Error('Reconnection timeout');
        logger.error('Reconnection test timeout', error);
        reject(error);
      }, 15000);
    });
  });

  test('should handle authentication failures', async () => {
    logger.logStep('Testing authentication failure with invalid credentials');
    
    return new Promise((resolve, reject) => {
      const clientId = `test-auth-failure-${Date.now()}`;
      logger.info('Attempting connection with invalid credentials', {
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        clientId,
        username: 'invalid_user'
      });

      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: 'invalid_user',
        password: 'invalid_password',
        clientId: clientId,
        connectTimeout: 5000
      });

      client.on('error', (error) => {
        logger.error('Expected authentication error', error);
        logger.logAuthentication('invalid_user', false, error);
        logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, false);
        
        logger.logAssertion('Error should be defined', !!error, true, !!error);
        logger.logAssertion('Client should not be connected', !client.connected, false, client.connected);
        
        expect(error).toBeDefined();
        expect(client.connected).toBe(false);
        resolve();
      });

      client.on('connect', () => {
        logger.warn('Unexpected successful authentication with invalid credentials');
        const error = new Error('Expected authentication to fail');
        logger.error('Authentication should have failed', error);
        reject(error);
      });

      // Should fail within 10 seconds
      setTimeout(() => {
        if (!client.connected) {
          logger.info('Authentication failed as expected');
          resolve();
        } else {
          const error = new Error('Expected authentication to fail');
          logger.error('Authentication should have failed', error);
          reject(error);
        }
      }, 10000);
    });
  });
}); 