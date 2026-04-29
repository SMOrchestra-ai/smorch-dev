# SOP-37 — Server-Side Parity

**Effective:** 2026-04-29 (smorch-ops v1.1.0)
**Status:** Active
**Owner:** Mamoun
**Related:** SOP-36 (L3 cascade), SOP-14 (plugin workflow), SOP-15 (cross-machine sync), SOP-16 (secrets rotation)

## The rule

The two SMO dev VPS — **smo-dev** (62.171.165.57) and **eo-dev** (84.247.172.113, renamed from smo-eo-qa as of 2026-04-29) — run the SAME Claude Code stack as the dev laptops. No "works on my machine" gaps.

## The 6-row parity checklist (v1.5+)

Per server, per quarter (or after any rebuild):

| # | Item | Verify command |
|---|------|----------------|
| 1 | Claude Code installed | `claude --version` returns ≥ current local version |
| 2 | gstack at `~/.claude/skills/gstack/` | `bash ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/scripts/l3-health-check.sh --strict --quiet` returns 0 |
| 3 | superpowers plugin installed | same script as #2 (covers both gstack + superpowers) |
| 4 | smorch-dev + smorch-ops plugins synced | `cat ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/.claude-plugin/plugin.json \| jq -r .version` matches local |
| 5 | `~/.claude/CLAUDE.md` synced from canonical | `sha256sum ~/.claude/CLAUDE.md` matches canonical |
| 6 | **No shadow direct-install** (added 2026-04-29 per L-011) | `ls ~/.claude/plugins/smorch-dev ~/.claude/plugins/smorch-ops 2>/dev/null` returns empty; same script as #2 detects via `shadow(N)` in status line |

Any failure → `/smo-skill-sync --server <name> --bootstrap` (full re-bootstrap) OR `--server <name>` (skill-only sync, faster).

### Why row 6 (shadow detection)

A pre-marketplace direct install at `~/.claude/plugins/{plugin-name}/` takes precedence over the marketplace cache at `~/.claude/plugins/cache/{marketplace}/{plugin-name}/{version}/`. New commands ship via the cache; the shadow blocks them silently. L3 health-check v1.5.1+ flags the shadow in warn mode and refuses session in strict mode (per L-011).

Remediation:
```bash
[ -d ~/.claude/plugins/smorch-dev ] && mv ~/.claude/plugins/smorch-dev ~/.claude/plugins/_legacy-smorch-dev-direct-pre-v1.5
[ -d ~/.claude/plugins/smorch-ops ] && mv ~/.claude/plugins/smorch-ops ~/.claude/plugins/_legacy-smorch-ops-direct-pre-v1.5
```

## Rename: smo-eo-qa → eo-dev (2026-04-29)

The QA VPS at 84.247.172.113 is reclassified as **eo-dev** — the EO Oasis development server, replica of smo-dev. Why: the server was being used for both EO dev work and SMO QA work, and the "smo-eo-qa" name created confusion about ownership.

**Rename steps (one-time):**
1. SSH as root to 84.247.172.113
2. `hostnamectl set-hostname eo-dev`
3. Update `/etc/hosts`: line `127.0.1.1 eo-dev`
4. `tailscale set --hostname=eo-dev`
5. Update `~/.ssh/config` on every dev laptop: rename `Host smo-eo-qa` → `Host eo-dev`
6. Update `~/.claude/CLAUDE.md` SERVERS table: rename row, set role = "EO Oasis dev VPS (replica of smo-dev)"
7. Update `smorch-brain/canonical/repo-registry.md`: same rename
8. Reboot to verify hostname sticks
9. Run `/smo-skill-sync --server eo-dev --verify` from a laptop — must pass parity checklist

## Bootstrap a fresh server (Mode B of /smo-skill-sync)

```
/smo-skill-sync --server eo-dev --bootstrap
```

Performs (per Mode B in smo-skill-sync.md):
1. Claude Code install
2. ANTHROPIC_API_KEY set in /root/.bashrc (server-specific, per SOP-16)
3. gstack clone + ./setup
4. **Manual step**: human operator runs `claude` then `/plugin install superpowers@claude-plugins-official` — cannot be automated (marketplace install is interactive)
5. smorch-dev + smorch-ops plugin sync
6. ~/.claude/CLAUDE.md sync
7. Hooks block of settings.json merged
8. l3-health-check.sh --strict — must return green

## Server discipline (already enforced; reaffirmed here)

These are inherited from CLAUDE.md, but called out for the parity context:

- **Never edit files directly on a server.** Local → GitHub → server pull (SOP-14).
- **Pull tags only, restart PM2.** Servers run shipped tags, not branches (SOP-14, L-009).
- **No paid-resource creates from server.** RULE 0 (money guardrail) inherited via CLAUDE.md sync.
- **Branch protection.** SOP-31/33/34 validators must be installed (already in smorch-dev SessionStart).
- **L3 strict mode on servers.** `SMORCH_STRICT_L3=1` set in `/root/.bashrc` — sessions refuse to start without full L3 cascade.

## When parity drifts

Symptoms:
- A command on the server produces different output than the laptop (e.g. /smo-triage uses inline hypothesis-list instead of superpowers:systematic-debugging)
- /smo-skill-sync --verify shows red on any row
- A new gstack/superpowers skill is referenced in a command but missing on the server

Response:
1. `/smo-skill-sync --server <name> --bootstrap` (re-bootstrap, idempotent)
2. If still drifted → file an incident via `/smo-incident --sev 3` describing the drift
3. Add a regression check to next quarter's parity audit

## Related lessons

- L-002: verify canonical app state before declaring rollout complete
- L-009: GitHub remote is single source of truth; act, don't ask
- L-010: L3 cascade discipline (the 2026-04-29 lesson that triggered SOP-36 + SOP-37)
