# Engineering Hat — Internal Rubric (11 questions)

**Dimension:** Is the code solid, tested, maintainable, SECURE? Includes Boris's elegance pause + 3 security questions (post-perfctl).

**Time to score:** 3-4 min per PR.

---

## Core 8 questions (each 1-10) — same as student rubric

### 1. Tests exist and cover the new code
- ✅ 10: Unit + integration, >80% coverage, all AC-N.N tagged
- ⚠️ 7: coverage 60-80%
- ❌ 4: <50% or placeholder
- 💀 1: no tests

### 2. Tests tagged with BRD acceptance criteria
- ✅ 10: every AC-N.N has matching `@AC-N.N` test
- ⚠️ 7: 80%+ tagged
- ❌ 4: tests exist but untagged
- 💀 1: no BRD = no traceability

### 3. Error handling on every external call
- ✅ 10: try/catch + user-facing fallback on every fetch/Supabase/Claude/etc.
- ⚠️ 7: 1-2 unhandled
- ❌ 4: happy path only
- 💀 1: no error handling

### 4. Types strict (TypeScript)
- ✅ 10: strict. No `any`. No `@ts-ignore` without comment.
- ⚠️ 7: 1-2 `any` with comment
- ❌ 4: several `any`
- 💀 1: strict off

### 5. Elegance pause honored
- ✅ 10: paused + documented in PR description
- ⚠️ 7: paused, accepted first solution
- ❌ 4: didn't pause
- 💀 1: obviously hacky

### 6. No dead code
- ✅ 10: every line live
- ⚠️ 7: 1-2 "TODO clean later"
- ❌ 4: blocks of commented code
- 💀 1: 30%+ dead

### 7. Secrets in .env (never in code)
- ✅ 10: `.env.local` gitignored + `.env.example` with placeholders
- ⚠️ 7: 1 "TEMP" hardcoded
- ❌ 4: several hardcoded
- 💀 1: production keys in repo

### 8. npm audit + cost-tracker
- ✅ 10: `npm audit --audit-level=high` = 0 AND cost-tracker no flags
- ⚠️ 7: 1-2 high, documented OR cost flag with justification
- ❌ 4: several high OR unjustified cost flag
- 💀 1: known CVE OR cost regression >3× unjustified

---

## 3 security questions (INTERNAL ONLY — post-perfctl)

### 9. Server posture verified (if deploy touches a server)
- ✅ 10: `/smo-health` confirms UFW active, fail2ban running, SSH key-only, no process masqueraders
- ⚠️ 7: most green, 1 warning
- ❌ 4: some hardening missing
- 💀 1: SSH password auth OR UFW disabled OR fail2ban missing

**Rule:** if PR deploys to a server, `security-hardener` skill MUST be run first. Skipping = Q9 ≤ 3.

### 10. CVE scan clean on production-path deps
- ✅ 10: 0 high/critical CVEs on prod-path deps
- ⚠️ 7: 1-2 non-exploitable, mitigation documented
- ❌ 4: high CVE present but not in production path
- 💀 1: critical CVE in prod-path dep (e.g., auth library)

### 11. SSH + secrets rotation compliant
- ✅ 10: all secrets rotated <90 days per SOP-16, SSH keys <1 year
- ⚠️ 7: secrets fresh but SSH key >1 year
- ❌ 4: some secrets >90 days
- 💀 1: production secrets never rotated

---

## Boris elegance pause (non-negotiable)

Same rule as eo-microsaas-dev: "Knowing everything I know now, would I implement this the same way?"
- Yes confident → 10 possible
- Yes with tweaks → document, 8-9
- No or "not sure" → REFACTOR. Caps at 7.

## Scoring formula

11 questions, average to 10-point scale:
```
engineering_hat = sum(Q1..Q11) / 11  # rounded to nearest 0.5, capped at 10
```

## Red flags forcing Engineering ≤ 6

- No tests for new code
- Types disabled
- Error paths not handled
- Elegance pause skipped on non-trivial PR
- Q9 below 7 (security posture gap)

## Red flags forcing Engineering ≤ 3

- Secrets committed (rotate immediately — SEV1)
- Known CVE in prod-path dep
- SSH password auth on any server
- UFW disabled on any production server
- fail2ban missing on any production server

## Calibration

See `calibration-examples.md` — real SMO PRs scored.
