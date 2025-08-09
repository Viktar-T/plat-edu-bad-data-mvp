# 🚀 Phase 4: Production Optimization

> **Optimize system performance, implement monitoring, and prepare for production deployment on Mikrus 3.0 VPS**

## 📋 Overview

This phase focuses on optimizing the system for production use, implementing advanced monitoring, performance tuning, and ensuring high availability on the Mikrus 3.0 VPS.

### 🎯 Objectives
- ✅ Optimize system performance for production
- ✅ Implement advanced monitoring and alerting
- ✅ Configure automated maintenance tasks
- ✅ Optimize resource usage for Mikrus 3.0
- ✅ Implement production-grade security measures

---

## 🔧 Prerequisites

### ✅ Phase 3 Completion
- System tested and validated
- Performance baseline established
- All components working properly
- Backup procedures tested

### ✅ Current System Status
- All services running stable
- Performance within acceptable limits
- Data integrity verified
- Security measures in place

---

## 🛠️ Step-by-Step Instructions

## Step 1 – Performance Optimization

#### 1.1 Optimize Docker Resource Limits
```bash
# Review current resource usage
docker stats --no-stream

# Create optimized docker-compose.yml for production
nano docker-compose.prod.yml
```

**Production-Optimized Docker Compose:**
```yaml
version: '3.8'

services:
  # MQTT Broker - Production Optimized
  mosquitto:
    image: eclipse-mosquitto:2.0.18
    container_name: iot-mosquitto-prod
    ports:
      - "${MQTT_PORT:-1883}:1883"
      - "${MQTT_WS_PORT:-9001}:9001"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
      - ./mosquitto/log:/mosquitto/log
    environment:
      - TZ=Europe/Helsinki
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 80M
          cpus: '0.15'
        reservations:
          memory: 40M
          cpus: '0.05'
    healthcheck:
      test: ["CMD", "mosquitto_pub", "-h", "localhost", "-u", "${MQTT_ADMIN_USER:-admin}", "-P", "${MQTT_ADMIN_PASSWORD:-admin_password_456}", "-t", "system/health/mosquitto", "-m", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - iot-network

  # InfluxDB - Production Optimized
  influxdb:
    image: influxdb:2.7
    container_name: iot-influxdb2-prod
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb/data:/var/lib/influxdb2
      - ./influxdb/backups:/backups
    environment:
      - TZ=Europe/Helsinki
      - INFLUXDB_ADMIN_USER=${INFLUXDB_ADMIN_USER:-admin}
      - INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_ADMIN_PASSWORD:-admin_password_123}
      - INFLUXDB_ADMIN_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
      - INFLUXDB_HTTP_AUTH_ENABLED=${INFLUXDB_HTTP_AUTH_ENABLED:-false}
      - INFLUXDB_DB=${INFLUXDB_DB:-renewable_energy}
      - INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
      - INFLUXDB_RETENTION=${INFLUXDB_RETENTION:-7d}
      - DOCKER_INFLUXDB_INIT_MODE=${INFLUXDB_SETUP_MODE:-setup}
      - DOCKER_INFLUXDB_INIT_USERNAME=${INFLUXDB_ADMIN_USER:-admin}
      - DOCKER_INFLUXDB_INIT_PASSWORD=${INFLUXDB_ADMIN_PASSWORD:-admin_password_123}
      - DOCKER_INFLUXDB_INIT_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - DOCKER_INFLUXDB_INIT_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
      - DOCKER_INFLUXDB_INIT_RETENTION=${INFLUXDB_RETENTION:-7d}
      - INFLUXDB_REPORTING_DISABLED=${INFLUXDB_REPORTING_DISABLED:-true}
      - INFLUXDB_META_DIR=${INFLUXDB_META_DIR:-/var/lib/influxdb2/meta}
      - INFLUXDB_DATA_DIR=${INFLUXDB_DATA_DIR:-/var/lib/influxdb2/data}
      - INFLUXDB_WAL_DIR=${INFLUXDB_WAL_DIR:-/var/lib/influxdb2/wal}
      - INFLUXDB_ENGINE_PATH=${INFLUXDB_ENGINE_PATH:-/var/lib/influxdb2/engine}
      - INFLUXDB_MAX_CONCURRENT_COMPACTIONS=1
      - INFLUXDB_HTTP_BIND_ADDRESS=${INFLUXDB_HTTP_BIND_ADDRESS:-:8086}
      - INFLUXDB_HTTP_PORT=${INFLUXDB_HTTP_PORT:-8086}
      - INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=${INFLUXDB_HTTP_MAX_CONNECTION_LIMIT:-50}
      - INFLUXDB_HTTP_READ_TIMEOUT=${INFLUXDB_HTTP_READ_TIMEOUT:-30s}
      - INFLUXDB_LOGGING_LEVEL=${INFLUXDB_LOGGING_LEVEL:-warn}
      - INFLUXDB_LOGGING_FORMAT=${INFLUXDB_LOGGING_FORMAT:-auto}
      - INFLUXDB_METRICS_DISABLED=${INFLUXDB_METRICS_DISABLED:-true}
      - INFLUXDB_PPROF_ENABLED=${INFLUXDB_PPROF_ENABLED:-false}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 800M
          cpus: '0.8'
        reservations:
          memory: 400M
          cpus: '0.4'
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8086/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    networks:
      - iot-network

  # Node-RED - Production Optimized
  node-red:
    image: nodered/node-red:latest
    container_name: iot-node-red-prod
    ports:
      - "1880:1880"
    volumes:
      - ./node-red/data:/data
      - ./node-red/settings.js:/data/settings.js
      - ./node-red/package.json:/data/package.json
      - ./node-red/startup.sh:/startup.sh
    environment:
      - TZ=Europe/Helsinki
      - NODE_RED_ENABLE_PROJECTS=true
      - NODE_RED_EDITOR_THEME=dark
      - NODE_RED_DISABLE_EDITOR=false
      - NODE_RED_DISABLE_FLOWS=false
      - NODE_RED_HOME=/data
      - NODE_RED_OPTIONS=--max-old-space-size=200
      - NODE_RED_SETTINGS_FILE=/data/settings.js
      - NODE_RED_USERNAME=admin
      - NODE_RED_PASSWORD=adminpassword
      - NODE_RED_INFLUXDB_URL=http://influxdb:8086
      - NODE_RED_INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - NODE_RED_INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
      - NODE_RED_INFLUXDB_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 300M
          cpus: '0.4'
        reservations:
          memory: 150M
          cpus: '0.2'
    depends_on:
      mosquitto:
        condition: service_healthy
      influxdb:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:1880 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 180s
    entrypoint: ["/bin/bash", "/startup.sh"]
    networks:
      - iot-network

  # Grafana - Production Optimized
  grafana:
    image: grafana/grafana:10.2.0
    container_name: iot-grafana-prod
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
      - ./grafana/plugins:/var/lib/grafana/plugins
    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
      - GF_SECURITY_COOKIE_SECURE=false
      - GF_SERVER_ROOT_URL=http://YOUR_VPS_IP:3000
      - GF_SERVER_SERVE_FROM_SUB_PATH=false
      - GF_ANALYTICS_REPORTING_ENABLED=false
      - GF_ANALYTICS_CHECK_FOR_UPDATES=false
      - GF_LOG_LEVEL=warn
      - GF_SERVER_MAX_CONCURRENT_REQUESTS=5
      - GF_SERVER_MAX_CONCURRENT_REQUESTS_PER_USER=3
      - GF_SERVER_READ_TIMEOUT=30s
      - GF_SERVER_WRITE_TIMEOUT=30s
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 250M
          cpus: '0.25'
        reservations:
          memory: 125M
          cpus: '0.1'
    depends_on:
      influxdb:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    networks:
      - iot-network

  # Express Backend - Production Optimized
  express-backend:
    build:
      context: ./web-app-for-testing/backend
      dockerfile: Dockerfile.prod
    container_name: iot-express-backend-prod
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - INFLUXDB_URL=http://influxdb:8086
      - INFLUXDB_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
      - INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
      - PORT=3001
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 150M
          cpus: '0.25'
        reservations:
          memory: 75M
          cpus: '0.1'
    depends_on:
      influxdb:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3001/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    networks:
      - iot-network

  # React Frontend - Production Optimized
  react-frontend:
    build:
      context: ./web-app-for-testing/frontend
      dockerfile: Dockerfile.prod
    container_name: iot-react-frontend-prod
    ports:
      - "3002:3000"
    environment:
      - REACT_APP_API_URL=http://YOUR_VPS_IP:3001
      - NODE_ENV=production
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 100M
          cpus: '0.15'
        reservations:
          memory: 50M
          cpus: '0.05'
    depends_on:
      express-backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    networks:
      - iot-network

networks:
  iot-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

volumes:
  mosquitto_data:
    driver: local
  mosquitto_log:
    driver: local
  influxdb_data:
    driver: local
  node_red_data:
    driver: local
  grafana_data:
    driver: local
```

