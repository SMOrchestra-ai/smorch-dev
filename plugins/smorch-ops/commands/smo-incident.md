---
description: SEV1-4 incident post-mortem generator. Follows SOP-10 structure. Distinct from /smo-triage (live diagnostic) — this is the WRITE-UP.
---

# /smo-incident

**Scope:** Generate + file a SEV1-4 incident post-mortem.
**When:** After triage + fix. Before closing the incident ticket.

## SEV classification (per SOP-10)

| Level | Definition | Response time | Who |
|-------|-----------|---------------|-----|
| SEV1 | Revenue-critical outage, data loss, security breach | Immediate | Mamoun + Lana + all hands |
| SEV2 | Major feature down, significant degradation | <30 min | Mamoun or Lana |
| SEV3 | Minor feature down, workaround exists | <2h | Whoever owns the area |
| SEV4 | Cosmetic, unusual-but-handled | Next sprint | Backlog |

## L3 cascade (per SOP-36)

| Step | L3 Skill | When | Owner |
|------|----------|------|-------|
| Root-cause analysis | `superpowers:systematic-debugging` | Step 4 (the "why" before the write-up) | superpowers |

L2: incident-runbook owns the SOP-10 structure (detect/ack/mitigate/resolve/review). L3 owns the analytical method (hypothesis → evidence → root cause).

## Workflow

1. Read `docs/triage/` for the associated triage report (if /smo-triage was run first)
2. Auto-populate from git + system logs:
   - Timestamp start/end (from Telegram alerts + /smo-deploy logs)
   - Affected apps/servers
   - Commits involved
   - Deploy/rollback log if applicable
3. Prompt operator to fill:
   - SEV classification
   - Blast radius (users affected, revenue impacted, data lost)
   - Timeline (detect → ack → mitigate → resolve)
4. **L3 superpowers:systematic-debugging** — drives root-cause analysis before write-up:
   - Hypothesis enumeration (≤3, ranked by likelihood)
   - Evidence gathering (logs, git blame, deploy/canary deltas, related incidents)
   - Root cause statement (one sentence, falsifiable)
   - Why current safeguards missed it (which hat / check / SOP)
5. Auto-generate action items:
   - If no regression test exists for the cause → append to backlog
   - If drift was involved → propose canonical update
   - If human error → propose SOP tightening
6. Save to `docs/incidents/YYYY-MM-DD-SEV{n}-{slug}.md`
7. Append row to `docs/incidents/trend.csv`
8. For SEV1/2: send summary via Telegram to Mamoun
9. If recurring pattern → append lesson to `smorch-brain/canonical/lessons.md`

## Arguments

- `$ARGUMENTS` — incident slug (e.g., "eo-prod-rate-limit-bypass")
- `--sev {1-4}` — classification
- `--auto` — generate from triage report without prompts (for already-documented incidents)

## Template structure (from QA/templates/INCIDENT-REPORT.md)

```markdown
# SEV{n} — {title}

**Date:** {date}
**Duration:** {start}  →  {end}  ({minutes}m)
**Classification:** SEV{n}
**Status:** RESOLVED / ONGOING / MONITORING

## Blast radius
- Users affected: {count or %}
- Revenue impact: {$amount or N/A}
- Data loss: {yes/no + scope}
- External communication needed: {yes/no}

## Timeline (Dubai time)
| Time | Event |
|------|-------|
| 14:03 | Anomaly detected — {how} |
| 14:07 | Acknowledged by {person} |
| 14:15 | Mitigation started — {what} |
| 14:22 | Fix deployed — commit {sha} |
| 14:30 | Health green, monitoring |
| 14:45 | Resolved + incident file created |

## What happened
{2-3 sentences, factual}

## Root cause
{One sentence.}

## Why current safeguards missed it
{Honest analysis. Which hat would have caught this? Which check was skipped?}

## Action items
- [ ] {Specific, owned, dated}
- [ ] Add regression test at `tests/{path}`
- [ ] Update SOP-{N} to prevent repeat

## Lessons
{0-2 lessons worth adding to smorch-brain/canonical/lessons.md}
```

## Integration with /smo-triage

`/smo-triage` finds the root cause live. `/smo-incident` writes it up after.

Don't skip the post-mortem. Incidents without post-mortems repeat.

## Monthly review

First sprint of each month, `/smo-retro` aggregates incidents. 3+ incidents of the same class → promote the lesson to canonical + block the failure mode in CI.
