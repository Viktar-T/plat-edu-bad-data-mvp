# 🧪 Step 5 – Validation, Testing, and Troubleshooting

Goal: Validate end-to-end data flow and resolve common issues. Include performance sanity checks and evidence collection.

Mikrus specifics:
- Web via Nginx path-based routing on `20108`
- MQTT on `1883/tcp` (exposed directly)
- **Current VPS**: robert108.mikrus.xyz

---

## Step 1 – MQTT publish/subscribe

From your local machine (ports must be open on VPS firewall):

```bash
# Subscribe (using your VPS details)
mosquitto_sub -h robert108.mikrus.xyz -p 1883 -u admin -P admin_password_456 -t devices/# -v

# In another shell, publish a test message
mosquitto_pub -h robert108.mikrus.xyz -p 1883 -u admin -P admin_password_456 -t devices/test/health -m '{"ok":true,"ts":"2024-01-01T00:00:00Z"}'
```

Expected: Subscriber prints the published JSON.

**Note**: Your VPS uses port `1883` for MQTT (not `40098` as originally planned).

---

## Step 2 – Node-RED flow check

Open `http://robert108.mikrus.xyz:20108/nodered` and confirm:
- Flows are deployed
- MQTT input nodes are connected
- Debug nodes print incoming messages
- Login with: `admin` / `adminpassword`

---

## Step 3 – InfluxDB write/read

Example write via HTTP API (from VPS):

```bash
curl -i -X POST "http://localhost:8086/api/v2/write?org=<ORG>&bucket=<BUCKET>&precision=ns" \
  --header "Authorization: Token <INFLUXDB_TOKEN>" \
  --data-binary "test_measurement,device_id=test value=1i"
```

Expected: `HTTP/1.1 204 No Content`.

Query (Flux):

```bash
curl -s -G "http://localhost:8086/api/v2/query?org=<ORG>" \
  --header "Authorization: Token <INFLUXDB_TOKEN>" \
  --header "Accept: application/csv" \
  --data-urlencode 'query=from(bucket:"<BUCKET>") |> range(start: -15m) |> filter(fn:(r)=> r._measurement == "test_measurement")' | sed -n '1,80p'
```

Expected: CSV rows containing `test_measurement`.

---

## Step 4 – Grafana dashboards

Open `http://robert108.mikrus.xyz:20108/grafana` and verify:
- InfluxDB datasource is healthy
- Core dashboards load without errors
- Panels show recent data (e.g., last 15m)
- Login with: `admin` / `admin`

---

## Step 5 – Performance sanity checks

```bash
htop | sed -n '1,40p'
df -h | sed -n '1,80p'
free -h | sed -n '1,80p'
docker stats --no-stream | sed -n '1,120p'
```

Expected: CPU/memory within VPS limits, sufficient disk space, container usage reasonable.

---

## Step 6 – Common problems and fixes

### Deployment Issues (Path A - PowerShell)

**Docker Compose Not Found:**
```bash
# Error: docker: 'compose' is not a docker command
# Solution: The deployment script now automatically installs Docker Compose
# If manual installation needed:
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

**Permission Issues (Grafana/Node-RED restarting):**
```bash
# Error: Permission denied on /var/lib/grafana/plugins
# Solution: Fix data directory permissions
sudo chown -R 472:472 grafana/data
sudo chown -R 1000:1000 node-red/data
```

**Nginx Container Name Mismatch:**
```bash
# Error: 404 Not Found when accessing /grafana/
# Solution: Update nginx/nginx.conf upstream definitions
# Change container names:
# grafana:3000 → iot-grafana:3000
# node-red:1880 → iot-node-red:1880
# influxdb:8086 → iot-influxdb2:8086
```

**SSL Configuration Issues:**
```bash
# Error: nginx: [emerg] no "ssl_certificate" is defined
# Solution: Comment out HTTPS server block in nginx/nginx.conf
# Until SSL certificates are configured
```

**Docker Compose YAML Errors:**
```bash
# Error: The Compose file './docker-compose.yml' is invalid
# Solution: Fix indentation and comment out HTTPS port mapping
# Ensure nginx service is properly indented
```

### General Issues

- **Ports blocked**: verify UFW allows `10108`, `20108`, `30108`, `1883`
- **Containers restarting**: inspect logs and healthchecks, fix config typos
- **Permission denied on volumes**: ensure correct ownership/paths
- **DNS/resolution issues**: test `nslookup`/`ping` from VPS

---

## Step 7 – Evidence collection when opening an issue

```bash
docker-compose ps | cat
docker-compose logs --tail=200 | sed -n '1,200p'
```
sudo journalctl -xe | sed -n '1,120p'
```

Attach outputs, describe steps to reproduce, include commit SHA.

---

## 🧩 Use in Cursor (prompt)
```text
Run end-to-end checks: MQTT pub/sub, Node-RED MQTT nodes connected, InfluxDB write/read returns success, Grafana dashboards load. If any step fails, capture logs and propose a minimal fix.
```


