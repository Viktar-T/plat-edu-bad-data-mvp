# Step 3: Create Dockerfile for Frontend Service

## Context
You have a Vite React application in the `frontend/` folder. Vite is a modern build tool that requires a build step for production and can serve development mode with hot reload.

## Current Frontend Structure
- **Location**: `frontend/`
- **Framework**: React 19 with Vite 7
- **Dev Port**: 5173 (Vite default)
- **Build Output**: `dist/` folder
- **Dependencies**:
  - React, React-DOM, React Router
  - Leaflet for maps
  - FontAwesome icons
  - SASS for styling

## Task
Create a production-ready Dockerfile for the frontend that:
1. Uses multi-stage build (build stage + nginx serve stage)
2. Builds the Vite application
3. Serves static files using nginx
4. Configures nginx for SPA routing
5. Optimizes for production deployment

## Implementation

### 1. Create `frontend/Dockerfile`

```dockerfile
# Stage 1: Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production stage with nginx
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create non-root user for nginx
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

### 2. Create `frontend/nginx.conf`

Create an nginx configuration for SPA routing:

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/json application/javascript;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA fallback - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Disable access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

### 3. Create `frontend/.dockerignore`

```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.local
.env.*.local
.DS_Store
*.md
.vscode
.idea
coverage
dist
build
.eslintcache
```

### 4. Update `frontend/vite.config.js` (Optional)

Ensure the Vite config is production-ready:

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [['babel-plugin-react-compiler']],
      },
    }),
  ],
  server: {
    host: true, // Listen on all addresses
    port: 5173,
  },
  preview: {
    host: true,
    port: 5173,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'map-vendor': ['leaflet', 'react-leaflet'],
        }
      }
    }
  }
})
```

## Verification Steps

1. Test the build locally:
```powershell
cd frontend
npm run build
```

2. Build the Docker image:
```powershell
docker build -t frontend-test ./frontend --no-cache
```

3. Test run the container:
```powershell
docker run -p 8080:80 frontend-test
```

4. Access http://localhost:8080 in your browser

5. Clean up:
```powershell
docker stop $(docker ps -q --filter ancestor=frontend-test)
docker rmi frontend-test
```

## Alternative: Development Dockerfile

If you need a development version with hot reload, create `frontend/Dockerfile.dev`:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev"]
```

## Next Steps
- Proceed to Step 4: Update docker-compose.yml to include both services
- Configure environment variables for API communication

## Notes
- Production build uses nginx for optimal performance
- SPA routing is configured to handle React Router
- Static assets are cached for 1 year
- Security headers are included
- Health check endpoint is available at `/health`
- The build creates optimized chunks for better loading performance

