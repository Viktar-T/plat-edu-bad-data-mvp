#!/bin/bash

# Complete InfluxDB reset - fixes "config name already exists" error
# WARNING: This will delete all existing InfluxDB data!

set -e

echo "⚠️  WARNING: This script will completely reset InfluxDB!"
echo "   Press Ctrl+C within 5 seconds to cancel..."
sleep 5

cd ~/plat-edu-bad-data-mvp

echo ""
echo "🛑 Step 1: Stopping all services..."
sudo docker-compose stop influxdb node-red

echo ""
echo "🗑️  Step 2: Removing InfluxDB container completely..."
sudo docker-compose rm -f influxdb

echo ""
echo "🗑️  Step 3: Removing ALL InfluxDB data..."
# Remove the entire data directory
sudo rm -rf influxdb/data

echo ""
echo "🔧 Step 4: Creating fresh data directory..."
sudo mkdir -p influxdb/data
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./influxdb/data

echo ""
echo "🚀 Step 5: Starting InfluxDB (will initialize fresh)..."
sudo docker-compose up -d influxdb

echo ""
echo "⏳ Step 6: Waiting for InfluxDB to initialize..."
echo "   (This can take 60-90 seconds for first-time setup)"
sleep 10

# Monitor container status
MAX_WAIT=120
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    CONTAINER_STATE=$(sudo docker inspect iot-influxdb2 --format='{{.State.Status}}' 2>/dev/null || echo "notfound")
    
    if [ "$CONTAINER_STATE" = "running" ]; then
        # Check if health endpoint works
        if sudo docker exec iot-influxdb2 curl -f http://localhost:8086/health > /dev/null 2>&1; then
            echo ""
            echo "✅ InfluxDB is running and healthy!"
            break
        fi
    elif [ "$CONTAINER_STATE" = "restarting" ]; then
        echo "   ⚠️  Container is restarting (checking logs)..."
        ERROR=$(sudo docker logs iot-influxdb2 --tail 3 2>&1 | grep -i "error\|fatal" | head -1 || echo "")
        if [ -n "$ERROR" ]; then
            echo "   Error found: $ERROR"
        fi
    elif [ "$CONTAINER_STATE" = "notfound" ]; then
        echo "   ⚠️  Container not found yet..."
    fi
    
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    
    if [ $((ELAPSED % 15)) -eq 0 ]; then
        echo "   Still waiting... ($ELAPSED/$MAX_WAIT seconds) - State: $CONTAINER_STATE"
    fi
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo ""
    echo "❌ InfluxDB did not start properly within $MAX_WAIT seconds"
    echo ""
    echo "📋 Container status:"
    sudo docker ps -a | grep influxdb
    echo ""
    echo "📋 Recent logs:"
    sudo docker logs iot-influxdb2 --tail 50
    echo ""
    echo "💡 Try running: sudo docker logs iot-influxdb2 -f"
    exit 1
fi

echo ""
echo "🔍 Step 7: Verifying token..."
sleep 5
TOKEN="renewable_energy_admin_token_123"
if sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token "$TOKEN" > /dev/null 2>&1; then
    echo "✅ Token '$TOKEN' is valid!"
else
    echo "⚠️  Token verification failed"
    echo "   This might be normal if InfluxDB is still initializing"
    echo "   Wait 30 more seconds and try:"
    echo "   sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token $TOKEN"
fi

echo ""
echo "🔄 Step 8: Restarting Node-RED..."
sudo docker-compose restart node-red

echo ""
echo "✅ Reset complete!"
echo ""
echo "📋 Verification commands:"
echo "   1. Check InfluxDB status: sudo docker ps | grep influxdb"
echo "   2. Check InfluxDB logs: sudo docker logs iot-influxdb2 --tail 20"
echo "   3. Verify token: sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token $TOKEN"
echo "   4. Check Node-RED logs: sudo docker logs iot-node-red --tail 50"
echo ""
echo "🎉 If everything looks good, Node-RED should now be able to write to InfluxDB!"

