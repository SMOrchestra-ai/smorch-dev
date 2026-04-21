# Plugin / Skills / Commands Guide — Coding Edition

**One reference for all Claude Code coding tooling at SMOrchestra.**
**Audience:** Mamoun, Lana, future hires. Skip if you're a GTM / content operator.

---

## The mental model

```
PLUGIN = package (shipped as a repo)
  ↳ COMMANDS = slash commands (/smo-plan, /smo-score, …)
  ↳ SKILLS = reusable instructions (smo-scorer, lessons-manager, …)
  ↳ TEMPLATES = starter files (CLAUDE.md, lessons.md, settings.json)

Commands CALL skills. Skills contain the rubrics, protocols, checklists.
Plugins own both. Installed globally or per-project.
```

---

## The 5 plugins you need

| Plugin | Source | Installed on | Purpose |
|--------|--------|--------------|---------|
| **smorch-dev** | github.com/SMOrchestra-ai/smorch-dev | Mac + Windows (dev + QA) | Workflow: plan→code→score→handover→ship |
| **smorch-ops** | github.com/SMOrchestra-ai/smorch-dev | Everywhere incl. servers | Infra: deploy, rollback, drift, health, incident, secrets |
| **gstack** | upstream garrytan/gstack | Mac + Windows only | Engineering utilities (used under the hood) |
| **superpowers** | upstream obra/superpowers | Mac + Windows only | TDD, debugging, subagents (used by /smo-code /smo-triage) |
| **smorch-builders** (formerly smorch-dev v1) | smorch-brain/plugins/smorch-builders | as needed per-project | MCP / n8n / webapp builder skills |

Install in one command:
```bash
# Mac / Linux:
bash <(curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/eng-desktop.sh)
# Windows (admin PowerShell):
iwr -useb https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/qa-machine.ps1 | iex
```

---

## The 18 commands — by daily sequence

### Morning
| Command | What it does |
|---------|--------------|
| `/smo-health` | Multi-server health check + git state across all projects |
| `/smo-drift --target {host}` | On-demand drift diagnostic (complements hourly cron) |

### Building a feature
| Command | What it does |
|---------|--------------|
| `/smo-plan {feature}` | Plan mode. Reads BRD + lessons + project overlay. Waits for approval. |
| `/smo-code` | TDD loop: test-first per AC-N.N, minimal impl, refactor, elegance pause. |
| `/smo-score [--quick / --full]` | 5-hat composite score. Gate 92+ internal, 90+ students. |
| `/smo-bridge-gaps` | Fix the lowest hat when score is 85-91. |

### Dev → QA handover
| Command | What it does |
|---------|--------------|
| `/smo-handover` | Auto-generate brief from SOP-13 template. Dev fills scenarios + risks + rollback. |
| `/smo-qa-handover-score` | Lana runs: 5-dim rubric. ≥80 accept, 60-79 send back, <60 auto-reject. |
| `/smo-qa-run` | Lana executes validation suite, produces QA report. |

### Ship + deploy
| Command | What it does |
|---------|--------------|
| `/smo-ship` | Merge PR + git tag. Does NOT deploy. Requires 92+ score + QA pass. |
| `/smo-deploy` | SSH to server + git pull + pm2 reload + health check. Pre-drift check. |
| `/smo-rollback` | Revert a deploy. Target SLA 90-120s. Deploy's twin. |

### Incidents + fixes
| Command | What it does |
|---------|--------------|
| `/smo-triage {bug}` | Live diagnostic: hypothesis → evidence → root cause → regression test. |
| `/smo-incident` | Post-mortem writer. SEV1-4 structure per SOP-10. |

### Ops
| Command | What it does |
|---------|--------------|
| `/smo-secrets [--audit / --rotate {name}]` | 90-day rotation tracking per SOP-16. |
| `/smo-skill-sync` | Push a skill edit → smorch-brain → all machines via sync-all. |

### End of sprint
| Command | What it does |
|---------|--------------|
| `/smo-retro` | Aggregate scores + handovers + incidents across all projects. Surface cross-project patterns. |

