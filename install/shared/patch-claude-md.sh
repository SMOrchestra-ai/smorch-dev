#!/usr/bin/env bash
# Shared: patch ~/.claude/CLAUDE.md + ~/.claude/lessons.md with L-009 push-discipline rule.
# Sourced by eng-desktop.sh, dev-server.sh, prod-server.sh.
# Windows equivalent is inlined in qa-machine.ps1.
#
# L-009 origin: 2026-04-21 — shipped eo-microsaas-dev v1.1.0 but left every change
# uncommitted. "GitHub drift" pattern: local worktree holds work, remote is stale,
# next machine pulls from empty origin/main. Single source of truth = GitHub remote.

set -euo pipefail

log() { echo "  [patch-claude-md] $1"; }

CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
LESSONS_MD="${HOME}/.claude/lessons.md"
SENTINEL_CLAUDE="<!-- L-009-PUSH-DISCIPLINE -->"
SENTINEL_LESSONS="### L-009 — GitHub is the single point of truth"

mkdir -p "${HOME}/.claude"

# ──────────────────────────────────────────────────────────────────
# Patch ~/.claude/CLAUDE.md — append L-009 block if absent
# ──────────────────────────────────────────────────────────────────
if [ ! -f "$CLAUDE_MD" ]; then
  log "~/.claude/CLAUDE.md missing — creating minimal file with L-009"
  cat > "$CLAUDE_MD" <<'EOF'
GLOBAL INSTRUCTIONS — SMOrchestra.ai

## GIT + DEPLOYMENT
EOF
fi

if grep -qF "$SENTINEL_CLAUDE" "$CLAUDE_MD" 2>/dev/null; then
  log "L-009 already present in CLAUDE.md — skipping"
else
  log "appending L-009 block to ~/.claude/CLAUDE.md"
  cat >> "$CLAUDE_MD" <<'EOF'

<!-- L-009-PUSH-DISCIPLINE -->
- Push discipline (L-009): GitHub remote is the single authoritative source of truth. Claude acts as lead architect — at the end of every work unit, commit + push + open PR + merge + tag + update any version references downstream scripts read. Do NOT ask "want me to open the PR?" — do it. Only escalate to CEO when: (a) force push / hard reset / branch delete, (b) deploys to smo-prod or eo-prod, (c) cross-repo edits that affect someone else's in-flight work, (d) anything touching customer data or secrets. Everything else: act. If blocked by approval, flag drift risk every turn until resolved — never carry silent drift.
EOF
fi

# ──────────────────────────────────────────────────────────────────
# Patch ~/.claude/lessons.md — append L-009 entry if absent
# ──────────────────────────────────────────────────────────────────
if [ ! -f "$LESSONS_MD" ]; then
  log "~/.claude/lessons.md missing — creating with L-009"
  cat > "$LESSONS_MD" <<'EOF'
# Global Lessons — ~/.claude/lessons.md
**Scope:** cross-project rules Claude applies at every SMOrchestra session.
**Auto-loaded at SessionStart via `~/.claude/settings.json` hook.**

## Active lessons

EOF
fi

if grep -qF "$SENTINEL_LESSONS" "$LESSONS_MD" 2>/dev/null; then
  log "L-009 already present in lessons.md — skipping"
else
  log "appending L-009 entry to ~/.claude/lessons.md"
  cat >> "$LESSONS_MD" <<'EOF'

### L-009 — GitHub is the single point of truth. Always commit AND push. No excuses.
- **Captured:** 2026-04-21
- **Trigger:** Shipped a full v1.1.0 upgrade to a plugin (new skill, 8 modified files, 10 new files, version bump, CHANGELOG, rollback runbook). Said "done" and moved on. Nothing was committed, nothing was pushed. Local worktree held every change. GitHub drift pattern — other machines, cron syncs, install.sh flows never saw the work.
- **Rule:** GitHub remote is the single authoritative source of truth for every SMOrchestra repo. Local worktrees, other machines, student machines, servers — all pull from there. A change that exists only in a local worktree is invisible work: can be wiped by machine failure, missed by sync cron, missed by install.sh, invites silent drift when the next session starts from stale `origin/main`.
  - **Default behavior:** at end of any work unit that produces a complete, self-consistent change → `git add {scope}` → `git commit` with a real message → `git push` → open PR → merge → tag → bump any downstream version references. No waiting for separate "please commit" prompt.
  - **Claude acts as CPO / lead architect,** not subordinate. CEO delegates executing authority. Do not ask "want me to open the PR?" — open it. Only escalate to CEO for: (a) force push / hard reset / branch delete, (b) deploys to smo-prod or eo-prod, (c) cross-repo edits affecting someone else's in-flight work, (d) anything touching customer data or secrets.
  - **When approval is needed:** flag drift risk every turn until resolved. Keep flagging — drift risk is a standing hazard, not a one-time disclosure.
  - **WIP checkpoints:** for multi-hour work, push mid-stream on feature branch. `claude/*` branches are cheap. Losing 3h of uncommitted work > noise in commit log.
  - **Never use destructive git ops** to "fix" a mess whose root cause is "I forgot to push earlier." Push first, then think about the mess.
- **Check:** every turn that ends a work unit → mental `git status`. Any modified/untracked under scope just worked → commit + push same turn, OR flag drift risk explicitly. Final message ending session or handing back to user → `git status` must be clean OR the drift-risk flag must appear.
- **Last triggered:** 2026-04-21
EOF
fi

log "done — L-009 present in both files"
