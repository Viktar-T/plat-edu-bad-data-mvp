# Add Nginx Reverse Proxy to Local Development Environment

## Goal
Add Nginx as reverse proxy to local development stack. Access services via:
- `http://localhost:8080/grafana/` → Grafana
- `http://localhost:8080/nodered/` → Node-RED  
- `http://localhost:8080/influxdb/` → InfluxDB
- Mosquitto stays on direct ports (1883, 9001)

## Scope
**ONLY modify local development files:**
- `docker-compose.local.yml` (add nginx service, change ports to expose)
- `nginx/nginx.local.conf` (new file)
- `node-red/settings.local.js` (new file)

**DO NOT touch:**
- `docker-compose.yml` (production)
- `nginx/nginx.conf` (production)

## Required Changes

### 1. Create `nginx/nginx.local.conf`
```nginx
events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;
    sendfile on;
    keepalive_timeout 65;
    gzip on;

    upstream grafana_backend { server iot-grafana-local:3000; }
    upstream nodered_backend { server iot-node-red-local:1880; }
    upstream influxdb_backend { server iot-influxdb2-local:8086; }

    server {
        listen 80;
        server_name _;

        location /grafana/ {
            rewrite ^/grafana/(.*)$ /$1 break;
            proxy_pass http://grafana_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /nodered/ {
            rewrite ^/nodered/(.*)$ /$1 break;
            proxy_pass http://nodered_backend/;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /influxdb/ {
            rewrite ^/influxdb/(.*)$ /$1 break;
            proxy_pass http://influxdb_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Script-Name /influxdb;
            proxy_set_header X-Scheme $scheme;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        location / {
            return 302 /grafana/;
        }
    }
}
```

### 2. Update `docker-compose.local.yml`
**For Grafana service:**
- Replace `ports: ["3000:3000"]` with `expose: ["3000"]`
- Add environment variables:
  ```yaml
  - GF_SERVER_ROOT_URL=http://localhost:8080/grafana
  - GF_SERVER_SERVE_FROM_SUB_PATH=true
  ```

**For Node-RED service:**
- Replace `ports: ["1880:1880"]` with `expose: ["1880"]`
- Change settings mount: `./node-red/settings.local.js:/data/settings.js`

**For InfluxDB service:**
- Replace `ports: ["8086:8086"]` with `expose: ["8086"]`

**Add new nginx service:**
```yaml
nginx:
  image: nginx:alpine
  container_name: iot-nginx-local
  ports:
    - "8080:80"
  volumes:
    - ./nginx/nginx.local.conf:/etc/nginx/nginx.conf:ro
  restart: unless-stopped
  depends_on:
    grafana:
      condition: service_healthy
    node-red:
      condition: service_healthy
    influxdb:
      condition: service_healthy
  healthcheck:
    test: ["CMD-SHELL", "wget -qO- http://localhost/health || exit 1"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 30s
  networks:
    - iot-network-local
```

### 3. Create `node-red/settings.local.js`
```javascript
module.exports = {
  flowFile: 'flows.json',
  ui: { path: 'ui' },
  httpAdminRoot: '/nodered',
  httpNodeRoot: '/nodered',
  editorTheme: { theme: { name: "dark" } },
  logging: { console: { level: "info", metrics: false, audit: false } },
};
```

## Test Commands
```powershell
docker-compose -f docker-compose.local.yml down
docker-compose -f docker-compose.local.yml up -d --build
docker-compose -f docker-compose.local.yml ps
```

## Success Criteria
- `http://localhost:8080/grafana/` loads Grafana
- `http://localhost:8080/nodered/` loads Node-RED
- `http://localhost:8080/influxdb/` loads InfluxDB
- `http://localhost:8080/health` returns 200
- Direct ports (3000, 1880, 8086) no longer accessible
- Mosquitto still accessible on 1883, 9001
