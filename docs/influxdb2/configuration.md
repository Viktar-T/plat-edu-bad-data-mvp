# InfluxDB 2.x Configuration Reference

## Overview

This document provides a comprehensive reference for all InfluxDB 2.x configuration options in the renewable energy monitoring system. It covers environment variables, configuration files, and system settings.

## Environment Variables

### Authentication & Access

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `INFLUXDB_ADMIN_USER` | `admin` | Admin username for InfluxDB |
| `INFLUXDB_ADMIN_PASSWORD` | `admin_password_123` | Admin password for InfluxDB |
| `INFLUXDB_ADMIN_TOKEN` | `renewable_energy_admin_token_123` | Admin token for API access |
| `INFLUXDB_HTTP_AUTH_ENABLED` | `false` | Enable/disable HTTP authentication |

### Database Configuration

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `INFLUXDB_DB` | `renewable_energy` | Main database name |
| `INFLUXDB_ORG` | `renewable_energy_org` | Organization name |
| `INFLUXDB_BUCKET` | `renewable_energy` | Default bucket name |
| `INFLUXDB_RETENTION` | `30d` | Data retention policy duration |

### Initial Setup

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `INFLUXDB_SETUP_MODE` | `setup` | Initialization mode |
| `INFLUXDB_REPORTING_DISABLED` | `true` | Disable usage reporting |
| `INFLUXDB_META_DIR` | `/var/lib/influxdb2/meta` | Metadata directory path |

### Performance & Storage

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `INFLUXDB_DATA_DIR` | `/var/lib/influxdb2/data` | Data directory path |
| `INFLUXDB_WAL_DIR` | `/var/lib/influxdb2/wal` | Write-ahead log directory |
| `INFLUXDB_ENGINE_PATH` | `/var/lib/influxdb2/engine` | Storage engine path |
| `INFLUXDB_MAX_CONCURRENT_COMPACTIONS` | `0` | Compaction limit (0 = unlimited) |

### HTTP Configuration

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `INFLUXDB_HTTP_BIND_ADDRESS` | `:8086` | HTTP bind address |
| `INFLUXDB_HTTP_PORT` | `8086` | HTTP port |
| `INFLUXDB_HTTP_MAX_CONNECTION_LIMIT` | `0` | Connection limit (0 = unlimited) |
| `INFLUXDB_HTTP_READ_TIMEOUT` | `30s` | Read timeout |

### Logging & Monitoring

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `INFLUXDB_LOGGING_LEVEL` | `info` | Log level (debug, info, warn, error) |
| `INFLUXDB_LOGGING_FORMAT` | `auto` | Log format (auto, logfmt, json) |
| `INFLUXDB_METRICS_DISABLED` | `true` | Disable internal metrics |
| `INFLUXDB_PPROF_ENABLED` | `false` | Enable profiling |

## Configuration Files

### influxdb.conf

Main InfluxDB configuration file located at `influxdb/config/influxdb.conf`:

```ini
[meta]
  dir = "/var/lib/influxdb2/meta"
  bind-address = ":8089"
  http-bind-address = ":8091"
  http-auth-enabled = false
  http-log-enabled = true
  http-log-path = "/var/log/influxdb/meta.log"
  http-log-level = "info"

[data]
  dir = "/var/lib/influxdb2/data"
  wal-dir = "/var/lib/influxdb2/wal"
  series-id-set-cache-size = 100
  series-file-max-concurrent-snapshot-compactions = 0
  max-concurrent-compactions = 0
  max-index-log-file-size = 1m
  max-series-per-database = 1000000
  max-values-per-tag = 100000
  max-memory-per-query = 0
  max-memory-per-query-unlimited = true
  max-concurrent-queries = 0
  max-concurrent-queries-unlimited = true
  query-timeout = 0
  query-timeout-unlimited = true
  log-queries-after = 0
  log-queries-after-unlimited = true
  max-select-point = 0
  max-select-point-unlimited = true
  max-select-series = 0
  max-select-series-unlimited = true
  max-select-buckets = 0
  max-select-buckets-unlimited = true

[http]
  enabled = true
  bind-address = ":8086"
  auth-enabled = false
  log-enabled = true
  log-access-path = "/var/log/influxdb/access.log"
  log-access-format = "auto"
  access-log-path = "/var/log/influxdb/access.log"
  access-log-status-filters = []
  access-log-format = "auto"
  suppress-write-log = false
  write-tracing = false
  pprof-enabled = false
  pprof-auth-enabled = false
  pprof-bind-address = ":6060"
  debug-pprof-enabled = false
  debug-pprof-bind-address = ":6060"
  ping-auth-enabled = false
  prom-read-auth-enabled = false
  max-body-size = 25000000
  max-concurrent-write-limit = 0
  max-enqueued-write-limit = 0
  enqueued-write-timeout = 30000000000
  max-concurrent-write-limit-unlimited = true
  max-enqueued-write-limit-unlimited = true

[logging]
  level = "info"
  format = "auto"
  suppress-logo = false

[subscriber]
  enabled = true
  http-timeout = "30s"
  insecure-skip-verify = false
  ca-certs = ""
  write-concurrency = 40
  write-buffer-size = 1000

[monitoring]
  enabled = false
  write-interval = "10s"

[reporting]
  enabled = false
  url = "https://usage.influxdata.com"
  token = ""
  org = ""
  bucket = ""
  interval = "12h"

[udp]
  enabled = false
  bind-address = ":8089"
  database = ""
  retention-policy = ""
  batch-size = 5000
  batch-pending = 10
  batch-timeout = "1s"
  read-buffer = 0
  precision = ""

[continuous_queries]
  enabled = true
  log-enabled = true
  run-interval = "1s"
  max-processes = 0
  max-processes-unlimited = true

[tls]
  enabled = false
  cert = ""
  key = ""
  min-version = ""
  max-version = ""
  ciphers = []
  prefer-server-ciphers = false
  curve-preferences = []
  hsts = false
  hsts-max-age = 0
```

