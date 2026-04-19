---
description: Multi-server health roll-up. Checks /api/health on every app across eo-prod, smo-dev, smo-prod, smo-eo-qa. Also checks UFW / fail2ban / SSH posture.
---

# /smo-health

**Scope:** Single-pane-of-glass health for all SMOrchestra production surfaces.
**When:** Morning standup, pre-deploy, post-incident, or anytime you want peace of mind.

## Workflow

1. Read `smorch-brain/canonical/project-registry.md` for all apps + their servers + health URLs
2. For each app:
   - HTTP GET `{health_url}` → expect 200 + JSON with `{status: "ok", commit: "<sha>"}`
   - Compare commit SHA vs GitHub latest tag on main
3. For each server:
   - SSH + run `ufw status | head -1` → expect "Status: active"
   - SSH + run `systemctl is-active fail2ban` → expect "active"
   - SSH + run `grep PasswordAuthentication /etc/ssh/sshd_config` → expect "no"
   - SSH + run `pm2 list --json | jq '[.[] | select(.pm2_env.status != "online")]'` → expect empty array
4. Aggregate into health report

## Arguments

- `--app {name}` — single app only
- `--server {host}` — single server only
- `--posture-only` — skip app health, only check server hardening
- `--verbose` — include per-app response times, memory usage

## Output

```
## Health report — 2026-04-19 09:14

### Apps (11 checked)
| App | Server | Health | Commit match | Response |
|-----|--------|:------:|:------------:|----------|
| eo-mena | eo-prod | ✅ 200 | ✅ | 124ms |
| eo-scoring | eo-prod | ✅ 200 | ✅ | 89ms |
| signal-sales-engine | smo-dev | ✅ 200 | ⚠️ 2 commits ahead | 67ms |
| smorch-web | netlify | ✅ 200 | ✅ | 211ms |
| saasfast | smo-prod | ❌ 503 | N/A | timeout |
| ... | ... | ... | ... | ... |

### Server posture
| Server | UFW | fail2ban | SSH key-only | PM2 all online |
|--------|:---:|:--------:|:------------:|:--------------:|
| eo-prod | ✅ | ✅ | ✅ | ✅ |
| smo-dev | ✅ | ✅ | ✅ | ⚠️ 1 stopped |
| smo-prod | ✅ | ✅ | ✅ | ⚠️ saasfast errored |
| smo-eo-qa | ✅ | ✅ | ✅ | ✅ |

### Summary
🔴 1 critical: saasfast on smo-prod (503)
🟡 2 warnings: SSE 2 commits ahead of deploy, smo-dev 1 PM2 process stopped
🟢 9 green

### Next actions
1. `/smo-triage saasfast` — investigate 503
2. `/smo-deploy --app signal-sales-engine --target staging` — catch up SSE
3. SSH smo-dev + `pm2 restart {stopped-process}`
```

## Telegram integration

If run with `--notify`, the report is posted to Telegram. Without `--notify`, output is local only (don't spam).

## Rule

Run `/smo-health` every morning. If anything is red or yellow, the sprint starts there — not at the first Slack message.
