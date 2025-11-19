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

# Check if flows.json is empty, missing, or only contains empty/default flow
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
    else
        # Check if flows.json only has the default flow (usually just one flow with minimal content)
        # Count the number of flow objects (tabs) - if only 1, it's likely the default flow
        FLOW_COUNT=$(cat /data/flows.json | grep -c '"type":"tab"' || echo "0")
        if [ "$FLOW_COUNT" -le 1 ]; then
            FLOWS_EMPTY=true
            echo "📥 flows.json contains only default flow (${FLOW_COUNT} tab(s)), will reload from /flows"
        fi
    fi
fi

if [ "$FLOWS_EMPTY" = true ]; then
    echo "📥 Loading flows from /flows directory..."
    
    # Debug: Check if flows directory exists
    if [ -d "/flows" ]; then
        echo "  ✓ /flows directory exists"
        echo "  📂 Contents of /flows:"
        ls -la /flows/ 2>/dev/null || echo "    (cannot list directory)"
    else
        echo "  ✗ /flows directory does not exist (volume mount may not be working)"
    fi
    
    # Check if flows directory exists and has flow files
    if [ -d "/flows" ] && [ "$(ls -A /flows/*.json 2>/dev/null)" ]; then
        echo "🔄 Merging flow files from /flows directory..."
        
        # Create a temporary file to store merged flows
        TEMP_FLOWS="/tmp/merged_flows.json"
        
        # Use Python to properly merge all flow files and generate tab definitions
        # stdout (JSON) goes to file, stderr (debug messages) goes to logs
        if python3 <<'PYTHON_SCRIPT' > "$TEMP_FLOWS"; then
import json
import glob
import os
import sys
import re

all_flows = []
tab_ids = set()
config_nodes = {}  # Track config nodes by ID to avoid duplicates

# Process each flow file
for flow_file in sorted(glob.glob('/flows/*.json')):
    if os.path.isfile(flow_file) and os.path.getsize(flow_file) > 0:
        filename = os.path.basename(flow_file)
        print(f"  📄 Processing {filename}...", file=sys.stderr)
        try:
            with open(flow_file, 'r') as f:
                flow_data = json.load(f)
            
            # If it's a list, process each node
            if isinstance(flow_data, list):
                for node in flow_data:
                    node_id = node.get('id', '')
                    node_type = node.get('type', '')
                    
                    # Collect tab IDs from nodes
                    if 'z' in node and node['z']:
                        tab_ids.add(node['z'])
                    
                    # Check if this is a config node (no 'z' property and specific types)
                    if 'z' not in node and node_type in ['mqtt-broker', 'influxdb']:
                        # Store config node (only once per ID)
                        if node_id not in config_nodes:
                            config_nodes[node_id] = node
                            print(f"    ✓ Found config node: {node_type} ({node_id})", file=sys.stderr)
                        # Don't add config nodes to all_flows - they're handled separately
                    else:
                        # Regular flow node (has 'z' property or is not a config node type)
                        all_flows.append(node)
            else:
                # Single node
                if 'z' in flow_data and flow_data['z']:
                    tab_ids.add(flow_data['z'])
                all_flows.append(flow_data)
        except Exception as e:
            print(f"  ⚠️  Error processing {filename}: {e}", file=sys.stderr)
            continue

# Generate tab definitions for each unique tab ID
tab_definitions = []
tab_labels = {
    'algae-farm-1-simulation': 'Algae Farm 1',
    'algae-farm-2-simulation': 'Algae Farm 2',
    'biogas-plant-simulation': 'Biogazownia',
    'energy-storage-simulation': 'Converter & Storage',
    'heat-boiler-simulation': 'Stirling-Ogniwo-Magazyn',
    'photovoltaic-simulation': 'Ładowarka słoneczna',
    'wind-turbine-simulation': 'Turbina wiatrowa VAWT',
    'engine-test-bench-simulation': 'Stanowisko do badań silnika',
    'pv-panels-simulation': 'Panele fotowoltaiczne',
    'wind-hawt-hybrid-simulation': 'Turbina wiatrowa HAWT',
    'pv-hulajnogi-simulation': 'PV Hulajnogi',
    'pv-hybrid-simulation': 'PV Hybrid'
}

