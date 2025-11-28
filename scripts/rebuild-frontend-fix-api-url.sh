#!/bin/bash

# Rebuild frontend with correct API URL
# This script ensures the build uses the correct API URL without /api

set -e

cd ~/plat-edu-bad-data-mvp

echo "🔍 Checking current configuration..."
echo "   VITE_API_URL should be: http://edubad.zut.edu.pl:8080 (without /api)"
echo ""

# Unset any environment variables that might interfere
unset VITE_API_URL
unset VITE_API_BASE_URL

echo "🗑️  Removing old frontend image and container..."
sudo docker-compose stop frontend 2>/dev/null || true
sudo docker-compose rm -f frontend 2>/dev/null || true
sudo docker rmi plat-edu-bad-data-mvp_frontend 2>/dev/null || true

echo ""
echo "🔨 Rebuilding frontend with correct API URL..."
echo "   Build args:"
echo "   - VITE_API_URL=http://edubad.zut.edu.pl:8080"
echo "   - VITE_API_BASE_URL=http://edubad.zut.edu.pl:8080/api"
echo ""

# Build with explicit args to ensure they're used
sudo docker-compose build --no-cache \
  --build-arg VITE_API_URL=http://edubad.zut.edu.pl:8080 \
  --build-arg VITE_API_BASE_URL=http://edubad.zut.edu.pl:8080/api \
  --build-arg NODE_ENV=production \
  frontend

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "🚀 Starting frontend container..."
    sudo docker-compose up -d frontend
    
    echo ""
    echo "🔍 Verifying the built URL..."
    sleep 5
    sudo docker exec iot-frontend sh -c "grep -o 'http://[^\"'\'' ]*edubad[^\"'\'' ]*' /usr/share/nginx/html/assets/index-*.js | head -3" || echo "   Could not verify (this is okay)"
    
    echo ""
    echo "✅ Frontend rebuilt and started!"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Hard refresh your browser: Ctrl+Shift+R (or Cmd+Shift+R on Mac)"
    echo "   2. Open DevTools (F12) → Network tab → Check 'Disable cache'"
    echo "   3. Check if API calls go to: http://edubad.zut.edu.pl:8080/api/summary/..."
    echo "   4. Should NOT see: http://edubad.zut.edu.pl:8080/api/api/summary/..."
else
    echo ""
    echo "❌ Build failed!"
    echo "   Check disk space: df -h"
    echo "   Clean Docker: sudo docker system prune -a -f"
    exit 1
fi

