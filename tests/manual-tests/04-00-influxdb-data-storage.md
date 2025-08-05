# Manual Test 04: InfluxDB Data Storage

## Overview
This test verifies that InfluxDB 2.x is properly receiving, storing, and managing time-series data from the renewable energy monitoring system.

**🔍 What This Test Does:**
This test checks if InfluxDB (the database) is working correctly as the "warehouse" of your IoT system. Think of InfluxDB as a specialized storage facility designed specifically for time-series data - data that changes over time, like temperature readings, power output, or wind speed measurements.

**🏗️ Why This Matters:**
InfluxDB is where all your renewable energy data gets stored permanently. If InfluxDB isn't working:
- Data from devices gets lost
- You can't see historical trends
- Grafana dashboards won't show data
- The entire monitoring system becomes useless

## Technical Architecture Overview

### InfluxDB 2.x Architecture
InfluxDB 2.x is a purpose-built time-series database with the following architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    InfluxDB 2.x Architecture                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   HTTP API  │  │   Flux      │  │   Storage   │         │
│  │   (8086)    │  │   Query     │  │   Engine    │         │
│  │             │  │   Language  │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Metadata  │  │   Time      │  │   Index     │         │
│  │   Service   │  │   Series    │  │   Service   │         │
│  │             │  │   Database  │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   WAL       │  │   TSM       │  │   Compactor │         │
│  │   (Write    │  │   (Time     │  │   (Data     │         │
│  │   Ahead     │  │   Series    │  │   Compression)│       │
│  │   Log)      │  │   Merge)    │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Data Model and Schema Design
InfluxDB 2.x uses a flexible data model optimized for time-series data:

**Core Concepts:**
- **Organization**: Top-level container for users and resources
- **Bucket**: Container for time-series data (replaces databases in 1.x)
- **Measurement**: Logical grouping of related time-series data
- **Tag**: Indexed metadata for efficient querying
- **Field**: Actual time-series values (not indexed)
- **Timestamp**: Time when the data point was recorded

**Schema Design for Renewable Energy:**
```
Organization: renewable_energy_org
├── Bucket: renewable_energy_data
│   ├── Measurement: photovoltaic_data
│   │   ├── Tags: device_id, location, panel_type
│   │   └── Fields: power, voltage, current, temperature, efficiency
│   ├── Measurement: wind_turbine_data
│   │   ├── Tags: device_id, location, turbine_model
│   │   └── Fields: power, wind_speed, rpm, temperature, direction
│   ├── Measurement: energy_storage_data
│   │   ├── Tags: device_id, location, battery_type
│   │   └── Fields: soc, voltage, current, temperature, power
│   └── Measurement: system_metrics
│       ├── Tags: metric_type, location
│       └── Fields: value, status, alert_level
```

### Storage Engine and Performance
**Time-Structured Merge Tree (TSM):**
- **Write-Optimized**: Efficient writes for high-frequency data
- **Compression**: Automatic data compression to reduce storage
- **Query Optimization**: Fast queries on time ranges and tags
- **Retention Policies**: Automatic data lifecycle management

**Performance Characteristics:**
- **Write Throughput**: 100,000+ points per second
- **Query Performance**: Sub-second queries on large datasets
- **Compression Ratio**: 10:1 to 100:1 depending on data patterns
- **Storage Efficiency**: Optimized for time-series workloads

### Security Model
- **Token-Based Authentication**: API tokens for application access
- **User Management**: Role-based access control
- **Organization Isolation**: Data isolation between organizations
- **Network Security**: Optional TLS/SSL encryption

## Test Objective
Ensure InfluxDB 2.x is properly configured, receiving data, and can be queried for analysis.

**🎯 What We're Checking:**
- **Service Status**: Is InfluxDB running and healthy?
- **Database Schema**: Are buckets and measurements created correctly?
- **Data Writing**: Can Node-RED write data to InfluxDB?
- **Data Querying**: Can we retrieve and analyze stored data?
- **Performance**: How well does InfluxDB handle the data load?
- **Data Management**: Are retention policies and backups working?

