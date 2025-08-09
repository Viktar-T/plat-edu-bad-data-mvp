You are an AI technical writer and developer working in Cursor. Your task is to fully write and refine the VPS deployment documentation for a container-based application hosted on Mikrus 3.0.

Context
- Target audience: beginner-to-intermediate users.
- Author uses Windows PC and prefers Windows PowerShell for commands.
- Mikrus reference docs: [Mikrus Wiki](https://wiki.mikr.us/).
- VPS OS: Ubuntu 24.04 LTS.

Scope of work
Update these files in place:
- `docs/prompts/deployment-vps/01-vps-setup-and-preparation.md`
- `docs/prompts/deployment-vps/02-application-deployment.md`
- `docs/prompts/deployment-vps/03-data-migration-testing.md`
- `docs/prompts/deployment-vps/04-production-optimization.md`
- `docs/prompts/deployment-vps/README.md`

Global writing requirements
- Use clear, numbered step sections with headings: `## Step 1 – ...`.
- For every command, explain what it does and expected output.
- Prefer Windows PowerShell syntax and paths when applicable.
- Include ready-to-use AI prompts for Cursor IDE where it helps automate or verify steps.
- Keep the language beginner(intermediate)-friendly but technically accurate.
- Use descriptive anchor links when referencing external docs.
- Keep paths and filenames consistent with this repository (`docs/prompts/...`).
- Where choices exist, provide a “recommended default.”
- Use language-tagged code fences with the correct tag: `powershell` for local Windows steps, `bash` for remote VPS commands.
- Prefer non-interactive, idempotent commands (e.g., add `-y`/`--yes`, avoid prompts) and state expected exit codes/output.
- Use consistent placeholder syntax like `<ORG>`, `<BUCKET>`, `<GRAFANA_ADMIN_PASSWORD>` and never include real secrets; demonstrate setting secrets via environment variables.

Repository context (read-only)
- Root has `docker-compose.yml`, service directories: `influxdb`, `mosquitto`, `node-red`, `grafana`; Node-RED flows under `node-red/flows`; Grafana dashboards under `grafana/dashboards`.
- This is a containerized stack: Mosquitto MQTT, Node-RED, InfluxDB 2.x, Grafana.

Deliverable structure and content requirements

1) `docs/prompts/deployment-vps/01-vps-setup-and-preparation.md`
- Goal: Prepare local Windows environment, get Mikrus VPS access, install tools, harden basics.
- Sections (use `## Step N – Title`):
  - Step 1 – Prerequisites on Windows: install PowerShell 7+, Git, Docker Desktop (WSL2 backend), optional WSL Ubuntu; verify versions.
  - Step 2 – Generate SSH keys on Windows PowerShell; upload public key to Mikrus panel; test ssh.
  - Step 3 – Mikrus VPS basics: machine specs, OS image, login, timezone, locales, sudo.
  - Step 4 – Base security: update/upgrade, create non-root user, SSH config (key-only), firewall (ufw), fail2ban (optional), time sync.
  - Step 5 – Install Docker Engine + Docker Compose plugin on VPS; verify hello-world.
  - Step 6 – Prepare project directory on VPS; clone this repo via SSH; verify tree.
- Include: exact PowerShell commands (local) and bash commands (VPS) with explanations; troubleshooting tips; validation checks.
- Include: a short “Cursor prompt” snippet to validate environment and connectivity.

2) `docs/prompts/deployment-vps/02-application-deployment.md`
- Goal: Configure environment and bring up containers on Mikrus.
- Sections:
  - Step 1 – Review repo structure: `docker-compose.yml`, `influxdb/config`, `mosquitto/config`, `node-red`, `grafana` paths.
  - Step 2 – Copy/prepare `.env` from `env.example`; define required variables (tokens, admin creds, ports).
  - Step 3 – Configure services:
    - Mosquitto: users, ACL, persistence, ports (1883).
    - InfluxDB 2.x: org, bucket, token, retention policies; init scripts if present.
    - Node-RED: flows path, persistent volume, startup.
    - Grafana: provisioning of data sources and dashboards; admin credentials.
  - Step 4 – Start stack: `docker compose up -d`; check logs; health checks.
  - Step 5 – Verify endpoints: Mosquitto (1883), Node-RED (1880), InfluxDB (8086), Grafana (3000).
  - Step 6 – Seed/test data path: use Node-RED simulation flows to push MQTT messages; confirm Influx writes; Grafana panels load.
