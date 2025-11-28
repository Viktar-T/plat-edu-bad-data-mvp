#!/bin/bash

# Clean up Docker resources to free disk space
# Use this when you get "no space left on device" errors

set -e

echo "🔍 Checking disk space..."
df -h

echo ""
echo "🗑️  Cleaning up Docker resources..."

# Remove stopped containers
echo "   Removing stopped containers..."
sudo docker container prune -f

# Remove unused images
echo "   Removing unused images..."
sudo docker image prune -a -f

# Remove unused volumes (be careful - this removes unused volumes)
echo "   Removing unused volumes..."
sudo docker volume prune -f

# Remove build cache
echo "   Removing build cache..."
sudo docker builder prune -a -f

echo ""
echo "📊 Docker disk usage:"
sudo docker system df

echo ""
echo "💾 Disk space after cleanup:"
df -h

echo ""
echo "✅ Cleanup complete!"

