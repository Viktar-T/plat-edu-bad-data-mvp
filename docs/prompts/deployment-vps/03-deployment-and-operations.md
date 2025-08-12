## Step 3 - Deployment and Operations

Goal: deploy, operate, and validate the stack on Mikrus VPS.

### 3.1 Start services (on VPS)

```bash
cd ~/deployment
docker-compose up -d
docker-compose ps
```

### 3.2 Logs and health

```bash
docker-compose logs --tail 200 | cat
docker-compose logs -f nginx | cat
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Healthy signals:
- Grafana: HTTP 200 on /grafana/
- Node-RED: UI loads at /nodered/
- InfluxDB: UI loads at /influxdb/, API responds
- Mosquitto: accepts TCP connections on 40098

### 3.3 Access via Nginx paths

```
http://<HOST>:20108/grafana
http://<HOST>:20108/nodered
http://<HOST>:20108/influxdb
```

Default / redirects to /grafana/.

### 3.4 Lifecycle

```bash
docker-compose restart
docker-compose down
docker-compose pull && docker-compose up -d
```

### 3.5 Auto-start

Ensure each service has `restart: unless-stopped` in compose.

---

### Use in Cursor - quick ops checklist

```markdown
Ask Cursor to:
- Check docker-compose.yml for restart policies on all services
- Generate a one-page runbook: start, stop, restart, logs, upgrade
- Stream `docker-compose logs -f nginx` and summarize any 4xx/5xx in last 200 lines
```


