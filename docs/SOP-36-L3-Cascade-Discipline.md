# SOP-36 — L3 Cascade Discipline

**Effective:** 2026-04-29 (smorch-dev v1.5.0)
**Status:** Active
**Owner:** Mamoun
**Lesson reference:** L-010 (~/.claude/lessons.md)

## The rule

The smorch-dev / smorch-ops command stack is layered. Each layer has a single job. Claude must invoke the right layer for the right work, every time, in the right order.

| Layer | What | Examples |
|-------|------|----------|
| **L1** | smorch-dev + smorch-ops slash commands | `/smo-plan`, `/smo-code`, `/smo-ship`, `/smo-deploy` |
| **L2** | SMO custom skills (FROZEN at 18 — 11 dev + 7 ops) | smo-scorer, brd-traceability, elegance-pause, qa-handover-scorer, deploy-pipeline, incident-runbook |
| **L3** | gstack (29 skills) + superpowers (14 skills) | writing-plans, plan-eng-review, test-driven-development, using-git-worktrees, retro, benchmark, canary, ship, finishing-a-development-branch, requesting-code-review |

## The 3 cascade rules

**Rule 1 — L1 → L3 → L2, never the reverse.** L1 commands invoke L3 first for universal craft work (planning, TDD, code review, deploy hygiene, retros, perf), then L2 for SMO-specific gates (5-hat scoring, MENA checks, BRD traceability, handover, deploy runbooks).

**Rule 2 — L2 must NOT reimplement L3.** If gstack or superpowers ships a skill that does the work, L2 calls it. L2 never inlines a TDD loop, plan generator, code reviewer, parallel agent dispatcher, worktree setup, retro builder, or benchmark collector. That's bloat masquerading as discipline.

**Rule 3 — L3 is hard-required where it matters, soft-warned where it doesn't.**
- **Strict (refuse session):** servers + CI (`SMORCH_STRICT_L3=1` or `CI=true`)
- **Warn (continue with remediation):** laptops, onboarding
- Same script (`l3-health-check.sh`), two modes. No silent drift on the boxes that matter; no stuck-out-of-the-box for new devs.

## Enforcement

| Mechanism | When | Mode |
|-----------|------|------|
| `plugins/smorch-dev/scripts/l3-health-check.sh` | SessionStart hook | warn (default) / strict (servers+CI) |
| `plugins/smorch-dev/scripts/check-no-l2-reimplementation.sh` | Pre-commit + CI | warn (default) / strict (CI) |
| L2 skill list FROZEN | Code review | reject any PR that adds an L2 skill |

## Coverage map (15 L1 commands → L3 wiring)

| L1 Command | L2 (custom) | L3 (gstack/superpowers) |
|-----------|-------------|--------------------------|
| `/smo-plan` | brd-traceability, lessons-manager | superpowers:writing-plans + gstack:plan-eng-review (always); plan-ceo-review / plan-design-review (conditional) |
| `/smo-worktree` | — | superpowers:using-git-worktrees |
| `/smo-code` | elegance-pause, arabic-rtl-checker, mena-mobile-check, lessons-manager, cost-tracker | superpowers:test-driven-development; subagent-driven-development (>1 file); dispatching-parallel-agents (3+ investigations) |
| `/smo-triage` | lessons-manager | gstack:investigate + superpowers:systematic-debugging |
| `/smo-review-pr` | brd-traceability | superpowers:requesting-code-review + receiving-code-review; gstack:review (--deep); built-in security-review (--security) |
| `/smo-benchmark` | — | gstack:benchmark |
| `/smo-score` | smo-scorer | — |
| `/smo-bridge-gaps` | smo-scorer | gstack:plan-eng-review / plan-design-review / plan-ceo-review (routed by lowest hat); superpowers:requesting-code-review (eng); gstack:qa (qa) |
| `/smo-handover` | handover-generator, brd-traceability | — |
| `/smo-qa-handover-score` | qa-handover-scorer | — |
| `/smo-qa-run` | qa-handover-scorer | gstack:qa / qa-only / browse |
| `/smo-ship` | smo-scorer | gstack:benchmark; gstack:ship; superpowers:finishing-a-development-branch |
| `/smorch-dev-start` | dev-start-bootstrap | — |
| `/smo-retro` | lessons-manager | gstack:retro |
| `/smo-dev-guide` | dev-guide-router | — |
| `/smo-deploy` (ops) | deploy-pipeline | gstack:canary (post-deploy) |
| `/smo-incident` (ops) | incident-runbook | superpowers:systematic-debugging (root-cause phase) |
| `/smo-skill-sync` (ops) | (own runbook) | extends sync to gstack + superpowers + CLAUDE.md (per SOP-37) |

ops: rollback, drift, health, secrets — kept untouched. No contrived L3 fit. Server runbooks, not craft work.

## Why this exists

Past pattern: SOPs got written, command surfaces grew, but the actual cascade behind each command stayed inconsistent. Result: you'd run `/smo-plan` and get a plan, but no eng-review, no design-review, no canonical structure. Drift returned. Debugging used `superpowers:systematic-debugging` sometimes and inline hypothesis-list-prose other times. Inconsistency killed reproducibility.

The fix: lock the cascade. One canonical sequence per command. L3 skills do the universal work. L2 skills do the SMO-specific work. L2 never grows; L3 evolves upstream. Pre-commit guard catches drift back into L2.

## What this SOP does NOT do

- It does not enforce paper sequence ("you must run /smo-plan before /smo-code"). That's a workflow choice; some PRs are hotfixes. The cascade is about WHAT each command does, not the order in which the operator chooses to run them.
- It does not block emergency overrides. `--no-eng-review`, `--single-file`, `--hotfix` flags exist to skip steps with PR-description accountability.
- It does not require all servers run strict mode. CI/servers do. Laptops warn. Mode is `$SMORCH_STRICT_L3` controlled.

## Related

- L-010 (~/.claude/lessons.md): the lesson capturing the drift this SOP fixes
- SOP-37: server-side parity (extends the cascade to dev VPS)
- SOP-14: plugin workflow (broader plugin discipline)
