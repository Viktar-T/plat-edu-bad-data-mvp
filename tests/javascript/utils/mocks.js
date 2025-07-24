/**
 * Mock data and functions for renewable energy IoT monitoring system tests
 */

/**
 * Mock MQTT client for testing
 */
class MockMqttClient {
  constructor(options = {}) {
    this.options = options;
    this.connected = false;
    this.subscriptions = new Map();
    this.publishedMessages = [];
    this.receivedMessages = [];
    this.eventListeners = new Map();
  }

  on(event, callback) {
    if (!this.eventListeners.has(event)) {
      this.eventListeners.set(event, []);
    }
    this.eventListeners.get(event).push(callback);
  }

  emit(event, ...args) {
    const listeners = this.eventListeners.get(event) || [];
    listeners.forEach(callback => callback(...args));
  }

  connect() {
    setTimeout(() => {
      this.connected = true;
      this.emit('connect');
    }, 100);
  }

  disconnect() {
    this.connected = false;
    this.emit('disconnect');
  }

  publish(topic, message, options = {}, callback) {
    const publishedMessage = {
      topic,
      message: typeof message === 'string' ? JSON.parse(message) : message,
      options,
      timestamp: new Date().toISOString()
    };
    
    this.publishedMessages.push(publishedMessage);
    
    if (callback) {
      setTimeout(() => callback(null, { messageId: Math.random() }), 50);
    }
  }

  subscribe(topic, options = {}, callback) {
    this.subscriptions.set(topic, options);
    
    if (callback) {
      setTimeout(() => callback(null, [{ topic, qos: options.qos || 0 }]), 50);
    }
  }

  unsubscribe(topic, callback) {
    this.subscriptions.delete(topic);
    
    if (callback) {
      setTimeout(callback, 50);
    }
  }

  // Mock receiving a message
  receiveMessage(topic, message) {
    const receivedMessage = {
      topic,
      message: typeof message === 'string' ? JSON.parse(message) : message,
      timestamp: new Date().toISOString()
    };
    
    this.receivedMessages.push(receivedMessage);
    this.emit('message', topic, JSON.stringify(message));
  }

  // Mock connection error
  simulateError(error) {
    this.emit('error', new Error(error));
  }
}

/**
 * Mock HTTP client for testing
 */
class MockHttpClient {
  constructor() {
    this.requests = [];
    this.responses = new Map();
  }

  // Set up mock responses
  mockResponse(url, method, response) {
    const key = `${method.toUpperCase()}:${url}`;
    this.responses.set(key, response);
  }

  async get(url, options = {}) {
    const key = `GET:${url}`;
    this.requests.push({ method: 'GET', url, options });
    
    const response = this.responses.get(key) || {
      status: 200,
      data: { message: 'Mock response' }
    };
    
    return response;
  }

  async post(url, data, options = {}) {
    const key = `POST:${url}`;
    this.requests.push({ method: 'POST', url, data, options });
    
    const response = this.responses.get(key) || {
      status: 200,
      data: { message: 'Mock response' }
    };
    
    return response;
  }
}

/**
 * Mock InfluxDB client for testing
 */
class MockInfluxDBClient {
  constructor() {
    this.writtenPoints = [];
    this.queries = [];
  }

  async writePoints(points) {
    this.writtenPoints.push(...points);
    return Promise.resolve();
  }

  async queryRaw(query) {
    this.queries.push(query);
    return Promise.resolve({
      data: [
        {
          table: 0,
          _time: new Date().toISOString(),
          _value: 100,
          device_id: 'test-device',
          device_type: 'photovoltaic'
        }
      ]
    });
  }
}

/**
 * Mock data generators
 */
