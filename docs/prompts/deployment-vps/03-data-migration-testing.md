# 🚀 Phase 3: Data Migration and Testing

> **Migrate existing data, test system functionality, and validate performance on Mikrus 3.0 VPS**

## 📋 Overview

This phase covers data migration from your local development environment to the VPS, comprehensive testing of all system components, and validation of performance under production conditions.

### 🎯 Objectives
- ✅ Migrate existing data and configurations
- ✅ Test all system components and data flows
- ✅ Validate performance under load
- ✅ Verify data integrity and persistence
- ✅ Test backup and recovery procedures

---

## 🔧 Prerequisites

### ✅ Phase 2 Completion
- All Docker containers deployed and running
- Services communicating properly
- Performance monitoring active
- System stable and accessible

### ✅ Required Data
- Local development data (if any)
- Node-RED flows
- Grafana dashboards
- InfluxDB data (if migrating from existing system)

---

## 🛠️ Step-by-Step Instructions

## Step 1 – Data Migration

#### 1.1 Export Local Data (if applicable)
```bash
# On your local machine, export existing data
# Export Node-RED flows
curl -X GET http://localhost:1880/flows > node-red-flows.json

# Export Grafana dashboards
# Access Grafana UI and export each dashboard manually
# Or use Grafana API to export all dashboards

# Export InfluxDB data (if needed)
# Use InfluxDB CLI to export data
influx backup /path/to/backup/directory
```

#### 1.2 Transfer Data to VPS
```bash
# Create data transfer package
tar -czf migration-data.tar.gz \
  node-red-flows.json \
  grafana-dashboards/ \
  influxdb-backup/ \
  configuration-files/

# Transfer to VPS
scp -P 2222 migration-data.tar.gz iotadmin@YOUR_VPS_IP:/home/iotadmin/renewable-energy-iot/

# On VPS, extract data
cd /home/iotadmin/renewable-energy-iot
tar -xzf migration-data.tar.gz
```

#### 1.3 Import Node-RED Flows
```bash
# Access Node-RED on VPS
# Navigate to http://YOUR_VPS_IP:1880

# Import flows via Node-RED UI:
# 1. Open Node-RED
# 2. Click on menu (top right)
# 3. Select "Import"
# 4. Choose "Select a file to import"
# 5. Upload node-red-flows.json
# 6. Click "Import"

# Or import via API
curl -X POST http://YOUR_VPS_IP:1880/flows \
  -H "Content-Type: application/json" \
  -d @node-red-flows.json
```

#### 1.4 Import Grafana Dashboards
```bash
# Copy dashboard files to Grafana directory
cp grafana-dashboards/*.json ./grafana/dashboards/

# Restart Grafana to load new dashboards
docker-compose restart grafana

# Or import via Grafana API
for dashboard in grafana-dashboards/*.json; do
  curl -X POST http://YOUR_VPS_IP:3000/api/dashboards/db \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer YOUR_GRAFANA_TOKEN" \
    -d @$dashboard
done
```

#### 1.5 Import InfluxDB Data (if applicable)
```bash
# If you have existing InfluxDB data to migrate
docker exec -it iot-influxdb2 influx restore /backups/influxdb-backup

# Or manually import data points
# Use InfluxDB CLI or API to import historical data
```

## Step 2 – System Testing

#### 2.1 Create Comprehensive Test Suite
```bash
# Create test script
nano /home/iotadmin/system-test.sh
```

**Comprehensive Test Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Comprehensive Test Suite ==="
echo "Timestamp: $(date)"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

# Function to check service health
check_service() {
    local service_name="$1"
    local port="$2"
    local health_endpoint="$3"
    
    if [ -n "$health_endpoint" ]; then
        curl -f "http://localhost:$port$health_endpoint" > /dev/null 2>&1
    else
        curl -f "http://localhost:$port" > /dev/null 2>&1
    fi
}

