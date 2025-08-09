# InfluxDB 2.x Environment Variables Setup

## Prompt for Cursor IDE

I need environment variables for InfluxDB 2.x in my Docker Compose setup.

## Requirements

1. **Admin username and password**
2. **Database name**
3. **Organization name**
4. **Retention policy settings**
5. **Initial setup flags**
6. **Performance tuning parameters**

## Environment Variables Needed

### Authentication & Access
- **INFLUXDB_ADMIN_USER**: Admin username (default: admin)
- **INFLUXDB_ADMIN_PASSWORD**: Admin password (default: admin)
- **INFLUXDB_ADMIN_TOKEN**: Initial admin token
- **INFLUXDB_HTTP_AUTH_ENABLED**: Enable/disable authentication

### Database Configuration
- **INFLUXDB_DB**: Database name (renewable_energy)
- **INFLUXDB_ORG**: Organization name (renewable_energy_org)
- **INFLUXDB_BUCKET**: Default bucket name
- **INFLUXDB_RETENTION**: Retention policy duration (30d)

### Initial Setup
- **INFLUXDB_SETUP_MODE**: Enable setup mode
- **INFLUXDB_INIT_MODE**: Initialization mode
- **INFLUXDB_REPORTING_DISABLED**: Disable usage reporting
- **INFLUXDB_META_DIR**: Metadata directory path

### Performance & Storage
- **INFLUXDB_DATA_DIR**: Data directory path
- **INFLUXDB_WAL_DIR**: Write-ahead log directory
- **INFLUXDB_ENGINE_PATH**: Storage engine path
- **INFLUXDB_MAX_CONCURRENT_COMPACTIONS**: Compaction limit

### HTTP Configuration
- **INFLUXDB_HTTP_BIND_ADDRESS**: HTTP bind address
- **INFLUXDB_HTTP_PORT**: HTTP port (8086)
- **INFLUXDB_HTTP_MAX_CONNECTION_LIMIT**: Connection limit
- **INFLUXDB_HTTP_READ_TIMEOUT**: Read timeout

### Logging & Monitoring
- **INFLUXDB_LOGGING_LEVEL**: Log level (info)
- **INFLUXDB_LOGGING_FORMAT**: Log format (auto)
- **INFLUXDB_METRICS_DISABLED**: Disable internal metrics
- **INFLUXDB_PPROF_ENABLED**: Enable profiling

## File Structure

Create both:
1. **Environment section** in docker-compose.yml
2. **.env file template** with all variables

## Expected Output

### Docker Compose Environment Section
Provide the complete environment section for the InfluxDB service in docker-compose.yml, including:
- All required environment variables
- Proper formatting and indentation
- Comments for clarity
- Default values where appropriate

### .env File Template
Create a .env file template with:
- All environment variables
- Default values
- Comments explaining each variable
- Example values for reference

### Documentation
Include documentation for:
- Variable descriptions
- Default values
- Usage examples
- Troubleshooting tips

## Context

This is for a development environment where:
- Authentication can be simplified
- Performance is important for time-series data
- Easy setup and configuration is prioritized
- Integration with Node-RED and Grafana is required

The environment variables should support both development and production configurations with appropriate defaults for development use. 