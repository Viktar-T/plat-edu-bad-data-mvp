# 🚀 Phase 2: Application Deployment

> **Deploy and configure the renewable energy IoT monitoring system on Mikrus 3.0 VPS**

## 📋 Overview

This phase covers the deployment of all application components, configuration optimization for limited resources, and initial system testing.

**What is application deployment?** Deployment is like "installing" all your programs on the server. Instead of installing them one by one, we use Docker to put each program in its own "container" (like a box) and run them all together.

### 🎯 Objectives
- ✅ Deploy all Docker containers
- ✅ Configure resource limits for Mikrus 3.0
- ✅ Set up data persistence
- ✅ Configure networking between services
- ✅ Test basic functionality

---

## 🔧 Prerequisites

### ✅ Phase 1 Completion
- VPS properly configured and secured - Your server is ready and safe
- Docker installed and optimized - The "container system" is ready to run your applications
- Environment variables set - Your applications have the settings they need
- Monitoring tools installed - You have tools to watch your system

### ✅ Required Files
- `docker-compose.yml` (optimized for Mikrus 3.0) - The "recipe" that tells Docker how to set up all your applications
- Environment variables file (`.env`) - The settings your applications need
- Application configuration files - The specific settings for each part of your system

---

## 🛠️ Step-by-Step Instructions

### **Step 1: Code Transfer and Setup**

#### 1.1 Transfer Project Files
```bash
# On your local machine, create a deployment package
cd /path/to/your/project
tar -czf renewable-energy-iot.tar.gz \
  docker-compose.yml \
  .env \
  mosquitto/ \
  influxdb/ \
  node-red/ \
  grafana/ \
  web-app-for-testing/

# Transfer to VPS
scp -P 2222 renewable-energy-iot.tar.gz iotadmin@YOUR_VPS_IP:/home/iotadmin/renewable-energy-iot/

# On VPS, extract files
cd /home/iotadmin/renewable-energy-iot
tar -xzf renewable-energy-iot.tar.gz
```

**What this does:**
- `tar -czf renewable-energy-iot.tar.gz` - Creates a compressed package of all your files (like zipping a folder)
- `scp -P 2222` - Copies the package to your server using the secure port we set up
- `tar -xzf renewable-energy-iot.tar.gz` - Extracts the files on your server (like unzipping a folder)

#### 1.2 Optimize Docker Compose for Mikrus 3.0
```bash
# Create optimized docker-compose.yml
nano docker-compose.yml
```

**What Docker Compose is:** Docker Compose is like a "recipe book" that tells Docker how to set up all your applications together. It's like having a recipe that tells you how to cook multiple dishes at the same time.

