# Performance Testing (Phase 3 - System)

## Objective
Implement comprehensive performance tests for the renewable energy IoT monitoring system MVP, focusing on system throughput, latency, resource utilization, and scalability under load. **Test against the actual running services from your main docker-compose.yml.**

## Context
This is Phase 3 of our incremental testing approach. We're building on the foundation of Phase 1 (JavaScript tests) and Phase 2 (integration tests) to validate system performance under various load conditions. **The main docker-compose.yml should be carefully analyzed to understand the actual service configurations, resource limits, and performance characteristics.**

## Pre-Implementation Analysis
**Before writing tests, thoroughly analyze the relevant folders in your project to understand:**

### **mosquitto/ folder:**
- **Configuration files** (`mosquitto/config/mosquitto.conf`) - Connection limits, message queuing, performance settings
- **Log files** (`mosquitto/log/`) - Performance metrics and connection patterns
- **Data persistence** (`mosquitto/data/`) - Message storage and retrieval performance

### **node-red/ folder:**
- **Flow files** (`node-red/flows/`) - Processing complexity and data transformation overhead
- **Package configuration** (`node-red/package.json`) - Dependencies and resource requirements
- **Settings configuration** (`node-red/settings.js`) - Runtime performance settings and limits

### **influxdb/ folder:**
- **Configuration files** (`influxdb/config/`) - Database performance settings, write/read optimizations
- **Schema definitions** (`influxdb/config/schemas/`) - Data structure impact on query performance
- **Scripts directory** (`influxdb/scripts/`) - Performance optimization scripts and utilities

### **grafana/ folder:**
- **Dashboard configurations** (`grafana/dashboards/`) - Query complexity and visualization performance
- **Data source configuration** (`grafana/provisioning/datasources/`) - Connection pooling and query optimization
- **Provisioning settings** (`grafana/provisioning/`) - Dashboard loading and rendering performance

### **scripts/ folder:**
- **Device simulation scripts** (`scripts/simulate-devices.sh`, `scripts/generate-data.js`) - Load generation capabilities
- **Performance monitoring scripts** (`scripts/check-data.js`) - Existing performance measurement utilities
- **System utilities** (`scripts/`) - Resource monitoring and optimization tools

## Scope
- System throughput and message processing capacity with actual running services
- End-to-end latency measurement with real data flow
- Resource utilization monitoring (CPU, memory, disk, network) with actual containers
- Scalability testing under increasing load with real services
- Performance degradation analysis with actual instances
- Bottleneck identification and optimization with real services
- **Integration with actual running services from main docker-compose.yml**

## Approach
**Primary Language**: JavaScript/Node.js (load generation and monitoring)
**Secondary Languages**: Python (complex performance analysis), Shell (system monitoring)
**Containerization**: Docker with all services
**Focus**: System performance validation and optimization
**Integration**: **Test against actual running services from main docker-compose.yml**

## Success Criteria
- System handles expected message throughput with actual services
- End-to-end latency remains within acceptable limits with real data flow
- Resource utilization stays within defined thresholds with actual containers
- System scales appropriately under increasing load with real services
- Performance bottlenecks are identified and documented with actual instances
- Performance degradation patterns are understood with real services
- Tests provide actionable performance insights with actual running services
- **Successfully validates performance characteristics of actual running services**

## Implementation Strategy

### Test Structure
```
tests/performance/
├── load-testing/
│   ├── throughput.test.js      # Message throughput testing with actual services
│   ├── latency.test.js         # End-to-end latency measurement with real services
│   └── scalability.test.js     # Scalability testing with actual services
├── resource-monitoring/
│   ├── cpu-usage.test.js       # CPU utilization monitoring with actual containers
│   ├── memory-usage.test.js    # Memory usage tracking with real containers
│   └── disk-io.test.js         # Disk I/O performance with actual services
├── stress-testing/
│   ├── peak-load.test.js       # Peak load handling with actual services
│   ├── sustained-load.test.js  # Sustained load testing with real services
│   └── recovery.test.js        # Recovery performance with actual services
└── utils/
    ├── load-generator.js       # Load generation utilities for actual services
    ├── performance-monitor.js  # Performance monitoring for real services
    └── metrics-collector.js    # Metrics collection from actual services
```

### Core Test Components

#### 1. Throughput Testing (`throughput.test.js`)
```javascript
// Test system throughput with actual running services
describe('System Throughput', () => {
  test('should handle expected message throughput with actual services', async () => {
    // Throughput test implementation using actual running services
  });
  
  test('should maintain throughput under sustained load with actual services', async () => {
    // Sustained load test using actual running services
  });
});
```

