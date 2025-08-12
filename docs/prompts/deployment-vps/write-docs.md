You are an AI technical writer and developer working in Cursor. Your task is to fully write the VPS deployment documentation for a container-based application hosted on Mikrus 3.0.

Context
- Target audience: beginner-to-intermediate users.
- Author uses Windows PC and prefers Windows PowerShell for commands.
- Mikrus reference docs: [Mikrus Wiki](https://wiki.mikr.us/).
- VPS OS: Ubuntu 24.04 LTS.
- MY project on GitHub [plat-edu-bad-data-mvp](https://github.com/Viktar-T/plat-edu-bad-data-mvp)


Global writing requirements
- Write to separate .md files in the `docs/prompts/deployment-vps/` folder.
- Use clear, numbered step sections with headings: `## Step 1 – ...`.
- For every command, explain what it does and expected output.
- Prefer Windows PowerShell syntax and paths when applicable.
- Include ready-to-use AI prompts for Cursor IDE where it helps automate or verify steps.
- Add explanation. Keep the language intermediate friendly but technically accurate.
- Use descriptive anchor links when referencing external docs.
- Where choices exist, provide a “recommended default.”
- Use language-tagged code fences with the correct tag: `powershell` for local Windows steps, `bash` for remote VPS commands.
- Prefer non-interactive, idempotent commands (e.g., add `-y`/`--yes`, avoid prompts) and state expected exit codes/output.
- Use consistent placeholder syntax like `<ORG>`, `<BUCKET>`, `<GRAFANA_ADMIN_PASSWORD>` and never include real secrets; demonstrate setting secrets via environment variables.
- Reflect Mikrus specifics: standard ports 80/443 are not available; use Mikrus defaults `20108` (HTTP) and `30108` (HTTPS) via Nginx reverse proxy with path-based routing (`/grafana`, `/nodered`, `/influxdb`).
- Document IoT port usage: MQTT uses custom Mikrus TCP port `40098`.
- Current deployment excludes Express/React; only Mosquitto, Node-RED, InfluxDB 2.x, Grafana, and Nginx are deployed.

Repository context (read-only)
- Root has `docker-compose.yml`, service directories: `influxdb`, `mosquitto`, `node-red`, `grafana`; Node-RED flows under `node-red/flows`; Grafana dashboards under `grafana/dashboards`.
- This is a containerized stack: Mosquitto MQTT, Node-RED, InfluxDB 2.x, Grafana.

Deliverable structure and content requirements

0) `docs/prompts/deployment-vps/README.md`
- Goal: Provide an index/overview for this folder.
- Include: brief description of the docs set, links to each step file with 1–2 line summaries, and a minimal quickstart linking to the most common path. Keep it short.

1) `docs/prompts/deployment-vps/01-vps-setup-and-preparation.md` -- 
- Important Notes: almost ready; minor changes/additions only. Keep Nginx path-based routing, Mikrus port strategy, UFW/Fail2ban, and kernel tuning aligned with the project.
- Goal: Prepare local Windows environment, get Mikrus VPS access, install tools, harden basics.
- Sections (use `## Step N – Title`):
- Include: exact PowerShell commands (local) and bash commands (VPS) with explanations; troubleshooting tips; validation checks.
- Include: a short “Cursor prompt” snippet to validate environment and connectivity.

2) `docs/prompts/deployment-vps/02-docker-compose-and-repo-setup.md`
- Goal: Prepare the application on the VPS.
- Include:
  - Cloning the repository to the VPS, directory layout, and permissions.
  - Environment files are managed by scripts: local uses `.env.local` → `.env` via `scripts/dev-local.ps1`; production uses `.env.production` via `scripts/deploy-production.ps1` (no manual `.env` creation on VPS).
  - Verifying and adjusting `docker-compose.yml` (volumes, networks, restart policies, healthchecks); remove Express/React services for production until ready.
  - Port strategy:
    - Local development: standard ports (1883 MQTT, 9001 WS, 8086 InfluxDB, 1880 Node-RED, 3000 Grafana).
    - Production: Nginx reverse proxy on `20108`/`30108` with path-based routing; MQTT on `40098`.
  - Persistence volumes for all stateful services.
  - Cursor prompts to generate `.env`, audit ports/volumes, and check compose file.

