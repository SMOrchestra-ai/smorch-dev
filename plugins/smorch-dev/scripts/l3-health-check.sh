#!/usr/bin/env bash
# l3-health-check.sh — verify the L3 cascade (gstack + superpowers) is reachable.
# Used by smorch-dev SessionStart hook and smorch-ops /smo-skill-sync --verify.
#
# Two modes (avoid stuck-out-of-the-box while still killing drift):
#   default = WARN: print status, exit 0 (session continues with note)
#   strict  = REFUSE: print status + remediation, exit 1
#
# Strict triggers:
#   --strict flag, OR
#   $SMORCH_STRICT_L3 = 1 (set on servers + CI), OR
#   $CI = true (GitHub Actions, etc.)
#
# Rationale: laptops/onboarding hit warn (clear remediation, not blocked).
# Servers/CI hit strict (no silent drift on the boxes that matter).
#
# Layers (per SOP-36 L3 Cascade Discipline):
#   L1 = smorch-dev + smorch-ops slash commands
#   L2 = SMO custom skills (frozen list, do not extend)
#   L3 = gstack (29 skills) + superpowers (14 skills)
#
# Usage: l3-health-check.sh [--quiet] [--strict]

set -uo pipefail

QUIET=""
STRICT=""
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET="1" ;;
    --strict) STRICT="1" ;;
  esac
done

# Auto-strict on servers / CI
if [ "${SMORCH_STRICT_L3:-}" = "1" ] || [ "${CI:-}" = "true" ]; then
  STRICT="1"
fi

GSTACK_SKILLS=(
  autoplan benchmark browse canary careful codex connect-chrome cso
  design-consultation design-review design-shotgun document-release
  freeze guard gstack-upgrade investigate land-and-deploy office-hours
  plan-ceo-review plan-design-review plan-eng-review qa qa-only retro
  review setup-browser-cookies setup-deploy ship unfreeze
)

SUPERPOWERS_SKILLS=(
  brainstorming dispatching-parallel-agents executing-plans
  finishing-a-development-branch receiving-code-review requesting-code-review
  subagent-driven-development systematic-debugging test-driven-development
  using-git-worktrees using-superpowers verification-before-completion
  writing-plans writing-skills
)

GSTACK_ROOT="${GSTACK_ROOT:-$HOME/.claude/skills/gstack}"
SUPERPOWERS_CACHE="${SUPERPOWERS_CACHE:-$HOME/.claude/plugins/cache/claude-plugins-official/superpowers}"
SUPERPOWERS_LOCAL="${SUPERPOWERS_LOCAL:-$HOME/.claude/skills/superpowers}"

missing_gstack=()
missing_superpowers=()
shadow_warnings=()

# Shadow-install detection (L-011, captured 2026-04-29 from Lana's blocker).
# A plugin directory at ~/.claude/plugins/smorch-{dev,ops}/ takes precedence
# over the marketplace cache. If the legacy direct install isn't renamed,
# new commands from v1.5.0+ never load. Filesystem presence ≠ runtime loading.
PLUGINS_DIR="${PLUGINS_DIR:-$HOME/.claude/plugins}"
for legacy in smorch-dev smorch-ops; do
  if [ -d "$PLUGINS_DIR/$legacy" ] && [ -d "$PLUGINS_DIR/$legacy/.claude-plugin" ]; then
    shadow_warnings+=("$PLUGINS_DIR/$legacy")
  fi
done

# gstack: each skill is a subdirectory of $GSTACK_ROOT
for skill in "${GSTACK_SKILLS[@]}"; do
  if [ ! -d "$GSTACK_ROOT/$skill" ]; then
    missing_gstack+=("$skill")
  fi
done

# superpowers: prefer official marketplace plugin, fall back to local symlink.
# The local symlink at ~/.claude/skills/superpowers may point either to a
# repo root (containing skills/) or directly to the skills dir.
sp_root=""
if [ -d "$SUPERPOWERS_CACHE/skills" ]; then
  sp_root="$SUPERPOWERS_CACHE/skills"
elif [ -d "$SUPERPOWERS_LOCAL/skills" ]; then
  sp_root="$SUPERPOWERS_LOCAL/skills"
