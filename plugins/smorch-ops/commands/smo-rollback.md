---
description: One-command rollback of a deploy. Reverts to previous tag + restarts + verifies health. Deploy's twin.
---

# /smo-rollback

**Scope:** Revert a deploy. **Does NOT revert code in git** (that's separate concern).
**When:** Deploy failed health check | Lana's QA on production surfaced regression | SEV1/2 incident.

## Workflow

1. Read `docs/deploys/` to find the PRE-current deploy (what was live before current)
2. Confirm target server + path from `.smorch/project.json`
3. SSH to target:
   - `cd {deploy_path}`
   - `git fetch origin`
   - `git checkout {previous_tag}`
   - `npm ci --production`
   - `npm run build`
   - `pm2 reload {pm2_process_name}`
4. Wait 10s
5. Hit `/api/health` → verify 200 + commit SHA matches previous tag
6. Log to `docs/deploys/YYYY-MM-DD-rollback-{from}-to-{to}.md`
7. Telegram SEV2 alert: "⚠️ {project} rolled back {current_tag} → {previous_tag}"
8. If triggered by `/smo-deploy --auto`: append to deploy log as failure cause
9. Open incident via `/smo-incident` if rollback was operator-triggered (vs auto-rollback)

## Arguments

- `--auto` — called from failed `/smo-deploy`, suppress interactive prompts
- `--to {tag}` — rollback to specific tag (vs "previous")
- `--dry-run` — show what would happen, don't SSH

## SLA

Target: complete rollback in < 2 minutes. Measured from command start to `/api/health` green.

Project-specific override in `.smorch/project.json`:
```json
{"deploy": {"rollback_sla_seconds": 120}}
```

## Failure handling

- Step 3 fails (build/pm2) on previous tag → SEV1 escalation: previous tag doesn't build cleanly (shouldn't happen — means previous deploy was bad). Ping Mamoun immediately.
- Step 5 fails (health check on previous tag) → SEV1: neither current nor previous works. Manual intervention.

## Output

```
✅ Rollback complete

**Project:** eo-mena
**Target:** production (eo-prod)
**From:** v1.4.2 → **To:** v1.4.1
**Commit:** b2c5d82
**Health check:** 200 OK
**Rollback time:** 94s (within SLA)

Log: docs/deploys/2026-04-19-rollback-v1.4.2-to-v1.4.1.md
Triggered by: /smo-deploy --auto (health check failed)

Next: /smo-incident to write post-mortem
```

## Data migration caveat

Rollbacks handle CODE. They do NOT reverse DB migrations. If a migration ran as part of the failed deploy, check `.smorch/project.json` → `deploy.migration_reversibility`:
- `"auto"` — rollback includes `npm run db:rollback`
- `"manual"` — rollback prompts dev for next action
- `"none"` — rollback halts, requires explicit Mamoun approval

## Rule

The rollback command is documented. Using it isn't a failure — it's the system working. Hiding rollbacks is the failure.
