# InfluxDB 2.x Configuration Files Setup

## Prompt for Cursor IDE

Create a complete InfluxDB 2.x configuration for my renewable energy monitoring system.

## Requirements

1. **Config file** that disables authentication for development
2. **Proper HTTP and UDP configurations**
3. **Database initialization script** to create 'renewable_energy' database
4. **Retention policy setup** (30 days)
5. **User creation** (admin/admin)
6. **Proper logging configuration**
7. **Performance optimizations** for time-series data

## File Structure

Create all necessary files in an 'influxdb' folder structure:

```
influxdb/
├── config/
│   ├── influxdb.conf
│   └── influxdb.yaml
├── scripts/
│   ├── init-database.sh
│   └── setup-users.sh
├── data/
├── backups/
└── README.md
```

## Configuration Details

### Main Configuration File
- **HTTP server**: Port 8086, bind to all interfaces
- **UDP server**: Disabled for this setup
- **Authentication**: Disabled for development
- **Logging**: Info level, structured logging
- **Performance**: Optimized for time-series workloads

### Database Initialization
- **Database name**: `renewable_energy`
- **Retention policy**: 30 days
- **Shard duration**: 1 day
- **Replication factor**: 1 (single node)

### User Management
- **Admin user**: `admin`
- **Admin password**: `admin`
- **Permissions**: Full access to all databases
- **Token**: Generate initial admin token

### Performance Optimizations
- **Memory settings**: Optimized for time-series data
- **Cache settings**: Appropriate for sensor data
- **Compression**: Enabled for storage efficiency
- **Query optimization**: Settings for analytical queries

## Expected Output

Provide all configuration files with:

1. **influxdb.conf** - Main configuration file
2. **init-database.sh** - Database initialization script
3. **setup-users.sh** - User and permission setup script
4. **README.md** - Configuration documentation
5. **Environment variables** for Docker integration

## Context

This configuration will be used in a Docker container for a renewable energy monitoring system that processes:
- High-frequency sensor data (every 1-5 seconds)
- Multiple device types (photovoltaic, wind, biogas, etc.)
- Time-series queries for dashboards
- Data retention for 30 days

The configuration should be optimized for development and testing while maintaining good performance characteristics. 