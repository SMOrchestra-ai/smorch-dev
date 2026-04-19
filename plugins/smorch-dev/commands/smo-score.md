---
description: Run 5-hat composite score (internal calibration). Replaces separate review+score. Modes - --quick / --full. Gate 92+ to ship.
---

# /smo-score

**Pillar:** EO Pillar #7 — Score+Ship (internal variant)
**When:** After `/smo-code`. Before `/smo-handover`.

## Modes

- `--quick` (2 min) — Product + Engineering only. Use on small fix PRs.
- `--full` (10 min) — all 5 hats. Default. Use on any feature PR.

## Workflow

1. Invoke `smo-scorer` skill
2. Read BRD, project overlay, lessons.md
3. Apply any `.smorch/overrides/{hat}.override.md`
4. Dispatch parallel subagents (one per hat in --full mode)
5. Aggregate → compute composite
6. Save `docs/qa-scores/YYYY-MM-DD-HHMM.md` + append trend.csv
7. Apply gate:
   - **92+** → ready to `/smo-handover`
   - **85-91** → `/smo-bridge-gaps`
   - **<85** → return to `/smo-plan` (major rework)
8. If pattern identified → prompt lessons-manager to append

## Arguments

- `--quick` | `--full` (default --full)
- Optional: single hat to score (e.g., `/smo-score --hat=engineering`)

## Output

```
## Score — {branch} — {date}

Mode: --full

| Hat | Score | Notes |
|-----|:-----:|-------|
| Product | 9.5 | BRD AC-N.N all covered |
| Architecture | 9 | Clean modules, 1 bundle comment missing |
| Engineering | 9.5 | All 11 questions addressed, security Q9-11 clean |
| QA | 9 | Happy + error tested, handover brief 86 |
| UX | 10 | Matches UX artifact |

**Composite: (9.5+9+9.5+9+10) × 2 = 94**
**No hat below 8.5 floor ✅**

**Decision: SHIP. Run /smo-handover next.**
```

## Key diff from student /eo-score

- Ship gate 92 (vs 90)
- Min hat 8.5 (vs 8)
- Engineering hat has 3 security questions (Q9-Q11)
- Calibration examples are internal SMO PRs
