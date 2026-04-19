# Guide — QA Workflow (Lana)

**Audience:** Lana (half QA, half Dev).
**Time:** 30-60 min per handover.
**Tone:** direct. No fluff.

---

## Daily flow

```
Morning: Telegram ping from @smo_drift_alert_bot or direct from Mamoun
         → new handover ready
         
For each handover:
  1. /smo-qa-handover-score {path}     # accept / send back / reject
  2. If accepted: /smo-qa-run          # execute test scenarios
  3. Update Linear ticket status
  4. Reply in Telegram: pass / fail / blocker
```

---

## The 5-dimension handover scorecard

Before ANY testing, score the brief:

| Dimension | Key question | If <7 |
|-----------|--------------|-------|
| **Completeness** | Does it link BRD AC-N.N + PR + staging URL? | SEND BACK |
| **Testability** | Are happy/empty/error/edge explicit with steps? | SEND BACK |
| **Repro-ability** | Can you reproduce setup (env vars, seed, creds)? | SEND BACK |
| **Risk disclosure** | Are known issues + untested areas + nearby code flagged? | SEND BACK |
| **Rollback readiness** | Is rollback command explicit + SLA defined? | SEND BACK |

**Composite = avg × 2 (range 10-100):**
- **≥90** — ACCEPT, start testing
- **80-89** — ACCEPT WITH NOTES (note fixes, dev addresses in parallel)
- **60-79** — SEND BACK with specific fixes
- **<60** — AUTO-REJECT, Mamoun notified

**Run this:**
```
/smo-qa-handover-score docs/handovers/2026-04-19-PR-47-handover.md
```

Output goes to `docs/handovers/2026-04-19-PR-47-qa-score.md`. Dev gets Telegram ping on decision.

---

## Testing (after accepting the handover)

```
/smo-qa-run
```

Auto-executes for each scenario in the brief:
- Happy path (primary flow works)
- Empty state (no data — does it crash?)
- Error state (API down, timeout, 500 — does UI recover?)
- Edge cases (very long input, zero, negative, special chars)

**Plus for MENA projects (auto if `mena:true` in `.smorch/project.json`):**
- Arabic RTL layout (dir="rtl" applied correctly)
- Mobile 375px viewport
- Currency format (AED/SAR/QAR/KWD correct)
- Fri/Sat weekend logic

**Plus:**
- axe-core accessibility scan (0 violations target)
- Console errors (0 red = pass)
- `/api/health` returns 200 + commit SHA match

Output: `docs/qa/YYYY-MM-DD-PR-{n}-qa-report.md`.

---

## Decision after testing

**All pass:**
- Update Linear: status = "QA passed"
- Reply Telegram to dev: "QA passed, ready to /smo-ship"
- Score this handover good in trend.csv

**Any fail:**
- Update Linear: status = "QA failed", add comment with specific failure
- Reply Telegram: "FAIL in {scenario}. Dev returns to /smo-triage."
- Link the QA report: `docs/qa/YYYY-MM-DD-PR-{n}-qa-report.md`

**Blocker (environment problem, not dev problem):**
- Update Linear: status = "QA blocked"
- `/smo-incident` to log the blocker (usually staging down, Supabase outage, etc.)
- Telegram: "BLOCKED. Not proceeding until {env issue} resolved."

---

## The argue test

If dev says "that failure is out of scope":

1. Open the handover brief
2. Go to section 4 (Risk Disclosure — "areas I did NOT test")
3. If the failing scenario IS flagged there → dev is right, accept
4. If NOT flagged → it's a true fail, dev fixes

No negotiation beyond that. Rubric decides.

---

## Linear integration

For every handover, Linear ticket flow:

```
Dev: assigns ticket to Lana, moves to "In QA"
Lana: /smo-qa-handover-score → runs → updates ticket

Decision → Linear status:
  ACCEPT         → "In QA" (no change, you started)
  ACCEPT W/NOTES → "In QA" + comment with notes
  SEND BACK      → "Needs clarification" + comment with handover-score path
  AUTO-REJECT    → "Blocked" + tag Mamoun

After /smo-qa-run:
  PASS           → "Ready to ship"
  FAIL           → "In progress" (dev's hands) + comment with qa-report path
  BLOCKED        → "Blocked" + link incident
```

MCP handles Linear updates automatically (in `0ee06d36-...` MCP). Trigger phrases:
- "Mark Linear ticket {TKT-N} as ready to ship"
- "Move {TKT-N} to Needs clarification with note X"

---

## Timeboxing

| Activity | Target | Hard limit |
|----------|:------:|:----------:|
| Handover scoring | 5 min | 10 min |
| QA run (simple PR) | 15 min | 30 min |
| QA run (complex PR) | 45 min | 90 min |
| Send-back writeup | 5 min | 10 min |
| Incident write-up | 15 min | 30 min |

If blown by >2×: log in `docs/retro/` — may need rubric / template fix.

---

## Your own dev work

Lana ships code too. Same chain as Mamoun:
```
/smo-plan → /smo-code → /smo-score → /smo-handover (to Mamoun, he scores YOUR handover)
```

When Mamoun scores your handover, you see the same 5 dimensions. Read his feedback, apply to next handover you WRITE.

---

## Common Lana mistakes (to avoid)

- **Accepting 75-handover "to unblock"** → this kills the system. 75 means SEND BACK.
- **Starting QA without reading all of section 4 (Risk Disclosure)** → you test something dev already flagged as out-of-scope
- **Skipping the axe scan on MENA projects** → accessibility issues ship
- **Not running `/smo-drift` before QA** → you test on drifted state, inconsistent results
- **Resolving Linear without linking the QA report** → audit trail breaks

---

## Communication with Mamoun (Telegram)

- **Always link the doc**: score report, QA report, incident file. Path + one-line summary.
- **Use SEV1-4 language**: "SEV2 — eo-mena auth broken on Arabic sign-up." Not "it's broken."
- **If blocked, say so immediately**: don't spend 1h trying around it.
- **End-of-day**: short summary — 3 handovers scored, 2 passed, 1 sent back.

---

## Escalation ladder

| Issue | First step | If unresolved |
|-------|-----------|---------------|
| Handover unscorable | Send back to dev with specific Q | Ping Mamoun |
| Testing fails repeatedly same spot | `/smo-triage` pair with dev | Mamoun |
| Environment blocker | `/smo-incident` SEV3 | Mamoun + Telegram |
| Security concern during QA | STOP testing, `/smo-incident` SEV2 | Mamoun immediately |
| Dev disputes rubric | Quote the rubric line | Mamoun arbitrates |

---

## Reference

- Your command surface: 4 primary (`/smo-qa-handover-score`, `/smo-qa-run`, `/smo-triage`, `/smo-incident`)
- Your dev commands (for your own PRs): all 17 of `/smo-*`
- SOP-01 QA Protocol
- SOP-13 Lana Handover Protocol
- Rubric details: `~/.claude/plugins/smorch-dev/skills/qa-handover-scorer/SKILL.md`
