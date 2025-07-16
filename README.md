# IoT Renewable Energy Monitoring System

A comprehensive IoT-based real-time monitoring system for renewable energy sources including photovoltaic panels, wind turbines, biogas plants, heat boilers, and energy storage systems.

## 🚀 Project Overview

This system provides real-time monitoring, data collection, and visualization for renewable energy infrastructure using modern IoT technologies and containerized microservices architecture.

### Key Features

- **Real-time Data Collection**: MQTT-based sensor data ingestion
- **Data Processing**: Node-RED flows for data transformation and validation
- **Time-Series Database**: InfluxDB for efficient storage of sensor data
- **Visualization**: Grafana dashboards for real-time and historical data
- **Containerized**: Docker-based deployment for easy scaling and management
- **Multi-Device Support**: Photovoltaic, Wind Turbine, Biogas, Heat Boiler, Energy Storage

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Devices   │───▶│    MQTT     │───▶│  Node-RED   │───▶│  InfluxDB   │
│ (Sensors)   │    │  (Mosquitto)│    │ (Processing)│    │ (Database)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                              │
                                                              ▼
                                                   ┌─────────────┐
                                                   │   Grafana   │
                                                   │(Visualization)│
                                                   └─────────────┘
```

## 🛠️ Tech Stack

- **MQTT Broker**: Eclipse Mosquitto
- **Data Processing**: Node-RED with TypeScript
- **Database**: InfluxDB 2.x (Time-series)
- **Visualization**: Grafana
- **Containerization**: Docker & Docker Compose
- **Language**: TypeScript/JavaScript

## 📁 Project Structure

```
├── docker-compose/          # Docker Compose configurations
├── node-red/               # Node-RED flows and configurations
├── mosquitto/              # MQTT broker configurations
├── influxdb/               # InfluxDB configurations and scripts
├── grafana/                # Grafana dashboards and configurations
├── docs/                   # Documentation
│   ├── architecture.md     # System architecture documentation
│   └── development-workflow.md # Development and deployment guide
├── scripts/                # Utility scripts
├── .env.example           # Environment variables template
├── docker-compose.yml     # Main Docker Compose file
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop (v20.10+)
- Docker Compose (v2.0+)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd plat-edu-bad-data-mvp
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your specific configurations
   ```

3. **Start the services**
   ```bash
   docker-compose up -d
   ```

4. **Access the services**
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Node-RED**: http://localhost:1880
   - **InfluxDB**: http://localhost:8086
   - **MQTT Broker**: localhost:1883

## 📊 Monitoring Dashboard

The system provides comprehensive dashboards for:

- **Real-time Energy Production**: Live monitoring of all energy sources
- **Historical Analysis**: Long-term trends and performance metrics
- **Device Status**: Health monitoring and alerting
- **Efficiency Metrics**: Performance optimization insights
- **Predictive Analytics**: Energy production forecasting

## 🔧 Development

### Adding New Devices

1. Create device simulation in `scripts/`
2. Add MQTT topic structure in `mosquitto/`
3. Create Node-RED flow in `node-red/`
4. Add InfluxDB measurement in `influxdb/`
5. Create Grafana dashboard in `grafana/`

### Code Standards

- Use TypeScript for Node-RED function nodes
- Follow JSON schema validation for MQTT payloads
- Implement comprehensive error handling
- Use descriptive variable names (camelCase)
- Include JSDoc comments for complex functions

## 🔒 Security

- MQTT authentication and authorization
- SSL/TLS encryption for data transmission
- Environment variables for sensitive configuration
- Proper access controls and user management
- Regular security updates

## 📈 Performance

- Optimized InfluxDB queries
- Connection pooling
- Batch processing for high-volume data
- Proper caching strategies
- Resource monitoring and limits

## 🧪 Testing

- End-to-end data flow testing
- Unit tests for Node-RED function nodes
- Docker health checks for service validation
- Performance benchmarking
- Load testing for high-volume scenarios

## 📚 Documentation

- [Architecture Documentation](docs/architecture.md)
- [Development Workflow](docs/development-workflow.md)
- [API Documentation](docs/api.md)
- [Deployment Guide](docs/deployment.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation in the `docs/` folder
- Review the troubleshooting guide

## 🔄 Version History

- **v1.0.0**: Initial release with basic monitoring capabilities
- **v1.1.0**: Added energy storage monitoring
- **v1.2.0**: Enhanced security and performance optimizations

---

**Built with ❤️ for sustainable energy monitoring** 