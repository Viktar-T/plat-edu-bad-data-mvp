#!/bin/bash
# Script to fix Grafana dashboard JSON files with encoding/BOM issues

set -e

echo "=========================================="
echo "Fixing Grafana Dashboard JSON Files"
echo "=========================================="
echo ""

cd ~/plat-edu-bad-data-mvp

DASHBOARD_DIR="grafana/dashboards"

if [ ! -d "$DASHBOARD_DIR" ]; then
    echo "Error: Dashboard directory not found: $DASHBOARD_DIR"
    exit 1
fi

echo "Checking and fixing JSON files in $DASHBOARD_DIR..."
echo ""

# Fix each JSON file
for json_file in "$DASHBOARD_DIR"/*.json; do
    if [ -f "$json_file" ]; then
        filename=$(basename "$json_file")
        echo "Processing: $filename"
        
        # Remove BOM if present
        sed -i '1s/^\xEF\xBB\xBF//' "$json_file"
        
        # Remove any non-printable characters except newlines and tabs
        sed -i 's/[[:cntrl:]]//g' "$json_file" 2>/dev/null || true
        
        # Validate JSON syntax
        if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "  ✓ $filename is valid JSON"
        else
            echo "  ✗ $filename has JSON syntax errors"
            # Try to fix common issues
            # Remove trailing commas before closing braces/brackets
            sed -i 's/,\s*}/}/g' "$json_file"
            sed -i 's/,\s*]/]/g' "$json_file"
            
            # Validate again
            if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
                echo "  ✓ $filename fixed and is now valid"
            else
                echo "  ✗ $filename still has errors - manual review needed"
            fi
        fi
    fi
done

echo ""
echo "Restarting Grafana to reload dashboards..."
sudo docker-compose restart grafana

echo ""
echo "Waiting 30 seconds for Grafana to restart..."
sleep 30

echo ""
echo "Checking Grafana logs for dashboard errors..."
sudo docker-compose logs --tail=20 grafana | grep -i "dashboard\|error" || echo "No recent dashboard errors found"

echo ""
echo "=========================================="
echo "Dashboard fix complete!"
echo "=========================================="

