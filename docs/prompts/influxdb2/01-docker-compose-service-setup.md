# InfluxDB 2.x Docker Compose Service Setup

## Prompt for Cursor IDE

I need to add InfluxDB 2.x to my Docker Compose file for an IoT renewable energy monitoring system. The system includes MQTT (Mosquitto), Node-RED, and Grafana.

## Requirements

1. **Use InfluxDB 2.x** with GUI access
2. **No authentication for development** (admin/admin)
3. **Create database 'renewable_energy'**
4. **Expose port 8086**
5. **Use named volumes for data persistence**
6. **Include health checks**
7. **Connect to existing 'iot-network'**
8. **Add proper restart policy**

## Service Configuration Details

- **Service name**: `influxdb`
- **Container name**: `iot-influxdb2`
- **Image**: Latest stable InfluxDB 2.x
- **Network**: Connect to existing `iot-network`
- **Volumes**: Persistent data storage
- **Environment**: Development-friendly configuration

## Integration Requirements

- **Node-RED dependency**: Node-RED should wait for InfluxDB to be healthy
- **Grafana dependency**: Grafana should wait for InfluxDB to be healthy
- **Health check**: Verify InfluxDB is responding on port 8086
- **Restart policy**: `unless-stopped`

## Expected Output

Provide the complete service configuration that can be added to the existing docker-compose.yml file, including:

1. Complete service definition
2. Volume mappings
3. Environment variables
4. Health check configuration
5. Network configuration
6. Dependency management

## Context

This is part of a renewable energy monitoring system that collects data from:
- Photovoltaic panels
- Wind turbines
- Biogas plants
- Heat boilers
- Energy storage systems

The InfluxDB 2.x instance will store time-series data from these devices and provide a web interface for data exploration and management. 