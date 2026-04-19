---
description: Fix the lowest-scoring hat when composite is 85-91. Turns a blocked PR into a ship-ready one (internal 92+ gate).
---

# /smo-bridge-gaps

**When:** `/smo-score` returned 85-91. Need to lift weakest hat to ≥8.5 to reach 92 composite.

## Workflow

1. Read latest score report from `docs/qa-scores/`
2. For hat(s) scoring <8.5:
   - Open hat rubric (e.g., `smo-scorer/engineering-hat.md`)
   - Identify questions that dragged the score
   - Propose minimal fix plan per question
3. Categorize:
   - **AUTO:** safe mechanical fixes (apply immediately)
   - **REVIEW:** human decision needed (present options)
   - **DEFER:** too big for this PR (create follow-up issue)
4. Apply AUTO fixes
5. Prompt user for REVIEW items
6. Re-score target hat
7. If ≥8.5 → return to `/smo-score` for full recompute
8. If still <8.5 after 2 loops → escalate to `/smo-plan` rework

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