echo "=== 1. Service Availability Tests ==="

run_test "MQTT Broker (Port 1883)" "check_service 'MQTT' 1883"
run_test "InfluxDB (Port 8086)" "check_service 'InfluxDB' 8086 '/health'"
run_test "Node-RED (Port 1880)" "check_service 'Node-RED' 1880"
run_test "Grafana (Port 3000)" "check_service 'Grafana' 3000 '/api/health'"
run_test "Express Backend (Port 3001)" "check_service 'Express' 3001 '/health'"
run_test "React Frontend (Port 3002)" "check_service 'React' 3002"

echo
echo "=== 2. Docker Container Tests ==="

run_test "All containers running" "docker ps --format '{{.Status}}' | grep -q 'Up'"
run_test "No container restarts" "docker ps --format '{{.Status}}' | grep -v 'Up' | wc -l | grep -q '^0$'"
run_test "Container health checks" "docker ps --format '{{.Status}}' | grep -q 'healthy'"

echo
echo "=== 3. Data Flow Tests ==="

# Test MQTT to InfluxDB flow
run_test "MQTT message publishing" "docker exec -it iot-mosquitto mosquitto_pub -h localhost -u admin -P admin_password_456 -t test/flow -m 'test_message'"
run_test "InfluxDB data writing" "curl -X POST http://localhost:8086/api/v2/write?org=renewable_energy_org&bucket=renewable_energy -H 'Authorization: Token renewable_energy_admin_token_123' -d 'test,device=test_device value=1'"

echo
echo "=== 4. Performance Tests ==="

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
if [ "$MEMORY_USAGE" -lt 80 ]; then
    echo -e "Memory Usage: ${GREEN}${MEMORY_USAGE}%${NC}"
    ((TESTS_PASSED++))
else
    echo -e "Memory Usage: ${RED}${MEMORY_USAGE}%${NC}"
    ((TESTS_FAILED++))
fi

# Check disk usage
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "Disk Usage: ${GREEN}${DISK_USAGE}%${NC}"
    ((TESTS_PASSED++))
else
    echo -e "Disk Usage: ${RED}${DISK_USAGE}%${NC}"
    ((TESTS_FAILED++))
fi

# Check CPU load
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
CPU_LOAD_NUM=$(echo $CPU_LOAD | awk '{print $1}')
if (( $(echo "$CPU_LOAD_NUM < 2.0" | bc -l) )); then
    echo -e "CPU Load: ${GREEN}${CPU_LOAD}${NC}"
    ((TESTS_PASSED++))
else
    echo -e "CPU Load: ${RED}${CPU_LOAD}${NC}"
    ((TESTS_FAILED++))
fi

echo
echo "=== 5. Network Tests ==="

run_test "External connectivity" "ping -c 1 google.com > /dev/null"
run_test "DNS resolution" "nslookup github.com > /dev/null"
run_test "Port accessibility" "netstat -tulpn | grep -q ':1883\|:8086\|:1880\|:3000\|:3001\|:3002'"

echo
echo "=== 6. Data Integrity Tests ==="

# Test InfluxDB data retention
run_test "InfluxDB bucket exists" "curl -G http://localhost:8086/api/v2/buckets?org=renewable_energy_org -H 'Authorization: Token renewable_energy_admin_token_123' | grep -q 'renewable_energy'"
run_test "InfluxDB organization exists" "curl -G http://localhost:8086/api/v2/orgs -H 'Authorization: Token renewable_energy_admin_token_123' | grep -q 'renewable_energy_org'"

echo
echo "=== 7. Security Tests ==="

run_test "SSH security" "ss -tulpn | grep ':2222' > /dev/null"
run_test "Firewall active" "sudo ufw status | grep -q 'Status: active'"
run_test "No root SSH access" "grep -q 'PermitRootLogin no' /etc/ssh/sshd_config"

