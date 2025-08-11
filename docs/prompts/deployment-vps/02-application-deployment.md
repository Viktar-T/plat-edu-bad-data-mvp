# 🚀 Phase 2: Application Deployment

> **Deploy and configure the renewable energy IoT monitoring system on Mikrus VPS**

## 📋 Overview

This phase covers the deployment of all application components using Docker Compose, optimized for Mikrus VPS specifications. The deployment includes MQTT broker, InfluxDB database, Node-RED data processing, Grafana visualization, and custom web applications (Express backend + React frontend).

### 🎯 What is Application Deployment?
Application deployment is like setting up all the programs on your server. Think of it like installing apps on your phone - you need to install each app, configure its settings, and make sure they can talk to each other. In this case, we're setting up several applications that work together to monitor renewable energy systems.

### ✅ Prerequisites
- ✅ Phase 1 completed - Your server is set up and secure
- ✅ Docker and Docker Compose installed - The "container system" is ready
- ✅ SSH access from Windows - You can connect to your server
- ✅ Project files ready for transfer - Your code is ready to copy to the server

### 📁 Required Files
- `docker-compose.yml` (optimized for Mikrus VPS) - The "recipe" that tells Docker how to set up all your applications
- `.env` file with environment variables - The settings your applications need
- Web application files (Express backend + React frontend) - Your custom website files
- Configuration files for each service - Settings for each part of your system

---

## 🚀 Step-by-Step Deployment

## Step 1 – File Transfer from Windows

#### **1.1 Transfer Project Files**

**Option A: Using WinSCP (Recommended for Windows)**
1. Download WinSCP from https://winscp.net/
2. Open WinSCP and connect to your server:
   - **Host name**: Your server IP address
   - **Port**: 2222 (or your custom SSH port)
   - **User name**: Your username
   - **Password**: Your password (or use SSH key)
3. Navigate to your project directory on Windows
4. Drag and drop files to the server

**Option B: Using WSL (Windows Subsystem for Linux)**
```bash
# Open WSL and transfer files
scp -r ./renewable-energy-iot username@your-server-ip:/home/username/

# Or use rsync for better performance
rsync -avz --progress ./renewable-energy-iot/ username@your-server-ip:/home/username/renewable-energy-iot/
```

**Option C: Using VS Code Remote SSH**
1. Install VS Code Remote SSH extension
2. Connect to your server via VS Code
3. Open the project folder directly on the server
4. Edit files directly on the server

#### **1.2 Verify File Transfer**
```bash
# Connect to your server
ssh username@your-server-ip

# Navigate to project directory
cd ~/renewable-energy-iot

# List files to verify transfer
ls -la

# Check if all required files are present
ls -la docker-compose.yml .env
```

**What this means:** You're copying your project files from your Windows computer to your server. This is like copying files from your computer to a USB drive, but over the internet.

---

## Step 2 – Docker Compose Configuration

#### **2.1 Optimize Docker Compose for Mikrus VPS**
```bash
# Edit the docker-compose.yml file
nano docker-compose.yml
```

