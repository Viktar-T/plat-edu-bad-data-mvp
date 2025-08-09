## Step 3 – Deployment and Operations

This step deploys the stack with Docker Compose, checks health, and shows how to operate the services.

## Step 1 – Start the stack (VPS)

```bash
cd ~/plat-edu-bad-data-mvp
# Pull and start
docker compose pull
docker compose up -d
```
Expected: Containers created and started in the background.

## Step 2 – Check status and health (VPS)

```bash
docker compose ps
# Optional: inspect health for a specific service
SERVICE=grafana
CONTAINER_ID=$(docker compose ps -q "$SERVICE")
[ -n "$CONTAINER_ID" ] && docker inspect --format='{{.Name}} => {{.State.Status}} / Health={{if .State.Health}}{{.State.Health.Status}}{{else}}n/a{{end}}' $CONTAINER_ID || true
```
Expected: Each service `running`; health `healthy` where healthchecks exist.

## Step 3 – View logs (VPS)

```bash
# All services (last 200 lines)
docker compose logs --tail=200
# Follow a single service
docker compose logs -f grafana
```
Expected: No repeating crash loops; Grafana/InfluxDB ready messages visible.

## Step 4 – Auto-restart on reboot

Ensure each service has `restart: unless-stopped` (or similar) in `docker-compose.yml`. If missing, add it and recreate the service.

```bash
# Example recreate after compose change
docker compose up -d --force-recreate
```

## Step 5 – Endpoint sanity checks (VPS)

```bash
# InfluxDB
curl -sS http://localhost:8086/health | jq . || curl -sS http://localhost:8086/health
# Grafana (expects 200/302)
curl -I http://localhost:3000 | head -n 1
# Node-RED
curl -I http://localhost:1880 | head -n 1
# Mosquitto – install client and quick test
sudo apt-get install -y mosquitto-clients
# Subscribe in background, publish once
timeout 3s mosquitto_sub -h localhost -t test/topic & sleep 1; mosquitto_pub -h localhost -t test/topic -m "hello"
```
Expected: Influx health reports `pass`; Grafana/Node-RED return HTTP 200/302; MQTT message received by subscriber.

## Step 6 – Operations basics

```bash
# Stop/Start/Restart
docker compose stop
docker compose start
docker compose restart
# Remove (data persists due to volumes)
docker compose down
```

### Use in Cursor – Stream logs and checklist
```
Task: Generate an operations checklist.
- Tail logs for all services and capture health signals.
- Summarize status of each service (running/health).
- Output next actions if a service is unhealthy (ports, volumes, env, tokens).
``` 