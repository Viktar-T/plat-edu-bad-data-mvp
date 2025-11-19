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

# Load flows from flows directory if flows.json is empty or missing
echo "📋 Checking Node-RED flows..."

# Check if flows.json is empty, missing, or only contains empty array
FLOWS_EMPTY=false
if [ ! -f "/data/flows.json" ]; then
    FLOWS_EMPTY=true
    echo "📥 flows.json not found"
elif [ ! -s "/data/flows.json" ]; then
    FLOWS_EMPTY=true
    echo "📥 flows.json is empty"
else
    # Check if flows.json only contains empty array or whitespace
    FLOWS_CONTENT=$(cat /data/flows.json | tr -d '[:space:]')
    if [ "$FLOWS_CONTENT" = "[]" ] || [ -z "$FLOWS_CONTENT" ]; then
        FLOWS_EMPTY=true
        echo "📥 flows.json contains only empty array"
    fi
fi

if [ "$FLOWS_EMPTY" = true ]; then
    echo "📥 Loading flows from /flows directory..."
    
    # Check if flows directory exists and has flow files
    if [ -d "/flows" ] && [ "$(ls -A /flows/*.json 2>/dev/null)" ]; then
        echo "🔄 Merging flow files from /flows directory..."
        
        # Create a temporary file to store merged flows
        TEMP_FLOWS="/tmp/merged_flows.json"
        
        # Initialize merged flows array
        echo "[" > "$TEMP_FLOWS"
        FIRST=true
        
        # Process each flow file
        for flow_file in /flows/*.json; do
            if [ -f "$flow_file" ] && [ -s "$flow_file" ]; then
                echo "  📄 Processing $(basename "$flow_file")..."
                
                # Read the flow file and merge its contents
                if [ "$FIRST" = true ]; then
                    FIRST=false
                else
                    echo "," >> "$TEMP_FLOWS"
                fi
                
                # Extract the array content from the flow file (remove [ and ])
                # Handle both single-line and multi-line JSON
                cat "$flow_file" | sed '1d;$d' | sed 's/^/  /' >> "$TEMP_FLOWS" 2>/dev/null || {
                    # Fallback: if sed fails, try to extract content differently
                    python3 -c "import json, sys; data=json.load(open('$flow_file')); print(json.dumps(data, indent=2)[1:-1])" 2>/dev/null | sed 's/^/  /' >> "$TEMP_FLOWS" || {
                        # Last resort: just copy the file content
                        cat "$flow_file" | grep -v '^\s*\[\s*$' | grep -v '^\s*\]\s*$' | sed 's/^/  /' >> "$TEMP_FLOWS"
                    }
                }
            fi
        done
        
        echo "]" >> "$TEMP_FLOWS"
        
        # Validate JSON before copying
        if python3 -m json.tool "$TEMP_FLOWS" > /dev/null 2>&1 || node -e "JSON.parse(require('fs').readFileSync('$TEMP_FLOWS'))" 2>/dev/null; then
            # Copy merged flows to flows.json
            cp "$TEMP_FLOWS" /data/flows.json
            echo "✅ Flows loaded successfully from /flows directory"
        else
            echo "⚠️  Merged flows JSON is invalid, keeping existing flows.json"
            if [ ! -f "/data/flows.json" ]; then
                echo "[]" > /data/flows.json
            fi
        fi
    else
        echo "⚠️  No flow files found in /flows directory, using existing flows.json or creating empty one"
        if [ ! -f "/data/flows.json" ]; then
            echo "[]" > /data/flows.json
        fi
    fi
else
    echo "✅ flows.json already exists and has content"
fi

# Start Node-RED
echo "🚀 Starting Node-RED..."
exec npm start
