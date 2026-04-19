---
name: drift-detector
description: |
  On-demand drift diagnostic. Complements (does not replace) hourly check-config-drift.sh and
  6h check-skill-drift.py crons. Powers /smo-drift command. Produces current-state report by
  SSHing each target + hashing files + comparing to canonical.
---

# drift-detector — On-Demand Drift Diagnostic

**Invoked by:** `/smo-drift`
**Canonical source:** `smorch-brain/canonical/` (snapshots of expected state)

## What drifts, what's tracked

### Config files (per machine)
- `/root/.claude/settings.json` (or `~/.claude/settings.json` on Mac)
- `/root/.claude/CLAUDE.md`
- `/root/.claude/.mcp.json`

### Skills (per machine)
- Hash of each file under `~/.claude/skills/*/SKILL.md`
- Plus `~/.claude/plugins/*/plugin.json`

### Plugin versions
- `smorch-dev` + `smorch-ops` versions from plugin.json

### Canonical snapshots
- `smorch-brain/canonical/skills-manifest.json` (16-char hashes per skill)
- `smorch-brain/canonical/config/` (expected settings.json, CLAUDE.md, .mcp.json per profile)

## The check flow

```
1. Read canonical/ snapshots
2. Read smorch-brain/servers.txt (or subset via --target)
3. For each target machine:
   a. SSH + compute hashes of tracked files
   b. Compare hash-by-hash to canonical
   c. Categorize: CLEAN | DRIFT | MISSING
4. Aggregate → docs/drift-reports/YYYY-MM-DD-HHMM.md
5. If any DRIFT or MISSING:
   - Telegram alert (CHAT_ID 311453473)
   - Exit non-zero (blocks /smo-deploy if used as pre-check)
```

## Comparison precision

- Config files: full SHA-256 hash match required
- Skill files: file-by-file SHA-256 — order doesn't matter, presence + content does
- Plugin versions: exact semver match

## `--fix` mode (destructive, confirmation required)

For a drifted file:
1. Show diff between canonical and actual
2. Prompt: "Overwrite {file} on {host} with canonical? (yes/no)"
3. On "yes" → rsync canonical → machine
4. Re-hash, confirm clean
5. Log to `docs/drift-reports/fixes.csv`

Never run `--fix` during an active SEV (could hide the cause).

## Canonical update flow

If the drift is INTENTIONAL (e.g., added a new MCP server, new skill):
1. Don't `--fix`
2. Instead: `bash smorch-brain/scripts/update-canonical.sh {machine} {file}`
3. Commits canonical with new hash
4. Future drift checks now pass

This is the "promote machine state → canonical" path. `--fix` is the "enforce canonical → machine" path. Both are legitimate; operator chooses which is true.

## Why two tiers (cron + command)

- **Cron** (hourly config, 6h skills): passive monitoring, always on
- **Command** (`/smo-drift`): active investigation, on-demand, more detailed report

The cron catches drift within hours. The command catches it within seconds of asking.

## Integration with /smo-deploy

`/smo-deploy` runs `/smo-drift --pre` before step 4 (git checkout). If drift found on target → deploy halts. This prevents deploying on top of an unknown state.

## Integration with /smo-health

`/smo-health` calls this skill with `--posture-only` to verify config files match canonical (quick check). For full skill-level drift, use `/smo-drift` directly.

## Output example

```
## Drift report — 2026-04-19 14:23

Scope: all machines (5 targets)
Canonical date: 2026-04-15 (3 days old — acceptable)

| Machine | Config | Skills | Version | Status |
|---------|:------:|:------:|:-------:|--------|
| eo-prod | ✅ | ✅ | v1.0.0 | CLEAN |
| smo-prod | ✅ | ⚠️ 1 missing | v1.0.0 | DRIFT |
| smo-dev | ✅ | ✅ | v1.0.0 | CLEAN |
| smo-eo-qa | ⚠️ .mcp.json | ✅ | v1.0.0 | DRIFT |
| lana-win | ✅ | ✅ | v1.0.0 | CLEAN |

### Drift details

**smo-prod — missing skill:**
skills/smo-scorer/calibration-examples.md not found
Expected hash: 7d4f2a9e... | Actual: (file absent)
Action: /smo-drift --fix --target smo-prod (requires confirmation)

**smo-eo-qa — config drift:**
/root/.claude/.mcp.json
Diff: +1 line (added "mcp-notion" — was this intentional?)
Action: Either promote via update-canonical.sh or rollback via --fix
```
