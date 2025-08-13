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
- Grafana: `http://robert108.mikrus.xyz:20108/grafana`
- Node-RED: `http://robert108.mikrus.xyz:20108/nodered`
- InfluxDB: `http://robert108.mikrus.xyz:20108/influxdb`
- MQTT: `robert108.mikrus.xyz:1883`

**Status**: ✅ Successfully deployed and running

## 📄 Files in this folder

- [01-vps-setup-and-preparation.md](./01-vps-setup-and-preparation.md)
  - Prepare VPS: users, SSH, firewall, Fail2ban, Docker, kernel tuning. Status: ✅ Completed.

- [02-docker-compose-and-repo-setup.md](./02-docker-compose-and-repo-setup.md)
  - Get the application onto the VPS; repository cloning; Docker Compose configuration; environment files via scripts; manual and CI/CD setup. Status: ✅ Completed (Path A - PowerShell).

- [03-deployment-and-operations.md](./03-deployment-and-operations.md)
  - Start, stop, and verify containers; logs and health; sanity checks; operational commands for manual and CI/CD flows.

- [04-security-backups-and-monitoring.md](./04-security-backups-and-monitoring.md)
  - Essential hardening; safe defaults for Mosquitto/Grafana/InfluxDB; backups; reverse proxy/TLS guidance; secrets in CI/CD.

- [05-validation-testing-and-troubleshooting.md](./05-validation-testing-and-troubleshooting.md)
  - End-to-end validation; MQTT, Node-RED, InfluxDB, Grafana tests; performance checks; common issues and fixes.

## 🧭 Mikrus specifics
- Standard ports 80/443 are blocked. Use 20108 (HTTP) and 30108 (HTTPS) behind Nginx path-based routing.
- MQTT runs on 1883/TCP (exposed directly, not through Nginx).
- Current production scope: Mosquitto, Node-RED, InfluxDB 2.x, Grafana, and Nginx. Express/React are excluded for now.
- **Current VPS**: robert108.mikrus.xyz (successfully deployed)

## 🧩 Use in Cursor (prompt)
```text
Act as a documentation QA reviewer. Verify that each step file in docs/prompts/deployment-vps/ is self-contained, uses correct PowerShell/bash fences, explains commands with expected outputs, and includes Mikrus port strategy (20108/30108/40098) and path routing (/grafana,/nodered,/influxdb). Report inconsistencies and propose edits.
```


