---
name: smo-scorer
description: |
  SMOrchestra internal 5-hat scoring orchestrator. Internal calibration is HARDER than the
  student-facing eo-scorer: ship gate 92+ (not 90+), no hat below 8.5, security questions
  baked into Engineering hat (no separate security hat).

  Uses the same 5 dimensions (Product, Architecture, Engineering, QA, UX) but with internal
  calibration-examples.md sourced from real SMOrchestra PRs — not student projects.

  Invoked by /smo-score command. Writes reports to docs/qa-scores/YYYY-MM-DD-HHMM.md and
  appends to docs/qa-scores/trend.csv.
---

# smo-scorer — Internal 5-Hat Scoring

**Ship gate:** composite ≥ 92 (internal bar). No hat below 8.5.
**Bridge-gaps range:** 85-91 → run /smo-bridge-gaps.
**Reject:** <85 → major rework.

**Why harder than eo-scorer:**
- SMOrchestra runs 4 production servers, 11+ projects, affects paying customers
- Post-perfctl malware incident raised the security bar permanently
- Lana + future hires need consistent quality — not solo-founder "ship fast" leeway

## Composite formula

```
composite = (product + architecture + engineering + qa + ux) × 2
```

Range 10-100. Ship gate 92. No hat may be below 8.5 regardless of composite.

## Hat files

- `product-hat.md` — 8 questions (internal calibration in calibration-examples.md)
- `architecture-hat.md` — 8 questions
- `engineering-hat.md` — 8 questions + **3 security questions** (Q9 UFW/fail2ban, Q10 CVE scan, Q11 SSH hardening) — ONLY for internal scoring
- `qa-hat.md` — 8 questions
- `ux-hat.md` — 8 questions (MENA + English B2B applicable)

## Workflow

1. Read BRD at `architecture/brd.md`, project overlay at `.smorch/project.json`, lessons at `.claude/lessons.md`
2. If overlay has `overrides/` directory, apply rubric overrides per hat
3. Dispatch 5 parallel subagents (Boris pillar 2), one per hat
4. Aggregate, compute composite
5. Save report `docs/qa-scores/YYYY-MM-DD-HHMM.md`, append trend.csv
6. Apply gate:
   - 92+ → ship (run `/smo-ship`)
   - 85-91 → `/smo-bridge-gaps`
   - <85 → reject + return to `/smo-plan`
7. If a pattern emerged → prompt lessons-manager to append a lesson

## Internal vs student calibration

| Aspect | eo-scorer (students) | smo-scorer (internal) |
|--------|:--------------------:|:---------------------:|
| Ship gate | 90 | 92 |
| Min hat | 8 | 8.5 |
| Security | Red flags in rubric | 3 explicit Q in Engineering hat |
| Calibration examples | Student solo-founder PRs | Real SMO PRs from 2026 sprints |
| Who scores | Self-score | Self-score + Lana validation via /smo-qa-handover-score |

## Integration

- **Invoked by:** `/smo-score --quick` (Product+Engineering only, 2 min) or `/smo-score --full` (all 5 hats, 10 min)
- **Blocks:** `/smo-ship` if composite < 92
- **Reads:** `.smorch/project.json` for overlay config, `.smorch/overrides/*.override.md` for rubric adjustments
- **Writes:** `docs/qa-scores/YYYY-MM-DD-HHMM.md` + `docs/qa-scores/trend.csv`

## Honest calibration rule

**Never score above what the evidence supports.** If a PR has 3 `any` types, Engineering Q4 caps at 6 regardless of other strengths. The rubric is descriptive, not aspirational. If you want to hit 92 and you're honestly at 85, fix the gaps — don't round up.

This is the lesson we captured as L-001 in eo-microsaas-dev: "Don't self-score immediately after building." Applies double internally.
