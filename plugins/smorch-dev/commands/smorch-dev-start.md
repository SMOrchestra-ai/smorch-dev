---
description: One-command bootstrap + enforcement for any SMOrchestra session. Detects machine role (eng-desktop | qa-machine | dev-server | prod-server), verifies prerequisites, enforces global + project CLAUDE.md discipline, reports GREEN/YELLOW/RED per check, and points to the next action. Works on Mac, Linux, Windows. Run first, every session.
---

# /smorch-dev-start

**Pillar:** Session bootstrap gate — nothing else runs until this is GREEN.
**For:** Mamoun (Mac), Lana (Windows/Mac), any new engineer or QA hire, any server session.
**When:** First thing at session start. Safe to re-run anytime (idempotent).
**Target runtime:** ≤15 seconds.

---

## Workflow

1. Invoke `dev-start-bootstrap` skill with `$ARGUMENTS` (flags: `--fix`, `--quiet`, `--profile=<role>`, `--skip-project`).
2. Skill runs three check layers in order. Halt on first RED unless `--fix` was passed.
3. Print GREEN/YELLOW/RED banner + next-action pointer.
4. If GREEN and inside a project: suggest `/smo-dev-guide next`.
5. If GREEN and no project context: suggest `cd` into a repo.

### The four layers

**Layer 1 — Machine (who am I, what do I have?)**
- Detect OS + shell (bash/zsh/pwsh).
- Detect role from `~/.sync-profile` written by `install/*.sh` scripts. Fallback: hostname heuristic (`smo-*` → server, `win-*` → qa, else eng-desktop).
- Verify tools for this role: git, gh, node, claude, tailscale, docker (role-conditional).
- Verify Claude Code plugins installed: `smorch-dev` (all roles), `smorch-ops` (all roles).
- Verify `~/.claude/CLAUDE.md` exists and is current (hash compared to canonical).
- Verify `~/.claude/lessons.md` exists and is loaded by SessionStart hook.
- Verify `~/.claude/settings.json` is valid JSON and has the lessons-loader hook.
- Verify cron/launchd sync job is registered (eng + qa + servers).

**Layer 2 — Context (am I somewhere sane?)**
- Detect current working directory. Is it inside `~/Desktop/repo-workspace/{smo,eo,shared,external-forks}/`?
- If yes: read `.git/config` → verify remote is SMOrchestra-ai or smorchestraai-code org.
- Verify branch is `dev` (per L-014: main = production, never develop on main).
- Verify local is not >1 day behind origin (drift flag).
- Verify no uncommitted changes >1 hour old (L-009 flag).
- Surface open PRs targeting current branch.

**Layer 3 — Project enforcement (is this repo Boris-compliant?)**
Skipped if outside a project or `--skip-project` passed. Per active repo:
- `CLAUDE.md` exists at repo root + top 3 lines reference Boris discipline (`Stack:`, `Non-negotiable rules:`, `Command chain:`).
- `.smorch/project.json` exists + validates against canonical schema (`plugins/smorch-dev/templates/smorch-project.json.template`).
- `architecture/brd.md` exists + has at least one `AC-N.N` tag.
- `docs/` tree has all 6 subfolders (handovers, qa-scores, qa, incidents, deploys, retros).
- `.claude/settings.json` has SessionStart hook loading `.claude/lessons.md`.
- `.env.example` exists + contains no literal secret values (all values must be `{placeholder}` or empty).
- `.gitignore` excludes `.env`, `.env.local`, `node_modules/`, `.next/`, `dist/`, `.venv/`.
- If `.smorch/project.json` has `dev_plugin: eo-microsaas-dev` or custom, verify that plugin is also installed (SOP-33).

**Layer 4 — Input inventory + quality scoring (project-scoped)**
Skipped if outside a project. Two halves:

*(a) Missing-input detector* — enumerates every expected input per project profile (drawn from Guide 01 Section 5 + `.smorch/project.json:project_type`). Classifies each as PRESENT · MISSING-MANDATORY · MISSING-CONDITIONAL · N/A. Missing-mandatory is RED. Missing-conditional is YELLOW with a reason ("customer-facing app expects design assets").

