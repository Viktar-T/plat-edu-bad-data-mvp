# InfluxDB Authentication - Unauthorized Access Issue

**Date:** 28 November 2025  
**Server:** edubad.zut.edu.pl  
**Status:** ✅ Resolved

## Issue Summary

Node-RED was unable to write data to InfluxDB, showing repeated "unauthorized access" errors (HTTP 401) in the logs. The error message was:

```
HttpError: unauthorized access
statusCode: 401
statusMessage: 'Unauthorized'
body: '{"code":"unauthorized","message":"unauthorized access"}'
```

## Root Cause

InfluxDB was initialized with a different authentication token than what was configured in:
- Node-RED flow files
- Docker Compose environment variables
- Documentation

**Expected Token:** `renewable_energy_admin_token_123`  
**Actual Token:** `simple_token_12345678901234567890123456789012`

## Symptoms

1. **Node-RED Logs:**
   - Continuous "unauthorized access" errors
   - All InfluxDB write operations failing
   - Error: `HttpError: unauthorized access` with status code 401

2. **InfluxDB Verification:**
   ```bash
   sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token renewable_energy_admin_token_123
   # Error: could not find authorization with given parameters: 401 Unauthorized
   ```

3. **Container Status:**
   - InfluxDB container was running and healthy
   - Node-RED container was running but unable to authenticate

## Solution

### Step 1: Identified the Correct Token

Verified the actual token in use:
```bash
sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token simple_token_12345678901234567890123456789012
```

### Step 2: Updated Node-RED Configuration

Updated InfluxDB config nodes in Node-RED UI:
1. Opened Node-RED: http://edubad.zut.edu.pl:8080/nodered/
2. Accessed Configuration nodes
3. Updated each InfluxDB config node with:
   - **Token:** `simple_token_12345678901234567890123456789012`
   - **Organization:** `renewable_energy_org`
   - **Bucket:** `renewable_energy`
   - **URL:** `http://influxdb:8086`
   - **Version:** `2.0`
4. Clicked "Deploy" to save credentials to `flows_cred.json`

### Step 3: Verification

After updating the token in Node-RED:
- ✅ Node-RED successfully writes to InfluxDB
- ✅ No more "unauthorized access" errors
- ✅ Data flow from MQTT → Node-RED → InfluxDB working correctly

## Technical Details

### InfluxDB Configuration

- **Organization:** `renewable_energy_org`
- **Bucket:** `renewable_energy`
- **Admin User:** `admin`
- **Admin Password:** `admin_password_123`
- **Admin Token:** `simple_token_12345678901234567890123456789012`

### Node-RED InfluxDB Connection

- **URL:** `http://influxdb:8086` (Docker internal network)
- **Version:** `2.0`
- **Token:** Stored in encrypted `flows_cred.json` file
- **Credentials:** Must be configured in Node-RED UI and deployed to persist

## Prevention

To prevent this issue in the future:

1. **Consistent Token Management:**
   - Use the same token across all configuration files
   - Document the actual token in use
   - Update `docker-compose.yml` defaults to match actual token

2. **Initialization Verification:**
   - Always verify InfluxDB initialization completed successfully
   - Check token validity after setup: `influx auth list --token <token>`
   - Verify Node-RED can authenticate before deploying flows

3. **Documentation:**
   - Keep documentation updated with actual tokens in use
   - Document token changes in production issues log

## Related Files

- `docker-compose.yml` - InfluxDB service configuration
- `node-red/flows/*.json` - Node-RED flow files with InfluxDB config
- `node-red/data/flows_cred.json` - Encrypted credentials (not in Git)
- `grafana/provisioning/datasources/influxdb.yaml` - Grafana data source config

## Scripts Created

During troubleshooting, the following scripts were created:

1. **`scripts/fix-influxdb-auth.sh`** - Diagnostic script for InfluxDB authentication
2. **`scripts/reset-influxdb.sh`** - Reset InfluxDB data and reinitialize
3. **`scripts/fix-influxdb-complete.sh`** - Complete reset with better error handling
4. **`scripts/manual-init-influxdb.sh`** - Manual InfluxDB initialization script

## Notes

- Node-RED stores InfluxDB tokens in encrypted `flows_cred.json`, not in flow JSON files
- The lock icon (🔒) in Node-RED UI indicates credentials will be encrypted
- Always click "Deploy" after configuring credentials in Node-RED UI
- InfluxDB initialization can take 60-90 seconds on first startup

## References

- [Node-RED InfluxDB Troubleshooting](../TROUBLESHOOTING-NODE-RED-CREDENTIALS.md)
- [InfluxDB API Documentation](../influxdb/01-influxdb-api.md)

