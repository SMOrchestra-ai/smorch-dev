#!/bin/bash
# App drift detector — checks every /opt/apps/{repo} git HEAD vs GitHub main
# Runs on the central hub (smo-prod + eo-prod).
set +e
WEBHOOK="https://flow.smorchestra.ai/webhook/app-drift"
HOST=$(hostname)
TS=$(date -u +%FT%TZ)
DRIFT=()

for repo_path in /opt/apps/*/; do
  [ -d "$repo_path/.git" ] || continue
  repo=$(basename "$repo_path")
  cd "$repo_path" || continue
  git fetch origin --quiet 2>/dev/null
  LOCAL=$(git rev-parse HEAD 2>/dev/null)
  REMOTE=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
  [ -z "$LOCAL" ] || [ -z "$REMOTE" ] && continue
  if [ "$LOCAL" != "$REMOTE" ]; then
    BEHIND=$(git rev-list --count "$LOCAL..$REMOTE" 2>/dev/null || echo 0)
    DRIFT+=("$repo:behind-$BEHIND")
  fi
  # Uncommitted changes on prod = big red flag
  [ -n "$(git status --porcelain 2>/dev/null)" ] && DRIFT+=("$repo:local-modified")
  # .env.local must exist (per L-001)
  [ ! -f .env.local ] && [ ! -f .env ] && DRIFT+=("$repo:no-env")
done

SEVERITY="info"
[ ${#DRIFT[@]} -gt 0 ] && SEVERITY="warn"

PAYLOAD=$(printf '{"host":"%s","ts":"%s","severity":"%s","drift":[%s]}' \
  "$HOST" "$TS" "$SEVERITY" \
  "$(printf '"%s",' "${DRIFT[@]}" | sed 's/,$//')")
curl -s --max-time 10 -X POST "$WEBHOOK" -H 'Content-Type: application/json' -d "$PAYLOAD" >/dev/null 2>&1
echo "$TS $HOST $SEVERITY ${#DRIFT[@]} ${DRIFT[*]}" >> /var/log/app-drift.log
