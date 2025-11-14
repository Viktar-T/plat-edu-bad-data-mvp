# Docker Internal Networking Setup Guide

**Date:** 2024-11-25  
**Purpose:** Configure API and Frontend to use Docker internal networking for local development and production deployment

---

## Overview

This guide explains how the system has been configured to use Docker internal networking, allowing all services to communicate within the Docker network using service names instead of external URLs.

### Key Changes

1. **API Backend**: Now uses Docker service name `influxdb:8086` for internal communication
2. **Removed Hardcoded URLs**: All external URLs have been removed from code
3. **Environment-Based Configuration**: Uses environment variables for flexibility

---

## Architecture

### Data Flow in Docker

```
┌─────────────────────────────────────────────────────────┐
│              Docker Network (iot-network)                │
│                                                          │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐     │
│  │ Frontend │─────▶│   API    │─────▶│ InfluxDB │     │
│  │  :80     │      │  :3001   │      │  :8086   │     │
│  └──────────┘      └──────────┘      └──────────┘     │
│       │                  │                  │           │
│       └──────────────────┴──────────────────┘           │
│                    (Service Names)                      │
└─────────────────────────────────────────────────────────┘
```

### Communication Methods

**Inside Docker (Container-to-Container):**
- Uses Docker service names: `http://influxdb:8086`
- Fast, secure, internal network communication
- No external network required

**From Host Machine (Browser-to-Container):**
- Uses `localhost` with mapped ports: `http://localhost:3001`
- Ports are exposed to host for browser access

---

## Configuration Details

### API Backend (`api/src/index.js`)

**InfluxDB Connection:**
```javascript
// Automatically detects Docker environment
const getInfluxDBUrl = () => {
  if (process.env.INFLUXDB_URL) {
    return process.env.INFLUXDB_URL;  // Use explicit config
  }
  return 'http://influxdb:8086';  // Default: Docker service name
};
```

**CORS Configuration:**
- Uses `CORS_ORIGIN` environment variable
- Defaults to local development URLs if not set
- Supports multiple origins (comma-separated)

### Docker Compose Configuration

#### Local Development (`docker-compose.local.yml`)

**API Service:**
```yaml
api:
  environment:
    - INFLUXDB_URL=http://influxdb:8086  # Docker service name
    - CORS_ORIGIN=http://localhost:3002,http://localhost:5173
  networks:
    - iot-network-local
  depends_on:
    influxdb:
      condition: service_healthy
```

**Frontend Service:**
```yaml
frontend:
  build:
    args:
      - VITE_API_URL=http://localhost:3001  # Browser-accessible URL
      - VITE_API_BASE_URL=http://localhost:3001/api
  depends_on:
    api:
      condition: service_healthy
```

#### Production (`docker-compose.prod.yml`)

**API Service:**
```yaml
api:
  environment:
    - INFLUXDB_URL=http://influxdb:8086  # Docker service name
    - CORS_ORIGIN=${CORS_ORIGIN}  # Set via .env file
```

**Frontend Service:**
```yaml
frontend:
  build:
    args:
      - VITE_API_URL=${VITE_API_URL}  # Set via .env file
      - VITE_API_BASE_URL=${VITE_API_BASE_URL}
```

---

## Environment Variables

### Local Development

Create `.env.local` or set in `docker-compose.local.yml`:

```bash
# API Configuration
INFLUXDB_URL=http://influxdb:8086
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
TEST_TOKEN=renewable_energy_admin_token_123
CORS_ORIGIN=http://localhost:3002,http://localhost:5173

# Frontend Configuration (build-time)
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
```

### Production (VPS)

Create `.env.production` or set in environment:

```bash
# API Configuration
INFLUXDB_URL=http://influxdb:8086  # Always use Docker service name
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
TEST_TOKEN=renewable_energy_admin_token_123
CORS_ORIGIN=http://robert108.mikrus.xyz:40103,http://localhost:3002

# Frontend Configuration (build-time)
VITE_API_URL=http://robert108.mikrus.xyz:40102
VITE_API_BASE_URL=http://robert108.mikrus.xyz:40102/api

# Port Configuration
API_PORT=40102
FRONTEND_PORT=40103
```

---

## Usage Instructions

### Local Development

1. **Start Infrastructure Services:**
   ```powershell
   docker-compose -f docker-compose.local.yml up -d mosquitto influxdb
   ```

2. **Start API and Frontend:**
   ```powershell
   docker-compose -f docker-compose.local.yml up -d api frontend
   ```

3. **Access Services:**
   - Frontend: http://localhost:3002
   - API: http://localhost:3001
   - API Health: http://localhost:3001/health

