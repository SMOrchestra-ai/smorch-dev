#!/usr/bin/env bash
# Install profile: Prod server (eo-prod, smo-prod).
# Ops plugin + stricter cron + security-hardener verification.
# Run as root via SSH.

set -euo pipefail

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SMOrchestra Production Server Setup                         ║"
echo "║  Installs: smorch-ops + cron + security-hardener baseline    ║"
echo "║  NON-NEGOTIABLE: UFW, fail2ban, SSH key-only, unattended     ║"
echo "╚══════════════════════════════════════════════════════════════╝"

PROFILE="prod-server"
REPO_DIR="${REPO_DIR:-/root/smorch-dev}"

if [ ! -d "$REPO_DIR" ]; then
  git clone https://github.com/SMOrchestra-ai/smorch-dev.git "$REPO_DIR"
fi
cd "$REPO_DIR"
git pull --quiet origin main || true

# Base tools
bash install/shared/install-base.sh

# Plugins (smorch-ops only)
bash install/shared/install-plugins.sh "$PROFILE"

# Cron sync
bash install/shared/install-cron-sync.sh "$REPO_DIR"

# smorch-brain clone
BRAIN_DIR="${BRAIN_DIR:-/root/smorch-brain}"
if [ ! -d "$BRAIN_DIR" ]; then
  git clone git@github.com:SMOrchestra-ai/smorch-brain.git "$BRAIN_DIR"
fi

# Apply security-hardener baseline (post-perfctl non-negotiables)
echo
echo "→ Applying security-hardener baseline…"
HARDENER="$REPO_DIR/plugins/smorch-ops/skills/security-hardener"
if [ -f "$HARDENER/scripts/apply-baseline.sh" ]; then
  bash "$HARDENER/scripts/apply-baseline.sh"
else
  echo "  ⚠️ apply-baseline.sh not yet implemented — manual baseline required:"
  echo "     1. ufw: deny in, allow 22/80/443/tailscale0"
  echo "     2. fail2ban on sshd (maxretry=5 bantime=3600)"
  echo "     3. /etc/ssh/sshd_config: PasswordAuthentication no"
  echo "     4. apt install unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades"
fi

# Verify
echo
echo "════════════════════════════════════════════════"
echo "  Verification"
echo "════════════════════════════════════════════════"
echo "  Node:              $(node --version 2>/dev/null || echo MISSING)"
echo "  Claude Code:       $(claude --version 2>&1 | head -1 || echo MISSING)"
echo "  smorch-ops:        $([ -d /root/.claude/plugins/smorch-ops ] && echo '✓' || echo '✗')"
echo "  smorch-brain:      $([ -d $BRAIN_DIR ] && echo '✓' || echo '✗')"
echo "  Cron sync:         $(crontab -l 2>/dev/null | grep -c sync-from-github.sh) entry"
echo
echo "  Security posture:"
echo "  UFW status:        $(ufw status 2>/dev/null | head -1 || echo 'NOT INSTALLED')"
echo "  fail2ban:          $(systemctl is-active fail2ban 2>/dev/null || echo 'NOT INSTALLED')"
echo "  SSH password auth: $(grep '^PasswordAuthentication' /etc/ssh/sshd_config 2>/dev/null || echo 'default (likely yes — HARDEN NOW)')"
echo "  Unattended upg:    $([ -f /etc/apt/apt.conf.d/20auto-upgrades ] && echo 'configured' || echo 'NOT configured')"
echo
echo "  Next:"
echo "  1. From desktop: /smo-health --posture-only --target $(hostname)"
echo "     (expect all 8 non-negotiables green)"
echo "  2. Verify ecosystem.config.js + /api/health present for each app on this server"
echo "  3. Register in smorch-brain/servers.txt if not already"
echo
