# 🚀 Step 3 – Deployment and Operations

Goal: Start the stack, verify status and health, view logs, and run basic sanity checks. Covers both manual and CI/CD flows.

Mikrus specifics:
- Access via `http://<HOST>:20108/...` with Nginx path-based routing
- MQTT on `40098/tcp`

---

## Step 1 – Start services

```bash
cd ~/plat-edu-bad-data-mvp

# Pull images and start in detached mode
docker compose pull
docker compose up -d
```

Expected result: Containers are created and started without errors.

---

## Step 2 – Check status and health

```bash
docker compose ps | cat
```

Look for `Up` or `healthy` (if healthchecks are present). If any container is `Restarting` or `Exited`, inspect its logs:

```bash
docker compose logs <service_name> --tail=200 | sed -n '1,200p'
```

Common services: `mosquitto`, `nodered`, `influxdb`, `grafana`, `nginx`.

---

## Step 3 – View and tail logs

```bash
# All logs
docker compose logs --tail=100 | sed -n '1,200p'

# Tail specific service
docker compose logs -f grafana | sed -n '1,200p'
```

Stop tailing with Ctrl+C.

---

## Step 4 – Enable auto-start on reboot

Docker Compose services with `restart: unless-stopped` will come back automatically when the Docker daemon starts. Ensure Docker is enabled:

```bash
sudo systemctl enable docker
sudo systemctl is-enabled docker
```

Expected output:
```
enabled
enabled
```

---

## Step 5 – Sanity checks (web paths and MQTT)

Web UI (replace `<HOST>`):
- Grafana: `http://<HOST>:20108/grafana`
- Node-RED: `http://<HOST>:20108/nodered`
- InfluxDB: `http://<HOST>:20108/influxdb`

MQTT port reachability from VPS:

```bash
nc -vz <HOST> 40098 || telnet <HOST> 40098 || true
```

Expected: A successful connection message from `nc` or `telnet`.

---

## Step 6 – Operate via CI/CD

If using the GitHub Actions workflow from Step 2, confirm from the Actions run logs that:
- `git pull` succeeded
- `docker compose up -d` ran without errors
- `docker compose ps` shows services running

Rollback approach:
- Revert to a previous commit locally and push
- or SSH to VPS, run `git checkout <previous_sha>` then `docker compose up -d`

---

## Troubleshooting quick tips
- `docker compose ps` shows Restarting: check per-service logs and healthcheck definitions
- Port in use errors: verify Nginx and MQTT ports, confirm UFW rules from Step 1
- Permission issues on volumes: confirm directory ownership for bind mounts

---

## 🧩 Use in Cursor (prompt)
```text
Verify that all services are Up/healthy on the VPS. If any container is Restarting or Exited, fetch its last 200 log lines and propose a fix with concrete steps.
```


