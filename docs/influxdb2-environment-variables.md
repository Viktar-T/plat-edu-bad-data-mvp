# InfluxDB 2.x Environment Variables Documentation

## Overview

This document provides comprehensive documentation for all environment variables used in the InfluxDB 2.x configuration for the Renewable Energy Monitoring System.

## Quick Start

1. **Copy the template**: `cp env.example .env`
2. **Modify values**: Edit `.env` file with your specific requirements
3. **Start services**: `docker-compose up -d`

## Environment Variables Reference

### Authentication & Access

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `INFLUXDB_ADMIN_USER` | `admin` | Admin username for InfluxDB | Yes |
| `INFLUXDB_ADMIN_PASSWORD` | `admin` | Admin password for InfluxDB | Yes |
| `INFLUXDB_ADMIN_TOKEN` | `renewable_energy_admin_token_123` | Initial admin token | Yes |
| `INFLUXDB_HTTP_AUTH_ENABLED` | `false` | Enable/disable authentication | No |

**Usage Examples:**
```bash
# Development (no authentication)
INFLUXDB_HTTP_AUTH_ENABLED=false

# Production (with authentication)
INFLUXDB_HTTP_AUTH_ENABLED=true
INFLUXDB_ADMIN_PASSWORD=your_strong_password_here
```

### Database Configuration

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `INFLUXDB_DB` | `renewable_energy` | Database name | Yes |
| `INFLUXDB_ORG` | `renewable_energy_org` | Organization name | Yes |
| `INFLUXDB_BUCKET` | `renewable_energy` | Default bucket name | Yes |
| `INFLUXDB_RETENTION` | `30d` | Data retention policy | No |

**Retention Policy Examples:**
```bash
# 30 days retention
INFLUXDB_RETENTION=30d

# 7 days retention
INFLUXDB_RETENTION=7d

# 1 year retention
INFLUXDB_RETENTION=1y

# Infinite retention
INFLUXDB_RETENTION=0
```

### Initial Setup

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `INFLUXDB_SETUP_MODE` | `setup` | Setup mode for initialization | No |
| `INFLUXDB_REPORTING_DISABLED` | `true` | Disable usage reporting | No |
| `INFLUXDB_META_DIR` | `/var/lib/influxdb2/meta` | Metadata directory | No |

**Setup Mode Options:**
- `setup`: First-time setup with initial user/org/bucket creation
- `upgrade`: Upgrade existing installation
- `skip`: Skip setup (for existing installations)

### Performance & Storage

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `INFLUXDB_DATA_DIR` | `/var/lib/influxdb2/data` | Data directory path | No |
| `INFLUXDB_WAL_DIR` | `/var/lib/influxdb2/wal` | Write-ahead log directory | No |
| `INFLUXDB_ENGINE_PATH` | `/var/lib/influxdb2/engine` | Storage engine path | No |
| `INFLUXDB_MAX_CONCURRENT_COMPACTIONS` | `0` | Compaction limit (0=unlimited) | No |

**Performance Tuning Examples:**
```bash
# Development (unlimited)
INFLUXDB_MAX_CONCURRENT_COMPACTIONS=0

# Production (limited)
INFLUXDB_MAX_CONCURRENT_COMPACTIONS=4
```

### HTTP Configuration

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `INFLUXDB_HTTP_BIND_ADDRESS` | `:8086` | HTTP bind address | No |
| `INFLUXDB_HTTP_PORT` | `8086` | HTTP port | No |
| `INFLUXDB_HTTP_MAX_CONNECTION_LIMIT` | `0` | Connection limit (0=unlimited) | No |
| `INFLUXDB_HTTP_READ_TIMEOUT` | `30s` | Read timeout | No |

**HTTP Configuration Examples:**
```bash
# Bind to all interfaces
INFLUXDB_HTTP_BIND_ADDRESS=:8086

# Bind to specific interface
INFLUXDB_HTTP_BIND_ADDRESS=192.168.1.100:8086

# Custom port
INFLUXDB_HTTP_PORT=9090
```

### Logging & Monitoring

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `INFLUXDB_LOGGING_LEVEL` | `info` | Log level | No |
| `INFLUXDB_LOGGING_FORMAT` | `auto` | Log format | No |
| `INFLUXDB_METRICS_DISABLED` | `true` | Disable internal metrics | No |
| `INFLUXDB_PPROF_ENABLED` | `false` | Enable profiling | No |

**Log Level Options:**
- `debug`: Detailed debug information
- `info`: General information (default)
- `warn`: Warning messages
- `error`: Error messages only

