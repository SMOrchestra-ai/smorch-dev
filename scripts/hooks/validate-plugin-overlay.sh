#!/bin/bash
# SOP-33 — Validate dev_plugin overlay aligns with CLAUDE.md declaration
# Runs as pre-commit hook
set -e
[ ! -f .smorch/project.json ] && exit 0  # not a plugin-aware repo, skip
command -v jq >/dev/null || { echo "WARN: jq not installed; skipping SOP-33 check"; exit 0; }
PLUGIN=$(jq -r '.dev_plugin // "missing"' .smorch/project.json)
if [ "$PLUGIN" = "missing" ]; then
  echo "🚨 SOP-33: .smorch/project.json missing 'dev_plugin' field"
  echo "Valid: smorch-dev | eo-microsaas-dev | none | {custom-id}"
  exit 1
fi
[ "$PLUGIN" = "none" ] && exit 0
if [ -f CLAUDE.md ] && ! grep -q "This project uses the \*\*$PLUGIN\*\* plugin" CLAUDE.md; then
  echo "🚨 SOP-33: CLAUDE.md plugin declaration misaligned with .smorch/project.json"
  echo "Expected: 'This project uses the **$PLUGIN** plugin'"
  echo "Guide: smorch-brain/docs/guides/03-CUSTOMIZE-DEV-PLUGIN.md"
  exit 1
fi
exit 0
