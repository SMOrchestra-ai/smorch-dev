#!/bin/bash
# Infra drift detector — server state vs canonical baseline
# Runs hourly. POSTs findings to n8n webhook.
set +e
WEBHOOK="https://flow.smorchestra.ai/webhook/infra-drift"
HOST=$(hostname)
TS=$(date -u +%FT%TZ)
DRIFT=()

# Disk usage >85% = drift
DISK=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
[ "$DISK" -gt 85 ] && DRIFT+=("disk:${DISK}%")

# Services expected up
for svc in docker fail2ban; do
  systemctl is-active --quiet $svc || DRIFT+=("service-down:$svc")
done
# nginx may be absent on smo-eo-qa (caddy replaces)
[ "$HOST" != "smo-eo-qa" ] && (systemctl is-active --quiet nginx || DRIFT+=("service-down:nginx"))

# UFW must be active
ufw status 2>/dev/null | grep -q "Status: active" || DRIFT+=("ufw-inactive")

# Perfctl IOCs
[ -f /etc/ld.so.preload ] && DRIFT+=("perfctl-ld-so")
[ -e /lib/libgcwrap.so ] && DRIFT+=("perfctl-libgcwrap")

# Swap present
swapon --show=SIZE --noheadings --bytes | head -1 | grep -qv '^$' || DRIFT+=("no-swap")

# SSH password auth must be off
grep -qE "^PasswordAuthentication no" /etc/ssh/sshd_config || DRIFT+=("ssh-passwd-auth")

# unattended-upgrades installed
dpkg -l unattended-upgrades 2>/dev/null | grep -q "^ii" || DRIFT+=("no-unattended-upgrades")

# Docker running containers count (for the 3 hosts that should have n8n)
if [ "$HOST" = "smo-prod" ] || [ "$HOST" = "smo-dev" ] || [ "$HOST" = "eo-prod" ] || [ "$HOST" = "smo-eo-qa" ]; then
  docker ps --format "{{.Names}}" 2>/dev/null | grep -q n8n || DRIFT+=("no-n8n-container")
fi

SEVERITY="info"
[ ${#DRIFT[@]} -gt 0 ] && SEVERITY="warn"
[ ${#DRIFT[@]} -gt 3 ] && SEVERITY="critical"

PAYLOAD=$(printf '{"host":"%s","ts":"%s","severity":"%s","drift":[%s]}' \
  "$HOST" "$TS" "$SEVERITY" \
  "$(printf '"%s",' "${DRIFT[@]}" | sed 's/,$//')")

curl -s --max-time 10 -X POST "$WEBHOOK" -H 'Content-Type: application/json' -d "$PAYLOAD" >/dev/null 2>&1
echo "$TS $HOST $SEVERITY ${#DRIFT[@]} ${DRIFT[*]}" >> /var/log/infra-drift.log
[ "$SEVERITY" = "critical" ] && exit 1 || exit 0
