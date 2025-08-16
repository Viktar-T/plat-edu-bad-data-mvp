# Cursor AI Prompt — Integrate FUXA SCADA for Renewable Energy Monitoring

Integrate **FUXA SCADA** as an additional visualization layer into the existing renewable energy IoT monitoring system alongside Grafana and the custom React web app.

## Project Context
- **Existing System**: MQTT → Node-RED → InfluxDB → Grafana + Custom React App
- **New Addition**: FUXA SCADA for industrial-style HMI (Human Machine Interface)
- **Purpose**: Provide operators with intuitive control interfaces and real-time asset management

## Integration Tasks

### 1. Docker & Infrastructure
- Add FUXA service to `docker-compose.yml` with persistent project storage
- Configure proper networking with existing MQTT broker and Node-RED
- Implement health checks and restart policies
- Use environment variables for configuration management

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

### 7. Persistence & Backup
- Mount FUXA project directory as Docker volume
- Implement automated backup scripts for project configurations
- Version control for dashboard layouts and device configurations
- Disaster recovery procedures for FUXA project data

### 8. Documentation & Training
- Update README with FUXA setup and configuration instructions
- Document MQTT topic structure and data formats
- Provide operator training materials for dashboard navigation
- Include troubleshooting guides for common issues

## Success Criteria
- FUXA displays live renewable energy asset data with <2 second latency
- Operator controls in FUXA successfully trigger Node-RED actions
- Alarm system provides timely notifications with proper acknowledgment
- All configurations persist across container restarts
- Integration complements existing Grafana and React app workflows
