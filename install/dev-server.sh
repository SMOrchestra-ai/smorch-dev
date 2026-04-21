#!/usr/bin/env bash
# Install profile: Dev server (smo-dev, smo-eo-qa).
# Ops plugin only — no gstack/superpowers/smorch-dev on servers.
# Run as root via SSH.

set -euo pipefail

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SMOrchestra Dev Server Setup                                ║"
echo "║  Installs: smorch-ops plugin + cron sync. No IDE plugins.    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

PROFILE="dev-server"
REPO_DIR="${REPO_DIR:-/root/smorch-dev}"

# Clone smorch-dev (for plugin source + scripts)
if [ ! -d "$REPO_DIR" ]; then
  git clone https://github.com/SMOrchestra-ai/smorch-dev.git "$REPO_DIR"
fi
cd "$REPO_DIR"
git pull --quiet origin main || true

# Base tools (Node, Bun, Claude Code, git, gh)
bash install/shared/install-base.sh

# Plugins (smorch-ops only)
bash install/shared/install-plugins.sh "$PROFILE"

# Patch ~/.claude/CLAUDE.md + lessons.md with L-009 push-discipline rule
bash install/shared/patch-claude-md.sh

# Cron sync
bash install/shared/install-cron-sync.sh "$REPO_DIR"

# smorch-brain clone (for canonical drift checks)
BRAIN_DIR="${BRAIN_DIR:-/root/smorch-brain}"
if [ ! -d "$BRAIN_DIR" ]; then
  git clone git@github.com:SMOrchestra-ai/smorch-brain.git "$BRAIN_DIR"
fi

# Verify
echo
echo "════════════════════════════════════════════════"
echo "  Verification"
echo "════════════════════════════════════════════════"
echo "  Node:              $(node --version 2>/dev/null || echo MISSING)"
echo "  Claude Code:       $(claude --version 2>&1 | head -1 || echo MISSING)"
echo "  smorch-ops:        $([ -d /root/.claude/plugins/smorch-ops ] && echo '✓' || echo '✗')"
echo "  smorch-dev NOT installed (ops-only profile): $([ ! -d /root/.claude/plugins/smorch-dev ] && echo '✓' || echo '✗ WARNING — should not be present')"
echo "  smorch-brain:      $([ -d $BRAIN_DIR ] && echo '✓' || echo '✗')"
echo "  Cron sync:         $(crontab -l 2>/dev/null | grep -c sync-from-github.sh) entry"
echo
echo "  Next:"
echo "  1. Verify SSH alias in smorch-brain/servers.txt includes this host"
echo "  2. From your desktop, run: /smo-drift --target $(hostname) to verify canonical match"
echo "  3. App-specific setup (ecosystem.config.js, /api/health) is per-app, not this script"
echo
