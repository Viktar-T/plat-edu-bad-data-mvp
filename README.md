# IoT Renewable Energy Monitoring System

A comprehensive IoT-based real-time monitoring system for renewable energy sources including photovoltaic panels, wind turbines, biogas plants, heat boilers, and energy storage systems. The system uses Node-RED, MQTT, InfluxDB 2.x, and Grafana with Docker containerization.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   MQTT Broker   │───▶│   Node-RED      │───▶│   InfluxDB 2.x  │
│   (Simulated)   │    │   (Mosquitto)   │    │   (Processing)  │    │   (Database)    │
│                 │    │                 │    │                 │    │                 │
│ • Photovoltaic  │    │ • Topic Routing │    │ • Data Validation│    │ • Time-series   │
│ • Wind Turbine  │    │ • Authentication│    │ • Transformation│    │ • Measurements  │
│ • Biogas Plant  │    │ • QoS Management│    │ • Aggregation   │    │ • Retention     │
│ • Heat Boiler   │    │ • Message Retain│    │ • Error Handling│    │ • Flux Queries  │
│ • Energy Storage│    │                 │    │ • Device Sim.   │    │                 │
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

**Note**: IoT devices are currently **simulated within Node-RED** using realistic mathematical models and data generation algorithms. The system is designed to easily integrate with real IoT devices by replacing the simulation nodes with actual device connections.

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Git
- PowerShell (for Windows testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd plat-edu-bad-data-mvp
   ```

2. **Configure environment variables**
   ```bash
   cp env.example .env
   # Edit .env file with your preferred settings
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Verify services are running**
   ```bash
   docker-compose ps
   ```

5. **Direct Browser Access Tests**
   - Node-RED: http://localhost:1880 ✅ (Login: admin / adminpassword)
   - Grafana: http://localhost:3000 ✅ (Login: admin / admin)
   - InfluxDB: http://localhost:8086/ ✅ (Web interface + API endpoint); 
     - (admin / admin_password_123 (API token: renewable_energy_admin_token_123))
   - MQTT: localhost:1883 -- Not browsable (MQTT protocol only)

   **Default Credentials** (from env.example):
   - **Node-RED**: admin / adminpassword
   - **Grafana**: admin / admin
   - **InfluxDB**: admin / admin_password_123 (API token: renewable_energy_admin_token_123)
   - **MQTT**: admin / admin_password_456

6. **Run comprehensive tests**
   ```powershell
   # For Windows PowerShell
   cd tests
   .\run-all-tests.ps1
   
   # Individual test scripts
   .\scripts\test-mqtt.ps1 -PublishTest -Topic "test/hello" -Message "Hello World!"
   .\scripts\test-data-flow.ps1
   .\scripts\test-flux-queries.ps1
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
│   ├── flows/                  # Node-RED flow files
│   │   ├── v2.0-pv-mqtt-loop-simulation.json
│   │   ├── v2.1-pv-mqtt-loop-simulation.json
│   │   └── FLUX_MIGRATION_SUMMARY.md
│   └── data/                   # Node-RED data directory
├── influxdb/                   # InfluxDB 2.x configuration
│   ├── config/                 # InfluxDB configuration files
│   ├── data/                   # Time-series data storage
│   └── backups/                # Database backups
├── grafana/                    # Grafana configuration
│   ├── dashboards/             # Pre-configured dashboards
│   │   ├── renewable-energy-overview.json
│   │   ├── photovoltaic-monitoring.json
│   │   ├── wind-turbine-analytics.json
│   │   ├── biogas-plant-metrics.json
│   │   ├── heat-boiler-monitoring.json
│   │   └── energy-storage-monitoring.json
│   └── provisioning/           # Auto-provisioning configuration
├── scripts/                    # Utility scripts
│   ├── deploy-mqtt-loop.ps1   # MQTT loop deployment
│   ├── convert-all-flows.ps1  # Flow conversion utilities
│   └── influx3-setup.ps1      # InfluxDB setup utilities
└── tests/                     # Comprehensive testing framework
    ├── run-all-tests.ps1      # Main test runner
    ├── scripts/               # Individual test scripts
    │   ├── test-mqtt.ps1      # MQTT connectivity testing
    │   ├── test-data-flow.ps1 # End-to-end data flow testing
    │   ├── test-flux-queries.ps1 # Flux query testing
    │   ├── test-integration.ps1 # Component integration testing
    │   └── test-performance.ps1 # Performance testing
    ├── javascript/            # JavaScript API testing
    │   ├── test-influxdb-api.js
    │   ├── test-config.json
    │   └── package.json
    └── data/                  # Test data files
        └── test-messages/     # Sample device messages
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

## 🧪 Testing Framework

### Comprehensive Testing Suite

The project includes a complete testing framework with PowerShell scripts and JavaScript API tests:

#### PowerShell Testing Scripts
- **`test-mqtt.ps1`** - MQTT connectivity and message testing
- **`test-data-flow.ps1`** - End-to-end data flow validation
- **`test-flux-queries.ps1`** - InfluxDB Flux query testing
- **`test-integration.ps1`** - Component integration testing
- **`test-performance.ps1`** - Performance and load testing

#### JavaScript API Testing
- **`test-influxdb-api.js`** - InfluxDB API testing with Node.js
- **`test-config.json`** - Centralized test configuration
- **`package.json`** - Node.js dependencies for testing

#### Test Runner
- **`run-all-tests.ps1`** - Comprehensive test execution with detailed reporting

### Running Tests

```powershell
# Run all tests
cd tests
.\run-all-tests.ps1

# Run individual tests
.\scripts\test-mqtt.ps1 -PublishTest -Topic "test/hello" -Message "Hello World!"
.\scripts\test-data-flow.ps1
.\scripts\test-flux-queries.ps1
.\scripts\test-integration.ps1
.\scripts\test-performance.ps1

# JavaScript API tests
cd javascript
npm install
node test-influxdb-api.js
```

## 🔧 Configuration

### Environment Variables

Copy `env.example` to `.env` and configure:

```bash
# MQTT Configuration
MQTT_PORT=1883
MQTT_WS_PORT=9001
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=admin_password_456

# InfluxDB 2.x Configuration
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=admin_password_123
INFLUXDB_ADMIN_TOKEN=renewable_energy_admin_token_123
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=30d

# Node-RED Configuration
NODE_RED_USERNAME=admin
NODE_RED_PASSWORD=adminpassword

# Grafana Configuration
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
```

### Service Ports

- **MQTT Broker**: 1883 (MQTT), 9001 (WebSocket)
- **Node-RED**: 1880 (Web UI)
- **InfluxDB**: 8086 (HTTP API)
- **Grafana**: 3000 (Web UI)

## 📊 Data Flow

1. **Node-RED Device Simulation** generates realistic IoT device data using mathematical models
2. **MQTT Broker** routes messages based on topic structure
3. **Node-RED Processing** validates and transforms data using Flux format
4. **InfluxDB 2.x** stores time-series data with proper retention policies
5. **Grafana** visualizes data through pre-configured dashboards and alerts

**Simulation Details**: The system currently uses Node-RED flows (`v2.0-pv-mqtt-loop-simulation.json` and `v2.1-pv-mqtt-loop-simulation.json`) to simulate photovoltaic panels with realistic solar irradiance, temperature, voltage, current, and power output models. The simulation includes fault scenarios and daily/seasonal variations.

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

### Flux Query Examples

```flux
// Data writing with Flux format
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r.device_type == "photovoltaic")

