/**
 * MQTT QoS Tests
 * 
 * Tests for MQTT Quality of Service levels with actual running Mosquitto broker.
 */

const mqtt = require('mqtt');
const { loadConfig } = require('../utils/test-helpers');
const TestLogger = require('../utils/test-logger');

describe('MQTT QoS Tests', () => {
  let publisher;
  let subscriber;
  let config;
  let logger;

  beforeAll(async () => {
    config = loadConfig('config/mqtt-test-config.json');
  });

  beforeEach(() => {
    logger = new TestLogger('MQTT QoS Tests');
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

  test('should handle QoS 0 (at most once)', async () => {
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'pv_001',
        device_type: 'photovoltaic',
        power_output: 2500.5,
        qos: 0
      };

      const topic = 'devices/photovoltaic/pv_001/data';
      let messageReceived = false;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-qos0-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        subscriber.subscribe(topic, { qos: 0 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          publisher = mqtt.connect({
            host: config.mqtt.connection.host,
            port: config.mqtt.connection.port,
            username: config.mqtt.connection.username,
            password: config.mqtt.connection.password,
            clientId: `test-qos0-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            publisher.publish(topic, JSON.stringify(testData), { qos: 0 });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        expect(receivedTopic).toBe(topic);
        
        const receivedData = JSON.parse(message.toString());
        expect(receivedData.qos).toBe(0);
        
        messageReceived = true;
        resolve();
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!messageReceived) {
          reject(new Error('QoS 0 test timeout'));
        }
      }, 10000);
    });
  });

  test('should handle QoS 1 (at least once)', async () => {
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'wt_001',
        device_type: 'wind_turbine',
        power_output: 1800.0,
        qos: 1
      };

      const topic = 'devices/wind_turbine/wt_001/data';
      let messageReceived = false;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-qos1-subscriber-${Date.now()}`
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
            clientId: `test-qos1-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            publisher.publish(topic, JSON.stringify(testData), { qos: 1 }, (error) => {
              if (error) {
                reject(error);
              }
            });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        expect(receivedTopic).toBe(topic);
        
        const receivedData = JSON.parse(message.toString());
        expect(receivedData.qos).toBe(1);
        
        messageReceived = true;
        resolve();
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!messageReceived) {
          reject(new Error('QoS 1 test timeout'));
        }
      }, 10000);
    });
  });

  test('should handle QoS 2 (exactly once)', async () => {
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'bg_001',
        device_type: 'biogas_plant',
        gas_flow_rate: 150.5,
        qos: 2
      };

      const topic = 'devices/biogas_plant/bg_001/data';
      let messageReceived = false;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-qos2-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        subscriber.subscribe(topic, { qos: 2 }, (error) => {
          if (error) {
            reject(error);
            return;
          }

          publisher = mqtt.connect({
            host: config.mqtt.connection.host,
            port: config.mqtt.connection.port,
            username: config.mqtt.connection.username,
            password: config.mqtt.connection.password,
            clientId: `test-qos2-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            publisher.publish(topic, JSON.stringify(testData), { qos: 2 }, (error) => {
              if (error) {
                reject(error);
              }
            });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        expect(receivedTopic).toBe(topic);
        
        const receivedData = JSON.parse(message.toString());
        expect(receivedData.qos).toBe(2);
        
        messageReceived = true;
        resolve();
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!messageReceived) {
          reject(new Error('QoS 2 test timeout'));
        }
      }, 10000);
    });
  });

  test('should handle QoS level mismatches', async () => {
    return new Promise((resolve, reject) => {
      const testData = {
        timestamp: new Date().toISOString(),
        device_id: 'hb_001',
        device_type: 'heat_boiler',
        temperature: 85.0,
        qos: 'mismatch'
      };

      const topic = 'devices/heat_boiler/hb_001/data';
      let messageReceived = false;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-qos-mismatch-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        // Subscribe with QoS 1
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
            clientId: `test-qos-mismatch-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            // Publish with QoS 2 (higher than subscription)
            publisher.publish(topic, JSON.stringify(testData), { qos: 2 }, (error) => {
              if (error) {
                reject(error);
              }
            });
          });
        });
      });

      subscriber.on('message', (receivedTopic, message) => {
        expect(receivedTopic).toBe(topic);
        
        const receivedData = JSON.parse(message.toString());
        expect(receivedData.qos).toBe('mismatch');
        
        messageReceived = true;
        resolve();
      });

      subscriber.on('error', (error) => {
        reject(error);
      });

      setTimeout(() => {
        if (!messageReceived) {
          reject(new Error('QoS mismatch test timeout'));
        }
      }, 10000);
    });
  });

  test('should test different QoS levels for different topics', async () => {
    return new Promise((resolve, reject) => {
      const testCases = [
        {
          topic: 'devices/photovoltaic/pv_001/data',
          qos: 0,
          data: { device_id: 'pv_001', device_type: 'photovoltaic', qos: 0 }
        },
        {
          topic: 'devices/wind_turbine/wt_001/data',
          qos: 1,
          data: { device_id: 'wt_001', device_type: 'wind_turbine', qos: 1 }
        },
        {
          topic: 'system/health/mosquitto',
          qos: 2,
          data: { component: 'mosquitto', status: 'healthy', qos: 2 }
        }
      ];

      let receivedCount = 0;
      const expectedCount = testCases.length;

      subscriber = mqtt.connect({
        host: config.mqtt.connection.host,
        port: config.mqtt.connection.port,
        username: config.mqtt.connection.username,
        password: config.mqtt.connection.password,
        clientId: `test-multi-qos-subscriber-${Date.now()}`
      });

      subscriber.on('connect', () => {
        // Subscribe to all topics with their respective QoS levels
        testCases.forEach(testCase => {
          subscriber.subscribe(testCase.topic, { qos: testCase.qos }, (error) => {
            if (error) {
              reject(error);
              return;
            }
          });
        });

        // Wait a bit for subscriptions to complete
        setTimeout(() => {
          publisher = mqtt.connect({
            host: config.mqtt.connection.host,
            port: config.mqtt.connection.port,
            username: config.mqtt.connection.username,
            password: config.mqtt.connection.password,
            clientId: `test-multi-qos-publisher-${Date.now()}`
          });

          publisher.on('connect', () => {
            testCases.forEach(testCase => {
              const messageData = {
                timestamp: new Date().toISOString(),
                ...testCase.data
              };

              publisher.publish(testCase.topic, JSON.stringify(messageData), { qos: testCase.qos });
            });
          });
        }, 1000);
      });

      subscriber.on('message', (receivedTopic, message) => {
        const receivedData = JSON.parse(message.toString());
        const testCase = testCases.find(tc => tc.topic === receivedTopic);
        
        expect(testCase).toBeDefined();
        expect(receivedData.qos).toBe(testCase.qos);
        
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