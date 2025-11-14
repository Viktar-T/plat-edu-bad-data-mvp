# Step 2: Create Dockerfile for API Service

## Context
You have an Express.js API in the `api/` folder that connects to InfluxDB. The API currently runs on port 3001 and uses InfluxDB client to query data from the renewable energy monitoring system.

## Current API Structure
- **Location**: `api/`
- **Entry Point**: `src/index.js`
- **Port**: 3001
- **Dependencies**: 
  - Express.js
  - @influxdata/influxdb-client
  - cors
  - dotenv
- **Current InfluxDB URL**: http://robert108.mikrus.xyz:40101 (production)

## Task
Create a production-ready Dockerfile for the API service that:
1. Uses Node.js 20 Alpine image for minimal size
2. Implements multi-stage build for optimization
3. Sets up proper working directory and user permissions
4. Installs dependencies efficiently with layer caching
5. Exposes port 3001
6. Includes health check support

## Implementation

Create `api/Dockerfile` with the following content:

```dockerfile
# Stage 1: Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Stage 2: Production stage
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy dependencies from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application source
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs src ./src
COPY --chown=nodejs:nodejs public ./public
COPY --chown=nodejs:nodejs components ./components

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3001

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "src/index.js"]
```

## Create .dockerignore File

Create `api/.dockerignore` to optimize build context:

```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.local
.DS_Store
*.md
.vscode
.idea
coverage
dist
build
```

## Verification Steps

After creating the Dockerfile:

1. Verify the Dockerfile syntax:
```powershell
docker build -t api-test ./api --no-cache
```

2. Test the image locally (without running):
```powershell
docker images | Select-String "api-test"
```

3. Clean up test image:
```powershell
docker rmi api-test
```

## Next Steps
- Proceed to Step 3: Create Dockerfile for Frontend
- The API will be integrated into docker-compose.yml in a later step

## Notes
- The Dockerfile uses multi-stage build to reduce final image size
- Non-root user (nodejs) improves security
- Health check endpoint `/health` is already implemented in your API
- Dependencies are cached in a separate layer for faster rebuilds

