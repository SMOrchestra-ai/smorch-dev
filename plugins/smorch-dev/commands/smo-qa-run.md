---
description: QA executes the validation suite per accepted handover brief. Produces QA report + decision - pass / fail / escalate.
---

# /smo-qa-run

**For:** Lana after `/smo-qa-handover-score` returned ≥80.
**When:** Accepted handover. Executing QA now.

## Workflow

0. Read `.smorch/project.json` for QA policy:
   - `locale` (default `"ar-MENA"`): `"ar-MENA" | "en-US" | "mixed"` — drives MENA check gating
   - `qa.rollback_drill` (default `"required"`): `"required" | "optional"` — CEO-gated per project (PR-level review)
1. Read accepted handover brief
2. Follow test scenarios in order: happy → empty → error → edge
3. For each scenario:
   a. Execute setup steps
   b. Perform actions
   c. Compare observed vs expected
   d. Screenshot + log output
4. MENA checks — gated on `locale`:
   - `ar-MENA` or `mixed` → run arabic-rtl-checker + mena-mobile-check (375px) + Arabic axe pass
   - `en-US` → skip all three. Report notes: `MENA checks: SKIPPED (locale=en-US)`
5. Run axe-core accessibility scan (English pass, all locales)
6. Check staging `/api/health` endpoint
7. Rollback drill — gated on `qa.rollback_drill`:
   - `required` → execute dry-run `/smo-rollback`; failure blocks QA PASS
   - `optional` → skip. Report notes: `Rollback drill: SKIPPED (qa.rollback_drill=optional per .smorch/project.json)`. Requires CEO approval in the PR that flipped this flag.
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

## MENA checks (locale=ar-MENA)
- Arabic RTL: ✅
- Mobile 375px: ✅
- axe-core (Arabic pass): ✅ 0 violations

## axe-core (English pass, all locales)
- 0 violations

## Rollback drill (dry-run) — required
- `/smo-rollback --dry-run PR-47`: ✅ would succeed, SLA 90s

<!--
Alternative report lines when gates are skipped:
- MENA checks: SKIPPED (locale=en-US per .smorch/project.json)
- Rollback drill: SKIPPED (qa.rollback_drill=optional per .smorch/project.json, CEO-approved PR #{flip-pr})
-->


## Decision: FAIL
Return to dev. Blocker: error state crash in draft endpoint.
```

## Lana's signing rule

If ≥1 scenario fails and dev argues "that's out of scope," Lana checks the handover brief section 4 (Risk Disclosure). If untested area was flagged → it's out of scope, ok. If not flagged → it's a true fail, dev fixes.
