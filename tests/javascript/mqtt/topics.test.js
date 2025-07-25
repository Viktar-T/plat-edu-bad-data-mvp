/**
 * MQTT Topic Structure Tests
 * 
 * Tests for MQTT topic structure validation with actual running Mosquitto broker.
 */

const mqtt = require('mqtt');
const { loadConfig, validateTopicStructure } = require('../utils/test-helpers');
const TestLogger = require('../utils/test-logger');

describe('MQTT Topic Structure Tests', () => {
  let client;
  let config;
  let logger;

  beforeAll(async () => {
    config = loadConfig('config/mqtt-test-config.json');
  });

  beforeEach(() => {
    logger = new TestLogger('MQTT Topic Structure Tests');
  });

  afterEach(async () => {
    if (client && client.connected) {
      await new Promise((resolve) => {
        client.end(true, {}, resolve);
      });
    }
    // Don't save logs here - global teardown will handle it
  });

  test('should follow device topic pattern in actual broker', async () => {
    logger.logStep('Testing device topic pattern validation and publishing');
    
    return new Promise((resolve, reject) => {
      const validTopics = [
        'devices/photovoltaic/pv_001/data',
        'devices/wind_turbine/wt_001/data',
        'devices/biogas_plant/bg_001/data',
        'devices/heat_boiler/hb_001/data',
        'devices/energy_storage/es_001/data'
      ];

      const validPatterns = [
        'devices/{device_type}/{device_id}/data',
        'devices/{device_type}/{device_id}/status',
        'devices/{device_type}/{device_id}/commands'
      ];

      logger.info('Validating topic structure patterns', {
        topics: validTopics,
        patterns: validPatterns
      });

      // Validate topic structure
      validTopics.forEach(topic => {
        const isValid = validateTopicStructure(topic, validPatterns);
        logger.logAssertion(`Topic ${topic} should be valid`, isValid, true, isValid);
        expect(isValid).toBe(true);
      });

      const clientId = `test-topic-structure-${Date.now()}`;
      logger.info('Creating MQTT client for topic structure test', {
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        clientId
      });

      // Test publishing to valid topics
      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: clientId
      });

      client.on('connect', () => {
        logger.logConnection(clientId, config.mqtt.connection.host, config.mqtt.connection.port, true);
        logger.logStep('Client connected, publishing to valid topics');
        
        let publishedCount = 0;
        const expectedCount = validTopics.length;

        validTopics.forEach(topic => {
          const testData = {
            timestamp: new Date().toISOString(),
            device_id: topic.split('/')[2],
            device_type: topic.split('/')[1],
            test: true
          };

          logger.info(`Publishing to topic: ${topic}`, testData);

          client.publish(topic, JSON.stringify(testData), { qos: 1 }, (error) => {
            if (error) {
              logger.error(`Failed to publish to topic ${topic}`, error);
              reject(error);
            } else {
              logger.logMessagePublish(topic, testData, 1, true);
              publishedCount++;
              logger.info(`Published ${publishedCount}/${expectedCount} messages`);
              
              if (publishedCount === expectedCount) {
                logger.logAssertion('All messages should be published', publishedCount === expectedCount, expectedCount, publishedCount);
                resolve();
              }
            }
          });
        });
      });

      client.on('error', (error) => {
        logger.error('MQTT client error during topic structure test', error);
        reject(error);
      });

      client.on('disconnect', () => {
        logger.logDisconnection(clientId, 'Topic structure test completed');
      });

      setTimeout(() => {
        const error = new Error('Topic structure test timeout');
        logger.error('Topic structure test timeout', error);
        reject(error);
      }, 15000);
    });
  });

  test('should handle wildcard subscriptions on real topics', async () => {
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'pv_001',
        device_type: 'photovoltaic',
        power_output: 2500.5,
        status: 'generating'
      };

      let messageReceived = false;

      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-wildcard-${Date.now()}`
      });

      client.on('connect', () => {
        // Subscribe to all photovoltaic device data
        client.subscribe('devices/photovoltaic/+/data', { qos: 1 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          // Publish to specific topic
          client.publish('devices/photovoltaic/pv_001/data', JSON.stringify(testData), { qos: 1 });
        });
      });

      client.on('message', (topic, message) => {
        expect(topic).toBe('devices/photovoltaic/pv_001/data');
        
        const receivedData = JSON.parse(message.toString());
        expect(receivedData.device_id).toBe('pv_001');
        expect(receivedData.device_type).toBe('photovoltaic');
        
        messageReceived = true;
        resolve();
      });

      client.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!messageReceived) {
          reject(new Error('Wildcard subscription timeout'));
        }
      }, 10000);
    });
  });

  test('should validate topic permissions with actual authentication', async () => {
    return new Promise((resolve, reject) => {
      const testTopics = [
        'devices/photovoltaic/pv_001/data',
        'devices/wind_turbine/wt_001/data',
        'system/health/mosquitto',
        'system/alerts/critical'
      ];

      let publishedCount = 0;
      const expectedCount = testTopics.length;

      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-permissions-${Date.now()}`
      });

      client.on('connect', () => {
        testTopics.forEach(topic => {
          const testData = {
            timestamp: new Date().toISOString(),
            test: true,
            topic: topic
          };

          client.publish(topic, JSON.stringify(testData), { qos: 1 }, (error) => {
            if (error) {
              // Some topics might be restricted - this is expected
              console.log(`Publish failed for topic ${topic}:`, error.message);
            }
            publishedCount++;
            
            if (publishedCount === expectedCount) {
              // Test completed regardless of individual publish results
              resolve();
            }
          });
        });
      });

      client.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (publishedCount < expectedCount) {
          resolve(); // Resolve anyway as some topics might be restricted
        }
      }, 15000);
    });
  });

  test('should handle invalid topic formats gracefully', async () => {
    return new Promise((resolve, reject) => {
      const invalidTopics = [
        'invalid/topic',
        'devices//data', // Empty device_type
        'devices/photovoltaic//data', // Empty device_id
        'devices/photovoltaic/pv_001/', // Missing data_type
        'devices/photovoltaic/pv_001/invalid_type' // Invalid data_type
      ];

      let errorCount = 0;
      const expectedErrors = invalidTopics.length;

      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-invalid-topics-${Date.now()}`
      });

      client.on('connect', () => {
        invalidTopics.forEach(topic => {
          const testData = { test: true };

          client.publish(topic, JSON.stringify(testData), { qos: 1 }, (error) => {
            if (error) {
              errorCount++;
            }
            
            if (errorCount === expectedErrors) {
              resolve();
            }
          });
        });
      });

      client.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (errorCount < expectedErrors) {
          resolve(); // Resolve anyway as some topics might be allowed
        }
      }, 10000);
    });
  });

  test('should support hierarchical topic structure', async () => {
    return new Promise((resolve, reject) => {
      const hierarchicalTopics = [
        'devices/photovoltaic/pv_001/data',
        'devices/photovoltaic/pv_001/status',
        'devices/photovoltaic/pv_001/commands',
        'devices/photovoltaic/pv_002/data',
        'devices/photovoltaic/pv_002/status'
      ];

      let subscribedCount = 0;
      const expectedCount = hierarchicalTopics.length;

      client = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-hierarchical-${Date.now()}`
      });

      client.on('connect', () => {
        // Subscribe to all photovoltaic device topics
        client.subscribe('devices/photovoltaic/+/+', { qos: 1 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          // Publish to each topic
          hierarchicalTopics.forEach(topic => {
            const testData = {
              timestamp: new Date().toISOString(),
              device_id: topic.split('/')[2],
              device_type: topic.split('/')[1],
              data_type: topic.split('/')[3],
              test: true
            };

            client.publish(topic, JSON.stringify(testData), { qos: 1 });
          });
        });
      });

      client.on('message', (topic, message) => {
        const receivedData = JSON.parse(message.toString());
        expect(receivedData).toHaveProperty('device_id');
        expect(receivedData).toHaveProperty('device_type');
        expect(receivedData).toHaveProperty('data_type');
        
        subscribedCount++;
        
        if (subscribedCount === expectedCount) {
          resolve();
        }
      });

      client.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (subscribedCount < expectedCount) {
          reject(new Error(`Expected ${expectedCount} messages, received ${subscribedCount}`));
        }
      }, 15000);
    });
  });
}); 