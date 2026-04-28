---
description: Spin up isolated git worktree for the current feature. Required before /smo-code on multi-file work.
allowed-tools: Bash, Read
---

# /smo-worktree

**Pillar:** Boris #2 — Subagent / Parallel work. Isolated workspace = clean blast radius.
**When:** After `/smo-plan` is approved, before `/smo-code` on any multi-file feature.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill |
|------|----------|
| Worktree create + setup + baseline | `superpowers:using-git-worktrees` |

L2: none. This command is a thin wrapper around the L3 skill — no SMO-specific gates required at this step.

## Workflow

1. Read latest plan from `docs/plans/{feature}.md` (most recent file)
2. Derive worktree name from plan filename (drop the `.md`)
3. **L3 superpowers:using-git-worktrees** — creates isolated worktree:
   - Smart directory selection (defaults to `.claude/worktrees/{feature}/`)
   - Safety verification (no uncommitted changes in source branch)
   - Runs project setup (`npm install`, db reset if applicable)
   - Verifies clean test baseline (all tests pass before any work)
4. Confirm worktree path back to user
5. Suggest next: `cd .claude/worktrees/{feature}/ && /smo-code`

## Arguments

- `$ARGUMENTS` — optional explicit feature name (overrides auto-detect from latest plan)
- `--from <branch>` — base branch (default: current branch / main)

## Output

```
✓ Worktree created: .claude/worktrees/draft-endpoint/
  Base: main @ a3f4e21
  Setup: npm install (✓), db reset (✓)
  Test baseline: 142 passing, 0 failing

Next: cd .claude/worktrees/draft-endpoint/ && /smo-code
```

## Why this is hard-required

Multi-file work outside a worktree mixes WIP across features. /smo-code refuses
to run if not inside a worktree (per L3 cascade). Single-file fixes can skip
this — /smo-code allows that case explicitly.

## Cleanup

`/smo-ship` invokes `superpowers:finishing-a-development-branch`, which handles
worktree teardown after merge. Don't manually `git worktree remove` — let the
ship flow do it.
