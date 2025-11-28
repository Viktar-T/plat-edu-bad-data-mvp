# Stage 1: Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Build arguments for Vite environment variables
ARG VITE_API_URL
ARG VITE_API_BASE_URL
ARG VITE_BASE_PATH=/
ARG NODE_ENV=production

# Set environment variables for build
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_BASE_PATH=$VITE_BASE_PATH
ENV NODE_ENV=$NODE_ENV

# Copy package files
COPY package*.json ./
COPY package-lock.json* ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci --include=dev

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

