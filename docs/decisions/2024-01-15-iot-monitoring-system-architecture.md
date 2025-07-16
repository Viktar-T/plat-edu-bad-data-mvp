# 2024-01-15 - IoT Renewable Energy Monitoring System Architecture

## Status
**Accepted**

## Context
Need to create a complete IoT renewable energy monitoring system with specific requirements for:
- Real-time monitoring of multiple renewable energy device types
- Containerized deployment with Docker
- TypeScript support for data processing
- Comprehensive error handling
- Production-ready architecture

## Decision
Adopted a microservices architecture with the following data flow pipeline:
**MQTT → Node-RED → InfluxDB → Grafana**

### Technology Stack
- **MQTT Broker**: Eclipse Mosquitto 2.0.18
- **Data Processing**: Node-RED 3.1 with TypeScript support
- **Database**: InfluxDB 2.7 (time-series optimized)
- **Visualization**: Grafana 10.2.0
- **Containerization**: Docker & Docker Compose
- **Language**: TypeScript/JavaScript for Node-RED flows

### Architecture Pattern
- **Microservices**: Each component runs as a separate container
- **Data Pipeline**: Unidirectional flow from devices to visualization
- **Container Orchestration**: Docker Compose for local development
- **Health Monitoring**: Built-in health checks for all services
- **Environment Configuration**: Comprehensive .env template

## Consequences

### Positive
- **Scalability**: Each service can be scaled independently
- **Maintainability**: Clear separation of concerns and modular structure
- **Reliability**: Health checks and restart policies ensure service availability
- **Flexibility**: Easy to add new device types or modify individual components
- **Development Experience**: TypeScript support improves code quality
- **Production Ready**: Comprehensive error handling and monitoring
- **Documentation**: Complete documentation for team collaboration

### Negative
- **Complexity**: More moving parts compared to monolithic architecture
- **Resource Usage**: Multiple containers consume more resources
- **Network Overhead**: Inter-service communication adds latency
- **Deployment Complexity**: Need to manage multiple service dependencies
- **Learning Curve**: Team needs to understand multiple technologies

## Alternatives Considered

### Monolithic Application
- **Why Rejected**: Would be difficult to scale individual components and maintain
- **Impact**: Would limit flexibility and make deployment more complex

### Serverless Architecture
- **Why Rejected**: Not suitable for real-time IoT data processing requirements
- **Impact**: Would introduce cold start latency and complexity

### Direct Database Writes
- **Why Rejected**: Would bypass data validation and processing capabilities
- **Impact**: Would reduce data quality and processing flexibility

### Message Queues (RabbitMQ, Kafka)
- **Why Rejected**: MQTT is more suitable for IoT device communication
- **Impact**: MQTT provides better IoT-specific features and lighter weight

### Other Databases (PostgreSQL, MongoDB)
- **Why Rejected**: InfluxDB is specifically optimized for time-series data
- **Impact**: Would result in poorer performance for IoT time-series data

## Implementation Notes

### Project Structure
```
plat-edu-bad-data-mvp/
├── docker-compose.yml              # Main service orchestration
├── env.example                     # Environment configuration template
├── README.md                       # Project documentation
├── .cursorrules                    # Development guidelines
├── docs/                           # Documentation
├── docker-compose/                 # Docker configurations
├── node-red/                       # Data processing flows
├── mosquitto/                      # MQTT broker configuration
├── influxdb/                       # Database configuration
├── grafana/                        # Visualization configuration
└── scripts/                        # Utility scripts
```

### Key Configuration Files
- `docker-compose.yml`: Service definitions with health checks
- `mosquitto/config/mosquitto.conf`: MQTT broker configuration
- `node-red/settings.js`: Node-RED with TypeScript support
- `node-red/package.json`: Comprehensive dependencies
- `scripts/start.sh`: Automated startup and health checks
- `scripts/simulate-devices.sh`: Realistic device simulation

### Device Support
- **Photovoltaic Panels**: Irradiance, temperature, voltage, current, power output
- **Wind Turbines**: Wind speed, direction, rotor speed, power output
- **Biogas Plants**: Gas flow rate, methane concentration, temperature, pressure
- **Heat Boilers**: Temperature, pressure, fuel consumption, efficiency
- **Energy Storage**: State of charge, voltage, current, temperature, cycle count

### Security Considerations
- MQTT authentication ready (username/password)
- SSL/TLS configuration templates
- Environment-based secrets management
- Access control lists for MQTT topics
- Secure container configurations

### Performance Optimizations
- InfluxDB query optimization
- Batch processing capabilities
- Connection pooling
- Resource monitoring
- Health check intervals

## Related Documents
- `docs/architecture.md` - Detailed system architecture
- `docs/development-workflow.md` - Development procedures
- `docs/design/project-structure/design.md` - Design specifications
- `docs/design/project-structure/tasks.md` - Implementation tasks
- `docs/design/project-structure/history.md` - Development history 