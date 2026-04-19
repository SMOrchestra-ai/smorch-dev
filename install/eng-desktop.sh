#!/usr/bin/env bash
# Install profile: Engineering desktop (Mamoun's Mac + future hires, Mac/Linux).
# Full toolkit: smorch-dev + smorch-ops + gstack + superpowers + cron sync.

set -euo pipefail

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SMOrchestra Engineering Desktop Setup                       ║"
echo "║  Installs: base tools + smorch-dev + smorch-ops + upstream   ║"
echo "╚══════════════════════════════════════════════════════════════╝"

PROFILE="eng-desktop"
REPO_DIR="${REPO_DIR:-$HOME/Desktop/cowork-workspace/CodingProjects/smorch-dev}"

# If not already cloned, clone into CodingProjects
if [ ! -d "$REPO_DIR" ]; then
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone https://github.com/SMOrchestra-ai/smorch-dev.git "$REPO_DIR"
fi

cd "$REPO_DIR"
git pull --quiet origin main || true

# Phase 1 — base tools
bash install/shared/install-base.sh

# Phase 2 — plugins
bash install/shared/install-plugins.sh "$PROFILE"

# Phase 3 — cron sync
bash install/shared/install-cron-sync.sh "$REPO_DIR"

# Phase 4 — smorch-brain clone (for canonical drift checks + shared lessons)
BRAIN_DIR="$HOME/smorch-brain"
if [ ! -d "$BRAIN_DIR" ]; then
  git clone git@github.com:SMOrchestra-ai/smorch-brain.git "$BRAIN_DIR"
fi

# Phase 5 — verify
echo
echo "════════════════════════════════════════════════"
echo "  Verification"
echo "════════════════════════════════════════════════"
echo "  Node:              $(node --version 2>/dev/null || echo MISSING)"
echo "  Bun:               $(bun --version 2>/dev/null || echo 'MISSING — re-source shell profile')"
echo "  Claude Code:       $(claude --version 2>&1 | head -1 || echo MISSING)"
echo "  gh:                $(gh --version 2>&1 | head -1 | awk '{print $3}' || echo MISSING)"
echo "  smorch-dev plugin: $([ -d $HOME/.claude/plugins/smorch-dev ] && echo '✓' || echo '✗')"
echo "  smorch-ops plugin: $([ -d $HOME/.claude/plugins/smorch-ops ] && echo '✓' || echo '✗')"
echo "  gstack:            $([ -d $HOME/.claude/skills/gstack ] && echo '✓' || echo '✗')"
echo "  superpowers:       $([ -d $HOME/.claude/skills/superpowers ] && echo '✓' || echo '✗')"
echo "  smorch-brain:      $([ -d $BRAIN_DIR ] && echo '✓' || echo '✗')"
echo "  Cron sync:         $(crontab -l 2>/dev/null | grep -c sync-from-github.sh) entry"
echo
echo "  Next:"
echo "  1. cd to any project"
echo "  2. Run: claude"
echo "  3. Type /smo to see autocomplete (17 commands should appear)"
echo "  4. Run /smo-health to verify server connectivity"
echo
