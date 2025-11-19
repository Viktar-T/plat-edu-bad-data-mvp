#!/bin/bash
# Comprehensive diagnostic script for Mikrus VPS server issues

set -e

echo "=========================================="
echo "Mikrus VPS Comprehensive Diagnostic Script"
echo "=========================================="
echo "Date: $(date)"
echo ""

cd ~/plat-edu-bad-data-mvp

# =============================================================================
# 1. SYSTEM INFORMATION
# =============================================================================
echo "1. SYSTEM INFORMATION"
echo "-----------------------------------"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""
echo "Disk Usage:"
df -h / | tail -1
echo ""
echo "Memory Usage:"
free -h | grep -E "Mem|Swap"
echo ""
echo "Docker Version:"
docker --version 2>/dev/null || echo "Docker not found"
docker compose version 2>/dev/null || echo "Docker Compose not found"
echo ""

# =============================================================================
# 2. DOCKER SERVICE STATUS
# =============================================================================
echo "2. DOCKER SERVICE STATUS"
echo "-----------------------------------"
sudo docker-compose ps
echo ""

# =============================================================================
# 3. HEALTH CHECK DETAILS
# =============================================================================
echo "3. HEALTH CHECK DETAILS"
echo "-----------------------------------"
for service in api frontend grafana influxdb mosquitto nginx node-red; do
    health=$(sudo docker inspect iot-${service} 2>/dev/null | grep -A 5 '"Health"' | grep '"Status"' | cut -d'"' -f4 || echo "N/A")
    echo "${service}: ${health}"
done
echo ""

# =============================================================================
# 4. PORT LISTENING CHECKS
# =============================================================================
echo "4. PORT LISTENING CHECKS"
echo "-----------------------------------"
echo "Checking if services are listening on expected ports:"
echo ""
echo "Node-RED (1880):"
sudo docker-compose exec -T node-red netstat -tlnp 2>/dev/null | grep 1880 || echo "  ✗ Not listening on 1880"
echo ""
echo "Frontend (80):"
sudo docker-compose exec -T frontend netstat -tlnp 2>/dev/null | grep ":80 " || echo "  ✗ Not listening on 80"
echo ""
echo "Grafana (3000):"
sudo docker-compose exec -T grafana netstat -tlnp 2>/dev/null | grep 3000 || echo "  ✗ Not listening on 3000"
echo ""
echo "InfluxDB (8086):"
sudo docker-compose exec -T influxdb netstat -tlnp 2>/dev/null | grep 8086 || echo "  ✗ Not listening on 8086"
echo ""
echo "API (3001):"
sudo docker-compose exec -T api netstat -tlnp 2>/dev/null | grep 3001 || echo "  ✗ Not listening on 3001"
echo ""
echo "Nginx (80):"
sudo docker-compose exec -T nginx netstat -tlnp 2>/dev/null | grep ":80 " || echo "  ✗ Not listening on 80"
echo ""

# =============================================================================
# 5. INTERNAL HEALTH ENDPOINT TESTS
# =============================================================================
echo "5. INTERNAL HEALTH ENDPOINT TESTS"
echo "-----------------------------------"
echo "Testing Nginx health endpoint:"
sudo docker-compose exec -T nginx wget --spider -q http://127.0.0.1/nginx-health 2>&1 && echo "  ✓ Nginx health endpoint OK" || echo "  ✗ Nginx health endpoint FAILED"
echo ""
echo "Testing Node-RED endpoint directly:"
sudo docker-compose exec -T node-red curl -f -s http://127.0.0.1:1880/nodered/ > /dev/null 2>&1 && echo "  ✓ Node-RED endpoint OK" || echo "  ✗ Node-RED endpoint FAILED"
echo ""
echo "Testing Frontend endpoint directly:"
sudo docker-compose exec -T frontend wget --spider -q http://127.0.0.1:80/ 2>&1 && echo "  ✓ Frontend endpoint OK" || echo "  ✗ Frontend endpoint FAILED"
echo ""
echo "Testing API health endpoint:"
sudo docker-compose exec -T api curl -f -s http://127.0.0.1:3001/health > /dev/null 2>&1 && echo "  ✓ API health endpoint OK" || echo "  ✗ API health endpoint FAILED"
echo ""
echo "Testing Grafana health endpoint:"
sudo docker-compose exec -T grafana curl -f -s http://127.0.0.1:3000/api/health > /dev/null 2>&1 && echo "  ✓ Grafana health endpoint OK" || echo "  ✗ Grafana health endpoint FAILED"
echo ""
echo "Testing InfluxDB health endpoint:"
sudo docker-compose exec -T influxdb curl -f -s http://127.0.0.1:8086/health > /dev/null 2>&1 && echo "  ✓ InfluxDB health endpoint OK" || echo "  ✗ InfluxDB health endpoint FAILED"
echo ""

# =============================================================================
# 6. PROCESS CHECKS
# =============================================================================
echo "6. PROCESS CHECKS"
echo "-----------------------------------"
echo "Node-RED processes:"
sudo docker-compose exec -T node-red ps aux | grep -E "(node|node-red)" | grep -v grep | head -3 || echo "  ✗ Node-RED process not found"
echo ""
echo "Frontend nginx processes:"
sudo docker-compose exec -T frontend ps aux | grep nginx | grep -v grep | head -3 || echo "  ✗ Frontend nginx not found"
echo ""
echo "Nginx processes:"
sudo docker-compose exec -T nginx ps aux | grep nginx | grep -v grep | head -3 || echo "  ✗ Nginx process not found"
echo ""