## Prerequisites
- Manual Tests 01, 02, and 03 completed successfully
- InfluxDB 2.x running on localhost:8086
- Node-RED configured to write to InfluxDB
- PowerShell execution policy set to allow script execution
- Testing framework available in `tests/scripts/` directory

**📋 What These Prerequisites Mean:**
- **Tests 01-03**: All previous components are working
- **InfluxDB**: The database service must be running
- **Node-RED**: Must be configured to send data to InfluxDB
- **PowerShell**: Our testing environment

## InfluxDB 2.x Setup and Configuration

### Initial Setup Verification
**🔍 What This Does:**
Verifies that InfluxDB 2.x was properly initialized with the correct organization, bucket, and user setup.

**💡 Why This Matters:**
InfluxDB 2.x requires initial setup unlike version 1.x. The setup creates:
- **Organization**: Your company/project container
- **Bucket**: Where your time-series data is stored
- **Admin User**: Initial administrator account
- **API Token**: For applications to connect

**Command:**
```powershell
# Check if InfluxDB is properly initialized
docker exec iot-influxdb2 influx org list
docker exec iot-influxdb2 influx bucket list
docker exec iot-influxdb2 influx user list
```

**📋 Understanding the Commands:**
- `influx org list`: Shows all organizations in InfluxDB
- `influx bucket list`: Shows all data buckets
- `influx user list`: Shows all users

**Expected Result:**
- Organization `renewable_energy_org` exists
- Bucket `renewable_energy_data` exists
- Admin user exists
- No error messages

### API Token Verification
**🔍 What This Does:**
Verifies that the API token for Node-RED and other applications is properly configured.

**💡 Why This Matters:**
API tokens are like passwords for applications to connect to InfluxDB. Without a valid token, Node-RED can't write data to the database.

**Command:**
```powershell
# Check if API token is valid
$env:INFLUXDB_TOKEN = "your_token_here"
docker exec iot-influxdb2 influx ping
```

**Expected Result:**
- Connection successful
- No authentication errors
- Token is valid and working

## Automated Testing Framework

### Quick InfluxDB Validation
Before running manual tests, you can use the automated testing framework for quick validation:

```powershell
# Run comprehensive InfluxDB testing
.\tests\scripts\test-influxdb-health.ps1

# Run data flow test (includes InfluxDB validation)
.\tests\scripts\test-data-flow.ps1

# Run integration tests (includes InfluxDB connectivity)
.\tests\scripts\test-integration.ps1

# Run all tests
.\tests\run-all-tests.ps1
```

**🤖 What These Scripts Do:**
These automated scripts test InfluxDB functionality quickly and consistently. They verify connectivity, data writing, and querying capabilities.

### Test Framework Features
- **Health Checks**: Service status, connectivity, authentication
- **Data Flow**: End-to-end testing from MQTT to InfluxDB
- **Integration**: Cross-component connectivity validation
- **Performance**: Load testing and benchmarking

## Test Steps

### Step 1: Verify InfluxDB Service Status

#### 1.1 Check Service Health
**🔍 What This Does:**
Tests if InfluxDB is running and responding to health checks. This is like checking if the warehouse is open and ready to receive shipments.

**💡 Why This Matters:**
If InfluxDB isn't running:
- No data can be stored
- All queries will fail
- The entire monitoring system breaks down

**Command:**
```powershell
# Check InfluxDB health endpoint
Invoke-WebRequest -Uri http://localhost:8086/health -UseBasicParsing
```

**📋 Understanding the Command:**
- `Invoke-WebRequest`: PowerShell command to make an HTTP request
- `http://localhost:8086/health`: The health check URL for InfluxDB
- `localhost:8086`: The address where InfluxDB is running

**Expected Result:**
- Returns HTTP 200 OK
- JSON response indicating service is healthy
- No error messages

#### 1.2 Check Container Status
**🔍 What This Does:**
Verifies that the InfluxDB Docker container is running properly and has the correct configuration.

**Command:**
```powershell
# Check InfluxDB container status
docker-compose ps influxdb

# Check InfluxDB logs
docker-compose logs influxdb --tail=20
```