**Optimized Docker Compose Configuration:**
```yaml
version: '3.8'

services:
  # MQTT Broker - Eclipse Mosquitto (Optimized)
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
      - TZ=Europe/Helsinki
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
      test: ["CMD", "mosquitto_pub", "-h", "localhost", "-u", "${MQTT_ADMIN_USER:-admin}", "-P", "${MQTT_ADMIN_PASSWORD:-admin_password_456}", "-t", "system/health/mosquitto", "-m", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - iot-network

**What this MQTT service does:**
- **image**: The "program" to run (Eclipse Mosquitto MQTT broker)
- **ports**: The "doors" that other programs can use to connect (1883 for MQTT, 9001 for WebSocket)
- **volumes**: Where to store data and settings (like folders on your computer)
- **deploy.resources.limits**: Maximum memory and CPU this program can use (100MB memory, 20% of one CPU)
- **deploy.resources.reservations**: Minimum memory and CPU this program needs (50MB memory, 10% of one CPU)
- **healthcheck**: A way to check if the program is working properly
- **networks**: Which "network" this program connects to (so it can talk to other programs)

  # Time-Series Database - InfluxDB 2.7 (Optimized)
  influxdb:
    image: influxdb:2.7
    container_name: iot-influxdb2
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
      - INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=${INFLUXDB_HTTP_MAX_CONNECTION_LIMIT:-100}
      - INFLUXDB_HTTP_READ_TIMEOUT=${INFLUXDB_HTTP_READ_TIMEOUT:-30s}
      - INFLUXDB_LOGGING_LEVEL=${INFLUXDB_LOGGING_LEVEL:-info}
      - INFLUXDB_LOGGING_FORMAT=${INFLUXDB_LOGGING_FORMAT:-auto}
      - INFLUXDB_METRICS_DISABLED=${INFLUXDB_METRICS_DISABLED:-true}
      - INFLUXDB_PPROF_ENABLED=${INFLUXDB_PPROF_ENABLED:-false}
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

**What this InfluxDB service does:**
- **image**: The "program" to run (InfluxDB 2.7 time-series database)
- **ports**: The "door" that other programs can use to connect (8086 for database access)
- **volumes**: Where to store data and backups (like folders on your computer)
- **environment**: All the settings the database needs (usernames, passwords, organization names, etc.)
- **deploy.resources.limits**: Maximum memory and CPU this program can use (1GB memory, 1 full CPU)
- **deploy.resources.reservations**: Minimum memory and CPU this program needs (512MB memory, 50% of one CPU)
- **healthcheck**: A way to check if the database is working properly
- **networks**: Which "network" this program connects to (so it can talk to other programs)

**Why InfluxDB uses more resources:** InfluxDB is like a "filing cabinet" that stores all your sensor data. It needs more memory and CPU because it's constantly reading and writing data, and it has to organize all the data by time.

  # Data Processing - Node-RED (Optimized)
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
      - TZ=Europe/Helsinki
      - NODE_RED_ENABLE_PROJECTS=true
      - NODE_RED_EDITOR_THEME=dark
      - NODE_RED_DISABLE_EDITOR=false
      - NODE_RED_DISABLE_FLOWS=false
      - NODE_RED_HOME=/data
      - NODE_RED_OPTIONS=--max-old-space-size=256
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
          memory: 400M
          cpus: '0.5'
        reservations:
          memory: 200M

**What this Node-RED service does:**
- **image**: The "program" to run (Node-RED visual programming tool)
- **ports**: The "door" that you can use to access the visual programming interface (1880 for web interface)
- **volumes**: Where to store your Node-RED flows and settings (like folders on your computer)
- **environment**: All the settings Node-RED needs (including connection to InfluxDB database)
- **deploy.resources.limits**: Maximum memory and CPU this program can use (400MB memory, 50% of one CPU)
- **deploy.resources.reservations**: Minimum memory and CPU this program needs (200MB memory)

**What Node-RED does:** Node-RED is like a "digital plumber" - it connects different parts of your system together. You can use it to create visual flows that process data from your sensors and send it to your database.
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

  # Visualization - Grafana (Optimized)
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
      - GF_SERVER_ROOT_URL=http://YOUR_VPS_IP:3000
      - GF_SERVER_SERVE_FROM_SUB_PATH=false
      - GF_ANALYTICS_REPORTING_ENABLED=false
      - GF_ANALYTICS_CHECK_FOR_UPDATES=false
      - GF_LOG_LEVEL=info
      - GF_SERVER_MAX_CONCURRENT_REQUESTS=10
      - GF_SERVER_MAX_CONCURRENT_REQUESTS_PER_USER=5
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

**What this Grafana service does:**
- **image**: The "program" to run (Grafana visualization tool)
- **ports**: The "door" that you can use to access the dashboard interface (3000 for web interface)
- **volumes**: Where to store dashboards, plugins, and settings (like folders on your computer)
- **environment**: All the settings Grafana needs (including admin credentials and performance settings)
- **deploy.resources.limits**: Maximum memory and CPU this program can use (300MB memory, 30% of one CPU)
- **deploy.resources.reservations**: Minimum memory and CPU this program needs (150MB memory, 10% of one CPU)
- **depends_on**: This service waits for InfluxDB to be healthy before starting
- **healthcheck**: A way to check if the dashboard is working properly
- **networks**: Which "network" this program connects to (so it can talk to other programs)

**What Grafana does:** Grafana is like a "digital artist" - it creates beautiful charts and dashboards from your data. You can use it to visualize your sensor data in real-time and create reports.

  # Express Backend (New Component)
  express-backend:
    build:
      context: ./web-app-for-testing/backend
      dockerfile: Dockerfile
    container_name: iot-express-backend
    ports:
      - "3001:3001"

**What this Express Backend service does:**
- **build**: This service needs to be "built" from source code (like compiling a program)
- **context**: Where to find the source code (in the backend folder)
- **dockerfile**: Instructions on how to build the program
- **container_name**: The name of this container
- **ports**: The "door" that other programs can use to connect (3001 for API access)

**What Express Backend does:** Express Backend is like the "brain" of your custom website. It handles requests from your website and communicates with your database to get data.
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
      start_period: 30s
    networks:
      - iot-network

  # React Frontend (New Component)
  react-frontend:
    build:
      context: ./web-app-for-testing/frontend
      dockerfile: Dockerfile
    container_name: iot-react-frontend
    ports:
      - "3002:3000"
    environment:
      - REACT_APP_API_URL=http://YOUR_VPS_IP:3001
      - NODE_ENV=production
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

**What this React Frontend service does:**
- **build**: This service needs to be "built" from source code (like compiling a program)
- **context**: Where to find the source code (in the frontend folder)
- **dockerfile**: Instructions on how to build the program
- **container_name**: The name of this container
- **ports**: The "door" that users can use to access your website (3002 for web access)
- **environment**: Settings for the website (including the URL to connect to the backend)
- **deploy.resources.limits**: Maximum memory and CPU this program can use (150MB memory, 20% of one CPU)
- **deploy.resources.reservations**: Minimum memory and CPU this program needs (75MB memory, 10% of one CPU)
- **depends_on**: This service waits for the Express Backend to be healthy before starting
- **healthcheck**: A way to check if the website is working properly
- **networks**: Which "network" this program connects to (so it can talk to other programs)

**What React Frontend does:** React Frontend is like the "face" of your custom website. It's what users see when they visit your website - the buttons, charts, and interface that displays your data.

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

**What networks do:** Networks are like "phone lines" that allow your applications to talk to each other. The `iot-network` is a private network that only your applications can use.

**What volumes do:** Volumes are like "folders" where your applications store their data. Each application has its own volume so the data persists even if you restart the applications.
```

