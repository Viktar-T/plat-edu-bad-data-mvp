/**
 * Service Health Check Tests
 * 
 * Automated tests to verify all main services are running and healthy
 * before running MQTT tests.
 */

const axios = require('axios');
const mqtt = require('mqtt');
const { loadConfig } = require('../utils/test-helpers');
const TestLogger = require('../utils/test-logger');

describe('Service Health Check Tests', () => {
  let logger;
  let config;

  beforeAll(async () => {
    config = loadConfig('config/test-env.json');
  });

  beforeEach(() => {
    logger = new TestLogger('Service Health Check Tests');
  });

  afterEach(() => {
    // Don't save logs here - global teardown will handle it
  });

  test('should verify Mosquitto MQTT broker is running and accessible', async () => {
    logger.logStep('Testing Mosquitto MQTT broker health');
    
    return new Promise((resolve, reject) => {
      const clientId = `health-check-${Date.now()}`;
      const testTopic = 'system/health/test';
      const testMessage = 'health-check-ping';
      
      logger.info('Attempting connection to Mosquitto broker', {
        host: config.services.mqtt.host,
        port: config.services.mqtt.port,
        clientId
      });

      const client = mqtt.connect({
        host: config.services.mqtt.host,
        port: config.services.mqtt.port,
        username: config.services.mqtt.username,
        password: config.services.mqtt.password,
        clientId: clientId,
        connectTimeout: 10000,
        keepalive: 60
      });

      let messageReceived = false;
      const startTime = Date.now();

      client.on('connect', () => {
        const responseTime = Date.now() - startTime;
        logger.logConnection(clientId, config.services.mqtt.host, config.services.mqtt.port, true);
        logger.logPerformance('Mosquitto Connection Response Time', responseTime);
        
        logger.logStep('Mosquitto connected, testing message publishing');
        
        // Subscribe to test topic
        client.subscribe(testTopic, { qos: 1 }, (error) => {
          if (error) {
            logger.error('Failed to subscribe to test topic', error);
            reject(error);
            return;
          }
          
          logger.logSubscription(testTopic, 1, true);
          
          // Publish test message
          client.publish(testTopic, testMessage, { qos: 1 }, (error) => {
            if (error) {
              logger.error('Failed to publish test message', error);
              reject(error);
              return;
            }
            
            logger.logMessagePublish(testTopic, testMessage, 1, true);
          });
        });
      });

      client.on('message', (topic, message) => {
        if (topic === testTopic && message.toString() === testMessage) {
          logger.logMessageReceive(topic, message.toString(), 1);
          messageReceived = true;
          
          logger.logAssertion('Mosquitto message round-trip should work', true, true, true);
          logger.logAssertion('Mosquitto should be healthy', true, true, true);
          
          client.end(true, {}, () => {
            logger.logDisconnection(clientId, 'Health check completed');
            resolve();
          });
        }
      });

      client.on('error', (error) => {
        logger.error('Mosquitto connection error', error);
        logger.logAssertion('Mosquitto should be accessible', false, true, false);
        reject(error);
      });

      client.on('disconnect', () => {
        logger.logDisconnection(clientId, 'Unexpected disconnect');
      });

      // Timeout after 15 seconds
      setTimeout(() => {
        if (!messageReceived) {
          const error = new Error('Mosquitto health check timeout');
          logger.error('Mosquitto health check timeout', error);
          reject(error);
        }
      }, 15000);
    });
  });

  test('should verify InfluxDB is running and accessible', async () => {
    logger.logStep('Testing InfluxDB health');
    
    try {
      const startTime = Date.now();
      
      logger.info('Attempting to connect to InfluxDB', {
        url: `http://${config.services.influxdb.host}:${config.services.influxdb.port}/health`
      });

      const response = await axios.get(`http://${config.services.influxdb.host}:${config.services.influxdb.port}/health`, {
        timeout: 10000,
        validateStatus: (status) => status < 500 // Accept 2xx, 3xx, 4xx status codes
      });

      const responseTime = Date.now() - startTime;
      logger.logPerformance('InfluxDB Health Check Response Time', responseTime);
      
      logger.info('InfluxDB health check response', {
        status: response.status,
        statusText: response.statusText,
        data: response.data
      });

      // InfluxDB health endpoint should return 200 or 204
      const isHealthy = response.status === 200 || response.status === 204;
      logger.logAssertion('InfluxDB should be healthy', isHealthy, '200 or 204', response.status);
      
      expect(response.status).toBeOneOf([200, 204]);
      expect(responseTime).toBeLessThan(5000); // Should respond within 5 seconds
      
      logger.logAssertion('InfluxDB response time should be acceptable', responseTime < 5000, '< 5000ms', `${responseTime}ms`);
      
    } catch (error) {
      logger.error('InfluxDB health check failed', error);
      logger.logAssertion('InfluxDB should be accessible', false, true, false);
      throw error;
    }
  });

  test('should verify Node-RED is running and accessible', async () => {
    logger.logStep('Testing Node-RED health');
    
    try {
      const startTime = Date.now();
      
      logger.info('Attempting to connect to Node-RED', {
        url: `http://${config.services.nodeRed.host}:${config.services.nodeRed.port}`
      });

      const response = await axios.get(`http://${config.services.nodeRed.host}:${config.services.nodeRed.port}`, {
        timeout: 10000,
        validateStatus: (status) => status < 500
      });

      const responseTime = Date.now() - startTime;
      logger.logPerformance('Node-RED Health Check Response Time', responseTime);
      
      logger.info('Node-RED health check response', {
        status: response.status,
        statusText: response.statusText,
        contentType: response.headers['content-type']
      });

      // Node-RED should return 200 OK
      const isHealthy = response.status === 200;
      logger.logAssertion('Node-RED should be healthy', isHealthy, 200, response.status);
      
      expect(response.status).toBe(200);
      expect(responseTime).toBeLessThan(5000); // Should respond within 5 seconds
      
      logger.logAssertion('Node-RED response time should be acceptable', responseTime < 5000, '< 5000ms', `${responseTime}ms`);
      
      // Check if response contains Node-RED indicators
      const hasNodeRedContent = response.data.includes('node-red') || 
                               response.data.includes('Node-RED') ||
                               response.headers['content-type']?.includes('text/html');
      
      logger.logAssertion('Node-RED should return valid content', hasNodeRedContent, true, hasNodeRedContent);
      
    } catch (error) {
      logger.error('Node-RED health check failed', error);
      logger.logAssertion('Node-RED should be accessible', false, true, false);
      throw error;
    }
  });

  test('should verify Grafana is running and accessible', async () => {
    logger.logStep('Testing Grafana health');
    
    try {
      const startTime = Date.now();
      
      logger.info('Attempting to connect to Grafana', {
        url: `http://${config.services.grafana.host}:${config.services.grafana.port}`
      });

      const response = await axios.get(`http://${config.services.grafana.host}:${config.services.grafana.port}`, {
        timeout: 10000,
        validateStatus: (status) => status < 500
      });

      const responseTime = Date.now() - startTime;
      logger.logPerformance('Grafana Health Check Response Time', responseTime);
      
      logger.info('Grafana health check response', {
        status: response.status,
        statusText: response.statusText,
        contentType: response.headers['content-type']
      });

      // Grafana should return 200 OK or 302 redirect
      const isHealthy = response.status === 200 || response.status === 302;
      logger.logAssertion('Grafana should be healthy', isHealthy, '200 or 302', response.status);
      
      expect(response.status).toBeOneOf([200, 302]);
      expect(responseTime).toBeLessThan(5000); // Should respond within 5 seconds
      
      logger.logAssertion('Grafana response time should be acceptable', responseTime < 5000, '< 5000ms', `${responseTime}ms`);
      
      // Check if response contains Grafana indicators
      const hasGrafanaContent = response.data.includes('grafana') || 
                               response.data.includes('Grafana') ||
                               response.headers['content-type']?.includes('text/html');
      
      logger.logAssertion('Grafana should return valid content', hasGrafanaContent, true, hasGrafanaContent);
      
    } catch (error) {
      logger.error('Grafana health check failed', error);
      logger.logAssertion('Grafana should be accessible', false, true, false);
      throw error;
    }
  });

  test('should verify all services are running and healthy', async () => {
    logger.logStep('Comprehensive health check of all services');
    
    const healthResults = {
      mosquitto: false,
      influxdb: false,
      nodeRed: false,
      grafana: false
    };

    const startTime = Date.now();

    // Test Mosquitto
    try {
      await new Promise((resolve, reject) => {
        const client = mqtt.connect({
          host: config.services.mqtt.host,
          port: config.services.mqtt.port,
          username: config.services.mqtt.username,
          password: config.services.mqtt.password,
          clientId: `comprehensive-health-${Date.now()}`,
          connectTimeout: 5000
        });

        client.on('connect', () => {
          healthResults.mosquitto = true;
          client.end(true, {}, resolve);
        });

        client.on('error', () => {
          healthResults.mosquitto = false;
          resolve();
        });

        setTimeout(() => {
          healthResults.mosquitto = false;
          resolve();
        }, 5000);
      });
    } catch (error) {
      healthResults.mosquitto = false;
    }

    // Test InfluxDB
    try {
      await axios.get(`http://${config.services.influxdb.host}:${config.services.influxdb.port}/health`, {
        timeout: 5000,
        validateStatus: (status) => status < 500
      });
      healthResults.influxdb = true;
    } catch (error) {
      healthResults.influxdb = false;
    }

    // Test Node-RED
    try {
      await axios.get(`http://${config.services.nodeRed.host}:${config.services.nodeRed.port}`, {
        timeout: 5000,
        validateStatus: (status) => status < 500
      });
      healthResults.nodeRed = true;
    } catch (error) {
      healthResults.nodeRed = false;
    }

    // Test Grafana
    try {
      await axios.get(`http://${config.services.grafana.host}:${config.services.grafana.port}`, {
        timeout: 5000,
        validateStatus: (status) => status < 500
      });
      healthResults.grafana = true;
    } catch (error) {
      healthResults.grafana = false;
    }

    const totalTime = Date.now() - startTime;
    logger.logPerformance('Comprehensive Health Check Total Time', totalTime);

    logger.info('Comprehensive health check results', healthResults);

    // Log individual service results
    Object.entries(healthResults).forEach(([service, isHealthy]) => {
      logger.logAssertion(`${service} should be healthy`, isHealthy, true, isHealthy);
    });

    // Check if all services are healthy
    const allHealthy = Object.values(healthResults).every(result => result === true);
    logger.logAssertion('All services should be healthy', allHealthy, true, allHealthy);

    // Log summary
    const healthyCount = Object.values(healthResults).filter(result => result === true).length;
    const totalServices = Object.keys(healthResults).length;
    logger.info(`Health check summary: ${healthyCount}/${totalServices} services healthy`);

    expect(allHealthy).toBe(true);
    expect(totalTime).toBeLessThan(30000); // Should complete within 30 seconds
  });

  test('should verify service ports are accessible', async () => {
    logger.logStep('Testing service port accessibility');
    
    const portTests = [
      { service: 'Mosquitto MQTT', host: config.services.mqtt.host, port: config.services.mqtt.port },
      { service: 'Mosquitto WebSocket', host: config.services.mqtt.host, port: 9001 },
      { service: 'InfluxDB', host: config.services.influxdb.host, port: config.services.influxdb.port },
      { service: 'Node-RED', host: config.services.nodeRed.host, port: config.services.nodeRed.port },
      { service: 'Grafana', host: config.services.grafana.host, port: config.services.grafana.port }
    ];

    const portResults = {};

    for (const test of portTests) {
      try {
        const startTime = Date.now();
        
        logger.info(`Testing port accessibility for ${test.service}`, {
          host: test.host,
          port: test.port
        });

        // Use a simple TCP connection test
        const response = await axios.get(`http://${test.host}:${test.port}`, {
          timeout: 5000,
          validateStatus: () => true // Accept any status code
        });

        const responseTime = Date.now() - startTime;
        portResults[test.service] = { accessible: true, responseTime };
        
        logger.logPerformance(`${test.service} Port Response Time`, responseTime);
        logger.logAssertion(`${test.service} port should be accessible`, true, true, true);
        
      } catch (error) {
        portResults[test.service] = { accessible: false, error: error.message };
        logger.logAssertion(`${test.service} port should be accessible`, false, true, false);
        logger.warn(`${test.service} port test failed`, { error: error.message });
      }
    }

    logger.info('Port accessibility test results', portResults);

    // Check if all critical ports are accessible
    const criticalServices = ['Mosquitto MQTT', 'InfluxDB', 'Node-RED'];
    const criticalPortsAccessible = criticalServices.every(service => 
      portResults[service]?.accessible === true
    );

    logger.logAssertion('All critical service ports should be accessible', 
      criticalPortsAccessible, true, criticalPortsAccessible);

    expect(criticalPortsAccessible).toBe(true);
  });
}); 