**📋 Understanding the Commands:**
- `docker-compose ps influxdb`: Shows the status of the InfluxDB container
- `docker-compose logs influxdb`: Shows recent log messages from InfluxDB

**Expected Result:**
- Container shows "Up (healthy)" status
- No error messages in logs
- Service started successfully

### Step 2: Test Database Schema and Buckets

#### 2.1 Verify Organization Setup
**🔍 What This Does:**
Checks that the InfluxDB organization is properly created and configured.

**💡 Why This Matters:**
Organizations in InfluxDB 2.x are like "companies" or "projects" that contain all your data. Without a proper organization, you can't store or query data.

**Command:**
```powershell
# List organizations
docker exec iot-influxdb2 influx org list
```

**📋 Understanding the Command:**
- `docker exec iot-influxdb2`: Runs a command inside the InfluxDB container
- `influx org list`: Lists all organizations in InfluxDB

**Expected Result:**
- Organization `renewable_energy_org` exists
- Organization ID is displayed
- No error messages

#### 2.2 Verify Bucket Setup
**🔍 What This Does:**
Checks that the data bucket is properly created and configured.

**💡 Why This Matters:**
Buckets in InfluxDB 2.x are like "folders" where your time-series data is stored. Without a bucket, there's nowhere to put your renewable energy data.

**Command:**
```powershell
# List buckets
docker exec iot-influxdb2 influx bucket list
```

**📋 Understanding the Command:**
- `influx bucket list`: Lists all buckets in InfluxDB

**Expected Result:**
- Bucket `renewable_energy_data` exists
- Bucket ID is displayed
- Retention policy is configured
- No error messages

#### 2.3 Verify User Setup
**🔍 What This Does:**
Checks that users are properly created and have the correct permissions.

**Command:**
```powershell
# List users
docker exec iot-influxdb2 influx user list
```

**Expected Result:**
- Admin user exists
- User permissions are correct
- No error messages

### Step 3: Test Data Writing

#### 3.1 Test Direct Data Writing
**🔍 What This Does:**
Tests if we can write data directly to InfluxDB using the command line. This verifies that the database is working correctly.

**💡 Why This Matters:**
This test ensures that:
- InfluxDB can accept data
- The bucket is writable
- Authentication is working
- Data format is correct

**Step 1: Create Test Bucket**
```powershell
# Create a new test bucket for this test
docker exec iot-influxdb2 influx bucket create -n renewable_energy_test -o renewable_energy_org -r 30d --token renewable_energy_admin_token_123
```

**Step 2: Write Test Data**
```powershell
# Write test data to the new test bucket
docker exec iot-influxdb2 influx write -b renewable_energy_test -o renewable_energy_org -p ns --token renewable_energy_admin_token_123 "test_measurement,device_id=test001,device_type=photovoltaic power=1500,voltage=48.5,current=30.9"
```

**📋 Understanding the Commands:**
- **Step 1**: Creates a new bucket called `renewable_energy_test` with 30-day retention
- **Step 2**: Writes test data to the new bucket
- `influx write`: Command to write data to InfluxDB
- `-b renewable_energy_test`: Target bucket name (newly created)
- `-o renewable_energy_org`: Organization name
- `-p ns`: Precision (nanoseconds)
- `--token renewable_energy_admin_token_123`: Authentication token
- The data string contains: measurement name, tags, and fields

**Expected Result:**
- Test bucket created successfully
- Data written successfully
- No error messages
- Data appears in the new test bucket

**Step 3: Cleanup (Optional)**
```powershell
# Remove the test bucket after testing (optional)
docker exec iot-influxdb2 influx bucket delete -n renewable_energy_test -o renewable_energy_org --token renewable_energy_admin_token_123
```

#### 3.2 Test Node-RED Data Writing
**🔍 What This Does:**
Tests if Node-RED can successfully write data to InfluxDB. This verifies the complete data flow from MQTT → Node-RED → InfluxDB.

**💡 Why This Matters:**
This is the real-world scenario - your renewable energy devices send data via MQTT, Node-RED processes it, and stores it in InfluxDB.

