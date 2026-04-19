---
description: QA scores the dev→QA handover BEFORE starting QA. 5-dimension rubric. ≥80 accept. 60-79 send back. <60 auto-reject + escalate.
---

# /smo-qa-handover-score

**For:** Lana (half QA, half Dev)
**When:** Dev sent a handover brief via /smo-handover. BEFORE she starts testing.

## Why this exists (Mamoun's explicit ask)

If the handover is weak, Lana rejects it back to dev — not silently works around gaps. This skill makes rejection legitimate and structured.

## Workflow

1. Invoke `qa-handover-scorer` skill
2. Read handover brief at path from `$ARGUMENTS` (or latest in `docs/handovers/`)
3. Score 5 dimensions (1-10 each):
   - **Completeness** — BRD refs, PR URL, staging URL
   - **Testability** — happy/empty/error/edge scenarios with setup+actions+expected
   - **Repro-ability** — env vars, seed data, test accounts
   - **Risk disclosure** — known issues, untested areas, nearby code
   - **Rollback readiness** — rollback command, SLA, reversibility
4. Compute composite = avg × 2 (range 10-100)
5. Apply decision:
   - **≥90:** ACCEPT — start QA immediately
   - **80-89:** ACCEPT WITH NOTES — start QA, dev fixes in parallel
   - **60-79:** SEND BACK — fixes required, dev resubmits
   - **<60:** AUTO-REJECT — Mamoun pinged, dev cannot resubmit without ack
6. Save `docs/handovers/{date}-PR-{n}-qa-score.md` + row in trend.csv
7. Notify dev + Mamoun per decision

## Arguments

- `$ARGUMENTS` — handover brief path (default: latest in docs/handovers/)
- `--send-back` — generate annotated version, ping dev
- `--reject` — escalate to Mamoun

## Output

```
## QA Handover Score — PR #47

**Scored by:** Lana
**Date:** 2026-04-19 14:23

| Dimension | Score | Notes |
|-----------|:-----:|-------|
| Completeness | 9 | BRD + PR + staging all linked |
| Testability | 7 | Empty state not specified |
| Repro-ability | 10 | Seed + creds clear |
| Risk disclosure | 8 | Nearby code regression not flagged |
| Rollback readiness | 9 | Command + SLA present |

**Composite: (9+7+10+8+9) × 2 = 86**
**Decision: ACCEPT WITH NOTES**

Notes for dev (parallel fix):
- Add empty-state test scenario to section 2
- Flag /lib/supabase/rls.ts as regression risk

Starting QA now.
```

## Trend

`docs/handovers/trend.csv` tracks dev patterns month-over-month. `/smo-retro` surfaces consistent gaps.