### influxdb.yaml

YAML configuration file located at `influxdb/config/influxdb.yaml`:

```yaml
# Server configuration
server:
  # HTTP server settings
  http:
    enabled: true
    bind-address: ":8086"
    auth-enabled: false
    log-enabled: true
    access-log-path: "/var/log/influxdb/access.log"
    access-log-format: "auto"
    max-body-size: 25000000
    max-concurrent-write-limit: 0
    max-enqueued-write-limit: 0
    enqueued-write-timeout: 30000000000
    pprof-enabled: false
    pprof-bind-address: ":6060"
    debug-pprof-enabled: false
    debug-pprof-bind-address: ":6060"
    ping-auth-enabled: false
    prom-read-auth-enabled: false

# Data storage configuration
storage:
  # Data directory
  data-dir: "/var/lib/influxdb2/data"
  # Write-ahead log directory
  wal-dir: "/var/lib/influxdb2/wal"
  # Meta directory
  meta-dir: "/var/lib/influxdb2/meta"
  
  # Performance settings
  series-id-set-cache-size: 100
  series-file-max-concurrent-snapshot-compactions: 0
  max-concurrent-compactions: 0
  max-index-log-file-size: "1m"
  max-series-per-database: 1000000
  max-values-per-tag: 100000
  
  # Query settings
  max-memory-per-query: 0
  max-concurrent-queries: 0
  query-timeout: 0
  log-queries-after: 0
  max-select-point: 0
  max-select-series: 0
  max-select-buckets: 0

# Logging configuration
logging:
  level: "info"
  format: "auto"
  suppress-logo: false

# Monitoring configuration
monitoring:
  enabled: false
  write-interval: "10s"

# Reporting configuration
reporting:
  enabled: false
  url: "https://usage.influxdb.com"
  token: ""
  org: ""
  bucket: ""
  interval: "12h"

# Subscriber configuration
subscriber:
  enabled: true
  http-timeout: "30s"
  insecure-skip-verify: false
  ca-certs: ""
  write-concurrency: 40
  write-buffer-size: 1000

# Continuous queries configuration
continuous_queries:
  enabled: true
  log-enabled: true
  run-interval: "1s"
  max-processes: 0

# TLS configuration (disabled for development)
tls:
  enabled: false
  cert: ""
  key: ""
  min-version: ""
  max-version: ""
  ciphers: []
  prefer-server-ciphers: false
  curve-preferences: []
  hsts: false
  hsts-max-age: 0

# UDP configuration (disabled for this setup)
udp:
  enabled: false
  bind-address: ":8089"
  database: ""
  retention-policy: ""
  batch-size: 5000
  batch-pending: 10
  batch-timeout: "1s"
  read-buffer: 0
  precision: ""
```

### influx-configs

CLI configuration file located at `influxdb/config/influx-configs`:

```ini
[default]
  url = "http://localhost:8086"
  token = "renewable_energy_admin_token_123"
  org = "renewable_energy_org"
  active = true

# Additional configurations for different environments
# [eu-central]
#   url = "https://eu-central-1-1.aws.cloud2.influxdata.com"
#   token = "XXX"
#   org = ""

# [us-central]
#   url = "https://us-central1-1.gcp.cloud2.influxdata.com"
#   token = "XXX"
#   org = ""

# [us-west]
#   url = "https://us-west-2-1.aws.cloud2.influxdata.com"
#   token = "XXX"
#   org = ""
```

