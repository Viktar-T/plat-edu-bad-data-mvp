#!/bin/bash
# =============================================================================
# Combine Environment Files Script
# Renewable Energy IoT Monitoring System
# =============================================================================
# 
# This script combines .env.production (non-sensitive) and .env.secrets 
# (sensitive) into a single .env file for Docker Compose.
# 
# Usage:
#   ./scripts/combine-env-files.sh [project-directory]
# 
# If project-directory is not provided, uses current directory.
# =============================================================================

set -e

PROJECT_DIR="${1:-$(pwd)}"
CONFIG_FILE="${PROJECT_DIR}/.env.production"
SECRETS_FILE="${PROJECT_DIR}/.env.secrets"
OUTPUT_FILE="${PROJECT_DIR}/.env"

echo "🔧 Combining environment files..."
echo "   Config: ${CONFIG_FILE}"
echo "   Secrets: ${SECRETS_FILE}"
echo "   Output: ${OUTPUT_FILE}"

# Check if files exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: .env.production not found at ${CONFIG_FILE}"
    exit 1
fi

if [ ! -f "$SECRETS_FILE" ]; then
    echo "❌ Error: .env.secrets not found at ${SECRETS_FILE}"
    exit 1
fi

# Combine files (config first, then secrets - secrets override if duplicates)
cat "$CONFIG_FILE" "$SECRETS_FILE" > "$OUTPUT_FILE"

# Set secure permissions
chmod 600 "$OUTPUT_FILE"
chmod 600 "$SECRETS_FILE"

# Get current user
CURRENT_USER=$(whoami)
chown "$CURRENT_USER:$CURRENT_USER" "$OUTPUT_FILE" "$SECRETS_FILE" 2>/dev/null || true

echo "✅ Environment files combined successfully"
echo "   Output file: ${OUTPUT_FILE}"
echo "   Permissions: 600 (read/write owner only)"
echo ""
echo "⚠️  Security reminder:"
echo "   - .env.secrets contains sensitive data"
echo "   - Keep it secure and never commit to Git"
echo "   - File permissions set to 600 (owner read/write only)"