**Replace with this optimized configuration:**
```yaml
version: '3.8'

services:
  # MQTT Broker - Eclipse Mosquitto
  mosquitto:
    image: eclipse-mosquitto:2.0.18
    container_name: iot-mosquitto
    ports:
      - "${MQTT_PORT:-1883}:1883"
      - "${MQTT_WS_PORT:-9001}:9001"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
      - ./mosquitto/log:/mosquitto/log
    environment:
      - TZ=UTC
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 100M
          cpus: '0.2'
        reservations:
          memory: 50M
          cpus: '0.1'
    healthcheck:
      test: ["CMD", "mosquitto_pub", "-h", "localhost", "-t", "system/health/mosquitto", "-m", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - iot-network

  # Time-Series Database - InfluxDB 2.7
  influxdb:
    image: influxdb:2.7
    container_name: iot-influxdb2
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb/data:/var/lib/influxdb2
      - ./influxdb/backups:/backups
    environment:
      - TZ=UTC
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
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8086/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    networks:
      - iot-network

  # Data Processing - Node-RED
  node-red:
    image: nodered/node-red:latest
    container_name: iot-node-red
    ports:
      - "1880:1880"
    volumes:
      - ./node-red/data:/data
      - ./node-red/settings.js:/data/settings.js
      - ./node-red/package.json:/data/package.json
      - ./node-red/startup.sh:/startup.sh
    environment:
      - TZ=UTC
      - NODE_RED_ENABLE_PROJECTS=true
      - NODE_RED_EDITOR_THEME=dark
      - NODE_RED_DISABLE_EDITOR=false
      - NODE_RED_DISABLE_FLOWS=false
      - NODE_RED_HOME=/data
      - NODE_RED_OPTIONS=${NODE_RED_OPTIONS:---max-old-space-size=256}
      - NODE_RED_SETTINGS_FILE=/data/settings.js
      - NODE_RED_USERNAME=${NODE_RED_USERNAME:-admin}
      - NODE_RED_PASSWORD=${NODE_RED_PASSWORD:-adminpassword}
      - NODE_RED_INFLUXDB_URL=http://influxdb:8086
      - NODE_RED_INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - NODE_RED_INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
      - NODE_RED_INFLUXDB_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 400M
          cpus: '0.5'
        reservations:
          memory: 200M
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

  # Visualization - Grafana
  grafana:
    image: grafana/grafana:10.2.0
    container_name: iot-grafana
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
      - GF_SERVER_ROOT_URL=${GF_SERVER_ROOT_URL:-http://YOUR_VPS_IP:3000}
      - GF_SERVER_SERVE_FROM_SUB_PATH=false
      - GF_ANALYTICS_REPORTING_ENABLED=false
      - GF_ANALYTICS_CHECK_FOR_UPDATES=false
      - GF_LOG_LEVEL=info
      - GF_SERVER_MAX_CONCURRENT_REQUESTS=${GF_SERVER_MAX_CONCURRENT_REQUESTS:-100}
      - GF_SERVER_MAX_CONCURRENT_REQUESTS_PER_USER=${GF_SERVER_MAX_CONCURRENT_REQUESTS_PER_USER:-10}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 300M
          cpus: '0.3'
        reservations:
          memory: 150M
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

  # Express Backend API
  express-backend:
    build:
      context: ./web-app-for-testing/backend
      dockerfile: Dockerfile
    container_name: iot-express-backend
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
      - INFLUXDB_URL=http://influxdb:8086
      - INFLUXDB_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
      - INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 200M
          cpus: '0.3'
        reservations:
          memory: 100M
          cpus: '0.1'
    depends_on:
      influxdb:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3001/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    networks:
      - iot-network

  # React Frontend
  react-frontend:
    build:
      context: ./web-app-for-testing/frontend
      dockerfile: Dockerfile
    container_name: iot-react-frontend
    ports:
      - "3002:3000"
    environment:
      - REACT_APP_API_URL=${REACT_APP_API_URL:-http://YOUR_VPS_IP:3001}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 150M
          cpus: '0.2'
        reservations:
          memory: 75M
          cpus: '0.1'
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

**What this configuration does:**
- **Resource Limits**: Each service has memory and CPU limits to prevent one service from using all resources
- **Health Checks**: Each service has health checks to ensure they're working properly
- **Dependencies**: Services start in the right order (core services first, then applications that depend on them)
- **Networking**: All services can communicate with each other through the `iot-network`
- **Volumes**: Data is stored persistently so it survives container restarts

#### **2.2 Service Explanations**

**MQTT Broker (Mosquitto):**
- **Purpose**: The "post office" that receives messages from IoT devices
- **Memory**: 50-100MB (very lightweight)
- **Port**: 1883 (MQTT), 9001 (WebSocket)
- **Health Check**: Publishes a test message to verify it's working

**InfluxDB Database:**
- **Purpose**: The "filing cabinet" that stores time-series data
- **Memory**: 512MB-1GB (uses more resources because it stores all your data)
- **Port**: 8086 (HTTP API)
- **Health Check**: Checks if the web interface is responding

**Node-RED:**
- **Purpose**: The "digital plumber" that connects different parts of your system
- **Memory**: 200-400MB (moderate usage)
- **Port**: 1880 (web interface)
- **Health Check**: Checks if the web interface is responding

**Grafana:**
- **Purpose**: The "digital artist" that creates charts and dashboards
- **Memory**: 150-300MB (moderate usage)
- **Port**: 3000 (web interface)
- **Health Check**: Checks if the web interface is responding

**Express Backend:**
- **Purpose**: The "brain" of your custom website (API server)
- **Memory**: 100-200MB (lightweight)
- **Port**: 3001 (API)
- **Health Check**: Checks if the API is responding

**React Frontend:**
- **Purpose**: The "face" of your custom website (user interface)
- **Memory**: 75-150MB (lightweight)
- **Port**: 3002 (web interface)
- **Health Check**: Checks if the web interface is responding

---

## Step 3 – Web Application Components

#### **3.1 Express Backend Dockerfile**
```bash
# Create Express backend Dockerfile
nano web-app-for-testing/backend/Dockerfile
```

**Add this content:**
```dockerfile
# Use Node.js 18 Alpine for smaller image size
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start the application
CMD ["npm", "start"]
```

#### **3.2 React Frontend Dockerfile**
```bash
# Create React frontend Dockerfile
nano web-app-for-testing/frontend/Dockerfile
```

**Add this content:**
```dockerfile
# Multi-stage build for smaller production image
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create non-root user
RUN addgroup -g 1001 -S nginx
RUN adduser -S nginx -u 1001

