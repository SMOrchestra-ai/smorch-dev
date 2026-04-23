---
name: dev-start-bootstrap
description: |
  Session bootstrap + enforcement for SMOrchestra machines. Invoked by /smorch-dev-start. Detects machine role (eng-desktop | qa-machine | dev-server | prod-server | unknown), runs three check layers (machine tools + plugins + global config · repo context + branch + sync state · project Boris discipline + overlay + docs tree + SessionStart hook), prints GREEN/YELLOW/RED with remediation pointers, and (when --fix is passed) auto-heals safe classes of findings. Cross-platform: works on macOS, Linux, WSL, Windows (Git Bash / PowerShell). Idempotent. Target runtime ≤15 seconds. Never rewrites history, never rotates secrets, never deploys. Read-only by default.
---

# dev-start-bootstrap — Session Bootstrap & Enforcement

**Invoked by:** `/smorch-dev-start [flags]`
**Consumes:** `~/.sync-profile`, `~/.claude/{CLAUDE.md,lessons.md,settings.json,plugins/}`, cwd git state, `{repo}/{CLAUDE.md,.smorch/,.claude/,architecture/,docs/,.env.example,.gitignore}`, `smorch-brain/canonical/` (for hash comparison).
**Produces:** Layered report + exit code. With `--fix`: idempotent remediations for pre-approved classes.

---

## Invocation contract

| Flag | Behavior |
|---|---|
| (none) | Full report, halt on first RED |
| `--fix` | Auto-remediate safe findings, require confirm on destructive |
| `--quiet` | Banner + next-action only |
| `--profile=<role>` | Force role, skip auto-detect |
| `--skip-project` | Skip Layer 3 (machine-only) |
| `--layer=<N>` | Run only layer N |

Exit codes: `0` GREEN (all 4 layers) · `1` YELLOW (warnings, no blockers) · `2` RED (blocker — missing mandatory input, FAIL on L1/L2/L3, or input_readiness<70) · `3` --fix applied, re-run to confirm · `10` profile detection failed.

---

## Phase A — Profile detection

Order of precedence (halt at first hit):

```bash
# 1. Explicit --profile flag (highest)
# 2. ~/.sync-profile file (written by install/*.sh or install/qa-machine.ps1)
# 3. Hostname heuristic:
#      smo-prod  → prod-server
#      eo-prod   → prod-server
#      smo-dev   → dev-server
#      smo-eo-qa → dev-server
# 4. OS + desktop presence:
#      darwin + ~/Desktop/repo-workspace/   → eng-desktop
#      linux  + ~/Desktop/repo-workspace/   → eng-desktop
#      MINGW*/MSYS*/CYGWIN* (Git Bash)      → eng-desktop or qa-machine (ask)
#      WSL (uname -r contains "microsoft")  → eng-desktop or qa-machine (ask)
# 5. Else: exit code 10, prompt user to pass --profile=
```

Write the resolved profile back to `~/.sync-profile` if it was derived via heuristic (idempotent — future runs skip detection).

---

## Phase B — Layer 1: Machine checks

Role-conditional matrix. `R` = required, `-` = not applicable, `O` = optional:

| Check | eng-desktop | qa-machine | dev-server | prod-server |
|---|---|---|---|---|
| `git` ≥ 2.30 | R | R | R | R |
| `gh` ≥ 2.30 | R | R | O | O |
| `node` ≥ 20 | R | R | R | R |
| `claude` (Claude Code CLI) | R | R | O | O |
| `tailscale` status = running | R | R | R | R |
| `docker` running | O | - | R | R |
| `smorch-dev` plugin installed | R | R | - | - |
| `smorch-ops` plugin installed | R | R | R | R |
| `~/.claude/CLAUDE.md` present + current | R | R | - | - |
| `~/.claude/lessons.md` present | R | R | - | - |
| `~/.claude/settings.json` valid JSON | R | R | - | - |
| SessionStart hook wires lessons.md | R | R | - | - |
| `~/smorch-brain` clone present | R | R | - | - |
| Sync job registered (cron/launchd) | R | R | R | R |
| Perfctl sentinel cron | - | - | R | R |
| UFW + fail2ban active | - | - | R | R |

Each row produces one of: ✓ PASS · ⚠ WARN · ✗ FAIL · ⊘ N/A.

**Currency check** for CLAUDE.md/lessons.md/plugin versions: SHA-256 of local file vs canonical manifest at `smorch-brain/canonical/manifest.json`. Mismatch → WARN (stale, re-sync recommended), NOT fail — sync may be in-flight.

