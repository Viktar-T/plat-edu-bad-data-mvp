## Step 2 – Docker Compose and Repo Setup

This step prepares the application repository on the VPS, creates the `.env` file with safe defaults, and validates the Compose configuration.

## Step 1 – Clone the repository (VPS)

```bash
cd /opt || cd ~
git clone https://github.com/<ORG>/plat-edu-bad-data-mvp.git
cd plat-edu-bad-data-mvp
```
Expected: Repository present under your chosen directory.

## Step 2 – Create `.env` from example (VPS)

```bash
cp -n env.example .env
# Set safe defaults (edit as needed). Use envsubst-like inline edits:
sed -i 's/^ORG=.*/ORG=<ORG>/' .env
sed -i 's/^INFLUXDB_ORG=.*/INFLUXDB_ORG=<ORG>/' .env
sed -i 's/^INFLUXDB_BUCKET=.*/INFLUXDB_BUCKET=<BUCKET>/' .env
sed -i 's/^GRAFANA_ADMIN_PASSWORD=.*/GRAFANA_ADMIN_PASSWORD=<GRAFANA_ADMIN_PASSWORD>/' .env
# Never commit .env with secrets.
```
Expected: `.env` exists with placeholders you control. Keep tokens/passwords private.

## Step 3 – Verify docker-compose.yml basics (VPS)

```bash
# Show services/ports quickly
awk '/services:/,0 {print}' docker-compose.yml | sed -n '1,200p' | sed -n '1,200p'
# Check for healthchecks and restart policies
grep -nE "healthcheck:|restart:" -n docker-compose.yml || true
```
Expected: Services for Mosquitto (1883), Node-RED (1880), InfluxDB (8086), Grafana (3000) with restart policies; healthchecks present where applicable.

## Step 4 – Ensure data directories exist (VPS)

```bash
mkdir -p grafana/data influxdb/data mosquitto/data mosquitto/log node-red/data grafana/provisioning grafana/dashboards
sudo chown -R $USER:$USER grafana influxdb mosquitto node-red || true
```
Expected: Local bind-mount targets exist and are writable by your user.

## Step 5 – Optional: pre-pull images (VPS)

```bash
docker compose pull --ignore-pull-failures || true
```
Expected: Images pulled if available; failures can be ignored until deploy.

### Use in Cursor – Generate .env safely
```
Goal: From env.example, generate .env with safe defaults for Mikrus.
- Read env.example and propose values for ORG, INFLUXDB_ORG, INFLUXDB_BUCKET, and other placeholders.
- Output a ready-to-paste sed command block to set them.
- Do not include real secrets; use placeholders and explain where to replace.
```

### Use in Cursor – Compose audit
```
Audit docker-compose.yml for:
- Ports: 1883, 1880, 8086, 3000
- Volumes mapped to local directories
- restart: unless-stopped (or better) and healthcheck sections
Return a short risk report with recommended defaults for Mikrus 3.0.
``` 