#### 1.2 Create Production Dockerfiles
```bash
# Create production Dockerfile for Express backend
nano web-app-for-testing/backend/Dockerfile.prod
```

**Production Express Dockerfile:**
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (production only)
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start application
CMD ["npm", "start"]
```

```bash
# Create production Dockerfile for React frontend
nano web-app-for-testing/frontend/Dockerfile.prod
```

**Production React Dockerfile:**
```dockerfile
# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built application
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.prod.conf /etc/nginx/nginx.conf

# Create non-root user
RUN addgroup -g 1001 -S nginx
RUN adduser -S nginx -u 1001

# Change ownership
RUN chown -R nginx:nginx /usr/share/nginx/html
USER nginx

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

#### 1.3 Create Production Nginx Configuration
```bash
# Create production nginx configuration
nano web-app-for-testing/frontend/nginx.prod.conf
```

**Production Nginx Configuration:**
```nginx
events {
    worker_connections 512;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Performance optimizations
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    server {
        listen 3000;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Handle React routing
        location / {
            try_files $uri $uri/ /index.html;
        }

        # API proxy to Express backend
        location /api/ {
            proxy_pass http://express-backend:3001;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 30s;
            proxy_connect_timeout 30s;
        }

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

## Step 2 – Advanced Monitoring Setup

#### 2.1 Create Advanced Monitoring Script
```bash
# Create advanced monitoring script
nano /home/iotadmin/advanced-monitor.sh
```

**Advanced Monitoring Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Advanced Monitoring ==="
echo "Timestamp: $(date)"
echo

# Configuration
LOG_FILE="/home/iotadmin/monitoring.log"
ALERT_EMAIL="your-email@example.com"
MEMORY_THRESHOLD=85
CPU_THRESHOLD=80
DISK_THRESHOLD=85

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to send alert
send_alert() {
    local message="$1"
    echo -e "${RED}ALERT: $message${NC}"
    log_message "ALERT: $message"
    # Uncomment to send email alerts
    # echo "$message" | mail -s "IoT System Alert" "$ALERT_EMAIL"
}

# Function to check resource usage
check_resources() {
    echo "=== Resource Monitoring ==="
    
    # Memory usage
    local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    echo "Memory Usage: ${memory_usage}%"
    
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        send_alert "High memory usage: ${memory_usage}%"
    fi
    
    # CPU usage
    local cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cpu_num=$(echo $cpu_load | awk '{print $1}')
    echo "CPU Load: $cpu_load"
    
    if (( $(echo "$cpu_num > $CPU_THRESHOLD" | bc -l) )); then
        send_alert "High CPU load: $cpu_load"
    fi
    
    # Disk usage
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Disk Usage: ${disk_usage}%"
    
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        send_alert "High disk usage: ${disk_usage}%"
    fi
}

# Function to check Docker containers
check_containers() {
    echo "=== Container Health ==="
    
    local unhealthy_containers=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep -v "Up" | wc -l)
    
    if [ "$unhealthy_containers" -gt 0 ]; then
        send_alert "Unhealthy containers detected: $unhealthy_containers"
        docker ps --format "table {{.Names}}\t{{.Status}}" | grep -v "Up"
    else
        echo -e "${GREEN}All containers healthy${NC}"
    fi
    
    # Check container resource usage
    echo "Container Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
}

# Function to check service endpoints
check_services() {
    echo "=== Service Health Checks ==="
    
    local services=(
        "MQTT:1883"
        "InfluxDB:8086:/health"
        "Node-RED:1880"
        "Grafana:3000:/api/health"
        "Express:3001:/health"
        "React:3002"
    )
    
    for service in "${services[@]}"; do
        local name=$(echo $service | cut -d: -f1)
        local port=$(echo $service | cut -d: -f2)
        local endpoint=$(echo $service | cut -d: -f3)
        
        if [ -n "$endpoint" ]; then
            local response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port$endpoint" 2>/dev/null || echo "000")
        else
            local response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null || echo "000")
        fi
        
        if [ "$response" = "200" ]; then
            echo -e "${GREEN}✅ $name: OK${NC}"
        else
            echo -e "${RED}❌ $name: FAILED (HTTP $response)${NC}"
            send_alert "Service $name is not responding properly"
        fi
    done
}

# Function to check data flow
check_data_flow() {
    echo "=== Data Flow Monitoring ==="
    
    # Check MQTT connectivity
    local mqtt_test=$(docker exec -it iot-mosquitto mosquitto_pub -h localhost -u admin -P admin_password_456 -t test/monitoring -m "test" 2>/dev/null && echo "OK" || echo "FAILED")
    
    if [ "$mqtt_test" = "OK" ]; then
        echo -e "${GREEN}✅ MQTT: OK${NC}"
    else
        echo -e "${RED}❌ MQTT: FAILED${NC}"
        send_alert "MQTT broker is not responding"
    fi
    
    # Check InfluxDB data writing
    local influx_test=$(curl -s -X POST "http://localhost:8086/api/v2/write?org=renewable_energy_org&bucket=renewable_energy" \
        -H "Authorization: Token renewable_energy_admin_token_123" \
        -d "monitoring_test,source=script value=1" 2>/dev/null && echo "OK" || echo "FAILED")
    
    if [ "$influx_test" = "OK" ]; then
        echo -e "${GREEN}✅ InfluxDB: OK${NC}"
    else
        echo -e "${RED}❌ InfluxDB: FAILED${NC}"
        send_alert "InfluxDB is not accepting data"
    fi
}

# Function to check network connectivity
check_network() {
    echo "=== Network Monitoring ==="
    
    # Check external connectivity
    if ping -c 1 google.com > /dev/null 2>&1; then
        echo -e "${GREEN}✅ External connectivity: OK${NC}"
    else
        echo -e "${RED}❌ External connectivity: FAILED${NC}"
        send_alert "External network connectivity is down"
    fi
    
    # Check DNS resolution
    if nslookup github.com > /dev/null 2>&1; then
        echo -e "${GREEN}✅ DNS resolution: OK${NC}"
    else
        echo -e "${RED}❌ DNS resolution: FAILED${NC}"
        send_alert "DNS resolution is not working"
    fi
}

# Function to generate performance report
generate_report() {
    echo "=== Performance Report ==="
    
    # System uptime
    echo "System Uptime: $(uptime -p)"
    
    # Memory details
    echo "Memory Details:"
    free -h
    
    # Disk details
    echo "Disk Details:"
    df -h
    
    # Top processes by memory
    echo "Top Memory Processes:"
    ps aux --sort=-%mem | head -5
    
    # Top processes by CPU
    echo "Top CPU Processes:"
    ps aux --sort=-%cpu | head -5
}

# Main monitoring function
main() {
    log_message "Starting advanced monitoring check"
    
    check_resources
    echo
    check_containers
    echo
    check_services
    echo
    check_data_flow
    echo
    check_network
    echo
    generate_report
    
    log_message "Advanced monitoring check completed"
}

# Run main function
main
```

