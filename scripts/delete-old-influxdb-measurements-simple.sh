#!/bin/bash

# Simple script to delete old measurement data from InfluxDB
# Run this on the VPS server

set -e

# Configuration
INFLUXDB_CONTAINER="iot-influxdb2"
ORG="renewable_energy_org"
BUCKET="renewable_energy"
TOKEN="simple_token_12345678901234567890123456789012"

echo "🗑️  Deleting old measurement data from InfluxDB..."
echo ""

# Old measurements to delete
OLD_MEASUREMENTS=(
    "wind_turbine_data"
    "photovoltaic_data"
    "algae_farm_data"
    "biogas_plant_data"
    "heat_boiler_data"
    "energy_storage_data"
    "engine_test_bench_data"
)

# Confirm deletion
echo "⚠️  WARNING: This will delete all data for:"
for m in "${OLD_MEASUREMENTS[@]}"; do
    echo "   - $m"
done
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

# Delete each measurement
for measurement in "${OLD_MEASUREMENTS[@]}"; do
    echo "Deleting: $measurement"
    docker exec "$INFLUXDB_CONTAINER" influx delete \
        --org "$ORG" \
        --bucket "$BUCKET" \
        --token "$TOKEN" \
        --start 1970-01-01T00:00:00Z \
        --stop $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --predicate "_measurement=\"${measurement}\""
    echo "✅ Deleted: $measurement"
done

echo ""
echo "✅ All old measurements deleted!"

