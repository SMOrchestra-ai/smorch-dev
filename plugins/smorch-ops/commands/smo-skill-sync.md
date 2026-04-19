---
description: smorch-brain skill push/audit per SOP-12. Validates skill lock files, pushes to canonical, triggers sync-all across machines.
---

# /smo-skill-sync

**Scope:** Push skills from local dev machine → smorch-brain canonical → all machines.
**When:** After creating/editing a skill locally. Before closing the work session.

## Workflow

1. Local audit:
   - Run `smorch audit` (existing tool in smorch-brain)
   - Check: skill has SKILL.md, frontmatter valid, no broken refs
2. Compute hashes + update `smorch-brain/canonical/skills-manifest.json`
3. Push `smorch-brain` to GitHub main
4. Trigger `smorch-sync-all` (existing 4-step cycle):
   a. Push skills to GitHub
   b. SSH to each machine → `git pull origin main` in smorch-brain clone
   c. SSH `smorch pull --profile {machine-profile}` — re-ingests skills
   d. Rebuild plugin indexes
5. Run `/smo-drift --skills-only` to confirm all machines in sync
6. Telegram notify: skill X synced to N machines

## Arguments

- `--skill {name}` — single skill, rest untouched
- `--dry-run` — audit + hash-diff, no push
- `--force` — push even if audit has warnings (requires confirmation)

## Pre-conditions

- Local smorch-brain clean (no uncommitted changes besides the skill update)
- User is on main branch (or feature branch with approved PR)

## Failure modes

- Audit fails → stop at step 1, fix locally
- Push fails (conflict) → rebase + retry
- SSH fail on 1+ machines → report stragglers; skill is on GitHub but not all machines have it yet; cron sync will catch up within 30 min

## Rule (per SOP-12)

Never edit skills directly on a machine. Always: local → smorch-brain → sync. This command is the enforcement surface.

## Output

```
## Skill sync — 2026-04-19

**Skill:** smo-scorer (v1.1.0)
**Hash:** 8f4c2d9a1b6e3c5d
**Manifest updated:** smorch-brain/canonical/skills-manifest.json

### Push
✅ smorch-brain main pushed

### Sync-all
| Machine | Status |
|---------|--------|
| eo-prod | ✅ synced |
| smo-dev | ✅ synced |
| smo-prod | ✅ synced |
| smo-eo-qa | ✅ synced |
| mamoun-mac | ✅ synced |
| lana-win | ⏳ SSH slow, will retry on next cron (30 min) |

5/6 machines synced. Lana will catch up via cron.
```

## Integration

- Replaces old manual `cp -r skills/* ~/.claude/skills/` workflow
- Complements (does not replace) `sync-plugins.sh` in smorch-brain
- Cron `sync-from-github.sh` is the fallback for machines that miss the push-triggered sync