echo
echo "=== Test Summary ==="
echo "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! System is ready for production.${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review and fix issues.${NC}"
    exit 1
fi
```

```bash
# Make test script executable
chmod +x /home/iotadmin/system-test.sh
```

#### 2.2 Run System Tests
```bash
# Run comprehensive test suite
./system-test.sh

# Run tests multiple times to ensure stability
for i in {1..3}; do
    echo "Test run $i/3"
    ./system-test.sh
    sleep 60
done
```

## Step 3 – Load Testing

#### 3.1 Create Load Test Script
```bash
# Create load testing script
nano /home/iotadmin/load-test.sh
```

**Load Test Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Load Testing ==="
echo "Timestamp: $(date)"
echo

# Test parameters
DURATION=300  # 5 minutes
INTERVAL=1    # 1 second between requests
CONCURRENT_USERS=10

echo "Starting load test for $DURATION seconds with $CONCURRENT_USERS concurrent users..."

# Function to simulate IoT device data
simulate_iot_data() {
    local device_id=$1
    local timestamp=$(date +%s)
    local power_output=$((RANDOM % 100 + 1))
    local temperature=$((RANDOM % 50 + 20))
    local efficiency=$((RANDOM % 100 + 50))
    
    # Send MQTT message
    docker exec -it iot-mosquitto mosquitto_pub \
        -h localhost \
        -u admin \
        -P admin_password_456 \
        -t "devices/photovoltaic/$device_id/data" \
        -m "{\"timestamp\":\"$timestamp\",\"power_output\":$power_output,\"temperature\":$temperature,\"efficiency\":$efficiency}"
    
    # Write to InfluxDB
    curl -X POST "http://localhost:8086/api/v2/write?org=renewable_energy_org&bucket=renewable_energy" \
        -H "Authorization: Token renewable_energy_admin_token_123" \
        -d "photovoltaic_data,device_id=$device_id power_output=$power_output,temperature=$temperature,efficiency=$efficiency $timestamp"
}

# Function to test API endpoints
test_api_endpoints() {
    # Test Express backend
    curl -s http://localhost:3001/health > /dev/null
    curl -s http://localhost:3001/api/energy-data > /dev/null
    
    # Test React frontend
    curl -s http://localhost:3002/ > /dev/null
    
    # Test Grafana
    curl -s http://localhost:3000/api/health > /dev/null
}

# Monitor system resources during test
monitor_resources() {
    while true; do
        echo "$(date): Memory: $(free -h | grep Mem | awk '{print $3"/"$2}'), CPU: $(uptime | awk '{print $10}'), Disk: $(df -h / | tail -1 | awk '{print $5}')"
        sleep 10
    done
}

# Start resource monitoring in background
monitor_resources &
MONITOR_PID=$!

# Start load test
echo "Starting IoT data simulation..."
for ((i=1; i<=DURATION; i++)); do
    echo "Test iteration $i/$DURATION"
    
    # Simulate multiple IoT devices
    for ((j=1; j<=CONCURRENT_USERS; j++)); do
        simulate_iot_data "device_$j" &
    done
    
    # Test API endpoints
    test_api_endpoints &
    
    sleep $INTERVAL
done

# Stop resource monitoring
kill $MONITOR_PID

echo "Load test completed!"
echo "Check system performance and logs for any issues."
```

```bash
# Make load test script executable
chmod +x /home/iotadmin/load-test.sh
```

#### 3.2 Run Load Tests
```bash
# Run load test
./load-test.sh

# Monitor results
docker stats --no-stream
./performance-monitor.sh
```

## Step 4 – Data Validation

#### 4.1 Create Data Validation Script
```bash
# Create data validation script
nano /home/iotadmin/data-validation.sh
```

**Data Validation Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Data Validation ==="
echo "Timestamp: $(date)"
echo

