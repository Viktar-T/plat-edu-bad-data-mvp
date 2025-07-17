#!/bin/bash

# Node-RED Startup Script for Renewable Energy IoT Monitoring System
# This script ensures all required plugins are installed before starting Node-RED

set -e

echo "🚀 Starting Node-RED with plugin installation..."

# Function to install plugins
install_plugins() {
    echo "📦 Installing Node-RED plugins..."
    
    # Only real, existing Node-RED packages
    local plugins=(
        "node-red-dashboard@3.6.0"
        "node-red-contrib-influxdb@0.6.0"
        "node-red-contrib-mqtt-broker@0.8.0"
        "node-red-contrib-mqtt-dynamic@0.3.0"
        "node-red-contrib-json@0.2.0"
        "node-red-contrib-cron-plus@1.0.0"
        "node-red-contrib-email@0.2.0"
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

# Check if plugins are already installed
if check_plugins; then
    echo "✅ Required plugins already installed"
else
    echo "📦 Installing required plugins..."
    install_plugins
fi

# Set proper permissions
echo "🔧 Setting permissions..."
chown -R node-red:node-red /data

# Start Node-RED
echo "🚀 Starting Node-RED..."
exec su node-red -c "npm start" 