## Step 4 – Security, Backups, and Monitoring

Apply essential hardening, set credentials/tokens safely, and configure backups. See the [Mikrus Wiki](https://wiki.mikr.us/) for platform-specific notes.

## Step 1 – SSH hardening (VPS)

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart ssh
```
Expected: Password login disabled; root login disabled.

## Step 2 – UFW firewall policy (VPS)

```bash
sudo ufw status || sudo apt-get install -y ufw
# Allow only what you need (adjust for your exposure model)
sudo ufw allow 22/tcp
sudo ufw allow 1883/tcp   # Mosquitto (MQTT)
sudo ufw allow 1880/tcp   # Node-RED
sudo ufw allow 8086/tcp   # InfluxDB API
sudo ufw allow 3000/tcp   # Grafana
sudo ufw --force enable
sudo ufw status numbered
```
Expected: Only the required ports are exposed.

## Step 3 – Service credentials and tokens

- Mosquitto: create users in the password file; use ACLs to restrict topics.
- Grafana: set `GRAFANA_ADMIN_PASSWORD` via `.env` (do not hardcode in compose file).
- InfluxDB 2.x: use tokens stored in `.env` or Docker secrets. Rotate regularly.

```bash
# Mosquitto example (inside the container)
docker compose exec mosquitto sh -lc 'mosquitto_passwd -b /mosquitto/config/passwd <MQTT_USER> <MQTT_PASSWORD>'
# Example minimal ACL (append on host):
cat << 'EOF' | sudo tee -a mosquitto/config/acl >/dev/null
user <MQTT_USER>
topic readwrite devices/#
EOF
# Restart mosquitto to apply
docker compose restart mosquitto
```
Expected: MQTT requires auth; ACLs applied. Keep passwords/tokens out of version control.

## Step 4 – Backups (volumes and configs)

Create a simple snapshot backup under `/opt/backups`.

```bash
BACKUP_DIR=/opt/backups/$(date +%Y%m%d-%H%M%S)
sudo mkdir -p "$BACKUP_DIR"
sudo tar -czf "$BACKUP_DIR/influxdb.tgz" -C $(pwd) influxdb
sudo tar -czf "$BACKUP_DIR/grafana.tgz" -C $(pwd) grafana
sudo tar -czf "$BACKUP_DIR/node-red.tgz" -C $(pwd) node-red
sudo tar -czf "$BACKUP_DIR/mosquitto.tgz" -C $(pwd) mosquitto
ls -lh "$BACKUP_DIR"
```
Expected: Four tarballs created with data/configs.

Automate daily backups via cron:
```bash
( crontab -l 2>/dev/null; echo "0 2 * * * cd ~/plat-edu-bad-data-mvp && BACKUP_DIR=/opt/backups/$(date +\%Y\%m\%d-\%H\%M\%S) && mkdir -p \"$BACKUP_DIR\" && tar -czf \"$BACKUP_DIR/influxdb.tgz\" -C $(pwd) influxdb && tar -czf \"$BACKUP_DIR/grafana.tgz\" -C $(pwd) grafana && tar -czf \"$BACKUP_DIR/node-red.tgz\" -C $(pwd) node-red && tar -czf \"$BACKUP_DIR/mosquitto.tgz\" -C $(pwd) mosquitto " ) | crontab -
```
Expected: A daily 02:00 backup job installed.

Restore example:
```bash
# Stop services
docker compose down
# Restore a component (example: influxdb)
sudo tar -xzf /opt/backups/<STAMP>/influxdb.tgz -C $(pwd)
# Restart services
docker compose up -d
```

## Step 5 – Optional TLS (reverse proxy)

If exposing services publicly, use a reverse proxy (Caddy or Nginx) with TLS.
- Recommended: Caddy for automatic HTTPS with minimal config.
- Ensure upstream services bind to `127.0.0.1` and only the proxy is exposed.

### Use in Cursor – Security/Backup audit
```
Audit the deployment for:
- SSH: root login disabled, password auth disabled
- UFW: only required ports open
- Mosquitto: passwd + ACLs present
- Secrets: .env not committed; tokens/passwords referenced via env
- Backups: latest snapshot exists and is recent (< 24h)
Return a short PASS/FAIL report with actionable fixes.
``` 