**Action:**
1. Send test messages through Node-RED flows
2. Check if data appears in InfluxDB
3. Verify data format and content

**📋 Understanding the Process:**
1. **MQTT Message**: Device sends data to MQTT broker
2. **Node-RED Processing**: Node-RED receives and processes the data
3. **InfluxDB Write**: Node-RED writes processed data to InfluxDB
4. **Verification**: Check that data appears in the database

**Expected Result:**
- Data flows from Node-RED to InfluxDB
- No write errors
- Data appears in correct measurements
- All fields and tags are present

### Step 4: Test Data Querying

#### 4.1 Test Basic Flux Queries
**🔍 What This Does:**
Tests if we can retrieve data from InfluxDB using Flux queries. Flux is InfluxDB's powerful query language.

**💡 Why This Matters:**
Querying data is essential for:
- **Monitoring**: Checking current system status
- **Analysis**: Understanding trends and patterns
- **Troubleshooting**: Investigating issues
- **Reporting**: Generating reports and dashboards

**Command:**
```powershell
# Query recent data from test measurement
docker exec iot-influxdb2 influx query -o renewable_energy_org --token renewable_energy_admin_token_123 "from(bucket: \"renewable_energy_test\") |> range(start: -1h) |> filter(fn: (r) => r._measurement == \"test_measurement\")"
```

**📋 Understanding the Command:**
- `influx query`: Command to execute Flux queries
- `-o renewable_energy_org`: Organization name
- `--token renewable_energy_admin_token_123`: Authentication token
- The Flux query:
  - `from(bucket: "renewable_energy_test")`: Select the test bucket
  - `|> range(start: -1h)`: Get data from the last hour
  - `|> filter(fn: (r) => r._measurement == "test_measurement")`: Filter to test measurement

**Expected Result:**
- Query executes successfully
- Data is returned in tabular format
- No error messages

#### 4.2 Test Advanced Flux Queries
**🔍 What This Does:**
Tests more complex queries that aggregate and analyze the data.

**Command:**
```powershell
# Query average power by device for the last hour
docker exec iot-influxdb2 influx query -o renewable_energy_org --token renewable_energy_admin_token_123 "from(bucket: \"renewable_energy_test\") |> range(start: -1h) |> filter(fn: (r) => r._field == \"power\") |> group(columns: [\"device_id\"]) |> mean()"

# Query total energy production for the last 24 hours
docker exec iot-influxdb2 influx query -o renewable_energy_org --token renewable_energy_admin_token_123 "from(bucket: \"renewable_energy_test\") |> range(start: -24h) |> filter(fn: (r) => r._field == \"power\") |> aggregateWindow(every: 1h, fn: mean) |> sum()"
```

**📋 Understanding the Queries:**
- **First Query**: Calculates average power for each device
- **Second Query**: Calculates total energy production over 24 hours

**Expected Result:**
- Queries execute successfully
- Aggregated results are returned
- Calculations are accurate

#### 4.3 Test Data Validation Queries
**🔍 What This Does:**
Tests queries that validate data quality and completeness.

**Command:**
```powershell
# Check for missing data points
docker exec iot-influxdb2 influx query -o renewable_energy_org --token renewable_energy_admin_token_123 "from(bucket: \"renewable_energy_test\") |> range(start: -1h) |> filter(fn: (r) => r._field == \"power\") |> aggregateWindow(every: 5m, fn: count) |> filter(fn: (r) => r._value < 1)"

# Check for out-of-range values
docker exec iot-influxdb2 influx query -o renewable_energy_org --token renewable_energy_admin_token_123 "from(bucket: \"renewable_energy_test\") |> range(start: -1h) |> filter(fn: (r) => r._field == \"power\" and r._value > 10000)"
```

**Expected Result:**
- Data quality issues are identified
- Out-of-range values are detected
- Missing data points are found

### Step 5: Test Performance and Load

#### 5.1 Test Write Performance
**🔍 What This Does:**
Tests how quickly InfluxDB can write data. This is important for high-frequency data from renewable energy devices.

**💡 Why This Matters:**
Solar panels and wind turbines can send data every few seconds. InfluxDB must handle this write load efficiently.