# Function to validate InfluxDB data
validate_influxdb_data() {
    echo "=== InfluxDB Data Validation ==="
    
    # Check if data exists
    local data_count=$(curl -s -G "http://localhost:8086/api/v2/query?org=renewable_energy_org" \
        -H "Authorization: Token renewable_energy_admin_token_123" \
        --data-urlencode "q=from(bucket:\"renewable_energy\") |> range(start: -1h) |> count()" \
        | jq -r '.results[0].series[0].values[0][1]' 2>/dev/null || echo "0")
    
    echo "Data points in last hour: $data_count"
    
    if [ "$data_count" -gt 0 ]; then
        echo "✅ InfluxDB data validation: PASS"
    else
        echo "❌ InfluxDB data validation: FAIL"
    fi
}

# Function to validate MQTT connectivity
validate_mqtt_connectivity() {
    echo "=== MQTT Connectivity Validation ==="
    
    # Test MQTT publish/subscribe
    local test_topic="validation/test"
    local test_message="validation_message_$(date +%s)"
    
    # Publish test message
    docker exec -it iot-mosquitto mosquitto_pub \
        -h localhost \
        -u admin \
        -P admin_password_456 \
        -t "$test_topic" \
        -m "$test_message" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ MQTT publish test: PASS"
    else
        echo "❌ MQTT publish test: FAIL"
    fi
}

# Function to validate Node-RED flows
validate_nodered_flows() {
    echo "=== Node-RED Flow Validation ==="
    
    # Check if Node-RED is accessible
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:1880/)
    
    if [ "$response" = "200" ]; then
        echo "✅ Node-RED accessibility: PASS"
    else
        echo "❌ Node-RED accessibility: FAIL"
    fi
}

# Function to validate Grafana dashboards
validate_grafana_dashboards() {
    echo "=== Grafana Dashboard Validation ==="
    
    # Check if Grafana is accessible
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
    
    if [ "$response" = "200" ]; then
        echo "✅ Grafana accessibility: PASS"
    else
        echo "❌ Grafana accessibility: FAIL"
    fi
}

# Function to validate web application
validate_web_application() {
    echo "=== Web Application Validation ==="
    
    # Test Express backend
    local backend_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health)
    if [ "$backend_response" = "200" ]; then
        echo "✅ Express backend: PASS"
    else
        echo "❌ Express backend: FAIL"
    fi
    
    # Test React frontend
    local frontend_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3002/)
    if [ "$frontend_response" = "200" ]; then
        echo "✅ React frontend: PASS"
    else
        echo "❌ React frontend: FAIL"
    fi
}

# Run all validations
validate_influxdb_data
validate_mqtt_connectivity
validate_nodered_flows
validate_grafana_dashboards
validate_web_application

echo
echo "=== Data Validation Complete ==="
```

```bash
# Make validation script executable
chmod +x /home/iotadmin/data-validation.sh
```

#### 4.2 Run Data Validation
```bash
# Run data validation
./data-validation.sh

# Run validation multiple times
for i in {1..5}; do
    echo "Validation run $i/5"
    ./data-validation.sh
    sleep 30
