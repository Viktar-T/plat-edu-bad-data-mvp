# InfluxDB 2.x Configuration

## Overview

This directory contains the configuration files and scripts for InfluxDB 2.x in the Renewable Energy Monitoring System. InfluxDB 2.x is a time-series database that stores sensor data from various renewable energy devices.

## Directory Structure

```
influxdb/
├── config/
│   ├── influxdb.conf      # Main configuration file
│   └── influxdb.yaml      # YAML configuration file
├── scripts/
│   ├── init-database.sh   # Database initialization script
│   └── setup-users.sh     # User and permission setup script
├── data/                  # Persistent data storage
├── backups/               # Backup directory
└── README.md             # This file
```

## Configuration Files

### influxdb.conf
The main configuration file for InfluxDB 2.x with the following key settings:

- **HTTP Server**: Port 8086, authentication disabled for development
- **Data Storage**: Optimized for time-series workloads
- **Logging**: Info level with structured logging
- **Performance**: Unlimited query limits for development
- **Security**: TLS disabled for development environment

### influxdb.yaml
YAML format configuration file with the same settings as influxdb.conf, providing an alternative configuration format.

## Scripts

### init-database.sh
Database initialization script that:

1. **Waits for InfluxDB** to be ready
2. **Sets up initial configuration** (admin user, organization, bucket)
3. **Creates device-specific buckets** for different renewable energy devices
4. **Sets up retention policies** for data management
5. **Verifies the setup** and provides access information

**Usage:**
```bash
chmod +x scripts/init-database.sh
./scripts/init-database.sh
```

### setup-users.sh
User and permission management script that:

1. **Creates users** with different roles (operator, viewer, developer, analyst)
2. **Creates organizations** for different teams
3. **Sets up buckets** for team-specific data
4. **Creates tokens** for API access
5. **Configures permissions** for different user roles
6. **Verifies the setup** and displays a summary

**Usage:**
```bash
chmod +x scripts/setup-users.sh
./scripts/setup-users.sh
```

## Default Configuration

### Access Information
- **URL**: http://localhost:8086
- **Admin Username**: admin
- **Admin Password**: admin
- **Organization**: renewable_energy_org
- **Default Bucket**: renewable_energy
- **Admin Token**: renewable_energy_admin_token_123

### Device-Specific Buckets
- `photovoltaic_data` (30 days retention)
- `wind_turbine_data` (30 days retention)
- `biogas_plant_data` (30 days retention)
- `heat_boiler_data` (30 days retention)
- `energy_storage_data` (30 days retention)
- `system_metrics` (7 days retention)
- `alerts` (90 days retention)

### User Roles
- **operator**: Read access to device data
- **viewer**: Read-only access to all data
- **developer**: Read-write access for development
- **analyst**: Read access for data analysis

## Data Schema

### Measurement Structure
Data is organized by device type with the following structure:

```sql
-- Example measurement structure
measurement: device_data
tags:
  - device_id (e.g., "pv_001", "wt_001")
  - device_type (e.g., "photovoltaic", "wind_turbine")
  - location (e.g., "site_a", "site_b")
  - status (e.g., "operational", "maintenance")

fields:
  - power_output (float)
  - temperature (float)
  - voltage (float)
  - current (float)
  - efficiency (float)
  - additional device-specific fields
```

### Device-Specific Fields

#### Photovoltaic Panels
- `power_output` (W)
- `temperature` (°C)
- `voltage` (V)
- `current` (A)
- `irradiance` (W/m²)
- `efficiency` (%)

#### Wind Turbines
- `power_output` (W)
- `wind_speed` (m/s)
- `wind_direction` (degrees)
- `rotor_speed` (RPM)
- `vibration` (mm/s)
- `efficiency` (%)

#### Biogas Plants
- `gas_flow` (m³/h)
- `methane_concentration` (%)
- `temperature` (°C)
- `pressure` (bar)
- `ph_level` (pH)
- `efficiency` (%)

#### Heat Boilers
- `temperature` (°C)
- `pressure` (bar)
- `fuel_consumption` (L/h)
- `efficiency` (%)
- `flow_rate` (L/min)
- `output_power` (kW)

#### Energy Storage
- `state_of_charge` (%)
- `voltage` (V)
- `current` (A)
- `temperature` (°C)
- `cycle_count` (integer)
- `health_status` (string)