**Command:**
```powershell
# Test write performance with multiple data points
for ($i = 1; $i -le 1000; $i++) {
    $timestamp = [DateTimeOffset]::Now.AddSeconds($i).ToUnixTimeSeconds()
    docker exec iot-influxdb2 influx write -b renewable_energy_test -o renewable_energy_org -p s --token renewable_energy_admin_token_123 "performance_test,device_id=test001 power=$i,voltage=48.5,current=30.9 $timestamp"
}
```

**📋 Understanding the Command:**
- Writes 1000 data points with timestamps
- Measures how quickly InfluxDB can handle the writes
- Tests system performance under load

**Expected Result:**
- All writes complete successfully
- No performance degradation
- Write throughput is acceptable

#### 5.2 Test Query Performance
**🔍 What This Does:**
Tests how quickly InfluxDB can retrieve and process data.

**Command:**
```powershell
# Test query performance on large dataset
docker exec iot-influxdb2 influx query -o renewable_energy_org --token renewable_energy_admin_token_123 "from(bucket: \"renewable_energy_test\") |> range(start: -24h) |> filter(fn: (r) => r._field == \"power\") |> aggregateWindow(every: 1h, fn: mean)"
```

**Expected Result:**
- Query completes within reasonable time
- No timeout errors
- Performance is acceptable for dashboard queries

### Step 6: Test Data Retention and Management

#### 6.1 Verify Retention Policies
**🔍 What This Does:**
Tests that data retention policies are working correctly. Retention policies automatically delete old data to manage storage.

**💡 Why This Matters:**
Time-series data can grow very large. Retention policies help:
- **Manage Storage**: Prevent unlimited data growth
- **Control Costs**: Reduce storage requirements
- **Maintain Performance**: Keep queries fast
- **Compliance**: Meet data retention requirements

**Command:**
```powershell
# Check retention policies
docker exec iot-influxdb2 influx bucket list
```

**Expected Result:**
- Retention policies are configured
- Data older than retention period is automatically deleted
- Storage usage is managed

#### 6.2 Test Data Backup
**🔍 What This Does:**
Tests that data can be backed up and restored if needed.

**Command:**
```powershell
# Create backup of InfluxDB data
docker exec iot-influxdb2 influx backup /tmp/backup -o renewable_energy_org
```

**Expected Result:**
- Backup completes successfully
- Backup files are created
- No error messages

## Advanced Technical Testing

### Flux Query Optimization
Test and optimize Flux queries for better performance:

```flux
// Optimized query with proper filtering
from(bucket: "renewable_energy_data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "power")
  |> aggregateWindow(every: 5m, fn: mean)
  |> yield(name: "mean_power")
```

### Continuous Queries
Test continuous queries for real-time aggregations:

```flux
// Continuous query for hourly power averages
option task = {
    name: "hourly_power_averages",
    every: 1h,
    offset: 0m
}

from(bucket: "renewable_energy_data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power")
  |> aggregateWindow(every: 1h, fn: mean)
  |> to(bucket: "renewable_energy_aggregated")
```

### Data Compression Analysis
Analyze data compression efficiency:

```powershell
# Check data compression statistics
docker exec iot-influxdb2 influx query -o renewable_energy_org "
from(bucket: \"_monitoring\")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == \"influxdb_tsm1_engine\")
  |> filter(fn: (r) => r._field =~ /.*compression.*/)
"
```

### Performance Benchmarking
Benchmark InfluxDB performance metrics:

```powershell
# Benchmark write performance
$startTime = Get-Date
for ($i = 1; $i -le 10000; $i++) {
    docker exec iot-influxdb2 influx write -b renewable_energy_data -o renewable_energy_org -p ns "benchmark_test,device_id=test001 value=$i"
}
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Write performance: $($duration.TotalSeconds) seconds for 10000 points"
```

## Professional Best Practices

### Schema Design Best Practices
- **Tag Strategy**: Use tags for high-cardinality data that you'll filter on
- **Field Strategy**: Use fields for actual measurements and low-cardinality data
- **Measurement Design**: Group related time-series in the same measurement
- **Naming Conventions**: Use consistent naming for measurements, tags, and fields
- **Data Types**: Choose appropriate data types for fields