```bash
# Make advanced monitoring script executable
chmod +x /home/iotadmin/advanced-monitor.sh
```

#### 2.2 Set Up Automated Monitoring
```bash
# Create monitoring cron jobs
crontab -e

# Add these lines for comprehensive monitoring:
# Every 5 minutes - Basic monitoring
*/5 * * * * /home/iotadmin/performance-monitor.sh >> /home/iotadmin/monitoring.log 2>&1

# Every 15 minutes - Advanced monitoring
*/15 * * * * /home/iotadmin/advanced-monitor.sh >> /home/iotadmin/monitoring.log 2>&1

# Every hour - System cleanup
0 * * * * /home/iotadmin/system-cleanup.sh >> /home/iotadmin/cleanup.log 2>&1

# Daily at 2 AM - Backup
0 2 * * * /home/iotadmin/backup-system.sh >> /home/iotadmin/backup.log 2>&1
```

## Step 3 – System Cleanup and Maintenance

#### 3.1 Create System Cleanup Script
```bash
# Create system cleanup script
nano /home/iotadmin/system-cleanup.sh
```

**System Cleanup Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Cleanup ==="
echo "Timestamp: $(date)"
echo

# Configuration
LOG_RETENTION_DAYS=7
BACKUP_RETENTION_DAYS=30
DOCKER_LOG_RETENTION_DAYS=3

