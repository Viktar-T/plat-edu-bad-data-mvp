## Step 5 - Validation, Testing, and Troubleshooting

Goal: validate end-to-end data flow and resolve common issues.

### 5.1 Quick endpoint checks (bash)

```bash
curl -I http://<HOST>:20108/grafana | head -n1
curl -I http://<HOST>:20108/nodered | head -n1
curl -I http://<HOST>:20108/influxdb | head -n1
```

Expect HTTP 200/302 responses.

### 5.2 MQTT broker test

```bash
sudo apt update && sudo apt install -y mosquitto-clients
mosquitto_sub -h <HOST> -p 40098 -t "test/topic" -u <MQTT_USER> -P <MQTT_PASS> -v &
sleep 1
mosquitto_pub -h <HOST> -p 40098 -t "test/topic" -m "hello" -u <MQTT_USER> -P <MQTT_PASS>
```

Expect subscriber output to show the published message.

### 5.3 InfluxDB write/read sanity

```bash
curl -s -i -XPOST "http://<HOST>:20108/influxdb/api/v2/write?org=<ORG>&bucket=<BUCKET>&precision=s" \
  --header "Authorization: Token <TOKEN>" \
  --data-binary "demo,source=smoke value=1 $(date +%s)"

curl -s -XPOST "http://<HOST>:20108/influxdb/api/v2/query?org=<ORG>" \
  --header "Authorization: Token <TOKEN>" \
  --header "Accept: application/csv" \
  --header 'Content-type: application/vnd.flux' \
  --data 'from(bucket:"<BUCKET>") |> range(start:-10m) |> filter(fn:(r)=> r._measurement=="demo")' | head -n 20
```

Expect recent rows with measurement `demo`.

### 5.4 Node-RED UI check

Open `http://<HOST>:20108/nodered` and confirm flows load and deploy.

### 5.5 Common issues and fixes

- Nothing on 20108: ensure Nginx is running and published; check UFW.
- 502/504 from Nginx: target service unhealthy; check `docker-compose logs`.
- MQTT connect fails: confirm 40098 open, credentials correct; check Mosquitto logs.
- InfluxDB auth errors: verify token/org/bucket; check service logs.
- Volume permission errors: verify ownership and mapping paths.

### 5.6 Performance sanity checks

```bash
docker stats --no-stream
sudo netstat -tlnp | grep -E ':(10108|20108|30108|40098)'
```

---

### Use in Cursor - validation pack

```markdown
Ask Cursor to:
- Generate a single block to curl-check /grafana, /nodered, /influxdb
- Produce a mosquitto_pub/sub test with placeholders for creds
- Emit a Flux query to validate a measurement exists and return last 5 rows
- Scan recent logs for errors: `docker-compose logs --tail 200 | rg -i "(error|fail|warn)"`
```


