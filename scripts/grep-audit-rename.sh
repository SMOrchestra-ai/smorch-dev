#!/usr/bin/env bash
# One-shot: grep every machine + every file for the literal string "smorch-dev"
# (referring to the OLD plugin at smorch-brain/plugins/smorch-dev/).
# Prints every match. Used BEFORE executing the rename to smorch-builders.
#
# Per plan ADR-003: the rename blast radius was underestimated in the first review.
# This script is the safety net.

set -euo pipefail

echo "════════════════════════════════════════════════"
echo "  GREP AUDIT — 'smorch-dev' string occurrences"
echo "  Plan ADR-003 — rename to smorch-builders"
echo "════════════════════════════════════════════════"

# Scope: files + paths where the old plugin name might appear
TARGETS=(
  "$HOME/Desktop/cowork-workspace/CodingProjects/NewDesktop/scripts/setup.sh"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/servers.txt"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/sync-plugins.sh"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/hooks"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/profiles"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/scripts"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/canonical"
  "$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/final-sop"
  "$HOME/Desktop/cowork-workspace/smorch-dist"
  "$HOME/.claude"
)

# Also check remote machines via ~/smorch-brain/servers.txt
REMOTE_FILES=(
  "~/.claude/settings.json"
  "~/.claude/CLAUDE.md"
)

echo
echo "━━━ Local scan ━━━"
for path in "${TARGETS[@]}"; do
  if [ -e "$path" ]; then
    # Use grep -rnI to recursively search text files, showing line numbers
    echo
    echo "— $path —"
    grep -rnI "smorch-dev" "$path" 2>/dev/null | head -50 || echo "  (no matches)"
  fi
done

echo
echo "━━━ Remote scan (via SSH from servers.txt) ━━━"
SERVERS_FILE="$HOME/Desktop/cowork-workspace/CodingProjects/smorch-brain/servers.txt"
if [ -f "$SERVERS_FILE" ]; then
  while IFS= read -r line; do
    # Format: user@host:profile
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue
    HOST="${line%%:*}"
    echo
    echo "— $HOST —"
    for f in "${REMOTE_FILES[@]}"; do
      echo "  $f:"
      ssh -o ConnectTimeout=5 -o BatchMode=yes "$HOST" "grep -n 'smorch-dev' $f 2>/dev/null || echo '  (no matches)'" 2>/dev/null || echo "  (ssh failed — $HOST may be unreachable)"
    done
  done < "$SERVERS_FILE"
else
  echo "servers.txt not found — skipping remote scan"
fi

echo
echo "════════════════════════════════════════════════"
echo "  Audit complete."
echo "  Review matches above. Any ambiguous? Stop."
echo "  Only proceed with rename when you can explain EVERY match."
echo "════════════════════════════════════════════════"