const mockData = {
  /**
   * Generate photovoltaic device data
   */
  photovoltaic: (deviceId = 'pv001', overrides = {}) => ({
    timestamp: new Date().toISOString(),
    device_id: deviceId,
    device_type: 'photovoltaic',
    power_output: 2500.5,
    voltage: 48.2,
    current: 51.9,
    temperature: 45.3,
    efficiency: 18.5,
    irradiance: 850.2,
    status: 'generating',
    ...overrides
  }),

  /**
   * Generate wind turbine device data
   */
  windTurbine: (deviceId = 'wt001', overrides = {}) => ({
    timestamp: new Date().toISOString(),
    device_id: deviceId,
    device_type: 'wind_turbine',
    power_output: 1800.0,
    wind_speed: 12.5,
    wind_direction: 180,
    rpm: 1200,
    temperature: 25.0,
    efficiency: 85.2,
    status: 'generating',
    ...overrides
  }),

  /**
   * Generate biogas plant device data
   */
  biogasPlant: (deviceId = 'bg001', overrides = {}) => ({
    timestamp: new Date().toISOString(),
    device_id: deviceId,
    device_type: 'biogas_plant',
    gas_flow_rate: 150.5,
    methane_concentration: 65.2,
    temperature: 38.0,
    pressure: 1.2,
    power_output: 3200.0,
    efficiency: 78.5,
    status: 'running',
    ...overrides
  }),

  /**
   * Generate heat boiler device data
   */
  heatBoiler: (deviceId = 'hb001', overrides = {}) => ({
    timestamp: new Date().toISOString(),
    device_id: deviceId,
    device_type: 'heat_boiler',
    temperature: 85.0,
    pressure: 2.5,
    fuel_consumption: 45.2,
    efficiency: 92.1,
    heat_output: 50000.0,
    status: 'running',
    ...overrides
  }),

  /**
   * Generate energy storage device data
   */
  energyStorage: (deviceId = 'es001', overrides = {}) => ({
    timestamp: new Date().toISOString(),
    device_id: deviceId,
    device_type: 'energy_storage',
    state_of_charge: 75.5,
    voltage: 400.0,
    current: 25.0,
    temperature: 25.0,
    power_input: 10000.0,
    power_output: 0.0,
    status: 'charging',
    ...overrides
  }),

  /**
   * Generate system status data
   */
  systemStatus: (component = 'mosquitto', overrides = {}) => ({
    timestamp: new Date().toISOString(),
    component,
    status: 'healthy',
    uptime: 3600,
    memory_usage: 45.2,
    cpu_usage: 12.5,
    ...overrides
  })
};

/**
 * Mock service responses
 */
const mockResponses = {
  nodeRed: {
    health: {
      status: 200,
      data: { status: 'ok', uptime: 3600 }
    },
    flows: {
      status: 200,
      data: [
        {
          id: 'flow1',
          label: 'Photovoltaic Data Flow',
          nodes: [
            { id: 'node1', type: 'mqtt in', name: 'MQTT Input' },
            { id: 'node2', type: 'function', name: 'Data Processing' },
            { id: 'node3', type: 'influxdb out', name: 'InfluxDB Output' }
          ]
        }
      ]
    }
  },

  grafana: {
    health: {
      status: 200,
      data: { database: 'ok', version: '10.2.0' }
    },
    dashboards: {
      status: 200,
      data: {
        dashboards: [
          { title: 'Renewable Energy Overview', uid: 'overview' },
          { title: 'Photovoltaic Monitoring', uid: 'photovoltaic' },
          { title: 'Wind Turbine Analytics', uid: 'wind-turbine' }
        ]
      }
    },
    datasources: {
      status: 200,
      data: [
        { name: 'InfluxDB', type: 'influxdb', url: 'http://influxdb:8086' }
      ]
    }
  },

  influxdb: {
    health: {
      status: 200,
      data: { status: 'pass', message: 'ready for queries and writes' }
    },
    query: {
      status: 200,
      data: {
        results: [
          {
            statement_id: 0,
            series: [
              {
                name: 'photovoltaic_data',
                columns: ['time', 'power_output', 'device_id'],
                values: [
                  ['2024-01-01T12:00:00Z', 2500.5, 'pv001'],
                  ['2024-01-01T12:01:00Z', 2510.2, 'pv001']
                ]
              }
            ]
          }
        ]
      }
    }
  }
};

module.exports = {
  MockMqttClient,
  MockHttpClient,
  MockInfluxDBClient,
  mockData,
  mockResponses
}; 