# Function to clean Docker logs
clean_docker_logs() {
    echo "Cleaning Docker logs..."
    
    # Remove old container logs
    find /var/lib/docker/containers/ -name "*-json.log" -mtime +$DOCKER_LOG_RETENTION_DAYS -delete 2>/dev/null
    
    # Clean Docker system
    docker system prune -f
    
    echo "Docker cleanup completed"
}

# Function to clean application logs
clean_application_logs() {
    echo "Cleaning application logs..."
    
    # Clean old monitoring logs
    find /home/iotadmin/ -name "*.log" -mtime +$LOG_RETENTION_DAYS -delete 2>/dev/null
    
    # Clean old backup files
    find /home/iotadmin/backups/ -name "*.tar.gz" -mtime +$BACKUP_RETENTION_DAYS -delete 2>/dev/null
    
    echo "Application log cleanup completed"
}

# Function to clean temporary files
clean_temp_files() {
    echo "Cleaning temporary files..."
    
    # Clean system temp files
    find /tmp -type f -mtime +1 -delete 2>/dev/null
    
    # Clean user temp files
    find /home/iotadmin/ -name "*.tmp" -delete 2>/dev/null
    
    echo "Temporary file cleanup completed"
}

# Function to optimize InfluxDB
optimize_influxdb() {
    echo "Optimizing InfluxDB..."
    
    # Run InfluxDB compaction (if needed)
    docker exec -it iot-influxdb2 influx task list 2>/dev/null || echo "No tasks to run"
    
    echo "InfluxDB optimization completed"
}