### **Step 2: Create Web Application Components**

**What are web application components?** These are the parts of your custom website. You need to create special "recipes" (Dockerfiles) that tell Docker how to build your website.

#### 2.1 Create Express Backend Dockerfile
```bash
# Create backend directory
mkdir -p web-app-for-testing/backend

# Create Dockerfile for Express backend
nano web-app-for-testing/backend/Dockerfile
```

**Express Backend Dockerfile:**
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start application
CMD ["npm", "start"]
```

**What this Dockerfile does:**
- `FROM node:18-alpine` - Uses Node.js version 18 as the base (like choosing the foundation for a building)
- `WORKDIR /app` - Sets the working directory (like choosing which room to work in)
- `COPY package*.json ./` - Copies the package files (like bringing in the tools you need)
- `RUN npm ci --only=production` - Installs only the necessary dependencies (like installing only the tools you need for production)
- `COPY . .` - Copies all the source code (like bringing in all your materials)
- `EXPOSE 3001` - Opens port 3001 (like opening a door)
- `HEALTHCHECK` - Checks if the application is working (like a health check for your application)
- `CMD ["npm", "start"]` - Starts the application (like turning on the machine)

#### 2.2 Create React Frontend Dockerfile
```bash
# Create frontend directory
mkdir -p web-app-for-testing/frontend

# Create Dockerfile for React frontend
nano web-app-for-testing/frontend/Dockerfile
```

**React Frontend Dockerfile:**
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
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
```

**What this Dockerfile does:**
- **Build stage**: First, it builds your React application (like assembling a car)
  - `FROM node:18-alpine as build` - Uses Node.js to build the application
  - `RUN npm ci` - Installs all dependencies needed for building
  - `RUN npm run build` - Creates the final website files
- **Production stage**: Then, it serves the built files using Nginx (like putting the finished car on the road)
  - `FROM nginx:alpine` - Uses Nginx web server to serve the files
  - `COPY --from=build /app/build /usr/share/nginx/html` - Copies the built website files
  - `EXPOSE 3000` - Opens port 3000 for web access

**Why two stages?** This is called "multi-stage build" - it's like building a car in a factory (stage 1) and then putting it in a showroom (stage 2). The final result is smaller and more efficient.
  CMD curl -f http://localhost:3000 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

#### 2.3 Create Nginx Configuration
```bash
# Create nginx configuration
nano web-app-for-testing/frontend/nginx.conf
```

