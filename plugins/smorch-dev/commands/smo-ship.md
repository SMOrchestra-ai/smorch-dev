---
description: Merge + tag (NOT deploy). Final gate before server push. 92+ score gate, QA passed gate, elegance pause gate.
---

# /smo-ship

**Scope:** merge PR + tag release. **Does NOT deploy.** (That's `/smo-deploy`.)
**When:** `/smo-qa-run` returned PASS. Ready to land on main.

## Workflow

### Phase 1 — Parallel gate preamble (fail fast)

Fire these 5 read-only gate checks **concurrently** (single background batch, `wait` for all, aggregate results). Each gate emits `GATE_{name}: PASS|FAIL <reason>`; if any fail, print the union of failure reasons and abort before Phase 2.

| Gate | Source |
|---|---|
| `GATE_score` | latest `docs/qa-scores/` composite ≥ 92 |
| `GATE_hat_floor` | same file — no hat < 8.5 |
| `GATE_qa` | latest `docs/qa/` → Decision = PASS |
| `GATE_handover` | latest `docs/handovers/` → score ≥ 80 |
| `GATE_git_clean` | `git status --porcelain` empty AND branch up-to-date with base |

**Failure surface rule:** the error message names the specific gate(s) that failed (e.g., `GATE_score FAIL: composite=88 < 92 (docs/qa-scores/2026-04-21-1402.md)`). Parallelization must not muddle which gate blocked.

### Phase 2 — Serial build verification

6. `npm run build && npm test && npm audit --audit-level=high` (serial — tests depend on build artifacts). For plugin repos, also run `scripts/validate-plugins.sh`.

### Phase 3 — Serial merge ceremony

7. Create PR via `gh pr create` with body:
   - Score report (inline)
   - Handover brief link
   - QA report link
   - Elegance pause block from commit
   - BRD ACs covered (from @AC tags)
8. On merge: tag release per semver (auto-bump patch unless --minor/--major)
9. Push tag
10. Append to `docs/ships/trend.csv`

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
