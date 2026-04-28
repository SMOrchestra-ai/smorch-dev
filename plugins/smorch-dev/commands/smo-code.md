---
description: Execute a planned feature via TDD. Hard-required worktree. Writes test first, then minimal impl, then refactors with elegance pause.
---

# /smo-code

**Pillars:** Boris #2 (Subagent) + #5 (Elegance) — via superpowers TDD
**When:** After `/smo-plan` is approved AND `/smo-worktree` has created the isolated workspace.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill | When |
|------|----------|------|
| Worktree precondition | `superpowers:using-git-worktrees` (via `/smo-worktree`) | Before /smo-code runs |
| TDD red→green→blue | `superpowers:test-driven-development` | Always, per AC |
| Multi-file work | `superpowers:subagent-driven-development` | If >1 independent file |
| Multi-investigation | `superpowers:dispatching-parallel-agents` | If 3+ truly independent investigations |

L2 wrappers: `elegance-pause` before each commit, `arabic-rtl-checker` + `mena-mobile-check` on `.tsx`/`.jsx` changes, `cost-tracker` on Claude/OpenAI/DB paths, `lessons-manager` appends corrections.

## Workflow

1. **Verify worktree** (drift guard): confirm we're in a git worktree (`git rev-parse --git-common-dir` differs from `git rev-parse --git-dir`).
   - **>1 file in plan**: refuse and route to `/smo-worktree`. No `--skip` flag — the right thing is the only thing for multi-file work.
   - **Single-file PR or hotfix**: pass `--single-file` or `--hotfix` to bypass. Decision goes into the PR description for accountability ("worktree skipped: single-file fix").
2. Read plan from `docs/plans/{feature}.md` (written by /smo-plan)
3. For each AC in the plan:
   a. **L3 superpowers:test-driven-development** — red→green→blue loop
      - Write failing test tagged `@AC-N.N` (red)
      - Minimal impl to pass (green)
      - Refactor (blue)
4. **If >1 independent file** in the AC scope:
   - **L3 superpowers:subagent-driven-development** with 2-stage review (spec compliance, then code quality). One subagent per file.
5. **If 3+ independent investigations** needed (e.g., search for type X across packages, scan for stale imports, audit env-var usage):
   - **L3 superpowers:dispatching-parallel-agents** — keep coordinator context clean
6. **L2 elegance-pause** before each commit (refactor review: "would I write this again?")
7. **L2 arabic-rtl-checker + mena-mobile-check** on `.tsx`/`.jsx` changes (gated by locale per /smo-plan)
8. **L2 cost-tracker** annotates any cost anomaly for Engineering Q8
9. **L2 lessons-manager** appends corrections received during the session
10. Stage + commit with conventional message + @AC-N.N refs + elegance-pause block

## Arguments

`$ARGUMENTS` — optional specific AC to focus on

## Exit criteria

- All targeted ACs have passing tests
- Elegance pause block in commit message
- No `.skip` tests in committed range
- cost-tracker either clean or tradeoff documented in PR description
