## Step 2 - Docker Compose and Repo Setup

Goal: prepare application files on the VPS for deployment using Docker Compose and Nginx path-based routing.

### 2.1 Recommended: use the deployment script (Windows PowerShell)

```powershell
./scripts/deploy-production.ps1 -Full
```

This packages the deployment folder, transfers it to the VPS, and runs the remote deploy script.

### 2.2 Manual alternative (on VPS)

```bash
ssh viktar@<HOST> -p 10108
mkdir -p ~/renewable-energy-iot && cd ~/renewable-energy-iot
git clone https://github.com/Viktar-T/plat-edu-bad-data-mvp.git repo
cd repo
mkdir -p ~/deployment && cd ~/deployment
cp ~/renewable-energy-iot/repo/docker-compose.yml .
cp ~/renewable-energy-iot/repo/nginx/nginx.conf ./nginx.conf -v
cp ~/renewable-energy-iot/repo/.env.production .env
```

Expected:
- `~/deployment` contains docker-compose.yml, nginx.conf, and .env

### 2.3 Verify compose and env

```bash
docker-compose -f docker-compose.yml config | head -n 120 | cat
docker-compose -f docker-compose.yml pull --ignore-pull-failures
test -f .env && echo OK: .env present || echo Missing: .env
```

Key points:
- Services: Mosquitto, Node-RED, InfluxDB 2.x, Grafana, Nginx reverse proxy
- Nginx publishes 20108:80 and 30108:443
- Only Nginx has public ports; backends are routed by path: /grafana, /nodered, /influxdb
- MQTT uses Mikrus TCP port 40098
- Express/React are not deployed in production

### 2.4 Volumes and persistence

```bash
ls -la ./influxdb ./grafana ./node-red ./mosquitto | cat || true
```

Ensure directories are writable and mapped to volumes in compose.

### 2.5 Nginx path routes

Confirm nginx.conf has routes for /grafana, /nodered, /influxdb and default redirect / -> /grafana/.

---

### Use in Cursor - audit compose and env

```markdown
Ask Cursor to:
- Open docker-compose.yml and verify:
  - Nginx publishes 20108:80 and 30108:443
  - No public ports on Grafana, Node-RED, InfluxDB (use expose only)
  - Mosquitto publishes 40098:1883
- Confirm Express/React services are absent in production
- Check .env.production exists and contains non-secret placeholders only
```


