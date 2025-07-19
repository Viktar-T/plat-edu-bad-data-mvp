# InfluxDB 3.x Configuration for Renewable Energy Monitoring

This directory contains the configuration for InfluxDB 3.x, which serves as the time-series database for the IoT Renewable Energy Monitoring System.

## Overview

InfluxDB 3.x replaces the bucket-based approach of InfluxDB 2.x with a database and table structure, providing:
- **SQL queries** instead of Flux (InfluxQL also supported)
- **Apache Arrow/Parquet storage** for better compression
- **Unlimited cardinality** for device and storage metadata
- **Object storage** for cost-effective long-term retention
- **Enhanced performance** for time-series workloads

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   Node-RED      │───▶│   InfluxDB 3.x  │
│                 │    │   (Processing)  │    │   (Database)    │
│ • Photovoltaic  │    │                 │    │                 │
│ • Wind Turbine  │    │ • Data Validation│    │ • Databases     │
│ • Biogas Plant  │    │ • Transformation│    │ • Tables        │
│ • Heat Boiler   │    │ • Aggregation   │    │ • SQL Queries   │
│ • Energy Storage│    │ • Error Handling│    │ • Object Store  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Database Structure

### Primary Database: `renewable-energy-monitoring`
**Retention**: 10 days (configurable)

#### Tables:
1. **photovoltaic_data** - Solar panel performance data
2. **wind_turbine_data** - Wind turbine performance data  
3. **biogas_plant_data** - Biogas plant performance data
4. **heat_boiler_data** - Heat boiler performance data
5. **energy_storage_data** - Energy storage system data
6. **laboratory_equipment_data** - Laboratory equipment measurements

### Supporting Databases:
- **sensor-data** (7 days) - Raw sensor readings
- **alerts** (30 days) - System alerts and notifications
- **system-metrics** (15 days) - System performance metrics

## Schema Design

### Tag Strategy (High Cardinality)
- `device_id` / `storage_id` / `equipment_id` - Unique device identifier
- `location` - Physical location
- `device_type` / `storage_type` / `equipment_type` - Device classification
- `status` - Operational status

### Field Strategy (Low Cardinality)
- `power_output` - Power generation/consumption in watts
- `temperature` - Temperature readings in Celsius
- `voltage`, `current` - Electrical measurements
- `efficiency` - Device efficiency percentage
- `state_of_charge` - Battery state of charge (0-100%)

## Configuration Files

### Main Configuration
- `config/influx3-configs` - Main configuration file
- `config/schemas/` - JSON schema files for each table

### Scripts
- `scripts/influx3-setup.sh` - Database initialization script
- `scripts/data-validation.js` - Data validation and transformation
- `scripts/connection-manager.js` - Connection management with retry logic

## Quick Start

### 1. Start InfluxDB 3.x
```bash
# Start the entire stack
docker-compose up -d

# Check InfluxDB status
docker-compose logs influxdb
```

### 2. Initialize Databases
```bash
# Run the setup script
chmod +x scripts/influx3-setup.sh
./scripts/influx3-setup.sh
```

### 3. Verify Setup
```bash
# Check health endpoint
curl http://localhost:8086/health

# List databases
curl -H "Authorization: Bearer $INFLUXDB3_ADMIN_TOKEN" \
     http://localhost:8086/api/v3/configure/database
```

## Data Operations

### Writing Data
```bash
# Example: Write photovoltaic data
curl -X POST "http://localhost:8086/api/v3/write/renewable-energy-monitoring/photovoltaic_data" \
     -H "Authorization: Bearer $APPLICATION_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "timestamp": "2024-01-15T10:30:00Z",
       "device_id": "pv_001",
       "location": "site_a",
       "device_type": "photovoltaic",
       "status": "operational",
       "power_output": 584.43,
       "voltage": 48.3,
       "current": 12.1,
       "temperature": 45.2,
       "irradiance": 850.5,
       "efficiency": 18.5
     }'
```

### Querying Data
```sql
-- Example: Get photovoltaic power output for last 24 hours
SELECT 
    timestamp,
    device_id,
    power_output,
    efficiency
FROM renewable_energy_monitoring.photovoltaic_data
WHERE timestamp >= NOW() - INTERVAL '24 hours'
  AND device_id = 'pv_001'
ORDER BY timestamp DESC;

-- Example: Energy storage state of charge analysis
SELECT 
    storage_id,
    AVG(state_of_charge) as avg_soc,
    MIN(state_of_charge) as min_soc,
    MAX(state_of_charge) as max_soc
FROM renewable_energy_monitoring.energy_storage_data
WHERE timestamp >= NOW() - INTERVAL '7 days'
GROUP BY storage_id;
```

## Performance Optimization

### Indexing Strategy
- **Primary indexes**: `device_id + timestamp`, `location + timestamp`
- **Secondary indexes**: `status + timestamp`, `health_status + timestamp`
- **Composite indexes**: For complex queries involving multiple tags