*(b) Quality scoring* — for each PRESENT input, scores 4 dimensions 0-10:
- **Completeness** — all required sections present (BRD needs Problem, ICP, MVP, ACs, OOS, metrics, deps; CLAUDE.md needs Stack, Rules, Command chain, Ship gates)
- **Depth** — enough detail to act on (BRD ACs are concrete + testable; CLAUDE.md rules are specific not generic)
- **Traceability** — links exist between inputs (BRD ACs have matching `@AC-N.N` tests; handovers reference BRD ACs; `.smorch/project.json` matches deploy paths)
- **Freshness** — modified within N days for active repos (N varies: BRD 90d, CLAUDE.md 60d, .smorch 30d, docs/ 14d)

Composite per input = `0.40·Complete + 0.30·Depth + 0.20·Trace + 0.10·Fresh`. Overall input-readiness = mean of present × (present_mandatory / expected_mandatory).

Gate: input-readiness <70 → RED. 70-84 → YELLOW. 85+ → GREEN.

---

## Arguments

| Flag | Effect |
|---|---|
| (none) | Run all layers, print report, halt on first RED |
| `--fix` | Auto-remediate where safe (scaffold missing dirs, re-run sync, apply CLAUDE.md patches). Destructive ops still require confirm. |
| `--quiet` | Only print final GREEN/YELLOW/RED banner + next-action line |
| `--profile=<role>` | Override auto-detected role. Values: `eng-desktop`, `qa-machine`, `dev-server`, `prod-server` |
| `--skip-project` | Skip Layer 3 (machine-only check, useful when not in a repo) |
| `--layer=<N>` | Run only layer N (1, 2, or 3) |

---

## Output format

