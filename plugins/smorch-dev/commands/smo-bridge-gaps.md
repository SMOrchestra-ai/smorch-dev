---
description: Fix the lowest-scoring hat when composite is 85-91. Turns a blocked PR into a ship-ready one (internal 92+ gate).
---

# /smo-bridge-gaps

**When:** `/smo-score` returned 85-91. Need to lift weakest hat to ≥8.5 to reach 92 composite.

## L3 cascade (hard-required, see SOP-36)

Route to the matching L3 review skill based on the lowest-scoring hat:

| Lowest hat | L3 Skill | Why |
|-----------|----------|-----|
| Product | `gstack:plan-ceo-review` | Strategy / scope rethink |
| Architecture | `gstack:plan-eng-review` | Architecture / data-flow / edge cases |
| UX (frontend) | `gstack:plan-design-review` | Design dimensions 0-10 fixes |
| Engineering | `superpowers:requesting-code-review` | External adversarial review of the diff |
| QA | `gstack:qa` (extended coverage) | Re-run QA with deeper test scenarios |

L2: `smo-scorer` re-scores after each fix; loop until composite ≥ 92 OR escalate.

## Workflow

1. Read latest score report from `docs/qa-scores/`
2. **L2 smo-scorer** identifies lowest hat
3. Route to the L3 skill in the table above based on lowest hat
4. **L3 review** surfaces specific gaps (questions that dragged the score)
5. Categorize fixes:
   - **AUTO:** safe mechanical fixes (apply immediately)
   - **REVIEW:** human decision needed (present options)
   - **DEFER:** too big for this PR (create follow-up issue)
6. Apply AUTO fixes
7. Prompt user for REVIEW items
8. **L2 smo-scorer** re-scores target hat
9. If ≥8.5 AND composite ≥92 → exit (ready for `/smo-ship`)
10. If still <8.5 after 2 loops → escalate to `/smo-plan` rework

## Arguments

`$ARGUMENTS` — optional: specific hat to target (default: lowest)

## Output example

```
## Bridge gaps — targeting Engineering (current: 7.5)

### AUTO-fix (applied)
- Added bundle size comment to PR description (Q8)
- Killed 1 `any` type in src/lib/draft.ts:42 → IDraftRequest (Q4)

### NEEDS REVIEW
- Q3 (error handling): 1 Claude API call missing try/catch
  Options: (A) wrap + toast "service unavailable", (B) wrap + silent retry once

### DEFERRED
- Q11 (secrets rotation): SSH key on smo-dev is 14 months old
  → Create issue for next secrets rotation sprint (SOP-16)

### Re-score prediction
Engineering 7.5 → 9.0 (ship-ready). Composite 87 → 93.
```

## Exit criteria

- All sub-8.5 hats lifted to ≥8.5
- Composite reaches 92+
- OR escalated to `/smo-plan` after 2 loops
