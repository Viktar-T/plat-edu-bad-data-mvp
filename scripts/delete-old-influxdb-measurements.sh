#!/bin/bash

# Script to delete old measurement data from InfluxDB
# This removes data with the old measurement names (snake_case with _data suffix)
# and keeps the new measurement names (kebab-case)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
INFLUXDB_CONTAINER="iot-influxdb2"
ORG="${INFLUXDB_ORG:-renewable_energy_org}"
BUCKET="${INFLUXDB_BUCKET:-renewable_energy}"
TOKEN="${INFLUXDB_ADMIN_TOKEN:-simple_token_12345678901234567890123456789012}"

# Old measurements to delete (snake_case with _data suffix)
OLD_MEASUREMENTS=(
    "wind_turbine_data"
    "photovoltaic_data"
    "algae_farm_data"
    "biogas_plant_data"
    "heat_boiler_data"
    "energy_storage_data"
    "engine_test_bench_data"
)

echo "🗑️  Deleting old measurement data from InfluxDB..."
echo ""

# Check if InfluxDB container is running
if ! docker ps | grep -q "$INFLUXDB_CONTAINER"; then
    echo -e "${RED}❌ Error: InfluxDB container '$INFLUXDB_CONTAINER' is not running${NC}"
    exit 1
fi

echo -e "${GREEN}✅ InfluxDB container is running${NC}"
echo ""

# Function to delete data for a specific measurement
delete_measurement() {
    local measurement=$1
    echo -e "${YELLOW}🗑️  Deleting data for measurement: ${measurement}${NC}"
    
    # Use influx delete command with Flux predicate
    # This deletes all data matching the measurement name
    docker exec "$INFLUXDB_CONTAINER" influx delete \
        --org "$ORG" \
        --bucket "$BUCKET" \
        --token "$TOKEN" \
        --start 1970-01-01T00:00:00Z \
        --stop $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --predicate "_measurement=\"${measurement}\""
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully deleted data for: ${measurement}${NC}"
    else
        echo -e "${RED}❌ Failed to delete data for: ${measurement}${NC}"
        return 1
    fi
    echo ""
}

# Confirm before deletion
echo -e "${YELLOW}⚠️  WARNING: This will permanently delete all data for the following measurements:${NC}"
for measurement in "${OLD_MEASUREMENTS[@]}"; do
    echo "   - ${measurement}"
done
echo ""
echo -e "${YELLOW}This action cannot be undone!${NC}"
echo ""
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}❌ Deletion cancelled${NC}"
    exit 0
fi

echo ""
echo "Starting deletion process..."
echo ""

# Delete each old measurement
FAILED=0
for measurement in "${OLD_MEASUREMENTS[@]}"; do
    if ! delete_measurement "$measurement"; then
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All old measurements deleted successfully!${NC}"
    echo ""
    echo "The following new measurements should now be active:"
    echo "   - wind-vawt"
    echo "   - wind-hawt-hybrid"
    echo "   - pv-hulajnogi"
    echo "   - pv-hybrid"
    echo "   - algae-farm-1"
    echo "   - algae-farm-2"
    echo "   - biogas-plant"
    echo "   - heat-boiler"
    echo "   - energy-storage"
    echo "   - engine-test-bench"
else
    echo -e "${RED}❌ Some deletions failed (${FAILED} out of ${#OLD_MEASUREMENTS[@]})${NC}"
    exit 1
fi
echo "=========================================="

