#!/bin/bash

# Automatic Node-RED InfluxDB Fix Script
# This script fixes the automatic dependency installation issue

set -e

echo "🔧 Automatic Node-RED InfluxDB Fix Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_status "Step 1: Stopping Node-RED container..."
docker-compose stop node-red

print_status "Step 2: Cleaning up corrupted data files..."
# Remove empty package.json and settings.js files
docker-compose run --rm node-red bash -c "
cd /data
if [ ! -s package.json ]; then
    echo 'Removing empty package.json'
    rm -f package.json
fi
if [ ! -s settings.js ]; then
    echo 'Removing empty settings.js'
    rm -f settings.js
fi
"

print_status "Step 3: Ensuring proper file mounting..."
# The docker-compose.yml already mounts the correct files, so we just need to restart

print_status "Step 4: Starting Node-RED with automatic dependency installation..."
docker-compose up -d node-red

print_status "Step 5: Waiting for Node-RED to start..."
sleep 10

print_status "Step 6: Checking if InfluxDB package is installed..."
if docker-compose exec node-red npm list node-red-contrib-influxdb > /dev/null 2>&1; then
    print_success "InfluxDB package is installed!"
else
    print_warning "InfluxDB package not found, checking logs..."
    docker-compose logs node-red --tail=20
fi

print_status "Step 7: Verifying Node-RED health..."
if docker-compose ps node-red | grep -q "healthy"; then
    print_success "Node-RED is healthy!"
else
    print_warning "Node-RED health check failed, but it might still be starting..."
fi

echo ""
print_success "Automatic fix completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open Node-RED at: http://localhost:1880"
echo "2. Check if InfluxDB nodes are available in the palette"
echo "3. If flows are missing, import them from node-red/flows/"
echo ""
echo "🔍 To check logs: docker-compose logs -f node-red"
echo "🔍 To check package installation: docker-compose exec node-red npm list node-red-contrib-influxdb" 