---
description: QA executes the validation suite per accepted handover brief. Produces QA report + decision - pass / fail / escalate.
---

# /smo-qa-run

**For:** Lana after `/smo-qa-handover-score` returned ≥80.
**When:** Accepted handover. Executing QA now.

## Workflow

1. Read accepted handover brief
2. Follow test scenarios in order: happy → empty → error → edge
3. For each scenario:
   a. Execute setup steps
   b. Perform actions
   c. Compare observed vs expected
   d. Screenshot + log output
4. For MENA projects: run Arabic RTL + mobile 375px validation (uses arabic-rtl-checker + mena-mobile-check skills)
5. Run axe-core accessibility scan
6. Check staging `/api/health` endpoint
7. Execute rollback drill (dry-run): verify `/smo-rollback` would work
8. Aggregate results into QA report

## Decision gate

- **All pass + rollback drill OK:** mark PR "QA passed" — dev can `/smo-ship`
- **Any fail:** mark PR "QA failed" — dev returns to `/smo-triage` with specific repro
- **Blocker encountered** (e.g., staging down): escalate via `/smo-incident` + Telegram

## Output

`docs/qa/YYYY-MM-DD-PR-{n}-qa-report.md`:

```markdown
# QA Report — PR #47

**QA:** Lana
**Date:** 2026-04-19 15:40
**Handover score:** 86 (accepted with notes)

## Scenarios tested

### Happy path ✅
- Setup: {steps}
- Result: PASS (screenshot)

### Empty state ✅
- Setup: {steps}
- Result: PASS

### Error state ❌
- Setup: disable network
- Expected: "service unavailable" toast
- Actual: app hung for 30s then crashed
- **Fail details:** `src/lib/draft.ts:42` try/catch missing timeout

### Edge ✅
- Setup: 10,000 char input
- Result: PASS (truncated gracefully)

## MENA checks
- Arabic RTL: ✅
- Mobile 375px: ✅
- axe-core: ✅ 0 violations

## Rollback drill (dry-run)
- `/smo-rollback --dry-run PR-47`: ✅ would succeed, SLA 90s

## Decision: FAIL
Return to dev. Blocker: error state crash in draft endpoint.
```

## Lana's signing rule

If ≥1 scenario fails and dev argues "that's out of scope," Lana checks the handover brief section 4 (Risk Disclosure). If untested area was flagged → it's out of scope, ok. If not flagged → it's a true fail, dev fixes.
