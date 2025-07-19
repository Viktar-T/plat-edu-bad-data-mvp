#!/bin/bash

# InfluxDB 3.x Setup Script for Renewable Energy Monitoring System
# This script initializes databases, creates tokens, and validates schema

set -e

# Configuration
INFLUXDB_HOST="${INFLUXDB_HOST:-localhost}"
INFLUXDB_PORT="${INFLUXDB_PORT:-8086}"
INFLUXDB_URL="http://${INFLUXDB_HOST}:${INFLUXDB_PORT}"
ADMIN_TOKEN="${INFLUXDB3_ADMIN_TOKEN:-your-super-secret-admin-token}"
ORGANIZATION="${INFLUXDB3_ORG:-renewable_energy}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Wait for InfluxDB to be ready
wait_for_influxdb() {
    log_info "Waiting for InfluxDB to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "${INFLUXDB_URL}/health" > /dev/null 2>&1; then
            log_success "InfluxDB is ready!"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts - InfluxDB not ready yet, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "InfluxDB failed to start within expected time"
    return 1
}

# Create database
create_database() {
    local db_name="$1"
    local retention_days="$2"
    local description="$3"
    
    log_info "Creating database: $db_name"
    
    # Create database using InfluxDB 3.x API
    local response=$(curl -s -w "%{http_code}" -X POST "${INFLUXDB_URL}/api/v3/configure/database" \
        -H "Authorization: Bearer ${ADMIN_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"${db_name}\",
            \"description\": \"${description}\",
            \"retention_days\": ${retention_days}
        }")
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "409" ]; then
        log_success "Database '$db_name' created successfully (HTTP: $http_code)"
    else
        log_error "Failed to create database '$db_name' (HTTP: $http_code): $response_body"
        return 1
    fi
}

# Create table schema
create_table_schema() {
    local db_name="$1"
    local table_name="$2"
    local schema_file="$3"
    
    log_info "Creating table schema: $table_name in database: $db_name"
    
    if [ ! -f "$schema_file" ]; then
        log_warning "Schema file not found: $schema_file, skipping table creation"
        return 0
    fi
    
    # Create table using InfluxDB 3.x API
    local response=$(curl -s -w "%{http_code}" -X POST "${INFLUXDB_URL}/api/v3/configure/database/${db_name}/table" \
        -H "Authorization: Bearer ${ADMIN_TOKEN}" \
        -H "Content-Type: application/json" \
        -d @$schema_file)
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "409" ]; then
        log_success "Table '$table_name' created successfully (HTTP: $http_code)"
    else
        log_error "Failed to create table '$table_name' (HTTP: $http_code): $response_body"
        return 1
    fi
}

# Create token
create_token() {
    local token_name="$1"
    local description="$2"
    local permissions="$3"
    
    log_info "Creating token: $token_name"
    
    # Create token using InfluxDB 3.x API
    local response=$(curl -s -w "%{http_code}" -X POST "${INFLUXDB_URL}/api/v3/configure/token" \
        -H "Authorization: Bearer ${ADMIN_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"${token_name}\",
            \"description\": \"${description}\",
            \"permissions\": ${permissions}
        }")
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [ "$http_code" = "201" ]; then
        # Extract token from response
        local token=$(echo "$response_body" | jq -r '.token // empty')
        if [ -n "$token" ]; then
            log_success "Token '$token_name' created successfully"
            echo "$token" > "/tmp/influxdb3_${token_name}_token.txt"
            log_info "Token saved to /tmp/influxdb3_${token_name}_token.txt"
        else
            log_warning "Token created but could not extract token value"
        fi
    elif [ "$http_code" = "409" ]; then
        log_warning "Token '$token_name' already exists"
    else
        log_error "Failed to create token '$token_name' (HTTP: $http_code): $response_body"
        return 1
    fi
}

# Validate database schema
validate_schema() {
    local db_name="$1"
    
    log_info "Validating schema for database: $db_name"
    
    # List tables in database
    local response=$(curl -s -w "%{http_code}" -X GET "${INFLUXDB_URL}/api/v3/configure/database/${db_name}/table" \
        -H "Authorization: Bearer ${ADMIN_TOKEN}")
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        local table_count=$(echo "$response_body" | jq '.tables | length')
        log_success "Database '$db_name' validation successful - found $table_count tables"
        echo "$response_body" | jq -r '.tables[].name' | while read table; do
            log_info "  - Table: $table"
        done
    else
        log_error "Failed to validate database '$db_name' (HTTP: $http_code): $response_body"
        return 1
    fi
}

