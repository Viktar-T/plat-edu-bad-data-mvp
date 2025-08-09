## Step 5 – Validation, Testing, and Troubleshooting

Verify that MQTT → Node-RED → InfluxDB → Grafana works end-to-end, then use this section to troubleshoot typical issues.

## Step 1 – MQTT publish/subscribe test (VPS)

```bash
sudo apt-get install -y mosquitto-clients
# Subscribe in background for 5s
TOPIC=test/validation
timeout 5s mosquitto_sub -h localhost -t "$TOPIC" &
sleep 1
mosquitto_pub -h localhost -t "$TOPIC" -m "hello-from-vps"
```
Expected: Subscriber prints `hello-from-vps`.

## Step 2 – Node-RED flow status

- Visit Node-RED at `http://<MIKRUS_HOST>:1880`.
- Confirm flows are deployed and running; verify that any simulation flows produce MQTT messages as expected.

## Step 3 – InfluxDB health and query

```bash
# Health check
curl -sS http://localhost:8086/health | jq . || curl -sS http://localhost:8086/health

# Example Flux query via HTTP API (adjust org/bucket/token)
cat << 'EOF' > /tmp/query.flux
from(bucket: "<BUCKET>")
  |> range(start: -15m)
  |> filter(fn: (r) => r["_measurement"] == "photovoltaic_data")
  |> limit(n: 5)
EOF
curl -sS -X POST "http://localhost:8086/api/v2/query?org=<ORG>" \
  -H "Authorization: Token <INFLUXDB_TOKEN>" \
  -H "Accept: application/csv" \
  -H "Content-type: application/vnd.flux" \
  --data-binary @/tmp/query.flux | head -n 20
```
Expected: CSV rows returned with recent data (if data exists).

## Step 4 – Grafana access

- Visit Grafana at `http://<MIKRUS_HOST>:3000`.
- Login as admin and verify dashboards are present under the provisioned folder.
- If dashboards are empty, verify Grafana provisioning and InfluxDB datasource.

## Step 5 – Common issues and fixes

- Ports in use: `sudo lsof -i -P -n | grep LISTEN` then change ports or stop conflicting services.
- File permissions: ensure repo directories are owned by your user: `sudo chown -R $USER:$USER .`.
- Missing volumes: create directories under `influxdb/`, `grafana/`, `node-red/`, `mosquitto/`.
- Healthcheck failures: `docker compose logs <service>`; check env vars and connection URLs.
- Tokens and passwords: ensure `.env` values exist and Compose loads them.
- Network issues: confirm UFW rules; check that services bind to expected interfaces.

## Step 6 – Light performance checks

```bash
# CPU/mem/IO of containers
docker stats --no-stream
# MQTT pub flood test (adjust rate)
for i in $(seq 1 100); do mosquitto_pub -h localhost -t load/test -m "msg-$i"; done
```
Expected: System handles moderate load without errors. If not, check logs and resource limits.

### Use in Cursor – Test data and audit
```
Generate:
- MQTT payloads for photovoltaic and wind topics with realistic fields
- A Flux query to validate writes for the last 15 minutes per measurement
- A short config audit: ports, volumes, restart policies, and healthchecks
Return a concise PASS/FAIL with next steps.
``` 