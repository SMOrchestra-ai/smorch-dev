#!/usr/bin/env bash
# Shared: install Claude Code plugins (smorch-dev, smorch-ops, gstack, superpowers).
# Profile argument determines which plugins get installed.
# Usage: bash install-plugins.sh {eng-desktop|qa-machine|dev-server|prod-server}

set -euo pipefail

PROFILE="${1:?missing profile argument}"
SRC_REPO="$(cd "$(dirname "$0")/../.." && pwd)"  # smorch-dev repo root
CLAUDE_PLUGINS_DIR="$HOME/.claude/plugins"

log() { echo "  [install-plugins] $1"; }

mkdir -p "$CLAUDE_PLUGINS_DIR"

install_plugin_via_marketplace() {
  local NAME="$1"
  # Uses Claude Code's marketplace CLI — the proper registration path.
  # Marketplace was added once via: claude plugin marketplace add SMOrchestra-ai/smorch-dev
  claude plugin install "$NAME@smorch-dev" 2>&1 | tail -1
  log "installed: $NAME via marketplace"
}

ensure_marketplace_added() {
  if ! claude plugin marketplace list 2>/dev/null | grep -q "^smorch-dev"; then
    log "adding smorch-dev marketplace (one-time)"
    claude plugin marketplace add SMOrchestra-ai/smorch-dev 2>&1 | tail -1
  else
    log "marketplace already added — refreshing"
    claude plugin marketplace update smorch-dev 2>&1 | tail -1
  fi
}

install_upstream_plugin() {
  local NAME="$1"
  local REPO="$2"
  local DST="$HOME/.claude/skills/$NAME"  # upstream skills go to skills/ not plugins/
  if [ ! -d "$DST" ]; then
    log "cloning $NAME from $REPO"
    git clone --depth 1 "$REPO" "$DST"
  else
    log "updating $NAME (git pull)"
    (cd "$DST" && git pull --quiet origin main 2>&1 | head -3) || true
  fi
}

ensure_marketplace_added

case "$PROFILE" in
  eng-desktop|qa-machine)
    install_plugin_via_marketplace "smorch-dev"
    install_plugin_via_marketplace "smorch-ops"
    install_upstream_plugin  "gstack" "https://github.com/garrytan/gstack.git"
    install_upstream_plugin  "superpowers" "https://github.com/obra/superpowers.git"
    ;;
  dev-server|prod-server)
    install_plugin_via_marketplace "smorch-ops"
    # no gstack/superpowers/smorch-dev on servers — ops-only surface
    ;;
  *)
    echo "  ✗ unknown profile: $PROFILE" >&2
    exit 1
    ;;
esac

log "plugin install complete for profile=$PROFILE"
