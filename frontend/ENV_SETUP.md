# Frontend Environment Variables Setup

## Overview
The frontend uses Vite environment variables prefixed with `VITE_` to configure API endpoints and other settings.

## Environment Files

### Development (`.env.development`)
Create this file for local development:
```bash
# Development Environment
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
```

### Production (`.env.production`)
Create this file for production builds:
```bash
# Production Environment (VPS)
VITE_API_URL=http://robert108.mikrus.xyz:40102
VITE_API_BASE_URL=http://robert108.mikrus.xyz:40102/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
```

### Local Docker (`.env.local`)
Create this file for local Docker development:
```bash
# Local Development with Docker
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
```

## Important Notes

1. **Vite embeds environment variables at build time** - You must rebuild the frontend after changing environment variables.

2. **Environment variables must be prefixed with `VITE_`** - Only variables starting with `VITE_` are exposed to the frontend code.

3. **Docker builds** - When building with Docker, environment variables can be passed via docker-compose.yml or Dockerfile ARG/ENV.

4. **Priority order**:
   - `.env.local` (highest priority, not committed to git)
   - `.env.development` or `.env.production` (based on mode)
   - Default values in `src/config/api.js`

## Quick Setup

1. Copy the example file:
   ```bash
   cp .env.local.example .env.local
   ```

2. Edit `.env.local` with your local settings

3. Rebuild if needed:
   ```bash
   npm run build
   ```

## Docker Environment Variables

When running in Docker, environment variables are set in `docker-compose.yml`:
```yaml
environment:
  - VITE_API_URL=${VITE_API_URL:-http://localhost:3001}
  - VITE_API_BASE_URL=${VITE_API_BASE_URL:-http://localhost:3001/api}
```

These are embedded during the Docker build process.

