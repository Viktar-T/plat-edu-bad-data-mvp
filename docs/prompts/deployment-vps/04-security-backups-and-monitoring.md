## Step 4 - Security, Backups, and Monitoring

Goal: apply essential hardening, configure basic backups, and monitor the stack.

### 4.1 SSH hardening (on VPS)

```bash
sudo nano /etc/ssh/sshd_config
# Port 10108
# PermitRootLogin prohibit-password
# PasswordAuthentication no   # after setting up keys
# AllowUsers viktar
# MaxAuthTries 3
# ClientAliveInterval 300
# ClientAliveCountMax 2
sudo systemctl restart ssh
```

### 4.2 UFW rules

```bash
sudo ufw enable
sudo ufw allow 10108/tcp     # SSH
sudo ufw allow 20108/tcp     # HTTP via Nginx
sudo ufw allow 30108/tcp     # HTTPS (future)
sudo ufw allow 40098/tcp     # MQTT
sudo ufw status numbered
```

Notes:
- Mikrus blocks standard 80/443 externally; use 20108/30108.
- Include IPv6 rules if enabled.

### 4.3 Fail2ban jail

```bash
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
sudo bash -c 'cat >/etc/fail2ban/jail.local' <<'JAIL'
[sshd]
enabled = true
port = 10108,22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
JAIL
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```

### 4.4 Service hardening notes

- Mosquitto: passwords + ACLs; disable anonymous.
- Grafana: change admin password; restrict signups.
- InfluxDB: use tokens; disable profiling in prod.
- Nginx: keep rate-limit and security headers; websocket headers for Node-RED.

### 4.5 Backups (volumes)

```bash
BACKUP_DIR=~/backups/$(date +%F)
mkdir -p "$BACKUP_DIR"
cp ~/deployment/.env "$BACKUP_DIR/" || true
cp -r ~/deployment/nginx "$BACKUP_DIR/" || true
cp -r ~/deployment/influxdb "$BACKUP_DIR/" || true
cp -r ~/deployment/grafana "$BACKUP_DIR/" || true
cp -r ~/deployment/node-red "$BACKUP_DIR/" || true
cp -r ~/deployment/mosquitto "$BACKUP_DIR/" || true
ls -la "$BACKUP_DIR" | cat
```

Schedule with cron:
```bash
(crontab -l 2>/dev/null; echo "30 2 * * * /bin/bash ~/backup-iot.sh") | crontab -
```

### 4.6 Monitoring basics

- Use Grafana dashboards for system metrics (optional: add node-exporter stack later).
- Watch `docker stats` for resource spikes.
- Tail Nginx and service logs during changes.

---

### Use in Cursor - security audit

```markdown
Ask Cursor to:
- Inspect UFW rules and Fail2ban status, summarize open ports and active jails
- Review Mosquitto config for allow_anonymous and ACL presence
- Verify Grafana admin password rotation steps are documented
```


