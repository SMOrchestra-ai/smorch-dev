# Internal Calibration Examples — Real SMO PRs

**Ship gate:** 92 internal (vs 90 student).
**Re-read before first score each sprint.**

These will be backfilled with real PRs during Phase 7. Until then, use the examples below as synthetic but realistic benchmarks based on past SMO work.

---

## Example 1: `feat: signal-sales-engine email draft endpoint` — Composite 94 SHIP

**Context:** Signal-Sales-Engine, new /api/draft endpoint, Claude API integration, MENA-first

| Hat | Score | Why |
|-----|:-----:|-----|
| Product | 9.5 | BRD AC-3.1/3.2/3.3 all covered. ICP (MENA B2B SaaS founders). Out-of-scope noted. |
| Architecture | 9 | Clean `/lib/claude/draft.ts` + `/app/api/draft/route.ts`. Types strict. |
| Engineering | 9.5 | Tests tagged @AC-3.1/3.2/3.3. Try/catch on Claude API. No `any`. Elegance pause documented. Q9 security 10 (smo-dev already hardened). |
| QA | 9 | Happy + rate-limit + Claude-down all tested. Handover score 88 (Lana accepted). |
| UX | 10 | N/A UI this PR, but API response format matches UX-reference artifact. |

**Composite: (9.5+9+9.5+9+10) × 2 = 94 ✅ SHIP**

---

## Example 2: `feat: eo-mena pricing page refresh` — Composite 87 → 92 after bridge-gaps

**Context:** EO-MENA cosmetic rewrite with 1 new framer-motion dep

| Hat | Score | Why |
|-----|:-----:|-----|
| Product | 9 | BRD existed. MENA-appropriate copy (no buzzwords). |
| Architecture | 7 | Framer-motion adds 80KB; justified in PR but no bundle comment. |
| Engineering | 7.5 | Tests happy-path only. Elegance pause skipped. 1 `any` type. |
| QA | 9 | Arabic RTL tested. Mobile 375px tested. |
| UX | 10 | Matches product-demo.html artifact. AppSumo-inspired. |

**Composite: (9+7+7.5+9+10) × 2 = 85 initial → BRIDGE-GAPS.**

Engineering 7.5 < 8.5 floor. Ran /smo-bridge-gaps: added bundle comment, wrote empty-state test, killed the `any`. Engineering → 9 → composite 91. Second bridge-gaps on Architecture: bundle size comment landed. Architecture → 8.5. Final composite 92. SHIP.

---

## Example 3: `fix: eo-prod nginx rate-limit bypass on /api/webhook` — Composite 96 SHIP

**Context:** Post-perfctl hardening PR, 40-line change, SEV2 fix

| Hat | Score | Why |
|-----|:-----:|-----|
| Product | 10 | Fixes explicit AC-5.2 (webhook must rate-limit). |
| Architecture | 9 | One file touched. No new deps. |
| Engineering | 9.5 | Regression test reproduced the bypass. Elegance pause documented. Security Q9 10, Q10 10, Q11 10. |
| QA | 10 | Reproduced with curl+jq. Lana validated on stage. |
| UX | 10 | N/A server-side. |

**Composite: (10+9+9.5+10+10) × 2 = 97 → rounded 96 after Lana noted missing log format update. SHIP.**

---

## Example 4: `feat: saasfast MVP landing page` — Composite 78 REJECTED

**Context:** New project, rushed BRD

| Hat | Score | Why |
|-----|:-----:|-----|
| Product | 6 | BRD 3 lines. No ICP specificity. "Leverage" used twice in copy. |
| Architecture | 7 | 4 new npm deps unjustified. |
| Engineering | 6 | No tests. Types loose. Elegance pause skipped. |
| QA | 8 | Manually clicked, mobile works. |
| UX | 10 | Looks good desktop only. |

**Composite: (6+7+6+8+10) × 2 = 74 → rescored 78 after minor fixes.**

**REJECTED.** Multiple hats below 8.5 floor, composite below 85. Return to `/smo-plan`. Write BRD properly. Remove buzzwords. Add tests.

**Lesson L-007 added:** SaaSFast MVP cannot skip BRD even for "just a landing page."

---

## Calibration targets

| PR type | Target composite | Notes |
|---------|:----------------:|-------|
| Bug fix (SEV2) | 92-96 | narrow, tight |
| New feature with BRD | 92-95 | standard |
| Cosmetic/copy rewrite | 85-92 (bridge-gaps common) | |
| Emergency hotfix (SEV1) | 88-94 | skip some rigor, document |
| Refactor only | 90-95 | strong engineering bar |

## Monthly calibration review

First sprint of each month, run `/smo-retro` across all projects. Compare your self-scores to Lana's QA scores. Delta > 5 points consistently = you're over-scoring. Adjust the rubric reading, not the number.