- Include: port table, volumes, and where data persists; restart policies; basic CORS note for future Express backend.
- Include: a “Cursor prompt” to auto-check service health and common misconfigurations.

3) `docs/prompts/deployment-vps/03-data-migration-testing.md`
- Goal: Migrate any existing data, test end-to-end data flow, and verify stability.
- Sections:
  - Step 1 – Backups and exports: InfluxDB backup/restore; Grafana dashboards export/import; Mosquitto persistence.
  - Step 2 – Migration procedure: stop services safely, copy volumes/backup files, restore, bring up services.
  - Step 3 – End-to-end test plan: MQTT → Node-RED → InfluxDB → Grafana; use specific test topics and sample payloads; expected results.
  - Step 4 – Performance sanity checks: container resource usage, Influx query response times, Grafana dashboard load.
  - Step 5 – Troubleshooting matrix: common issues, symptoms, diagnostics, fixes.
- Include: command blocks for both PowerShell (scp/rsync via Windows) and VPS bash; verification queries to Influx; Grafana UI checks.
- Include: a “Cursor prompt” to generate/validate synthetic test payloads and queries.

4) `docs/prompts/deployment-vps/04-production-optimization.md`
- Goal: Hardening, backups, monitoring, and scaling guidance for Mikrus constraints.
- Sections:
  - Step 1 – Security: least-privilege Docker users, secrets management, SSL/TLS offload options, security updates strategy.
  - Step 2 – Backups: schedule InfluxDB and Grafana backups, retention policies, offsite copies; restore drills.
  - Step 3 – Monitoring/logging: container healthchecks, docker logs rotation, basic alerting options.
  - Step 4 – Performance tuning: Influx retention and indexing tips, Node-RED flow performance, Grafana query optimization, resource limits.
  - Step 5 – Scaling paths: vertical vs. horizontal on Mikrus, pruning unused images/volumes, safe redeploy procedures.
- Include: copy-paste cron examples, verification commands, and rollback steps.
- Include: a “Cursor prompt” to audit the compose file for production-readiness.

5) `docs/prompts/deployment-vps/README.md`
- Goal: High-level guide and table of contents.
- Required structure:
  - Overview: what the stack does; two data flows (Grafana only; custom web app).
  - Prerequisites and target audience.
  - Quick start summary: 5–8 bullets referencing steps in the other docs.
  - Links to each file with one-line descriptions.
  - Support/troubleshooting pointers and where to file issues.
- Keep concise and highly scannable.

AI prompts to include within the docs
- Provide short “Use in Cursor” blocks that the reader can paste to:
  - Validate environment (versions, ports open, ssh connectivity).
  - Generate initial `.env` from example with safe defaults.
  - Inspect docker logs for health signals.
  - Produce test MQTT payloads and Influx queries.
  - Run a config audit (ports, volumes, healthchecks, restart policies).

Quality bar (acceptance criteria)
- All five files exist and are complete, self-contained, and consistent.
- Headings follow `## Step N – …` style; each command has a purpose and expected result.
- Commands favor Windows PowerShell for local steps; bash on VPS for remote steps.
- Paths match repo reality: `docs/prompts/deployment-vps/...` (not `docs/promts`).
- Includes at least one AI prompt in each file.
- Beginner-friendly, but technically correct; no dead links; URLs use descriptive anchors.
- No TODOs left; no placeholders; copy-pasteable commands.
- Internal links resolve.
- Commands use correct language fences.
- Commands are non-interactive and copy-pasteable.

What to deliver
- Overwrite the contents of the five files with the finalized documentation.
- Do not rename directories or files.
- After writing, output a brief changelog of what you added to each file.

Now proceed to implement the docs updates.
