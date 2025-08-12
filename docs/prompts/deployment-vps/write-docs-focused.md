# 🚀 VPS Deployment Documentation Generator

> **Create comprehensive VPS deployment docs for renewable energy IoT monitoring system**

## 🎯 **Primary Objective**
Generate 6 complete documentation files for deploying a containerized renewable energy IoT monitoring system on Mikrus VPS.

## 📋 **Essential Requirements**

### **Target Audience**
- Beginner-to-intermediate users
- Windows PowerShell for local commands
- Ubuntu 24.04 LTS on VPS

### **Technical Stack**
- **Services**: Mosquitto MQTT, Node-RED, InfluxDB 2.x, Grafana, Nginx
- **Ports**: 20108 (HTTP), 30108 (HTTPS), 40098 (MQTT)
- **Routing**: Path-based Nginx proxy (/grafana, /nodered, /influxdb)
- **Deployment**: Manual + CI/CD tracks

### **Repository Context**
- Root: `docker-compose.yml`
- Services: `influxdb/`, `mosquitto/`, `node-red/`, `grafana/`
- Scripts: `scripts/dev-local.ps1`, `scripts/deploy-production.ps1`
- **Note**: Express/React excluded from current deployment

## 📁 **Files to Create**

### **0. `README.md`**
- Index/overview for the docs folder
- Links to each step file with summaries
- Minimal quickstart guide
- **Keep it short and focused**

### **1. `01-vps-setup-and-preparation.md`**
- **Status**: ✅ **COMPLETED** - All steps finished and tested
- Server preparation, security hardening, Docker installation
- Mikrus VPS access configured (robert108.mikrus.xyz:10108)
- Nginx path-based routing, UFW/Fail2ban, kernel optimization implemented
- **No further changes needed** - Ready for Phase 2

### **2. `02-docker-compose-and-repo-setup.md`**
- Clone repository to VPS
- Environment files (handled by scripts)
- Verify/adjust `docker-compose.yml`
- Port strategy: local vs production
- Two deployment tracks (Manual + CI/CD)

### **3. `03-deployment-and-operations.md`**
- Deploy and operate the stack
- `docker compose up -d`, status checks, healthchecks
- Viewing/tailing logs, service management
- Quick sanity tests via `http://robert108.mikrus.xyz:20108/...`
- Two operational approaches (Manual + CI/CD)

### **4. `04-security-backups-and-monitoring.md`**
- SSH hardening, UFW firewall
- Secure defaults for all services
- Backup strategy (volumes + configs)
- Reverse proxy and TLS guidance
- CI/CD secrets management

### **5. `05-validation-testing-and-troubleshooting.md`**
- End-to-end data flow validation
- MQTT publish/subscribe tests
- Node-RED flow checks, InfluxDB queries
- Common problems and fixes
- Performance sanity checks

## ✍️ **Writing Standards**

### **Format Requirements**
- Use `## Step N – Title` headings
- Explain every command with expected output
- PowerShell for local, bash for VPS commands
- Include "Use in Cursor" prompt blocks
- No real secrets, use placeholders consistently

### **Technical Accuracy**
- Mikrus-specific: ports 80/443 blocked, use 20108/30108/40098
- Path-based routing: `/grafana`, `/nodered`, `/influxdb`
- Environment files managed by scripts (no manual `.env` creation)
- Two deployment tracks with clear procedures

### **User Experience**
- Beginner-friendly but technically accurate
- Copy-pasteable commands with `-y` flags
- Troubleshooting tips for each step
- Validation checks after major operations

## 🚀 **Implementation Strategy**

### **Phase 1: Foundation**
1. Create `README.md` (index and overview)
2. ✅ `01-vps-setup-and-preparation.md` (COMPLETED - no changes needed)

### **Phase 2: Core Setup**
3. Create `02-docker-compose-and-repo-setup.md`
4. Create `03-deployment-and-operations.md`

### **Phase 3: Security & Testing**
5. Create `04-security-backups-and-monitoring.md`
6. Create `05-validation-testing-and-troubleshooting.md`

## ✅ **Quality Checklist**

### **Content Requirements**
- [ ] All 6 files exist and are complete
- [ ] Self-contained and consistent across files
- [ ] No unresolved TODOs or dead links
- [ ] Internal links resolve correctly
- [ ] Placeholders used consistently, no real secrets

### **Technical Accuracy**
- [ ] Mikrus port strategy correctly implemented
- [ ] Path-based routing properly documented
- [ ] Two deployment tracks (Manual + CI/CD) included
- [ ] Environment file management explained
- [ ] Service stack accurately reflected

### **User Experience**
- [ ] Beginner-to-intermediate friendly language
- [ ] Every command explained with expected output
- [ ] Troubleshooting tips provided
- [ ] Validation checks included
- [ ] "Use in Cursor" prompt blocks present

## 🎯 **Start Here**

**Begin with `README.md`** - Create the index file first, then proceed with each numbered file in sequence. Each file should be self-contained but reference the overall system architecture.

**Note**: `01-vps-setup-and-preparation.md` is already complete and tested. Focus on creating the remaining 5 files.

**Focus on one file at a time** and ensure it's complete before moving to the next. The goal is comprehensive, user-friendly documentation that enables successful VPS deployment.
