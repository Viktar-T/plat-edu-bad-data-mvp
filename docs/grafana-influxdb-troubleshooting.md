# Grafana-InfluxDB Connection Troubleshooting Guide

## Overview

This guide helps you diagnose and fix issues with Grafana not displaying data from InfluxDB 2.x in the Renewable Energy IoT Monitoring System.

## Quick Diagnostic

Run the diagnostic script to identify issues:

```powershell
# Windows PowerShell
.\scripts\diagnose-grafana-influxdb.ps1

# Linux/Mac
./scripts/diagnose-grafana-influxdb.sh
```

## Common Issues and Solutions

### 1. Containers Not Running

**Symptoms:**
- Grafana shows "No data" or connection errors
- InfluxDB queries return empty results

**Diagnosis:**
```powershell
docker ps
```

**Solution:**
```powershell
# Start all services
docker-compose up -d

# Or restart specific containers
docker restart iot-influxdb2
docker restart iot-grafana
docker restart iot-node-red
```

### 2. InfluxDB Authentication Issues

**Symptoms:**
- Grafana shows "401 Unauthorized" errors
- Data source test fails

**Diagnosis:**
Check if authentication is enabled in your `.env` file:
```
INFLUXDB_HTTP_AUTH_ENABLED=false  # Development mode
```

**Solution:**
```powershell
# For development, ensure authentication is disabled
echo "INFLUXDB_HTTP_AUTH_ENABLED=false" >> .env

# Restart InfluxDB
docker restart iot-influxdb2
```

### 3. Incorrect Data Source Configuration

**Symptoms:**
- Grafana shows "Data source not found" errors
- Wrong organization or bucket names

**Diagnosis:**
Check the data source configuration in Grafana:
1. Go to http://localhost:3000
2. Navigate to Configuration → Data Sources
3. Check the InfluxDB data source settings

**Solution:**
Run the automatic fix script:
```powershell
.\scripts\fix-grafana-influxdb.ps1
```

**Manual Fix:**
1. In Grafana, go to Configuration → Data Sources
2. Edit the InfluxDB data source
3. Verify these settings:
   - **URL:** `http://influxdb:8086`
   - **Organization:** `renewable_energy_org`
   - **Default Bucket:** `renewable_energy`
   - **Token:** `renewable_energy_admin_token_123`

### 4. No Data in InfluxDB

**Symptoms:**
- InfluxDB queries return empty results
- Node-RED flows are not sending data

**Diagnosis:**
```powershell
# Check if data exists in InfluxDB
curl "http://localhost:8086/query?org=renewable_energy_org&q=from(bucket:\"renewable_energy\")|>range(start:-1h)|>count()" \
  -H "Authorization: Token renewable_energy_admin_token_123"
```

**Solution:**
1. Check Node-RED flows at http://localhost:1880
2. Ensure flows are deployed and running
3. Check MQTT connections
4. Restart Node-RED if needed:
   ```powershell
   docker restart iot-node-red
   ```

### 5. Network Connectivity Issues

**Symptoms:**
- Grafana cannot reach InfluxDB
- Connection timeouts

**Diagnosis:**
```powershell
# Test connectivity from Grafana container
docker exec iot-grafana curl -f http://influxdb:8086/health

# Test from host
curl -f http://localhost:8086/health
```

**Solution:**
1. Ensure all containers are on the same network:
   ```powershell
   docker network ls
   docker network inspect iot-network
   ```

2. Check container logs:
   ```powershell
   docker logs iot-grafana
   docker logs iot-influxdb2
   ```

### 6. Time Range Issues

**Symptoms:**
- Dashboards show no data despite data existing
- Wrong time zone settings

**Diagnosis:**
1. Check the time range in Grafana dashboards
2. Verify time zone settings

**Solution:**
1. Adjust the time range in Grafana (top-right corner)
2. Try "Last 1 hour" or "Last 24 hours"
3. Check if data exists for the selected time range

### 7. Bucket/Organization Mismatch

**Symptoms:**
- "Bucket not found" errors
- "Organization not found" errors

**Diagnosis:**
Check the exact bucket and organization names:
```powershell
# List buckets
curl "http://localhost:8086/api/v2/buckets?org=renewable_energy_org" \
  -H "Authorization: Token renewable_energy_admin_token_123"

# List organizations
curl "http://localhost:8086/api/v2/orgs" \
  -H "Authorization: Token renewable_energy_admin_token_123"
```

