#!/usr/bin/env bash
# bootstrap-v1.5.sh — one-shot installer for smorch-dev v1.5.x.
# Works on macOS, Linux, and Windows (Git Bash / WSL).
# Idempotent: safe to run multiple times.
#
# What it does (auto-detect, no prompts):
#   1. Rename any pre-marketplace shadow installs (~/.claude/plugins/smorch-{dev,ops}/) → _legacy-*
#   2. Clone or pull the smorch-dev marketplace
#   3. Clone or pull the eo-microsaas-training marketplace
#   4. Refresh the plugin cache (smorch-dev v1.5.0, smorch-ops v1.1.0)
#   5. Update installed_plugins.json (version + path + SHA)
#   6. Clone or refresh gstack (~/.claude/skills/gstack)
#   7. Clone or refresh superpowers (~/.claude/skills/superpowers, via _superpowers-repo)
#   8. Run l3-health-check.sh — print final PASS / FAIL
#
# Usage:
#   bash bootstrap-v1.5.sh
#   curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/scripts/install/bootstrap-v1.5.sh | bash

set -euo pipefail

# ─── Config ───────────────────────────────────────────────────
SMORCH_DEV_REPO="https://github.com/SMOrchestra-ai/smorch-dev.git"
EO_REPO="https://github.com/smorchestraai-code/eo-microsaas-training.git"
GSTACK_REPO="https://github.com/garrytan/gstack.git"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"

PLUGINS_DIR="$HOME/.claude/plugins"
SKILLS_DIR="$HOME/.claude/skills"
MARKETS_DIR="$PLUGINS_DIR/marketplaces"
CACHE_DIR="$PLUGINS_DIR/cache"
INSTALL_RECORD="$PLUGINS_DIR/installed_plugins.json"

# ─── Pretty output ────────────────────────────────────────────
ok()   { echo "  ✓ $*"; }
warn() { echo "  ⚠ $*"; }
step() { echo ""; echo "▶ $*"; }
fail() { echo ""; echo "✗ $*" >&2; exit 1; }

# ─── Pre-checks ───────────────────────────────────────────────
command -v git    >/dev/null 2>&1 || fail "git is required but not installed"
command -v rsync  >/dev/null 2>&1 || fail "rsync is required but not installed (Git Bash on Windows: install via 'pacman -S rsync' or use WSL)"
command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || fail "python3 (or python) is required but not installed"
PYTHON=$(command -v python3 || command -v python)

mkdir -p "$PLUGINS_DIR" "$SKILLS_DIR" "$MARKETS_DIR" "$CACHE_DIR"

# ─── 1. Rename shadow direct installs ─────────────────────────
step "Step 1: rename legacy shadow direct installs (if present)"
for legacy in smorch-dev smorch-ops; do
  src="$PLUGINS_DIR/$legacy"
  if [ -d "$src" ] && [ -d "$src/.claude-plugin" ]; then
    dst="$PLUGINS_DIR/_legacy-${legacy}-direct-pre-v1.5"
    if [ -e "$dst" ]; then
      dst="$PLUGINS_DIR/_legacy-${legacy}-direct-pre-v1.5-$(date +%Y%m%d%H%M%S)"
    fi
    mv "$src" "$dst"
    ok "renamed $src → $dst"
  else
    ok "no shadow at $src"
  fi
done

# ─── 2. Marketplace: smorch-dev ───────────────────────────────
step "Step 2: smorch-dev marketplace"
if [ -d "$MARKETS_DIR/smorch-dev/.git" ]; then
  ( cd "$MARKETS_DIR/smorch-dev" && git pull origin main >/dev/null 2>&1 )
  ok "smorch-dev marketplace updated"
else
  git clone --depth 1 "$SMORCH_DEV_REPO" "$MARKETS_DIR/smorch-dev" >/dev/null 2>&1
  ok "smorch-dev marketplace cloned"
fi
SMORCH_SHA=$( cd "$MARKETS_DIR/smorch-dev" && git rev-parse HEAD )

# ─── 3. Marketplace: eo-microsaas-training ────────────────────
step "Step 3: eo-microsaas-training marketplace"
if [ -d "$MARKETS_DIR/eo-microsaas-training/.git" ]; then
  ( cd "$MARKETS_DIR/eo-microsaas-training" && git pull origin main >/dev/null 2>&1 )
  ok "eo-microsaas-training marketplace updated"
else
  git clone --depth 1 "$EO_REPO" "$MARKETS_DIR/eo-microsaas-training" >/dev/null 2>&1
  ok "eo-microsaas-training marketplace cloned"
fi
EO_SHA=$( cd "$MARKETS_DIR/eo-microsaas-training" && git rev-parse HEAD )

