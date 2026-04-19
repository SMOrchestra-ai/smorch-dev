---
name: rollback-runbook
description: |
  Rollback procedure. Invoked by /smo-rollback. SSH to target, check out previous tag, rebuild,
  reload PM2, verify health. Target SLA 90-120s per project. Includes DB migration reversibility handling.
---

# rollback-runbook — Deploy's Twin

**Invoked by:** `/smo-rollback`
**Uses:** Same `.smorch/project.json` deploy config as deploy-pipeline

## The rollback flow

```
1. identify-previous → read docs/deploys/*.md, find most recent tag before current
2. preflight         → confirm previous tag builds cleanly (rare edge: previous tag broken)
3. ssh-connect       → Tailscale IP from project.json
4. checkout-prev     → cd {path} && git fetch && git checkout {previous_tag}
5. install           → npm ci --production
6. build             → npm run build
7. migration-check   → if reversibility="auto" → npm run db:rollback; if "manual" → prompt
8. reload            → pm2 reload {pm2_name}
9. sleep             → wait 10s
10. health-check     → curl {health_url} → expect 200 + commit SHA match previous tag
11. log              → docs/deploys/YYYY-MM-DD-rollback-{from}-to-{to}.md
12. telegram         → SEV2 alert + outcome
```

## SLA per project (from .smorch/project.json)

```json
{"deploy": {"production": {"rollback_sla_seconds": 90}}}
```

Breached SLA → log to `docs/incidents/sla-breaches.csv`.

## Failure modes

| Stage | Failure | Action |
|-------|---------|--------|
| 2 preflight | Previous tag doesn't build | SEV1: both current + previous broken. Escalate Mamoun. |
| 7 migration | Reversibility "none" | Halt rollback. Prompt: "This migration is irreversible. Proceed with forward-fix instead?" |
| 10 health check | Previous tag health fails | SEV1 ditto — no known-good version. Manual intervention. |

## Data migration reversibility (3 modes)

Per `.smorch/project.json`:

### "auto"
Migrations must be idempotent + reversible. `npm run db:rollback` script exists. Executed as step 7.

### "manual"
Rollback halts at step 7, prompts operator: "Run manual migration rollback? (y/n)". Operator runs SQL manually then resumes.

### "none"
Cannot rollback code because data schema changed irreversibly. Only forward-fix allowed. Rollback halts with error.

## Integration with /smo-incident

After rollback, `/smo-incident` is typically the next command. The rollback log auto-references the incident file:

```markdown
Rollback from v1.4.2 → v1.4.1
Triggered by: /smo-deploy --auto (health check failed)
Post-mortem: docs/incidents/2026-04-19-SEV2-rate-limit-bypass.md
```

## Rule

Rollbacks are first-class. Using one is not a failure — hiding one is. Log every rollback to trend.csv so monthly /smo-retro can surface deploy quality patterns.

## Rollback drill (required quarterly)

Per SOP-15, every project runs a rollback drill quarterly:
1. Deploy a throwaway PR to staging
2. Run `/smo-rollback --dry-run`
3. Verify SLA + health check pass predictions
4. If drill fails → project.json rollback config is stale, fix before next ship

Drills are tracked in `docs/drill-log.md`.