## Performance Optimization

### Configuration Optimizations
- **Unlimited query limits** for development
- **Optimized memory settings** for time-series data
- **Efficient compression** for storage
- **Proper indexing** on device_id and device_type tags

### Query Optimization Tips
1. **Use time ranges** to limit data scope
2. **Filter by tags** before aggregating
3. **Use appropriate retention policies**
4. **Index frequently queried tags**
5. **Use continuous queries** for aggregations

## Backup and Recovery

### Backup Strategy
- **Daily backups** of all buckets
- **Weekly full backups** including configuration
- **Monthly retention** of backup files

### Backup Commands
```bash
# Backup specific bucket
influx backup /backups/bucket_backup_$(date +%Y%m%d) --bucket renewable_energy

# Full backup
influx backup /backups/full_backup_$(date +%Y%m%d)
```

### Restore Commands
```bash
# Restore specific bucket
influx restore /backups/bucket_backup_20240101 --bucket renewable_energy

# Full restore
influx restore /backups/full_backup_20240101
```

## Monitoring and Maintenance

### Health Checks
- **Service status**: Check if InfluxDB is running
- **HTTP endpoint**: Verify port 8086 is accessible
- **Database connectivity**: Test connection and queries
- **Disk space**: Monitor data directory usage

### Log Monitoring
- **Access logs**: Monitor API usage
- **Error logs**: Track and resolve issues
- **Performance logs**: Monitor query performance
- **System logs**: Track resource usage

### Maintenance Tasks
- **Data compaction**: Automatic background process
- **Index optimization**: Periodic index maintenance
- **Log rotation**: Manage log file sizes
- **Configuration updates**: Apply security patches

## Security Considerations

### Development Environment
- **Authentication disabled** for easy development
- **No TLS encryption** for local development
- **Unlimited access** for testing purposes

### Production Environment
- **Enable authentication** with strong passwords
- **Use TLS encryption** for data transmission
- **Implement proper access controls**
- **Regular security updates**
- **Audit logging** enabled

## Troubleshooting

### Common Issues

#### Connection Problems
- **Check service status**: `docker ps | grep influxdb`
- **Verify port access**: `curl http://localhost:8086/health`
- **Check logs**: `docker logs iot-influxdb2`

#### Performance Issues
- **Monitor resource usage**: CPU, memory, disk I/O
- **Check query performance**: Use EXPLAIN for slow queries
- **Optimize indexes**: Review tag and field usage
- **Adjust retention policies**: Remove old data

#### Data Issues
- **Verify data ingestion**: Check Node-RED flows
- **Validate data format**: Ensure proper line protocol
- **Check permissions**: Verify user access rights
- **Review schema**: Ensure consistent measurement structure

### Debug Commands
```bash
# Check InfluxDB status
curl -f http://localhost:8086/health

# List buckets
influx bucket list

# Check user permissions
influx auth list

# Monitor system metrics
influx query 'from(bucket:"system_metrics") |> range(start: -1h)'
```

## Integration

### Node-RED Integration
- **InfluxDB Out node**: Write data to buckets
- **InfluxDB In node**: Query data from buckets
- **Authentication**: Use admin token or credentials
- **Error handling**: Implement proper error handling

### Grafana Integration
- **Data source**: Configure InfluxDB 2.x data source
- **Query language**: Use Flux for queries
- **Authentication**: Use admin token
- **Dashboards**: Create device-specific dashboards

### MQTT Integration
- **Data flow**: MQTT → Node-RED → InfluxDB
- **Topic structure**: `devices/{device_type}/{device_id}/{data_type}`
- **Data transformation**: Convert JSON to line protocol
- **Error handling**: Implement retry logic

## Support

For issues and questions:
1. **Check logs**: Review InfluxDB and application logs
2. **Verify configuration**: Ensure all settings are correct
3. **Test connectivity**: Verify network and service connectivity
4. **Review documentation**: Check InfluxDB official documentation
5. **Community support**: Use InfluxDB community forums

## Version Information

- **InfluxDB Version**: 2.7
- **Configuration Version**: 1.0
- **Last Updated**: 2024-01-15
- **Compatibility**: Docker Compose, Node-RED, Grafana 