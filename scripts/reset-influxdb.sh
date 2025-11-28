#!/bin/bash

# Reset InfluxDB to use the correct token
# WARNING: This will delete all existing InfluxDB data!

set -e

echo "⚠️  WARNING: This script will delete all InfluxDB data!"
echo "   Press Ctrl+C within 5 seconds to cancel..."
sleep 5

echo ""
echo "🛑 Stopping services..."
cd ~/plat-edu-bad-data-mvp
sudo docker-compose stop influxdb node-red

echo ""
echo "🗑️  Removing InfluxDB container and volumes..."
# Remove container completely to clear any cached state
sudo docker-compose rm -f influxdb

echo ""
echo "🗑️  Removing ALL InfluxDB data and config files..."
# Remove entire data directory (not just contents)
sudo rm -rf influxdb/data
# Also remove any config files that might exist
sudo rm -rf influxdb/config/influx-configs 2>/dev/null || true

echo ""
echo "🔧 Creating fresh data directory with correct permissions..."
sudo mkdir -p influxdb/data
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./influxdb/data

echo ""
echo "🚀 Starting InfluxDB..."
sudo docker-compose up -d influxdb

echo ""
echo "⏳ Waiting for InfluxDB to initialize (this may take 30-60 seconds)..."
sleep 30

# Wait for InfluxDB to be ready
# Check container is running first
MAX_ATTEMPTS=60
ATTEMPT=0
CONTAINER_RUNNING=false

echo "   Checking if container started..."
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # First check if container is running (not restarting)
    CONTAINER_STATE=$(sudo docker inspect iot-influxdb2 --format='{{.State.Status}}' 2>/dev/null || echo "notfound")
    
    if [ "$CONTAINER_STATE" = "running" ]; then
        CONTAINER_RUNNING=true
        # Now check if health endpoint responds
        if sudo docker exec iot-influxdb2 curl -f http://localhost:8086/health > /dev/null 2>&1; then
            echo "✅ InfluxDB is ready and healthy!"
            break
        fi
    elif [ "$CONTAINER_STATE" = "restarting" ]; then
        echo "   Container is restarting... checking logs for errors"
        sudo docker logs iot-influxdb2 --tail 5 2>&1 | grep -i "error\|fatal" || true
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    if [ $((ATTEMPT % 5)) -eq 0 ]; then
        echo "   Waiting for InfluxDB... ($ATTEMPT/$MAX_ATTEMPTS) - State: $CONTAINER_STATE"
    fi
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "❌ InfluxDB did not start in time"
    echo ""
    echo "📋 Checking container status and logs..."
    sudo docker ps -a | grep influxdb
    echo ""
    echo "Recent logs:"
    sudo docker logs iot-influxdb2 --tail 30
    exit 1
fi

echo ""
echo "🔍 Verifying token..."
TOKEN="renewable_energy_admin_token_123"
if sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token "$TOKEN" > /dev/null 2>&1; then
    echo "✅ Token '$TOKEN' is valid!"
else
    echo "⚠️  Token verification failed, but InfluxDB should be initializing..."
    echo "   This is normal if InfluxDB is still setting up"
fi

echo ""
echo "🔄 Restarting Node-RED..."
sudo docker-compose restart node-red

echo ""
echo "✅ InfluxDB reset complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Wait 30-60 seconds for InfluxDB to fully initialize"
echo "   2. Verify token: sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token renewable_energy_admin_token_123"
echo "   3. Check Node-RED logs: sudo docker logs iot-node-red --tail 50"
echo "   4. If errors persist, reconfigure InfluxDB config nodes in Node-RED UI and deploy"

