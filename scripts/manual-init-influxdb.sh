#!/bin/bash

# Manually initialize InfluxDB 2.x with the correct token
# Use this if automatic initialization didn't work

set -e

echo "🔧 Manually initializing InfluxDB 2.x..."

cd ~/plat-edu-bad-data-mvp

# Configuration
ADMIN_USER="admin"
ADMIN_PASSWORD="admin_password_123"
ADMIN_TOKEN="simple_token_12345678901234567890123456789012"
ORG_NAME="renewable_energy_org"
BUCKET_NAME="renewable_energy"
RETENTION="30d"

echo ""
echo "📋 Configuration:"
echo "   User: $ADMIN_USER"
echo "   Org: $ORG_NAME"
echo "   Bucket: $BUCKET_NAME"
echo "   Token: $ADMIN_TOKEN"
echo ""

# Check if InfluxDB is running
if ! sudo docker ps | grep -q iot-influxdb2; then
    echo "❌ InfluxDB container is not running!"
    echo "   Start it with: sudo docker-compose up -d influxdb"
    exit 1
fi

echo "✅ InfluxDB container is running"
echo ""

# Wait for InfluxDB to be ready
echo "⏳ Waiting for InfluxDB to be ready..."
MAX_WAIT=30
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if sudo docker exec iot-influxdb2 curl -f http://localhost:8086/health > /dev/null 2>&1; then
        echo "✅ InfluxDB is ready!"
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo "❌ InfluxDB did not become ready"
    exit 1
fi

echo ""
echo "🚀 Running InfluxDB setup..."
echo "   This will create the organization, bucket, and admin token"

# Run setup command inside the container
sudo docker exec iot-influxdb2 influx setup \
    --username "$ADMIN_USER" \
    --password "$ADMIN_PASSWORD" \
    --org "$ORG_NAME" \
    --bucket "$BUCKET_NAME" \
    --retention "$RETENTION" \
    --token "$ADMIN_TOKEN" \
    --force

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Setup completed successfully!"
else
    echo ""
    echo "⚠️  Setup command returned an error"
    echo "   This might be normal if InfluxDB was already partially initialized"
fi

echo ""
echo "🔍 Verifying setup..."

# Verify organization
echo "   Checking organization..."
if sudo docker exec iot-influxdb2 influx org list --host http://localhost:8086 --token "$ADMIN_TOKEN" 2>/dev/null | grep -q "$ORG_NAME"; then
    echo "   ✅ Organization '$ORG_NAME' exists"
else
    echo "   ❌ Organization '$ORG_NAME' not found"
fi

# Verify bucket
echo "   Checking bucket..."
if sudo docker exec iot-influxdb2 influx bucket list --host http://localhost:8086 --token "$ADMIN_TOKEN" --org "$ORG_NAME" 2>/dev/null | grep -q "$BUCKET_NAME"; then
    echo "   ✅ Bucket '$BUCKET_NAME' exists"
else
    echo "   ❌ Bucket '$BUCKET_NAME' not found"
fi

# Verify token
echo "   Checking token..."
if sudo docker exec iot-influxdb2 influx auth list --host http://localhost:8086 --token "$ADMIN_TOKEN" > /dev/null 2>&1; then
    echo "   ✅ Token is valid!"
else
    echo "   ❌ Token verification failed"
fi

echo ""
echo "🔄 Restarting Node-RED to reconnect..."
sudo docker-compose restart node-red

echo ""
echo "✅ Manual initialization complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Check Node-RED logs: sudo docker logs iot-node-red --tail 50"
echo "   2. Verify no more 'unauthorized' errors"
echo "   3. Check InfluxDB logs: sudo docker logs iot-influxdb2 --tail 20"

