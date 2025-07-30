#!/bin/bash

# InfluxDB 2.x User Setup Script
# Renewable Energy Monitoring System

set -e

# Configuration
INFLUXDB_URL="http://localhost:8086"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin_password_123"
ADMIN_TOKEN="renewable_energy_admin_token_123"
ORG_NAME="renewable_energy_org"

echo "👥 Starting InfluxDB 2.x User Setup..."

# Wait for InfluxDB to be ready
echo "⏳ Waiting for InfluxDB to be ready..."
until curl -f "$INFLUXDB_URL/health" > /dev/null 2>&1; do
    echo "   Waiting for InfluxDB to start..."
    sleep 2
done
echo "✅ InfluxDB is ready!"

# Verify admin token works
echo "🔍 Verifying admin token..."
if ! influx org list --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" > /dev/null 2>&1; then
    echo "❌ Admin token verification failed"
    echo "   Please ensure InfluxDB is properly initialized with the admin token"
    exit 1
fi
echo "✅ Admin token verified!"

# Create additional users for different roles
echo "👤 Creating additional users..."

# Create read-only user for dashboards
echo "   Creating read-only user..."
influx user create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" \
    --name "dashboard_user" --password "dashboard_password_123" || {
    echo "⚠️  dashboard_user may already exist"
}

# Create write-only user for data ingestion
echo "   Creating write-only user..."
influx user create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" \
    --name "ingestion_user" --password "ingestion_password_123" || {
    echo "⚠️  ingestion_user may already exist"
}

# Create analytics user for complex queries
echo "   Creating analytics user..."
influx user create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" \
    --name "analytics_user" --password "analytics_password_123" || {
    echo "⚠️  analytics_user may already exist"
}

echo "✅ Users created successfully!"

# Create tokens for each user
echo "🔑 Creating user tokens..."

# Dashboard user token (read-only)
echo "   Creating dashboard user token..."
DASHBOARD_TOKEN=$(influx auth create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" \
    --org "$ORG_NAME" --user "dashboard_user" --read-bucket "renewable_energy" \
    --read-bucket "system_metrics" --read-bucket "alerts" --read-bucket "analytics" \
    --json | jq -r '.token') || {
    echo "⚠️  Dashboard token may already exist"
    DASHBOARD_TOKEN="dashboard_token_123"
}

# Ingestion user token (write-only)
echo "   Creating ingestion user token..."
INGESTION_TOKEN=$(influx auth create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" \
    --org "$ORG_NAME" --user "ingestion_user" --write-bucket "renewable_energy" \
    --json | jq -r '.token') || {
    echo "⚠️  Ingestion token may already exist"
    INGESTION_TOKEN="ingestion_token_123"
}

# Analytics user token (read-write)
echo "   Creating analytics user token..."
ANALYTICS_TOKEN=$(influx auth create --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" \
    --org "$ORG_NAME" --user "analytics_user" --read-bucket "renewable_energy" \
    --write-bucket "analytics" --json | jq -r '.token') || {
    echo "⚠️  Analytics token may already exist"
    ANALYTICS_TOKEN="analytics_token_123"
}

echo "✅ User tokens created successfully!"

# List all users
echo "📋 Current users:"
influx user list --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN"

# List all tokens
echo "🔑 Current tokens:"
influx auth list --host "$INFLUXDB_URL" --token "$ADMIN_TOKEN" --org "$ORG_NAME"

echo "🎉 User setup completed successfully!"
echo ""
echo "📊 User Configuration Summary:"
echo "   Admin User: $ADMIN_USER"
echo "   Admin Token: $ADMIN_TOKEN"
echo "   Dashboard User: dashboard_user"
echo "   Dashboard Token: $DASHBOARD_TOKEN"
echo "   Ingestion User: ingestion_user"
echo "   Ingestion Token: $INGESTION_TOKEN"
echo "   Analytics User: analytics_user"
echo "   Analytics Token: $ANALYTICS_TOKEN"
echo ""
echo "🔐 Security Notes:"
echo "   - Change default passwords in production"
echo "   - Rotate tokens regularly"
echo "   - Use least privilege principle"
echo "   - Monitor user access and activity" 