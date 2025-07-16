# Development Workflow

## Overview

This document outlines the development workflow, container management procedures, and best practices for the IoT Renewable Energy Monitoring System.

## Development Environment Setup

### Prerequisites

- **Docker Desktop**: v20.10+ with WSL2 backend
- **Docker Compose**: v2.0+
- **Node.js**: v18+ (for local development)
- **Git**: Latest version
- **VS Code**: Recommended IDE with extensions

### Required VS Code Extensions

```json
{
  "recommendations": [
    "ms-vscode.vscode-docker",
    "ms-vscode.vscode-json",
    "ms-vscode.vscode-yaml",
    "ms-vscode.vscode-typescript-next",
    "ms-vscode.vscode-node-debug2",
    "ms-vscode.vscode-jest",
    "ms-vscode.vscode-eslint"
  ]
}
```

## Container Management Procedures

### 1. Service Lifecycle Management

#### Starting Services
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d mosquitto

# Start with logs
docker-compose up

# Start with rebuild
docker-compose up --build -d
```

#### Stopping Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop node-red
```

#### Service Status
```bash
# Check service status
docker-compose ps

# Check service logs
docker-compose logs -f node-red

# Check resource usage
docker stats
```

### 2. Development Workflow

#### Daily Development Cycle

1. **Start Development Environment**
   ```bash
   # Pull latest changes
   git pull origin main
   
   # Start services
   docker-compose up -d
   
   # Verify all services are running
   docker-compose ps
   ```

2. **Development Tasks**
   ```bash
   # Access Node-RED for flow development
   # http://localhost:1880
   
   # Access Grafana for dashboard development
   # http://localhost:3000 (admin/admin)
   
   # Access InfluxDB for data inspection
   # http://localhost:8086
   ```

3. **Testing Changes**
   ```bash
   # Test MQTT communication
   mosquitto_pub -h localhost -t "test/topic" -m "test message"
   
   # Check Node-RED logs
   docker-compose logs -f node-red
   
   # Verify data flow
   # Check InfluxDB for data insertion
   ```

4. **Commit and Push**
   ```bash
   # Stage changes
   git add .
   
   # Commit with descriptive message
   git commit -m "feat: add photovoltaic data processing flow"
   
   # Push to remote
   git push origin feature/new-feature
   ```

### 3. Service-Specific Development

#### Node-RED Development

**Local Development Setup**
```bash
# Create local Node-RED directory
mkdir -p node-red/data
mkdir -p node-red/flows

# Copy flows from container
docker cp $(docker-compose ps -q node-red):/data/flows.json node-red/flows/

# Edit flows locally
code node-red/flows/flows.json
```

**Flow Development Best Practices**
```typescript
// TypeScript function node example
interface DeviceData {
  device_id: string;
  device_type: string;
  timestamp: string;
  data: Record<string, number>;
  status: string;
  location: string;
}

function processDeviceData(msg: any): any {
  try {
    const data = msg.payload as DeviceData;
    
    // Validation
    if (!validateDeviceData(data)) {
      throw new Error('Invalid device data');
    }
    
    // Transformation
    const transformed = transformDeviceData(data);
    
    // Return processed data
    return {
      payload: transformed,
      topic: `processed/${data.device_type}/${data.device_id}`
    };
  } catch (error) {
    node.error(`Processing error: ${error.message}`);
    return null;
  }
}

function validateDeviceData(data: DeviceData): boolean {
  return !!(data.device_id && data.timestamp && data.data);
}

function transformDeviceData(data: DeviceData): any {
  return {
    ...data,
    timestamp: new Date(data.timestamp).toISOString(),
    processed_at: new Date().toISOString()
  };
}
```

#### MQTT Development

**Topic Structure Development**
```bash
# Test topic publishing
mosquitto_pub -h localhost -t "devices/photovoltaic/pv_001/telemetry" \
  -m '{"device_id":"pv_001","device_type":"photovoltaic","timestamp":"2024-01-15T10:30:00Z","data":{"irradiance":850.5,"temperature":45.2,"voltage":48.3,"current":12.1,"power_output":584.43},"status":"operational","location":"site_a"}'

# Subscribe to topics
mosquitto_sub -h localhost -t "devices/+/+/telemetry" -v
```

**MQTT Configuration Development**
```conf
# mosquitto/mosquitto.conf
listener 1883
allow_anonymous true

# Authentication (for production)
# password_file /mosquitto/config/password_file
# acl_file /mosquitto/config/acl_file

# Logging
log_type all
log_timestamp true
```

#### InfluxDB Development

**Database Setup**
```bash
# Access InfluxDB CLI
docker-compose exec influxdb influx

# Create organization and bucket
CREATE ORG renewable_energy
CREATE BUCKET iot_data WITH ORG renewable_energy
```

**Data Query Development**
```sql
-- Query photovoltaic data
FROM(bucket: "iot_data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r.device_id == "pv_001")

-- Aggregate data
FROM(bucket: "iot_data")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> aggregateWindow(every: 1h, fn: mean)
```

#### Grafana Development

