---
description: End-of-sprint retro. Aggregates scores + handovers + incidents across ALL projects on-demand (no synced aggregate file). Surfaces cross-project patterns.
---

# /smo-retro

**Pillar:** Boris #3 — Self-Improvement Loop
**When:** End of sprint (weekly or bi-weekly).

## Why on-demand aggregation

Per plan ADR-002: no synced `scores-aggregate.csv`. Merge conflicts would eat time. Instead, `/smo-retro` greps all projects on demand:
- `CodingProjects/*/docs/qa-scores/trend.csv`
- `CodingProjects/*/docs/handovers/trend.csv`
- `CodingProjects/*/docs/qa/YYYY-MM-DD-*.md`
- Aggregates in memory + writes single retro report

## Workflow

1. Find all `CodingProjects/*/docs/qa-scores/trend.csv` files
2. Filter rows to last N days (default 14)
3. Group by project, compute avg composite + avg per-hat + trend
4. Parse all `docs/handovers/trend.csv` for same window
5. Scan `docs/incidents/` for any SEV1-3 in window
6. Pull `.claude/lessons.md` from each project — count triggers in window
7. Cross-project pattern detection:
   - Hat consistently low across multiple projects → team-wide rule
   - Handover dimension consistently rejected → dev training
   - Same bug class across projects → shared skill/lesson
8. Write `docs/retros/YYYY-MM-DD-sprint-retro.md`
9. Propose lessons for `smorch-brain/canonical/lessons.md` (cross-project)
10. Prune stale per-project lessons (>90 days untriggered)

## Arguments

- `--days N` — window length (default 14)
- `--project {name}` — single-project retro (default all)

## Output

```
## Sprint retro — 2026-04-06 to 2026-04-19

**PRs shipped (all projects):** 12
**Avg composite:** 91.2
**Trend vs prior sprint:** +1.8 ✅

### Per-project hat averages
| Project | Product | Arch | Eng | QA | UX | Composite | Focus |
|---------|:-------:|:----:|:---:|:--:|:--:|:---------:|-------|
| EO-MENA | 9.1 | 8.9 | 9.0 | 8.5 | 9.2 | 89 | QA |
| SSE | 9.4 | 9.2 | 9.3 | 8.8 | 9.0 | 92 | — |
| SaaSFast | 8.2 | 8.4 | 8.3 | 8.0 | 9.0 | 84 | all hats |

### Handover trends (Lana scored 9 briefs)
- Avg: 83 (range 72-94)
- Send-back rate: 22%
- Weakest dimension: Risk Disclosure (avg 7.8)

### Incidents
- 1 SEV2 (eo-prod rate-limit bypass) — resolved in 90 min

### Cross-project pattern detected
⚠️ Risk Disclosure weak across all dev. Propose new lesson in smorch-brain/canonical/lessons.md:
"Before /smo-handover, grep recent commits for files touched by this PR. List those files as regression risks in section 4."

### Stale lessons pruned
- L-003 "watch Supabase RLS" — not triggered in 120d, archived

### Next sprint focus
- All devs: improve Risk Disclosure section of /smo-handover briefs
- SaaSFast: BRD remediation (Product hat 8.2)
```

## Integration with smorch-brain/canonical/lessons.md

Patterns confirmed across ≥3 projects get promoted to the cross-project lessons file. These get loaded at every session start via the canonical SessionStart hook.

## Cadence

Every 14 days. Block 30 min on calendar. Mamoun + Lana attend live (or async review).
