#!/usr/bin/env python3
"""
Fix unescaped quotes in Grafana dashboard JSON files
"""
import json
import re
import sys
import os

def fix_unescaped_quotes_in_json(text):
    """Fix unescaped double quotes inside JSON string values"""
    lines = text.split('\n')
    fixed_lines = []
    
    for line_num, line in enumerate(lines, 1):
        # Look for patterns like: "key": "value with "quotes" inside"
        # We need to escape quotes that are inside string values but not the quotes that delimit the string
        
        # Pattern to match: "key": "value"
        # We'll use a state machine approach
        result = []
        i = 0
        in_key = False
        in_value_string = False
        key_start = -1
        value_start = -1
        
        while i < len(line):
            char = line[i]
            
            # Track when we're in a key
            if char == '"' and not in_value_string:
                if not in_key:
                    in_key = True
                    key_start = i
                else:
                    in_key = False
                    # Check if next is colon (we're at end of key)
                    j = i + 1
                    while j < len(line) and line[j] in ' \t':
                        j += 1
                    if j < len(line) and line[j] == ':':
                        # This is a key, next should be value
                        result.append(char)
                        i += 1
                        # Skip whitespace and colon
                        while i < len(line) and line[i] in ' \t:':
                            result.append(line[i])
                            i += 1
                        # If next is quote, we're starting a string value
                        if i < len(line) and line[i] == '"':
                            in_value_string = True
                            value_start = i
                            result.append('"')
                            i += 1
                            continue
                    else:
                        result.append(char)
                        i += 1
                        continue
                result.append(char)
                i += 1
            elif in_value_string and char == '"':
                # Check if this is an escaped quote
                if i > 0 and line[i-1] == '\\':
                    result.append(char)
                    i += 1
                else:
                    # Check if this is the end of the string value
                    # Look ahead to see if next non-whitespace is comma, }, or ]
                    j = i + 1
                    while j < len(line) and line[j] in ' \t':
                        j += 1
                    if j >= len(line) or line[j] in ',}]':
                        # End of string value
                        in_value_string = False
                        result.append(char)
                        i += 1
                    else:
                        # This is an unescaped quote inside the string - escape it
                        result.append('\\"')
                        i += 1
            else:
                result.append(char)
                i += 1
        
        fixed_lines.append(''.join(result))
    
    return '\n'.join(fixed_lines)

def fix_json_file(filepath):
    """Fix a single JSON file"""
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # Remove BOM
        if content.startswith(b'\xef\xbb\xbf'):
            content = content[3:]
        
        # Decode
        try:
            text = content.decode('utf-8')
        except UnicodeDecodeError:
            text = content.decode('latin-1')
        
        # Remove null bytes and normalize line endings
        text = text.replace('\x00', '').replace('\r\n', '\n').replace('\r', '\n')
        
        # Try to parse
        try:
            data = json.loads(text)
            # Valid JSON, write it back
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            return True, "Valid JSON"
        except json.JSONDecodeError as e:
            # Try to fix unescaped quotes
            fixed_text = fix_unescaped_quotes_in_json(text)
            
            # Remove trailing commas
            fixed_text = re.sub(r',(\s*[}\]])', r'\1', fixed_text)
            
            try:
                data = json.loads(fixed_text)
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                return True, "Fixed and valid"
            except json.JSONDecodeError as e2:
                return False, f"Still invalid: {e2}"
    except Exception as e:
        return False, f"Error: {e}"

if __name__ == '__main__':
    dashboard_dir = sys.argv[1] if len(sys.argv) > 1 else "grafana/dashboards"
    
    import glob
    fixed = 0
    errors = 0
    
    for json_file in glob.glob(os.path.join(dashboard_dir, "*.json")):
        filename = os.path.basename(json_file)
        print(f"Processing: {filename}")
        success, message = fix_json_file(json_file)
        if success:
            print(f"  ✓ {filename}: {message}")
            fixed += 1
        else:
            print(f"  ✗ {filename}: {message}")
            errors += 1
    
    print(f"\nSummary: {fixed} fixed, {errors} errors")
    sys.exit(0 if errors == 0 else 1)