**Nginx Configuration:**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

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
        }

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    }
}
```

**What this Nginx configuration does:**
- **events**: Sets how many connections Nginx can handle at once (like how many customers a restaurant can serve)
- **gzip**: Compresses files to make them load faster (like packing a suitcase efficiently)
- **server**: Defines how to serve your website
  - `listen 3000` - Listens on port 3000 (like opening a door)
  - `root /usr/share/nginx/html` - Where to find your website files
  - `location /` - Handles React routing (like a receptionist directing visitors)
  - `location /api/` - Forwards API requests to your Express backend (like a switchboard operator)
  - **Security headers**: Adds protection against common web attacks (like security guards)

### **Step 3: Deploy Application**

**What is deployment?** Deployment is like "turning on" all your applications. We start them in a specific order to make sure they can find each other.

#### 3.1 Start Core Services
```bash
# Start core services first
docker-compose up -d mosquitto influxdb

# Wait for services to be healthy
docker-compose ps

# Check logs for any issues
docker-compose logs mosquitto
docker-compose logs influxdb
```

**What these commands do:**
- `docker-compose up -d mosquitto influxdb` - Starts the MQTT broker and database first (like turning on the foundation of your system)
- `docker-compose ps` - Shows which services are running and their health status
- `docker-compose logs` - Shows the "diary" of each service (useful for troubleshooting)

#### 3.2 Start Processing Services
```bash
# Start Node-RED
docker-compose up -d node-red

# Wait and check
docker-compose ps
docker-compose logs node-red
```

**What this does:** Starts Node-RED (the "digital plumber") after the core services are ready. Node-RED needs the MQTT broker and database to be running first.

#### 3.3 Start Visualization Services
```bash
# Start Grafana
docker-compose up -d grafana

# Wait and check
docker-compose ps
docker-compose logs grafana
```

**What this does:** Starts Grafana (the "digital artist") after the database is ready. Grafana needs InfluxDB to be running to display data.

#### 3.4 Start Web Application
```bash
# Build and start web application
docker-compose up -d express-backend react-frontend

# Check all services
docker-compose ps
```

**What this does:** Starts your custom website (Express backend and React frontend) after all other services are ready. The website needs the database and backend to be running.

### **Step 4: Configuration and Testing**

**What is configuration?** Configuration is like "setting up" your applications so they can work together. It's like connecting the wires between different parts of your system.

#### 4.1 Configure InfluxDB
```bash
# Access InfluxDB CLI
docker exec -it iot-influxdb2 influx

# Create organization and bucket (if not auto-created)
# The docker-compose should handle this automatically
```

**What this does:** Connects to your database to make sure it's set up correctly. The Docker Compose file should automatically create the organization and bucket (like creating folders in your filing cabinet).

#### 4.2 Configure Grafana
```bash
# Access Grafana at http://YOUR_VPS_IP:3000
# Login with admin/admin
# Add InfluxDB data source:
# URL: http://influxdb:8086
# Token: renewable_energy_admin_token_123
# Organization: renewable_energy_org
# Bucket: renewable_energy
```

**What this does:** Sets up Grafana to connect to your database. It's like telling your "digital artist" where to find the data to paint pictures with.

#### 4.3 Configure Node-RED
```bash
# Access Node-RED at http://YOUR_VPS_IP:1880
# Login with admin/adminpassword
# Import your existing flows
```

**What this does:** Sets up Node-RED with your existing data processing flows. It's like importing your "plumbing plans" into the digital plumber.

### **Step 5: Performance Monitoring**

**What is performance monitoring?** Performance monitoring is like having a "dashboard" for your server. It shows you how much work your server is doing and if everything is running smoothly.

#### 5.1 Create Performance Monitoring Script
```bash
# Create performance monitoring script
nano /home/iotadmin/performance-monitor.sh
```

**Performance Monitoring Script:**
```bash
#!/bin/bash

echo "=== Renewable Energy IoT System Performance ==="
echo "Timestamp: $(date)"
echo

echo "=== System Resources ==="
echo "Memory Usage:"
free -h

echo -e "\nDisk Usage:"
df -h

echo -e "\nCPU Load:"
uptime

echo -e "\n=== Docker Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"