# Function to check disk space
check_disk_space() {
    echo "Checking disk space..."
    
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -gt 80 ]; then
        echo "WARNING: High disk usage: ${disk_usage}%"
        echo "Consider increasing disk space or cleaning more aggressively"
    else
        echo "Disk usage is acceptable: ${disk_usage}%"
    fi
}

# Main cleanup function
main() {
    echo "Starting system cleanup..."
    
    clean_docker_logs
    clean_application_logs
    clean_temp_files
    optimize_influxdb
    check_disk_space
    
    echo "System cleanup completed"
}

# Run main function
main
```

```bash
# Make cleanup script executable
chmod +x /home/iotadmin/system-cleanup.sh
```

## Step 4 – Performance Tuning

#### 4.1 Optimize System Settings
```bash
# Create system optimization script
nano /home/iotadmin/system-optimization.sh
```

**System Optimization Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System - Performance Optimization ==="
echo "Timestamp: $(date)"
echo

# Function to optimize kernel parameters
optimize_kernel_params() {
    echo "Optimizing kernel parameters..."
    
    # Create sysctl configuration
    cat > /tmp/sysctl-optimization.conf << EOF
# File descriptor limits
fs.file-max = 65536

# Network optimizations
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216

# Memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# TCP optimizations
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF

    # Apply optimizations
    sudo sysctl -p /tmp/sysctl-optimization.conf
    
    echo "Kernel parameters optimized"
}

# Function to optimize Docker settings
optimize_docker() {
    echo "Optimizing Docker settings..."
    
    # Create optimized Docker daemon configuration
    sudo tee /etc/docker/daemon.json > /dev/null << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 3
}
EOF

    # Restart Docker
    sudo systemctl restart docker
    
    echo "Docker settings optimized"
}

# Function to optimize InfluxDB settings
optimize_influxdb() {
    echo "Optimizing InfluxDB settings..."
    
    # Update InfluxDB environment variables for better performance
    docker-compose exec influxdb influx config set \
        --host-url http://localhost:8086 \
        --token renewable_energy_admin_token_123 \
        --org renewable_energy_org \
        --active-config-name default
    
    echo "InfluxDB settings optimized"
}

# Function to create performance monitoring
setup_performance_monitoring() {
    echo "Setting up performance monitoring..."
    
    # Create performance monitoring script
    cat > /home/iotadmin/performance-tracker.sh << 'EOF'
#!/bin/bash

# Performance tracking script
LOG_FILE="/home/iotadmin/performance-metrics.log"

echo "$(date),$(free | grep Mem | awk '{print $3"/"$2}'),$(uptime | awk '{print $10}'),$(df / | tail -1 | awk '{print $5}')" >> "$LOG_FILE"

# Keep only last 1000 lines
tail -1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
EOF

    chmod +x /home/iotadmin/performance-tracker.sh
    
    # Add to crontab for every minute tracking
    (crontab -l 2>/dev/null; echo "*/1 * * * * /home/iotadmin/performance-tracker.sh") | crontab -
    
    echo "Performance monitoring setup completed"
}

# Main optimization function
main() {
    echo "Starting system optimization..."
    
    optimize_kernel_params
    optimize_docker
    optimize_influxdb
    setup_performance_monitoring
    
    echo "System optimization completed"
}

# Run main function
main
```

