---
name: deploy-pipeline
description: |
  SSH-based deploy flow for SMOrchestra servers. Reads .smorch/project.json for target config,
  pulls tag, builds, reloads PM2, verifies health, supports rollback. The substrate /smo-deploy
  uses. No docker-compose or k8s complexity — matches the reality of our 4 servers.
---

# deploy-pipeline — SSH Deploy Substrate

**Invoked by:** `/smo-deploy`
**Reads:** `.smorch/project.json` for server + path + PM2 process
**Does NOT:** docker-compose, k8s, blue-green. (YAGNI — 4 servers, direct PM2.)

## The pipeline (10 steps)

```
1. preflight        → verify tag exists, score ≥ 92, QA passed
2. drift-check-pre  → /smo-drift --pre --target {host}
3. ssh-connect      → verify SSH reachable (Tailscale preferred)
4. git-checkout     → cd {path} && git fetch && git checkout {tag}
5. install          → npm ci --production
6. build            → npm run build
7. reload           → pm2 reload {pm2_name} (zero-downtime)
8. sleep            → wait 10s for app boot
9. health-check     → curl {health_url} → expect 200 + commit SHA match
10. drift-check-post→ /smo-drift --post --target {host}
```

Any step fails → trigger `rollback-runbook` skill → `/smo-rollback --auto`.

## Project.json contract

```json
{
  "deploy": {
    "staging": {
      "host": "smo-dev",
      "tailscale_ip": "100.83.242.99",
      "path": "/opt/apps/eo-mena",
      "pm2_name": "eo-main-staging",
      "branch": "dev",
      "health_url": "https://dev.entrepreneursoasis.me/api/health",
      "rollback_sla_seconds": 120,
      "migration_reversibility": "manual"
    },
    "production": {
      "host": "eo-prod",
      "tailscale_ip": "100.89.148.62",
      "path": "/opt/apps/eo-mena",
      "pm2_name": "eo-main",
      "branch": "main",
      "health_url": "https://entrepreneursoasis.me/api/health",
      "rollback_sla_seconds": 90,
      "migration_reversibility": "auto"
    }
  }
}
```

## Never

- Never `git reset --hard` on server (old deploy script did this — destructive, obscures local changes)
- Never deploy without /smo-drift pre-check (perfctl lesson)
- Never skip health check (step 9) — it's the ground truth
- Never deploy Friday 2pm Dubai + (MENA weekend — rollback window collapses)

## Health check expectation

`/api/health` on every app MUST return:
```json
{
  "status": "ok",
  "commit": "<git short sha>",
  "uptime_seconds": 42,
  "deps": {
    "supabase": "ok",
    "anthropic": "ok"
  }
}
```

If any app's `/api/health` doesn't conform → blocking issue before /smo-deploy can target it.

## Integration

- Upstream: `/smo-ship` (must succeed first)
- Downstream: `/smo-rollback` (auto-triggered on failure)
- Verification: `/smo-health` (post-deploy dashboard)

## Script location

Actual shell script at `scripts/deploy.sh` (one file, ~80 lines). Per-project overrides in `.smorch/deploy.sh` (optional, extends default).