# Change ownership
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chown -R nginx:nginx /var/cache/nginx
RUN chown -R nginx:nginx /var/log/nginx
RUN chown -R nginx:nginx /etc/nginx/conf.d

USER nginx

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

#### **3.3 Nginx Configuration for React Frontend**
```bash
# Create nginx configuration
nano web-app-for-testing/frontend/nginx.conf
```

**Add this content:**
```nginx
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

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
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    server {
        listen 3000;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # Handle React Router
        location / {
            try_files $uri $uri/ /index.html;
        }

        # Static assets caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # API proxy to Express backend
        location /api/ {
            proxy_pass http://express-backend:3001/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

**What these configurations do:**
- **Express Backend**: A Node.js API server that connects to InfluxDB and provides data to the frontend
- **React Frontend**: A modern web application that displays your data in a user-friendly interface
- **Nginx**: A web server that serves the React app and proxies API requests to the Express backend
- **Security**: Non-root users, security headers, and proper file permissions
- **Performance**: Gzip compression, caching, and optimized static file serving

---

## Step 4 – Deployment Steps

#### **4.1 Start Core Services First**
```bash
# Start MQTT and InfluxDB (core services)
docker-compose up -d mosquitto influxdb

# Wait for services to be healthy
docker-compose ps

# Check logs for any issues
docker-compose logs mosquitto influxdb
```

#### **4.2 Start Processing Services**
```bash
# Start Node-RED (data processing)
docker-compose up -d node-red

# Wait for Node-RED to be healthy
docker-compose ps

# Check Node-RED logs
docker-compose logs node-red
```

#### **4.3 Start Visualization Services**
```bash
# Start Grafana (visualization)
docker-compose up -d grafana

# Wait for Grafana to be healthy
docker-compose ps

# Check Grafana logs
docker-compose logs grafana
```

#### **4.4 Start Web Application**
```bash
# Start Express backend and React frontend
docker-compose up -d express-backend react-frontend

# Wait for all services to be healthy
docker-compose ps

# Check all logs
docker-compose logs
```

#### **4.5 Verify All Services**
```bash
# Check all container status
docker-compose ps

# Check resource usage
docker stats --no-stream

# Test service connectivity
curl -f http://localhost:8086/health  # InfluxDB
curl -f http://localhost:1880         # Node-RED
curl -f http://localhost:3000/api/health  # Grafana
curl -f http://localhost:3001/health  # Express Backend
curl -f http://localhost:3002         # React Frontend
```

---

## Step 5 – Configuration and Testing

#### **5.1 Configure InfluxDB**
```bash
# Access InfluxDB web interface
# Open in browser: http://your-server-ip:8086

# Default credentials:
# Username: admin
# Password: admin_password_123
# Organization: renewable_energy_org
# Bucket: renewable_energy
```

#### **5.2 Configure Grafana**
```bash
# Access Grafana web interface
# Open in browser: http://your-server-ip:3000

