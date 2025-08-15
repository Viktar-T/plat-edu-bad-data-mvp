# 📚 Mikrus VPS Deployment Documentation (Index)

This folder contains step-by-step documentation to deploy the renewable energy IoT monitoring system on Mikrus VPS using Docker.

## ⚡ Quickstart (Most common path)

Run from Windows PowerShell in the project root:

```powershell
# Prepare artifacts for production deployment
./scripts/deploy-production.ps1 -Prepare

# Full deployment to VPS (packages, transfers, and deploys)
./scripts/deploy-production.ps1 -Full
```

Expected result:
- A production bundle is created locally
- Bundle is copied to the VPS
- Services are started via Docker Compose on the VPS

Then access services:
- Grafana: `http://robert108.mikrus.xyz:40099`
- Node-RED: `http://robert108.mikrus.xyz:40100`
- InfluxDB: `http://robert108.mikrus.xyz:40101`
- MQTT: `robert108.mikrus.xyz:40098`

**Status**: ✅ Successfully deployed and running

## 📄 Files in this folder

- [01-vps-setup-and-preparation.md](./01-vps-setup-and-preparation.md)
  - Prepare VPS: users, SSH, firewall, Fail2ban, Docker, kernel tuning. Status: ✅ Completed.

- [02-docker-compose-and-repo-setup.md](./02-docker-compose-and-repo-setup.md)
  - Get the application onto the VPS; repository cloning; Docker Compose configuration; environment files via scripts; manual and CI/CD setup. Status: ✅ Completed (Path A - PowerShell).

- [03-manage-and-operations.md](./03-manage-and-operations.md)
  - Start, stop, and verify containers; logs and health; sanity checks; operational commands for manual and CI/CD flows.

- [04-security-backups-and-monitoring.md](./04-security-backups-and-monitoring.md)
  - Essential hardening; safe defaults for Mosquitto/Grafana/InfluxDB; backups; reverse proxy/TLS guidance; secrets in CI/CD.

- [05-validation-testing-and-troubleshooting.md](./05-validation-testing-and-troubleshooting.md)
  - End-to-end validation; MQTT, Node-RED, InfluxDB, Grafana tests; performance checks; common issues and fixes.

## 🧭 Mikrus specifics
- **Direct Port Access**: Each service runs on its own dedicated port (no nginx required)
- **MQTT**: Port 40098 (exposed directly)
- **Grafana**: Port 40099 (exposed directly)
- **Node-RED**: Port 40100 (exposed directly)
- **InfluxDB**: Port 40101 (exposed directly)
- **Current VPS**: robert108.mikrus.xyz (successfully deployed)

## 🧩 Use in Cursor (prompt)
```text
Act as a documentation QA reviewer. Verify that each step file in docs/prompts/deployment-vps/ is self-contained, uses correct PowerShell/bash fences, explains commands with expected outputs, and includes Mikrus port strategy (40098-40101) with direct service access. Report inconsistencies and propose edits.
```