### In-session guidance (v1.3.0-dev)
| Command | What it does |
|---------|--------------|
| `/smo-dev-guide [topic]` | In-session cheat-sheet. No args → overview. `next` → context-aware next command (reads `docs/qa-scores/`, `docs/handovers/`, `docs/qa/`, `.smorch/project.json`, git state). Also: `chain`, `score`, `handover`, `qa`, `ship`, `deploy`, `architecture`, `plugins`, `overlay`, `skills`, `marketplace`, `validators`, `hooks`, `infra`, `servers`, `install`, `sync`, `drift`, `secrets`, `incident`, `locale`, `rollback`, `dirs`, `verbs`, `sops`, `lessons`, `stuck`, `sop-NN`, `l-NNN`. |

---

## The 17 skills — by domain

### Scoring + quality
- **smo-scorer** (smorch-dev) — 5-hat orchestrator. Hat files: product-hat, architecture-hat, engineering-hat (+3 security Q), qa-hat, ux-hat + calibration-examples.
- **qa-handover-scorer** (smorch-dev) — Lana's pre-QA rubric.
- **cost-tracker** (smorch-dev) — flags token/API/DB cost anomalies per PR; surfaces in Engineering Q8.

### Self-improvement
- **lessons-manager** (smorch-dev) — per-project `.claude/lessons.md`; Boris pillar #3. Auto-loaded at SessionStart.
- **elegance-pause** (smorch-dev) — Boris pillar #5; 3-question protocol before non-trivial commits.

### Guidance (v1.3.0-dev)
- **dev-guide-router** (smorch-dev) — routes `/smo-dev-guide` topic queries. Context-aware `next` reads live state (qa-scores, handovers, qa, git/PR, overlay) to recommend the single right next command. First-match rule table; never invents commands or SOPs.

### Handover
- **handover-generator** (smorch-dev) — generates dev→QA brief from SOP-13 template.

### MENA
- **arabic-rtl-checker** (smorch-dev) — 8-point RTL + fonts + BiDi checklist.
- **mena-mobile-check** (smorch-dev) — 10-point 375px + currency + weekend + imagery.

### BRD + tests
- **brd-traceability** (smorch-dev) — enforces `AC-N.N` test tagging. Caps Engineering Q2 if coverage <90%.

### Infra
- **security-hardener** (smorch-ops) — UFW + fail2ban + SSH + 5 more non-negotiables. Post-perfctl.
- **incident-runbook** (smorch-ops) — SEV1-4 protocol (detect/classify/mitigate/resolve/review).
- **deploy-pipeline** (smorch-ops) — SSH → git pull → pm2 → health-check flow.
- **rollback-runbook** (smorch-ops) — revert deploy per `migration_reversibility` config.
- **drift-detector** (smorch-ops) — on-demand complement to cron drift checks.
- **secrets-manager** (smorch-ops) — SOP-16 rotation orchestration.
- **codex-doctrine** (smorch-ops) — SOP-11 enforcement (default to Claude Code, Codex gated).

---

## The non-negotiable gates

| Gate | Threshold | Enforced by |
|------|-----------|-------------|
| Composite score | ≥92 internal, ≥90 students | `/smo-score` → blocks `/smo-ship` |
| Minimum hat | ≥8.5 internal, ≥8 students | Same |
| Handover acceptance | ≥80 (5-dim) | `/smo-qa-handover-score` → Lana rejects <80 |
| BRD traceability | 100% AC → test mapping | Engineering Q2 via brd-traceability |
| Elegance pause block | Present in PR description | Engineering Q5 via elegance-pause |
| Security posture (servers) | UFW + fail2ban + SSH key-only + unattended | Engineering Q9 via security-hardener |
| Secrets rotation | <SLA days old | Engineering Q11 via secrets-manager |
| Pre-commit drift | No machine drifted | Git pre-commit hook |
| Plugin manifest valid | commands[] + skills[] paths resolve | validate-plugins.sh (CI) |

---

## Project-level overlay pattern

