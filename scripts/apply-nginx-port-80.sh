#!/bin/bash

# Script to apply nginx port 80 configuration
# This restarts nginx with the new configuration

set -e

echo "🔄 Applying nginx port 80 configuration..."
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found. Please run this script from the project root."
    exit 1
fi

# Check if port 80 is available
if sudo ss -tulpn | grep -q ":80 "; then
    echo "⚠️  Warning: Port 80 appears to be in use. Checking..."
    sudo ss -tulpn | grep ":80 "
    read -p "Continue anyway? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
fi

echo "✅ Port 80 is available"
echo ""

# Stop nginx
echo "⏹️  Stopping nginx..."
sudo docker-compose stop nginx

# Remove nginx container to force recreation with new port mapping
echo "🗑️  Removing nginx container..."
sudo docker-compose rm -f nginx

# Start nginx with new configuration
echo "🚀 Starting nginx on port 80..."
sudo docker-compose up -d nginx

# Wait a moment for nginx to start
sleep 3

# Check if nginx is running
if sudo docker-compose ps nginx | grep -q "Up"; then
    echo ""
    echo "✅ Nginx is running on port 80"
    echo ""
    echo "📋 Verify the new URLs:"
    echo "   - Frontend: http://edubad.zut.edu.pl/"
    echo "   - Node-RED: http://edubad.zut.edu.pl/nodered/"
    echo "   - InfluxDB: http://edubad.zut.edu.pl/influxdb/"
    echo "   - Grafana: http://edubad.zut.edu.pl/grafana/"
    echo "   - API: http://edubad.zut.edu.pl/api/"
    echo ""
    echo "🔍 Check nginx status:"
    sudo docker-compose ps nginx
    echo ""
    echo "📋 Check nginx logs:"
    echo "   sudo docker-compose logs -f nginx"
else
    echo "❌ Error: Nginx failed to start. Check logs:"
    echo "   sudo docker-compose logs nginx"
    exit 1
fi

