# MQTT Broker Configuration Guide
# IoT Renewable Energy Monitoring System

## Overview

This document provides comprehensive configuration and setup instructions for the Eclipse Mosquitto MQTT broker used in the IoT Renewable Energy Monitoring System. The configuration includes authentication, topic-based access control, persistence, logging, and WebSocket support.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Configuration Files](#configuration-files)
3. [Topic Structure](#topic-structure)
4. [Authentication & Security](#authentication--security)
5. [Access Control](#access-control)
6. [Performance Tuning](#performance-tuning)
7. [Monitoring & Logging](#monitoring--logging)
8. [Testing & Validation](#testing--validation)
9. [Troubleshooting](#troubleshooting)
10. [Security Best Practices](#security-best-practices)

## Architecture Overview

The MQTT broker serves as the central messaging hub for the renewable energy IoT system, handling communication between:

- **IoT Devices**: Photovoltaic panels, wind turbines, biogas plants, heat boilers, energy storage systems
- **Data Processing**: Node-RED flows for data validation and transformation
- **Visualization**: Grafana dashboards for real-time monitoring
- **External Systems**: Bridge connections for data replication

### Data Flow

```
IoT Devices → MQTT Broker → Node-RED → InfluxDB → Grafana
     ↑              ↓           ↓         ↓         ↓
  Commands ←   Topic Routing ← Processing ← Storage ← Visualization
```

## Configuration Files

### 1. mosquitto.conf

The main configuration file located at `mosquitto/config/mosquitto.conf`:

```bash
# Network Configuration
listener 1883
protocol mqtt
max_connections 1000

listener 9001
protocol websockets
max_connections 500

# Security Configuration
allow_anonymous false
password_file /mosquitto/config/passwd
acl_file /mosquitto/config/acl

# Logging Configuration
log_dest stdout
log_dest file /mosquitto/log/mosquitto.log
log_type error warning notice information debug

# Persistence Configuration
persistence true
persistence_location /mosquitto/data/
autosave_interval 1800
```

### 2. passwd

Password file for device authentication located at `mosquitto/config/passwd`:

```bash
# Device Authentication
pv_001:$7$101$password_hash_here
wt_001:$7$101$password_hash_here
bg_001:$7$101$password_hash_here

# Service Accounts
node_red:$7$101$password_hash_here
grafana:$7$101$password_hash_here

# Administrative Accounts
admin:$7$101$password_hash_here
```

### 3. acl

Access Control List for topic-based permissions located at `mosquitto/config/acl`:

```bash
# Device Permissions
topic write devices/photovoltaic/pv_001/data
topic write devices/photovoltaic/pv_001/status
topic read devices/photovoltaic/pv_001/commands

# Service Permissions
topic read devices/+/+/data
topic read devices/+/+/status
topic write devices/+/+/commands

# Administrative Permissions
topic readwrite #
```

## Topic Structure

### Hierarchical Topic Design

The system uses a hierarchical topic structure for scalable and organized messaging:

```
devices/{device_type}/{device_id}/{data_type}
```

### Topic Categories

#### 1. Device Data Topics
- **Purpose**: Telemetry data from IoT devices
- **Pattern**: `devices/{device_type}/{device_id}/data`
- **Permissions**: Write by device, read by services
- **QoS**: 1 (at least once delivery)
- **Retain**: false (real-time data)

**Examples:**
```
devices/photovoltaic/pv_001/data
devices/wind_turbine/wt_001/data
devices/energy_storage/es_001/data
```

#### 2. Device Status Topics
- **Purpose**: Device operational status
- **Pattern**: `devices/{device_type}/{device_id}/status`
- **Permissions**: Write by device, read by services
- **QoS**: 1
- **Retain**: true (last known status)

**Examples:**
```
devices/photovoltaic/pv_001/status
devices/wind_turbine/wt_001/status
devices/energy_storage/es_001/status
```

#### 3. Device Command Topics
- **Purpose**: Control commands to devices
- **Pattern**: `devices/{device_type}/{device_id}/commands`
- **Permissions**: Write by services, read by device
- **QoS**: 1
- **Retain**: false (immediate commands)

**Examples:**
```
devices/photovoltaic/pv_001/commands
devices/wind_turbine/wt_001/commands
devices/energy_storage/es_001/commands
```

#### 4. System Health Topics
- **Purpose**: Service health monitoring
- **Pattern**: `system/health/{service_name}`
- **Permissions**: Write by services, read by all
- **QoS**: 1
- **Retain**: true

**Examples:**
```
system/health/mosquitto
system/health/node_red
system/health/influxdb
system/health/grafana
```

#### 5. System Alert Topics
- **Purpose**: System alerts and notifications
- **Pattern**: `system/alerts/{severity}`
- **Permissions**: Write by services, read by all
- **QoS**: 1
- **Retain**: true

**Examples:**
```
system/alerts/info
system/alerts/warning
system/alerts/critical
system/alerts/error
```

### Device Types

The system supports the following device types:

1. **photovoltaic** - Solar panel systems
2. **wind_turbine** - Wind power generators
3. **biogas_plant** - Biogas production facilities
4. **heat_boiler** - Thermal energy systems
5. **energy_storage** - Battery storage systems

## Authentication & Security

### Password Management

#### Generating Passwords

Use the `mosquitto_passwd` utility to generate password hashes:

```bash
# Create new password file
mosquitto_passwd -c passwd username

# Add new user
mosquitto_passwd -b passwd username password

# Update existing password
mosquitto_passwd -b passwd existing_user new_password
```

#### Password Security Guidelines

1. **Strong Passwords**: Use at least 12 characters with mixed case, numbers, and symbols
2. **Unique Passwords**: Each device should have a unique password
3. **Regular Rotation**: Rotate passwords every 90 days
4. **Secure Storage**: Never store passwords in plain text
5. **Environment Variables**: Use environment variables for sensitive credentials

### SSL/TLS Configuration

For production environments, enable SSL/TLS encryption:

```bash
# In mosquitto.conf
listener 8883
protocol mqtt
cafile /mosquitto/config/certs/ca.crt
certfile /mosquitto/config/certs/server.crt
keyfile /mosquitto/config/certs/server.key
require_certificate false
use_identity_as_username true
```

## Access Control

### Permission Levels

#### 1. Device Permissions
- **Write Access**: Can publish to their own data and status topics
- **Read Access**: Can subscribe to their own command topics
- **Scope**: Limited to device-specific topics

#### 2. Service Permissions
- **Node-RED**: Read all device data, write commands, publish system health
- **Grafana**: Read all device data and system health for visualization
- **Bridge**: Full read/write access for external replication

#### 3. Administrative Permissions
- **Admin**: Full access to all topics
- **Monitor**: Read-only access to all topics

### Wildcard Permissions

For scalable device management, use wildcard permissions:

```bash
# Allow new photovoltaic devices
topic write devices/photovoltaic/+/data
topic write devices/photovoltaic/+/status
topic read devices/photovoltaic/+/commands

# Allow new wind turbine devices
topic write devices/wind_turbine/+/data
topic write devices/wind_turbine/+/status
topic read devices/wind_turbine/+/commands
```

## Performance Tuning

### Connection Limits

```bash
# Maximum concurrent connections
max_connections 1000

# WebSocket connections
max_connections 500
```

### Message Handling

```bash
# Message queue limits
max_queued_messages 100
max_inflight_messages 20

# Message size (0 = unlimited)
message_size_limit 0
```

### Persistence Configuration

```bash
# Enable persistence
persistence true
persistence_location /mosquitto/data/

# Autosave settings
autosave_interval 1800
autosave_on_changes false
```

## Monitoring & Logging

### Log Configuration

```bash
# Log destinations
log_dest stdout
log_dest file /mosquitto/log/mosquitto.log

# Log levels
log_type error warning notice information debug

# Log format
log_timestamp true
log_facility daemon
```

### Health Monitoring

The broker publishes health information to `system/health/mosquitto`:

```json
{
  "service": "mosquitto",
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "connections": 15,
  "messages_sent": 1250,
  "messages_received": 1200
}
```

### Metrics to Monitor

1. **Connection Count**: Number of active connections
2. **Message Throughput**: Messages per second
3. **Queue Size**: Number of queued messages
4. **Memory Usage**: Broker memory consumption
5. **Authentication Failures**: Failed login attempts

## Testing & Validation

### Using the Test Script

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

#### 1. Basic Connectivity

```bash
# Test connection
mosquitto_pub -h localhost -p 1883 -t test/topic -m "Hello World"

# Test subscription
mosquitto_sub -h localhost -p 1883 -t test/topic
```

#### 2. Authentication Testing

```bash
# Test with credentials
mosquitto_pub -h localhost -p 1883 -u username -P password -t test/topic -m "Auth test"

# Test anonymous access (should fail)
mosquitto_pub -h localhost -p 1883 -t test/topic -m "Anonymous test"
```

#### 3. Topic Testing

```bash
# Test device data publishing
mosquitto_pub -h localhost -p 1883 -u pv_001 -P password \
  -t devices/photovoltaic/pv_001/data \
  -m '{"device_id":"pv_001","data":{"power":500}}'

# Test device command subscription
mosquitto_sub -h localhost -p 1883 -u pv_001 -P password \
  -t devices/photovoltaic/pv_001/commands
```

## Troubleshooting

### Common Issues

#### 1. Connection Refused

**Symptoms**: Cannot connect to MQTT broker
**Causes**: Broker not running, wrong port, firewall blocking
**Solutions**:
- Check if broker is running: `docker ps | grep mosquitto`
- Verify port configuration: `netstat -tlnp | grep 1883`
- Check firewall settings

#### 2. Authentication Failed

**Symptoms**: "Connection refused: not authorised"
**Causes**: Wrong credentials, user not in password file
**Solutions**:
- Verify username/password in passwd file
- Check ACL permissions
- Test with mosquitto_passwd utility

#### 3. Topic Access Denied

**Symptoms**: "Topic not allowed"
**Causes**: Insufficient permissions in ACL file
**Solutions**:
- Check ACL file for topic permissions
- Verify user has appropriate read/write access
- Test with admin credentials

#### 4. High Memory Usage

**Symptoms**: Broker consuming excessive memory
**Causes**: Too many connections, large message queues
**Solutions**:
- Reduce max_connections
- Lower max_queued_messages
- Monitor and disconnect idle clients

### Debug Commands

```bash
# Check broker logs
docker logs iot-mosquitto

# Check configuration
docker exec iot-mosquitto mosquitto -c /mosquitto/config/mosquitto.conf -v

# Test configuration syntax
docker exec iot-mosquitto mosquitto -c /mosquitto/config/mosquitto.conf --test-config

# Monitor connections
docker exec iot-mosquitto mosquitto_sub -t '$SYS/broker/clients/connected' -C 1
```

## Security Best Practices

### 1. Authentication

- **Disable Anonymous Access**: Set `allow_anonymous false`
- **Strong Passwords**: Use complex, unique passwords
- **Regular Rotation**: Change passwords every 90 days
- **Credential Management**: Use environment variables

### 2. Access Control

- **Principle of Least Privilege**: Grant minimum required permissions
- **Topic Isolation**: Separate device topics by device ID
- **Service Accounts**: Use dedicated accounts for services
- **Regular Review**: Audit permissions quarterly

### 3. Network Security

- **Firewall Rules**: Restrict access to MQTT ports
- **VPN Access**: Use VPN for remote access
- **Network Segmentation**: Isolate IoT devices
- **SSL/TLS**: Enable encryption in production

### 4. Monitoring

- **Authentication Logs**: Monitor failed login attempts
- **Connection Monitoring**: Track active connections
- **Topic Usage**: Monitor topic access patterns
- **Performance Metrics**: Track broker performance

### 5. Backup & Recovery

- **Configuration Backup**: Backup all config files
- **Password Backup**: Secure backup of password hashes
- **Disaster Recovery**: Document recovery procedures
- **Testing**: Regularly test backup restoration

### 6. Updates & Maintenance

- **Security Updates**: Keep Mosquitto updated
- **Dependency Updates**: Update underlying OS packages
- **Configuration Review**: Regular security audits
- **Documentation**: Keep configuration documentation current

## Environment Variables

The system uses environment variables for configuration. Key variables include:

```bash
# MQTT Configuration
MQTT_PORT=1883
MQTT_WS_PORT=9001
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=admin_password_456

# Performance Tuning
MOSQUITTO_MAX_CONNECTIONS=1000
MOSQUITTO_MAX_QUEUED_MESSAGES=100
MOSQUITTO_AUTOSAVE_INTERVAL=1800

# Logging
MOSQUITTO_LOG_LEVEL=information
```

## Conclusion

This MQTT broker configuration provides a secure, scalable, and performant messaging infrastructure for the IoT Renewable Energy Monitoring System. The hierarchical topic structure, comprehensive access control, and security measures ensure reliable communication between all system components while maintaining data integrity and system security.

For additional support or questions, refer to the [Eclipse Mosquitto documentation](https://mosquitto.org/documentation/) or the project's issue tracker. 