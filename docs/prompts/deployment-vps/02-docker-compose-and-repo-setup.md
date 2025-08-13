# 🧩 Step 2 – Docker Compose and Repository Setup

Goal: Choose your deployment approach and set up the application on the VPS.

Mikrus specifics:
- Web: `20108` (HTTP) and `30108` (HTTPS future) via Nginx path-based routing (`/grafana`, `/nodered`, `/influxdb`)
- MQTT: `40098/tcp`
- Services: Mosquitto, Node-RED, InfluxDB 2.x, Grafana, Nginx (Express/React not deployed now)

---

## 📊 Deployment Paths Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CHOOSE DEPLOYMENT PATH                            │
└─────────────────────────────────────────────────────────────────────────────┘
                    │                               │
                    ▼                               ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │     PATH A              │    │     PATH B              │
    │  PowerShell Script      │    │   Direct Git            │
    │  (No VPS setup needed)  │    │  (Requires VPS setup)   │
    └─────────────────────────┘    └─────────────────────────┘
                    │                               │
                    ▼                               ▼
    ┌─────────────────────────┐    ┌─────────────────────────┐
    │ 1. Run locally:         │    │ 1. Clone repo on VPS:   │
    │    ./deploy-production.ps1   │    git clone ...         │
    │    -Prepare             │    │                        │
    │                        │    │ 2. Set permissions:     │
    │ 2. Transfer files:      │    │    sudo chown -R ...    │
    │    ./deploy-production.ps1   │                        │
    │    -Transfer            │    │ 3. Start services:     │
    │                        │    │    docker compose up -d │
    │ 3. Deploy on VPS:       │    │                        │
    │    ./deploy-production.ps1   │ Location:               │
    │    -Deploy              │    │ /home/viktar/plat-edu-bad-data-mvp │
    │                        │    │                        │
    │ Location:               │    │ Updates:               │
    │ /root/renewable-energy-iot   │ git pull --ff-only      │
    │                        │    │                        │
    │ Updates:                │    │                        │
    │ Re-run PowerShell script│    │                        │
    └─────────────────────────┘    └─────────────────────────┘
```

**Key Differences:**
- **Path A**: No VPS setup required, PowerShell handles everything from your local machine
- **Path B**: Requires VPS setup (clone repo, set permissions), then direct Docker commands

---

## Path A: PowerShell-Driven Deployment (Recommended for Beginners)

**✅ No VPS setup required** - PowerShell script handles everything from your local Windows machine.

### Step 1: Prepare and Deploy

Run locally on Windows from project root:

```powershell
# Prepare production bundle (includes env handling)
# - Validates required files exist (docker-compose.yml, nginx/, mosquitto/, etc.)
# - Creates .env.production from env.example if missing
# - Checks file permissions and structure
./scripts/deploy-production.ps1 -Prepare

# Transfer files to VPS
# - Creates remote directories on VPS (/root/renewable-energy-iot/...)
# - Transfers docker-compose.yml, service configs, and .env.production
# - Uses SCP to copy files directly to VPS
./scripts/deploy-production.ps1 -Transfer -VpsUser root -VpsHost robert108.mikrus.xyz -VpsPort 10108

# Deploy on VPS
# - Connects to VPS via SSH
# - Runs: docker compose pull && docker compose up -d && docker compose ps
# - Shows container status after deployment
./scripts/deploy-production.ps1 -Deploy -VpsUser root -VpsHost robert108.mikrus.xyz -VpsPort 10108

# OR Deploy end-to-end (all steps combined)
./scripts/deploy-production.ps1 -Full
```

### Step 2: Verify Deployment

```bash
# SSH as root to check deployment
ssh root@robert108.mikrus.xyz -p10108
cd /root/renewable-energy-iot
docker compose ps | cat
```

**Location**: `/root/renewable-energy-iot` (separate deployment directory)
**Updates**: Re-run PowerShell script from your local machine

---

## Path B: Direct Git Deployment (Advanced)

**⚠️ Requires VPS setup** - Clone repository on VPS and manage directly.

### Step 1: Clone Repository on VPS

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

### Step 2: Set Permissions

```bash
# Ensure your user (e.g., viktar) owns the repo directory
sudo chown -R $USER:$USER ~/plat-edu-bad-data-mvp
```

### Step 3: Verify Docker Compose Configuration

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

### Step 4: Start Services

```bash
cd ~/plat-edu-bad-data-mvp

# Start services
docker compose up -d
```

### Step 5: Verify Deployment

```bash
# SSH as viktar to check deployment
ssh viktar@robert108.mikrus.xyz -p10108
cd ~/plat-edu-bad-data-mvp
docker compose ps | cat
```

**Location**: `/home/viktar/plat-edu-bad-data-mvp` (Git repository directly)
**Updates**: `git pull --ff-only` then `docker compose up -d`

---

## Environment Files (Both Paths)

**📝 Information Only - No Manual Setup Required**

- **Path A**: PowerShell script manages `.env.production` automatically
- **Path B**: No `.env` file needed on VPS (uses defaults from docker-compose.yml)

**Validation**: You can verify this by checking that no `.env` file exists on the VPS:

```bash
# Check for any .env files (should not exist on VPS)
ls -la | grep "\.env" || echo "No .env files found (correct)"
```

Expected output: `No .env files found (correct)`

---

## Path Comparison Summary

| Aspect | Path A (PowerShell) | Path B (Direct Git) |
|--------|-------------------|-------------------|
| **VPS Setup Required** | ❌ No | ✅ Yes (clone, permissions) |
| **Local Machine Required** | ✅ Yes (Windows + PowerShell) | ❌ No |
| **Deployment Location** | `/root/renewable-energy-iot` | `/home/viktar/plat-edu-bad-data-mvp` |
| **Updates** | Re-run PowerShell script | `git pull --ff-only` |
| **Complexity** | 🟢 Beginner-friendly | 🟡 Requires VPS knowledge |
| **Automation** | 🟢 Fully automated | 🟡 Manual steps |

**Recommendation**: Use **Path A** if you're new to VPS deployment, **Path B** if you prefer direct control.

---

## CI/CD Pipeline (GitHub Actions)

Example workflow for Path B (Direct Git):

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

---

## ✅ Validation (Both Paths)

```bash
# Check container status
docker compose ps | cat

# Check recent logs
docker compose logs --tail=50 | sed -n '1,120p'
```

You should see healthy/starting states and recent logs for all services.

---

## 🧩 Use in Cursor (prompt)
```text
Using the repo at ~/plat-edu-bad-data-mvp on the VPS, verify that docker-compose.yml contains only Mosquitto, Node-RED, InfluxDB 2.x, Grafana, and Nginx. Ensure volumes, restart policies, and healthchecks exist. If issues are found, propose exact edits.
```


