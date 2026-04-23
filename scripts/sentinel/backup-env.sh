#!/bin/bash
# .env file nightly backup (L-001 mandate)
# Tars all /opt/apps/*/.env* files, gzips, retains 30 days
set -e
DATE=$(date +%Y-%m-%d)
HOST=$(hostname)
BACKUP_ROOT="/opt/backups/env"
mkdir -p "$BACKUP_ROOT"

FILES=$(find /opt/apps /root -maxdepth 5 -name ".env" -type f 2>/dev/null; find /opt/apps /root -maxdepth 5 -name ".env.local" -type f 2>/dev/null; find /opt/apps /root -maxdepth 5 -name ".env.production" -type f 2>/dev/null)
if [ -z "$FILES" ]; then
  echo "[$(date -u +%FT%TZ)] no .env files to backup on $HOST"
  exit 0
fi

ARCHIVE="$BACKUP_ROOT/envs-${HOST}-${DATE}.tar.gz"
tar czf "$ARCHIVE" $FILES 2>&1 | tail -2
echo "[$(date -u +%FT%TZ)] env backup saved: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"

# Prune >30 days
find "$BACKUP_ROOT" -name "envs-*-*.tar.gz" -type f -mtime +30 -delete

# Heartbeat
curl -s --max-time 10 -X POST "https://flows.smorchestra.ai/webhook/env-backup-heartbeat" \
  -H 'Content-Type: application/json' \
  -d "{\"host\":\"$HOST\",\"date\":\"$DATE\",\"file_count\":$(echo "$FILES" | wc -l),\"status\":\"ok\"}" >/dev/null 2>&1 || true

exit 0
