#!/bin/bash

# Node-RED Startup Script for Renewable Energy IoT Monitoring System
# This script cleans corrupted node_modules and starts Node-RED

set -e

echo "🚀 Starting Node-RED for IoT Monitoring..."

# Function to clean npm cache and node_modules if corrupted
clean_npm_environment() {
    echo "🧹 Cleaning npm environment..."
    rm -rf /data/node_modules
    rm -rf /data/.npm
    npm cache clean --force
}

# Main execution
cd /data

# Clean npm environment if node_modules is corrupted
if [ -d "/data/node_modules" ] && [ -d "/data/node_modules/busboy" ]; then
    echo "🔧 Detected corrupted node_modules, cleaning..."
    clean_npm_environment
fi

# Ensure settings file is in the correct location
echo "🔧 Setting up Node-RED configuration..."
mkdir -p /usr/src/node-red/.node-red
cp /data/settings.js /usr/src/node-red/.node-red/settings.js

# Start Node-RED (npm will install dependencies from package.json automatically)
echo "🚀 Starting Node-RED..."
exec npm start 