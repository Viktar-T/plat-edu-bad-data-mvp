# System Architecture

## Overview

The IoT Renewable Energy Monitoring System follows a microservices architecture with a clear data flow pipeline: **MQTT → Node-RED → InfluxDB → Grafana**. This architecture ensures scalability, reliability, and maintainability for real-time energy monitoring.

## Data Flow Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   MQTT Broker   │───▶│   Node-RED      │───▶│   InfluxDB      │
│                 │    │   (Mosquitto)   │    │   (Processing)  │    │   (Database)    │
│ • Photovoltaic  │    │                 │    │                 │    │                 │
│ • Wind Turbine  │    │ • Topic Routing │    │ • Data Validation│    │ • Time-series   │
│ • Biogas Plant  │    │ • Authentication│    │ • Transformation│    │ • Measurements  │
│ • Heat Boiler   │    │ • QoS Management│    │ • Aggregation   │    │ • Retention     │
│ • Energy Storage│    │ • Message Retain│    │ • Error Handling│    │ • Queries       │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                                              │
                                                                              ▼
                                                                   ┌─────────────────┐
                                                                   │   Grafana       │
                                                                   │ (Visualization) │
                                                                   │                 │
                                                                   │ • Dashboards    │
                                                                   │ • Alerts        │
                                                                   │ • Analytics     │
                                                                   │ • Reports       │
                                                                   └─────────────────┘
```

## Component Details

### 1. IoT Devices (Data Sources)

#### Device Types
- **Photovoltaic Panels**: Solar irradiance, temperature, voltage, current, power output
- **Wind Turbines**: Wind speed, direction, rotor speed, power output, temperature
- **Biogas Plants**: Gas flow rate, methane concentration, temperature, pressure
- **Heat Boilers**: Temperature, pressure, fuel consumption, efficiency
- **Energy Storage**: State of charge, voltage, current, temperature, cycle count

#### Data Format
```json
{
  "device_id": "pv_001",
  "device_type": "photovoltaic",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "irradiance": 850.5,
    "temperature": 45.2,
    "voltage": 48.3,
    "current": 12.1,
    "power_output": 584.43
  },
  "status": "operational",
  "location": "site_a"
}
```

### 2. MQTT Broker (Mosquitto)

#### Configuration
- **Port**: 1883 (standard), 8883 (SSL)
- **Authentication**: Username/password or certificate-based
- **QoS**: Level 1 for reliable delivery
- **Retained Messages**: For device status

#### Topic Structure
```
devices/{device_type}/{device_id}/{data_type}
devices/{device_type}/{device_id}/status
devices/{device_type}/{device_id}/config
```

#### Example Topics
- `devices/photovoltaic/pv_001/telemetry`
- `devices/wind_turbine/wt_001/status`
- `devices/energy_storage/es_001/state`

### 3. Node-RED (Data Processing)

#### Flow Structure
```
MQTT Input → Validation → Transformation → InfluxDB Output
     ↓           ↓              ↓              ↓
  Topic      Schema        Calculations    Batch Write
  Filter     Check         Aggregation     Error Handle
```

#### Key Functions
- **Data Validation**: JSON schema validation, range checks
- **Data Transformation**: Unit conversions, calculations
- **Error Handling**: Invalid data rejection, retry logic
- **Aggregation**: Time-based data summarization
- **Alerting**: Threshold monitoring and notifications

#### TypeScript Function Example
```typescript
interface DeviceData {
  device_id: string;
  device_type: string;
  timestamp: string;
  data: Record<string, number>;
  status: string;
  location: string;
}

function validateAndTransform(msg: any): DeviceData | null {
  try {
    const data = msg.payload as DeviceData;
    
    // Validation
    if (!data.device_id || !data.timestamp) {
      throw new Error('Missing required fields');
    }
    
    // Transformation
    const transformed = {
      ...data,
      timestamp: new Date(data.timestamp).toISOString(),
      data: Object.fromEntries(
        Object.entries(data.data).map(([key, value]) => [
          key, 
          typeof value === 'number' ? Number(value.toFixed(2)) : value
        ])
      )
    };
    
    return transformed;
  } catch (error) {
    node.error(`Validation error: ${error.message}`);
    return null;
  }
}
```

### 4. InfluxDB (Time-Series Database)

#### Database Structure
- **Organization**: `renewable_energy`
- **Bucket**: `iot_data`
- **Retention Policy**: 30 days (configurable)

#### Measurement Schema
```sql
-- Photovoltaic Data
measurement: photovoltaic_data
tags: device_id, location, status
fields: irradiance, temperature, voltage, current, power_output

