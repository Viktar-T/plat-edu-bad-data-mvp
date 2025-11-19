# Troubleshooting Node-RED Flows Loading Issue

## Problem
Node-RED container cannot find flow files in `/flows` directory, showing:
```
⚠️  No flow files found in /flows directory
```

## Diagnosis Steps

### 1. Check if flows directory exists on the server

```bash
# SSH to your server
ssh viktar@robert108.mikrus.xyz -p10108

# Navigate to project directory
cd ~/plat-edu-bad-data-mvp

# Check if flows directory exists
ls -la node-red/flows/

# Check if flow files are present
ls -la node-red/flows/*.json
```

**Expected output**: You should see multiple `.json` files like:
- `v2.0-pv-hybrid-simulation.json`
- `v2.0-wind-vawt-simulation.json`
- `v2.0-biogas-plant-simulation.json`
- etc.

### 2. Verify the volume mount is working

```bash
# Check if the volume is mounted correctly in the container
sudo docker exec iot-node-red ls -la /flows/

# Or check the container's mount points
sudo docker inspect iot-node-red | grep -A 10 Mounts
```

### 3. Check if files are synced from git

If the `node-red/flows/` directory doesn't exist or is empty on the server:

```bash
# Make sure you're in the project directory
cd ~/plat-edu-bad-data-mvp

# Pull latest changes from git
git pull

# Verify flows directory exists
ls -la node-red/flows/

# If still missing, check git status
git status

# Check if flows directory is in .gitignore (it shouldn't be)
cat .gitignore | grep flows
```

## Solutions

### Solution 1: Ensure flows directory exists and has files

If the `node-red/flows/` directory is missing or empty:

```bash
# Make sure you have the latest code
cd ~/plat-edu-bad-data-mvp
git pull

# Verify flows directory exists
if [ ! -d "node-red/flows" ]; then
    echo "ERROR: node-red/flows directory does not exist!"
    echo "Please ensure you've pulled the latest code from git."
    exit 1
fi

# List flow files
ls -la node-red/flows/*.json

# If no files, you may need to copy them manually or check git
```

### Solution 2: Restart container with proper volume mount

```bash
# Stop the container
sudo docker-compose stop node-red

# Remove the container (this won't delete data)
sudo docker-compose rm -f node-red

# Verify flows directory exists before starting
ls -la node-red/flows/

# Start the container again
sudo docker-compose up -d node-red

# Check logs to see if flows are loading
sudo docker-compose logs -f node-red
```

### Solution 3: Manually copy flows if needed

If the flows directory exists locally but not on the server:

```bash
# On your local machine, create a tarball of flows
cd node-red
tar czf flows.tar.gz flows/
scp -P 10108 flows.tar.gz viktar@robert108.mikrus.xyz:~/plat-edu-bad-data-mvp/node-red/

# On the server, extract the flows
cd ~/plat-edu-bad-data-mvp/node-red
tar xzf flows.tar.gz
rm flows.tar.gz

# Verify files are there
ls -la flows/

# Restart Node-RED
cd ..
sudo docker-compose restart node-red
```

### Solution 4: Check container logs for detailed debugging

The updated startup script now provides more debugging information:

```bash
# View Node-RED logs
sudo docker-compose logs node-red | grep -A 20 "Checking Node-RED flows"

# Or follow logs in real-time
sudo docker-compose logs -f node-red
```

Look for these messages:
- `✓ /flows directory exists` - Good, directory is mounted
- `✗ /flows directory does not exist` - Volume mount issue
- `📂 Contents of /flows:` - Shows what files are found

## Verification

After applying fixes, verify flows are loaded:

```bash
# Check if flows.json was created/updated
ls -lh node-red/data/flows.json

# Check the size (should be > 0 if flows are loaded)
du -h node-red/data/flows.json

# View first few lines to verify content
head -20 node-red/data/flows.json

# Access Node-RED editor and verify flows are visible
# URL: http://robert108.mikrus.xyz:20108/nodered/
```

## Common Issues

### Issue 1: Flows directory not in git repository
**Symptom**: `node-red/flows/` directory doesn't exist on server after `git pull`

**Solution**: Ensure `node-red/flows/` is committed to git and not in `.gitignore`

```bash
# Check if flows are tracked by git
git ls-files node-red/flows/

# If empty, add flows to git (on local machine)
git add node-red/flows/
git commit -m "Add Node-RED flow files"
git push

# Then on server
git pull
```

### Issue 2: Volume mount path incorrect
**Symptom**: Container logs show `/flows` directory doesn't exist

**Solution**: Verify docker-compose.yml has the correct volume mount:
```yaml
volumes:
  - ./node-red/flows:/flows:ro
```

### Issue 3: Permission issues
**Symptom**: Directory exists but files can't be read

**Solution**: Fix permissions:
```bash
sudo chmod -R 755 node-red/flows/
sudo chown -R $USER:$USER node-red/flows/
```

## Next Steps

1. Run the diagnosis steps above
2. Check the container logs with the new debugging output
3. Verify the `node-red/flows/` directory exists and contains `.json` files
4. Restart the container and check logs again
5. If still not working, check the volume mount with `docker inspect`