## Docker Compose Configuration

### InfluxDB Service

```yaml
influxdb:
  image: influxdb:2.7
  container_name: iot-influxdb2
  ports:
    - "8086:8086"
  volumes:
    - ./influxdb/data:/var/lib/influxdb2
    - ./influxdb/config:/etc/influxdb2
    - ./influxdb/backups:/backups
  environment:
    # Time Zone
    - TZ=UTC
    
    # Authentication & Access
    - INFLUXDB_ADMIN_USER=${INFLUXDB_ADMIN_USER:-admin}
    - INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD:-admin_password_123}
    - INFLUXDB_ADMIN_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
    - INFLUXDB_HTTP_AUTH_ENABLED=${INFLUXDB_HTTP_AUTH_ENABLED:-false}
    
    # Database Configuration
    - INFLUXDB_DB=${INFLUXDB_DB:-renewable_energy}
    - INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
    - INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
    - INFLUXDB_RETENTION=${INFLUXDB_RETENTION:-30d}
    
    # Initial Setup
    - DOCKER_INFLUXDB_INIT_MODE=${INFLUXDB_SETUP_MODE:-setup}
    - DOCKER_INFLUXDB_INIT_USERNAME=${INFLUXDB_ADMIN_USER:-admin}
    - DOCKER_INFLUXDB_INIT_PASSWORD=${INFLUXDB_ADMIN_PASSWORD:-admin_password_123}
    - DOCKER_INFLUXDB_INIT_ORG=${INFLUXDB_ORG:-renewable_energy_org}
    - DOCKER_INFLUXDB_INIT_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
    - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
    - DOCKER_INFLUXDB_INIT_RETENTION=${INFLUXDB_RETENTION:-30d}
    - INFLUXDB_REPORTING_DISABLED=${INFLUXDB_REPORTING_DISABLED:-true}
    - INFLUXDB_META_DIR=${INFLUXDB_META_DIR:-/var/lib/influxdb2/meta}
    
    # Performance & Storage
    - INFLUXDB_DATA_DIR=${INFLUXDB_DATA_DIR:-/var/lib/influxdb2/data}
    - INFLUXDB_WAL_DIR=${INFLUXDB_WAL_DIR:-/var/lib/influxdb2/wal}
    - INFLUXDB_ENGINE_PATH=${INFLUXDB_ENGINE_PATH:-/var/lib/influxdb2/engine}
    - INFLUXDB_MAX_CONCURRENT_COMPACTIONS=${INFLUXDB_MAX_CONCURRENT_COMPACTIONS:-0}
    
    # HTTP Configuration
    - INFLUXDB_HTTP_BIND_ADDRESS=${INFLUXDB_HTTP_BIND_ADDRESS:-:8086}
    - INFLUXDB_HTTP_PORT=${INFLUXDB_HTTP_PORT:-8086}
    - INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=${INFLUXDB_HTTP_MAX_CONNECTION_LIMIT:-0}
    - INFLUXDB_HTTP_READ_TIMEOUT=${INFLUXDB_HTTP_READ_TIMEOUT:-30s}
    
    # Logging & Monitoring
    - INFLUXDB_LOGGING_LEVEL=${INFLUXDB_LOGGING_LEVEL:-info}
    - INFLUXDB_LOGGING_FORMAT=${INFLUXDB_LOGGING_FORMAT:-auto}
    - INFLUXDB_METRICS_DISABLED=${INFLUXDB_METRICS_DISABLED:-true}
    - INFLUXDB_PPROF_ENABLED=${INFLUXDB_PPROF_ENABLED:-false}
  restart: unless-stopped
  healthcheck:
    test: ["CMD-SHELL", "curl -f http://localhost:8086/health || exit 1"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 60s
  networks:
    - iot-network
```

## Bucket Configuration

### Default Buckets

| Bucket Name | Retention | Purpose |
|-------------|-----------|---------|
| `renewable_energy` | 30 days | Main device data |
| `system_metrics` | 7 days | System performance data |
| `alerts` | 90 days | Alert and notification data |
| `analytics` | 365 days | Long-term analytics data |

### Bucket Creation Commands

```bash
# Create main bucket
influx bucket create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --name "renewable_energy" --retention "30d"

# Create system metrics bucket
influx bucket create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --name "system_metrics" --retention "7d"

# Create alerts bucket
influx bucket create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --name "alerts" --retention "90d"

# Create analytics bucket
influx bucket create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --name "analytics" --retention "365d"
```