// Data reading with aggregation
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "efficiency")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```

## 📈 Grafana Dashboards

### Pre-Configured Dashboards

The system includes comprehensive dashboards for all device types:

- **Renewable Energy Overview** - System-wide monitoring
- **Photovoltaic Monitoring** - Solar panel performance metrics
- **Wind Turbine Analytics** - Wind power generation analysis
- **Biogas Plant Metrics** - Biogas production monitoring
- **Heat Boiler Monitoring** - Thermal energy system tracking
- **Energy Storage Monitoring** - Battery storage analytics

### Dashboard Features

- Real-time data visualization
- Historical trend analysis
- Performance metrics and KPIs
- Alert configuration
- Responsive design for multiple screen sizes

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

### Node-RED Flow Development

The system includes two main flow versions for **device simulation**:
- **v2.0-pv-mqtt-loop-simulation.json** - Basic photovoltaic simulation with realistic solar models
- **v2.1-pv-mqtt-loop-simulation.json** - Enhanced photovoltaic simulation with Flux integration

**Simulation Features**:
- **Realistic Solar Models**: Irradiance based on time of day and season
- **Temperature Effects**: Panel temperature modeling with efficiency calculations
- **Fault Scenarios**: Random fault injection (shading, temperature, connection issues)
- **Data Validation**: Comprehensive data range and consistency checks
- **Flux Integration**: Proper data conversion for InfluxDB 2.x storage

### Flux Migration

The system has been migrated to use InfluxDB 2.x with Flux query language:
- ✅ Token-based authentication
- ✅ Flux-compatible data structure
- ✅ Proper organization and bucket configuration
- ✅ Advanced query capabilities

## 📚 Documentation

- [System Architecture](docs/architecture.md) - Detailed system design
- [MQTT Configuration](docs/mqtt-configuration.md) - Complete MQTT setup guide
- [Development Workflow](docs/development-workflow.md) - Development guidelines
- [Architecture Decisions](docs/decisions/) - Design decision records
- [Testing Implementation](tests/TESTING_IMPLEMENTATION_SUMMARY.md) - Testing framework details
- [Flux Migration](node-red/flows/FLUX_MIGRATION_SUMMARY.md) - InfluxDB 2.x migration details

### InfluxDB 2.x Documentation

- [InfluxDB 2.x Overview](docs/influxdb2/README.md) - Complete InfluxDB 2.x system overview and quick start
- [InfluxDB 2.x Architecture](docs/influxdb2/architecture.md) - Detailed InfluxDB 2.x architecture and data flow
- [InfluxDB 2.x Configuration](docs/influxdb2/configuration.md) - Comprehensive configuration reference
- [InfluxDB 2.x Implementation Summary](docs/influxdb2/IMPLEMENTATION_SUMMARY.md) - Complete implementation details and verification

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
3. Run the [testing framework](tests/) to diagnose issues
4. Open an issue on GitHub
5. Contact the development team

## 🔄 Updates

### Recent Changes

- ✅ Complete MQTT broker configuration with authentication
- ✅ Topic-based access control implementation
- ✅ Comprehensive testing framework with PowerShell and JavaScript
- ✅ InfluxDB 2.x migration with Flux query language
- ✅ Pre-configured Grafana dashboards for all device types
- ✅ Node-RED flows with Flux data conversion
- ✅ Security best practices documentation
- ✅ Environment variable configuration
- ✅ Docker service integration with health checks
- ✅ **NEW**: Complete InfluxDB 2.x documentation suite (README, Architecture, Configuration)
- ✅ **NEW**: InfluxDB 2.x initialization and user setup scripts
- ✅ **NEW**: Node-RED flow consistency fixes for InfluxDB 2.x integration
- ✅ **NEW**: Comprehensive implementation summary and verification checklist

### Current Implementation Status

- ✅ **MQTT Broker**: Fully configured with authentication and ACL
- ✅ **InfluxDB 2.x**: Migrated from 1.x with Flux queries
- ✅ **Node-RED**: Flows with Flux data conversion
- ✅ **Grafana**: Complete dashboard suite
- ✅ **Testing**: Comprehensive PowerShell and JavaScript testing framework
- ✅ **Documentation**: Complete system documentation
- ✅ **Docker**: Production-ready containerization

### Roadmap

- [ ] SSL/TLS certificate management
- [ ] Advanced monitoring and alerting
- [ ] Multi-site deployment support
- [ ] API gateway integration
- [ ] Mobile application support
- [ ] Machine learning integration for predictive maintenance 