#### 2. Latency Testing (`latency.test.js`)
```javascript
// Test end-to-end latency with actual services
describe('End-to-End Latency', () => {
  test('should maintain acceptable latency with actual services', async () => {
    // Latency test using actual running services
  });
});
```

#### 3. Resource Monitoring (`cpu-usage.test.js`)
```javascript
// Test resource utilization with actual containers
describe('Resource Utilization', () => {
  test('should maintain CPU usage within limits with actual containers', async () => {
    // CPU monitoring test using actual running containers
  });
});
```

### Test Data Configuration

#### Performance Test Scenarios
```javascript
// Performance test scenarios for actual services
const performanceTestScenarios = {
  baseline: {
    messageRate: 100,  // messages per second
    duration: 300,     // seconds
    deviceTypes: ["photovoltaic", "wind_turbine"]
  },
  moderate: {
    messageRate: 500,
    duration: 600,
    deviceTypes: ["photovoltaic", "wind_turbine", "energy_storage"]
  },
  high: {
    messageRate: 1000,
    duration: 900,
    deviceTypes: ["photovoltaic", "wind_turbine", "energy_storage", "biogas_plant"]
  },
  peak: {
    messageRate: 2000,
    duration: 300,
    deviceTypes: ["photovoltaic", "wind_turbine", "energy_storage", "biogas_plant", "heat_boiler"]
  }
};
```

### Docker Integration

#### Performance Test Configuration
```javascript
// config/performance-test-config.json - Based on actual docker-compose.yml
{
  "services": {
    "mqtt": {
      "host": "mosquitto",  // Actual service name from docker-compose.yml
      "port": 1883,         // Actual port from docker-compose.yml
      "maxConnections": 1000  // From docker-compose.yml environment variables
    },
    "nodeRed": {
      "host": "node-red",   // Actual service name from docker-compose.yml
      "port": 1880,         // Actual port from docker-compose.yml
      "maxMemory": "512m"   // From docker-compose.yml
    },
    "influxdb": {
      "host": "influxdb",   // Actual service name from docker-compose.yml
      "port": 8086          // Actual port from docker-compose.yml
    },
    "grafana": {
      "host": "grafana",    // Actual service name from docker-compose.yml
      "port": 3000          // Actual port from docker-compose.yml
    }
  },
  "performanceThresholds": {
    "maxLatency": 5000,     // milliseconds
    "maxCpuUsage": 80,      // percentage
    "maxMemoryUsage": 85,   // percentage
    "minThroughput": 100    // messages per second
  }
}
```

### Test Execution

#### Performance Test Setup
```javascript
// tests/performance/utils/load-generator.js
class LoadGenerator {
  async generateLoad(scenario) {
    // Generate realistic load for actual services
    // Use device simulation scripts from scripts/ folder
    // Monitor performance metrics from actual running services
  }
}
```

## Test Scenarios

### 1. Baseline Performance
- System performance under normal operating conditions with actual services
- Resource utilization during typical usage with real containers
- End-to-end latency measurement with actual data flow

### 2. Load Testing
- Gradual increase in message throughput with actual services
- System behavior under moderate load with real services
- Performance degradation patterns with actual instances

### 3. Stress Testing
- System behavior under peak load with actual services
- Resource exhaustion scenarios with real containers
- Recovery performance after stress with actual services

### 4. Scalability Testing
- System performance with increasing device count with actual services
- Resource scaling patterns with real containers
- Performance bottlenecks identification with actual instances

### 5. Resource Monitoring
- CPU utilization patterns with actual containers
- Memory usage tracking with real services
- Disk I/O performance with actual instances
- Network bandwidth utilization with real services

### 6. Recovery Testing
- System recovery after performance degradation with actual services
- Resource cleanup and optimization with real containers
- Performance restoration patterns with actual instances

## MVP Considerations
- Focus on photovoltaic and wind turbine performance first
- Test with realistic but manageable load levels
- Prioritize system stability over maximum performance
- Use simple performance metrics for MVP phase
- Ensure basic performance requirements are met
- Keep performance thresholds reasonable for MVP
- Use Docker for consistent test environment
- **Test against actual running services from main docker-compose.yml**

## Implementation Notes
- Use device simulation scripts to generate realistic load for actual services
- Monitor resource utilization across all containers with real services
- Measure end-to-end performance metrics with actual data flow
- Test performance degradation and recovery with real services
- Focus on critical performance paths for MVP
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- **Carefully analyze main docker-compose.yml for performance-related configurations**
- **Use actual service names, ports, resource limits, and network settings from docker-compose.yml**
- **Test real performance characteristics, not simulated metrics**
- **Analyze all relevant project folders (mosquitto/, node-red/, influxdb/, grafana/, scripts/) before implementing tests** 