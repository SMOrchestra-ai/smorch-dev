---
name: incident-runbook
description: |
  SEV1-4 incident response runbook. Drives /smo-incident command. Enforces SOP-10 structure
  (detect, ack, mitigate, resolve, review). Provides operator with the right question at the
  right time. Replaces ad-hoc Slack triage with disciplined, repeatable flow.
---

# incident-runbook — SEV1-4 Response Protocol

**Goal:** Reduce MTTR. Produce post-mortems that actually prevent recurrence.

## The 5 phases

### Phase 1 — Detect (goal: ack within SLA)

Entry points:
- Telegram alert from `check-config-drift.sh` / `check-skill-drift.py` cron
- `/smo-health` red flag
- User/customer report via Intercom/email
- On-call monitoring (future)

**Action:** whoever sees first → acks in Telegram within SLA (SEV1 <5 min, SEV2 <30 min, SEV3 <2h)

### Phase 2 — Classify

Decision tree (5 questions):
1. Is revenue directly affected? → SEV1
2. Is a major feature down with no workaround? → SEV2
3. Is a minor feature broken with workaround? → SEV3
4. Cosmetic / unusual-but-handled? → SEV4

Then declare in Telegram: "🔴 SEV{n}: {one-line-symptom}"

### Phase 3 — Mitigate

SEV1/2: stop the bleeding FIRST, understand SECOND.
- Rollback candidate? → `/smo-rollback`
- Recent drift? → `/smo-drift --target {host}` → `--fix` if safe
- Secret compromised? → rotate immediately via `/smo-secrets --rotate`
- Overloaded server? → pm2 scale or temp maintenance page

SEV3/4: understand first, mitigate deliberately.

### Phase 4 — Resolve (verify green)

- `/smo-health` returns all green
- Original repro steps no longer reproduce the failure
- Monitoring shows sustained normal for 15+ min
- Announce RESOLVED in Telegram

### Phase 5 — Review (within 48h)

- Run `/smo-incident` to generate post-mortem
- Fill in timeline + root cause + action items
- Commit to `docs/incidents/`
- Action items tracked in Linear
- Lesson added to `smorch-brain/canonical/lessons.md` if pattern

## Templates per SEV

### SEV1 incident file

Must include:
- Executive summary (3 sentences, readable by non-tech stakeholder)
- Blast radius: users, $ impact, data
- Timeline to the minute
- Root cause (1 sentence)
- Why current safeguards missed it
- Action items with owners + dates

### SEV2/3/4

Abbreviated template — timeline + root cause + action items only.

## Rules during active incident

1. **Pair-review destructive commands.** Rollback, restart, DB writes — second pair of eyes before execute.
2. **Announce every action in Telegram.** "running /smo-rollback on eo-prod" — so others don't duplicate.
3. **Don't fix drift during an incident** unless drift is the cause. (`/smo-drift --fix` during unrelated SEV could hide state.)
4. **Time-box mitigation attempts.** 30 min of no progress on SEV1/2 → escalate to Mamoun even if you think you're close.

## Anti-patterns

- Fixing without acknowledging (silent mitigation = same incident repeats because nobody learned)
- Closing without post-mortem (48h rule — if post-mortem not filed, incident auto-reopens)
- "Resolved: restarted the service" as root cause (restart is mitigation, not RCA)
- Blaming a person instead of a system gap (every RCA asks: why did the system allow this?)

## Integration

- `/smo-triage` → live diagnostic (what's happening NOW)
- `/smo-incident` → write-up (what happened, why, prevent)
- `incident-runbook` (this) → the protocol the operator follows

## SLA targets

| SEV | Ack | Mitigate | Resolve | Review |
|:---:|:---:|:--------:|:-------:|:------:|
| 1 | 5 min | 30 min | 2h | 48h |
| 2 | 30 min | 2h | 8h | 72h |
| 3 | 2h | 24h | 1 sprint | 1 sprint |
| 4 | 24h | next sprint | when convenient | optional |

Breached SLA → logged in `docs/incidents/sla-breaches.csv`. 3 breaches in 30 days → protocol review.
