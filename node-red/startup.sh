#!/bin/bash

# Node-RED Startup Script for Renewable Energy IoT Monitoring System
# This script ensures all required plugins are installed before starting Node-RED

set -e

echo "🚀 Starting Node-RED with plugin installation..."

# Function to clean npm cache and node_modules if corrupted
clean_npm_environment() {
    echo "🧹 Cleaning npm environment..."
    rm -rf /data/node_modules
    rm -rf /data/.npm
    npm cache clean --force
}

# Function to install plugins safely
install_plugins() {
    echo "📦 Installing Node-RED plugins..."
    
    # Only real, existing Node-RED packages with correct versions
    local plugins=(
        "node-red-dashboard@3.6.0"
        "node-red-contrib-influxdb@0.6.0"
        "node-red-contrib-mqtt-broker@0.2.9"
        "node-red-contrib-json@0.2.0"
        "node-red-contrib-cron-plus@2.1.0"
        "node-red-contrib-email@0.3.1"
        "node-red-contrib-telegrambot@0.4.0"
        "node-red-contrib-moment@3.0.0"
        "node-red-contrib-simple-gate@0.2.0"
        "node-red-contrib-chartjs@0.2.0"
    )
    
    # Install each plugin
    for plugin in "${plugins[@]}"; do
        echo "   Installing $plugin..."
        npm install --unsafe-perm --no-update-notifier --no-fund "$plugin" || {
            echo "   ⚠️  Warning: Failed to install $plugin, continuing..."
        }
    done
    
    echo "✅ Plugin installation completed"
}

# Function to check if plugins are already installed
check_plugins() {
    local required_plugins=(
        "node-red-dashboard"
        "node-red-contrib-influxdb"
        "node-red-contrib-mqtt-broker"
    )
    
    for plugin in "${required_plugins[@]}"; do
        if [ ! -d "/data/node_modules/$plugin" ]; then
            return 1
        fi
    done
    return 0
}

# Main execution
cd /data

# Clean npm environment if node_modules is corrupted
if [ -d "/data/node_modules" ] && [ -f "/data/node_modules/busboy" ]; then
    echo "🔧 Detected corrupted node_modules, cleaning..."
    clean_npm_environment
fi

# Check if plugins are already installed
if check_plugins; then
    echo "✅ Required plugins already installed"
else
    echo "📦 Installing required plugins..."
    install_plugins
fi

# Start Node-RED directly without su command to avoid permission issues
echo "🚀 Starting Node-RED..."
exec npm start 