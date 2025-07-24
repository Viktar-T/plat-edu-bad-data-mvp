#!/bin/bash

# Node-RED Startup Script for Renewable Energy IoT Monitoring System
# This script ensures proper setup and starts Node-RED with all dependencies

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

# Always ensure package.json and settings.js are properly set up
echo "🔧 Setting up Node-RED configuration files..."

# Copy package.json if it's empty or missing
if [ ! -s "/data/package.json" ]; then
    echo "📦 Copying package.json from mounted volume..."
    cp /data/package.json.backup /data/package.json 2>/dev/null || echo "⚠️  No backup package.json found"
fi

# Copy settings.js if it's empty or missing
if [ ! -s "/data/settings.js" ]; then
    echo "⚙️  Copying settings.js from mounted volume..."
    cp /data/settings.js.backup /data/settings.js 2>/dev/null || echo "⚠️  No backup settings.js found"
fi

# Check if we need to install dependencies
NEED_INSTALL=false

# If package.json exists and node_modules doesn't exist, we need to install
if [ -s "/data/package.json" ] && [ ! -d "/data/node_modules" ]; then
    echo "📦 node_modules missing, will install dependencies"
    NEED_INSTALL=true
fi

# If node_modules exists but is empty or corrupted, we need to reinstall
if [ -d "/data/node_modules" ]; then
    if [ ! -d "/data/node_modules/node-red-contrib-influxdb" ]; then
        echo "📦 InfluxDB package missing from node_modules, will reinstall dependencies"
        NEED_INSTALL=true
    fi
fi

# Install dependencies if needed
if [ "$NEED_INSTALL" = true ]; then
    echo "🔧 Cleaning and installing Node-RED dependencies..."
    clean_npm_environment
    echo "📦 Installing Node-RED dependencies..."
    npm install --production
    echo "✅ Dependencies installed successfully"
else
    echo "✅ Dependencies already installed"
fi

# Ensure settings file is in the correct location for Node-RED
echo "🔧 Setting up Node-RED configuration..."
mkdir -p /usr/src/node-red/.node-red
if [ -s "/data/settings.js" ]; then
    cp /data/settings.js /usr/src/node-red/.node-red/settings.js
    echo "✅ Settings file configured"
else
    echo "⚠️  Using default Node-RED settings"
fi

# Start Node-RED
echo "🚀 Starting Node-RED..."
exec npm start 