echo -e "\n=== Container Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo -e "\n=== Service Health Checks ==="
echo "MQTT Broker:"
curl -s http://localhost:1883/ || echo "MQTT not accessible via HTTP"

echo -e "\nInfluxDB:"
curl -s http://localhost:8086/health || echo "InfluxDB health check failed"

echo -e "\nNode-RED:"
curl -s http://localhost:1880/ || echo "Node-RED not accessible"

echo -e "\nGrafana:"
curl -s http://localhost:3000/api/health || echo "Grafana health check failed"

echo -e "\nExpress Backend:"
curl -s http://localhost:3001/health || echo "Express backend health check failed"

echo -e "\nReact Frontend:"
curl -s http://localhost:3002/ || echo "React frontend not accessible"

echo -e "\n=== Network Connections ==="
netstat -tulpn | grep -E ':(1883|8086|1880|3000|3001|3002)'

echo -e "\n=== Recent Logs ==="
echo "Last 10 lines from each service:"
for service in mosquitto influxdb node-red grafana express-backend react-frontend; do
    echo "--- $service ---"
    docker logs --tail 10 $service 2>/dev/null || echo "No logs available"
    echo
done
```

```bash
# Make script executable
chmod +x /home/iotadmin/performance-monitor.sh
```

#### 5.2 Set Up Automated Monitoring
```bash
# Create cron job for regular monitoring
crontab -e

# Add this line for monitoring every 5 minutes:
# */5 * * * * /home/iotadmin/performance-monitor.sh >> /home/iotadmin/performance.log 2>&1
```

---

## 🧪 Testing and Validation

**What is testing and validation?** Testing is like "checking" that everything works properly. It's like testing all the parts of a machine to make sure they're working correctly.

### **Test 1: Service Connectivity**
```bash
# Test all services are running
docker-compose ps

# Test service health
./performance-monitor.sh
```

**What this tests:** Checks if all your applications are running and healthy. It's like checking if all the lights are on in your house.

### **Test 2: Web Interface Access**
```bash
# Test Grafana
curl -I http://YOUR_VPS_IP:3000

# Test Node-RED
curl -I http://YOUR_VPS_IP:1880

# Test Express Backend
curl -I http://YOUR_VPS_IP:3001

# Test React Frontend
curl -I http://YOUR_VPS_IP:3002
```

**What this tests:** Checks if you can access all your web interfaces from the internet. It's like testing if all the doors to your house are working.

### **Test 3: Data Flow Testing**
```bash
# Test MQTT connectivity
docker exec -it iot-mosquitto mosquitto_pub -h localhost -u admin -P admin_password_456 -t test/topic -m "test message"

# Test InfluxDB connectivity
curl -G http://localhost:8086/query \
  --data-urlencode "q=SHOW DATABASES" \
  --header "Authorization: Token renewable_energy_admin_token_123"
```

### **Test 4: Performance Testing**
```bash
# Monitor resource usage
docker stats

# Check memory usage
free -h

# Check disk usage
df -h
```

---

## 📊 Expected Performance Metrics

**What are performance metrics?** Performance metrics are like "measurements" of how well your system is working. They tell you how much resources each part of your system is using.

### **Resource Usage on Mikrus 3.0:**

| Service | Memory | CPU | Storage | Status | What This Means |
|---------|--------|-----|---------|--------|-----------------|
| **MQTT Broker** | 50-100MB | 0.1-0.2 cores | 100MB | ✅ Lightweight | The "post office" uses very little resources |
| **InfluxDB** | 512MB-1GB | 0.5-1.0 cores | 5-10GB | ⚠️ Resource-intensive | The "filing cabinet" uses the most resources (stores all your data) |
| **Node-RED** | 200-400MB | 0.2-0.5 cores | 500MB | ✅ Moderate | The "digital plumber" uses moderate resources |
| **Grafana** | 150-300MB | 0.1-0.3 cores | 1GB | ✅ Moderate | The "digital artist" uses moderate resources |
| **Express Backend** | 100-200MB | 0.1-0.3 cores | 100MB | ✅ Lightweight | Your website's "brain" uses little resources |
| **React Frontend** | 75-150MB | 0.1-0.2 cores | 200MB | ✅ Lightweight | Your website's "face" uses little resources |
| **System Overhead** | 200-400MB | 0.5 core | 2GB | ✅ Acceptable | The operating system and basic tools |

**Total Expected Usage:**
- **Memory**: 1.2-2.2GB (within 2GB limit) - You're using most of your available memory, but it should work
- **CPU**: 1.1-2.5 cores (within 2 core limit) - You're using most of your available CPU power, but it should work
- **Storage**: 8-14GB (within 25GB limit) - You have plenty of storage space left

---

## ⚠️ Troubleshooting

**What is troubleshooting?** Troubleshooting is like "fixing problems" when something goes wrong. It's like being a mechanic who figures out what's wrong with a car and fixes it.

### **Common Issues:**

#### **Issue 1: Memory Exhaustion**
```bash
# Solution: Optimize memory usage
# Reduce InfluxDB memory limits
# Add swap file
# Monitor with: docker stats
```

**What this means:** Your server runs out of memory (RAM). This happens when your applications try to use more memory than your server has available.

#### **Issue 2: Container Startup Failures**
```bash
# Check container logs
docker-compose logs [service-name]