```
╔══════════════════════════════════════════════════════════════╗
║  /smorch-dev-start — SMOrchestra Session Bootstrap           ║
║  Profile: eng-desktop · OS: darwin · User: mamounalamouri    ║
╚══════════════════════════════════════════════════════════════╝

Layer 1 — Machine
  ✓ git 2.42.0         ✓ gh 2.40.0         ✓ node v22.2.0
  ✓ claude 1.8.3       ✓ tailscale up       ✓ docker 25.0.3
  ✓ smorch-dev plugin  ✓ smorch-ops plugin
  ✓ ~/.claude/CLAUDE.md (canonical, last-sync 2026-04-23)
  ✓ ~/.claude/lessons.md (25 lessons loaded)
  ✓ ~/.claude/settings.json valid
  ✓ launchd sync registered (last run 12 min ago)

Layer 2 — Context
  ✓ cwd inside repo-workspace/smo/signal-sales-engine
  ✓ remote: SMOrchestra-ai/Signal-Sales-Engine
  ✓ branch: dev (up to date with origin)
  ✓ working tree clean
  ⚠ open PR #47 targeting dev (15 hours old, mergeable)

Layer 3 — Project
  ✓ CLAUDE.md (Boris-compliant)
  ✓ .smorch/project.json (schema valid, dev_plugin=smorch-dev)
  ✓ architecture/brd.md (17 ACs)
  ✓ docs/ tree (all 6 subfolders)
  ✓ .claude/settings.json (lessons hook loaded)
  ✓ .env.example (no literal secrets)
  ✓ .gitignore (all required patterns)

Layer 4 — Input inventory + quality
  Input              Present  Complete  Depth  Trace  Fresh  Composite
  CLAUDE.md            ✓        9.0      8.5    9.0    10.0    9.1
  architecture/brd.md  ✓        9.0      8.0    9.5     7.0    8.5
  .smorch/project.json ✓       10.0      9.0    9.0    10.0    9.6
  README.md            ✓        7.0      6.5    7.0     8.0    6.9
  project-brain/       ✓        8.0      7.5    8.0     9.0    7.9
  assets/design/       ⚠ miss   —        —      —       —      —    (customer-facing → expected)
  system-diagram.md    ⊘ N/A    (only 2 services, threshold is 3+)
  mcp-integration.md   ⊘ N/A    (0 external MCPs consumed)
  tech-stack-decision  ⊘ N/A    (using default Next.js+Supabase)

  Mandatory present: 4/4 · Conditional present: 1/2 (50%) · Freshness median: 21d
  INPUT-READINESS: 86 (GREEN)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STATUS: GREEN (2 warnings)
  Next:   /smo-dev-guide next
  ⚠       PR #47 has been open 15h — review or close before new work
  ⚠       assets/design/ missing — add Figma exports (customer-facing)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Status codes

| Code | Meaning | Next step |
|---|---|---|
| GREEN | All checks passed | `/smo-dev-guide next` or begin work |
| YELLOW | Non-blocking warnings (stale PR, one lesson out-of-date) | Address warnings or continue with awareness |
| RED | Blocking failures (missing plugin, malformed settings.json, CLAUDE.md absent) | Run `/smorch-dev-start --fix` or follow remediation text |

**RED always halts.** No `/smo-*` or `/eo-*` workflow command should run with a RED machine. YELLOW is the engineer's call — flagged in session transcript for audit.

---

## Role detection logic

`dev-start-bootstrap` reads `~/.sync-profile` first (written by `install/eng-desktop.sh`, `install/qa-machine.ps1`, `install/dev-server.sh`, `install/prod-server.sh`). Fallback chain if missing:

1. File `~/.sync-profile` with content `eng-desktop|qa-machine|dev-server|prod-server`
2. Hostname match: `smo-prod` | `smo-dev` | `eo-prod` | `smo-eo-qa` → server role
3. macOS + `~/Desktop/repo-workspace/` exists → `eng-desktop`
4. Windows (detected via `$OS` env or `uname -r | grep -i microsoft`) + Claude Code installed → `qa-machine`
5. Else → `unknown` → prompt user to pick.

---

## Remediation matrix (what `--fix` can auto-heal)

| Finding | `--fix` action | Requires confirm |
|---|---|---|
| Missing `~/.claude/CLAUDE.md` | Copy from canonical (smorch-brain/canonical/claude-md/) | No |
| Missing `~/.claude/lessons.md` | Copy from canonical + install SessionStart hook | No |
| `~/.claude/settings.json` malformed | Backup + reinstall canonical | Yes |
| Plugin not installed | Run `claude plugin install smorch-dev@smorch-dev` | No |
| launchd/cron sync missing | Re-run `install/shared/install-cron-sync.sh` | No |
| Missing project `docs/` subfolders | `mkdir -p` all 6 | No |
| Missing project `.claude/settings.json` | Copy from `per-app-settings-hook.json` | No |
| Missing `.env.example` | Scaffold from `.env.local` with values redacted | Yes |
| Branch = `main` (L-014 breach) | `git checkout dev` after pull | Yes |
| Uncommitted >1 hour | Offer to commit + push (L-009) | Yes |
| Stale PR >7 days | Comment + assign review, don't auto-close | No |

Things `--fix` NEVER does (CEO approval required):
- Rewrite git history or force-push
- Modify branch protection
- Delete any file (even `.env` backups)
- Rotate secrets
- Deploy anything

---

## Exit codes (for CI / chaining)

- `0` — GREEN
- `1` — YELLOW (warnings)
- `2` — RED (blocked)
- `3` — `--fix` applied fixes, re-run needed to confirm GREEN
- `10` — profile detection failed, user must supply `--profile=`

---

## Non-goals

- **NOT an installer.** If tooling is missing, it points to `install/*.sh` — it does not run full provisioning.
- **NOT a project initializer.** Use `gh repo create` + Guide 01 for a fresh app.
- **NOT a deploy check.** That's `/smo-health` + `/smo-drift`.
- **NOT a scoring tool.** That's `/smo-score`.

## See also

- Guide 04 — Set up a new machine (Engineer or QA)
- Guide 01 — Start a New App
- `/smo-dev-guide start` — inline docs for this command
- `/smo-dev-guide next` — context-aware what-to-run-now
- SOP-17 — Hire Onboarding Engineering
- SOP-33 — Plugin Selection Enforcement
