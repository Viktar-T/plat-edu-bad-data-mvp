#!/bin/bash
# Diagnostic and fix script for Mikrus VPS

set -e

echo "=== Diagnosing Issues on Mikrus VPS ==="
echo ""

cd ~/plat-edu-bad-data-mvp

echo "1. Checking service logs..."
echo ""
echo "--- Nginx logs (last 30 lines) ---"
sudo docker-compose logs --tail=30 nginx

echo ""
echo "--- Node-RED logs (last 30 lines) ---"
sudo docker-compose logs --tail=30 node-red

echo ""
echo "--- Frontend logs (last 30 lines) ---"
sudo docker-compose logs --tail=30 frontend

echo ""
echo "2. Testing health endpoints directly..."
echo ""
echo "Testing Nginx /health endpoint:"
sudo docker-compose exec nginx wget -qO- http://localhost/health 2>/dev/null || echo "Failed"

echo ""
echo "Testing Nginx /nginx-health endpoint:"
sudo docker-compose exec nginx wget -qO- http://localhost/nginx-health 2>/dev/null || echo "Failed"

echo ""
echo "Testing Node-RED endpoint:"
sudo docker-compose exec node-red curl -f http://localhost:1880/nodered/ || echo "Failed"

echo ""
echo "Testing Frontend endpoint:"
sudo docker-compose exec frontend wget --quiet --tries=1 --spider http://localhost:80/ || echo "Failed"

echo ""
echo "3. Checking if services are actually running..."
sudo docker-compose exec nginx ps aux | grep nginx || echo "Nginx not running"
sudo docker-compose exec node-red ps aux | grep node || echo "Node-RED not running"
sudo docker-compose exec frontend ps aux | grep nginx || echo "Frontend not running"

echo ""
echo "=== Diagnosis complete ==="

