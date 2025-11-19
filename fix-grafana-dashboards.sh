#!/bin/bash
# Script to fix Grafana dashboard JSON files with encoding/BOM issues and unescaped quotes

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

# Use the dedicated Python script if it exists, otherwise use inline script
if [ -f "fix-json-quotes.py" ]; then
    echo "Using fix-json-quotes.py script..."
    python3 fix-json-quotes.py "$DASHBOARD_DIR"
    PYTHON_EXIT=$?
else
    # Create a Python script to fix JSON files
    python3 << 'PYTHON_SCRIPT'
import json
import os
import glob
import sys
import re

dashboard_dir = "grafana/dashboards"
fixed_count = 0
error_count = 0

def fix_json_string_quotes(text):
    """Fix unescaped quotes inside JSON string values"""
    # This is a complex problem - we need to fix quotes inside string values
    # but not break the JSON structure. We'll use a regex approach.
    
    # Pattern to match string values that might have unescaped quotes
    # This matches: "key": "value with "quotes" inside"
    def fix_quotes_in_value(match):
        key_part = match.group(1)  # "key":
        value_start = match.group(2)  # opening quote
        value_content = match.group(3)  # content
        value_end = match.group(4)  # closing quote
        
        # Escape any unescaped double quotes in the value content
        # But preserve already escaped quotes (\")
        fixed_content = re.sub(r'(?<!\\)"(?!\s*[,}\]])', r'\\"', value_content)
        
        return f'{key_part} {value_start}{fixed_content}{value_end}'
    
    # Try to fix common patterns: "query": "text with "quotes""
    # This is tricky, so we'll use a simpler approach: fix quotes that appear
    # between quotes that aren't properly escaped
    
    # First, let's try to parse and see what the actual error is
    return text

for json_file in glob.glob(os.path.join(dashboard_dir, "*.json")):
    filename = os.path.basename(json_file)
    print(f"Processing: {filename}")
    
    try:
        # Read the file
        with open(json_file, 'rb') as f:
            content = f.read()
        
        # Check if file is empty
        if len(content.strip()) == 0:
            print(f"  ✗ {filename} is empty - skipping")
            error_count += 1
            continue
        
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
        
        # Remove Windows line endings
        text = text.replace('\r\n', '\n').replace('\r', '\n')
        
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
            
            # Try to fix unescaped quotes in string values
            # Pattern: find "key": "value" where value contains unescaped quotes
            lines = text.split('\n')
            fixed_lines = []
            in_string = False
            escape_next = False
            
            for i, line in enumerate(lines):
                # Simple heuristic: if we see a quote after a colon and before a comma/brace, it might need escaping
                # This is a simplified fix - for complex cases, manual editing may be needed
                if '": "' in line or '":"' in line:
                    # Try to fix obvious cases: "query": "text "with" quotes"
                    # Look for pattern: "text "word" text"
                    fixed_line = re.sub(
                        r'("(?:[^"\\]|\\.)*")\s*:\s*"([^"]*)"([^",}\]]*)"([^",}\]]*)"',
                        r'\1: "\2\\"\3\\"\4"',
                        line
                    )
                    if fixed_line != line:
                        line = fixed_line
                        print(f"    Fixed quotes on line {i+1}")
                
                fixed_lines.append(line)
            
            text = '\n'.join(fixed_lines)
            
            # Remove trailing commas
            text = re.sub(r',(\s*[}\]])', r'\1', text)
            
            # Try parsing again
            try:
                data = json.loads(text)
                with open(json_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                print(f"  ✓ {filename} fixed and is now valid")
                fixed_count += 1
            except json.JSONDecodeError as e2:
                print(f"  ✗ {filename} still has errors after fix attempt")
                print(f"    Error: {e2}")
                print(f"    Line {e2.lineno}, column {e2.colno}")
                # Show the problematic line
                if e2.lineno <= len(lines):
                    print(f"    Problematic line: {lines[e2.lineno-1][:100]}")
                error_count += 1
    except Exception as e:
        print(f"  ✗ Error processing {filename}: {e}")
        error_count += 1

print("")
print(f"Summary: {fixed_count} files fixed, {error_count} files with errors")
if error_count > 0:
    print("")
    print("For files with errors, you may need to manually fix unescaped quotes in string values.")
    print("Look for patterns like: \"query\": \"text \"with\" quotes\"")
    print("These should be: \"query\": \"text \\\"with\\\" quotes\"")

sys.exit(0 if error_count == 0 else 1)
PYTHON_SCRIPT
    PYTHON_EXIT=$?
fi

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
    echo "Some files had errors. The script attempted to fix them but manual intervention may be needed."
    echo ""
    echo "Common issue: Unescaped double quotes inside JSON string values."
    echo "Example: \"query\": \"from(bucket: \"name\")\" should be \"query\": \"from(bucket: \\\"name\\\")\""
fi

echo ""
echo "=========================================="
echo "Dashboard fix complete!"
echo "=========================================="