# Check resource limits
docker stats

# Restart specific service
docker-compose restart [service-name]
```

**What this means:** One or more of your applications isn't starting properly. This could be due to configuration errors, missing files, or resource issues.

#### **Issue 3: Network Connectivity Issues**
```bash
# Check network configuration
docker network ls
docker network inspect renewable-energy-iot_iot-network

# Test inter-container communication
docker exec -it iot-node-red ping influxdb
```

**What this means:** Your applications can't talk to each other. This is like having a broken phone line between different parts of your system.

#### **Issue 4: Data Persistence Issues**
```bash
# Check volume mounts
docker volume ls
docker volume inspect [volume-name]

# Backup important data
docker exec -it iot-influxdb2 influx backup /backups/$(date +%Y%m%d)
```

**What this means:** Your data is disappearing when you restart your applications. This usually means your data isn't being saved to the right place.

---

## ✅ Phase 2 Completion Checklist

- [ ] **All Docker containers deployed** - All your applications are running on the server
- [ ] **Resource limits configured** - Your applications won't use too much memory or CPU
- [ ] **Services communicating properly** - All your applications can talk to each other
- [ ] **Web interfaces accessible** - You can access your dashboards and website from the internet
- [ ] **Data persistence working** - Your data will be saved even if you restart the applications
- [ ] **Performance monitoring active** - You have tools to watch how your system is performing
- [ ] **All tests passed** - Everything is working correctly
- [ ] **System stable and running** - Your system is working smoothly and reliably

---

## 🎯 Next Steps

After completing Phase 2, proceed to:
- **[Phase 3: Data Migration and Testing](./03-data-migration-testing.md)**
- **[Phase 4: Production Optimization](./04-production-optimization.md)**
- **[Phase 5: Monitoring and Maintenance](./05-monitoring-maintenance.md)**

---

## 🤖 AI Prompts for This Phase

**What are AI prompts?** These are questions you can ask AI (like ChatGPT or Claude) to get help with specific problems. Copy and paste these prompts when you need help with this phase.

### **Prompt 1: Docker Resource Optimization**
```
I'm deploying a renewable energy IoT monitoring system on a VPS with 2GB RAM and 25GB storage.
Services: MQTT broker, InfluxDB 2.7, Node-RED, Grafana, Express backend, React frontend.
Please help optimize Docker container resource limits and memory allocation for optimal performance.
```

**When to use this:** If your applications are using too much memory or CPU, or if you want to optimize performance.

### **Prompt 2: Service Health Monitoring**
```
I need to create comprehensive health monitoring for my Docker-based IoT system.
Services: Mosquitto MQTT, InfluxDB, Node-RED, Grafana, Express, React.
Please provide monitoring scripts and alerting configuration for a production environment.
```

**When to use this:** If you want to set up better monitoring tools or if your current monitoring isn't working well.

### **Prompt 3: Performance Troubleshooting**
```
My renewable energy IoT system is experiencing performance issues on a 2GB RAM VPS.
Symptoms: slow response times, high memory usage, container restarts.
Please help diagnose and optimize the system for better performance.
```

**When to use this:** If your system is running slowly or having problems with performance.

---

**🎉 Phase 2 Complete! Your renewable energy IoT monitoring system is now deployed and running.**
