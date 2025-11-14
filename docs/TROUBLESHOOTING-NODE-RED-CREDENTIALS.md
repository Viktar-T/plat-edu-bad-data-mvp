# Troubleshooting Node-RED InfluxDB Credentials

## Problem
Node-RED shows "unauthorized access" errors when writing to InfluxDB, even though the token is configured in the UI and shows a lock icon.

## Root Cause
The `node-red-contrib-influxdb` package **only reads tokens from encrypted credentials** (`flows_cred.json`), not from the flow JSON file. If the credentials file doesn't exist or isn't being created, the package can't read the token.

## Solution

### Step 1: Verify Credentials File Exists
```bash
docker exec iot-node-red-local ls -la /data/flows_cred.json
```

If the file doesn't exist, an empty one has been created. Node-RED will populate it when you save credentials.

### Step 2: Configure Token in Node-RED UI

1. **Open Node-RED**: http://localhost:1880
2. **Find InfluxDB Config Nodes**: Look for nodes with type "influxdb" (they appear as configuration nodes, not regular flow nodes)
3. **Double-click each InfluxDB config node** to open its configuration
4. **Enter the token**: `renewable_energy_admin_token_123`
5. **Verify the lock icon** appears next to the token field
6. **Click "Done"**
7. **Click "Deploy"** (this is critical - credentials are only saved when you deploy!)

### Step 3: Verify Credentials Were Saved

After deploying, check if the credentials file was updated:
```bash
docker exec iot-node-red-local cat /data/flows_cred.json
```

You should see encrypted credentials (not the plain token).

### Step 4: Check Logs

Monitor Node-RED logs for errors:
```bash
docker logs iot-node-red-local --tail 20 | Select-String -Pattern "error|Error|unauthorized|Unauthorized"
```

If you still see "unauthorized access" errors after deploying, the credentials might not be saving correctly.

## Alternative: Temporary Workaround

If credentials still don't work, you can temporarily modify the package to read from the flow JSON. However, this is **not recommended** for production as it stores the token in plain text.

## Why This Happens

1. **Node-RED credentials system**: Node-RED stores sensitive data (like tokens) in an encrypted `flows_cred.json` file
2. **Package behavior**: The `node-red-contrib-influxdb` package is designed to only read tokens from credentials, not from the flow JSON
3. **File not created**: If you configure credentials in the UI but don't deploy, or if there's a permission issue, the credentials file won't be created
4. **Memory vs. disk**: The lock icon shows credentials are in memory, but they need to be persisted to disk for the package to read them

## Prevention

- Always click **"Deploy"** after configuring credentials
- Check that `flows_cred.json` exists after deployment
- Ensure Node-RED has write permissions to the `/data` directory
- Use a consistent `credentialSecret` in `settings.js` across deployments