# Default credentials:
# Username: admin
# Password: admin

# Add InfluxDB data source:
# URL: http://influxdb:8086
# Access: Server (default)
# Database: renewable_energy
# User: admin
# Password: admin_password_123
```

#### **5.3 Configure Node-RED**
```bash
# Access Node-RED web interface
# Open in browser: http://your-server-ip:1880

# Default credentials:
# Username: admin
# Password: adminpassword

# Import your flows from the local environment
```

#### **5.4 Test Web Applications**
Express API and React Frontend are currently under development and not deployed. Skip these tests for now.

---

## Step 6 – Performance Monitoring

#### **6.1 Create Performance Monitor Script**
```bash
# Create performance monitoring script
nano ~/performance-monitor.sh
```

**Add this content:**
```bash
#!/bin/bash

echo "=== Mikrus VPS Performance Monitor ==="
echo "Date: $(date)"
echo ""

echo "=== System Resources ==="
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
echo ""

echo "=== Docker Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"
echo ""

echo "=== Container Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
echo ""

echo "=== Service Health Checks ==="
echo "MQTT Broker: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:1883 || echo "DOWN")"
echo "InfluxDB: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8086/health || echo "DOWN")"
echo "Node-RED: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:1880 || echo "DOWN")"
echo "Grafana: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health || echo "DOWN")"
echo "Express API: SKIPPED (under development)"
echo "React Frontend: SKIPPED (under development)"
echo ""

echo "=== Network Connections ==="
netstat -tlnp | grep -E ":(1883|8086|1880|3000)"
echo ""

echo "=== Top Processes by Memory ==="
ps aux --sort=-%mem | head -5
echo ""

echo "=== Docker System Info ==="
docker system df
echo ""
```

**Make script executable:**
```bash
chmod +x ~/performance-monitor.sh

# Run performance monitor
./performance-monitor.sh
```

#### **6.2 Set Up Automated Monitoring**
```bash
# Create cron job for regular monitoring
crontab -e

# Add this line to run monitoring every 5 minutes
*/5 * * * * /home/username/performance-monitor.sh >> /home/username/performance.log 2>&1
```

---

## Step 7 – Testing and Validation

#### **7.1 Service Connectivity Tests**
```bash
# Test MQTT connectivity
mosquitto_pub -h localhost -t test/topic -m "Hello MQTT"

# Test InfluxDB connectivity
curl -f http://localhost:8086/health

# Test Node-RED connectivity
curl -f http://localhost:1880

# Test Grafana connectivity
curl -f http://localhost:3000/api/health

# Express API and React frontend tests skipped (under development)
```

#### **7.2 Web Interface Access Tests**
```bash
# Test from Windows browser:
# MQTT: http://your-server-ip:1883 (if web interface available)
# InfluxDB: http://your-server-ip:8086
# Node-RED: http://your-server-ip:1880
# Grafana: http://your-server-ip:3000
# Express API: http://your-server-ip:3001
# React Frontend: http://your-server-ip:3002
```

#### **7.3 Data Flow Tests**
```bash
# Test MQTT to InfluxDB flow
mosquitto_pub -h localhost -t devices/pv/001/power -m '{"value": 100, "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'

# Check if data appears in InfluxDB
curl -G "http://localhost:8086/query" --data-urlencode "q=SHOW MEASUREMENTS"

# Test API data retrieval
curl http://localhost:3001/api/data
```

#### **7.4 Performance Tests**
```bash
# Test system under load
for i in {1..100}; do
  curl -s http://localhost:3001/health > /dev/null &
done
wait

