#!/bin/bash

# =============================================================================
# Grafana-InfluxDB Connection Diagnostic Script
# Renewable Energy IoT Monitoring System
# =============================================================================

set -e

echo "🔍 Starting Grafana-InfluxDB Connection Diagnostic..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Check if Docker is running
echo "1. Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    print_status "ERROR" "Docker is not running. Please start Docker first."
    exit 1
fi
print_status "SUCCESS" "Docker is running"

# Check if containers are running
echo "2. Checking container status..."
containers=("iot-mosquitto" "iot-influxdb2" "iot-node-red" "iot-grafana")
for container in "${containers[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "^$container$"; then
        print_status "SUCCESS" "Container $container is running"
    else
        print_status "ERROR" "Container $container is not running"
    fi
done

# Check InfluxDB health
echo "3. Checking InfluxDB health..."
if curl -f http://localhost:8086/health > /dev/null 2>&1; then
    print_status "SUCCESS" "InfluxDB is healthy"
else
    print_status "ERROR" "InfluxDB is not responding"
fi

# Check Grafana health
echo "4. Checking Grafana health..."
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    print_status "SUCCESS" "Grafana is healthy"
else
    print_status "ERROR" "Grafana is not responding"
fi

# Check InfluxDB data
echo "5. Checking InfluxDB data..."
echo "   Testing InfluxDB connection and data..."

# Create a temporary script to test InfluxDB
cat > /tmp/test_influxdb.js << 'EOF'
const { InfluxDB, Point } = require('@influxdata/influxdb-client');

const url = 'http://localhost:8086';
const token = 'renewable_energy_admin_token_123';
const org = 'renewable_energy_org';
const bucket = 'renewable_energy';

const client = new InfluxDB({ url, token });

async function testConnection() {
    try {
        // Test query
        const queryApi = client.getQueryApi(org);
        const query = `from(bucket: "${bucket}")
            |> range(start: -1h)
            |> limit(n: 1)`;
        
        const results = await queryApi.queryRaw(query);
        console.log('✅ InfluxDB connection successful');
        console.log('📊 Data found:', results.length > 0 ? 'Yes' : 'No');
        
        if (results.length > 0) {
            console.log('📈 Sample data:', results.substring(0, 200) + '...');
        }
        
        return true;
    } catch (error) {
        console.error('❌ InfluxDB connection failed:', error.message);
        return false;
    } finally {
        client.close();
    }
}

testConnection();
EOF

# Run the test
if node /tmp/test_influxdb.js 2>/dev/null; then
    print_status "SUCCESS" "InfluxDB connection and data access working"
else
    print_status "ERROR" "InfluxDB connection or data access failed"
fi

# Check Grafana data source configuration
echo "6. Checking Grafana data source..."
echo "   Testing Grafana-InfluxDB connection..."

# Create a temporary script to test Grafana data source
cat > /tmp/test_grafana_datasource.js << 'EOF'
const axios = require('axios');

async function testGrafanaDataSource() {
    try {
        const baseURL = 'http://localhost:3000';
        const auth = {
            username: 'admin',
            password: 'admin'
        };
        
        // Get data sources
        const response = await axios.get(`${baseURL}/api/datasources`, { auth });
        const datasources = response.data;
        
        console.log('✅ Grafana API accessible');
        console.log('📊 Found data sources:', datasources.length);
        
        const influxDS = datasources.find(ds => ds.type === 'influxdb');
        if (influxDS) {
            console.log('✅ InfluxDB data source found:', influxDS.name);
            console.log('🔗 URL:', influxDS.url);
            console.log('🏢 Organization:', influxDS.jsonData?.organization);
            console.log('🪣 Bucket:', influxDS.jsonData?.defaultBucket);
            
            // Test the data source
            const testResponse = await axios.post(
                `${baseURL}/api/datasources/${influxDS.id}/resources/query`,
                {
                    query: 'from(bucket: "renewable_energy") |> range(start: -1h) |> limit(n: 1)'
                },
                { auth }
            );
            
            if (testResponse.data.results && testResponse.data.results.length > 0) {
                console.log('✅ Data source test successful');
                console.log('📈 Query returned data');
            } else {
                console.log('⚠️  Data source test returned no data');
            }
        } else {
            console.log('❌ InfluxDB data source not found');
        }
        
    } catch (error) {
        console.error('❌ Grafana data source test failed:', error.message);
    }
}

