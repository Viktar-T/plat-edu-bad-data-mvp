# Grafana Dashboard Testing (Phase 4 - Validation)

## Objective
Implement comprehensive Grafana dashboard tests for the renewable energy IoT monitoring system MVP, focusing on dashboard functionality, data visualization accuracy, and real-time data display. **Test against the actual running Grafana instance from your main docker-compose.yml.**

## Context
This is Phase 4 of our incremental testing approach. We're building on the foundation of previous phases to validate the visualization layer of the system. **The main docker-compose.yml should be carefully analyzed to understand the actual Grafana configuration, ports, authentication, and dashboard provisioning.**

## Pre-Implementation Analysis
**Before writing tests, thoroughly analyze the `grafana/` folder in your project to understand:**
- **Dashboard configurations** (`grafana/dashboards/`) - JSON dashboard definitions for renewable energy monitoring (photovoltaic, wind turbine, energy storage, etc.)
- **Data source configuration** (`grafana/provisioning/datasources/`) - InfluxDB data source setup and connection parameters
- **Dashboard provisioning** (`grafana/provisioning/dashboards/`) - Dashboard deployment configuration and auto-loading settings
- **Data directory** (`grafana/data/`) - Grafana runtime data, user preferences, and configuration persistence
- **Plugins directory** (`grafana/plugins/`) - Custom plugins and visualization components
- **Dashboard structure** - How panels are organized and configured for different device types
- **Query patterns** - InfluxDB query templates and data retrieval strategies
- **Alerting configuration** - Dashboard-based alerting rules and notification settings

## Scope
- Dashboard loading and rendering with actual running Grafana instance
- Data source connectivity and query execution with real InfluxDB
- Real-time data visualization accuracy with actual data flow
- Panel functionality and interaction with real dashboards
- Alerting and notification systems with actual Grafana
- Dashboard performance and responsiveness with real data
- **Integration with actual Grafana service from main docker-compose.yml**

## Approach
**Primary Language**: JavaScript/Node.js (Grafana API testing)
**Secondary Language**: SQL (data verification queries)
**Containerization**: Docker with Grafana instance
**Focus**: Dashboard functionality and data visualization validation
**Integration**: **Test against actual running Grafana service**

## Success Criteria
- Dashboards load correctly with actual Grafana instance
- Data sources connect and query successfully with real InfluxDB
- Real-time data updates display accurately with actual data flow
- Panel interactions work correctly with real dashboards
- Alerting systems function properly with actual Grafana
- Dashboard performance meets user experience requirements
- Tests run consistently in Docker environment
- **Successfully validates dashboard functionality with actual running Grafana**

## Implementation Strategy

### Test Structure
```
tests/javascript/grafana/
├── dashboard.test.js           # Dashboard loading and functionality with actual Grafana
├── data-source.test.js         # Data source connectivity with real InfluxDB
├── visualization.test.js       # Data visualization accuracy with actual dashboards
├── alerting.test.js           # Alerting system testing with actual Grafana
├── performance.test.js         # Dashboard performance with real data
└── utils/
    ├── grafana-api.js         # Grafana API utilities for actual instance
    └── dashboard-validator.js  # Dashboard validation utilities for real dashboards
```

### Core Test Components

#### 1. Dashboard Testing (`dashboard.test.js`)
```javascript
// Test dashboard functionality with actual Grafana
describe('Grafana Dashboard', () => {
  test('should load photovoltaic dashboard successfully with actual Grafana', async () => {
    // Dashboard loading test using actual Grafana instance
  });
  
  test('should display real-time data correctly with actual Grafana', async () => {
    // Real-time data test using actual Grafana
  });
});
```

#### 2. Data Source Testing (`data-source.test.js`)
```javascript
// Test data source connectivity with actual InfluxDB
describe('Data Source Connectivity', () => {
  test('should connect to InfluxDB data source with actual Grafana', async () => {
    // Data source test using actual Grafana and InfluxDB
  });
  
  test('should execute queries successfully with actual Grafana', async () => {
    // Query execution test using actual Grafana
  });
});
```

#### 3. Visualization Testing (`visualization.test.js`)
```javascript
// Test data visualization accuracy with actual dashboards
describe('Data Visualization', () => {
  test('should display photovoltaic data correctly with actual dashboards', async () => {
    // Visualization test using actual dashboards
  });
});
```