**Dashboard Development**
```json
{
  "dashboard": {
    "title": "Renewable Energy Overview",
    "panels": [
      {
        "title": "Power Output",
        "type": "timeseries",
        "targets": [
          {
            "query": "FROM(bucket: \"iot_data\") |> range(start: -1h) |> filter(fn: (r) => r._measurement == \"photovoltaic_data\")"
          }
        ]
      }
    ]
  }
}
```

### 4. Testing Procedures

#### Unit Testing
```bash
# Test Node-RED functions
npm test

# Test MQTT communication
./scripts/test-mqtt.sh

# Test data flow
./scripts/test-data-flow.sh
```

#### Integration Testing
```bash
# Test complete data pipeline
./scripts/test-pipeline.sh

# Test service communication
./scripts/test-services.sh
```

#### Load Testing
```bash
# Simulate high device load
./scripts/load-test.sh

# Monitor system performance
docker stats
```

### 5. Debugging Procedures

#### Service Debugging
```bash
# Check service logs
docker-compose logs -f [service-name]

# Access service shell
docker-compose exec [service-name] /bin/bash

# Check service health
docker-compose ps
```

#### Data Flow Debugging
```bash
# Monitor MQTT messages
mosquitto_sub -h localhost -t "#" -v

# Check Node-RED debug output
# Access http://localhost:1880 and check debug panel

# Verify InfluxDB data
docker-compose exec influxdb influx -execute "SHOW MEASUREMENTS"
```

#### Performance Debugging
```bash
# Monitor resource usage
docker stats

# Check network connectivity
docker network ls
docker network inspect plat-edu-bad-data-mvp_default

# Profile Node-RED performance
# Use Node-RED's built-in profiling tools
```

### 6. Deployment Procedures

#### Development Deployment
```bash
# Build and start development environment
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Apply development configurations
./scripts/setup-dev.sh
```

#### Staging Deployment
```bash
# Deploy to staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Run staging tests
./scripts/staging-tests.sh
```

#### Production Deployment
```bash
# Deploy to production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Verify deployment
./scripts/verify-deployment.sh
```

### 7. Backup and Recovery

#### Data Backup
```bash
# Backup InfluxDB data
docker-compose exec influxdb influx backup /backup

# Backup Node-RED flows
docker cp $(docker-compose ps -q node-red):/data/flows.json ./backups/

# Backup Grafana dashboards
curl -X GET http://admin:admin@localhost:3000/api/dashboards > ./backups/dashboards.json
```

#### Data Recovery
```bash
# Restore InfluxDB data
docker-compose exec influxdb influx restore /backup

# Restore Node-RED flows
docker cp ./backups/flows.json $(docker-compose ps -q node-red):/data/

# Restore Grafana dashboards
curl -X POST http://admin:admin@localhost:3000/api/dashboards/db -H "Content-Type: application/json" -d @./backups/dashboards.json
```

### 8. Monitoring and Alerting

#### Health Monitoring
```bash
# Check service health
./scripts/health-check.sh

# Monitor system metrics
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# Check disk usage
docker system df
```

#### Alerting Setup
```bash
# Configure Grafana alerts
# Access http://localhost:3000 and set up alerting rules

# Configure Node-RED alerts
# Add email/SMS notification nodes to flows
```

### 9. Security Procedures

#### Development Security
```bash
# Use development certificates
./scripts/generate-dev-certs.sh

# Set up development authentication
./scripts/setup-dev-auth.sh
```

#### Production Security
```bash
# Generate production certificates
./scripts/generate-prod-certs.sh

# Set up production authentication
./scripts/setup-prod-auth.sh

# Configure firewall rules
./scripts/configure-firewall.sh
```

## Best Practices

### Code Quality
- Use TypeScript for complex Node-RED functions
- Implement comprehensive error handling
- Follow consistent naming conventions
- Add JSDoc comments for complex functions
- Use environment variables for configuration

### Data Management
- Validate all incoming data
- Implement data retention policies
- Use appropriate data types in InfluxDB
- Monitor data quality metrics
- Implement backup and recovery procedures

### Performance
- Use batch processing for high-volume data
- Implement proper indexing in InfluxDB
- Monitor resource usage
- Optimize queries for performance
- Use caching where appropriate

### Security
- Use authentication for all services
- Implement SSL/TLS encryption
- Follow the principle of least privilege
- Regular security updates
- Monitor for security issues

## Troubleshooting

### Common Issues

1. **Service won't start**
   ```bash
   # Check logs
   docker-compose logs [service-name]
   
   # Check port conflicts
   netstat -an | grep :1883
   ```

2. **Data not flowing**
   ```bash
   # Check MQTT connectivity
   mosquitto_pub -h localhost -t "test" -m "test"
   
   # Check Node-RED flows
   # Access http://localhost:1880
   ```

3. **Performance issues**
   ```bash
   # Check resource usage
   docker stats
   
   # Check InfluxDB performance
   docker-compose exec influxdb influx -execute "SHOW STATS"
   ```

### Getting Help

- Check the documentation in `docs/`
- Review service logs
- Check GitHub issues
- Contact the development team 