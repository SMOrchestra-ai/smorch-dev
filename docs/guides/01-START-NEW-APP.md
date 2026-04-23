# Guide 01 — Start a New App (zero-to-shippable)

## 0. Session bootstrap (always first)

```bash
/smorch-dev-start
```

Before anything else this session. Runs the 4-layer gate (machine tools + plugins + global config · cwd + branch + sync state · project Boris discipline · input inventory + quality scoring). GREEN = continue. YELLOW = address warnings and proceed with awareness. RED = `/smorch-dev-start --fix` or remediation text. Works on Mac, Windows, Linux, servers — auto-detects role (eng-desktop / qa-machine / dev-server / prod-server). Full explainer: `/smo-dev-guide start`.

## 0b. Pre-checks (30 seconds)

- Pick domain: `smo` / `eo` / `shared`
- Pick lifecycle: `status-dev` (always start here)
- Pick distribution: `distribution-internal` / `distribution-customer`
- Pick orchestration: `pm2` OR `docker-compose` (never both — L-004)
- Pick Supabase project ref OR `null` (if MongoDB / no DB)
- Pick project type (drives Layer 4 input expectations): `customer-facing-app` / `internal-tool` / `infrastructure` / `sold-product` / `automation-only` / `research-spike`

## 1. Create repo on GitHub

```bash
gh repo create SMOrchestra-ai/{kebab-case-name} \
  --private \
  --description "{1-line purpose}" \
  --gitignore Node \
  --license MIT
```

Apply canonical topics:
```bash
gh repo edit SMOrchestra-ai/{repo} \
  --add-topic {smo|eo|shared} \
  --add-topic status-dev \
  --add-topic distribution-internal
```

Create `dev` branch from `main`:
```bash
SHA=$(gh api repos/SMOrchestra-ai/{repo}/git/refs/heads/main --jq .object.sha)
gh api repos/SMOrchestra-ai/{repo}/git/refs --method POST -f ref="refs/heads/dev" -f sha="$SHA"
```

Apply protection (copy from `smorch-dev/scripts/github-audit/phase-1-apply.sh` — STEP 5).

## 2. Clone into canonical desktop location

```bash
TIER={smo|eo|shared}
gh repo clone SMOrchestra-ai/{repo} ~/Desktop/repo-workspace/$TIER/{repo}
cd ~/Desktop/repo-workspace/$TIER/{repo}
git checkout dev
```

## 3. Mandatory file scaffolding (before any code)

Create in this order — nothing else is allowed:

```
{repo}/
├── CLAUDE.md                ← copy from smorch-brain/canonical/claude-md/per-app-CLAUDE-template.md, fill in
├── README.md                ← 1 paragraph + quick-start
├── .smorch/
│   ├── project.json         ← from template below
│   └── README.md
├── architecture/
│   └── brd.md               ← REQUIRED before /smo-plan
├── .claude/
│   ├── lessons.md           ← empty, accrues during dev
│   └── settings.json        ← copy from smorch-brain/canonical/claude-md/per-app-settings-hook.json
├── docs/
│   ├── handovers/
│   ├── qa-scores/
│   ├── qa/
│   ├── incidents/
│   ├── deploys/
│   └── retros/
├── .env.example             ← variable NAMES only, no values
├── .gitignore               ← node_modules, .env*, .next/, dist/, .venv/
└── tests/                   ← empty, gets @AC-N.N tagged tests
```

Commit this scaffolding BEFORE any code: `feat(scaffold): Boris + .smorch + docs/ structure`.

## 4. BRD (architecture/brd.md) — REQUIRED

Structure:

```markdown
# {Project} BRD

## Problem
{2-3 sentences — whose pain, quantified}

## ICP
{who uses this}

## MVP scope
{what's IN, what's OUT}

## Acceptance Criteria
- **AC-1.1**: User can {do X} given {context}
- **AC-1.2**: ...
- **AC-2.1**: ...

## Out of scope (v1)
- ...

## Success metrics
- ...

## Dependencies
- Supabase project: {ref or N/A}
- External APIs: {list}
- Servers: {target prod host}
```

**Rule**: every AC-N.N must have a matching `@AC-N.N` tagged test in `tests/`. Enforced by `smorch-dev:brd-traceability` skill — caps Engineering hat at 6 if coverage <90%.

## 5. Additional inputs if applicable

| Kind | Lives at | When required |
|---|---|---|
| Frontend design artifacts (Figma exports, screenshots, wireframes) | `assets/design/` | Always for customer-facing apps |
| Architecture diagram | `architecture/system-diagram.md` (Mermaid) | If >3 services interact |
| Tech stack decision doc | `architecture/tech-stack-decision.md` | If any non-default choice (not Next.js + Supabase) |
| Business context | `project-brain/` (icp.md, positioning.md, brandvoice.md) | EO + SMO customer-facing apps |
| MCP integration plan | `architecture/mcp-integration-plan.md` | If consuming 3+ external MCPs |

