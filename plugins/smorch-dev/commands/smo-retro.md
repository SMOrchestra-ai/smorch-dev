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

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill | What it owns |
|------|----------|--------------|
| Engineering retro | `gstack:retro` | Commit history + work patterns + per-person breakdown + quality trends + persistent history |

L2: `lessons-manager` promotes patterns triggered ≥3 times across projects to `~/.claude/lessons.md` (global).

## Workflow

1. **L3 gstack:retro** — runs the canonical engineering retrospective:
   - Commit history analysis (last 14 days default)
   - Work patterns (PR size distribution, time-of-day, stuck branches)
   - Code quality metrics (test coverage delta, linter trends)
   - Per-person breakdown with praise + growth areas
   - Trend analysis vs prior sprints
2. Find all `CodingProjects/*/docs/qa-scores/trend.csv` files (read-only aggregation)
3. Filter rows to last N days (default 14)
4. Group by project, compute avg composite + avg per-hat + trend
5. Parse all `docs/handovers/trend.csv` for same window
6. Scan `docs/incidents/` for any SEV1-3 in window
7. **L2 lessons-manager** — count triggers in window per project; promote patterns triggered ≥3 times to `~/.claude/lessons.md`
8. Cross-project pattern detection:
   - Hat consistently low across multiple projects → team-wide rule
   - Handover dimension consistently rejected → dev training
   - Same bug class across projects → shared skill/lesson
9. Merge gstack:retro output + L2 cross-project view → `docs/retros/YYYY-MM-DD-sprint-retro.md`
10. Propose new global lessons (PR against smorch-brain canonical)
11. **L2 lessons-manager** prunes stale per-project lessons (>90 days untriggered)

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