# ─── 4. Refresh plugin cache ──────────────────────────────────
step "Step 4: refresh plugin cache"
mkdir -p "$CACHE_DIR/smorch-dev/smorch-dev/1.5.0" "$CACHE_DIR/smorch-dev/smorch-ops/1.1.0" "$CACHE_DIR/eo-microsaas-training/eo-microsaas-dev/1.4.5"
rsync -a --delete "$MARKETS_DIR/smorch-dev/plugins/smorch-dev/" "$CACHE_DIR/smorch-dev/smorch-dev/1.5.0/"
rsync -a --delete "$MARKETS_DIR/smorch-dev/plugins/smorch-ops/" "$CACHE_DIR/smorch-dev/smorch-ops/1.1.0/"
rsync -a --delete "$MARKETS_DIR/eo-microsaas-training/eo-microsaas-dev/" "$CACHE_DIR/eo-microsaas-training/eo-microsaas-dev/1.4.5/"
chmod +x "$CACHE_DIR/smorch-dev/smorch-dev/1.5.0/scripts/"*.sh 2>/dev/null || true
ok "smorch-dev v1.5.0: $(ls "$CACHE_DIR/smorch-dev/smorch-dev/1.5.0/commands/" 2>/dev/null | wc -l | tr -d ' ') commands"
ok "smorch-ops v1.1.0: $(ls "$CACHE_DIR/smorch-dev/smorch-ops/1.1.0/commands/" 2>/dev/null | wc -l | tr -d ' ') commands"
ok "eo-microsaas-dev v1.4.5: $(ls "$CACHE_DIR/eo-microsaas-training/eo-microsaas-dev/1.4.5/commands/" 2>/dev/null | wc -l | tr -d ' ') commands"

# ─── 5. Update installed_plugins.json ─────────────────────────
step "Step 5: update install record"
if [ ! -f "$INSTALL_RECORD" ]; then
  echo '{"version":2,"plugins":{}}' > "$INSTALL_RECORD"
fi

"$PYTHON" - "$INSTALL_RECORD" "$SMORCH_SHA" "$EO_SHA" "$HOME" <<'PYEOF'
import json, datetime, sys, os

path = sys.argv[1]
smorch_sha = sys.argv[2]
eo_sha = sys.argv[3]
home = sys.argv[4]
now = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

with open(path) as f:
    d = json.load(f)
d.setdefault("version", 2)
d.setdefault("plugins", {})

def upsert(key, version, install_path, sha):
    install_path = install_path.replace("$HOME", home)
    entry = {
        "scope": "user",
        "installPath": install_path,
        "version": version,
        "installedAt": now,
        "lastUpdated": now,
        "gitCommitSha": sha,
    }
    if key in d["plugins"] and d["plugins"][key]:
        existing = d["plugins"][key][0]
        existing.update({
            "installPath": install_path,
            "version": version,
            "lastUpdated": now,
            "gitCommitSha": sha,
        })
    else:
        d["plugins"][key] = [entry]

upsert("smorch-dev@smorch-dev",
       "1.5.0", f"{home}/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0", smorch_sha)
upsert("smorch-ops@smorch-dev",
       "1.1.0", f"{home}/.claude/plugins/cache/smorch-dev/smorch-ops/1.1.0", smorch_sha)
upsert("eo-microsaas-dev@eo-microsaas-training",
       "1.4.5", f"{home}/.claude/plugins/cache/eo-microsaas-training/eo-microsaas-dev/1.4.5", eo_sha)

with open(path, "w") as f:
    json.dump(d, f, indent=2)
print("  ✓ installed_plugins.json updated (smorch-dev=1.5.0, smorch-ops=1.1.0, eo-microsaas-dev=1.4.5)")
PYEOF

# ─── 6. gstack ────────────────────────────────────────────────
step "Step 6: gstack"
if [ -d "$SKILLS_DIR/gstack/.git" ] || ([ -L "$SKILLS_DIR/gstack" ] && [ -d "$SKILLS_DIR/gstack" ]); then
  if [ -d "$SKILLS_DIR/gstack/.git" ]; then
    ( cd "$SKILLS_DIR/gstack" && git pull --ff-only origin main >/dev/null 2>&1 || true )
  fi
  ok "gstack present"
else
  git clone --single-branch --depth 1 "$GSTACK_REPO" "$SKILLS_DIR/gstack" >/dev/null 2>&1
  ok "gstack cloned (run './setup' inside ~/.claude/skills/gstack/ when bun is installed)"
fi

# ─── 7. superpowers ───────────────────────────────────────────
step "Step 7: superpowers"
SP_REPO_DIR="$SKILLS_DIR/_superpowers-repo"
SP_LINK="$SKILLS_DIR/superpowers"
if [ -d "$SP_REPO_DIR/.git" ]; then
  ( cd "$SP_REPO_DIR" && git pull --ff-only origin main >/dev/null 2>&1 || true )
  ok "superpowers repo updated"
else
  if [ -e "$SP_LINK" ] && [ ! -L "$SP_LINK" ]; then
    # Existing dir at the symlink target — back it up to keep the user's data
    mv "$SP_LINK" "${SP_LINK}.bak-$(date +%Y%m%d%H%M%S)"
  fi
  git clone --single-branch --depth 1 "$SUPERPOWERS_REPO" "$SP_REPO_DIR" >/dev/null 2>&1
  ok "superpowers cloned"
fi
# Recreate symlink (idempotent)
if [ -L "$SP_LINK" ] || [ ! -e "$SP_LINK" ]; then
  ln -sfn "$SP_REPO_DIR/skills" "$SP_LINK"
  ok "superpowers symlinked at $SP_LINK"
fi

# ─── 8. Final verify ──────────────────────────────────────────
step "Step 8: verify L3 cascade"
HEALTH="$CACHE_DIR/smorch-dev/smorch-dev/1.5.0/scripts/l3-health-check.sh"
if [ ! -x "$HEALTH" ]; then
  fail "l3-health-check.sh not found at $HEALTH"
fi

echo ""
if "$HEALTH"; then
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "  PASS — restart Claude Code, then run /smo-dev-guide l3"
  echo "════════════════════════════════════════════════════════════"
  exit 0
else
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "  FAIL — see remediation lines above"
  echo "════════════════════════════════════════════════════════════"
  exit 1
fi