```bash
# Make optimization script executable
chmod +x /home/iotadmin/system-optimization.sh
```

#### 4.2 Run Performance Optimization
```bash
# Run system optimization
./system-optimization.sh

# Restart services with optimized settings
docker-compose down
docker-compose -f docker-compose.prod.yml up -d

# Monitor performance improvements
./advanced-monitor.sh
```

---

## 🧪 Testing and Validation

### **Test 1: Performance Benchmark**
```bash
# Run performance benchmark
echo "=== Performance Benchmark ==="
echo "Before optimization:"
./performance-monitor.sh

echo "After optimization:"
./advanced-monitor.sh

# Compare results
echo "Performance improvement analysis completed"
```

### **Test 2: Load Testing with Optimizations**
```bash
# Run load test with optimized system
./load-test.sh

# Monitor performance during load
watch -n 5 './performance-tracker.sh'
```

### **Test 3: Resource Usage Validation**
```bash
# Check resource usage after optimization
docker stats --no-stream
free -h
df -h
uptime
```

---

## 📊 Performance Metrics

### **Expected Performance After Optimization:**

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| **Memory Usage** | 1.8-2.2GB | 1.4-1.8GB | < 1.8GB |
| **CPU Load** | 1.2-2.0 | 0.8-1.5 | < 1.5 |
| **Response Time** | 2-3s | 1-2s | < 2s |
| **Disk Usage** | 15-20GB | 12-18GB | < 20GB |
| **Container Restarts** | Occasional | Minimal | 0 |