### Partitioning
- **Time-based partitioning**: Daily partitions for efficient querying
- **Compression**: ZSTD algorithm with level 3 for optimal compression ratio

### Query Optimization
- **Query cache**: 512MB cache for frequently accessed data
- **Write buffer**: 64MB buffer with 1-second flush interval
- **Connection pooling**: Up to 1000 concurrent connections

## Security Configuration

### Authentication
- **Token-based authentication** with admin and application tokens
- **Read-only tokens** for dashboard access
- **Token expiration** and rotation policies

### Network Security
- **TLS/SSL encryption** (configurable for production)
- **Connection timeouts** and rate limiting
- **IP whitelisting** capabilities

## Monitoring and Health Checks

### Health Endpoints
- `/health` - Basic health check
- `/ready` - Readiness check
- `/metrics` - Prometheus metrics

### Performance Monitoring
- **Slow query detection** (threshold: 1000ms)
- **Memory usage monitoring** (limit: 2GB)
- **Connection pool monitoring**

## Backup and Recovery

### Backup Configuration
- **Automated backups** with cron scheduling
- **Parquet format** for efficient storage
- **S3-compatible storage** for production

### Backup Commands
```bash
# Manual backup
docker exec iot-influxdb3 influx backup \
    --database renewable-energy-monitoring \
    --output /var/lib/influxdb3/backups/backup_$(date +%Y%m%d_%H%M%S)

# Restore from backup
docker exec iot-influxdb3 influx restore \
    --database renewable-energy-monitoring \
    --input /var/lib/influxdb3/backups/backup_20240115_143000
```

## Data Validation

### Schema Validation
- **JSON Schema validation** for all incoming data
- **Range checks** for sensor values
- **Business logic validation** for device-specific rules

### Error Handling
- **Duplicate detection** and handling
- **Retry logic** for failed writes
- **Dead letter queue** for persistent failures

## Migration from InfluxDB 2.x

### Key Differences
1. **Buckets → Databases**: Use databases instead of buckets
2. **Measurements → Tables**: Use tables with defined schemas
3. **Flux → SQL**: Use SQL queries instead of Flux
4. **Line Protocol → JSON**: Use JSON format for data ingestion

### Migration Steps
1. **Export data** from InfluxDB 2.x using `influx backup`
2. **Transform data** to new schema format
3. **Import data** to InfluxDB 3.x using new APIs
4. **Update applications** to use new endpoints

## Troubleshooting

### Common Issues

#### Connection Refused
```bash
# Check if InfluxDB is running
docker-compose ps influxdb

# Check logs
docker-compose logs influxdb
```

#### Authentication Errors
```bash
# Verify token is valid
curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:8086/api/v3/configure/database
```

#### Performance Issues
```bash
# Check memory usage
docker stats iot-influxdb3

# Check slow queries
curl -H "Authorization: Bearer $ADMIN_TOKEN" \
     http://localhost:8086/api/v3/monitoring/slow-queries
```

### Log Analysis
```bash
# Follow logs in real-time
docker-compose logs -f influxdb

# Search for errors
docker-compose logs influxdb | grep ERROR
```

## Environment Variables

### Required Variables
```bash
INFLUXDB3_ADMIN_TOKEN=your-super-secret-admin-token
INFLUXDB3_ORG=renewable_energy
```

### Optional Variables
```bash
INFLUXDB3_OBJECT_STORE=file
INFLUXDB3_DATA_DIR=/var/lib/influxdb3
INFLUXDB3_QUERY_CACHE_SIZE_MB=512
INFLUXDB3_WRITE_BUFFER_SIZE_MB=64
```

## API Reference

### Database Operations
- `POST /api/v3/configure/database` - Create database
- `GET /api/v3/configure/database` - List databases
- `DELETE /api/v3/configure/database/{name}` - Delete database

### Table Operations
- `POST /api/v3/configure/database/{db}/table` - Create table
- `GET /api/v3/configure/database/{db}/table` - List tables
- `DELETE /api/v3/configure/database/{db}/table/{table}` - Delete table

### Data Operations
- `POST /api/v3/write/{db}/{table}` - Write data
- `POST /api/v3/query/{db}` - Query data
- `GET /api/v3/query/{db}/schema` - Get schema

### Token Operations
- `POST /api/v3/configure/token` - Create token
- `GET /api/v3/configure/token` - List tokens
- `DELETE /api/v3/configure/token/{id}` - Delete token

## Contributing

When contributing to the InfluxDB configuration:

1. **Update schemas** when adding new device types
2. **Add validation rules** for new data fields
3. **Update documentation** for new features
4. **Test thoroughly** before deployment
5. **Follow naming conventions** for consistency

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the logs for error messages
3. Consult the InfluxDB 3.x documentation
4. Create an issue in the project repository 