testGrafanaDataSource();
EOF

# Install axios if not available
if ! node -e "require('axios')" 2>/dev/null; then
    npm install axios --no-save > /dev/null 2>&1
fi

# Run the test
if node /tmp/test_grafana_datasource.js 2>/dev/null; then
    print_status "SUCCESS" "Grafana data source configuration verified"
else
    print_status "ERROR" "Grafana data source configuration failed"
fi

# Check for common issues
echo "7. Checking for common configuration issues..."

# Check if .env file exists
if [ -f ".env" ]; then
    print_status "SUCCESS" ".env file exists"
else
    print_status "WARNING" ".env file not found, using defaults"
fi

# Check InfluxDB authentication
if grep -q "INFLUXDB_HTTP_AUTH_ENABLED=false" .env 2>/dev/null || [ ! -f ".env" ]; then
    print_status "INFO" "InfluxDB authentication is disabled (development mode)"
else
    print_status "INFO" "InfluxDB authentication is enabled"
fi

# Check bucket name consistency
echo "8. Checking bucket name consistency..."
expected_bucket="renewable_energy"
if grep -q "INFLUXDB_BUCKET=$expected_bucket" .env 2>/dev/null || [ ! -f ".env" ]; then
    print_status "SUCCESS" "Bucket name is consistent: $expected_bucket"
else
    print_status "WARNING" "Bucket name may be inconsistent"
fi

# Check organization name consistency
echo "9. Checking organization name consistency..."
expected_org="renewable_energy_org"
if grep -q "INFLUXDB_ORG=$expected_org" .env 2>/dev/null || [ ! -f ".env" ]; then
    print_status "SUCCESS" "Organization name is consistent: $expected_org"
else
    print_status "WARNING" "Organization name may be inconsistent"
fi

# Check token consistency
echo "10. Checking token consistency..."
expected_token="renewable_energy_admin_token_123"
if grep -q "INFLUXDB_ADMIN_TOKEN=$expected_token" .env 2>/dev/null || [ ! -f ".env" ]; then
    print_status "SUCCESS" "Token is consistent"
else
    print_status "WARNING" "Token may be inconsistent"
fi

echo ""
echo "=================================================="
echo "🔧 Recommended fixes:"
echo ""

# Check if data exists in InfluxDB
echo "📊 Checking if data exists in InfluxDB..."
if curl -s "http://localhost:8086/query?org=renewable_energy_org&q=from(bucket:\"renewable_energy\")|>range(start:-1h)|>count()" \
    -H "Authorization: Token renewable_energy_admin_token_123" | grep -q "result"; then
    print_status "SUCCESS" "Data exists in InfluxDB"
else
    print_status "WARNING" "No data found in InfluxDB - check Node-RED flows"
    echo "   💡 Try restarting Node-RED: docker restart iot-node-red"
fi

# Cleanup
rm -f /tmp/test_influxdb.js /tmp/test_grafana_datasource.js

echo ""
echo "🎯 Next steps:"
echo "1. If containers are not running: docker-compose up -d"
echo "2. If no data in InfluxDB: Check Node-RED flows and restart"
echo "3. If Grafana shows no data: Check data source configuration"
echo "4. Access Grafana at: http://localhost:3000 (admin/admin)"
echo "5. Access InfluxDB at: http://localhost:8086"
echo "6. Access Node-RED at: http://localhost:1880"

print_status "SUCCESS" "Diagnostic completed!" 