You are an AI technical writer and developer working in Cursor. Your task is to fully write the VPS deployment documentation for a container-based application hosted on Mikrus 3.0.

Context
- Target audience: beginner-to-intermediate users.
- Author uses Windows PC and prefers Windows PowerShell for commands.
- Mikrus reference docs: [Mikrus Wiki](https://wiki.mikr.us/).
- VPS OS: Ubuntu 24.04 LTS.


Global writing requirements
- Write to separate .md files in the `docs/prompts/dev-vps-v2/` folder.
- Use clear, numbered step sections with headings: `## Step 1 – ...`.
- For every command, explain what it does and expected output.
- Prefer Windows PowerShell syntax and paths when applicable.
- Include ready-to-use AI prompts for Cursor IDE where it helps automate or verify steps.
- Keep the language beginner-to-intermediate friendly but technically accurate.
- Use descriptive anchor links when referencing external docs.
- Where choices exist, provide a “recommended default.”
- Use language-tagged code fences with the correct tag: `powershell` for local Windows steps, `bash` for remote VPS commands.
- Prefer non-interactive, idempotent commands (e.g., add `-y`/`--yes`, avoid prompts) and state expected exit codes/output.
- Use consistent placeholder syntax like `<ORG>`, `<BUCKET>`, `<GRAFANA_ADMIN_PASSWORD>` and never include real secrets; demonstrate setting secrets via environment variables.

Repository context (read-only)
- Root has `docker-compose.yml`, service directories: `influxdb`, `mosquitto`, `node-red`, `grafana`; Node-RED flows under `node-red/flows`; Grafana dashboards under `grafana/dashboards`.
- This is a containerized stack: Mosquitto MQTT, Node-RED, InfluxDB 2.x, Grafana.

Deliverable structure and content requirements

0) `docs/prompts/dev-vps-v2/README.md`
- Goal: Provide an index/overview for this folder.
- Include: brief description of the docs set, links to each step file with 1–2 line summaries, and a minimal quickstart linking to the most common path. Keep it short.

1) `docs/prompts/dev-vps-v2/01-vps-setup-and-preparation.md`
- Goal: Prepare local Windows environment, get Mikrus VPS access, install tools, harden basics.
- Sections (use `## Step N – Title`):
- Include: exact PowerShell commands (local) and bash commands (VPS) with explanations; troubleshooting tips; validation checks.
- Include: a short “Cursor prompt” snippet to validate environment and connectivity.

2) `docs/prompts/dev-vps-v2/02-docker-compose-and-repo-setup.md`
- Goal: Prepare the application on the VPS.
- Include:
  - Cloning the repository to the VPS, directory layout, and permissions.
  - Creating `.env` from `env.example` with safe defaults; explain each variable briefly.
  - Verifying and adjusting `docker-compose.yml` (ports, volumes, networks, restart policies, healthchecks).
  - Recommended defaults for Mikrus 3.0 (ports 1883, 1880, 8086, 3000; persistence volumes).
  - Cursor prompts to generate `.env`, audit ports/volumes, and check compose file.

3) `docs/prompts/dev-vps-v2/03-deployment-and-operations.md`
- Goal: Deploy and operate the stack.
- Include:
  - Pulling/building images, starting services with `docker compose up -d`, verifying status with `docker compose ps` and healthchecks.
  - Viewing logs, tailing logs, and filtering by service; common healthy vs. unhealthy signals.
  - Start/stop/restart flows; enabling auto-start on reboot.
  - Quick sanity tests: hitting Grafana, Node-RED, InfluxDB endpoints; verifying Mosquitto readiness.
  - Cursor prompts to stream logs, collect diagnostics, and generate an operations checklist.

4) `docs/prompts/dev-vps-v2/04-security-backups-and-monitoring.md`
- Goal: Apply essential security hardening and backups.
- Include:
  - SSH hardening (key-based auth, basic `ufw` firewall), Mikrus-specific notes with link to Mikrus Wiki.
  - Secure defaults for Mosquitto (ACLs, passwords), Grafana admin password management, InfluxDB token handling.
  - Backup strategy: volumes and configuration for InfluxDB, Grafana, Node-RED, Mosquitto; scheduled backups and restore testing.
  - Optional: reverse proxy and TLS guidance (Caddy/Nginx) with recommended defaults.
  - Cursor prompts to audit security (ports, users, ACLs) and to validate backup integrity.

5) `docs/prompts/dev-vps-v2/05-validation-testing-and-troubleshooting.md`
- Goal: Validate end-to-end data flow and fix common issues.
- Include:
  - Test MQTT publish/subscribe, Node-RED flow checks, InfluxDB write/read queries, Grafana dashboard validation.
  - Common problems and fixes (ports in use, permission issues, missing volumes, healthcheck failures).
  - Performance sanity checks and simple load tests; how to collect evidence when opening an issue.
  - Cursor prompts to generate test payloads, Influx queries, and to run a config audit.

AI prompts to include within the docs
- Provide short “Use in Cursor” blocks that the reader can paste to:
  - Validate environment (versions, ports open, ssh connectivity).
  - Generate initial `.env` from example with safe defaults.
  - Inspect docker logs for health signals.
  - Produce test MQTT payloads and Influx queries.
  - Run a config audit (ports, volumes, healthchecks, restart policies).

Quality bar (acceptance criteria)
- README plus the five step files exist and are complete, self-contained, and consistent.
- Headings follow `## Step N – …` style; each command has a purpose and expected result.
- Commands favor Windows PowerShell for local steps; bash on VPS for remote steps.
- Paths match repo reality: `docs/prompts/dev-vps-v2/...`.
- Includes AI prompts where needed in files to delegate task/step to AI.
- Beginner-to-intermediate friendly, but technically correct; no dead links; URLs use descriptive anchors.
- No unresolved TODOs; placeholders are used consistently and explained; never include real secrets.
- Internal links resolve.
- Commands use correct language fences and are non-interactive and copy-pasteable.

What to deliver
- The following files created and fully written under `docs/prompts/dev-vps-v2/`:
  0. `README.md` (index with links and brief descriptions for each step)
  1. `01-vps-setup-and-preparation.md`
  2. `02-docker-compose-and-repo-setup.md`
  3. `03-deployment-and-operations.md`
  4. `04-security-backups-and-monitoring.md`
  5. `05-validation-testing-and-troubleshooting.md`
- Each file must include at least one “Use in Cursor” prompt block.
- This `write-docs.md` file remains as the authoritative brief guiding the above docs.

Now proceed to implement the docs updates.