-- Wind Turbine Data
measurement: wind_turbine_data
tags: device_id, location, status
fields: wind_speed, wind_direction, rotor_speed, power_output, temperature

-- Energy Storage Data
measurement: energy_storage_data
tags: device_id, location, status
fields: state_of_charge, voltage, current, temperature, cycle_count
```

#### Query Optimization
- **Indexing**: Device ID and timestamp
- **Partitioning**: By device type and time
- **Compression**: Automatic data compression
- **Downsampling**: Aggregated views for long-term analysis

### 5. Grafana (Visualization)

#### Dashboard Structure
- **Overview Dashboard**: System-wide metrics
- **Device-Specific Dashboards**: Individual device monitoring
- **Analytics Dashboard**: Performance analysis
- **Alerting Dashboard**: System alerts and notifications

#### Key Visualizations
- **Time Series**: Real-time data plots
- **Gauges**: Current status indicators
- **Heatmaps**: Performance patterns
- **Tables**: Detailed data views
- **Stat Panels**: Key metrics summary

## Security Architecture

### Authentication & Authorization
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Devices   │───▶│   MQTT      │───▶│   Services  │
│ (Certificates)│  │ (Username/  │    │ (JWT Tokens)│
│             │    │  Password)  │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Data Encryption
- **Transport**: TLS/SSL for all communications
- **Storage**: Encrypted volumes for sensitive data
- **Backup**: Encrypted backup storage

## Performance Considerations

### Scalability
- **Horizontal Scaling**: Multiple Node-RED instances
- **Load Balancing**: MQTT broker clustering
- **Database Sharding**: InfluxDB cluster for high volume
- **Caching**: Redis for frequently accessed data

### Monitoring
- **Health Checks**: Docker health checks for all services
- **Metrics**: Prometheus integration for system metrics
- **Logging**: Centralized logging with ELK stack
- **Alerting**: Proactive monitoring and notifications

## Deployment Architecture

### Docker Compose Services
```yaml
services:
  mosquitto:
    image: eclipse-mosquitto:latest
    ports: ["1883:1883", "9001:9001"]
    
  node-red:
    image: nodered/node-red:latest
    ports: ["1880:1880"]
    
  influxdb:
    image: influxdb:2.7
    ports: ["8086:8086"]
    
  grafana:
    image: grafana/grafana:latest
    ports: ["3000:3000"]
```

### Environment Configuration
- **Development**: Local Docker Compose
- **Staging**: Docker Swarm with limited resources
- **Production**: Kubernetes with auto-scaling

## Data Retention Strategy

### Time-Based Retention
- **Raw Data**: 7 days (high resolution)
- **Aggregated Data**: 30 days (hourly averages)
- **Historical Data**: 1 year (daily averages)
- **Archive**: Long-term storage for compliance

### Backup Strategy
- **Real-time**: Continuous backup to secondary storage
- **Daily**: Full system backup
- **Weekly**: Disaster recovery testing
- **Monthly**: Long-term archive

## Integration Points

### External Systems
- **SCADA Systems**: OPC UA integration
- **Weather APIs**: External weather data
- **Energy Markets**: Price and demand data
- **Maintenance Systems**: Work order integration

### APIs
- **REST API**: For external integrations
- **GraphQL**: For flexible data queries
- **WebSocket**: For real-time updates
- **MQTT**: For device communication

## Future Enhancements

### Planned Features
- **Machine Learning**: Predictive maintenance
- **Edge Computing**: Local data processing
- **Blockchain**: Energy trading integration
- **5G Integration**: Low-latency communication
- **AI Analytics**: Advanced pattern recognition

### Technology Evolution
- **Quantum Computing**: Complex optimization problems
- **Digital Twins**: Virtual device representations
- **Federated Learning**: Distributed AI training
- **Edge AI**: On-device intelligence 