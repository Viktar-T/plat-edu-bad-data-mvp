#!/bin/bash
# Comprehensive diagnostic script for Mikrus VPS server issues

set -e

echo "=========================================="
echo "Mikrus VPS Diagnostic Script"
echo "=========================================="
echo ""

cd ~/plat-edu-bad-data-mvp

echo "1. Checking Docker service status..."
echo "-----------------------------------"
sudo docker-compose ps
echo ""

echo "2. Testing Nginx health endpoint..."
echo "-----------------------------------"
sudo docker-compose exec -T nginx wget --spider -q http://localhost/nginx-health 2>&1 && echo "✓ Nginx health endpoint OK" || echo "✗ Nginx health endpoint FAILED"
echo ""

echo "3. Testing Node-RED endpoint directly..."
echo "-----------------------------------"
sudo docker-compose exec -T node-red curl -f http://localhost:1880/nodered/ 2>&1 | head -5 && echo "✓ Node-RED endpoint OK" || echo "✗ Node-RED endpoint FAILED"
echo ""

echo "4. Testing Frontend endpoint directly..."
echo "-----------------------------------"
sudo docker-compose exec -T frontend wget --spider -q http://localhost:80/ 2>&1 && echo "✓ Frontend endpoint OK" || echo "✗ Frontend endpoint FAILED"
echo ""

echo "5. Checking if Node-RED process is running..."
echo "-----------------------------------"
sudo docker-compose exec -T node-red ps aux | grep -E "(node|node-red)" | head -3 || echo "✗ Node-RED process not found"
echo ""

echo "6. Checking if Frontend nginx is running..."
echo "-----------------------------------"
sudo docker-compose exec -T frontend ps aux | grep nginx | head -3 || echo "✗ Frontend nginx not found"
echo ""

echo "7. Checking Node-RED logs (last 20 lines)..."
echo "-----------------------------------"
sudo docker-compose logs --tail=20 node-red
echo ""

echo "8. Checking Frontend logs (last 20 lines)..."
echo "-----------------------------------"
sudo docker-compose logs --tail=20 frontend
echo ""

echo "9. Testing service connectivity from Nginx..."
echo "-----------------------------------"
echo "Testing Grafana from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-grafana:3000/api/health 2>&1 && echo "✓ Grafana reachable" || echo "✗ Grafana unreachable"
echo ""

echo "Testing Node-RED from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-node-red:1880/nodered/ 2>&1 && echo "✓ Node-RED reachable" || echo "✗ Node-RED unreachable"
echo ""

echo "Testing Frontend from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-frontend:80/ 2>&1 && echo "✓ Frontend reachable" || echo "✗ Frontend unreachable"
echo ""

echo "10. Checking container resource usage..."
echo "-----------------------------------"
sudo docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Status}}"
echo ""

echo "=========================================="
echo "Diagnostic complete!"
echo "=========================================="

