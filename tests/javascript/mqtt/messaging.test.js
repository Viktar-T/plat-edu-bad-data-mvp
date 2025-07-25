/**
 * MQTT Messaging Tests
 * 
 * Tests for MQTT message publishing and subscribing with actual running Mosquitto broker.
 */

const mqtt = require('mqtt');
const { loadConfig, validateMessageFormat } = require('../utils/test-helpers');
const TestLogger = require('../utils/test-logger');

describe('MQTT Messaging Tests', () => {
  let publisher;
  let subscriber;
  let config;
  let logger;

  beforeAll(async () => {
    config = loadConfig('config/mqtt-test-config.json');
  });

  beforeEach(() => {
    logger = new TestLogger('MQTT Messaging Tests');
  });

  afterEach(async () => {
    if (publisher && publisher.connected) {
      await new Promise((resolve) => {
        publisher.end(true, {}, resolve);
      });
    }
    if (subscriber && subscriber.connected) {
      await new Promise((resolve) => {
        subscriber.end(true, {}, resolve);
      });
    }
    // Don't save logs here - global teardown will handle it
  });

  test('should publish photovoltaic data to actual broker', async () => {
    logger.logStep('Testing photovoltaic data publishing to actual broker');
    
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'pv_001',
        device_type: 'photovoltaic',
        power_output: 2500.5,
        voltage: 48.2,
        current: 51.9,
        temperature: 45.3,
        efficiency: 18.5,
        irradiance: 850.2,
        status: 'generating'
      };

      const topic = 'devices/photovoltaic/pv_001/data';
      const clientId = `test-publisher-${Date.now()}`;

      logger.info('Creating publisher client', {
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        clientId,
        topic
      });

      logger.info('Test data prepared', testData);

      publisher = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: clientId
      });

      publisher.on('connect', () => {
        logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, true);
        logger.logStep('Publisher connected, publishing message');
        
        publisher.publish(topic, JSON.stringify(testData), { qos: 1 }, (error) => {
          if (error) {
            logger.error('Publish error', error);
            reject(error);
          } else {
            logger.logMessagePublish(topic, testData, 1, true);
            logger.logAssertion('Publisher should be connected', publisher.connected, true, publisher.connected);
            expect(publisher.connected).toBe(true);
            resolve();
          }
        });
      });

      publisher.on('error', (error) => {
        logger.error('Publisher connection error', error);
        reject(error);
      });

      publisher.on('disconnect', () => {
        logger.logDisconnection(clientId, 'Test completed');
      });

      setTimeout(() => {
        const error = new Error('Publish timeout');
        logger.error('Publish test timeout', error);
        reject(error);
      }, 10000);
    });
  });

  test('should receive messages with correct format from actual broker', async () => {
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'wt_001',
        device_type: 'wind_turbine',
        power_output: 1800.0,
        wind_speed: 12.5,
        wind_direction: 180,
        rotor_speed: 15.2,
        efficiency: 85.3,
        status: 'generating'
      };

      const topic = 'devices/wind_turbine/wt_001/data';
      let messageReceived = false;

      // Create subscriber
      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        subscriber.subscribe(topic, { qos: 1 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          // Create publisher and send message
          publisher = mqtt.connect({
            host: config.mqtt.connection.host,
            port: config.mqtt.connection.port,
            username: config.mqtt.connection.username,
            password: config.mqtt.connection.password,
            clientId: `test-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            publisher.publish(topic, JSON.stringify(testData), { qos: 1 });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        expect(receivedTopic).toBe(topic);
        
        const receivedData = JSON.parse(message.toString());
        expect(receivedData).toEqual(testData);
        
        // Validate message format
        const validation = validateMessageFormat(receivedData, ['timestamp', 'device_id', 'device_type']);
        expect(validation.valid).toBe(true);
        
        messageReceived = true;
        resolve();
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!messageReceived) {
          reject(new Error('Message receive timeout'));
        }
      }, 10000);
    });
  });

  test('should handle message parsing errors', async () => {
    return new Promise((resolve, reject) => {
      const invalidData = 'invalid json data';
      const topic = 'devices/photovoltaic/pv_001/data';
      let errorHandled = false;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        subscriber.subscribe(topic, { qos: 1 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          publisher = mqtt.connect({
            host: config.mqtt.connection.host,
            port: config.mqtt.connection.port,
            username: config.mqtt.connection.username,
            password: config.mqtt.connection.password,
            clientId: `test-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            publisher.publish(topic, invalidData, { qos: 1 });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        expect(receivedTopic).toBe(topic);
        
        // Should handle invalid JSON gracefully
        try {
          JSON.parse(message.toString());
          reject(new Error('Expected JSON parsing to fail'));
        } catch (error) {
          expect(error).toBeInstanceOf(SyntaxError);
          errorHandled = true;
          resolve();
        }
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!errorHandled) {
          reject(new Error('Error handling timeout'));
        }
      }, 10000);
    });
  });

  test('should publish and receive multiple device types', async () => {
    return new Promise((resolve, reject) => {
      const deviceData = [
        {
          timestamp: new Date().toISOString(),
          device_id: 'pv_001',
          device_type: 'photovoltaic',
          power_output: 2500.5,
          voltage: 48.2,
          current: 51.9,
          temperature: 45.3,
          efficiency: 18.5,
          irradiance: 850.2,
          status: 'generating'
        },
        {
          timestamp: new Date().toISOString(),
          device_id: 'wt_001',
          device_type: 'wind_turbine',
          power_output: 1800.0,
          wind_speed: 12.5,
          wind_direction: 180,
          rotor_speed: 15.2,
          efficiency: 85.3,
          status: 'generating'
        },
        {
          timestamp: new Date().toISOString(),
          device_id: 'bg_001',
          device_type: 'biogas_plant',
          gas_flow_rate: 150.5,
          methane_concentration: 65.2,
          temperature: 38.0,
          pressure: 1.2,
          power_output: 3200.0,
          efficiency: 78.5,
          status: 'running'
        }
      ];

      const topics = [
        'devices/photovoltaic/pv_001/data',
        'devices/wind_turbine/wt_001/data',
        'devices/biogas_plant/bg_001/data'
      ];

      let receivedCount = 0;
      const expectedCount = deviceData.length;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        // Subscribe to all topics
        subscriber.subscribe('devices/+/+/data', { qos: 1 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          // Publish all messages
          publisher = mqtt.connect({
            host: config.mqtt.connection.host,
            port: config.mqtt.connection.port,
            username: config.mqtt.connection.username,
            password: config.mqtt.connection.password,
            clientId: `test-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            deviceData.forEach((data, index) => {
              publisher.publish(topics[index], JSON.stringify(data), { qos: 1 });
            });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        const receivedData = JSON.parse(message.toString());
        expect(receivedData).toHaveProperty('device_id');
        expect(receivedData).toHaveProperty('device_type');
        expect(receivedData).toHaveProperty('timestamp');
        
        receivedCount++;
        
        if (receivedCount === expectedCount) {
          resolve();
        }
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (receivedCount < expectedCount) {
          reject(new Error(`Expected ${expectedCount} messages, received ${receivedCount}`));
        }
      }, 15000);
    });
  });
}); 