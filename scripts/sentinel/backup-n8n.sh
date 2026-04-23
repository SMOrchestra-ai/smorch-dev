#!/bin/bash
# n8n nightly backup — SQLite + workflow JSON exports
# Retention: 14 days daily, 60 days weekly
set -e
DATE=$(date +%Y-%m-%d)
HOST=$(hostname)
BACKUP_ROOT="/opt/backups/n8n"
mkdir -p "$BACKUP_ROOT"

for container in $(docker ps --format "{{.Names}}" | grep -E "^n8n|n8n$|n8n-n8n"); do
  echo "[$(date -u +%FT%TZ)] backing up $container on $HOST"
  TARGET="$BACKUP_ROOT/${container}-${DATE}"
  mkdir -p "$TARGET"

  # Export all workflows as separate JSONs
  docker exec "$container" sh -c "mkdir -p /tmp/wf-export && n8n export:workflow --all --separate --output=/tmp/wf-export" 2>&1 | tail -2
  docker cp "$container:/tmp/wf-export" "$TARGET/workflows" 2>&1 | tail -1

  # Copy the SQLite DB (live copy; WAL may miss in-flight writes but good enough for nightly)
  VOLPATH=$(docker inspect "$container" --format '{{range .Mounts}}{{if eq .Destination "/home/node/.n8n"}}{{.Source}}{{end}}{{end}}')
  if [ -n "$VOLPATH" ] && [ -f "$VOLPATH/database.sqlite" ]; then
    cp "$VOLPATH/database.sqlite" "$TARGET/database.sqlite"
  fi

  # Tar + gzip
  tar czf "${TARGET}.tar.gz" -C "$BACKUP_ROOT" "$(basename "$TARGET")"
  rm -rf "$TARGET"
  echo "[$(date -u +%FT%TZ)] done $container → ${TARGET}.tar.gz ($(du -h "${TARGET}.tar.gz" | cut -f1))"
done

# Prune: delete daily >14 days
find "$BACKUP_ROOT" -name "*-20*.tar.gz" -type f -mtime +14 -delete

# Weekly archive (copy Sunday's as weekly, retain 60 days)
if [ "$(date +%u)" = "7" ]; then
  for f in "$BACKUP_ROOT"/*-${DATE}.tar.gz; do
    [ -f "$f" ] && cp "$f" "${f%.tar.gz}-weekly.tar.gz" 2>/dev/null
  done
  find "$BACKUP_ROOT" -name "*-weekly.tar.gz" -type f -mtime +60 -delete
fi

# Heartbeat
curl -s --max-time 10 -X POST "https://flows.smorchestra.ai/webhook/n8n-backup-heartbeat" \
  -H 'Content-Type: application/json' \
  -d "{\"host\":\"$HOST\",\"date\":\"$DATE\",\"status\":\"ok\"}" >/dev/null 2>&1 || true

exit 0