Every coding project declares its own overlay at `{project}/.smorch/`:

```
my-project/
  CLAUDE.md              # 40-60 line project-specific header
  .smorch/
    project.json         # {"project":"...","locale":"ar-MENA|en-US|mixed","qa":{"rollback_drill":"required|optional"},"deploy":{...},"cost_tracking":{...}}  # v1.2.0-dev schema
    skills/              # optional project-specific skills
    templates/           # optional project-specific templates
    overrides/           # optional scoring-rubric overrides
  docs/
    qa-scores/           # /smo-score outputs + trend.csv
    handovers/           # /smo-handover briefs + qa-score files
    qa/                  # /smo-qa-run reports
    incidents/           # /smo-incident post-mortems
    deploys/             # /smo-deploy logs
    retros/              # /smo-retro outputs
  architecture/
    brd.md               # BRD with AC-N.N tags
  .claude/
    lessons.md           # per-project self-improvement (L-001, L-002, …)
    settings.json        # SessionStart hook to load lessons
```

The plugin reads `.smorch/project.json` at SessionStart and adapts. No PR to the plugin needed per project.

---

## The folder conventions (mandatory)

| Folder | Contents | Gitignored? |
|--------|----------|:-----------:|
| `architecture/` | BRD, diagrams, ADRs | No |
| `docs/qa-scores/` | Score reports + trend.csv | No |
| `docs/handovers/` | Dev→QA briefs + handover-score reports | No |
| `docs/qa/` | QA execution reports (from /smo-qa-run) | No |
| `docs/incidents/` | SEV1-4 post-mortems | No |
| `docs/deploys/` | Deploy logs + rollback records | No |
| `docs/retros/` | Sprint retro reports | No |
| `docs/secrets/` | Rotation audit reports (names only, never values) | YES |
| `.claude/lessons.md` | Per-project lessons | No (content only, no secrets) |
| `.env.local` | Secrets | YES |
| `node_modules/`, `.next/` | Build output | YES |

---

## Cheat sheet — bar prompts

| You say | Plugin does |
|---------|-------------|
| "start a feature for X" | `/smo-plan X` |
| "code it" | `/smo-code` |
| "score it" | `/smo-score --full` |
| "fix the weakest hat" | `/smo-bridge-gaps` |
| "send to QA" | `/smo-handover --notify` |
| "ship it" | `/smo-ship` |
| "deploy" | `/smo-deploy` |
| "something is broken" | `/smo-triage "{symptom}"` |
| "write up the incident" | `/smo-incident` |
| "revert the deploy" | `/smo-rollback` |
| "are all servers healthy" | `/smo-health` |
| "scan for drift" | `/smo-drift` |
| "is any secret overdue" | `/smo-secrets --audit` |
| "push the new skill" | `/smo-skill-sync` |
| "end of sprint" | `/smo-retro` |
| "what do I run next?" | `/smo-dev-guide next` |
| "how does X work?" | `/smo-dev-guide {topic}` (e.g. `architecture`, `overlay`, `sync`) |
| "look up SOP-14" | `/smo-dev-guide sop-14` |
| "look up L-008" | `/smo-dev-guide l-008` |

---

## What NOT to do

- Don't install both plugins manually — use the install profile
- Don't edit skills on servers — always via GitHub PR → sync
- Don't skip `/smo-score` "because it's small" — the quick mode exists (2 min)
- Don't use `/smo-ship` to deploy — ship = merge+tag, deploy = separate
- Don't use `/smo-debug` (renamed to `/smo-triage`)
- Don't score your own PR above evidence supports — Lana catches inflation in handover score

---

## References

- SOP-14 — Plugin workflow (command surface + verb boundaries)
- SOP-15 — Cross-machine sync (cron + GitHub Actions)
- SOP-16 — Secrets rotation (90-day SLA)
- SOP-17 — Hire onboarding (Day 1 → Month 1)
- `~/.claude/CLAUDE.md` — global, 116 lines
- `github.com/SMOrchestra-ai/smorch-dev` — source of truth
