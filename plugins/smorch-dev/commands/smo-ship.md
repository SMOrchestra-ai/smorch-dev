---
description: Merge + tag (NOT deploy). Final gate before server push. 92+ score gate, QA passed gate, elegance pause gate.
---

# /smo-ship

**Scope:** merge PR + tag release. **Does NOT deploy.** (That's `/smo-deploy`.)
**When:** `/smo-qa-run` returned PASS. Ready to land on main.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill | When |
|------|----------|------|
| Perf regression gate | `gstack:benchmark` (via `/smo-benchmark`) | If any UI/API code touched |
| PR template + create | `gstack:ship` | Always |
| Branch finish flow | `superpowers:finishing-a-development-branch` | Always (merge / PR / keep / discard decision) |

L2 wrappers: smo-scorer composite ≥ 92 + hat floor ≥ 8.5, qa-handover-scorer ≥ 80, brd-traceability AC = 100%, elegance-pause block in last commit.

## Workflow

### Phase 1 — Parallel L2 gate preamble (fail fast)

Fire these 6 read-only gate checks **concurrently**. Each emits `GATE_{name}: PASS|FAIL <reason>`; if any fail, print the union and abort.

| Gate | Source |
|---|---|
| `GATE_score` | latest `docs/qa-scores/` composite ≥ 92 |
| `GATE_hat_floor` | same file — no hat < 8.5 |
| `GATE_qa` | latest `docs/qa/` → Decision = PASS |
| `GATE_handover` | latest `docs/handovers/` → score ≥ 80 |
| `GATE_git_clean` | `git status --porcelain` empty AND branch up-to-date with base |
| `GATE_benchmark` | latest `docs/benchmarks/` shows no >10% regression (skip if no UI/API change) |

**Failure surface rule:** error message names the specific gate(s) (e.g., `GATE_benchmark FAIL: LCP regressed 14.2% vs baseline (docs/benchmarks/2026-04-21-feat-x.md)`).

### Phase 2 — Serial build verification

`npm run build && npm test && npm audit --audit-level=high`. For plugin repos, also run `scripts/validate-plugins.sh` and `plugins/smorch-dev/scripts/check-no-l2-reimplementation.sh` (SOP-36).

### Phase 3 — L3 ship ceremony

1. **L3 gstack:ship** — generate PR via canonical SMO template (creates the PR but does NOT merge):
   - Score report (inline)
   - Handover brief link
   - QA report link
   - Elegance pause block from commit
   - BRD ACs covered (from @AC tags)
   - Benchmark delta vs baseline
2. **Run `/smo-review-pr <PR#>`** (external adversarial review) — must return 0 blockers before merge
3. **L3 superpowers:finishing-a-development-branch** — present merge / PR / keep / discard decision flow; verify clean test baseline
4. On merge: tag release per semver (auto-bump patch unless --minor/--major)
5. Push tag
6. Append to `docs/ships/trend.csv`

**Order:** gates → build → push branch → gstack:ship creates PR → /smo-review-pr (external review) → if 0 blockers → finishing-a-development-branch merges. /smo-review-pr is INSIDE the ship flow, not a separate manual step.

## Arguments

- `--minor` / `--major` — version bump override (default: patch)
- `--skip-deploy` — just merge + tag, don't queue deploy (rare; most PRs deploy after ship)

## Gate (blocks if any fail)

- Score < 92
- Any hat < 8.5
- QA report missing or FAIL
- Handover score < 80
- Uncommitted changes
- Build / test / audit failure
- Plugin validator fail (if plugin repo)
- Benchmark regression > 10% on any tracked metric (UI/API changes only)
- L2-reimplementation guard fail (SOP-36)

## Output

```
✅ Shipped PR #47

**Branch:** feat/draft-endpoint
**Composite score:** 94
**QA:** PASS (Lana 2026-04-19)
**Handover:** 86 (accepted with notes)
**Commit:** a3f4e21
**Tag:** v1.4.2
**PR:** https://github.com/.../pull/47

Next: /smo-deploy to push to {staging|production}
```

## Rule

Ship is the merge ceremony. Deploy is the server action. Separating them prevents "merged but not deployed" confusion and enables deploy windows that aren't tied to merge time.