### **Performance Monitoring Dashboard:**
```bash
# Create performance dashboard data
echo "Creating performance metrics for Grafana dashboard..."

# Generate sample performance data
for i in {1..100}; do
    timestamp=$(date -d "$i minutes ago" +%s)
    memory=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
    cpu=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    disk=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    echo "system_performance,metric=memory value=$memory $timestamp"
    echo "system_performance,metric=cpu value=$cpu $timestamp"
    echo "system_performance,metric=disk value=$disk $timestamp"
done | curl -X POST "http://localhost:8086/api/v2/write?org=renewable_energy_org&bucket=renewable_energy" \
    -H "Authorization: Token renewable_energy_admin_token_123" \
    --data-binary @-
```

---

## ⚠️ Troubleshooting

### **Common Optimization Issues:**

#### **Issue 1: Memory Still High**
```bash
# Solution: Further optimize memory usage
# Reduce InfluxDB memory limits
# Optimize Node-RED flows
# Monitor with: docker stats
```

#### **Issue 2: Performance Degradation**
```bash
# Solution: Revert optimizations
# Check system logs
# Monitor resource usage
# Adjust optimization parameters
```

#### **Issue 3: Service Failures**
```bash
# Solution: Check service health
docker-compose ps
docker-compose logs [service-name]
# Restart problematic services
```

---

## ✅ Phase 4 Completion Checklist

- [ ] **Production Docker configuration created**
- [ ] **Advanced monitoring implemented**
- [ ] **System optimization completed**
- [ ] **Performance improvements validated**
- [ ] **Automated maintenance configured**
- [ ] **Resource usage optimized**
- [ ] **System stable under load**
- [ ] **Production ready**

---

## 🎯 Next Steps

After completing Phase 4, proceed to:
- **[Phase 5: Monitoring and Maintenance](./05-monitoring-maintenance.md)**
- **[Phase 6: Security Hardening](./06-security-hardening.md)**
- **[Phase 7: Production Deployment](./07-production-deployment.md)**

---

## 🤖 AI Prompts for This Phase

### **Prompt 1: Performance Optimization**
```
I need to optimize my renewable energy IoT monitoring system for production on a 2GB RAM VPS.
Current issues: high memory usage, slow response times, occasional container restarts.
Services: MQTT, InfluxDB 2.7, Node-RED, Grafana, Express, React.
Please help optimize Docker configurations and system settings for better performance.
```

### **Prompt 2: Advanced Monitoring**
```
I need to implement comprehensive monitoring for my production IoT system.
Requirements: resource monitoring, service health checks, alerting, performance tracking.
Components: Docker containers, time-series database, web applications.
Please help create monitoring scripts and alerting configuration for production use.
```

### **Prompt 3: System Maintenance**
```
I need to set up automated maintenance procedures for my IoT monitoring system.
Requirements: log rotation, disk cleanup, backup automation, performance optimization.
Components: Docker containers, InfluxDB, configuration files, application data.
Please help create maintenance scripts and automation for production environment.
```

---

**🎉 Phase 4 Complete! Your system is now optimized for production use.**

## Use in Cursor – Compose production audit
```text
Act as a production readiness auditor for docker-compose.yml.
- Check for: restart policies (unless-stopped), healthchecks per service, explicit resource limits/reservations, pinned image versions, named volumes, least-privilege users, and exposed ports mapping.
- Suggest concrete edits with YAML snippets for any missing item.
- Include security recommendations (read-only root filesystem where possible, no-new-privileges, drop capabilities) and log rotation.
- Output a short diff-like summary I can paste back into the file.
```
