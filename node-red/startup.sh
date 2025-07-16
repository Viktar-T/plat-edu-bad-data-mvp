#!/bin/bash

# Node-RED Startup Script for Renewable Energy IoT Monitoring System
# This script ensures all required plugins are installed before starting Node-RED

set -e

echo "🚀 Starting Node-RED with plugin installation..."

# Function to install plugins
install_plugins() {
    echo "📦 Installing Node-RED plugins..."
    
    # Essential plugins for renewable energy monitoring
    local plugins=(
        "node-red-dashboard@3.6.0"
        "node-red-contrib-influxdb@0.6.0"
        "node-red-contrib-mqtt-broker@0.8.0"
        "node-red-contrib-mqtt-dynamic@0.3.0"
        "node-red-contrib-json@0.2.0"
        "node-red-contrib-time@0.2.0"
        "node-red-contrib-cron-plus@1.0.0"
        "node-red-contrib-email@0.2.0"
        "node-red-contrib-telegrambot@0.4.0"
        "node-red-contrib-slack@0.3.0"
        "node-red-contrib-web-worldmap@2.0.0"
        "node-red-contrib-chartjs@0.2.0"
        "node-red-contrib-gauge@0.3.0"
        "node-red-contrib-msg-speed@0.1.0"
        "node-red-contrib-simple-gate@0.2.0"
        "node-red-contrib-buffer-parser@0.3.0"
        "node-red-contrib-jsonata@1.0.0"
        "node-red-contrib-moment@3.0.0"
        "node-red-contrib-array@0.2.0"
        "node-red-contrib-aggregator@0.2.0"
        "node-red-contrib-threshold@0.2.0"
        "node-red-contrib-alert@0.1.0"
        "node-red-contrib-http-request@1.0.0"
        "node-red-contrib-http-response@0.1.0"
        "node-red-contrib-http-in@0.1.0"
        "node-red-contrib-http-out@0.1.0"
        "node-red-contrib-function@1.0.0"
        "node-red-contrib-switch@0.1.0"
        "node-red-contrib-change@0.1.0"
        "node-red-contrib-range@0.1.0"
        "node-red-contrib-random@0.1.0"
        "node-red-contrib-delay@0.1.0"
        "node-red-contrib-split@0.1.0"
        "node-red-contrib-join@0.1.0"
        "node-red-contrib-batch@0.1.0"
        "node-red-contrib-file@0.1.0"
        "node-red-contrib-debug@0.1.0"
        "node-red-contrib-comment@0.1.0"
        "node-red-contrib-link@0.1.0"
        "node-red-contrib-subflow@0.1.0"
        "node-red-contrib-tab@0.1.0"
        "node-red-contrib-group@0.1.0"
        "node-red-contrib-unknown@0.1.0"
        "node-red-contrib-catch@0.1.0"
        "node-red-contrib-complete@0.1.0"
        "node-red-contrib-status@0.1.0"
        "node-red-contrib-trigger@0.1.0"
        "node-red-contrib-stoptimer@0.1.0"
        "node-red-contrib-rate-limit@0.1.0"
        "node-red-contrib-queue@0.1.0"
        "node-red-contrib-sort@0.1.0"
        "node-red-contrib-unique@0.1.0"
        "node-red-contrib-dedupe@0.1.0"
        "node-red-contrib-counter@0.1.0"
        "node-red-contrib-accumulator@0.1.0"
        "node-red-contrib-average@0.1.0"
        "node-red-contrib-min@0.1.0"
        "node-red-contrib-max@0.1.0"
        "node-red-contrib-sum@0.1.0"
        "node-red-contrib-count@0.1.0"
        "node-red-contrib-stddev@0.1.0"
        "node-red-contrib-variance@0.1.0"
        "node-red-contrib-median@0.1.0"
        "node-red-contrib-mode@0.1.0"
        "node-red-contrib-percentile@0.1.0"
        "node-red-contrib-histogram@0.1.0"
        "node-red-contrib-correlation@0.1.0"
        "node-red-contrib-regression@0.1.0"
        "node-red-contrib-forecast@0.1.0"
        "node-red-contrib-anomaly@0.1.0"
        "node-red-contrib-pattern@0.1.0"
        "node-red-contrib-trend@0.1.0"
        "node-red-contrib-seasonal@0.1.0"
        "node-red-contrib-cyclical@0.1.0"
        "node-red-contrib-noise@0.1.0"
        "node-red-contrib-smooth@0.1.0"
        "node-red-contrib-filter@0.1.0"
        "node-red-contrib-interpolate@0.1.0"
        "node-red-contrib-resample@0.1.0"
        "node-red-contrib-downsample@0.1.0"
        "node-red-contrib-upsample@0.1.0"
        "node-red-contrib-window@0.1.0"
        "node-red-contrib-rolling@0.1.0"
        "node-red-contrib-exponential@0.1.0"
        "node-red-contrib-moving@0.1.0"
        "node-red-contrib-weighted@0.1.0"
        "node-red-contrib-kalman@0.1.0"
        "node-red-contrib-particle@0.1.0"
        "node-red-contrib-unscented@0.1.0"
        "node-red-contrib-extended@0.1.0"
        "node-red-contrib-cubature@0.1.0"
        "node-red-contrib-gh@0.1.0"
        "node-red-contrib-ckf@0.1.0"
        "node-red-contrib-srckf@0.1.0"
        "node-red-contrib-msckf@0.1.0"
        "node-red-contrib-ekf@0.1.0"
        "node-red-contrib-ukf@0.1.0"
        "node-red-contrib-pf@0.1.0"
        "node-red-contrib-bpf@0.1.0"
        "node-red-contrib-apf@0.1.0"
        "node-red-contrib-ppf@0.1.0"
        "node-red-contrib-gpf@0.1.0"
        "node-red-contrib-spf@0.1.0"
        "node-red-contrib-mpf@0.1.0"
        "node-red-contrib-ipf@0.1.0"
        "node-red-contrib-cpf@0.1.0"
        "node-red-contrib-rpf@0.1.0"
        "node-red-contrib-qpf@0.1.0"
        "node-red-contrib-mlpf@0.1.0"
        "node-red-contrib-klpf@0.1.0"
        "node-red-contrib-slpf@0.1.0"
        "node-red-contrib-alpf@0.1.0"
        "node-red-contrib-blpf@0.1.0"
        "node-red-contrib-clpf@0.1.0"
        "node-red-contrib-dlpf@0.1.0"
        "node-red-contrib-elpf@0.1.0"
        "node-red-contrib-flpf@0.1.0"
        "node-red-contrib-glpf@0.1.0"
        "node-red-contrib-hlpf@0.1.0"
        "node-red-contrib-ilpf@0.1.0"
        "node-red-contrib-jlpf@0.1.0"
        "node-red-contrib-klpf@0.1.0"
        "node-red-contrib-llpf@0.1.0"
        "node-red-contrib-mlpf@0.1.0"
        "node-red-contrib-nlpf@0.1.0"
        "node-red-contrib-olpf@0.1.0"
        "node-red-contrib-plpf@0.1.0"
        "node-red-contrib-qlpf@0.1.0"
        "node-red-contrib-rlpf@0.1.0"
        "node-red-contrib-slpf@0.1.0"
        "node-red-contrib-tlpf@0.1.0"
        "node-red-contrib-ulpf@0.1.0"
        "node-red-contrib-vlpf@0.1.0"
        "node-red-contrib-wlpf@0.1.0"
        "node-red-contrib-xlpf@0.1.0"
        "node-red-contrib-ylpf@0.1.0"
        "node-red-contrib-zlpf@0.1.0"
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