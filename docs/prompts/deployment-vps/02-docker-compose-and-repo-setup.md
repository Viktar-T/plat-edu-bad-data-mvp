# 🧩 Step 2 – Docker Compose and Repository Setup

Goal: Prepare the application on the VPS, ensure Docker Compose configuration is correct, and choose a deployment track (Manual or CI/CD).

Mikrus specifics:
- Web: `20108` (HTTP) and `30108` (HTTPS future) via Nginx path-based routing (`/grafana`, `/nodered`, `/influxdb`)
- MQTT: `40098/tcp`
- Services: Mosquitto, Node-RED, InfluxDB 2.x, Grafana, Nginx (Express/React not deployed now)

---

## Step 1 – Clone the repository on the VPS (recommended)

```bash
# From your home directory on the VPS
cd ~

# Clone the repository
git clone https://github.com/Viktar-T/plat-edu-bad-data-mvp.git

cd plat-edu-bad-data-mvp

# Verify expected files are present
ls -la
```

Expected output (abridged):
```
docker-compose.yml
influxdb/
mosquitto/
node-red/
grafana/
scripts/
```

Why: This places the project under your user, making updates via `git pull` easy.

---

## Step 2 – Set permissions (if needed)

```bash
# Ensure your user (e.g., viktar) owns the repo directory
sudo chown -R $USER:$USER ~/plat-edu-bad-data-mvp
```

Expected result: No output on success. Ownership updated.

---

## Step 3 – Environment files are handled by scripts (no manual .env on VPS)

**📝 Information Only - No Commands to Run**

- Local development: `scripts/dev-local.ps1` creates `.env.local` and materializes `.env`.
- Production: `scripts/deploy-production.ps1` uses `.env.production` during packaging/deploy.

**Important**: Do not manually create `.env` on the VPS unless you know you must diverge. The scripts manage consistent variables and safe defaults.

**Validation**: You can verify this by checking that no `.env` file exists on the VPS:

```bash
# Check for any .env files (should not exist on VPS)
ls -la | grep "\.env" || echo "No .env files found (correct)"
```

Expected output: `No .env files found (correct)`

---

## Step 4 – Verify Docker Compose configuration

```bash
# Validate and render the compose file for review
docker compose config | sed -n '1,120p'
```

Check for:
- Only required services: Mosquitto, Node-RED, InfluxDB 2.x, Grafana, Nginx
- Named volumes for persistence
- `restart: unless-stopped`
- Healthchecks where applicable
- Networks: single shared network is fine for MVP

Tip: Express/React services should not be present for production yet.

---

## Step 5 – Deployment Tracks

### A) Manual Deployment (PowerShell driven)

Run locally on Windows from project root:

```powershell
# Prepare production bundle (includes env handling)
./scripts/deploy-production.ps1 -Prepare

# Deploy end-to-end to VPS
./scripts/deploy-production.ps1 -Full
```

Expected result:
- Bundle built locally and transferred to the VPS
- On VPS: `docker compose up -d` executed
- Services accessible via Nginx path routes

Verify on VPS:

```bash
cd ~/plat-edu-bad-data-mvp
docker compose ps | cat
```

### B) Alternate: Direct Git on VPS

```bash
cd ~/plat-edu-bad-data-mvp

# Pull latest changes when updating
git pull --ff-only

# Start services
docker compose up -d
```

Expected result: Containers start and remain healthy.

---

## Step 6 – CI/CD Pipeline (GitHub Actions)

Example workflow to SSH into the VPS, pull changes, and (re)start services.

```yaml
name: Deploy to Mikrus VPS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Deploy
        run: |
          ssh -o StrictHostKeyChecking=no -p 10108 viktar@${{ secrets.VPS_HOST }} "\
            set -e; \
            cd ~/plat-edu-bad-data-mvp; \
            git pull --ff-only; \
            docker compose pull; \
            docker compose up -d; \
            docker compose ps \
          "
```

Required repository secrets:
- `VPS_HOST` – example: `robert108.mikrus.xyz`
- `VPS_SSH_KEY` – private key for user (e.g., viktar)

Notes:
- Do not store plaintext passwords/tokens in workflows
- Prefer image pull + restart; pin images by tag or digest for reproducibility

---

## ✅ Validation

```bash
# On the VPS
docker compose ps | cat
docker compose logs --tail=50 | sed -n '1,120p'
```

You should see healthy/starting states and recent logs for all services.

---

## 🧩 Use in Cursor (prompt)
```text
Using the repo at ~/plat-edu-bad-data-mvp on the VPS, verify that docker-compose.yml contains only Mosquitto, Node-RED, InfluxDB 2.x, Grafana, and Nginx. Ensure volumes, restart policies, and healthchecks exist. If issues are found, propose exact edits.
```