for tab_id in sorted(tab_ids):
    # Generate a human-readable label
    label = tab_labels.get(tab_id, tab_id.replace('-', ' ').title())
    
    tab_def = {
        "id": tab_id,
        "type": "tab",
        "label": label,
        "disabled": False,
        "info": ""
    }
    tab_definitions.append(tab_def)

print(f"  ✅ Generated {len(tab_definitions)} tab definitions", file=sys.stderr)
print(f"  ✅ Found {len(config_nodes)} config nodes", file=sys.stderr)
if len(config_nodes) > 0:
    for config_id, config in config_nodes.items():
        print(f"    - {config.get('type')} ({config_id})", file=sys.stderr)
else:
    print(f"  ⚠️  WARNING: No config nodes found! This may cause connection issues.", file=sys.stderr)

# Combine tab definitions, config nodes, and flows (tabs first, then configs, then flows)
final_flows = tab_definitions + list(config_nodes.values()) + all_flows

print(f"  ✅ Total flows in output: {len(final_flows)} (tabs: {len(tab_definitions)}, configs: {len(config_nodes)}, nodes: {len(all_flows)})", file=sys.stderr)

# Write merged flows as formatted JSON
print(json.dumps(final_flows, indent=2))
PYTHON_SCRIPT
            echo "  ✅ Python merge completed"
            # Debug: Check what's in the temp file
            if [ -f "$TEMP_FLOWS" ]; then
                TEMP_CONFIG_COUNT=$(grep -c '"id":"influxdb-config"\|"id":"mqtt-broker-config"' "$TEMP_FLOWS" 2>/dev/null || echo "0")
                TEMP_TAB_COUNT=$(grep -c '"type":"tab"' "$TEMP_FLOWS" 2>/dev/null || echo "0")
                echo "  📊 Temp file stats: ${TEMP_CONFIG_COUNT} config nodes, ${TEMP_TAB_COUNT} tabs"
            fi
        else
            echo "⚠️  Python merge failed, using fallback method..."
            # Fallback: simple sed-based merge
            FIRST=true
            for flow_file in /flows/*.json; do
                if [ -f "$flow_file" ] && [ -s "$flow_file" ]; then
                    echo "  📄 Processing $(basename "$flow_file")..."
                    if [ "$FIRST" = true ]; then
                        echo "[" > "$TEMP_FLOWS"
                        FIRST=false
                    else
                        echo "," >> "$TEMP_FLOWS"
                    fi
                    cat "$flow_file" | sed '1d;$d' | sed 's/^/  /' >> "$TEMP_FLOWS"
                fi
            done
            echo "]" >> "$TEMP_FLOWS"
        fi
        
        # Validate JSON and verify config nodes before copying
        if python3 -m json.tool "$TEMP_FLOWS" > /dev/null 2>&1 || node -e "JSON.parse(require('fs').readFileSync('$TEMP_FLOWS'))" 2>/dev/null; then
            # Verify config nodes are in the temp file
            CONFIG_COUNT=$(grep -c '"id":"influxdb-config"\|"id":"mqtt-broker-config"' "$TEMP_FLOWS" 2>/dev/null || echo "0")
            if [ "$CONFIG_COUNT" -ge 2 ]; then
                # Copy merged flows to flows.json
                cp "$TEMP_FLOWS" /data/flows.json
                # Verify it was copied correctly
                FINAL_CONFIG_COUNT=$(grep -c '"id":"influxdb-config"\|"id":"mqtt-broker-config"' /data/flows.json 2>/dev/null || echo "0")
                if [ "$FINAL_CONFIG_COUNT" -ge 2 ]; then
                    echo "✅ Flows loaded successfully from /flows directory (${FINAL_CONFIG_COUNT} config nodes verified in flows.json)"
                else
                    echo "⚠️  WARNING: Config nodes were in temp file but missing from flows.json after copy!"
                fi
            else
                echo "⚠️  WARNING: Config nodes missing from merged file! Checking temp file..."
                grep -c '"type":"influxdb"\|"type":"mqtt-broker"' "$TEMP_FLOWS" || echo "No config nodes found in temp file"
                # Still copy it, but warn
                cp "$TEMP_FLOWS" /data/flows.json
                echo "⚠️  Copied flows.json but config nodes may be missing"
            fi
        else
            echo "⚠️  Merged flows JSON is invalid, checking temp file..."
            head -50 "$TEMP_FLOWS" || echo "Cannot read temp file"
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
