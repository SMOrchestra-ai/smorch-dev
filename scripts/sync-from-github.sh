#!/usr/bin/env bash
# Cron-invoked: idempotent pull + plugin install + hash verify.
# Runs every 30 min (installed by install-cron-sync.sh).
# Logs to ~/.claude/sync.log.
#
# Exit 0 = machine in sync | Exit non-zero = drift detected, Telegram alert sent

set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/smorch-dev}"
[ ! -d "$REPO_DIR" ] && REPO_DIR="$HOME/Desktop/cowork-workspace/CodingProjects/smorch-dev"
[ ! -d "$REPO_DIR" ] && REPO_DIR="/root/smorch-dev"
[ ! -d "$REPO_DIR" ] && { echo "✗ smorch-dev not found"; exit 1; }

PROFILE_FILE="$REPO_DIR/.sync-profile"
[ -f "$PROFILE_FILE" ] || echo "eng-desktop" > "$PROFILE_FILE"
PROFILE="$(cat "$PROFILE_FILE")"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "[$TIMESTAMP] sync start (profile=$PROFILE)"

# 1. Pull latest from GitHub
cd "$REPO_DIR"
LOCAL_HEAD_BEFORE="$(git rev-parse HEAD)"
git fetch --quiet origin main
REMOTE_HEAD="$(git rev-parse origin/main)"

if [ "$LOCAL_HEAD_BEFORE" = "$REMOTE_HEAD" ]; then
  echo "[$TIMESTAMP] already up to date"
  exit 0
fi

git pull --quiet --ff-only origin main || {
  echo "[$TIMESTAMP] ✗ git pull failed (non-ff or conflict)"
  # Telegram alert via shared script if present
  if [ -f "$HOME/smorch-brain/scripts/telegram-notify.sh" ]; then
    bash "$HOME/smorch-brain/scripts/telegram-notify.sh" "⚠️ smorch-dev sync failed on $(hostname): git pull non-ff"
  fi
  exit 1
}

LOCAL_HEAD_AFTER="$(git rev-parse HEAD)"
echo "[$TIMESTAMP] pulled $LOCAL_HEAD_BEFORE → $LOCAL_HEAD_AFTER"

# 2. Re-install plugins (idempotent)
bash install/shared/install-plugins.sh "$PROFILE"

# 3. Validate — if CI-quality script is here, run it
if [ -x scripts/validate-plugins.sh ]; then
  if ! bash scripts/validate-plugins.sh > /tmp/smorch-validate.log 2>&1; then
    echo "[$TIMESTAMP] ✗ validate-plugins.sh failed"
    if [ -f "$HOME/smorch-brain/scripts/telegram-notify.sh" ]; then
      bash "$HOME/smorch-brain/scripts/telegram-notify.sh" "⚠️ smorch-dev validate failed on $(hostname) after pull — see /tmp/smorch-validate.log"
    fi
    exit 1
  fi
fi

# 4. Hash verify against canonical (if manifest present)
BRAIN_MANIFEST="$HOME/smorch-brain/canonical/smorch-dev-manifest.json"
if [ -f "$BRAIN_MANIFEST" ]; then
  # Expected hashes from canonical
  EXPECTED_DEV_VERSION="$(python3 -c "import json; print(json.load(open('$BRAIN_MANIFEST')).get('smorch-dev_version','unknown'))" 2>/dev/null || echo "unknown")"
  ACTUAL_DEV_VERSION="$(python3 -c "import json; print(json.load(open('plugins/smorch-dev/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "unknown")"
  if [ "$EXPECTED_DEV_VERSION" != "unknown" ] && [ "$EXPECTED_DEV_VERSION" != "$ACTUAL_DEV_VERSION" ]; then
    echo "[$TIMESTAMP] ⚠️ smorch-dev version drift: expected $EXPECTED_DEV_VERSION, actual $ACTUAL_DEV_VERSION"
  fi
fi

echo "[$TIMESTAMP] sync complete"
exit 0
