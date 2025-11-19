#!/usr/bin/env python3
"""
Fix unescaped quotes in Grafana dashboard JSON files
Specifically fixes: from(bucket: "name") -> from(bucket: \"name\")
"""
import json
import re
import sys
import os

def fix_flux_quotes(text):
    """Fix unescaped quotes in Flux query strings"""
    # Pattern: from(bucket: "bucket-name") -> from(bucket: \"bucket-name\")
    # Also: from(bucket: "bucket-name") -> from(bucket: \"bucket-name\")
    
    # Fix pattern: from(bucket: "name")
    text = re.sub(r'from\(bucket:\s*"([^"]+)"\)', r'from(bucket: "\\1")', text)
    
    # Fix pattern: from(bucket: "name") in union
    text = re.sub(r'union\(tables:\s*\[from\(bucket:\s*"([^"]+)"\)', r'union(tables: [from(bucket: "\\1")', text)
    
    # Fix any remaining unescaped quotes inside "query": "..." strings
    # This is more complex - we need to find query fields and fix quotes inside them
    lines = text.split('\n')
    fixed_lines = []
    in_query_field = False
    
    for line in lines:
        # Check if this line contains a query field
        if '"query":' in line or '"query" :' in line:
            in_query_field = True
            # Extract the query value part
            # Pattern: "query": "value"
            match = re.search(r'("query"\s*:\s*")(.*)(")', line)
            if match:
                prefix = match.group(1)
                query_content = match.group(2)
                suffix = match.group(3)
                
                # Fix unescaped quotes in the query content
                # Replace " with \" but preserve already escaped quotes
                # Pattern: find " that are not preceded by \ and not at start/end
                fixed_query = re.sub(r'(?<!\\)"(?![,}\]])', r'\\"', query_content)
                
                line = prefix + fixed_query + suffix
            in_query_field = False
        elif in_query_field and line.strip().endswith('",'):
            # Continuation of query field
            # Fix quotes in this line too
            line = re.sub(r'(?<!\\)"(?![,}\]])', r'\\"', line)
            in_query_field = False
        elif in_query_field:
            # Continuation of query field
            line = re.sub(r'(?<!\\)"(?![,}\]])', r'\\"', line)
        
        fixed_lines.append(line)
    
    return '\n'.join(fixed_lines)

def fix_json_file(filepath):
    """Fix a single JSON file"""
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # Check if empty
        if len(content.strip()) == 0:
            return False, "File is empty"
        
        # Remove BOM
        if content.startswith(b'\xef\xbb\xbf'):
            content = content[3:]
        
        # Decode
        try:
            text = content.decode('utf-8')
        except UnicodeDecodeError:
            text = content.decode('latin-1')
        
        # Normalize
        text = text.replace('\x00', '').replace('\r\n', '\n').replace('\r', '\n')
        
        # Try to parse
        try:
            data = json.loads(text)
            # Valid JSON, write it back
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            return True, "Valid JSON"
        except json.JSONDecodeError as e:
            # Try to fix
            fixed_text = fix_flux_quotes(text)
            
            # Remove trailing commas
            fixed_text = re.sub(r',(\s*[}\]])', r'\1', fixed_text)
            
            try:
                data = json.loads(fixed_text)
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                return True, "Fixed and valid"
            except json.JSONDecodeError as e2:
                # Last resort: try to manually fix the specific pattern
                # Find all "query": "..." and fix quotes inside
                def fix_query_quotes(m):
                    key = m.group(1)
                    query = m.group(2)
                    # Escape all unescaped quotes in query
                    fixed_query = query.replace('"', '\\"')
                    return f'{key}"{fixed_query}"'
                
                # More aggressive fix
                fixed_text = re.sub(
                    r'("query"\s*:\s*")([^"]*(?:"[^",}\]]*)*)(")',
                    lambda m: m.group(1) + m.group(2).replace('"', '\\"') + m.group(3),
                    fixed_text,
                    flags=re.MULTILINE
                )
                
                try:
                    data = json.loads(fixed_text)
                    with open(filepath, 'w', encoding='utf-8') as f:
                        json.dump(data, f, indent=2, ensure_ascii=False)
                    return True, "Fixed with aggressive method"
                except:
                    return False, f"Could not fix: {e2}"
    except Exception as e:
        return False, f"Error: {e}"

if __name__ == '__main__':
    dashboard_dir = sys.argv[1] if len(sys.argv) > 1 else "grafana/dashboards"
    
    import glob
    fixed = 0
    errors = 0
    
    for json_file in sorted(glob.glob(os.path.join(dashboard_dir, "*.json"))):
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
