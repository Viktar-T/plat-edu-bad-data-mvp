# 🔐 Step 4 – Security, Backups, and Monitoring

Goal: Apply essential hardening, set safe defaults, and implement backups and basic monitoring practices.

Mikrus specifics:
- Use ports `20108` (HTTP) and `30108` (future HTTPS) with Nginx path-based routing
- MQTT on `40098/tcp`

---

## Step 1 – SSH and firewall recap

Already applied in Step 1:
- SSH custom port `10108`, fail2ban jail for `10108,22`
- UFW allow: `10108/tcp`, `20108/tcp`, `30108/tcp`, `40098/tcp` (+ IPv6)

Validate:
```bash
sudo ufw status numbered | sed -n '1,120p'
sudo fail2ban-client status sshd | sed -n '1,80p'
```

---

## Step 2 – Mosquitto hardening

Passwords and ACLs:
```bash
# Create/update MQTT password file (inside repo paths if bind-mounted)
sudo mosquitto_passwd -c /mosquitto/config/passwd admin

# Example ACL file (restrict topics by user)
sudo tee /mosquitto/config/acl >/dev/null <<'EOF'
user admin
topic readwrite devices/#
EOF
```

Restart Mosquitto:
```bash
docker compose restart mosquitto
```

Expected: Mosquitto reloads and accepts admin auth on allowed topics.

---

## Step 3 – Grafana admin and data source

Change admin password on first login (or via env vars for provisioning). In production, avoid default `admin/admin`.

Verify data source points to InfluxDB at `http://influxdb:8086` with correct org/bucket/token.

---

## Step 4 – InfluxDB tokens and retention

Use scoped tokens for writes vs. reads. Rotate tokens periodically.

Retention policies: consider a shorter retention for noisy measurements and longer for aggregated data.

---

## Step 5 – Backups

Snapshot volumes for persistence. From VPS:

```bash
cd ~/plat-edu-bad-data-mvp

# Create a dated backup archive (adjust volume paths if using bind mounts)
sudo tar -czf backup-$(date +%Y%m%d).tar.gz \
  influxdb/ grafana/ mosquitto/ node-red/

ls -lh backup-*.tar.gz | tail -n 1
```

Expected: A `.tar.gz` with configuration and data directories.

Restore test (separate environment recommended): extract archive and point services to restored volumes.

Scheduling: configure `cron` to run the backup daily/weekly and copy off-server (e.g., S3, remote SCP).

---

## Step 6 – Basic monitoring

- Enable healthchecks in Compose where possible
- Use Grafana alerts (optional) for key panels
- Periodically review `docker compose logs` for anomalies

---

## Step 7 – CI/CD secrets hygiene

- Store secrets in repository or organization secrets (GitHub)
- Avoid plaintext secrets in workflow YAML
- Limit token scopes; audit Actions permissions

---

## 🧩 Use in Cursor (prompt)
```text
Review Mosquitto ACL and password configuration. Suggest improvements to restrict topics per user and enforce least privilege for common device roles.
```


