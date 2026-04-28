#!/usr/bin/env bash
# check-no-l2-reimplementation.sh — enforce SOP-36 L3 Cascade Discipline.
# L2 skills (SMO custom) MUST NOT inline-reimplement what L3 (gstack/superpowers) does.
#
# Two modes (avoid CI noise from heuristic regex):
#   default = WARN: print violations, exit 0 (don't block local pre-commit)
#   strict  = REFUSE: exit 1 (CI / `--strict` flag / $CI=true)
#
# Frozen L2 set (do not extend):
#   smorch-dev: smo-scorer, qa-handover-scorer, elegance-pause, brd-traceability,
#               mena-mobile-check, arabic-rtl-checker, cost-tracker,
#               handover-generator, lessons-manager, dev-start-bootstrap, dev-guide-router
#   smorch-ops: deploy-pipeline, rollback-runbook, drift-detector, security-hardener,
#               incident-runbook, secrets-manager, codex-doctrine

set -uo pipefail

STRICT=""
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT="1" ;;
  esac
done
if [ "${CI:-}" = "true" ]; then STRICT="1"; fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS_DIRS=(
  "$REPO_ROOT/plugins/smorch-dev/skills"
  "$REPO_ROOT/plugins/smorch-ops/skills"
)

# Patterns that indicate inline reimplementation of L3 work.
# Format: pattern|matching-rule|L3-skill-to-call-instead
violations_found=0

check_pattern() {
  local pattern="$1"
  local rule="$2"
  local l3_skill="$3"

  for skills_dir in "${SKILLS_DIRS[@]}"; do
    [ -d "$skills_dir" ] || continue
    matches=$(grep -rEln --include='SKILL.md' --include='*.md' "$pattern" "$skills_dir" 2>/dev/null || true)
    if [ -n "$matches" ]; then
      echo "✗ L2 reimplementation detected: $rule"
      echo "  → Call L3 skill instead: $l3_skill"
      echo "  Files:"
      echo "$matches" | sed 's/^/    /'
      echo ""
      violations_found=$((violations_found + 1))
    fi
  done
}

# Inline TDD red→green→blue narration (L2 should call superpowers:test-driven-development)
check_pattern '(?i)(red[ -]?green[ -]?(blue|refactor)|write (a|the) (failing )?test first.*(then|now) implement)' \
  "Inline TDD loop in L2 skill" \
  "superpowers:test-driven-development"

# Inline plan generation prompts (L2 should call superpowers:writing-plans)
check_pattern '(?i)(draft (a|the|an) (implementation )?plan with .{0,80}(bite-?sized|2-5 ?min|exact file paths)|emit a plan that breaks work into)' \
  "Inline plan generation in L2 skill" \
  "superpowers:writing-plans"

# Inline parallel agent dispatch logic (L2 should call superpowers:dispatching-parallel-agents or subagent-driven-development)
check_pattern '(?i)dispatch [0-9]+ (parallel |subagents? for |independent ).{0,60}(investigation|search|task|file)' \
  "Inline parallel agent dispatch in L2 skill" \
  "superpowers:dispatching-parallel-agents OR superpowers:subagent-driven-development"

# Inline worktree creation (L2 should call superpowers:using-git-worktrees)
check_pattern '(?i)(git worktree add .{0,80}(verify|setup|baseline)|create (an? )?isolated worktree (with|and) (run|verify))' \
  "Inline worktree management in L2 skill" \
  "superpowers:using-git-worktrees"

# Inline retro / commit-history aggregation (L2 should call gstack:retro)
check_pattern '(?i)(weekly engineering retrospective|aggregate commit history.{0,40}per[- ]?person|engineering retro that shows trends)' \
  "Inline retro generation in L2 skill" \
  "gstack:retro"

# Inline benchmark / Core Web Vitals collection (L2 should call gstack:benchmark)
check_pattern '(?i)(measure (core web vitals|page load time|lighthouse).{0,40}(baseline|regression)|capture performance baseline (with|using) (browse|chromium))' \
  "Inline benchmark collection in L2 skill" \
  "gstack:benchmark"

# Inline code-review subagent prompts (L2 should call superpowers:requesting-code-review)
check_pattern '(?i)(dispatch (a|the) code[- ]?reviewer subagent with crafted context|external adversarial review of (the|this) (PR|diff))' \
  "Inline code-review subagent dispatch in L2 skill" \
  "superpowers:requesting-code-review"

if [ "$violations_found" -gt 0 ]; then
  if [ "$STRICT" = "1" ]; then
    echo "✗ Found $violations_found L2-reimplementing-L3 violation(s) [STRICT]. See SOP-36."
    echo "  L2 skills (frozen 18) must invoke L3 skills, not duplicate them."
    echo "  Allowlist: prefix doc references with 'see' (e.g., 'see superpowers:writing-plans')."
    exit 1
  else
    echo "⚠ Found $violations_found L2-reimplementing-L3 hint(s) [warn — not blocking]. See SOP-36."
    echo "  Set CI=true or pass --strict to enforce. False positives → tighten regex in this script."
    exit 0
  fi
fi

echo "✓ No L2 reimplementation of L3 detected ($(echo "${SKILLS_DIRS[@]}" | tr ' ' '\n' | wc -l | tr -d ' ') skill dirs scanned)."
exit 0