done
```

## Step 5 – Backup and Recovery Testing

#### 5.1 Create Backup Script
```bash
# Create backup script
nano /home/iotadmin/backup-system.sh
```

**Backup Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Backup ==="
echo "Timestamp: $(date)"
echo

# Create backup directory
BACKUP_DIR="/home/iotadmin/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup in: $BACKUP_DIR"

# Backup Docker volumes
echo "Backing up Docker volumes..."
docker run --rm -v renewable-energy-iot_mosquitto_data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/mosquitto_data.tar.gz -C /data .
docker run --rm -v renewable-energy-iot_influxdb_data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/influxdb_data.tar.gz -C /data .
docker run --rm -v renewable-energy-iot_node_red_data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/nodered_data.tar.gz -C /data .
docker run --rm -v renewable-energy-iot_grafana_data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/grafana_data.tar.gz -C /data .

# Backup configuration files
echo "Backing up configuration files..."
cp -r /home/iotadmin/renewable-energy-iot/mosquitto/config "$BACKUP_DIR/"
cp -r /home/iotadmin/renewable-energy-iot/grafana/provisioning "$BACKUP_DIR/"
cp -r /home/iotadmin/renewable-energy-iot/node-red/flows "$BACKUP_DIR/"
cp /home/iotadmin/renewable-energy-iot/.env "$BACKUP_DIR/"
cp /home/iotadmin/renewable-energy-iot/docker-compose.yml "$BACKUP_DIR/"

# Backup InfluxDB data (if possible)
echo "Backing up InfluxDB data..."
docker exec -it iot-influxdb2 influx backup /backups/$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo "InfluxDB backup not available"

# Create backup manifest
cat > "$BACKUP_DIR/backup-manifest.txt" << EOF
Backup created: $(date)
System: Renewable Energy IoT Monitoring
VPS: Mikrus 3.0
Components:
- MQTT Broker (Mosquitto)
- InfluxDB 2.7
- Node-RED
- Grafana
- Express Backend
- React Frontend

Backup contents:
- Docker volumes
- Configuration files
- Environment variables
- InfluxDB data (if available)

Restore instructions:
1. Stop all containers: docker-compose down
2. Extract backup files
3. Restore volumes and configurations
4. Start containers: docker-compose up -d
EOF

echo "Backup completed: $BACKUP_DIR"
echo "Backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"
```

```bash
# Make backup script executable
chmod +x /home/iotadmin/backup-system.sh
```

#### 5.2 Test Backup and Recovery
```bash
# Create backup
./backup-system.sh

# Test recovery (simulation)
echo "Testing backup integrity..."
tar -tzf /home/iotadmin/backups/*/mosquitto_data.tar.gz > /dev/null && echo "✅ Mosquitto backup: OK" || echo "❌ Mosquitto backup: FAILED"
tar -tzf /home/iotadmin/backups/*/influxdb_data.tar.gz > /dev/null && echo "✅ InfluxDB backup: OK" || echo "❌ InfluxDB backup: FAILED"
tar -tzf /home/iotadmin/backups/*/nodered_data.tar.gz > /dev/null && echo "✅ Node-RED backup: OK" || echo "❌ Node-RED backup: FAILED"
tar -tzf /home/iotadmin/backups/*/grafana_data.tar.gz > /dev/null && echo "✅ Grafana backup: OK" || echo "❌ Grafana backup: FAILED"
```

---

## 🧪 Testing and Validation

### **Test 1: End-to-End Data Flow**
```bash
# Test complete data flow from MQTT to visualization
# 1. Send test data via MQTT
docker exec -it iot-mosquitto mosquitto_pub \
  -h localhost \
  -u admin \
  -P admin_password_456 \
  -t "devices/photovoltaic/test_device/data" \
  -m '{"power_output": 50.5, "temperature": 25.3, "efficiency": 0.85}'

# 2. Verify data in InfluxDB
curl -G "http://localhost:8086/api/v2/query?org=renewable_energy_org" \
  -H "Authorization: Token renewable_energy_admin_token_123" \
  --data-urlencode "q=from(bucket:\"renewable_energy\") |> range(start: -5m) |> filter(fn: (r) => r._measurement == \"photovoltaic_data\")"

# 3. Check visualization in Grafana
# Access http://YOUR_VPS_IP:3000 and verify data appears
```

### **Test 2: Performance Under Load**
```bash
# Run load test for extended period
./load-test.sh

# Monitor system performance
watch -n 5 './performance-monitor.sh'
```

### **Test 3: Recovery Testing**
```bash
# Simulate service failure and recovery
docker-compose restart influxdb
sleep 30
./system-test.sh

# Test data persistence
docker-compose restart mosquitto
sleep 10
./data-validation.sh
```

---

## 📊 Performance Validation

