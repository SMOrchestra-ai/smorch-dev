---
description: On-demand drift diagnostic across machines. Complements (does NOT replace) the hourly check-config-drift.sh and 6h check-skill-drift.py crons.
---

# /smo-drift

**Scope:** Run a single drift check on one or all machines. Produces a current-state report.
**When:** Before deploy, during incident, when Telegram alert fires and you want to inspect NOW (not wait 6h).

## Workflow

1. Read `smorch-brain/canonical/` snapshots (config + skills manifest)
2. Read `smorch-brain/servers.txt` for target machines
3. For each target (default all):
   - SSH + compute hashes of `/root/.claude/settings.json`, `CLAUDE.md`, `.mcp.json`, skill dirs
   - Compare to canonical
   - Report per-file status: clean | drift | missing
4. Aggregate → write `docs/drift-reports/YYYY-MM-DD-HHMM.md`
5. If drift found on any target:
   - Telegram alert to CHAT_ID 311453473 (same channel as cron alerts)
   - Exit 1 (command fails — blocks /smo-deploy if invoked as pre-check)

## Arguments

- `--target {host}` — single machine (from servers.txt)
- `--pre` — invoked by /smo-deploy as pre-check (blocks deploy on drift)
- `--post` — invoked by /smo-deploy as post-check
- `--fix` — for a drifted file, rsync canonical back to machine (destructive — requires confirmation)
- `--skills-only` / `--config-only` — scope the check

## Output

```
## Drift report — 2026-04-19 14:23

| Machine | Config | Skills | Status |
|---------|:------:|:------:|--------|
| eo-prod | ✅ | ✅ | CLEAN |
| smo-prod | ⚠️ | ✅ | DRIFT (/root/.claude/.mcp.json) |
| smo-dev | ✅ | ✅ | CLEAN |
| smo-eo-qa | ✅ | ✅ | CLEAN |
| lana-win | ✅ | ⚠️ | DRIFT (missing: skills/smo-scorer) |

### Drift details: smo-prod
File: /root/.claude/.mcp.json
Canonical: 8f4c2d9a1b6e3...
Actual:    9e1a8b7c4d5f2...
Diff: 2 lines changed (added 'n8n-prod' mcp)

Action: Run /smo-drift --fix --target smo-prod --file .mcp.json (requires confirmation)
OR commit the change to smorch-brain/canonical/ if intentional.

### Drift details: lana-win
Missing skill: skills/smo-scorer
Action: bash install/qa-machine.ps1 on Lana's machine (re-sync)
```

## Relationship to the crons

| Mechanism | Frequency | Produces | Best for |
|-----------|-----------|----------|----------|
| `check-config-drift.sh` cron | Hourly | Telegram alert on drift | Passive monitoring |
| `check-skill-drift.py` cron | Every 6h | Telegram alert on drift | Passive monitoring |
| `/smo-drift` command | On-demand | Detailed report + exit code | Active investigation, pre-deploy |

The crons continue unchanged. This command is the human "I want to check NOW" entry point.

## Never

- Never `--fix` on production without confirmation + pair-review
- Never run `--fix` during an incident (fixing drift during SEV could hide the cause)
- Never skip the cron in favor of manual — cron is the baseline, command is the supplement