# Check performance after load test
./performance-monitor.sh
```

---

## Step 8 – Performance Metrics

#### **8.1 Resource Usage on Mikrus VPS:**

| Service | Memory | CPU | Storage | Status | What This Means |
|---------|--------|-----|---------|--------|-----------------|
| **MQTT Broker** | 50-100MB | 0.1-0.2 cores | 100MB | ✅ Lightweight | The "post office" - very efficient |
| **InfluxDB** | 512MB-1GB | 0.5-1.0 cores | 5-10GB | ⚠️ Resource-intensive | The "filing cabinet" - uses more resources but stores all your data |
| **Node-RED** | 200-400MB | 0.2-0.5 cores | 500MB | ✅ Moderate | The "digital plumber" - moderate resource usage |
| **Grafana** | 150-300MB | 0.1-0.3 cores | 1GB | ✅ Moderate | The "digital artist" - moderate resource usage |
| **Express Backend** | 100-200MB | 0.1-0.3 cores | 100MB | ✅ Lightweight | Your custom website's "brain" - very efficient |
| **React Frontend** | 75-150MB | 0.1-0.2 cores | 200MB | ✅ Lightweight | Your custom website's "face" - very efficient |
| **System Overhead** | 200-400MB | 0.5 core | 2GB | ✅ Acceptable | The operating system and basic tools |

**Total Expected Usage:**
- **Memory**: 1.2-2.2GB (within 2GB limit for Mikrus 3.0) - You're using most of your available memory, but it should work
- **CPU**: 1.1-2.5 cores (within 2 core limit for Mikrus 3.0) - You're using most of your available CPU power, but it should work
- **Storage**: 8-14GB (within 25GB limit for Mikrus 3.0) - You have plenty of storage space left

#### **8.2 Performance Optimization Tips:**
- **Monitor regularly**: Use the performance monitor script
- **Scale if needed**: Consider upgrading to Mikrus 3.5 for more resources
- **Optimize data retention**: Reduce InfluxDB retention period if storage is limited
- **Use resource limits**: Docker resource limits prevent one service from using all resources

---

## ⚠️ Troubleshooting

### **Common Issues and Solutions:**

#### **Issue 1: Memory Exhaustion**
```bash
# Symptoms: Container restarts, slow performance
# Solution: Optimize resource limits
docker-compose down
docker-compose up -d

# Check memory usage
free -h
docker stats
```

**What this means:** Your server is running out of memory (RAM). This happens when your applications try to use more memory than your server has available.

#### **Issue 2: Container Startup Failures**
```bash
# Symptoms: Services not starting
# Solution: Check logs and dependencies
docker-compose logs [service-name]
docker-compose ps

# Check container status
docker ps -a
```

**What this means:** One or more of your applications isn't starting properly. This could be due to configuration errors, missing files, or resource issues.

#### **Issue 3: Network Connectivity**
```bash
# Symptoms: Services can't communicate
# Solution: Check Docker network
docker network ls
docker network inspect iot-network

# Test inter-service communication
docker exec iot-node-red ping influxdb
```

**What this means:** Your applications can't talk to each other. This is like having a broken phone line between different parts of your system.

#### **Issue 4: Data Persistence Issues**
```bash
# Symptoms: Data loss after restart
# Solution: Verify volume mounts
docker volume ls
docker volume inspect [volume-name]

# Check data directories
ls -la ./influxdb/data/
ls -la ./mosquitto/data/
```

**What this means:** Your data is disappearing when you restart your applications. This usually means your data isn't being saved to the right place.

#### **Issue 5: Web Interface Access Problems**
```bash
# Symptoms: Can't access web interfaces from Windows
# Solution: Check firewall and port configuration
sudo ufw status
netstat -tlnp | grep -E ":(3000|3001|3002|1880|8086)"