### Performance Optimization
- **Indexing Strategy**: Use tags efficiently for fast queries
- **Query Optimization**: Write efficient Flux queries with proper filtering
- **Batch Writes**: Batch multiple data points in single write operations
- **Compression**: Monitor and optimize data compression
- **Retention Policies**: Configure appropriate retention policies

### Security Best Practices
- **Token Management**: Use least-privilege tokens for different applications
- **Network Security**: Implement TLS/SSL for production deployments
- **Access Control**: Use proper user roles and permissions
- **Audit Logging**: Enable audit logging for security monitoring
- **Regular Updates**: Keep InfluxDB updated with security patches

### Monitoring and Alerting
- **Health Monitoring**: Monitor InfluxDB service health and performance
- **Resource Monitoring**: Track CPU, memory, and disk usage
- **Query Performance**: Monitor slow queries and optimize them
- **Error Alerting**: Set up alerts for database errors and failures
- **Capacity Planning**: Monitor storage growth and plan for expansion

### Backup and Recovery
- **Regular Backups**: Implement automated backup procedures
- **Backup Testing**: Regularly test backup and recovery procedures
- **Disaster Recovery**: Have disaster recovery procedures documented
- **Data Validation**: Validate backup integrity
- **Recovery Testing**: Test recovery procedures regularly

## Test Results Documentation

### Pass Criteria
- InfluxDB service is healthy and responding
- Organization and bucket are properly configured
- Data can be written successfully
- Data can be queried and retrieved
- Performance is acceptable under load
- Retention policies are working
- Backup procedures are functional

### Fail Criteria
- InfluxDB service is not responding
- Organization or bucket configuration issues
- Data writing failures
- Query execution errors
- Performance issues under load
- Retention policy failures
- Backup procedure failures

## Troubleshooting

### Common Issues

#### 1. InfluxDB Service Not Responding
**Problem:** Health check fails or service not accessible
**🔍 What This Means:** InfluxDB might not be running or there's a configuration issue.

**Solution:**
```powershell
# Check container status
docker-compose ps influxdb

# Check InfluxDB logs
docker-compose logs influxdb

# Restart InfluxDB
docker-compose restart influxdb
```

#### 2. Authentication Failures
**Problem:** API token not working or authentication errors
**🔍 What This Means:** The API token might be invalid or expired.

**Solution:**
```powershell
# Check token validity
docker exec iot-influxdb2 influx ping

# Generate new token if needed
docker exec iot-influxdb2 influx auth create --org renewable_energy_org --user admin
```

#### 3. Data Writing Failures
**Problem:** Can't write data to InfluxDB
**🔍 What This Means:** There might be permission issues or bucket problems.

**Solution:**
```powershell
# Check bucket permissions
docker exec iot-influxdb2 influx bucket list

# Check organization access
docker exec iot-influxdb2 influx org list
```

#### 4. Query Performance Issues
**Problem:** Queries are slow or timeout
**🔍 What This Means:** The queries might be inefficient or the system is overloaded.

**Solution:**
```powershell
# Check system resources
docker stats iot-influxdb2

# Optimize queries with proper filtering
# Use appropriate time ranges
# Add proper indexes via tags
```

#### 5. Storage Issues
**Problem:** Disk space issues or data corruption
**🔍 What This Means:** Storage might be full or data might be corrupted.

**Solution:**
```powershell
# Check disk usage
docker exec iot-influxdb2 df -h

# Check data integrity
docker exec iot-influxdb2 influx query -o renewable_energy_org "from(bucket: \"renewable_energy_data\") |> range(start: -1h) |> limit(n: 1)"
```

## Next Steps
If all InfluxDB tests pass, proceed to:
- [Manual Test 05: Grafana Data Visualization](./05-grafana-data-visualization.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ InfluxDB service healthy
□ Organization and bucket configured
□ Data writing successful
□ Data querying functional
□ Performance acceptable
□ Retention policies working
□ Backup procedures functional

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 