### **Expected Performance Metrics:**

| Metric | Target | Monitoring Command |
|--------|--------|-------------------|
| **Response Time** | < 2s | `curl -w "@-" -o /dev/null -s http://localhost:3000` |
| **Memory Usage** | < 1.8GB | `free -h` |
| **CPU Load** | < 1.5 | `uptime` |
| **Disk Usage** | < 20GB | `df -h` |
| **Container Health** | All healthy | `docker ps` |
| **Data Throughput** | > 100 msg/min | Monitor MQTT logs |

### **Performance Baseline:**
```bash
# Create performance baseline
echo "=== Performance Baseline ===" > /home/iotadmin/performance-baseline.txt
./performance-monitor.sh >> /home/iotadmin/performance-baseline.txt
echo "Baseline created: $(date)" >> /home/iotadmin/performance-baseline.txt
```

---

## ⚠️ Troubleshooting

### **Common Issues:**

#### **Issue 1: Data Migration Failures**
```bash
# Solution: Manual data import
# Use InfluxDB CLI for data import
docker exec -it iot-influxdb2 influx write -b renewable_energy -o renewable_energy_org -t renewable_energy_admin_token_123 -f /path/to/data.csv
```

#### **Issue 2: Performance Degradation**
```bash
# Solution: Optimize resource usage
# Reduce InfluxDB retention period
# Optimize Node-RED flows
# Monitor with: docker stats
```

#### **Issue 3: Data Loss**
```bash
# Solution: Implement regular backups
# Set up automated backup cron job
# Test backup restoration procedures
```

---

## ✅ Phase 3 Completion Checklist

- [ ] **Data migration completed**
- [ ] **All system tests passed**
- [ ] **Load testing completed**
- [ ] **Data validation successful**
- [ ] **Backup and recovery tested**
- [ ] **Performance baseline established**
- [ ] **All components validated**
- [ ] **System ready for production**

---

## 🎯 Next Steps

After completing Phase 3, proceed to:
- **[Phase 4: Production Optimization](./04-production-optimization.md)**
- **[Phase 5: Monitoring and Maintenance](./05-monitoring-maintenance.md)**
- **[Phase 6: Security Hardening](./06-security-hardening.md)**

---

## 🤖 AI Prompts for This Phase

### **Prompt 1: Data Migration Strategy**
```
I need to migrate my renewable energy IoT monitoring system from local development to a VPS.
Components: MQTT broker, InfluxDB 2.7, Node-RED flows, Grafana dashboards, Express backend, React frontend.
Please help create a comprehensive data migration strategy and validation procedures.
```

### **Prompt 2: Load Testing Optimization**
```
I need to perform load testing on my renewable energy IoT system deployed on a 2GB RAM VPS.
Services: MQTT, InfluxDB, Node-RED, Grafana, Express, React.
Please help create load testing scenarios and performance monitoring for production readiness.
```

### **Prompt 3: Backup and Recovery**
```
I need to implement comprehensive backup and recovery procedures for my IoT monitoring system.
Components: Docker containers, InfluxDB time-series data, configuration files, Node-RED flows, Grafana dashboards.
Please help create automated backup scripts and recovery procedures for a production environment.
```

---

**🎉 Phase 3 Complete! Your system is now tested, validated, and ready for production optimization.**

## Use in Cursor – Generate synthetic MQTT payloads and Influx queries
```text
You are assisting with end-to-end data flow validation.
Produce:
- A Windows PowerShell block to publish test MQTT messages (via mosquitto_pub inside the container using docker exec) on topics devices/pv/TEST-001/metrics with realistic JSON payloads including ISO 8601 timestamps.
- A bash block for the VPS to write sample points to Influx via HTTP API (org/bucket/token placeholders) and to query recent points to verify ingestion.
- A checklist to confirm Grafana dashboards load and panels return data.
Show expected outputs and how to interpret failures.
```
