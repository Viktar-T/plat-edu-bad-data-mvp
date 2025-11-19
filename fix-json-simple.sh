#!/bin/bash
# Simple sed-based fix for unescaped quotes in Grafana dashboard JSON files

set -e

cd ~/plat-edu-bad-data-mvp
DASHBOARD_DIR="grafana/dashboards"

echo "Fixing unescaped quotes in JSON files using sed..."
echo ""

for json_file in "$DASHBOARD_DIR"/*.json; do
    if [ -f "$json_file" ]; then
        filename=$(basename "$json_file")
        echo "Processing: $filename"
        
        # Remove BOM
        sed -i '1s/^\xEF\xBB\xBF//' "$json_file"
        
        # Fix pattern: from(bucket: "name") -> from(bucket: \"name\")
        # This is tricky with sed, so we'll use a Python one-liner
        python3 -c "
import re
import sys

with open('$json_file', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix unescaped quotes in Flux queries
# Pattern: find \"query\": \"...\" and fix quotes inside
def fix_query(match):
    key = match.group(1)
    query = match.group(2)
    # Escape all unescaped double quotes
    fixed = query.replace('\"', '\\\\\"')
    return key + '\"' + fixed + '\"'

# Fix the query field values
content = re.sub(
    r'(\"query\"\s*:\s*\")([^\"]*(?:\"[^\",}\]]*)*)(\")',
    lambda m: m.group(1) + m.group(2).replace('\"', '\\\\\"') + m.group(3),
    content
)

# Remove trailing commas
content = re.sub(r',(\s*[}\]])', r'\1', content)

with open('$json_file', 'w', encoding='utf-8') as f:
    f.write(content)
"
        
        # Validate JSON
        if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "  ✓ $filename is now valid"
        else
            echo "  ✗ $filename still has errors"
        fi
    fi
done

echo ""
echo "Done! Restarting Grafana..."
sudo docker-compose restart grafana