## 6. `.smorch/project.json` (fill template)

```json
{
  "project": "{kebab-case}",
  "display_name": "{Human Name}",
  "mena": true,
  "rtl": false,
  "stack": "nextjs-14 + supabase + claude",
  "supabase": {"project_ref": "{ref}", "schema": "public"},
  "deploy": {
    "staging": {
      "host": "smo-dev",
      "tailscale_ip": "100.83.242.99",
      "path": "/root/{repo}",
      "branch": "dev",
      "orchestration": "pm2",
      "pm2_name": "{repo}-staging",
      "health_url": "https://staging-{repo}.smorchestra.ai/api/health",
      "rollback_sla_seconds": 120
    },
    "production": {
      "host": "smo-prod",
      "tailscale_ip": "100.108.44.127",
      "path": "/opt/apps/{repo}",
      "branch": "main",
      "orchestration": "pm2",
      "pm2_name": "{repo}",
      "health_url": "https://{domain}/api/health",
      "rollback_sla_seconds": 90
    }
  },
  "qa": {
    "rollback_drill": "required",
    "handover_required": true,
    "mena_checks": true,
    "external_qa_host": "smo-eo-qa",
    "scoring_weights": {
      "critical": ["product-market-fit", "ux", "qa"],
      "critical_weight_total": 0.80,
      "supporting": ["architecture", "engineering", "security", "performance", "a11y"],
      "supporting_weight_total": 0.20,
      "min_critical_hat": 8.5,
      "min_supporting_hat": 7.0,
      "composite_floor": 92
    }
  },
  "backup": {"db_enabled": true, "db_schedule": "0 2 * * *"}
}
```

## 7. Bootstrap prompt for Claude

Once the scaffolding above is committed, open Claude Code in the repo and paste:

```
You are building {project} per architecture/brd.md.

Context:
- CLAUDE.md loaded (Boris discipline)
- .smorch/project.json sets deploy targets
- BRD has N Acceptance Criteria (AC-1.1 through AC-N.N)
- Stack: {stack from project.json}
- Target: staging {host} /root/{repo}; prod {host} /opt/apps/{repo}

Daily loop:
/smo-plan → /smo-code → /smo-score → /smo-bridge-gaps (if <92) → /smo-handover → Lana /smo-qa-handover-score → Lana /smo-qa-run → /smo-ship → /smo-deploy

Ship gates (SOP-23 weighted):
- composite ≥92
- each top-3 hat ≥8.5
- each supporting hat ≥7.0
- handover ≥80 from Lana

Start with: /smo-plan AC-1.1
```

## 8. Command chain (the 7-pillar workflow)

| Step | Command | Owner | Gate |
|---|---|---|---|
| 0 | `/smorch-dev-start` | Dev/QA | 4-layer bootstrap. RED blocks everything downstream. Re-run anytime (idempotent). |
| 1 | `/smo-plan AC-N.N` | Dev | Reads BRD + lessons.md + overlay |
| 2 | `/smo-code` | Dev | Test-first per AC (TDD). Every AC gets @AC-N.N test |
| 3 | `/smo-score` | Dev | Composite ≥92, hat ≥8.5. Saved to `docs/qa-scores/YYYY-MM-DD-HHMM.md` |
| 4 | `/smo-bridge-gaps` | Dev | Only if 85-91. Auto-fix lowest hat |
| 5 | `/smo-handover` | Dev | Auto-fills PR + BRD + scenarios + rollback. Saved to `docs/handovers/` |
| 6 | `/smo-qa-handover-score` | **Lana** | ≥80 accept / 60-79 send back / <60 reject. BEFORE QA starts |
| 7 | `/smo-qa-run` | **Lana** | 4 scenarios (happy/empty/error/edge) × N AC + MENA + a11y |
| 8 | `/smo-ship` | Dev | Merge to dev via PR → squash. Then release PR dev→main. Tag vX.Y.Z |
| 9 | `/smo-deploy --env staging` | Dev | SSH to smo-dev, pull tag, build, pm2 reload, /api/health 200 |
| 10 | `/smo-deploy --env production` | Dev | Same on smo-prod AFTER Lana re-runs /smo-qa-run --env staging |

### Session-bootstrap command — `/smorch-dev-start` (run first, every session)

`/smorch-dev-start` is the mandatory 4-layer session gate. It is NOT interactive — it runs, reports, halts on RED. Designed for Mamoun's Mac, Lana's Windows/Mac, every new engineer and QA hire, and server sessions (auto-detects role).

**The four layers:**

