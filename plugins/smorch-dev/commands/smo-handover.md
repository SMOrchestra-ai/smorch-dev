---
description: Generate dev→QA handover brief from SOP-13 template. Auto-fills PR+BRD+score+rollback. Dev fills test scenarios + risks. Required before QA starts work.
---

# /smo-handover

**Pillar:** SOP-13 (Lana Handover Protocol)
**When:** After `/smo-score` returns 92+. Before Lana starts QA.

## Workflow

1. Invoke `handover-generator` skill
2. Auto-fill from git + filesystem:
   - PR number, URL, branch
   - BRD ACs covered (from @AC-N.N test tags)
   - Env vars (diff `.env.example`)
   - Score report (latest `docs/qa-scores/`)
   - Rollback command (from `.smorch/project.json` → `deploy.rollback_template`)
3. Prompt dev to fill:
   - Happy / empty / error / edge test scenarios
   - Known issues + untested areas
   - Seed data + feature flags
4. Dev reviews + signs off
5. Commit to `docs/handovers/YYYY-MM-DD-PR-{n}-handover.md`
6. Run `--validate` → check all 5 sections have content, PR URL resolves
7. Run `--notify` → Telegram ping to Lana with link

## Arguments

- `--validate` (check completeness before notifying)
- `--notify` (send Telegram ping to Lana after validate passes)

## Gate

Cannot proceed to `/smo-ship` until:
- Handover brief exists at `docs/handovers/`
- Validation passes
- Lana's `/smo-qa-handover-score` returns ≥80

## Integration

Lana receives the Telegram ping. Runs `/smo-qa-handover-score {handover-path}`. If ≥80, starts QA. If <80, sends back with fixes. See `qa-handover-scorer` skill + SOP-13.