elif [ -d "$SUPERPOWERS_LOCAL" ] && [ -d "$SUPERPOWERS_LOCAL/writing-plans" ]; then
  sp_root="$SUPERPOWERS_LOCAL"
fi

if [ -z "$sp_root" ]; then
  for skill in "${SUPERPOWERS_SKILLS[@]}"; do
    missing_superpowers+=("$skill")
  done
else
  for skill in "${SUPERPOWERS_SKILLS[@]}"; do
    if [ ! -d "$sp_root/$skill" ]; then
      missing_superpowers+=("$skill")
    fi
  done
fi

gstack_ok=$(( ${#GSTACK_SKILLS[@]} - ${#missing_gstack[@]} ))
sp_ok=$(( ${#SUPERPOWERS_SKILLS[@]} - ${#missing_superpowers[@]} ))

all_clean=1
if [ ${#missing_gstack[@]} -gt 0 ] || [ ${#missing_superpowers[@]} -gt 0 ]; then
  all_clean=0
fi
if [ ${#shadow_warnings[@]} -gt 0 ]; then
  all_clean=0
fi

if [ "$all_clean" = "1" ]; then
  echo "L3 ✓ gstack(${gstack_ok}/${#GSTACK_SKILLS[@]}) superpowers(${sp_ok}/${#SUPERPOWERS_SKILLS[@]})"
  exit 0
fi

# Failure path. Mode-aware: warn (default) vs strict (servers/CI).
status_glyph="⚠"
status_tag="warn — session continues"
if [ "$STRICT" = "1" ]; then
  status_glyph="✗"
  status_tag="STRICT — refusing session"
fi

# Status line includes shadow count if any
shadow_note=""
if [ ${#shadow_warnings[@]} -gt 0 ]; then
  shadow_note=" shadow($(echo ${#shadow_warnings[@]}))"
fi
echo "L3 $status_glyph gstack(${gstack_ok}/${#GSTACK_SKILLS[@]}) superpowers(${sp_ok}/${#SUPERPOWERS_SKILLS[@]})${shadow_note} [$status_tag]"

if [ -n "$QUIET" ]; then
  [ "$STRICT" = "1" ] && exit 1 || exit 0
fi

echo ""
if [ "$STRICT" = "1" ]; then
  echo "STRICT mode: smorch-dev refuses to start without the full L3 cascade (per SOP-36)."
else
  echo "WARN mode (laptop/onboarding default). Set SMORCH_STRICT_L3=1 to enforce."
fi
echo ""

if [ ${#shadow_warnings[@]} -gt 0 ]; then
  echo "Shadow direct-install detected (L-011): legacy plugin dir takes precedence over marketplace cache."
  for path in "${shadow_warnings[@]}"; do
    echo "  → $path"
  done
  echo "Remediation: rename to legacy-prefix so the marketplace cache wins:"
  for path in "${shadow_warnings[@]}"; do
    base=$(basename "$path")
    echo "  mv \"$path\" \"${PLUGINS_DIR}/_legacy-${base}-direct-pre-v1.5\""
  done
  echo "Then restart Claude Code. Marketplace cache (cache/smorch-dev/...) loads correctly."
  echo ""
fi

if [ ${#missing_gstack[@]} -gt 0 ]; then
  echo "Missing gstack skills: ${missing_gstack[*]}"
  echo "Remediation:"
  echo "  git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack"
  echo "  cd ~/.claude/skills/gstack && ./setup"
  echo ""
fi

if [ ${#missing_superpowers[@]} -gt 0 ]; then
  echo "Missing superpowers skills: ${missing_superpowers[*]}"
  echo "Remediation (laptop with /plugin support):"
  echo "  /plugin install superpowers@claude-plugins-official"
  echo "Remediation (server / no /plugin support):"
  echo "  git clone --single-branch --depth 1 https://github.com/obra/superpowers.git ~/.claude/skills/_superpowers-repo"
  echo "  ln -sfn ~/.claude/skills/_superpowers-repo/skills ~/.claude/skills/superpowers"
  echo ""
fi

[ "$STRICT" = "1" ] && exit 1 || exit 0
