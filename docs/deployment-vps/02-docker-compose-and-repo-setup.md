# 🧩 Step 2 – Docker Compose and Repository Setup

Goal: Choose your deployment approach and set up the application on the VPS.

Mikrus specifics:
- **Direct Port Access**: Each service runs on its own dedicated port (no nginx required)
- **MQTT**: Port 40098 (exposed directly)
- **Grafana**: Port 40099 (exposed directly)
- **Node-RED**: Port 40100 (exposed directly)
- **InfluxDB**: Port 40101 (exposed directly)
- **Current VPS**: robert108.mikrus.xyz
- **Services**: Mosquitto, Node-RED, InfluxDB 2.x, Grafana (Express/React not deployed now)

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
    │   (works well)          │    │   (✅ IMPLEMENTED)      │
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
    │                        │    │    docker-compose up -d │
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
# - Validates required files exist (docker-compose.yml, mosquitto/, influxdb/, etc.)
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
# - Runs: docker-compose pull && docker-compose up -d && docker-compose ps
# - Shows container status after deployment
./scripts/deploy-production.ps1 -Deploy -VpsUser root -VpsHost robert108.mikrus.xyz -VpsPort 10108

# OR Deploy end-to-end (all steps combined)
./scripts/deploy-production.ps1 -Full
```

### ✅ Current VPS Status (robert108.mikrus.xyz)

**Successfully Deployed Services:**
- ✅ **InfluxDB**: Running and healthy (port 40101 external)
- ✅ **Mosquitto**: Running and healthy (port 40098 external)
- ✅ **Node-RED**: Running and healthy (port 40100 external)
- ✅ **Grafana**: Running and healthy (port 40099 external)

**Access URLs (Direct Port Access):**
- **Grafana Dashboard**: `http://robert108.mikrus.xyz:40099`
- **Node-RED Editor**: `http://robert108.mikrus.xyz:40100`
- **InfluxDB Admin**: `http://robert108.mikrus.xyz:40101`
- **MQTT Broker**: `robert108.mikrus.xyz:40098`

**Default Credentials:**
- **Grafana**: `admin` / `admin`
- **Node-RED**: `admin` / `adminpassword`
- **InfluxDB**: `admin` / `admin_password_123`
- **MQTT**: `admin` / `admin_password_456`

### 🚨 Issues Encountered and Resolved

**1. Docker Compose Command Differences**
- **Issue**: `docker: 'compose' is not a docker command` (newer Docker versions)
- **Solution**: Use `docker-compose` (legacy) instead of `docker compose` (newer)
- **Fix**: Updated documentation to use `docker-compose` consistently
- **Note**: Some systems have `docker-compose` (legacy), others have `docker compose` (newer)

**2. Permission Issues with Grafana and Node-RED**
- **Issue**: Services restarting due to permission denied errors
- **Solution**: Fixed data directory permissions
- **Fix**: 
  ```bash
  sudo chown -R 472:472 grafana/data
  sudo chown -R 1000:1000 node-red/data
  ```

**3. Nginx Container Name Mismatch**
- **Issue**: Nginx couldn't reach services due to wrong container names in configuration
- **Solution**: Updated Nginx upstream definitions
- **Fix**: Changed container names in `nginx/nginx.conf`:
  - `grafana:3000` → `iot-grafana:3000`
  - `node-red:1880` → `iot-node-red:1880`
  - `influxdb:8086` → `iot-influxdb2:8086`

**4. SSL Configuration Issues**
- **Issue**: Nginx failing due to SSL certificate configuration
- **Solution**: Temporarily disabled HTTPS server block
- **Fix**: Commented out HTTPS configuration until SSL certificates are configured

**5. Docker Compose YAML Syntax Errors**
- **Issue**: Invalid YAML due to indentation problems
- **Solution**: Fixed indentation in docker-compose.yml
- **Fix**: Corrected nginx service indentation and commented out HTTPS port mapping

### Step 2: Verify Deployment

```bash
# SSH as root to check deployment
ssh root@robert108.mikrus.xyz -p10108
cd /root/renewable-energy-iot
sudo docker-compose ps | cat
```

**Location**: `/root/renewable-energy-iot` (separate deployment directory)
**Updates**: Re-run PowerShell script from your local machine

---

## Path B: Direct Git Deployment (Advanced) ✅ IMPLEMENTED

**✅ Successfully implemented** - Repository cloned and services deployed on VPS.

### ✅ Current Implementation Status

**Repository Location**: `/home/viktar/plat-edu-bad-data-mvp`
**User**: `viktar`
**Status**: ✅ Repository cloned successfully
**Next Step**: Start services

### Step 1: Clone Repository on VPS ✅ COMPLETED

```bash
# From your home directory on the VPS
cd ~

# Clone the repository
git clone https://github.com/Viktar-T/plat-edu-bad-data-mvp.git

cd plat-edu-bad-data-mvp

# Verify expected files are present
ls -la
tree -ah -L 2
```

