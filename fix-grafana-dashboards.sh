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

# Check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not installed"
    exit 1
fi

# Create a Python script to fix JSON files
python3 << 'PYTHON_SCRIPT'
import json
import os
import glob
import sys

dashboard_dir = "grafana/dashboards"
fixed_count = 0
error_count = 0

for json_file in glob.glob(os.path.join(dashboard_dir, "*.json")):
    filename = os.path.basename(json_file)
    print(f"Processing: {filename}")
    
    try:
        # Read the file
        with open(json_file, 'rb') as f:
            content = f.read()
        
        # Remove BOM if present
        if content.startswith(b'\xef\xbb\xbf'):
            content = content[3:]
            print(f"  Removed BOM")
        
        # Decode to string, trying UTF-8 first
        try:
            text = content.decode('utf-8')
        except UnicodeDecodeError:
            # Try latin-1 as fallback (preserves all bytes)
            text = content.decode('latin-1')
            print(f"  Used latin-1 encoding")
        
        # Remove any null bytes
        text = text.replace('\x00', '')
        
        # Try to parse JSON
        try:
            data = json.loads(text)
            # If successful, write it back with proper formatting
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"  ✓ {filename} is valid JSON")
            fixed_count += 1
        except json.JSONDecodeError as e:
            print(f"  ✗ {filename} has JSON syntax errors: {e}")
            # Try to fix common issues
            # Remove trailing commas before closing braces/brackets
            import re
            text = re.sub(r',(\s*[}\]])', r'\1', text)
            
            # Try parsing again
            try:
                data = json.loads(text)
                with open(json_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                print(f"  ✓ {filename} fixed and is now valid")
                fixed_count += 1
            except json.JSONDecodeError as e2:
                print(f"  ✗ {filename} still has errors after fix attempt: {e2}")
                error_count += 1
    except Exception as e:
        print(f"  ✗ Error processing {filename}: {e}")
        error_count += 1

print("")
print(f"Summary: {fixed_count} files fixed, {error_count} files with errors")
sys.exit(0 if error_count == 0 else 1)
PYTHON_SCRIPT

PYTHON_EXIT=$?

echo ""
if [ $PYTHON_EXIT -eq 0 ]; then
    echo "Restarting Grafana to reload dashboards..."
    sudo docker-compose restart grafana
    
    echo ""
    echo "Waiting 30 seconds for Grafana to restart..."
    sleep 30
    
    echo ""
    echo "Checking Grafana logs for dashboard errors..."
    sudo docker-compose logs --tail=30 grafana | grep -i "dashboard\|error" || echo "No recent dashboard errors found"
else
    echo "Some files had errors. Please review them manually."
fi

echo ""
echo "=========================================="
echo "Dashboard fix complete!"
echo "=========================================="
