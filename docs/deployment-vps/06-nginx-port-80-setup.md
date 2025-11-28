# Nginx Port 80 Setup Guide

This guide explains how to configure the system to use port 80 (standard HTTP port) so URLs don't require the port number.

## Current Configuration

After the update, the system is configured to:
- Serve frontend at root: `http://edubad.zut.edu.pl/`
- Node-RED at: `http://edubad.zut.edu.pl/nodered/`
- InfluxDB at: `http://edubad.zut.edu.pl/influxdb/`
- Grafana at: `http://edubad.zut.edu.pl/grafana/`
- API at: `http://edubad.zut.edu.pl/api/`

## Option 1: Direct Port 80 Access (Recommended)

If you have access to port 80 on your VPS:

### Step 1: Update docker-compose.yml

The `docker-compose.yml` is already configured to use port 80:

```yaml
nginx:
  ports:
    - "${NGINX_PORT:-80}:80"
```

### Step 2: Ensure Port 80 is Available

```bash
# Check if port 80 is in use
sudo netstat -tulpn | grep :80
# or
sudo ss -tulpn | grep :80

# If another service is using port 80, you may need to:
# 1. Stop the service
# 2. Configure it to use a different port
# 3. Or use Option 2 (External Reverse Proxy)
```

### Step 3: Restart Services

```bash
cd ~/plat-edu-bad-data-mvp
sudo docker-compose down
sudo docker-compose up -d
```

### Step 4: Verify

- Frontend: `http://edubad.zut.edu.pl/`
- Node-RED: `http://edubad.zut.edu.pl/nodered/`
- InfluxDB: `http://edubad.zut.edu.pl/influxdb/`
- Grafana: `http://edubad.zut.edu.pl/grafana/`

## Option 2: External Reverse Proxy (If Port 80 Not Available)

If port 80 is not available or you prefer to use an external reverse proxy:

### Step 1: Keep Docker on Port 8080

Update `docker-compose.yml` to use port 8080:

```yaml
nginx:
  ports:
    - "${NGINX_PORT:-8080}:80"
```

Or set environment variable:

```bash
export NGINX_PORT=8080
```

### Step 2: Configure External Reverse Proxy

#### Using Apache (if installed)

Create `/etc/apache2/sites-available/edubad.conf`:

```apache
<VirtualHost *:80>
    ServerName edubad.zut.edu.pl
    
    ProxyPreserveHost On
    ProxyRequests Off
    
    # Frontend (root)
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    # Node-RED
    ProxyPass /nodered/ http://localhost:8080/nodered/
    ProxyPassReverse /nodered/ http://localhost:8080/nodered/
    
    # InfluxDB
    ProxyPass /influxdb/ http://localhost:8080/influxdb/
    ProxyPassReverse /influxdb/ http://localhost:8080/influxdb/
    
    # Grafana
    ProxyPass /grafana/ http://localhost:8080/grafana/
    ProxyPassReverse /grafana/ http://localhost:8080/grafana/
    
    # API
    ProxyPass /api/ http://localhost:8080/api/
    ProxyPassReverse /api/ http://localhost:8080/api/
    
    # WebSocket support
    RewriteEngine on
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://localhost:8080/$1" [P,L]
</VirtualHost>
```

Enable and restart:

```bash
sudo a2ensite edubad.conf
sudo a2enmod proxy proxy_http rewrite
sudo systemctl restart apache2
```

#### Using Another Nginx Instance

Create `/etc/nginx/sites-available/edubad`:

```nginx
server {
    listen 80;
    server_name edubad.zut.edu.pl;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Enable and restart:

```bash
sudo ln -s /etc/nginx/sites-available/edubad /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Option 3: Use Environment Variable

You can override the port using environment variables:

```bash
# Use port 80
export NGINX_PORT=80
sudo docker-compose up -d

# Or use port 8080
export NGINX_PORT=8080
sudo docker-compose up -d
```

## Troubleshooting

### Port Already in Use

If you get an error that port 80 is already in use:

```bash
# Find what's using port 80
sudo lsof -i :80
# or
sudo fuser 80/tcp

# Stop the service or reconfigure it
```

### Firewall Configuration

Make sure port 80 is open in your firewall:

```bash
# UFW
sudo ufw allow 80/tcp

# firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

### SELinux (if enabled)

If SELinux is blocking the connection:

```bash
# Allow nginx to bind to port 80
sudo setsebool -P httpd_can_network_connect 1
```

## Verification

After setup, verify all services are accessible:

```bash
# Frontend
curl -I http://edubad.zut.edu.pl/

# Node-RED
curl -I http://edubad.zut.edu.pl/nodered/

# InfluxDB
curl -I http://edubad.zut.edu.pl/influxdb/

# Grafana
curl -I http://edubad.zut.edu.pl/grafana/

# API
curl -I http://edubad.zut.edu.pl/api/health
```

All should return `200 OK` or `302 Found` (redirect) status codes.

