#!/bin/bash

# Fix InfluxDB Authentication for Node-RED
# This script helps diagnose and fix InfluxDB authentication issues

set -e

echo "🔍 Diagnosing InfluxDB Authentication Issue..."
echo ""

# Check if InfluxDB container is running
echo "1. Checking InfluxDB container status..."
if ! sudo docker ps | grep -q iot-influxdb2; then
    echo "❌ InfluxDB container is not running!"
    exit 1
fi
echo "✅ InfluxDB container is running"
echo ""

# Check if Node-RED container is running
echo "2. Checking Node-RED container status..."
if ! sudo docker ps | grep -q iot-node-red; then
    echo "❌ Node-RED container is not running!"
    exit 1
fi
echo "✅ Node-RED container is running"
echo ""

# Check InfluxDB token
echo "3. Verifying InfluxDB token..."
TOKEN="renewable_energy_admin_token_123"
ORG="renewable_energy_org"
BUCKET="renewable_energy"

if sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token "$TOKEN" > /dev/null 2>&1; then
    echo "✅ Token '$TOKEN' is valid"
else
    echo "❌ Token '$TOKEN' is NOT valid or InfluxDB needs reinitialization"
    echo ""
    echo "📋 Listing all tokens in InfluxDB:"
    sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token "$TOKEN" 2>&1 || echo "   Could not list tokens"
    echo ""
    echo "💡 If token is invalid, you may need to:"
    echo "   1. Reset InfluxDB data: sudo docker-compose down && sudo rm -rf influxdb/data/* && sudo docker-compose up -d"
    echo "   2. Or update Node-RED flows with the correct token"
    exit 1
fi
echo ""

# Check Node-RED credentials file
echo "4. Checking Node-RED credentials file..."
if sudo docker exec iot-node-red test -f /data/flows_cred.json; then
    echo "✅ flows_cred.json exists"
    CRED_SIZE=$(sudo docker exec iot-node-red stat -c%s /data/flows_cred.json 2>/dev/null || echo "0")
    if [ "$CRED_SIZE" -gt 100 ]; then
        echo "✅ Credentials file has content (${CRED_SIZE} bytes)"
    else
        echo "⚠️  Credentials file is very small (${CRED_SIZE} bytes) - may be empty"
    fi
else
    echo "❌ flows_cred.json does NOT exist"
    echo "   This is the problem! Node-RED needs this file to store encrypted credentials."
fi
echo ""

# Check Node-RED flows for InfluxDB config
echo "5. Checking Node-RED flows for InfluxDB configuration..."
if sudo docker exec iot-node-red test -f /data/flows.json; then
    INFLUXDB_CONFIGS=$(sudo docker exec iot-node-red grep -c '"type": "influxdb"' /data/flows.json || echo "0")
    echo "   Found $INFLUXDB_CONFIGS InfluxDB configuration node(s)"
    
    # Check if token is in flows.json (should be, but credentials are in flows_cred.json)
    TOKEN_IN_FLOWS=$(sudo docker exec iot-node-red grep -c "renewable_energy_admin_token_123" /data/flows.json || echo "0")
    echo "   Token reference found in flows.json: $TOKEN_IN_FLOWS time(s)"
else
    echo "❌ flows.json does not exist"
fi
echo ""

# Summary and recommendations
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 DIAGNOSIS SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 SOLUTION: Configure InfluxDB token in Node-RED UI"
echo ""
echo "Step 1: Open Node-RED in your browser:"
echo "   http://edubad.zut.edu.pl:8080/nodered/"
echo "   Login: admin / adminpassword"
echo ""
echo "Step 2: Find InfluxDB Config Nodes"
echo "   - Click the menu (☰) in the top right"
echo "   - Select 'Configuration nodes'"
echo "   - Look for nodes with type 'influxdb' (named 'InfluxDB')"
echo ""
echo "Step 3: Configure Each InfluxDB Config Node"
echo "   - Double-click each InfluxDB config node"
echo "   - Verify/Set the following:"
echo "     • URL: http://influxdb:8086"
echo "     • Organization: renewable_energy_org"
echo "     • Bucket: renewable_energy"
echo "     • Token: renewable_energy_admin_token_123"
echo "     • Version: 2.0"
echo "   - Click 'Done'"
echo ""
echo "Step 4: Deploy (CRITICAL!)"
echo "   - Click the red 'Deploy' button in the top right"
echo "   - This saves credentials to flows_cred.json"
echo ""
echo "Step 5: Verify"
echo "   - Check logs: sudo docker logs iot-node-red --tail 50"
echo "   - Errors should stop appearing"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

