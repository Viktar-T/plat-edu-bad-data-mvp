#!/bin/bash

# InfluxDB 2.x Database Initialization Script
# Renewable Energy Monitoring System

set -e

# Configuration
INFLUXDB_URL="http://localhost:8086"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin_password_123"
ADMIN_TOKEN="renewable_energy_admin_token_123"
ORG_NAME="renewable_energy_org"
BUCKET_NAME="renewable_energy"
RETENTION_POLICY="30d"

echo "🚀 Starting InfluxDB 2.x Database Initialization..."

# Wait for InfluxDB to be ready
echo "⏳ Waiting for InfluxDB to be ready..."
until curl -f "$INFLUXDB_URL/health" > /dev/null 2>&1; do
    echo "   Waiting for InfluxDB to start..."
    sleep 2
done
echo "✅ InfluxDB is ready!"

# Check if setup is already completed
echo "🔍 Checking if setup is already completed..."
if influx setup --host "$INFLUXDB_URL" --username "$ADMIN_USER" --password "$ADMIN_PASSWORD" --org "$ORG_NAME" --bucket "$BUCKET_NAME" --retention "$RETENTION_POLICY" --token "$ADMIN_TOKEN" --force; then
    echo "✅ InfluxDB setup completed successfully!"
else
    echo "⚠️  Setup may have already been completed or failed. Continuing..."
fi

# Verify setup
echo "🔍 Verifying setup..."
influx org list --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" | grep "$ORG_NAME" || {
    echo "❌ Organization verification failed"
    exit 1
}

influx bucket list --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" --org "$ORG_NAME" | grep "$BUCKET_NAME" || {
    echo "❌ Bucket verification failed"
    exit 1
}

echo "✅ Setup verification completed successfully!"

# Create additional buckets for different data types
echo "📦 Creating additional buckets for renewable energy data..."

# System metrics bucket (7 days retention)
influx bucket create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" --org "$ORG_NAME" \
    --name "system_metrics" --retention "7d" || echo "⚠️  system_metrics bucket may already exist"

# Alerts bucket (90 days retention)
influx bucket create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" --org "$ORG_NAME" \
    --name "alerts" --retention "90d" || echo "⚠️  alerts bucket may already exist"

# Analytics bucket (365 days retention)
influx bucket create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" --org "$ORG_NAME" \
    --name "analytics" --retention "365d" || echo "⚠️  analytics bucket may already exist"

echo "✅ Additional buckets created successfully!"

# List all buckets
echo "📋 Current buckets:"
influx bucket list --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" --org "$ORG_NAME"

echo "🎉 InfluxDB 2.x initialization completed successfully!"
echo ""
echo "📊 Configuration Summary:"
echo "   URL: $INFLUXDB_URL"
echo "   Organization: $ORG_NAME"
echo "   Admin User: $ADMIN_USER"
echo "   Admin Token: $ADMIN_TOKEN"
echo "   Main Bucket: $BUCKET_NAME"
echo "   Retention: $RETENTION_POLICY"
echo ""
echo "🔗 Access URLs:"
echo "   InfluxDB UI: http://localhost:8086"
echo "   Node-RED: http://localhost:1880"
echo "   Grafana: http://localhost:3000" 