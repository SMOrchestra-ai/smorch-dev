---
description: Merge + tag (NOT deploy). Final gate before server push. 92+ score gate, QA passed gate, elegance pause gate.
---

# /smo-ship

**Scope:** merge PR + tag release. **Does NOT deploy.** (That's `/smo-deploy`.)
**When:** `/smo-qa-run` returned PASS. Ready to land on main.

## Workflow

1. Verify score gate (composite ≥ 92, no hat < 8.5) from latest `docs/qa-scores/`
2. Verify QA passed from latest `docs/qa/`
3. Verify handover score ≥ 80 from `docs/handovers/`
4. Verify git hygiene:
   - Branch up to date with base
   - No uncommitted changes
   - `validate-plugins.sh` green (for plugin repo changes)
5. Run `npm run build`, `npm test`, `npm audit --audit-level=high`
6. Create PR via `gh pr create` with body:
   - Score report (inline)
   - Handover brief link
   - QA report link
   - Elegance pause block from commit
   - BRD ACs covered (from @AC tags)
7. On merge: tag release per semver (auto-bump patch unless --minor/--major)
8. Push tag
9. Append to `docs/ships/trend.csv`

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
