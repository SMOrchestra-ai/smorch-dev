#!/bin/bash
# EX-7 Multi-Machine Sync — pulls canonical content from GitHub every 30 min
# Runs on: smo-prod, smo-dev, eo-prod, smo-eo-qa, Mamoun's Mac, Lana's Mac
# Repos synced: smorch-brain (SOPs, canonical/, skills), smorch-dev (plugins/, scripts/)
set +e
WEBHOOK="https://flow.smorchestra.ai/webhook/sync-heartbeat"
HOST=$(hostname)
TS=$(date -u +%FT%TZ)
ERRS=()

if [ -n "$HOME" ] && [ -d "$HOME/Desktop" ]; then
  # Mac
  REPOS_ROOT="$HOME/Desktop/cowork-workspace/CodingProjects"
else
  # Server
  REPOS_ROOT="/root"
fi

for repo in smorch-brain smorch-dev; do
  REPO_PATH="$REPOS_ROOT/$repo"
  if [ ! -d "$REPO_PATH/.git" ]; then
    cd "$REPOS_ROOT" && git clone --depth=1 "https://github.com/SMOrchestra-ai/$repo.git" 2>&1 | tail -1 | grep -v "already exists" || ERRS+=("$repo:clone-failed")
    continue
  fi
  cd "$REPO_PATH"
  # Fetch + check divergence
  git fetch origin --quiet
  BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
  LOCAL_DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$LOCAL_DIRTY" -gt 0 ]; then
    ERRS+=("$repo:local-dirty-$LOCAL_DIRTY")
    continue  # Never overwrite local changes
  fi
  if [ "$BEHIND" -gt 0 ]; then
    git pull --ff-only origin main 2>&1 | tail -2 | grep -v "Already up to date" || ERRS+=("$repo:pull-failed")
  fi
done

SEVERITY="ok"
[ ${#ERRS[@]} -gt 0 ] && SEVERITY="warn"
PAYLOAD=$(printf '{"host":"%s","ts":"%s","severity":"%s","errors":[%s]}' \
  "$HOST" "$TS" "$SEVERITY" \
  "$(printf '"%s",' "${ERRS[@]}" | sed 's/,$//')")
curl -s --max-time 10 -X POST "$WEBHOOK" -H 'Content-Type: application/json' -d "$PAYLOAD" >/dev/null 2>&1
SYNC_LOG="${SYNC_LOG:-/var/log/sync-from-github.log}"
[ ! -w "$(dirname "$SYNC_LOG")" ] && SYNC_LOG="$HOME/.claude/logs/sync-from-github.log" && mkdir -p "$(dirname "$SYNC_LOG")"
echo "$TS $HOST $SEVERITY ${#ERRS[@]} ${ERRS[*]}" >> "$SYNC_LOG"
