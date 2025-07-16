# 2024-01-15 - MQTT Broker Configuration Architecture

## Status
**Accepted**

## Context

The IoT Renewable Energy Monitoring System requires a secure, scalable MQTT broker to handle communication between IoT devices (photovoltaic panels, wind turbines, biogas plants, heat boilers, energy storage systems) and backend services (Node-RED, InfluxDB, Grafana). The system needs to support authentication, topic-based access control, persistence, and WebSocket connectivity while maintaining high performance and reliability.

## Decision

Implement a comprehensive Mosquitto MQTT broker configuration with the following architecture:

### Core Components
1. **Eclipse Mosquitto 2.0.18** as the MQTT broker
2. **Hierarchical topic structure**: `devices/{device_type}/{device_id}/{data_type}`
3. **Username/password authentication** with device-specific credentials
4. **Access Control List (ACL)** for topic-based permissions
5. **Message persistence** with configurable autosave intervals
6. **WebSocket support** for web application connectivity
7. **Comprehensive logging** and health monitoring

### Security Architecture
- **No anonymous access** - all connections require authentication
- **Device isolation** - each device can only access its own topics
- **Service account separation** - dedicated credentials for Node-RED, Grafana, and monitoring
- **Principle of least privilege** - minimal required permissions for each entity
- **Environment variable configuration** for secure credential management

### Topic Structure
```
devices/{device_type}/{device_id}/data      # Telemetry data
devices/{device_type}/{device_id}/status    # Device status
devices/{device_type}/{device_id}/commands  # Control commands
system/health/{service_name}                # System health
system/alerts/{severity}                    # System alerts
```

### Device Types Supported
- `photovoltaic` - Solar panel systems
- `wind_turbine` - Wind power generators
- `biogas_plant` - Biogas production facilities
- `heat_boiler` - Thermal energy systems
- `energy_storage` - Battery storage systems

## Consequences

### Positive
- **Security**: Comprehensive authentication and access control prevents unauthorized access
- **Scalability**: Hierarchical topic structure supports unlimited device types and instances
- **Reliability**: Message persistence ensures data integrity across broker restarts
- **Maintainability**: Clear configuration structure and comprehensive documentation
- **Performance**: Optimized settings for IoT workloads with connection limits and message queues
- **Flexibility**: Environment variable configuration supports multiple deployment scenarios
- **Monitoring**: Built-in health checks and comprehensive logging for operational visibility

### Negative
- **Complexity**: More complex setup compared to basic MQTT broker configuration
- **Management Overhead**: Requires credential management and ACL maintenance
- **Resource Usage**: Persistence and logging consume additional storage and memory
- **Learning Curve**: Team needs to understand ACL syntax and topic structure
- **Certificate Management**: SSL/TLS implementation requires additional certificate management

## Alternatives Considered

### 1. **HiveMQ as MQTT Broker**
- **Pros**: Enterprise features, clustering, advanced monitoring
- **Cons**: Higher resource requirements, licensing costs, overkill for IoT use case
- **Rejection Reason**: Too complex and expensive for the current requirements

### 2. **RabbitMQ with MQTT Plugin**
- **Pros**: Advanced messaging features, clustering, enterprise support
- **Cons**: Higher resource usage, complex configuration, MQTT as secondary feature
- **Rejection Reason**: Over-engineered for simple IoT messaging requirements

### 3. **AWS IoT Core**
- **Pros**: Managed service, built-in security, scalability
- **Cons**: Vendor lock-in, ongoing costs, internet dependency
- **Rejection Reason**: Prefer self-hosted solution for data sovereignty and cost control

### 4. **Flat Topic Structure**
- **Pros**: Simpler implementation, easier to understand
- **Cons**: Poor scalability, difficult permission management, no device isolation
- **Rejection Reason**: Doesn't support the required scalability and security requirements

### 5. **Certificate-Based Authentication**
- **Pros**: Higher security, no password management
- **Cons**: Complex certificate management, higher operational overhead
- **Rejection Reason**: Username/password provides adequate security with simpler management

### 6. **No Persistence Configuration**
- **Pros**: Simpler configuration, lower resource usage
- **Cons**: Data loss on broker restart, poor reliability
- **Rejection Reason**: Reliability is critical for IoT data collection

## Implementation Notes

### Configuration Files
- `mosquitto/config/mosquitto.conf` - Main broker configuration
- `mosquitto/config/passwd` - Password file for authentication
- `mosquitto/config/acl` - Access control list for topic permissions

### Docker Integration
- Environment variables for flexible configuration
- Health checks with authentication
- Proper volume mounts for persistence
- Service dependencies and restart policies

### Testing Strategy
- Comprehensive testing script (`scripts/mqtt-test.sh`)
- Connectivity, authentication, and security validation
- Performance and topic structure testing
- Automated setup script (`scripts/setup-mqtt.sh`)

### Security Considerations
- Regular password rotation (recommended: 90 days)
- Monitor authentication failures
- Review ACL permissions quarterly
- Enable SSL/TLS for production environments
- Implement proper firewall rules

### Performance Tuning
- Maximum 1000 concurrent connections
- Message queue limit of 100 messages
- 30-minute autosave interval
- Configurable log levels for different environments

## Related Documents

- [MQTT Configuration Guide](docs/mqtt-configuration.md)
- [System Architecture](docs/architecture.md)
- [Development Workflow](docs/development-workflow.md)
- [MQTT Broker Configuration Design](docs/design/mqtt-broker-configuration/design.md)
- [MQTT Broker Configuration Tasks](docs/design/mqtt-broker-configuration/tasks.md)
- [MQTT Broker Configuration History](docs/design/mqtt-broker-configuration/history.md)

## Review Schedule

- **Initial Review**: 2024-01-15 (Implementation completion)
- **Security Review**: 2024-02-15 (30 days post-implementation)
- **Performance Review**: 2024-03-15 (60 days post-implementation)
- **Architecture Review**: 2024-04-15 (90 days post-implementation)

## Success Metrics

- **Security**: No unauthorized access attempts successful
- **Performance**: Support 1000+ concurrent connections with <100ms latency
- **Reliability**: 99.9% uptime with no data loss on broker restarts
- **Scalability**: Support 100+ devices across all device types
- **Maintainability**: Setup time <30 minutes for new environments 