**✅ Expected output (verified):**
```
docker-compose.yml
influxdb/
mosquitto/
node-red/
grafana/
scripts/
docs/
tests/
web-app-for-testing/
```

### Step 2: Set Permissions ✅ COMPLETED

```bash
# Ensure your user (e.g., viktar) owns the repo directory
sudo chown -R $USER:$USER ~/plat-edu-bad-data-mvp
```

### Step 3: Verify Docker Compose Configuration

```bash
# Check Docker version and available commands
sudo docker -v
sudo docker-compose -v

# Validate and render the compose file for review
sudo docker-compose config
```

**Important Note**: Use `docker-compose` (legacy) instead of `docker compose` (newer) based on your system. All Docker commands require `sudo` on this VPS setup.

Check for:
- ✅ Only required services: Mosquitto, Node-RED, InfluxDB 2.x, Grafana
- ✅ Named volumes for persistence
- ✅ `restart: unless-stopped`
- ✅ Healthchecks where applicable
- ✅ Networks: single shared network is fine for MVP

### Step 4: Start Services

```bash
cd ~/plat-edu-bad-data-mvp

# Check available disk space first
df -h

# Check Docker disk usage
sudo docker system df

# Start services
sudo docker-compose up -d

# Monitor startup process
sudo docker-compose logs -f
```

### Step 5: Verify Deployment

```bash
# Check container status
sudo docker-compose ps

# Check individual service logs
sudo docker-compose logs mosquitto --tail=10
sudo docker-compose logs influxdb --tail=10
sudo docker-compose logs node-red --tail=10
sudo docker-compose logs grafana --tail=10
```

**Expected Services:**
- **iot-mosquitto** (MQTT broker) - port 40098
- **iot-influxdb2** (InfluxDB 2.x) - port 40101
- **iot-node-red** (Node-RED) - port 40100
- **iot-grafana** (Grafana) - port 40099

### Step 6: Access Your Services

Once services are running, access at:

- **Grafana Dashboard**: `http://robert108.mikrus.xyz:40099`
  - Username: `admin`
  - Password: `admin`

- **Node-RED Editor**: `http://robert108.mikrus.xyz:40100`
  - Username: `admin`
  - Password: `adminpassword`

- **InfluxDB Admin**: `http://robert108.mikrus.xyz:40101`
  - Username: `admin`
  - Password: `admin_password_123`

- **MQTT Broker**: `robert108.mikrus.xyz:40098`

### Step 7: Future Updates

```bash
# Navigate to your project directory
cd ~/plat-edu-bad-data-mvp

# Pull latest changes
git pull --ff-only

# Restart services with new configuration
sudo docker-compose up -d

# Check status
sudo docker-compose ps
```

### 🚨 Troubleshooting Commands

```bash
# Check if Docker is running
sudo systemctl status docker

# Check available disk space
df -h

# Check Docker disk usage
sudo docker system df

# View detailed logs for a specific service
sudo docker-compose logs -f [service-name]

# Restart a specific service
sudo docker-compose restart [service-name]

# Stop all services
sudo docker-compose down

# Stop and remove volumes (⚠️ will delete data)
sudo docker-compose down -v

# Check for port conflicts
sudo netstat -tlnp | grep -E "(40098|40099|40100|40101)"
```

### 🔧 Docker Permission Issues

**Issue**: `permission denied while trying to connect to the Docker daemon socket`

**Solution 1: Add user to docker group (Recommended)**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and back in, or run this command to apply changes
newgrp docker

# Verify you can run Docker without sudo
docker ps
```

**Note**: For this VPS setup, we're using `sudo` with all Docker commands for simplicity.

**Solution 2: Use sudo (Current Setup)**
```bash
# Run Docker commands with sudo
sudo docker system df
sudo docker-compose up -d
sudo docker-compose ps
```

**Solution 3: Fix Docker daemon permissions**
```bash
# Check Docker daemon status
sudo systemctl status docker

# Restart Docker daemon if needed
sudo systemctl restart docker

# Check if user is in docker group
groups $USER
```

**Location**: `/home/viktar/plat-edu-bad-data-mvp` (Git repository directly)
**Updates**: `git pull --ff-only` then `docker-compose up -d`

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
| **Status** | ✅ Working | ✅ Implemented |

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
            docker-compose pull; \
            docker-compose up -d; \
            docker-compose ps \
          "
```

Required repository secrets:
- `VPS_HOST` – example: `robert108.mikrus.xyz`
- `VPS_SSH_KEY` – private key for user (e.g., viktar)

---

## ✅ Validation (Both Paths)

```bash
# Check container status
sudo docker-compose ps | cat

# Check recent logs
sudo docker-compose logs --tail=50 | sed -n '1,120p'
```

You should see healthy/starting states and recent logs for all services.

---

## 🧩 Use in Cursor (prompt)
```text
Using the repo at ~/plat-edu-bad-data-mvp on the VPS, verify that docker-compose.yml contains only Mosquitto, Node-RED, InfluxDB 2.x, and Grafana. Ensure volumes, restart policies, and healthchecks exist. If issues are found, propose exact edits.
```


