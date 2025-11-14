# Step 4: Update docker-compose.yml to Include Frontend and API

## Context
You have an existing docker-compose.yml with mosquitto, influxdb, node-red, and grafana services. Now you need to add the frontend and api services to the orchestration.

## Current Services
- **mosquitto**: Port 40098 (MQTT broker)
- **influxdb**: Port 40101 (Time-series database)
- **node-red**: Port 40100 (Data processing)
- **grafana**: Port 40099 (Visualization)

## New Services to Add
- **api**: Port 3001 (Express.js backend)
- **frontend**: Port 5173 (React frontend via nginx on port 80, mapped to 5173)

## Task
Add the frontend and api services to your docker-compose.yml with proper:
1. Service definitions
2. Port mappings
3. Environment variables
4. Volume mounts
5. Dependencies
6. Health checks
7. Network configuration

## Implementation

Add these two services to your `docker-compose.yml` file, right after the `grafana` service (before the `networks` section):

```yaml
  # API Backend - Express.js
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: iot-api
    ports:
      - "${API_PORT:-3001}:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
      - TZ=UTC
      # InfluxDB Configuration
      - INFLUXDB_URL=http://influxdb:8086
      - INFLUXDB_ORG=${INFLUXDB_ORG:-renewable_energy_org}
      - INFLUXDB_BUCKET=${INFLUXDB_BUCKET:-renewable_energy}
      - TEST_TOKEN=${INFLUXDB_ADMIN_TOKEN:-renewable_energy_admin_token_123}
      # CORS Configuration
      - CORS_ORIGIN=${CORS_ORIGIN:-http://localhost:5173}
    volumes:
      - ./api/src:/app/src:ro
      - ./api/public:/app/public:ro
    restart: unless-stopped
    depends_on:
      influxdb:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:3001/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - iot-network

  # Frontend - React with Vite
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: iot-frontend
    ports:
      - "${FRONTEND_PORT:-5173}:80"
    environment:
      - NODE_ENV=production
      - TZ=UTC
      # API Configuration
      - VITE_API_URL=${VITE_API_URL:-http://localhost:3001}
      - VITE_API_BASE_URL=${VITE_API_BASE_URL:-http://localhost:3001/api}
    restart: unless-stopped
    depends_on:
      api:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:80/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    networks:
      - iot-network
```

## Update Environment Variables

Add these variables to your `.env` file (or `env.example`):

```bash
# API Service Configuration
API_PORT=3001
CORS_ORIGIN=http://localhost:5173

# Frontend Service Configuration
FRONTEND_PORT=5173
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
```

## Update API Code for Docker Networking

The API currently uses a hardcoded production URL. Update `api/src/index.js`:

**Find this line:**
```javascript
const INFLUXDB_BASE_URL_PROD = 'http://robert108.mikrus.xyz:40101'
```

**Replace with:**
```javascript
const INFLUXDB_BASE_URL = process.env.INFLUXDB_URL || 'http://robert108.mikrus.xyz:40101'
```

**And update the InfluxDB initialization:**
```javascript
const influx = new InfluxDB({ url: INFLUXDB_BASE_URL, token, timeout });
```

## Complete Docker Compose Structure

Your updated `docker-compose.yml` should now have this service order:
1. mosquitto (MQTT Broker)
2. influxdb (Database)
3. node-red (Data Processing)
4. grafana (Visualization)
5. **api (NEW - Backend API)**
6. **frontend (NEW - Web Interface)**
7. networks section
8. volumes section

## Verification Steps

1. **Validate docker-compose syntax:**
```powershell
docker-compose config
```

2. **Build all services:**
```powershell
docker-compose build api frontend
```

3. **Start only new services:**
```powershell
docker-compose up -d api frontend
```

4. **Check service status:**
```powershell
docker-compose ps
```

5. **View logs:**
```powershell
docker-compose logs -f api frontend
```

6. **Test API health:**
```powershell
curl http://localhost:3001/health
```

7. **Test Frontend:**
Open browser to http://localhost:5173

8. **Check network connectivity:**
```powershell
docker exec iot-api ping influxdb -c 3
docker exec iot-frontend ping api -c 3
```

## Service Dependencies Flow

```
mosquitto (MQTT Broker)
    ↓
node-red (depends on mosquitto)
    ↓
influxdb (depends on mosquitto)
    ↓
grafana (depends on influxdb)
    ↓
api (depends on influxdb)
    ↓
frontend (depends on api)
```

## Troubleshooting

### API cannot connect to InfluxDB
```powershell
# Check if InfluxDB is healthy
docker-compose ps influxdb

# Check network connectivity
docker exec iot-api ping influxdb -c 3

# Check environment variables
docker exec iot-api env | Select-String "INFLUX"
```

### Frontend cannot reach API
```powershell
# Check API logs
docker-compose logs api

# Verify CORS configuration
docker exec iot-api env | Select-String "CORS"

# Test API from host
curl http://localhost:3001/health
```

### Port conflicts
```powershell
# Check what's using ports
netstat -ano | Select-String "3001"
netstat -ano | Select-String "5173"
```

## Production Considerations

For VPS deployment, update `.env` with production values:
```bash
# Production Ports (Mikrus VPS)
API_PORT=40102
FRONTEND_PORT=40103

# Production URLs
VITE_API_URL=http://robert108.mikrus.xyz:40102
VITE_API_BASE_URL=http://robert108.mikrus.xyz:40102/api
CORS_ORIGIN=http://robert108.mikrus.xyz:40103
```

## Next Steps
- Proceed to Step 5: Configure Frontend-API Communication
- Update frontend API service configuration to use environment variables

## Notes
- Services use internal Docker networking (iot-network)
- API connects to InfluxDB using `http://influxdb:8086` (internal DNS)
- Frontend connects to API using `http://localhost:3001` (from host) or configure for internal
- All services have health checks for proper orchestration
- Volumes are mounted read-only (`:ro`) where possible for security

