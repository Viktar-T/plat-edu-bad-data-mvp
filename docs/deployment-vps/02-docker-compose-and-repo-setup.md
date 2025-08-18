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

## 📊 Deployment Path Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DIRECT GIT DEPLOYMENT (PATH B)                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌─────────────────────────┐
                    │     PATH B              │
                    │   (✅ IMPLEMENTED)      │
                    │   Direct Git            │
                    │  (Requires VPS setup)   │
                    └─────────────────────────┘
                                    │
                                    ▼
                    ┌─────────────────────────┐
                    │ 1. Clone repo on VPS:   │
                    │    git clone ...         │
                    │                        │
                    │ 2. Set permissions:     │
                    │    sudo chown -R ...    │
                    │                        │
                    │ 3. Start services:     │
                    │    docker-compose up -d │
                    │                        │
                    │ Location:               │
                    │ /home/viktar/plat-edu-bad-data-mvp │
                    │                        │
                    │ Updates:               │
                    │ git pull --ff-only      │
                    │                        │
                    └─────────────────────────┘
```

**Deployment Method:**
- **Path B**: Direct Git deployment with VPS setup (clone repo, set permissions), then direct Docker commands
- **Location**: `/home/viktar/plat-edu-bad-data-mvp`
- **Updates**: `git pull --ff-only` then `docker-compose up -d`

---

## Path B: Direct Git Deployment (Implemented)

**✅ Direct Git deployment** - Clone repository on VPS and manage directly with Docker commands.

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

# Copy production environment file
cp .env.production .env

# Fix Docker volume permissions (IMPORTANT for VPS deployment)
echo "🔧 Fixing Docker volume permissions..."
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data

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

# Copy production environment file
cp .env.production .env

# Fix Docker volume permissions (IMPORTANT for VPS deployment)
echo "🔧 Fixing Docker volume permissions..."
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data

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
cp .env.production .env
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

### 🔧 Container Permission Issues

**Issue**: Grafana or Node-RED containers showing `Restarting` or `health: starting` status with permission errors in logs.

**Symptoms**:
- Grafana: `GF_PATHS_DATA='/var/lib/grafana' is not writable`
- Node-RED: `npm error code EACCES` and `Your cache folder contains root-owned files`

**Solution**: Fix Docker volume permissions
```bash
# Stop all containers first
sudo docker-compose down

# Fix permissions for all services
sudo chown -R 472:472 ./grafana/data ./grafana/plugins
sudo chown -R 1000:1000 ./node-red/data
sudo chown -R 1883:1883 ./mosquitto/data ./mosquitto/log
sudo chown -R 472:472 ./influxdb/data
sudo chmod -R 755 ./grafana/data ./grafana/plugins ./node-red/data ./mosquitto/data ./mosquitto/log ./influxdb/data

# Ensure correct environment file
cp .env.production .env

# Start services
sudo docker-compose up -d

# Check status
sudo docker-compose ps
```

**Why this happens**: Docker containers run as specific users (Grafana=472, Node-RED=1000) but host directories are owned by your user (viktar). This is a common issue when deploying Docker containers on Linux systems.

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
cp .env.production .env
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

## Environment Files

**📝 Information Only - No Manual Setup Required**

- **Path B**: Uses `.env.production` file for environment configuration
- **Environment file**: Copied from `.env.production` to `.env` before starting services

**Validation**: You can verify the environment setup by checking:

```bash
# Check for environment files
ls -la | grep "\.env" || echo "No .env files found"

# Check if .env.production exists
ls -la .env.production || echo ".env.production not found"
```

Expected output: Should show `.env.production` file exists.

---

## Deployment Summary

| Aspect | Path B (Direct Git) |
|--------|-------------------|
| **VPS Setup Required** | ✅ Yes (clone, permissions) |
| **Local Machine Required** | ❌ No |
| **Deployment Location** | `/home/viktar/plat-edu-bad-data-mvp` |
| **Updates** | `git pull --ff-only` |
| **Complexity** | 🟡 Requires VPS knowledge |
| **Automation** | 🟡 Manual steps |
| **Status** | ✅ Implemented |

**Current Setup**: Using **Path B** (Direct Git Deployment) for direct control and management.

---

## CI/CD Pipeline (GitHub Actions)

Example workflow for Direct Git Deployment:

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
            cp .env.production .env; \
            docker-compose pull; \
            docker-compose up -d; \
            docker-compose ps \
          "
```

Required repository secrets:
- `VPS_HOST` – example: `robert108.mikrus.xyz`
- `VPS_SSH_KEY` – private key for user (e.g., viktar)

---

## ✅ Validation

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


