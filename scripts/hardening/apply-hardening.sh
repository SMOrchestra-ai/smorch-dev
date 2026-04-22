#!/bin/bash
# SMOrchestra server hardening — idempotent, safe to re-run
# Per SOP/plan Phase A. Applies: UFW, fail2ban, SSH, unattended-upgrades, logrotate, swap, perfctl-sentinel
set -e

HOST=$(hostname)
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "========================================"
echo "HARDENING $HOST — $DATE"
echo "========================================"

# --- Pre-flight: state inventory (read-only) ---
echo ""
echo "### PRE-STATE ###"
echo "--- UFW ---"; ufw status | head -8 || echo "ufw not installed"
echo "--- fail2ban ---"; systemctl is-active fail2ban 2>/dev/null || echo "not active"
echo "--- SSH ---"; grep -E "^(PasswordAuthentication|PermitRootLogin)" /etc/ssh/sshd_config
echo "--- unattended-upgrades ---"; dpkg -l unattended-upgrades 2>/dev/null | tail -1 || echo "not installed"
echo "--- swap ---"; free -h | grep Swap
echo "--- /etc/ld.so.preload ---"; [ -f /etc/ld.so.preload ] && echo "PRESENT" || echo "absent (clean)"

# --- UFW (idempotent) ---
echo ""
echo "### UFW ###"
if ! command -v ufw >/dev/null; then apt-get install -y -qq ufw; fi
# Allow critical ports BEFORE enable (never self-lock)
ufw allow 22/tcp >/dev/null 2>&1
ufw allow 80/tcp >/dev/null 2>&1
ufw allow 443/tcp >/dev/null 2>&1
# Tailscale — allow only if interface exists
if ip link show tailscale0 >/dev/null 2>&1; then ufw allow in on tailscale0 >/dev/null 2>&1; fi
ufw default deny incoming >/dev/null 2>&1
ufw default allow outgoing >/dev/null 2>&1
# Enable only if not active
ufw status | grep -q "^Status: active" || echo "y" | ufw enable 2>&1 | tail -1
ufw status numbered | head -15

# --- fail2ban ---
echo ""
echo "### fail2ban ###"
if ! command -v fail2ban-client >/dev/null; then
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq fail2ban
fi
cat > /etc/fail2ban/jail.local <<'JAIL'
[sshd]
enabled = true
port    = 22
maxretry = 5
findtime = 600
bantime  = 3600
JAIL
systemctl enable --now fail2ban 2>&1 | tail -2
sleep 2
fail2ban-client status sshd 2>&1 | head -10

# --- SSH hardening ---
echo ""
echo "### SSH ###"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.pre-hardening.$(date +%s) 2>/dev/null
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
# Also override any sshd_config.d drop-ins that might re-enable password auth
for f in /etc/ssh/sshd_config.d/*.conf; do
  [ -f "$f" ] && sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$f" 2>/dev/null
done
sshd -t && systemctl reload ssh
grep -E "^(PasswordAuthentication|PermitRootLogin)" /etc/ssh/sshd_config

# --- unattended-upgrades ---
echo ""
echo "### unattended-upgrades ###"
if ! dpkg -l unattended-upgrades 2>/dev/null | grep -q ^ii; then
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq unattended-upgrades
fi
# Enable automatic reboot at 2am UTC if kernel updates
mkdir -p /etc/apt/apt.conf.d
cat > /etc/apt/apt.conf.d/52unattended-reboot <<'UPG'
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
UPG
systemctl is-active unattended-upgrades

# --- logrotate for /opt/logs ---
echo ""
echo "### logrotate ###"
mkdir -p /opt/logs
cat > /etc/logrotate.d/smo-apps <<'LR'
/opt/logs/*/*.log {
  daily
  rotate 30
  compress
  delaycompress
  missingok
  notifempty
  copytruncate
}
LR
logrotate -d /etc/logrotate.d/smo-apps 2>&1 | tail -3

# --- swap ---
echo ""
echo "### swap ###"
SWAP_KB=$(free | awk '/^Swap:/ {print $2}')
if [ "$SWAP_KB" -lt 1000000 ]; then
  if [ ! -f /swapfile ]; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    grep -q "/swapfile" /etc/fstab || echo "/swapfile none swap sw 0 0" >> /etc/fstab
    echo "created 4GB /swapfile"
  fi
fi
free -h | grep Swap

# --- perfctl sentinel ---
echo ""
echo "### perfctl-sentinel ###"
mkdir -p /opt/scripts
cat > /opt/scripts/perfctl-sentinel.sh <<'SENT'
#!/bin/bash
INFECTED=0
[ -f /etc/ld.so.preload ] && INFECTED=1
[ -e /lib/libgcwrap.so ] && INFECTED=1
[ -f /etc/cron.d/perfclean ] && INFECTED=1
[ -d /root/.config/cron ] && [ "$(ls -A /root/.config/cron 2>/dev/null)" ] && INFECTED=1
if [ $INFECTED -eq 1 ]; then
  curl -s --max-time 5 -X POST "https://flow.smorchestra.ai/webhook/perfctl-alert" \
    -d "host=$(hostname)&timestamp=$(date -u +%FT%TZ)" >/dev/null 2>&1 || true
  echo "$(date -u +%FT%TZ) PERFCTL INDICATORS ON $(hostname)" >> /var/log/perfctl-sentinel.log
fi
SENT
chmod +x /opt/scripts/perfctl-sentinel.sh
# cron every 30 min (add only if not present)
(crontab -l 2>/dev/null | grep -v "perfctl-sentinel"; echo "*/30 * * * * bash /opt/scripts/perfctl-sentinel.sh") | crontab -
crontab -l | grep perfctl

# --- POST-STATE ---
echo ""
echo "### POST-STATE ###"
ufw status | head -8
systemctl is-active fail2ban
grep -E "^(PasswordAuthentication|PermitRootLogin)" /etc/ssh/sshd_config
free -h | grep Swap
ls /etc/ld.so.preload 2>&1 | head -1
echo ""
echo "### HARDENING COMPLETE on $HOST at $(date -u +%FT%TZ) ###"
