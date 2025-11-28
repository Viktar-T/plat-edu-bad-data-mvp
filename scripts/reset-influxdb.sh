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
echo "🗑️  Removing InfluxDB data directory..."
sudo rm -rf influxdb/data/*

echo ""
echo "🔧 Fixing permissions..."
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./influxdb/data

echo ""
echo "🚀 Starting InfluxDB..."
sudo docker-compose up -d influxdb

echo ""
echo "⏳ Waiting for InfluxDB to initialize (this may take 30-60 seconds)..."
sleep 30

# Wait for InfluxDB to be ready
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -f http://localhost:8086/health > /dev/null 2>&1; then
        echo "✅ InfluxDB is ready!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "   Waiting for InfluxDB... ($ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "❌ InfluxDB did not start in time"
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

