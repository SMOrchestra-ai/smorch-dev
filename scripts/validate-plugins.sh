#!/usr/bin/env bash
# Validates BOTH plugins in this repo (smorch-dev + smorch-ops).
# Generalized from the pattern proven in eo-microsaas-dev (caught real bugs there).
# Exit 0 = all plugins valid. Exit 1 = block release.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

TOTAL_ERRORS=0
PLUGIN_ERRORS=0

warn() { echo "  ⚠️  $1"; PLUGIN_ERRORS=$((PLUGIN_ERRORS+1)); }
ok()   { echo "  ✅ $1"; }

validate_plugin() {
  local PLUGIN_DIR="$1"
  local NAME
  NAME="$(basename "$PLUGIN_DIR")"
  PLUGIN_ERRORS=0

  echo
  echo "━━━ Validating: $NAME ━━━"

  local MANIFEST="$PLUGIN_DIR/.claude-plugin/plugin.json"
  if [ ! -f "$MANIFEST" ]; then
    warn "plugin.json not found at $MANIFEST"
    TOTAL_ERRORS=$((TOTAL_ERRORS+PLUGIN_ERRORS))
    return
  fi

  # 1. valid JSON + required keys
  if ! python3 -c "import json; json.load(open('$MANIFEST'))" 2>/dev/null; then
    warn "plugin.json is not valid JSON"
  else
    ok "plugin.json is valid JSON"
    for key in name version description; do
      if ! python3 -c "import json; d=json.load(open('$MANIFEST')); exit(0 if '$key' in d else 1)" 2>/dev/null; then
        warn "plugin.json missing required key: $key"
      fi
    done
    # Per L-008: commands[] and skills[] arrays MUST NOT be present in plugin.json
    # (folders are auto-discovered by Claude Code). Fail if they appear.
    for forbidden in commands skills; do
      if python3 -c "import json; d=json.load(open('$MANIFEST')); exit(0 if '$forbidden' in d else 1)" 2>/dev/null; then
        warn "plugin.json MUST NOT contain '$forbidden' array (L-008 — folders auto-discovered)"
      fi
    done
  fi

  # 2. commands[] paths resolve
  local cmd_missing=0
  while IFS= read -r cmd; do
    [ -f "$PLUGIN_DIR/$cmd" ] || { warn "commands[] entry not found: $cmd"; cmd_missing=1; }
  done < <(python3 -c "import json; [print(x) for x in json.load(open('$MANIFEST')).get('commands',[])]" 2>/dev/null || true)
  [ "$cmd_missing" -eq 0 ] && ok "all commands[] paths resolve"

  # 3. skills[] paths resolve to dir with SKILL.md
  local skill_missing=0
  while IFS= read -r skill; do
    if [ ! -f "$PLUGIN_DIR/$skill/SKILL.md" ]; then
      warn "skills[] entry missing SKILL.md: $skill"
      skill_missing=1
    fi
  done < <(python3 -c "import json; [print(x) for x in json.load(open('$MANIFEST')).get('skills',[])]" 2>/dev/null || true)
  [ "$skill_missing" -eq 0 ] && ok "all skills[] paths resolve"

  # 4. command frontmatter
  local cmd_frontmatter_fail=0
  for f in "$PLUGIN_DIR"/commands/*.md; do
    [ -f "$f" ] || continue
    head -5 "$f" | grep -q "^description:" || { warn "$(basename "$f") missing 'description:' in frontmatter"; cmd_frontmatter_fail=1; }
  done
  [ "$cmd_frontmatter_fail" -eq 0 ] && ok "all command frontmatter present"

  # 5. skill frontmatter
  local skill_frontmatter_fail=0
  for f in "$PLUGIN_DIR"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    head -3 "$f" | grep -q "^---$" || { warn "$(basename "$(dirname "$f")")/SKILL.md missing YAML frontmatter fence"; skill_frontmatter_fail=1; }
  done
  [ "$skill_frontmatter_fail" -eq 0 ] && ok "all skill frontmatter present"

  # 6. dead reference scan
  local dead_refs=0
  for ref in "scripts/sync-skills.js" "scripts/validate-skills-lock.js"; do
    if [ -d "$PLUGIN_DIR/skills" ] || [ -d "$PLUGIN_DIR/commands" ]; then
      if grep -rq "$ref" "$PLUGIN_DIR/skills" "$PLUGIN_DIR/commands" 2>/dev/null; then
        warn "dead reference: $ref"
        dead_refs=1
      fi
    fi
  done
  [ "$dead_refs" -eq 0 ] && ok "no dead script references"

  TOTAL_ERRORS=$((TOTAL_ERRORS+PLUGIN_ERRORS))
  if [ "$PLUGIN_ERRORS" -eq 0 ]; then
    echo "  🟢 $NAME: PASS"
  else
    echo "  🔴 $NAME: FAIL ($PLUGIN_ERRORS issues)"
  fi
}

echo "════════════════════════════════════════════════"
echo "  smorch-dev Plugin Validation"
echo "════════════════════════════════════════════════"

validate_plugin "plugins/smorch-dev"
validate_plugin "plugins/smorch-ops"

echo
echo "════════════════════════════════════════════════"
if [ "$TOTAL_ERRORS" -eq 0 ]; then
  echo "  🟢 ALL PLUGINS VALIDATED"
  exit 0
else
  echo "  🔴 VALIDATION FAILED — $TOTAL_ERRORS total issues"
  exit 1
fi
