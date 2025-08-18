# FUXA SCADA - Local Development Setup

## Overview
FUXA SCADA is integrated as an additional visualization layer for the renewable energy IoT monitoring system, providing industrial-style HMI (Human Machine Interface) capabilities.

## Local Development Configuration
- **Port**: 3002 (to avoid conflicts with Grafana on 3000)
- **Purpose**: Local development and testing of SCADA interfaces
- **Integration**: MQTT-based communication with Node-RED for real-time data

## Directory Structure
```
fuxa/
├── projects/          # FUXA project files and configurations
├── backups/           # Local backup scripts and configurations
└── README.md          # This file
```

## MQTT Topic Structure
- **Telemetry**: `renewable/{device_type}/{device_id}/{data_type}`
- **Control**: `renewable/control/{device_type}/{device_id}/{command}`
- **Alarms**: `renewable/alarms/{device_type}/{device_id}/{alarm_type}`

## Device Types Supported
- **Photovoltaic Systems**: Power output, efficiency, temperature, irradiance
- **Wind Turbines**: Power generation, wind speed, rotor speed, blade pitch
- **Biogas Plants**: Gas flow rate, methane concentration, temperature, pressure
- **Heat Boilers**: Temperature, pressure, fuel consumption, efficiency
- **Energy Storage**: State of charge, charge/discharge power, temperature, cycle count

## Local Development Workflow
1. Start services: `docker-compose -f docker-compose.local.yml up -d`
2. Access FUXA: http://localhost:3002
3. Configure MQTT connections and device mappings
4. Create dashboards and control interfaces
5. Test with simulated renewable energy data from Node-RED

## Backup and Persistence
- Project configurations are stored in `./fuxa/projects/`
- Local backups are stored in `./fuxa/backups/`
- All data persists across container restarts