# Test from server
curl -f http://localhost:3000
```

**What this means:** You can't access your web applications from your Windows computer. This could be due to firewall settings or network configuration.

---

## ✅ Completion Checklist

### **Phase 2 Completion Criteria:**

#### **✅ File Transfer:**
- [ ] Successfully transferred project files from Windows to Mikrus VPS - Your code is now on the server
- [ ] Verified all required files are present - All necessary files are in the right place
- [ ] Confirmed file permissions are correct - Files can be read and executed properly

#### **✅ Docker Compose Configuration:**
- [ ] Optimized docker-compose.yml for Mikrus VPS - Your "recipe" is configured for your specific server
- [ ] Configured resource limits for all services - Each application has memory and CPU limits
- [ ] Set up health checks for all services - Each application can be monitored for health
- [ ] Configured service dependencies - Applications start in the correct order

#### **✅ Web Application Components:**
- [ ] Created Express backend Dockerfile - Your custom website's "brain" is ready
- [ ] Created React frontend Dockerfile - Your custom website's "face" is ready
- [ ] Configured Nginx for React frontend - Your website can be served properly
- [ ] Set up API proxy configuration - Your frontend can talk to your backend

#### **✅ Service Deployment:**
- [ ] Started core services (MQTT, InfluxDB) - The foundation is running
- [ ] Started processing services (Node-RED) - Data processing is working
- [ ] Started visualization services (Grafana) - Dashboards are available
- [ ] Started web applications (Express, React) - Your custom website is running
- [ ] Verified all services are healthy - All applications are working properly

#### **✅ Configuration and Testing:**
- [ ] Configured InfluxDB with proper credentials - Your database is set up
- [ ] Configured Grafana with InfluxDB data source - Your dashboards can access data
- [ ] Configured Node-RED with proper settings - Your data processing is configured
- [ ] Tested all web interfaces from Windows - You can access all applications from your computer
- [ ] Verified data flow between services - Data moves through your system properly

#### **✅ Performance Monitoring:**
- [ ] Created performance monitoring script - You can watch your system's performance
- [ ] Set up automated monitoring with cron - Your system is monitored automatically
- [ ] Established performance baseline - You know how your system should perform
- [ ] Verified resource usage is within limits - Your system isn't using too many resources

#### **✅ Testing and Validation:**
- [ ] Tested service connectivity - All applications can talk to each other
- [ ] Tested web interface access - You can access all web applications from Windows
- [ ] Tested data flow validation - Data moves through your system correctly
- [ ] Tested performance under load - Your system handles multiple requests properly
- [ ] Verified all services respond to health checks - All applications are healthy

---

## 🤖 AI Prompts for Phase 2

### **When You Need Help:**

#### **For Docker Compose Issues:**
```
I'm deploying a renewable energy IoT system on a Mikrus VPS with 2GB RAM.
Services: MQTT, InfluxDB 2.7, Node-RED, Grafana, Express, React.
I'm having trouble with [specific issue].
Please help me optimize Docker configurations and resource allocation for Mikrus hardware.
```

#### **For Web Application Issues:**
```
I'm deploying Express backend and React frontend on a Mikrus VPS.
I need help with Dockerfile configuration, Nginx setup, and API proxy.
Please help me configure the web applications for optimal performance.
```

#### **For Performance Issues:**
```
My Mikrus VPS (2GB RAM) is experiencing performance issues with Docker containers.
Services are using too much memory/CPU.
Please help me optimize resource limits and performance for limited hardware.
```

#### **For Service Communication Issues:**
```
My Docker containers on Mikrus VPS can't communicate with each other.
Services: MQTT, InfluxDB, Node-RED, Grafana, Express, React.
Please help me troubleshoot network connectivity and service dependencies.
```

---

## 🎯 Next Steps

After completing Phase 2:

1. **Verify All Services**: Ensure all applications are running and healthy
2. **Test from Windows**: Access all web interfaces from your Windows computer
3. **Monitor Performance**: Use the performance monitoring script regularly
4. **Proceed to Phase 3**: Move on to data migration and comprehensive testing
5. **Document Configuration**: Keep notes of your setup for future reference

---

**✅ Phase 2 Complete! Your renewable energy IoT monitoring system is deployed on Mikrus VPS.**

---

*This deployment is optimized for Mikrus VPS servers with Ubuntu 24.04 LTS and Windows users connecting from a Windows PC environment.*

## Use in Cursor – Health check and misconfiguration scan
```text
Act as a deployment verifier for this repository on Mikrus.
Tasks:
- Generate Windows PowerShell commands to run on the VPS via SSH that:
  - docker compose ps, docker ps --format, and health statuses for mosquitto, influxdb, node-red, grafana.
  - Stream the last 200 log lines per service and grep for common errors (port in use, permission denied, auth errors, OOMKilled).
  - curl/Invoke-WebRequest health endpoints: :1880, :8086/health, :3000/api/health.
- Summarize common misconfigurations: missing .env, wrong token/org/bucket, port collisions, volume permissions, firewall.
- Output a remediation checklist with exact commands to fix typical issues.
Return commands separated into Windows PowerShell (local) and bash (remote VPS).
```
