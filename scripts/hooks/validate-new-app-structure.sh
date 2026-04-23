#!/bin/bash
# SOP-31 — Validate new app structure before first non-scaffold commit
# Install: git config --global core.hooksPath ~/Desktop/repo-workspace/smo/smorch-dev/scripts/hooks
# Runs as pre-commit hook
set -e
COMMIT_COUNT=$(git rev-list HEAD --count 2>/dev/null || echo 0)
# Only enforce on repos with <5 commits OR when CLAUDE.md is absent (new repo)
if [ "$COMMIT_COUNT" -ge 5 ] && [ -f CLAUDE.md ]; then
  exit 0
fi
MISSING=()
[ ! -f CLAUDE.md ] && MISSING+=("CLAUDE.md")
[ ! -f README.md ] && MISSING+=("README.md")
[ ! -f architecture/brd.md ] && MISSING+=("architecture/brd.md")
[ ! -f .smorch/project.json ] && MISSING+=(".smorch/project.json")
[ ! -f .smorch/README.md ] && MISSING+=(".smorch/README.md")
[ ! -f .claude/lessons.md ] && MISSING+=(".claude/lessons.md")
[ ! -f .claude/settings.json ] && MISSING+=(".claude/settings.json")
[ ! -f .env.example ] && MISSING+=(".env.example")
[ ! -f .gitignore ] && MISSING+=(".gitignore")
for d in handovers qa-scores qa incidents deploys retros; do
  [ ! -d "docs/$d" ] && MISSING+=("docs/$d/")
done
[ ! -d tests ] && MISSING+=("tests/")
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "🚨 SOP-31 NEW APP SCAFFOLD MISSING:"
  printf '  - %s\n' "${MISSING[@]}"
  echo ""
  echo "Copy templates from smorch-brain/canonical/claude-md/ and fix before committing."
  echo "Guide: smorch-brain/docs/guides/01-START-NEW-APP.md"
  exit 1
fi
exit 0
