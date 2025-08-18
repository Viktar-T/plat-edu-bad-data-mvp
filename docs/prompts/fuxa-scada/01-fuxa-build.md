# Cursor AI Prompt — Local FUXA SCADA Development for Renewable Energy Monitoring

Build and integrate **FUXA SCADA** locally using Docker as an additional visualization layer into the existing renewable energy IoT monitoring system alongside Grafana and the custom React web app.

## Project Context
- **Existing System**: MQTT → Node-RED → InfluxDB → Grafana + Custom React App
- **New Addition**: FUXA SCADA for industrial-style HMI (Human Machine Interface) - **LOCAL DEVELOPMENT ONLY**
- **Purpose**: Provide operators with intuitive control interfaces and real-time asset management in local development environment

## Integration Tasks

### 1. Local Docker Development Setup
- Add FUXA service to `docker-compose.local.yml` for local development only
- Configure proper networking with existing MQTT broker and Node-RED
- Implement health checks and restart policies for local development
- Use environment variables for local configuration management
- Ensure FUXA runs on a unique local port (e.g., 3002) to avoid conflicts with existing services

### 2. MQTT Integration Strategy
- **Telemetry Flow**: Node-RED publishes renewable energy data to FUXA-subscribed topics
- **Control Flow**: FUXA publishes operator commands to Node-RED-subscribed topics
- **Topic Structure**: `renewable/{device_type}/{device_id}/{data_type}` (e.g., `renewable/pv/panel_01/power`)
- **QoS Levels**: QoS 1 for critical control commands, QoS 0 for telemetry data
- **Retained Messages**: Latest device status for FUXA initialization

### 3. Renewable Energy Asset Configuration
- **Photovoltaic Systems**: Power output, efficiency, temperature, irradiance
- **Wind Turbines**: Power generation, wind speed, rotor speed, blade pitch
- **Biogas Plants**: Gas flow rate, methane concentration, temperature, pressure
- **Heat Boilers**: Temperature, pressure, fuel consumption, efficiency
- **Energy Storage**: State of charge, charge/discharge power, temperature, cycle count

### 4. FUXA Dashboard Design
- **Overview Dashboard**: System-wide KPIs, total power generation, storage status
- **Asset-Specific Pages**: Detailed views for each renewable energy type
- **Control Interfaces**: Start/stop buttons, setpoint adjustments, mode selection
- **Real-time Visualization**: Gauges, charts, trend displays, status indicators

### 5. Alarm & Event Management
- **Alarm Rules**: Over-temperature, low battery SoC, equipment faults, efficiency drops
- **Event Flow**: Node-RED detects alarms → MQTT → FUXA displays → Operator acknowledgment
- **Alarm Categories**: Critical (red), Warning (yellow), Information (blue)
- **Acknowledgment Loop**: Operator actions published back to Node-RED for logging

### 6. Data Flow Integration
- **Primary Flow**: MQTT → FUXA (real-time monitoring and control)
- **Secondary Flow**: Selected metrics → InfluxDB (historical analysis)
- **Data Filtering**: Node-RED forwards relevant metrics to InfluxDB for long-term storage
- **Performance**: Optimize for real-time responsiveness in FUXA

### 7. Local Development Persistence
- Mount FUXA project directory as Docker volume for local development
- Implement local backup scripts for project configurations during development
- Version control for dashboard layouts and device configurations in local environment
- Local disaster recovery procedures for FUXA project data during development

### 8. Local Development Documentation
- Update README with local FUXA development setup and configuration instructions
- Document MQTT topic structure and data formats for local development
- Provide developer training materials for local dashboard navigation and testing
- Include troubleshooting guides for common local development issues

## Local Development Success Criteria
- FUXA displays live renewable energy asset data with <2 second latency in local environment
- Operator controls in FUXA successfully trigger Node-RED actions during local development
- Alarm system provides timely notifications with proper acknowledgment in local testing
- All configurations persist across local container restarts
- Local integration complements existing Grafana and React app workflows for development purposes
- FUXA runs successfully on local Docker environment without conflicts with existing services