# Test data insertion
test_data_insertion() {
    local db_name="$1"
    local test_token="$2"
    
    log_info "Testing data insertion for database: $db_name"
    
    # Test data for photovoltaic
    local test_data='{
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "device_id": "test_pv_001",
        "location": "test_site",
        "device_type": "photovoltaic",
        "status": "operational",
        "power_output": 584.43,
        "voltage": 48.3,
        "current": 12.1,
        "temperature": 45.2,
        "irradiance": 850.5,
        "efficiency": 18.5
    }'
    
    # Insert test data
    local response=$(curl -s -w "%{http_code}" -X POST "${INFLUXDB_URL}/api/v3/write/${db_name}/photovoltaic_data" \
        -H "Authorization: Bearer ${test_token}" \
        -H "Content-Type: application/json" \
        -d "$test_data")
    
    local http_code="${response: -3}"
    
    if [ "$http_code" = "204" ]; then
        log_success "Test data insertion successful"
    else
        log_error "Test data insertion failed (HTTP: $http_code)"
        return 1
    fi
}

# Main setup function
main() {
    log_info "Starting InfluxDB 3.x setup for Renewable Energy Monitoring System"
    
    # Wait for InfluxDB to be ready
    wait_for_influxdb
    
    # Create databases
    log_info "Creating databases..."
    create_database "renewable-energy-monitoring" 10 "Primary database for renewable energy device data"
    create_database "sensor-data" 7 "Raw sensor data from all devices"
    create_database "alerts" 30 "System alerts and notifications"
    create_database "system-metrics" 15 "System performance and health metrics"
    
    # Create application token with permissions
    local app_permissions='[
        {
            "database": "renewable-energy-monitoring",
            "permissions": ["READ", "WRITE"]
        },
        {
            "database": "sensor-data",
            "permissions": ["READ", "WRITE"]
        },
        {
            "database": "alerts",
            "permissions": ["READ", "WRITE"]
        },
        {
            "database": "system-metrics",
            "permissions": ["READ", "WRITE"]
        }
    ]'
    
    create_token "application-token" "Application token for data ingestion and queries" "$app_permissions"
    
    # Create read-only token
    local read_permissions='[
        {
            "database": "renewable-energy-monitoring",
            "permissions": ["READ"]
        },
        {
            "database": "sensor-data",
            "permissions": ["READ"]
        },
        {
            "database": "alerts",
            "permissions": ["READ"]
        },
        {
            "database": "system-metrics",
            "permissions": ["READ"]
        }
    ]'
    
    create_token "read-only-token" "Read-only token for dashboards and analytics" "$read_permissions"
    
    # Create table schemas
    log_info "Creating table schemas..."
    local schema_dir="../influxdb/config/schemas"
    
    # Renewable energy monitoring database tables
    create_table_schema "renewable-energy-monitoring" "photovoltaic_data" "$schema_dir/photovoltaic_data.json"
    create_table_schema "renewable-energy-monitoring" "wind_turbine_data" "$schema_dir/wind_turbine_data.json"
    create_table_schema "renewable-energy-monitoring" "biogas_plant_data" "$schema_dir/biogas_plant_data.json"
    create_table_schema "renewable-energy-monitoring" "heat_boiler_data" "$schema_dir/heat_boiler_data.json"
    create_table_schema "renewable-energy-monitoring" "energy_storage_data" "$schema_dir/energy_storage_data.json"
    create_table_schema "renewable-energy-monitoring" "laboratory_equipment_data" "$schema_dir/laboratory_equipment_data.json"
    
    # Validate schemas
    log_info "Validating database schemas..."
    validate_schema "renewable-energy-monitoring"
    validate_schema "sensor-data"
    validate_schema "alerts"
    validate_schema "system-metrics"
    
    # Test data insertion if application token exists
    if [ -f "/tmp/influxdb3_application-token_token.txt" ]; then
        local test_token=$(cat "/tmp/influxdb3_application-token_token.txt")
        test_data_insertion "renewable-energy-monitoring" "$test_token"
    fi
    
    log_success "InfluxDB 3.x setup completed successfully!"
    
    # Display summary
    echo ""
    log_info "Setup Summary:"
    log_info "  - Databases created: renewable-energy-monitoring, sensor-data, alerts, system-metrics"
    log_info "  - Tokens created: application-token, read-only-token"
    log_info "  - Token files saved to /tmp/influxdb3_*_token.txt"
    echo ""
    log_info "Next steps:"
    log_info "  1. Update your application configuration with the generated tokens"
    log_info "  2. Configure Node-RED flows to use the new InfluxDB 3.x endpoints"
    log_info "  3. Update Grafana data sources to use InfluxDB 3.x"
    log_info "  4. Test data ingestion and querying"
}

# Run main function
main "$@" 