# =============================================================================
# 7. NETWORK CONNECTIVITY BETWEEN CONTAINERS
# =============================================================================
echo "7. NETWORK CONNECTIVITY BETWEEN CONTAINERS"
echo "-----------------------------------"
echo "Testing Grafana from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-grafana:3000/api/health 2>&1 && echo "  ✓ Grafana reachable from Nginx" || echo "  ✗ Grafana unreachable from Nginx"
echo ""
echo "Testing Node-RED from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-node-red:1880/nodered/ 2>&1 && echo "  ✓ Node-RED reachable from Nginx" || echo "  ✗ Node-RED unreachable from Nginx"
echo ""
echo "Testing Frontend from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-frontend:80/ 2>&1 && echo "  ✓ Frontend reachable from Nginx" || echo "  ✗ Frontend unreachable from Nginx"
echo ""
echo "Testing API from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-api:3001/health 2>&1 && echo "  ✓ API reachable from Nginx" || echo "  ✗ API unreachable from Nginx"
echo ""
echo "Testing InfluxDB from Nginx:"
sudo docker-compose exec -T nginx wget --spider -q http://iot-influxdb2:8086/health 2>&1 && echo "  ✓ InfluxDB reachable from Nginx" || echo "  ✗ InfluxDB unreachable from Nginx"
echo ""

# =============================================================================
# 8. EXTERNAL ACCESSIBILITY THROUGH NGINX
# =============================================================================
echo "8. EXTERNAL ACCESSIBILITY THROUGH NGINX"
echo "-----------------------------------"
echo "Testing Grafana through Nginx (localhost:20108):"
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://localhost:20108/grafana/ || echo "  ✗ Failed to connect"
echo ""
echo "Testing Node-RED through Nginx (localhost:20108):"
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://localhost:20108/nodered/ || echo "  ✗ Failed to connect"
echo ""
echo "Testing InfluxDB through Nginx (localhost:20108):"
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://localhost:20108/influxdb/ || echo "  ✗ Failed to connect"
echo ""
echo "Testing API through Nginx (localhost:20108):"
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://localhost:20108/api/ || echo "  ✗ Failed to connect"
echo ""
echo "Testing Frontend through Nginx (localhost:20108):"
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://localhost:20108/app/ || echo "  ✗ Failed to connect"
echo ""
echo "Testing Nginx health endpoint (localhost:20108):"
curl -s http://localhost:20108/nginx-health && echo "" || echo "  ✗ Failed to connect"
echo ""

# =============================================================================
# 9. RECENT ERRORS IN LOGS
# =============================================================================
echo "9. RECENT ERRORS IN LOGS (last 10 error lines per service)"
echo "-----------------------------------"
for service in api frontend grafana influxdb mosquitto nginx node-red; do
    echo "${service} errors:"
    sudo docker-compose logs --tail=100 ${service} 2>&1 | grep -i error | tail -5 || echo "  No recent errors found"
    echo ""
done

# =============================================================================
# 10. CONTAINER RESOURCE USAGE
# =============================================================================
echo "10. CONTAINER RESOURCE USAGE"
echo "-----------------------------------"
sudo docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null || echo "Unable to get stats"
echo ""

# =============================================================================
# 11. DOCKER NETWORK INFORMATION
# =============================================================================
echo "11. DOCKER NETWORK INFORMATION"
echo "-----------------------------------"
echo "Network: iot-network"
sudo docker network inspect iot-network 2>/dev/null | grep -A 3 "Containers" | head -20 || echo "  Network not found"
echo ""

# =============================================================================
# 12. CONFIGURATION FILE CHECKS
# =============================================================================
echo "12. CONFIGURATION FILE CHECKS"
echo "-----------------------------------"
echo "Checking nginx.conf syntax:"
sudo docker-compose exec -T nginx nginx -t 2>&1 | tail -2 || echo "  ✗ Nginx config check failed"
echo ""
echo "Checking if .env file exists:"
[ -f .env ] && echo "  ✓ .env file exists" || echo "  ✗ .env file missing"
echo ""
echo "Checking if docker-compose.yml exists:"
[ -f docker-compose.yml ] && echo "  ✓ docker-compose.yml exists" || echo "  ✗ docker-compose.yml missing"
echo ""

# =============================================================================
# 13. ENVIRONMENT VARIABLES CHECK
# =============================================================================
echo "13. ENVIRONMENT VARIABLES CHECK (non-sensitive)"
echo "-----------------------------------"
echo "Nginx port: ${NGINX_PORT:-20108}"
echo "Nginx HTTPS port: ${NGINX_HTTPS_PORT:-30108}"
echo "MQTT port: ${MQTT_PORT:-40098}"
echo ""

# =============================================================================
# 14. RECENT LOGS SUMMARY
# =============================================================================
echo "14. RECENT LOGS SUMMARY (last 5 lines per service)"
echo "-----------------------------------"
for service in api frontend grafana influxdb mosquitto nginx node-red; do
    echo "${service} (last 5 lines):"
    sudo docker-compose logs --tail=5 ${service} 2>&1 | sed 's/^/  /'
    echo ""
done

# =============================================================================
# SUMMARY
# =============================================================================
echo "=========================================="
echo "DIAGNOSTIC SUMMARY"
echo "=========================================="
healthy_count=$(sudo docker-compose ps | grep -c "healthy" || echo "0")
total_count=$(sudo docker-compose ps | grep -c "Up" || echo "0")
echo "Healthy services: ${healthy_count}/${total_count}"
echo ""
echo "Services status:"
sudo docker-compose ps --format "table {{.Name}}\t{{.Status}}"
echo ""
echo "=========================================="
echo "Diagnostic complete at $(date)"
echo "=========================================="