**Log Format Options:**
- `auto`: Automatic format detection
- `logfmt`: Logfmt format
- `json`: JSON format

## Docker Compose Integration

### Environment Section

The environment variables are integrated into the Docker Compose file:

```yaml
environment:
  # Time Zone
  - TZ=UTC
  
  # Authentication & Access
  - INFLUXDB_ADMIN_USER=${INFLUXDB_ADMIN_USER:-admin}
  - INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD:-admin}
  - INFLUXDB_ADMIN_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
  - INFLUXDB_HTTP_AUTH_ENABLED=${INFLUXDB_HTTP_AUTH_ENABLED:-false}
  
  # Database Configuration
  - INFLUXDB_DB=${INFLUXDB_DB:-renewable_energy}
  - INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
  - INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
  - INFLUXDB_RETENTION=${INFLUXDB_RETENTION:-30d}
  
  # ... additional variables
```

### Variable Substitution

Docker Compose supports variable substitution with default values:
- `${VARIABLE:-default}`: Use environment variable or default if not set
- `${VARIABLE}`: Use environment variable (fails if not set)

## Integration Variables

### Node-RED Integration

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_RED_INFLUXDB_URL` | `http://influxdb:8086` | InfluxDB URL for Node-RED |
| `NODE_RED_INFLUXDB_ORG` | `renewable_energy_org` | Organization for Node-RED |
| `NODE_RED_INFLUXDB_BUCKET` | `renewable_energy` | Bucket for Node-RED |
| `NODE_RED_INFLUXDB_TOKEN` | `renewable_energy_admin_token_123` | Token for Node-RED |

### Grafana Integration

| Variable | Default | Description |
|----------|---------|-------------|
| `GRAFANA_INFLUXDB_URL` | `http://influxdb:8086` | InfluxDB URL for Grafana |
| `GRAFANA_INFLUXDB_ORG` | `renewable_energy_org` | Organization for Grafana |
| `GRAFANA_INFLUXDB_BUCKET` | `renewable_energy` | Bucket for Grafana |
| `GRAFANA_INFLUXDB_TOKEN` | `renewable_energy_admin_token_123` | Token for Grafana |

## Environment-Specific Configurations

### Development Environment

```bash
# Development settings
INFLUXDB_HTTP_AUTH_ENABLED=false
INFLUXDB_LOGGING_LEVEL=debug
INFLUXDB_METRICS_DISABLED=true
INFLUXDB_PPROF_ENABLED=true
INFLUXDB_MAX_CONCURRENT_COMPACTIONS=0
INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=0
```

### Production Environment

```bash
# Production settings
INFLUXDB_HTTP_AUTH_ENABLED=true
INFLUXDB_LOGGING_LEVEL=warn
INFLUXDB_METRICS_DISABLED=false
INFLUXDB_PPROF_ENABLED=false
INFLUXDB_MAX_CONCURRENT_COMPACTIONS=4
INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=1000
INFLUXDB_HTTP_READ_TIMEOUT=60s
```

### Testing Environment

```bash
# Testing settings
INFLUXDB_HTTP_AUTH_ENABLED=false
INFLUXDB_LOGGING_LEVEL=info
INFLUXDB_RETENTION=1d
INFLUXDB_METRICS_DISABLED=true
```

## Security Considerations

### Development Security

- **Authentication disabled**: `INFLUXDB_HTTP_AUTH_ENABLED=false`
- **Unlimited access**: All limits set to 0 or unlimited
- **Debug logging**: Detailed logs for troubleshooting
- **No SSL/TLS**: Plain HTTP for local development

### Production Security

- **Authentication enabled**: `INFLUXDB_HTTP_AUTH_ENABLED=true`
- **Strong passwords**: Use complex, unique passwords
- **Token management**: Rotate tokens regularly
- **SSL/TLS**: Enable encryption for data transmission
- **Access limits**: Set appropriate connection and query limits
- **Audit logging**: Enable comprehensive logging

### Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use strong, unique passwords** for all accounts
3. **Rotate credentials regularly** (recommended: every 90 days)
4. **Enable authentication** in production environments
5. **Use SSL/TLS** for data transmission
6. **Implement proper access controls** and permissions
7. **Monitor and log** all authentication attempts
8. **Regular security updates** for all components

## Troubleshooting

### Common Issues

#### Connection Problems
```bash
# Check if InfluxDB is running
docker ps | grep influxdb

# Test HTTP endpoint
curl -f http://localhost:8086/health

# Check logs
docker logs iot-influxdb2
```