**Solution:**
Update the data source configuration with correct names:
- **Organization:** `renewable_energy_org`
- **Bucket:** `renewable_energy`

### 8. Token Issues

**Symptoms:**
- "Invalid token" errors
- Authentication failures

**Diagnosis:**
Verify the token is correct:
```powershell
# Check token in environment
echo $env:INFLUXDB_ADMIN_TOKEN
# Should be: renewable_energy_admin_token_123
```

**Solution:**
1. Ensure the token is consistent across all configurations
2. Check the token in:
   - `.env` file
   - Grafana data source configuration
   - Node-RED InfluxDB node configuration

## Step-by-Step Troubleshooting

### Step 1: Verify Container Status
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected output:
```
NAMES           STATUS          PORTS
iot-mosquitto   Up 2 minutes    0.0.0.0:1883->1883/tcp, 0.0.0.0:9001->9001/tcp
iot-influxdb2   Up 2 minutes    0.0.0.0:8086->8086/tcp
iot-node-red    Up 2 minutes    0.0.0.0:1880->1880/tcp
iot-grafana     Up 2 minutes    0.0.0.0:3000->3000/tcp
```

### Step 2: Check Service Health
```powershell
# InfluxDB
curl -f http://localhost:8086/health

# Grafana
curl -f http://localhost:3000/api/health

# Node-RED
curl -f http://localhost:1880
```

### Step 3: Verify Data Flow
```powershell
# Check if data exists in InfluxDB
curl "http://localhost:8086/query?org=renewable_energy_org&q=from(bucket:\"renewable_energy\")|>range(start:-1h)|>limit(n:1)" \
  -H "Authorization: Token renewable_energy_admin_token_123"
```

### Step 4: Test Grafana Data Source
1. Go to http://localhost:3000 (admin/admin)
2. Navigate to Configuration → Data Sources
3. Click on "InfluxDB 2.x"
4. Click "Test" button
5. Check for any error messages

### Step 5: Check Dashboard Configuration
1. Open a dashboard in Grafana
2. Check the time range (top-right corner)
3. Verify the data source is set to "InfluxDB 2.x"
4. Check panel queries for correct bucket and field names

## Advanced Troubleshooting

### Check Container Logs
```powershell
# Grafana logs
docker logs iot-grafana --tail 50

# InfluxDB logs
docker logs iot-influxdb2 --tail 50

# Node-RED logs
docker logs iot-node-red --tail 50
```

### Verify Network Configuration
```powershell
# Check network
docker network inspect iot-network

# Test connectivity between containers
docker exec iot-grafana ping influxdb
docker exec iot-node-red ping influxdb
```

### Check Data Structure
```powershell
# Query available measurements
curl "http://localhost:8086/query?org=renewable_energy_org&q=import \"influxdata/influxdb/schema\" schema.measurements(bucket: \"renewable_energy\")" \
  -H "Authorization: Token renewable_energy_admin_token_123"

# Query available fields
curl "http://localhost:8086/query?org=renewable_energy_org&q=from(bucket:\"renewable_energy\")|>range(start:-1h)|>keys()" \
  -H "Authorization: Token renewable_energy_admin_token_123"
```

## Prevention

### Best Practices
1. **Use consistent naming:** Always use the same organization, bucket, and token names
2. **Monitor container health:** Use health checks in docker-compose.yml
3. **Backup configurations:** Keep copies of working configurations
4. **Test regularly:** Run diagnostic scripts periodically
5. **Document changes:** Keep track of configuration changes

### Monitoring
Set up monitoring for:
- Container health status
- Data flow from Node-RED to InfluxDB
- Grafana dashboard performance
- Network connectivity between services

## Getting Help

If you're still experiencing issues:

1. **Run the diagnostic script** and share the output
2. **Check container logs** for error messages
3. **Verify your configuration** matches the examples in this guide
4. **Test with a simple query** to isolate the issue
5. **Check the project documentation** for updates

## Useful Commands

```powershell
# Quick health check
.\scripts\diagnose-grafana-influxdb.ps1

# Automatic fix
.\scripts\fix-grafana-influxdb.ps1

# Restart all services
docker-compose restart

# View real-time logs
docker-compose logs -f

# Access container shell
docker exec -it iot-grafana /bin/bash
docker exec -it iot-influxdb2 /bin/bash
docker exec -it iot-node-red /bin/bash
``` 