## User and Token Configuration

### Default Users

| User | Role | Token | Permissions |
|------|------|-------|-------------|
| `admin` | Admin | `renewable_energy_admin_token_123` | Full access |
| `dashboard_user` | Read-only | `dashboard_token_123` | Read access to all buckets |
| `ingestion_user` | Write-only | `ingestion_token_123` | Write access to renewable_energy |
| `analytics_user` | Read-write | `analytics_token_123` | Read renewable_energy, write analytics |

### User Creation Commands

```bash
# Create dashboard user
influx user create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --name "dashboard_user" --password "dashboard_password_123"

# Create ingestion user
influx user create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --name "ingestion_user" --password "ingestion_password_123"

# Create analytics user
influx user create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --name "analytics_user" --password "analytics_password_123"
```

### Token Creation Commands

```bash
# Create dashboard token (read-only)
influx auth create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --user "dashboard_user" \
  --read-bucket "renewable_energy" --read-bucket "system_metrics" \
  --read-bucket "alerts" --read-bucket "analytics"

# Create ingestion token (write-only)
influx auth create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --user "ingestion_user" \
  --write-bucket "renewable_energy"

# Create analytics token (read-write)
influx auth create --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --user "analytics_user" \
  --read-bucket "renewable_energy" --write-bucket "analytics"
```

## Performance Configuration

### Memory Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `max-memory-per-query` | 0 (unlimited) | Maximum memory per query |
| `series-id-set-cache-size` | 100 | Series ID cache size |
| `max-concurrent-queries` | 0 (unlimited) | Maximum concurrent queries |
| `max-concurrent-compactions` | 0 (unlimited) | Maximum concurrent compactions |

### Storage Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `max-series-per-database` | 1,000,000 | Maximum series per database |
| `max-values-per-tag` | 100,000 | Maximum values per tag |
| `max-index-log-file-size` | 1MB | Maximum index log file size |
| `series-file-max-concurrent-snapshot-compactions` | 0 | Snapshot compaction limit |

### HTTP Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `max-body-size` | 25MB | Maximum request body size |
| `max-concurrent-write-limit` | 0 (unlimited) | Maximum concurrent writes |
| `max-enqueued-write-limit` | 0 (unlimited) | Maximum enqueued writes |
| `enqueued-write-timeout` | 30s | Write timeout |

## Security Configuration

### Authentication Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `http-auth-enabled` | false | Enable HTTP authentication |
| `ping-auth-enabled` | false | Enable ping authentication |
| `prom-read-auth-enabled` | false | Enable Prometheus read auth |

### TLS Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `enabled` | false | Enable TLS encryption |
| `cert` | "" | TLS certificate path |
| `key` | "" | TLS private key path |
| `min-version` | "" | Minimum TLS version |
| `max-version` | "" | Maximum TLS version |

## Monitoring Configuration

### Health Checks

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:8086/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 60s
```

### Logging Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `level` | info | Log level (debug, info, warn, error) |
| `format` | auto | Log format (auto, logfmt, json) |
| `suppress-logo` | false | Suppress InfluxDB logo |

### Metrics Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `enabled` | false | Enable internal metrics |
| `write-interval` | 10s | Metrics write interval |
| `metrics-disabled` | true | Disable metrics collection |

## Backup Configuration

### Backup Directory

```yaml
volumes:
  - ./influxdb/backups:/backups
```

### Backup Commands

```bash
# Create backup
influx backup --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --bucket "renewable_energy" /backups/backup_$(date +%Y%m%d_%H%M%S)

# Restore backup
influx restore --host "http://localhost:8086" --token "renewable_energy_admin_token_123" \
  --org "renewable_energy_org" --bucket "renewable_energy" /backups/backup_20240115_120000
```

## Configuration Validation

### Validation Commands

```bash
# Validate configuration
influx ping --host "http://localhost:8086" --token "renewable_energy_admin_token_123"

# Check organization
influx org list --host "http://localhost:8086" --token "renewable_energy_admin_token_123"

# Check buckets
influx bucket list --host "http://localhost:8086" --token "renewable_energy_admin_token_123" --org "renewable_energy_org"

# Check users
influx user list --host "http://localhost:8086" --token "renewable_energy_admin_token_123"

# Check tokens
influx auth list --host "http://localhost:8086" --token "renewable_energy_admin_token_123" --org "renewable_energy_org"
```

---

**Last Updated**: January 2024  
**Version**: 2.7  
**Status**: Production Ready 