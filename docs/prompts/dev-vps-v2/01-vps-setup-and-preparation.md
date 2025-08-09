## Step 1 – VPS Setup and Preparation (Mikrus 3.0, Ubuntu 24.04)

This step prepares your Windows environment, grants SSH access to your Mikrus VPS, applies basic hardening, and installs Docker.

### What you need
- Mikrus 3.0 VPS credentials (see the [Mikrus Wiki](https://wiki.mikr.us/))
- Windows 10/11 with PowerShell
- SSH key pair (you will create one if needed)

## Step 1 – Validate local environment (Windows)

```powershell
$PSVersionTable.PSVersion
ssh -V
curl --version
```
Expected:
- PowerShell version 5.1+ or 7+
- `OpenSSH_for_Windows` present
- `curl` available

If SSH is missing, enable it via Windows Optional Features.

## Step 2 – Generate an SSH key (Windows)

```powershell
$KeyPath = "$HOME/.ssh/id_ed25519"
if (!(Test-Path $KeyPath)) { ssh-keygen -t ed25519 -C "<YOUR_EMAIL_OR_NOTE>" -f $KeyPath -N "" }
Get-Content "$KeyPath.pub"
```
Expected: The public key contents (starts with `ssh-ed25519`). Keep it handy.

## Step 3 – First login to Mikrus VPS

Obtain your hostname/IP and username from Mikrus.

```powershell
ssh -o StrictHostKeyChecking=no <MIKRUS_USER>@<MIKRUS_HOST>
```
Expected: You are connected to the VPS shell.

## Step 4 – Create a non-root sudo user (VPS)

```bash
sudo adduser --disabled-password --gecos "" <APP_USER>
echo "<APP_USER> ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/<APP_USER> >/dev/null
sudo mkdir -p /home/<APP_USER>/.ssh
sudo chmod 700 /home/<APP_USER>/.ssh
# Paste your Windows public key into authorized_keys:
cat << 'EOF' | sudo tee /home/<APP_USER>/.ssh/authorized_keys >/dev/null
<PASTE_YOUR_SSH_PUBLIC_KEY_HERE>
EOF
sudo chmod 600 /home/<APP_USER>/.ssh/authorized_keys
sudo chown -R <APP_USER>:<APP_USER> /home/<APP_USER>/.ssh
```
Expected: New user with passwordless sudo and your SSH key installed.

## Step 5 – Basic system prep (VPS)

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo timedatectl set-timezone UTC
sudo hostnamectl set-hostname <HOSTNAME>
```
Expected: System updated; timezone and hostname set.

## Step 6 – SSH hardening baseline (VPS)

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart ssh
```
Expected: Password login disabled; root SSH disabled. Confirm you can login as `<APP_USER>` before ending your current session.

## Step 7 – Firewall (UFW) minimal allow-list (VPS)

```bash
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
# Allow application ports (adjust later as needed)
sudo ufw allow 1883/tcp   # Mosquitto
sudo ufw allow 1880/tcp   # Node-RED
sudo ufw allow 8086/tcp   # InfluxDB
sudo ufw allow 3000/tcp   # Grafana
sudo ufw --force enable
sudo ufw status numbered
```
Expected: UFW enabled with listed rules.

## Step 8 – Install Docker Engine and Compose plugin (VPS)

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker <APP_USER>
docker --version && docker compose version || true
```
Expected: Docker Engine installed; Compose plugin available. Re-login as `<APP_USER>` for group membership to take effect.

## Step 9 – Validation checks (VPS)

```bash
# Test Docker without sudo if you re-logged in
docker run --rm hello-world || true
docker info | grep -E "^ Server Version|Cgroup Driver" || true
```
Expected: `hello-world` prints the welcome message; Docker info shows versions.

### Use in Cursor
```
You are a deployment assistant. Verify Step 1 completion:
- Confirm SSH key exists on Windows and key-based login works for <APP_USER>.
- Confirm UFW is enabled and only necessary ports are open.
- Confirm Docker Engine and Compose plugin are installed and usable without sudo.
Output a short PASS/FAIL checklist with remediation tips.
``` 