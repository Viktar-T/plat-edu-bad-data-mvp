### Mikrus 3.0 VPS Deployment Docs (Index)

This folder contains an end-to-end, beginner-to-intermediate guide for deploying the containerized stack (Mosquitto, Node-RED, InfluxDB 2.x, Grafana) on a Mikrus 3.0 VPS running Ubuntu 24.04 LTS.

- Prefer Windows PowerShell for local steps; use bash on the VPS.
- Commands are non-interactive where possible. Replace placeholders like `<ORG>` or `<GRAFANA_ADMIN_PASSWORD>` before running.

## Files
- [Step 1 – VPS Setup and Preparation](./01-vps-setup-and-preparation.md): Prepare your Windows environment, generate SSH keys, harden the VPS, install Docker.
- [Step 2 – Docker Compose and Repo Setup](./02-docker-compose-and-repo-setup.md): Clone the repo, create `.env`, verify `docker-compose.yml`, and prepare volumes.
- [Step 3 – Deployment and Operations](./03-deployment-and-operations.md): Start the stack, check health, view logs, and set up auto-restart.
- [Step 4 – Security, Backups, and Monitoring](./04-security-backups-and-monitoring.md): Apply essential hardening, set credentials/tokens, configure backups, optional TLS.
- [Step 5 – Validation, Testing, and Troubleshooting](./05-validation-testing-and-troubleshooting.md): Verify the data flow end-to-end and fix common issues.

## Quickstart (summary)

1) From Windows (local):
```powershell
# Replace <MIKRUS_USER> and <MIKRUS_HOST>
ssh -o StrictHostKeyChecking=no <MIKRUS_USER>@<MIKRUS_HOST> "echo OK"
```
Expected: OK

2) On the VPS:
```bash
sudo apt-get update -y && sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```
Expected: Docker installed; re-login required for group change to take effect.

3) Clone and run:
```bash
cd ~
git clone https://github.com/<ORG>/plat-edu-bad-data-mvp.git
cd plat-edu-bad-data-mvp
cp env.example .env
# Adjust .env safely, then:
docker compose pull
docker compose up -d
```
Expected: All services up; `docker compose ps` shows running/healthy containers.

Continue in Step 1 for the complete, hardened setup.

### Use in Cursor (paste into a new file or command palette)
```
Goal: Create an index for Mikrus VPS deployment docs and verify links.
- Check that all 5 step files exist in docs/prompts/dev-vps-v2/
- Validate each file begins with headings using the format "## Step N – ...".
- Produce a short checklist for the user to follow next (Step 1 to Step 5).
``` 