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

install_plugin_from_repo() {
  local NAME="$1"
  local SRC="$SRC_REPO/plugins/$NAME"
  local DST="$CLAUDE_PLUGINS_DIR/$NAME"
  [ -d "$SRC" ] || { echo "  ✗ plugin source missing: $SRC"; exit 1; }
  rm -rf "$DST"
  cp -R "$SRC" "$DST"
  log "installed: $NAME → $DST"
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

case "$PROFILE" in
  eng-desktop|qa-machine)
    install_plugin_from_repo "smorch-dev"
    install_plugin_from_repo "smorch-ops"
    install_upstream_plugin  "gstack" "https://github.com/garrytan/gstack.git"
    install_upstream_plugin  "superpowers" "https://github.com/obra/superpowers.git"
    ;;
  dev-server|prod-server)
    install_plugin_from_repo "smorch-ops"
    # no gstack/superpowers/smorch-dev on servers — ops-only surface
    ;;
  *)
    echo "  ✗ unknown profile: $PROFILE" >&2
    exit 1
    ;;
esac

log "plugin install complete for profile=$PROFILE"