3) `docs/prompts/deployment-vps/03-deployment-and-operations.md`
- Goal: Deploy and operate the stack.
- Include:
  - Pulling/building images, starting services with `docker compose up -d`, verifying status with `docker compose ps` and healthchecks.
  - Viewing logs, tailing logs, and filtering by service; common healthy vs. unhealthy signals.
  - Start/stop/restart flows; enabling auto-start on reboot.
  - Quick sanity tests: access Grafana `/grafana`, Node-RED `/nodered`, InfluxDB `/influxdb` via `http://<HOST>:20108/...`; verify Mosquitto on port `40098`.
  - Note: Express/React are currently not deployed; Nginx default route redirects to `/grafana/`.
  - Cursor prompts to stream logs, collect diagnostics, and generate an operations checklist.

4) `docs/prompts/deployment-vps/04-security-backups-and-monitoring.md`
- Goal: Apply essential security hardening and backups.
- Include:
  - SSH hardening (key-based auth, basic `ufw` firewall), Mikrus-specific notes (80/443 blocked; use `20108`/`30108`).
  - Secure defaults for Mosquitto (ACLs, passwords), Grafana admin password management, InfluxDB token handling.
  - Backup strategy: volumes and configuration for InfluxDB, Grafana, Node-RED, Mosquitto; scheduled backups and restore testing.
  - Reverse proxy and TLS guidance (Nginx) with recommended defaults; path-based routing and CORS where needed.
  - Cursor prompts to audit security (ports, users, ACLs) and to validate backup integrity.
  - UFW baseline: allow `10108/tcp` (SSH), `20108/tcp` (HTTP via Nginx), `30108/tcp` (HTTPS future), `40098/tcp` (MQTT); include IPv6 equivalents. Fail2ban jail for ports `10108,22`.

5) `docs/prompts/deployment-vps/05-validation-testing-and-troubleshooting.md`
- Goal: Validate end-to-end data flow and fix common issues.
- Include:
  - Test MQTT publish/subscribe, Node-RED flow checks, InfluxDB write/read queries, Grafana dashboard validation.
  - Common problems and fixes (ports in use, permission issues, missing volumes, healthcheck failures).
  - Performance sanity checks and simple load tests; how to collect evidence when opening an issue.
  - Cursor prompts to generate test payloads, Influx queries, and to run a config audit.

AI prompts to include within the docs
- Provide short “Use in Cursor” blocks that the reader can paste to:
  - Validate environment (versions, ports open, ssh connectivity).
  - Generate initial `.env.local` from `env.example` (local) and verify `.env.production` (production) are present.
  - Inspect docker logs for health signals.
  - Produce test MQTT payloads and Influx queries.
  - Run a config audit (ports, volumes, healthchecks, restart policies).
  - Verify kernel parameter values applied (selected `sysctl` keys only) and audit UFW port rules.

Quality bar (acceptance criteria)
- README plus the five step files exist and are complete, self-contained, and consistent.
- Headings follow `## Step N – …` style; each command has a purpose and expected result.
- Commands favor Windows PowerShell for local steps; bash on VPS for remote steps.
- Paths match repo reality: `docs/prompts/deployment-vps/...`.
- Includes AI prompts where needed in files to delegate task/step to AI.
- Beginner-to-intermediate friendly, but technically correct; no dead links; URLs use descriptive anchors.
- No unresolved TODOs; placeholders are used consistently and explained; never include real secrets.
- Internal links resolve.
- Commands use correct language fences and are non-interactive and copy-pasteable.

What to deliver
- The following files created and fully written under `docs/prompts/deployment-vps/`:
  0. `README.md` (index with links and brief descriptions for each step)
  1. `01-vps-setup-and-preparation.md`
  2. `02-docker-compose-and-repo-setup.md`
  3. `03-deployment-and-operations.md`
  4. `04-security-backups-and-monitoring.md`
  5. `05-validation-testing-and-troubleshooting.md`
- Each file must include at least one “Use in Cursor” prompt block.
- This `write-docs.md` file remains as the authoritative brief guiding the above docs.

Now proceed to implement the docs updates.
