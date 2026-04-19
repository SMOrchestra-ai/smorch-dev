#!/usr/bin/env bash
# Shared: install base tools (Node 22, Bun, Claude Code, git, gh).
# Sourced by eng-desktop.sh, dev-server.sh, prod-server.sh.
# Windows equivalent is in qa-machine.ps1 (PowerShell, separate logic).

set -euo pipefail

log()  { echo "  [install-base] $1"; }
fail() { echo "  ✗ [install-base] $1" >&2; exit 1; }

OS="$(uname -s)"
case "$OS" in
  Darwin) PKG="brew" ;;
  Linux)  PKG="apt"  ;;
  *)      fail "unsupported OS: $OS" ;;
esac

# Package manager
if [ "$PKG" = "brew" ] && ! command -v brew >/dev/null 2>&1; then
  log "installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Node 22
if ! command -v node >/dev/null 2>&1 || ! node --version | grep -q "v22"; then
  log "installing Node 22…"
  if [ "$PKG" = "brew" ]; then
    brew install node@22 && brew link --overwrite node@22 2>/dev/null || true
  else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
  fi
fi
node --version | grep -q "v22" || fail "Node 22 install failed"
log "Node $(node --version)"

# Bun
if ! command -v bun >/dev/null 2>&1; then
  log "installing Bun…"
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
command -v bun >/dev/null 2>&1 || fail "Bun install failed (add ~/.bun/bin to PATH)"
log "Bun $(bun --version)"

# Claude Code
if ! command -v claude >/dev/null 2>&1; then
  log "installing Claude Code…"
  npm install -g @anthropic-ai/claude-code
fi
command -v claude >/dev/null 2>&1 || fail "Claude Code install failed"
log "Claude Code $(claude --version 2>&1 | head -1)"

# git
command -v git >/dev/null 2>&1 || fail "git missing (install first)"
log "git $(git --version | awk '{print $3}')"

# gh (GitHub CLI)
if ! command -v gh >/dev/null 2>&1; then
  log "installing GitHub CLI…"
  if [ "$PKG" = "brew" ]; then
    brew install gh
  else
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update && sudo apt install -y gh
  fi
fi
log "gh $(gh --version 2>&1 | head -1 | awk '{print $3}')"

log "base tools ready"