#### Authentication Issues
```bash
# Verify authentication settings
echo $INFLUXDB_HTTP_AUTH_ENABLED

# Test with credentials
curl -u admin:admin http://localhost:8086/health

# Check token validity
curl -H "Authorization: Token $INFLUXDB_ADMIN_TOKEN" http://localhost:8086/api/v2/orgs
```

#### Performance Issues
```bash
# Check resource usage
docker stats iot-influxdb2

# Monitor disk usage
du -sh ./influxdb/data

# Check query performance
influx query 'from(bucket:"renewable_energy") |> range(start: -1h) |> count()'
```

### Debug Commands

```bash
# Check environment variables
docker exec iot-influxdb2 env | grep INFLUXDB

# Verify configuration
docker exec iot-influxdb2 influx config

# Test database connectivity
docker exec iot-influxdb2 influx ping

# List buckets
docker exec iot-influxdb2 influx bucket list
```

## Migration from InfluxDB 3.x

### Key Differences

| InfluxDB 3.x | InfluxDB 2.x | Notes |
|--------------|--------------|-------|
| `influxdb:3-core` | `influxdb:2.7` | Different image |
| `--without-auth` | `INFLUXDB_HTTP_AUTH_ENABLED=false` | Different auth flag |
| `/api/v3/query_sql` | `/api/v2/query` | Different API endpoints |
| SQL queries | Flux queries | Different query language |
| Database/Table | Bucket/Measurement | Different data model |

### Migration Steps

1. **Update Docker image**: Change to `influxdb:2.7`
2. **Update environment variables**: Use InfluxDB 2.x variables
3. **Update API endpoints**: Change from v3 to v2
4. **Update query language**: Convert from SQL to Flux
5. **Update data model**: Convert from database/table to bucket/measurement

## Performance Optimization

### Memory Settings

```bash
# Optimize for time-series data
INFLUXDB_MAX_MEMORY_PER_QUERY=0
INFLUXDB_MAX_CONCURRENT_QUERIES=0
INFLUXDB_QUERY_TIMEOUT=0
```

### Storage Settings

```bash
# Optimize storage performance
INFLUXDB_MAX_CONCURRENT_COMPACTIONS=4
INFLUXDB_SERIES_ID_SET_CACHE_SIZE=100
INFLUXDB_MAX_INDEX_LOG_FILE_SIZE=1m
```

### Query Optimization

```bash
# Enable query logging
INFLUXDB_LOG_QUERIES_AFTER=0

# Set query limits
INFLUXDB_MAX_SELECT_POINT=0
INFLUXDB_MAX_SELECT_SERIES=0
INFLUXDB_MAX_SELECT_BUCKETS=0
```

## Monitoring and Alerting

### Health Checks

```bash
# Health check endpoint
curl -f http://localhost:8086/health

# Docker health check
docker inspect iot-influxdb2 | grep Health -A 10
```

### Metrics Collection

```bash
# Enable metrics (production)
INFLUXDB_METRICS_DISABLED=false

# Monitor system metrics
influx query 'from(bucket:"system_metrics") |> range(start: -1h)'
```

### Alerting Thresholds

```bash
# Disk usage threshold
ALERT_DISK_USAGE_THRESHOLD=80

# Memory usage threshold
ALERT_MEMORY_USAGE_THRESHOLD=85

# CPU usage threshold
ALERT_CPU_USAGE_THRESHOLD=90
```

## Backup and Recovery

### Backup Configuration

```bash
# Enable backups
BACKUP_ENABLED=true

# Backup retention
BACKUP_RETENTION_DAYS=30

# Backup schedule (cron format)
BACKUP_SCHEDULE="0 2 * * *"
```

### Backup Commands

```bash
# Manual backup
docker exec iot-influxdb2 influx backup /backups/$(date +%Y%m%d)

# Restore from backup
docker exec iot-influxdb2 influx restore /backups/20240101
```

## Support and Resources

### Documentation
- [InfluxDB 2.x Official Documentation](https://docs.influxdata.com/influxdb/v2.7/)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [InfluxDB Configuration Reference](https://docs.influxdata.com/influxdb/v2.7/administration/config/)

### Community Support
- [InfluxDB Community Forums](https://community.influxdata.com/)
- [GitHub Issues](https://github.com/influxdata/influxdb/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/influxdb)

### Version Information
- **InfluxDB Version**: 2.7
- **Documentation Version**: 1.0
- **Last Updated**: 2024-01-15
- **Compatibility**: Docker Compose, Node-RED, Grafana 