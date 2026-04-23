#!/bin/bash
# Perfctl sentinel — post-Apr-18 incident detection tripwire
# Runs every 30 min via cron. Posts alert on any IOC match.
set -e

WEBHOOK="https://flow.smorchestra.ai/webhook/perfctl-alert"
HOST=$(hostname)
TIMESTAMP=$(date -u +%FT%TZ)
FINDINGS=""
INFECTED=0

# Known perfctl IOCs
[ -f /etc/ld.so.preload ] && FINDINGS="$FINDINGS ld.so.preload-exists" && INFECTED=1
[ -e /lib/libgcwrap.so ] && FINDINGS="$FINDINGS libgcwrap.so" && INFECTED=1
[ -e /usr/lib/libgcwrap.so ] && FINDINGS="$FINDINGS usr-libgcwrap.so" && INFECTED=1
[ -f /etc/cron.d/perfclean ] && FINDINGS="$FINDINGS perfclean-cron" && INFECTED=1
[ -d /root/.config/cron ] && [ -n "$(ls -A /root/.config/cron 2>/dev/null)" ] && FINDINGS="$FINDINGS root-config-cron" && INFECTED=1
[ -d /tmp/.perf.c ] && FINDINGS="$FINDINGS tmp-perf-c" && INFECTED=1
[ -d /tmp/.xdiag ] && FINDINGS="$FINDINGS tmp-xdiag" && INFECTED=1
pgrep -f 'perfcc|xmrig|kdevtmpfsi' >/dev/null 2>&1 && FINDINGS="$FINDINGS suspicious-process" && INFECTED=1

if [ $INFECTED -eq 1 ]; then
  logger -t perfctl-sentinel "ALERT: $HOST findings=$FINDINGS"
  curl -s --max-time 10 -X POST "$WEBHOOK" \
    -H 'Content-Type: application/json' \
    -d "{\"host\":\"$HOST\",\"timestamp\":\"$TIMESTAMP\",\"findings\":\"$FINDINGS\",\"severity\":\"CRITICAL\"}" || true
  exit 1
fi

# Heartbeat on clean run (so dashboard can show last-check-per-host)
curl -s --max-time 5 -X POST "${WEBHOOK%/*}/perfctl-heartbeat" \
  -H 'Content-Type: application/json' \
  -d "{\"host\":\"$HOST\",\"timestamp\":\"$TIMESTAMP\",\"status\":\"clean\"}" >/dev/null 2>&1 || true
exit 0