4. **View Logs:**
   ```powershell
   docker-compose -f docker-compose.local.yml logs -f api
   docker-compose -f docker-compose.local.yml logs -f frontend
   ```

### Production Deployment (VPS)

1. **Set Environment Variables:**
   ```bash
   # On VPS, create .env file
   export VITE_API_URL=http://robert108.mikrus.xyz:40102
   export VITE_API_BASE_URL=http://robert108.mikrus.xyz:40102/api
   export CORS_ORIGIN=http://robert108.mikrus.xyz:40103
   ```

2. **Build and Start Services:**
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
   ```

3. **Verify Services:**
   ```bash
   docker-compose ps
   curl http://localhost:3001/health
   ```

---

## Key Benefits

### ✅ Internal Communication
- **Fast**: No external network latency
- **Secure**: Services communicate within Docker network
- **Reliable**: No dependency on external URLs

### ✅ Flexibility
- **Environment-Based**: Different configs for dev/prod
- **Override Support**: Can override via environment variables
- **Port Mapping**: External ports can be changed without code changes

### ✅ Scalability
- **Service Discovery**: Docker handles service name resolution
- **Load Balancing**: Can add multiple instances behind service name
- **Network Isolation**: Services isolated from host network

---

## Troubleshooting

### API Cannot Connect to InfluxDB

**Symptoms:**
- API logs show connection errors
- Health check fails

**Solutions:**
1. Verify InfluxDB is running:
   ```powershell
   docker-compose ps influxdb
   ```

2. Check API can resolve service name:
   ```powershell
   docker-compose exec api ping influxdb
   ```

3. Verify environment variable:
   ```powershell
   docker-compose exec api env | grep INFLUXDB_URL
   ```
   Should show: `INFLUXDB_URL=http://influxdb:8086`

4. Check network connectivity:
   ```powershell
   docker-compose exec api wget -O- http://influxdb:8086/health
   ```

### Frontend Cannot Connect to API

**Symptoms:**
- Browser console shows CORS errors
- API requests fail

**Solutions:**
1. Verify API is accessible from browser:
   ```powershell
   curl http://localhost:3001/health
   ```

2. Check CORS configuration:
   ```powershell
   docker-compose exec api env | grep CORS_ORIGIN
   ```

3. Verify frontend API URL:
   - Check browser Network tab for actual request URL
   - Verify `VITE_API_URL` was set at build time

4. Rebuild frontend if API URL changed:
   ```powershell
   docker-compose -f docker-compose.local.yml build frontend
   docker-compose -f docker-compose.local.yml up -d frontend
   ```

### Port Conflicts

**Symptoms:**
- Services fail to start
- "Port already in use" errors

**Solutions:**
1. Check what's using the port:
   ```powershell
   netstat -ano | findstr :3001
   ```

2. Change port in docker-compose:
   ```yaml
   ports:
     - "3003:3001"  # Host:Container
   ```

3. Update frontend API URL if API port changed

---

## Migration Notes

### What Changed

1. **Removed Hardcoded URLs:**
   - ❌ `http://robert108.mikrus.xyz:40101` (removed from code)
   - ✅ `http://influxdb:8086` (Docker service name)

2. **Updated Defaults:**
   - API now defaults to Docker service name
   - CORS defaults to local development URLs

3. **Environment Variables:**
   - All URLs now configurable via environment variables
   - No code changes needed for different environments

### Backward Compatibility

- **Existing Deployments**: Will continue to work if `INFLUXDB_URL` is set
- **Local Development**: Works out of the box with Docker Compose
- **Production**: Requires setting environment variables

---

## Best Practices

1. **Always Use Service Names in Docker:**
   - ✅ `http://influxdb:8086` (inside Docker)
   - ❌ `http://localhost:8086` (won't work from container)

2. **Set Environment Variables:**
   - Use `.env` files for different environments
   - Never commit `.env` files to git
   - Document required variables in `env.example`

3. **Verify Network Connectivity:**
   - Test service-to-service communication
   - Check health endpoints
   - Monitor logs for connection errors

4. **Port Mapping:**
   - Map ports only for browser access
   - Use service names for container-to-container communication
   - Document port mappings in README

---

## Summary

The system now uses Docker internal networking for all service-to-service communication:

- **API → InfluxDB**: Uses `http://influxdb:8086` (Docker service name)
- **Frontend → API**: Uses `http://localhost:3001` (browser access) or service name if needed
- **All Services**: Connected via Docker network `iot-network`

This provides:
- ✅ Faster internal communication
- ✅ Better security (isolated network)
- ✅ Easier deployment (no external URL dependencies)
- ✅ Environment flexibility (dev/prod configs)

---

**Last Updated:** 2024-11-25  
**Version:** 1.0