---

## Phase C — Layer 2: Context checks

Skip if cwd is outside a git repo.

```
cwd inside ~/Desktop/repo-workspace/{smo,eo,shared,external-forks}/*   ✓
remote origin points to SMOrchestra-ai or smorchestraai-code            ✓
current branch is `dev` (or `feat/*`, `fix/*`, `hotfix/*`)              ✓ / FAIL if `main`
local not >24h behind origin                                            ✓ / WARN
no uncommitted changes >1h old                                          ✓ / WARN (L-009)
no open PRs against dev >7 days old                                     ✓ / WARN
```

Branch `main` on eng-desktop triggers FAIL (L-014: production is sacred). Offer `git checkout dev` under `--fix` with confirm.

Branch `main` on server is PASS (servers pull deployed code).

---

## Phase D — Layer 3: Project enforcement

Skip if cwd is not a git repo OR `--skip-project` passed OR repo is `external-fork` lifecycle (external, we don't enforce Boris).

### Required files + content checks

| File | Exists | Content check |
|---|---|---|
| `CLAUDE.md` | R | Line count 30-80 (Boris discipline). Has lines matching `Stack:`, `Command chain:`, `Ship gates:` |
| `.smorch/project.json` | R | Valid JSON. Validates against `templates/smorch-project.json.template` keys. Has `deploy.staging.host` + `deploy.production.host` |
| `.smorch/README.md` | O (warn if missing) | — |
| `architecture/brd.md` | R | Has ≥ 1 line matching `^- \*\*AC-\d+\.\d+\*\*:` |
| `docs/handovers/` | R | dir exists |
| `docs/qa-scores/` | R | dir exists |
| `docs/qa/` | R | dir exists |
| `docs/incidents/` | R | dir exists |
| `docs/deploys/` | R | dir exists |
| `docs/retros/` | R | dir exists |
| `.claude/settings.json` | R | Valid JSON, has SessionStart hook referencing `./claude/lessons.md` or `.claude/lessons.md` |
| `.claude/lessons.md` | O | Empty file OK; just must exist as accrual target |
| `.env.example` | R | Must NOT contain strings matching secret regex (ghp_, sk-, AKIA, xox[bp]-, supabase service key pattern). Only placeholder values allowed (blank, `{…}`, `<…>`, `changeme`, `your-…`) |
| `.gitignore` | R | Must include lines: `.env`, `.env.local`, `node_modules/`, `.next/`, `dist/`, `.venv/` |
| `README.md` | R | Any content, >50 bytes |

### Plugin-selection check (SOP-33)

Read `.smorch/project.json:dev_plugin`. Compare to installed plugin list (`~/.claude/plugins/`). If declared plugin not installed → FAIL with remediation (`claude plugin install {x}`).

Valid `dev_plugin` values: `smorch-dev`, `eo-microsaas-dev`, `none`, or any listed in `smorch-brain/canonical/plugin-registry.md`.

### Scoring weight schema (SOP-23)

Verify `.smorch/project.json:qa.scoring_weights` has: `critical[]` (len 3), `critical_weight_total` (0.8), `supporting[]` (len 3-7), `supporting_weight_total` (0.2), `min_critical_hat` (≥8.0), `min_supporting_hat` (≥7.0), `composite_floor` (≥90). Missing → WARN (project is pre-SOP-23), not fail.

---

## Phase D2 — Layer 4: Input inventory + quality scoring

Runs after Layer 3 passes presence checks. Skip if `--skip-project` or not in repo.

### Step 1 — Determine project profile

Read `.smorch/project.json:project_type` (one of: `customer-facing-app`, `internal-tool`, `infrastructure`, `sold-product`, `automation-only`, `research-spike`). Fallback heuristics if missing:
- Has `frontend/` or `src/app/` + `public/` → `customer-facing-app`
- Has `n8n-workflows/` but no frontend → `automation-only`
- Has `scripts/` + server configs → `infrastructure`
- Has `Dockerfile` + `docs/customer-guide.md` → `sold-product`
- Else → `internal-tool`

### Step 2 — Expected-input matrix per profile

| Input | customer-facing-app | internal-tool | infrastructure | sold-product | automation-only | research-spike |
|---|---|---|---|---|---|---|
| `CLAUDE.md` | M | M | M | M | M | O |
| `architecture/brd.md` | M | M | M | M | M | O |
| `.smorch/project.json` | M | M | M | M | M | M |
| `README.md` | M | M | M | M | M | M |
| `.env.example` | M | M | M | M | M | O |
| `.gitignore` | M | M | M | M | M | M |
| `docs/` tree (6 dirs) | M | M | M | M | M | O |
| `assets/design/` | M | O | — | M | — | — |
| `architecture/system-diagram.md` | C (≥3 services) | C (≥3 services) | M | C (≥3 services) | C (≥5 workflows) | — |
| `architecture/tech-stack-decision.md` | C (non-default) | C (non-default) | C (non-default) | C (non-default) | C (non-default) | — |
| `project-brain/` (icp.md, positioning.md, brandvoice.md) | M (MENA customer) | O | — | M | — | — |
| `architecture/mcp-integration-plan.md` | C (≥3 MCPs) | C (≥3 MCPs) | C (≥3 MCPs) | C (≥3 MCPs) | C (≥3 MCPs) | — |
| `architecture/adrs/` | O | O | M | O | O | — |
| `tests/` with `@AC-N.N` tags | M | M | O | M | O | — |
| `scripts/migrate-*.sh` | C (any migration) | C | C | C | — | — |
| `ecosystem.config.js` OR `docker-compose.yml` (L-004: exactly one) | M | M | O | M | O | — |
| `.claude/settings.json` with SessionStart hook | M | M | M | M | M | O |
| `.claude/lessons.md` | O | O | O | O | O | — |

Legend: M = mandatory · O = optional (recommended) · C = conditional (condition in parens) · — = not applicable

### Step 3 — Score each PRESENT input (0-10 per dimension)

#### Completeness rubric

For each input type, predefined section list:

| Input | Required sections (each missing = -1 completeness) |
|---|---|
| `CLAUDE.md` | `Stack:`, `Non-negotiable rules:`, `Command chain:`, `Ship gates:`, `Env vars:`, `Deploy:`, `Rollback SLA:` (7 anchors) |
| `architecture/brd.md` | `## Problem`, `## ICP`, `## MVP scope`, `## Acceptance Criteria`, `## Out of scope`, `## Success metrics`, `## Dependencies` (7 anchors) |
| `.smorch/project.json` | keys: `project`, `stack`, `supabase` or explicit null, `deploy.staging`, `deploy.production`, `qa.scoring_weights`, `backup` (7 keys) |
| `README.md` | H1 title, 1-sentence purpose, `## Quick start`, `## Stack`, `## Deploy` (5 anchors) |
| `project-brain/icp.md` | Demographics, pains, buying triggers, MENA context, quantified cost (5 anchors) |
| `architecture/system-diagram.md` | At least 1 Mermaid block + 3 nodes + 2 edges + legend (4 anchors) |
| `.env.example` | All vars used in code present as placeholders (compared to `grep -rhoE 'process\.env\.[A-Z_]+' src/`) — completeness = coverage_pct / 10 |
| `.gitignore` | Lines: `.env`, `.env.local`, `node_modules/`, `.next/`, `dist/`, `.venv/`, `*.log` (7 lines) |

Score = `10 * (anchors_present / anchors_required)`.

#### Depth rubric

| Input | Depth signal |
|---|---|
| `CLAUDE.md` | 40-80 lines (Boris target). <30 = 4, 30-39 = 6, 40-80 = 10, 81-120 = 7, 120+ = 5 (bloat) |
| `architecture/brd.md` | AC count: <3 = 3, 3-5 = 6, 6-15 = 10, 16-30 = 8, 30+ = 6 (scope creep). Each AC has `given/when/then` = +1 (cap 10) |
| `.smorch/project.json` | Has `deploy.{staging,production}.health_url` + `rollback_sla_seconds` + `migration_reversibility` = 10. Missing any = -2 each |
| `README.md` | Line count: 20-100 lines = 10. <20 = 5 (stub). 100+ = 7 (bloat) |
| `.env.example` | Each var has inline `# comment` describing purpose: score = 10 * (commented_vars / total_vars) |
| design assets | File count ≥3 = 10, 1-2 = 6, 0 = — |
| tests | AC coverage: `grep -rhoE '@AC-\d+\.\d+' tests/` vs BRD ACs → 10 * (covered / total) |

#### Traceability rubric

| Input | Traceability signal |
|---|---|
| `architecture/brd.md` | Each AC has matching `@AC-N.N` test = 10. Missing any = 10 - (missing * 2), floor 0 |
| `CLAUDE.md` | References `.smorch/project.json` + `architecture/brd.md` + `docs/` + `lessons.md` = 10. Each missing = -2 |
| `.smorch/project.json` | `deploy.production.path` + `health_url` resolve to actual values (not `{placeholder}`) = 10 |
| `docs/handovers/*` | Each links to PR + BRD AC + /smo-score file = 10. Missing any link = -3 |
| `.env.example` | Var names match `process.env.X` in code = 10 * (matched / total) |

#### Freshness rubric

| Input | Freshness signal (days since last `git log -1` on the file) |
|---|---|
| `.smorch/project.json` | ≤30d = 10, ≤60d = 7, ≤90d = 4, >90d = 1 |
| `CLAUDE.md` | ≤60d = 10, ≤90d = 7, ≤180d = 4, >180d = 1 |
| `architecture/brd.md` | ≤90d = 10, ≤180d = 7, ≤365d = 4, >365d = 1 |
| `docs/handovers/*` (most recent) | ≤14d = 10, ≤30d = 7, ≤60d = 4, >60d = 1 |
| `.env.example` | ≤90d = 10, ≤180d = 7, ≤365d = 4, >365d = 1 |
| For archived repos (`status-archived` topic) | freshness always reports 10 (staleness is expected) |

### Step 4 — Composite + gate

```
per_input_score = 0.40·Completeness + 0.30·Depth + 0.20·Traceability + 0.10·Freshness
input_readiness = mean(per_input_score over PRESENT inputs)
                  × (mandatory_present_count / mandatory_expected_count)
```

Gate:
- `input_readiness >= 85` → GREEN
- `70 <= input_readiness < 85` → YELLOW (list weakest 3 inputs with dimension that pulled them down)
- `input_readiness < 70` → RED (list missing mandatory + lowest-scoring present inputs, block with remediation)

### Step 5 — Missing-input report

For each expected input not present:
- If `M` and missing → FAIL row: `✗ {path} MISSING-MANDATORY · remediation: {command}`
- If `C` and condition true + missing → FAIL row with condition explained
- If `C` and condition false → `⊘ N/A ({reason})`
- If `O` and missing → `⚠ {path} MISSING-OPTIONAL · recommended: {reason}`

### Step 6 — Output table

```
Layer 4 — Input inventory + quality
  Input                         Present  Cmpl  Dpth  Trc   Frsh  Composite
  CLAUDE.md                       ✓       9.0   8.5   9.0   10.0   9.1
  architecture/brd.md             ✓       9.0   8.0   9.5    7.0   8.5
  .smorch/project.json            ✓      10.0   9.0   9.0   10.0   9.6
  README.md                       ✓       7.0   6.5   7.0    8.0   6.9
  .env.example                    ✓       8.0   5.0   8.0    9.0   7.3
  .gitignore                      ✓      10.0   —     —     10.0  10.0
  docs/ tree (6 subfolders)       ✓      10.0   —     —      —    10.0
  tests/ (@AC coverage)           ✓       7.0   —     7.0    8.0   7.1
  project-brain/                  ✓       8.0   7.5   8.0    9.0   7.9
  assets/design/                  ⚠ miss  (customer-facing-app expects this)
  architecture/system-diagram.md  ⊘ N/A   (service count 2 < threshold 3)
  mcp-integration-plan.md         ⊘ N/A   (consuming 0 MCPs)
  tech-stack-decision.md          ⊘ N/A   (using default stack)
  ecosystem.config.js | compose   ✓      10.0   —     —     10.0  10.0

  Mandatory present: 8/8 · Conditional expected: 1 · Conditional present: 0
  Completeness mean: 8.6 · Depth mean: 7.4 · Traceability mean: 8.1 · Freshness mean: 8.9
  INPUT-READINESS: 86 (GREEN)

  Weakest 3 inputs (improve next):
    1. .env.example      depth 5.0 — add inline # comments for each var
    2. README.md         depth 6.5 — expand Quick start section
    3. architecture/brd.md freshness 7.0 — last touched 85d ago, review
```

### Step 7 — Remediation suggestions (Layer 4 under `--fix`)

Auto-remediable:
- Scaffold missing mandatory files from canonical templates (CLAUDE.md, .env.example, .gitignore, docs/ tree)
- Generate `.env.example` from actual `process.env.X` scan (values redacted)
- Add missing `.gitignore` lines

Requires confirm or human:
- Expand README.md or BRD (content generation needs CEO context)
- Add design assets (human-provided)
- Bump freshness (someone needs to review + commit)
- Fix traceability gaps (write missing `@AC-N.N` tests)

---

## Phase E — Remediation (`--fix` mode only)

Each remediation is idempotent. Logged to `~/.claude/logs/dev-start-bootstrap-YYYY-MM-DD.log`.

```
FINDING                                    ACTION                                      CONFIRM?
Missing ~/.claude/CLAUDE.md                cp from smorch-brain/canonical/claude-md/   no
Missing ~/.claude/lessons.md               cp + install SessionStart hook              no
~/.claude/settings.json malformed          backup + reinstall canonical                YES
Plugin smorch-dev not installed            claude plugin install smorch-dev@smorch-dev no
Plugin smorch-ops not installed            claude plugin install smorch-ops@smorch-dev no
launchd/cron sync missing                  bash install/shared/install-cron-sync.sh    no
~/smorch-brain clone missing               git clone git@github.com:SMO../smorch-brain no
Missing project docs/ subfolders           mkdir -p docs/{handovers,qa-scores,...}     no
Missing project .claude/settings.json      cp from canonical/claude-md/per-app-…       no
Missing .env.example                       generate from .env.local with values stripped YES
Missing .gitignore entries                 append required lines                       no
Branch = main on eng-desktop (L-014)       git pull + git checkout dev                 YES
Uncommitted >1h                            show changes, offer git add + commit + push YES
Stale CLAUDE.md/lessons.md hash            re-run sync-from-github.sh                  no
```

**Never under `--fix`:**
- Force-push, reset --hard, branch delete
- Any .env / .env.local / secrets file modification (only .env.example is safe)
- Any cross-repo edit
- Any server-side change (dev-start is client-side only)
- Any plugin uninstall
- Any rotation or credential change

---

## Phase F — Output format

### Full output (default)

```
╔══════════════════════════════════════════════════════════════╗
║  /smorch-dev-start — SMOrchestra Session Bootstrap           ║
║  Profile: {role} · OS: {darwin|linux|windows} · User: {u}    ║
╚══════════════════════════════════════════════════════════════╝

Layer 1 — Machine
  {rows, one per check, aligned}

Layer 2 — Context
  {rows, skipped if not in repo}

Layer 3 — Project
  {rows, skipped if --skip-project or not in repo}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STATUS: {GREEN | YELLOW (n warnings) | RED (n blockers)}
  Next:   {the one next action}
  {for each warning or blocker: one-line description + fix hint}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Quiet output (`--quiet`)

```
GREEN · eng-desktop · signal-sales-engine · next: /smo-dev-guide next
```

or

```
RED · eng-desktop · missing ~/.claude/CLAUDE.md · run: /smorch-dev-start --fix
```

---

## Implementation strategy

Implemented as a single shell function invoked by the command file. Core logic in pure bash (POSIX where possible) with `jq` + `git` + `gh`. Windows path: same logic runs under Git Bash; PowerShell wrapper at `install/qa-machine.ps1` forwards to `bash dev-start-bootstrap.sh` (installed by qa-machine.ps1).

The command file at `commands/smorch-dev-start.md` invokes this skill. The skill's executable logic lives in this SKILL.md's checklist — Claude Code reads the skill, enumerates the checks, and executes each via Bash tool. No separate `.sh` file to drift.

---

## Anti-patterns

- **Do not silently pass.** Every check emits a row. No row = check didn't run = implementation bug.
- **Do not auto-fix destructive findings.** Branch switch, settings.json rewrite, .env.example generation all need confirm.
- **Do not exceed 15 seconds.** If `gh pr status` or `tailscale status` hangs, `timeout 3s` and WARN.
- **Do not hallucinate findings.** Every ✓/⚠/✗ must reference a real file/command output.
- **Do not mix this with /smo-health.** This is client-side session bootstrap; /smo-health is server-side health check. They compose, not overlap.
- **Do not skip Layer 1 even on servers.** Server-side role has its own matrix row — run it, just with `- N/A` for plugins.

---

## Test fixtures (for CI)

Mock homes at `tests/fixtures/dev-start-bootstrap/`:

- `eng-desktop-green/` — everything present + current → exit 0
- `eng-desktop-yellow/` — stale CLAUDE.md hash → exit 1
- `eng-desktop-red-no-plugin/` → exit 2
- `eng-desktop-red-main-branch/` → exit 2 (L-014)
- `qa-machine-windows/` — Git Bash, qa role → exit 0
- `prod-server-minimal/` → exit 0 (N/A most client-side rows)
- `unknown-profile/` → exit 10

CI invokes: `HOME=fixtures/... bash smorch-dev-start --quiet` and asserts exit code + first word of output.

---

## Changelog

- **v1.4.0-dev (2026-04-23)** — initial skill. Replaces clunky 4-guide manual bootstrap.