### Test Data Configuration

#### Grafana Test Scenarios
```javascript
// Test scenarios for actual Grafana dashboards
const grafanaTestScenarios = {
  photovoltaic: {
    dashboard: "photovoltaic-monitoring",
    panels: ["power_output", "efficiency", "temperature"],
    dataSource: "InfluxDB",
    expectedData: {
      power_output: { min: 0, max: 1000 },
      efficiency: { min: 0, max: 100 },
      temperature: { min: -20, max: 80 }
    }
  },
  windTurbine: {
    dashboard: "wind-turbine-analytics",
    panels: ["power_output", "wind_speed", "efficiency"],
    dataSource: "InfluxDB",
    expectedData: {
      power_output: { min: 0, max: 2000 },
      wind_speed: { min: 0, max: 25 },
      efficiency: { min: 0, max: 100 }
    }
  }
};
```

### Docker Integration

#### Grafana Test Configuration
```javascript
// config/grafana-test-config.json - Based on actual docker-compose.yml
{
  "grafana": {
    "host": "grafana",    // Actual service name from docker-compose.yml
    "port": 3000,         // Actual port from docker-compose.yml
    "adminUser": "admin", // From docker-compose.yml environment variables
    "adminPassword": "admin" // From docker-compose.yml
  },
  "dashboards": {
    "photovoltaic": "dashboards/photovoltaic-monitoring.json",
    "windTurbine": "dashboards/wind-turbine-analytics.json",
    "energyStorage": "dashboards/energy-storage-monitoring.json"
  },
  "dataSources": {
    "influxdb": {
      "name": "InfluxDB",
      "type": "influxdb",
      "url": "http://influxdb:8086"  // Actual InfluxDB service from docker-compose.yml
    }
  }
}
```

### Test Execution

#### Grafana Test Setup
```javascript
// tests/javascript/utils/grafana-api.js
class GrafanaAPI {
  constructor(config) {
    this.baseUrl = `http://${config.host}:${config.port}`;
    this.auth = {
      username: config.adminUser,
      password: config.adminPassword
    };
  }
  
  async testDashboard(dashboardName) {
    // Test dashboard functionality with actual Grafana instance
  }
  
  async testDataSource(dataSourceName) {
    // Test data source connectivity with actual Grafana
  }
}
```

## Test Scenarios

### 1. Dashboard Loading
- Load photovoltaic monitoring dashboard with actual Grafana
- Load wind turbine analytics dashboard with actual Grafana
- Validate dashboard structure and panel configuration with real dashboards

### 2. Data Source Connectivity
- Connect to InfluxDB data source with actual Grafana
- Execute test queries with actual Grafana
- Validate query results with real InfluxDB data

### 3. Real-time Visualization
- Display real-time photovoltaic data with actual dashboards
- Display real-time wind turbine data with actual dashboards
- Validate data accuracy and update frequency with real data

### 4. Panel Functionality
- Test panel interactions with actual dashboards
- Validate chart rendering with real data
- Test time range selection with actual dashboards

### 5. Alerting System
- Test alert rule creation with actual Grafana
- Validate alert notifications with actual Grafana
- Test alert state management with real dashboards

### 6. Performance Testing
- Dashboard loading time with actual Grafana
- Query response time with real InfluxDB
- Panel rendering performance with actual dashboards

## MVP Considerations
- Focus on photovoltaic and wind turbine dashboards first
- Test with realistic but manageable data volumes
- Prioritize core visualization functionality
- Use simple alerting rules for MVP phase
- Ensure basic dashboard functionality works reliably
- Keep performance requirements reasonable for MVP
- Use Docker for consistent test environment
- **Test against actual running Grafana instance from main docker-compose.yml**

## Implementation Notes
- Use Grafana API for testing actual instance functionality
- Test with realistic renewable energy device data
- Validate data visualization accuracy with real dashboards
- Test dashboard performance with actual data flow
- Focus on critical visualization paths for MVP
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- **Carefully analyze main docker-compose.yml for Grafana configuration**
- **Use actual service names, ports, authentication, and volumes from docker-compose.yml**
- **Test real Grafana dashboards, not mocked visualizations**
- **Analyze grafana/ folder structure and dashboard configurations before implementing tests** 