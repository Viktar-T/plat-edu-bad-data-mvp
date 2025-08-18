# FUXA SCADA Integration Testing Guide

## Prerequisites
- Docker and Docker Compose installed
- Local development environment running
- MQTT broker (Mosquitto) accessible
- Node-RED flows deployed

## Test Environment Setup

### 1. Start Local Development Environment
```powershell
# Start all services including FUXA
docker-compose -f docker-compose.local.yml up -d

# Verify all services are running
docker-compose -f docker-compose.local.yml ps
```

### 2. Verify Service Health
```powershell
# Check FUXA service health
docker-compose -f docker-compose.local.yml logs fuxa

# Check MQTT broker connectivity
docker-compose -f docker-compose.local.yml logs mosquitto

# Check Node-RED connectivity
docker-compose -f docker-compose.local.yml logs node-red
```

## FUXA Access and Configuration

### 1. Access FUXA Web Interface
- **URL**: http://localhost:3002
- **Default Credentials**: No authentication required (local development)
- **Expected**: FUXA web interface loads successfully

### 2. Initial FUXA Configuration
1. **Create New Project**:
   - Click "New Project"
   - Name: "Renewable Energy Monitoring"
   - Description: "Local development SCADA for renewable energy IoT system"

2. **Configure MQTT Connection**:
   - Go to Settings → MQTT
   - Broker: `mosquitto` (container name)
   - Port: `1883`
   - Username: `admin`
   - Password: `admin_password_456`
   - Test connection

## MQTT Topic Testing

### 1. Test Data Flow from Node-RED to FUXA

#### Photovoltaic Data
```powershell
# Test PV power data
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/pv/panel_01/power" -m '{"value": 1250.5, "timestamp": "2024-01-15T10:30:00Z", "quality": "good"}'
```

#### Wind Turbine Data
```powershell
# Test wind turbine power data
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/wind/turbine_01/power" -m '{"value": 850.2, "timestamp": "2024-01-15T10:30:00Z", "quality": "good"}'
```

#### Biogas Plant Data
```powershell
# Test biogas gas flow data
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/biogas/plant_01/gas_flow" -m '{"value": 45.8, "timestamp": "2024-01-15T10:30:00Z", "quality": "good"}'
```

#### Heat Boiler Data
```powershell
# Test boiler temperature data
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/boiler/boiler_01/temperature" -m '{"value": 185.5, "timestamp": "2024-01-15T10:30:00Z", "quality": "good"}'
```

#### Energy Storage Data
```powershell
# Test battery state of charge data
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/storage/battery_01/soc" -m '{"value": 78.5, "timestamp": "2024-01-15T10:30:00Z", "quality": "good"}'
```

### 2. Test Control Commands from FUXA to Node-RED

#### Send Control Command
```powershell
# Test control command (this should be sent from FUXA interface)
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/control/pv/panel_01/start" -m '{"value": true, "timestamp": "2024-01-15T10:30:00Z"}'
```

### 3. Test Alarm System

#### Send Alarm Message
```powershell
# Test alarm message
mosquitto_pub -h localhost -u admin -P admin_password_456 -t "renewable/alarms/pv/panel_01/overtemperature" -m '{"severity": "critical", "message": "Panel temperature exceeds safe limits", "timestamp": "2024-01-15T10:30:00Z", "acknowledged": false}'
```

## FUXA Dashboard Testing

### 1. Create Overview Dashboard
1. **Add Gauge Widgets**:
   - PV Power Output (0-2000 W)
   - Wind Turbine Power (0-1500 W)
   - Biogas Gas Flow (0-100 m³/h)
   - Boiler Temperature (0-300 °C)
   - Battery State of Charge (0-100 %)

2. **Add Chart Widgets**:
   - Real-time power generation trends
   - Historical efficiency data
   - Temperature monitoring

3. **Add Control Widgets**:
   - Start/Stop buttons for each device
   - Setpoint adjustment sliders
   - Mode selection dropdowns

### 2. Test Real-time Data Display
- Verify gauges update with live data
- Check chart widgets show trending data
- Confirm control widgets respond to user input

### 3. Test Alarm Display
- Verify alarm messages appear in FUXA
- Test alarm acknowledgment functionality
- Check alarm history logging

## Integration Testing

### 1. End-to-End Data Flow Test
1. **Start Node-RED simulation flows**
2. **Verify data appears in FUXA dashboards**
3. **Test control commands from FUXA**
4. **Verify alarms are displayed and acknowledged**

### 2. Performance Testing
- **Latency**: Data should appear in FUXA within 2 seconds
- **Throughput**: Handle multiple concurrent data streams
- **Reliability**: Test with network interruptions

### 3. Error Handling Testing
- **MQTT Connection Loss**: Verify reconnection behavior
- **Invalid Data**: Test with malformed JSON messages
- **Service Restart**: Verify data persistence after container restart

## Backup and Recovery Testing

### 1. Test Backup Script
```powershell
# Run FUXA backup script
.\fuxa\backups\backup-fuxa-config.ps1

# Verify backup was created
Get-ChildItem .\fuxa\backups\
```

### 2. Test Data Persistence
1. **Stop FUXA container**
2. **Modify project files**
3. **Restart FUXA container**
4. **Verify configurations persist**

## Troubleshooting

### Common Issues

#### FUXA Not Accessible
- Check if container is running: `docker-compose -f docker-compose.local.yml ps fuxa`
- Check logs: `docker-compose -f docker-compose.local.yml logs fuxa`
- Verify port mapping: Port 3002 should be available

#### MQTT Connection Issues
- Verify Mosquitto is running: `docker-compose -f docker-compose.local.yml ps mosquitto`
- Check MQTT credentials in FUXA configuration
- Test MQTT connection manually with mosquitto_pub/sub

#### Data Not Appearing in FUXA
- Verify Node-RED flows are deployed
- Check MQTT topic structure matches FUXA configuration
- Verify data format is JSON-compatible

#### Control Commands Not Working
- Check Node-RED control flow is active
- Verify MQTT topic structure for control commands
- Check Node-RED logs for command processing

## Success Criteria
- [ ] FUXA web interface accessible at http://localhost:3002
- [ ] MQTT connection established successfully
- [ ] Real-time data displays in FUXA dashboards
- [ ] Control commands sent from FUXA are received by Node-RED
- [ ] Alarm messages are displayed and can be acknowledged
- [ ] Data persists across container restarts
- [ ] Backup script creates valid backups
- [ ] All renewable energy device types are supported
