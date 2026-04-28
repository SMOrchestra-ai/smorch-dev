---
description: SSH deploy via ecosystem.config.js. Project-aware (reads .smorch/project.json). Runs drift check pre+post. Rollback on health check fail.
---

# /smo-deploy

**Scope:** Push a shipped PR to a target server. Verify health. Rollback on failure.
**When:** After `/smo-ship` merged + tagged. Ready for server.

## L3 cascade (per SOP-36)

| Step | L3 Skill | When | Owner |
|------|----------|------|-------|
| Post-deploy canary | `gstack:canary` | Always after step 6 (health 200 OK) | gstack |

L2: deploy-pipeline runbook owns SSH/PM2/drift. L3 owns post-deploy regression watch.

## Workflow

1. Read `.smorch/project.json` for deploy target (staging | production | both)
2. Verify pre-conditions:
   - Score ≥ 92 (from latest `docs/qa-scores/`)
   - QA passed (from latest `docs/qa/`)
   - Tag exists on remote
3. Run `/smo-drift --pre` on target server (fail if drifted)
4. SSH to target:
   - `cd {deploy_path}` (from project.json)
   - `git fetch origin && git checkout {tag}`
   - `npm ci --production`
   - `npm run build`
   - `pm2 reload {pm2_process_name}`
5. Wait 10s
6. Hit `/api/health` endpoint → verify 200 + commit SHA matches deploy
7. **L3 gstack:canary** — post-deploy regression watch (60-300s window):
   - Console errors via browse daemon
   - Performance regressions vs last deploy baseline
   - Page failures on top-3 routes
   - Compares against baseline in `docs/canary/baseline.json`
   - If any tracked metric regresses or any page errors → trigger /smo-rollback --auto + SEV2 alert
8. Run `/smo-drift --post` (confirm clean)
9. Log deploy to `docs/deploys/YYYY-MM-DD-{tag}.md` (includes canary delta)
10. Telegram notify: "✅ {project} v{tag} deployed to {target} — canary clean"

## Failure handling

- Step 4 fails (build/pm2) → immediate rollback via `/smo-rollback --auto`
- Step 6 fails (health check) → `/smo-rollback --auto` + Telegram SEV2 alert
- Step 7 fails (canary regression) → `/smo-rollback --auto` + SEV2 alert with canary report attached
- Step 8 fails (drift detected) → `/smo-rollback --auto` + SEV1 alert (something changed server-side mid-deploy)

## Arguments

- `--target staging` | `--target production` | `--target both` (default: both in sequence)
- `--dry-run` — show what would happen, don't SSH
- `--force` — skip score gate check (requires Mamoun explicit approval, logs audit)

## Reads from project.json

```json
{
  "deploy": {
    "staging": {
      "host": "smo-dev",
      "path": "/opt/apps/eo-mena",
      "pm2_name": "eo-main",
      "branch": "dev",
      "health_url": "https://dev.entrepreneursoasis.me/api/health"
    },
    "production": {
      "host": "eo-prod",
      "path": "/opt/apps/eo-mena",
      "pm2_name": "eo-main",
      "branch": "main",
      "health_url": "https://entrepreneursoasis.me/api/health"
    }
  }
}
```

## Never

- Never edit files directly on the server (enforced by NewDesktop/Manual rule)
- Never deploy without a tag (/smo-ship must succeed first)
- Never deploy on Fri after 2pm Dubai (MENA weekend starts — rollback window shrinks)

## Output

```
✅ Deploy complete

**Project:** eo-mena
**Target:** production (eo-prod)
**Tag:** v1.4.2
**Commit:** a3f4e21
**Health check:** 200 OK (commit SHA matched)
**Drift check:** clean (pre + post)
**Deploy time:** 87s

Log: docs/deploys/2026-04-19-v1.4.2.md
```
