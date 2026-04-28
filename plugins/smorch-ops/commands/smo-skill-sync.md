---
description: smorch-brain skill push/audit per SOP-12 + L3 stack sync (gstack/superpowers/CLAUDE.md) per SOP-37. Validates skill lock files, pushes to canonical, triggers sync-all across machines.
---

# /smo-skill-sync

**Scope:** Keep all 4 servers + local in lockstep on:
1. smorch-brain canonical skills (per SOP-12)
2. smorch-dev + smorch-ops plugins
3. **L3 cascade** (gstack + superpowers) — added in v1.5 per SOP-37
4. ~/.claude/CLAUDE.md global instructions

**When:** After creating/editing a skill locally, OR when bootstrapping a new server.

## L3 stack sync (added v1.5, SOP-37)

Per SOP-37 (server-side parity): the same L3 stack lives on every dev box.
This command pushes it to whichever target you name. Default = `--server all-dev`
(smo-dev + eo-dev — the dev VPS pair).

| Component | Source | Target path on server |
|-----------|--------|------------------------|
| gstack | https://github.com/garrytan/gstack | `~/.claude/skills/gstack/` (clone + ./setup) |
| superpowers | claude-plugins-official marketplace | installed via `/plugin install` (manual) |
| smorch-dev plugin | https://github.com/SMOrchestra-ai/smorch-dev | `~/.claude/plugins/cache/smorch-dev/` |
| smorch-ops plugin | same repo, plugins/smorch-ops/ | `~/.claude/plugins/cache/smorch-ops/` |
| ~/.claude/CLAUDE.md | smorch-brain canonical | `~/.claude/CLAUDE.md` |
| Hooks block of settings.json | smorch-brain canonical | merged into `~/.claude/settings.json` (NEVER credentials) |

## Workflow

### Mode A — skill sync (default, existing behavior)

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

### Mode B — L3 stack bootstrap (new in v1.5, SOP-37)

Triggered by `--bootstrap` or `--server <name> --bootstrap`. Use on a fresh server,
or to bring an existing server into parity.

For each target server:
1. SSH in, ensure `node` + `npm` (or `bun`) installed
2. Install Claude Code: `npm i -g @anthropic-ai/claude-code` (idempotent — re-run safe)
3. Verify `ANTHROPIC_API_KEY` in `/root/.bashrc` (server-specific key per SOP-16; do NOT push from local)
4. Clone gstack: `git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup`
5. Print one-time instruction for human operator: "On this server, run `claude` then `/plugin install superpowers@claude-plugins-official` to complete L3 install. Cannot be automated — marketplace install requires interactive session."
6. Sync smorch-dev + smorch-ops plugins via Mode A
7. Sync `~/.claude/CLAUDE.md` (rsync from canonical)
8. Merge hooks block of `~/.claude/settings.json` (jq merge — preserves server-specific credentials/env)
9. Run `~/.claude/plugins/cache/smorch-dev/scripts/l3-health-check.sh --strict` on the server — must return green

### Mode C — verify parity (new in v1.5)

Triggered by `--verify` or `--server <name> --verify`.

For each target, SSH and run:
- `bash ~/.claude/plugins/cache/smorch-dev/scripts/l3-health-check.sh --strict --quiet`
- `cat ~/.claude/plugins/cache/smorch-dev/.claude-plugin/plugin.json | jq -r .version` (compare to local)
- `sha256sum ~/.claude/CLAUDE.md` (compare to local)
- Print red/green table per server.

## Arguments

- `--skill {name}` — single skill, rest untouched (Mode A only)
- `--server <name>` — target one server: `eo-dev` | `smo-dev` | `smo-prod` | `eo-prod` | `all` | `all-dev` (default `all-dev` = smo-dev + eo-dev)
- `--bootstrap` — Mode B (full L3 stack bootstrap)
- `--verify` — Mode C (parity check, no changes)
- `--dry-run` — show plan, no SSH
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