| Layer | Scope | Fails if… |
|---|---|---|
| 1 | Machine tools + plugins + global config | git/gh/node/claude missing, `smorch-dev`/`smorch-ops` plugin not installed, `~/.claude/CLAUDE.md` missing/stale, `~/.claude/settings.json` malformed, cron/launchd sync not registered |
| 2 | Current-repo context | Not inside repo-workspace, on `main` branch (L-014), >24h behind origin, uncommitted >1h (L-009 risk) |
| 3 | Project Boris enforcement | CLAUDE.md/BRD/.smorch/project.json/docs/ tree missing, `.env.example` contains literal secrets, `.gitignore` missing required lines, `dev_plugin` field mismatch (SOP-33) |
| 4 | Input inventory + quality scoring (0-10 per dimension × 4 dimensions = composite per input; input-readiness overall ≥85 GREEN / 70-84 YELLOW / <70 RED) | Mandatory input missing, conditional input missing when condition is true, shallow/stale/orphan inputs pulling score below 70 |

**Input scoring rubric (Layer 4):** each PRESENT input scored on Completeness (40%), Depth (30%), Traceability (20%), Freshness (10%). Missing-input report enumerates expected-per-project-type. See `/smo-dev-guide start` for full rubric.

**Flags:**
- `--fix` — auto-heal safe findings (scaffold missing dirs, reinstall plugins, append .gitignore lines)
- `--quiet` — banner + next-action only
- `--profile=<role>` — override auto-detection
- `--skip-project` — machine-only (Layers 1+2)
- `--layer=<N>` — run only layer N

**Exit codes:** `0` GREEN · `1` YELLOW · `2` RED · `3` --fix applied (re-run) · `10` profile unknown.

Command file: `smorch-dev/plugins/smorch-dev/commands/smorch-dev-start.md`. Backing skill: `dev-start-bootstrap`.

---

### Helper command — `/smo-dev-guide` (context-aware cheat-sheet)

`/smo-dev-guide` is the in-session router that answers "what command do I run now?" and "where is SOP-X?" without leaving Claude Code. Context-aware via `.smorch/project.json` + latest `docs/qa-scores/` + `docs/handovers/`.

**Topics**: invoke with no argument for overview, or pass a topic:

| Arg | Returns |
|---|---|
| (empty) | overview + topic table |
| `start` | `/smorch-dev-start` 4-layer bootstrap + input-scoring rubric detail |
| `next` | context-aware "next command to run" (reads last `/smorch-dev-start` result + current branch + last score + last handover) |
| `chain` | daily chain visualization with wall-clock targets |
| `score` | scoring gates (92/8.5) + what to do at each level |
| `handover` | SOP-13 5-dim rubric + how Lana scores |
| `qa` | `/smo-qa-run` steps + MENA / rollback-drill gates |
| `ship` | ship vs deploy verb boundary (SOP-14) |
| `rollback` | rollback drill policy |
| `sops` | SOP index (SOP-01…SOP-35) |
| `lessons` | global + project lessons.md pointer |
| `stuck` | troubleshooting decision tree |

**Use it when**: onboarding a new hire, forgot a gate threshold, unsure which command is next, need to look up an SOP reference inline.

Part of `smorch-dev` plugin. Command file: `smorch-dev/plugins/smorch-dev/commands/smo-dev-guide.md`. Backing skill: `dev-guide-router`.

## 9. Hard gates (can't bypass)

| Gate | Blocker |
|---|---|
| Composite score | <92 or hat <8.5 — blocks /smo-ship |
| Handover score | <80 — blocks Lana from starting QA |
| QA scenarios | Any of 4 fails — blocks /smo-ship |
| Staging health | /api/health ≠ 200 — blocks prod deploy |
| Git state | Uncommitted / unpushed — blocks /smo-ship (L-009) |
| Branch protection | Direct commit to main — rejected by GitHub |
| Drift | Server state ≠ git — blocks /smo-deploy |
| Perfctl sentinel | IOC detected — alerts before any deploy |
| .env backup | No backup within 24h — caps Engineering Q7b at 5 |

## 10. Handover to QA (Lana)

`/smo-handover` produces a brief at `docs/handovers/YYYY-MM-DD-PR-{n}-handover.md`. Brief must include:

- PR URL + linked Linear ticket
- BRD AC-N.N addressed
- `/smo-score` composite + hat breakdown
- Test scenarios filled in (happy + empty + error + edge)
- Known risks + mitigations
- Rollback path with SLA
- Staging URL

Lana runs `/smo-qa-handover-score`:
- ≥80 → accept, starts /smo-qa-run
- 60-79 → send back (missing pieces)
- <60 → reject + escalate

## 11. What "done" means

Ship gate passes all 9 hard gates above. Then:
1. Merge feat/ → dev (PR squash)
2. When ready: release PR dev → main, CEO approves
3. `git tag vX.Y.Z && git push origin vX.Y.Z`
4. `/smo-deploy --env production`
5. `/api/health` returns 200 on production URL
6. `/smo-drift` reports clean
7. Telegram heartbeat: "🚀 {project} vX.Y.Z deployed"
