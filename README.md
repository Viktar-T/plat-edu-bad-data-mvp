# IoT Renewable Energy Monitoring System

A comprehensive IoT-based real-time monitoring system for renewable energy sources including photovoltaic panels, wind turbines, biogas plants, heat boilers, and energy storage systems. The system uses Node-RED, MQTT, InfluxDB, and Grafana with Docker containerization.

## 🏗️ Architecture

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

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Git
- mosquitto-clients (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd plat-edu-bad-data-mvp
   ```

2. **Set up MQTT broker with authentication**
   ```bash
   # Run the setup script (Linux/macOS)
   ./scripts/setup-mqtt.sh
   
   # Or manually copy environment template
   cp env.example .env
   # Edit .env with your credentials
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Verify services are running**
   ```bash
   docker-compose ps
   ```

5. **Test MQTT connectivity**
   ```bash
   ./scripts/mqtt-test.sh
   ```

## 📁 Project Structure

```
plat-edu-bad-data-mvp/
├── docker-compose.yml          # Docker services configuration
├── env.example                 # Environment variables template
├── README.md                   # This file
├── docs/                       # Documentation
│   ├── architecture.md         # System architecture
│   ├── mqtt-configuration.md   # MQTT broker configuration guide
│   └── decisions/              # Architecture decisions
├── mosquitto/                  # MQTT broker configuration
│   └── config/
│       ├── mosquitto.conf      # Main broker configuration
│       ├── passwd              # Password file (generated)
│       └── acl                 # Access control list
├── node-red/                   # Node-RED configuration
├── influxdb/                   # InfluxDB configuration
├── grafana/                    # Grafana configuration
└── scripts/                    # Utility scripts
    ├── setup-mqtt.sh          # MQTT setup script
    ├── mqtt-test.sh           # MQTT connectivity testing
    └── simulate-devices.sh    # Device simulation
```

## 🔐 MQTT Configuration

### Topic Structure

The system uses a hierarchical topic structure for scalable messaging:

```
devices/{device_type}/{device_id}/{data_type}
```

**Topic Categories:**
- **Device Data**: `devices/{device_type}/{device_id}/data` - Telemetry data
- **Device Status**: `devices/{device_type}/{device_id}/status` - Operational status
- **Device Commands**: `devices/{device_type}/{device_id}/commands` - Control commands
- **System Health**: `system/health/{service_name}` - Service health monitoring
- **System Alerts**: `system/alerts/{severity}` - System alerts and notifications

**Supported Device Types:**
- `photovoltaic` - Solar panel systems
- `wind_turbine` - Wind power generators
- `biogas_plant` - Biogas production facilities
- `heat_boiler` - Thermal energy systems
- `energy_storage` - Battery storage systems

### Security Features

- ✅ **Authentication**: Username/password authentication for all devices and services
- ✅ **Access Control**: Topic-based permissions with ACL
- ✅ **No Anonymous Access**: Anonymous connections disabled
- ✅ **Persistence**: Message storage and recovery
- ✅ **Logging**: Comprehensive logging for monitoring and debugging
- ✅ **WebSocket Support**: Web application connectivity on port 9001

### Example Topics

```
devices/photovoltaic/pv_001/data
devices/wind_turbine/wt_001/status
devices/energy_storage/es_001/commands
system/health/mosquitto
system/alerts/critical
```

## 🧪 Testing

### MQTT Connectivity Testing

The `scripts/mqtt-test.sh` script provides comprehensive testing:

```bash
# Basic connectivity test
./scripts/mqtt-test.sh

# Test with custom credentials
./scripts/mqtt-test.sh -u admin -P mypassword

# Test specific device
./scripts/mqtt-test.sh --pv-user pv_001 --pv-password device_password_123
```

### Manual Testing

```bash
# Test basic connectivity
mosquitto_pub -h localhost -p 1883 -u admin -P password -t test/topic -m "Hello World"

# Test device data publishing
mosquitto_pub -h localhost -p 1883 -u pv_001 -P password \
  -t devices/photovoltaic/pv_001/data \
  -m '{"device_id":"pv_001","data":{"power":500}}'

# Test device command subscription
mosquitto_sub -h localhost -p 1883 -u pv_001 -P password \
  -t devices/photovoltaic/pv_001/commands
```

## 🔧 Configuration

### Environment Variables

Copy `env.example` to `.env` and configure:

```bash
# MQTT Configuration
MQTT_PORT=1883
MQTT_WS_PORT=9001
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=your_secure_password

# Performance Tuning
MOSQUITTO_MAX_CONNECTIONS=1000
MOSQUITTO_MAX_QUEUED_MESSAGES=100
MOSQUITTO_AUTOSAVE_INTERVAL=1800

# Logging
MOSQUITTO_LOG_LEVEL=information
```

### Service Ports

- **MQTT Broker**: 1883 (MQTT), 9001 (WebSocket)
- **Node-RED**: 1880 (Web UI)
- **InfluxDB**: 8086 (HTTP API)
- **Grafana**: 3000 (Web UI)

## 📊 Data Flow

1. **IoT Devices** publish telemetry data to MQTT topics
2. **MQTT Broker** routes messages based on topic structure
3. **Node-RED** subscribes to device topics, validates and transforms data
4. **InfluxDB** stores time-series data with proper retention policies
5. **Grafana** visualizes data through dashboards and alerts

### Example Data Format

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

## 🛡️ Security

### Authentication

- Each device has unique credentials
- Service accounts for Node-RED, Grafana, and monitoring
- Admin account for system management
- Regular password rotation recommended

### Access Control

- Device-specific topic permissions
- Service accounts with appropriate read/write access
- Wildcard permissions for scalable device management
- Principle of least privilege enforced

### Network Security

- Firewall rules for MQTT ports
- SSL/TLS encryption for production (configured but disabled by default)
- Network segmentation for IoT devices
- VPN access for remote management

## 📈 Monitoring

### Health Checks

All services include Docker health checks:

```bash
# Check service health
docker-compose ps

# View service logs
docker-compose logs mosquitto
docker-compose logs node-red
docker-compose logs influxdb
docker-compose logs grafana
```

### Metrics

- Connection count and message throughput
- Authentication failures and access violations
- System resource usage
- Data processing performance

## 🔄 Development

### Adding New Devices

1. **Generate device credentials**:
   ```bash
   mosquitto_passwd -b mosquitto/config/passwd new_device_id new_password
   ```

2. **Add ACL permissions**:
   ```bash
   # Add to mosquitto/config/acl
   topic write devices/device_type/new_device_id/data
   topic write devices/device_type/new_device_id/status
   topic read devices/device_type/new_device_id/commands
   ```

3. **Update environment variables**:
   ```bash
   # Add to .env
   NEW_DEVICE_ID_PASSWORD=new_password
   ```

### Simulating Devices

Use the device simulation script:

```bash
./scripts/simulate-devices.sh
```

## 📚 Documentation

- [System Architecture](docs/architecture.md) - Detailed system design
- [MQTT Configuration](docs/mqtt-configuration.md) - Complete MQTT setup guide
- [Development Workflow](docs/development-workflow.md) - Development guidelines
- [Architecture Decisions](docs/decisions/) - Design decision records

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:

1. Check the [documentation](docs/)
2. Review [troubleshooting guide](docs/mqtt-configuration.md#troubleshooting)
3. Open an issue on GitHub
4. Contact the development team

## 🔄 Updates

### Recent Changes

- ✅ Complete MQTT broker configuration with authentication
- ✅ Topic-based access control implementation
- ✅ Comprehensive testing scripts
- ✅ Security best practices documentation
- ✅ Environment variable configuration
- ✅ Docker service integration

### Roadmap

- [ ] SSL/TLS certificate management
- [ ] Advanced monitoring and alerting
- [ ] Multi-site deployment support
- [ ] API gateway integration
- [ ] Mobile application support 