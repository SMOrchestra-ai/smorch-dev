# Guide 05 — Complete `smorch-dev` Plugin Guide

**Audience:** Mamoun (founder), Lana (QA + half-Dev), every new engineering or QA hire from Day 1, anyone reading the repo for the first time.
**Purpose:** Everything about the `smorch-dev` plugin — how it's structured, what each piece does, how it composes with `gstack` and `superpowers`, and how to actually use it for real work.
**Read time:** 30 minutes end-to-end. 10 minutes if you skim the per-command/per-skill tables.

---

## Part 1 — The 3-Layer Architecture (one-page mental model)

Every SMOrchestra dev session sits on top of three composed layers. You only ever directly invoke Layer 1; Layers 2 and 3 are reached *through* Layer 1.

```
┌──────────────────────────────────────────────────────────────────────┐
│  LAYER 1 — Commands (you type these)                                 │
│  /smorch-dev-start  /smo-dev-guide  /smo-plan  /smo-code  /smo-score │
│  /smo-bridge-gaps   /smo-handover   /smo-qa-handover-score           │
│  /smo-qa-run        /smo-ship       /smo-triage   /smo-retro         │
│  + smorch-ops:  /smo-deploy /smo-rollback /smo-drift /smo-health     │
│                 /smo-incident /smo-secrets /smo-skill-sync           │
└──────────────────────────────────────────────────────────────────────┘
                               │
                               ▼ commands invoke skills
┌──────────────────────────────────────────────────────────────────────┐
│  LAYER 2 — smorch-dev skills (SMOrchestra-specific knowledge)         │
│  dev-start-bootstrap · dev-guide-router · smo-scorer                  │
│  brd-traceability · handover-generator · qa-handover-scorer           │
│  arabic-rtl-checker · mena-mobile-check · cost-tracker                │
│  elegance-pause · lessons-manager                                     │
│  + smorch-ops skills (deploy-pipeline, rollback-runbook, etc.)        │
└──────────────────────────────────────────────────────────────────────┘
                               │
                               ▼ skills delegate craft to upstream
┌──────────────────────────────────────────────────────────────────────┐
│  LAYER 3 — gstack + superpowers (general-purpose dev craft)           │
│  superpowers:writing-plans · test-driven-development                  │
│             · systematic-debugging · verification-before-completion   │
│             · subagent-driven-development · using-git-worktrees       │
│  gstack:    autoplan · plan-eng-review · careful · investigate        │
│             · ship · land-and-deploy · qa · review · retro · supabase │
│             · design-review · benchmark · canary · guard              │
└──────────────────────────────────────────────────────────────────────┘
```

### What each layer is for

**Layer 1 — Commands** are the verb-bound entry points. They are the *only* thing engineers should memorize. Every command has one job, follows the same shape (`description:` frontmatter + numbered Workflow + Arguments + Output), and never does work itself — it routes to skills.

**Layer 2 — `smorch-dev` skills** encode SMOrchestra-specific rules: 5-hat scoring with weighted top-3 (SOP-23), MENA Arabic RTL + 375px mobile checks, BRD `AC-N.N` traceability, Lana's 5-dim handover rubric, lessons.md self-promotion. **A skill in this layer never reinvents general dev practice** — it defers craft (TDD, planning, debugging) to Layer 3 and only owns the SMOrchestra-shaped wrapper.

**Layer 3 — `gstack` + `superpowers`** are upstream open-source skill packs (vendored as forks under `smorchestraai-code` org). They provide the underlying craft: how to write a plan, how to do TDD, how to ship, how to debug systematically. We treat them as read-mostly — bug fixes go upstream, not into our fork.

### How the layers compose during one command

Example: you type `/smo-plan AC-1.1`

```
L1  /smo-plan       — reads $ARGUMENTS, enters plan mode
L2  smo-scorer      — pre-flight rubric warmup (no-op until /smo-score)
L2  brd-traceability — reads architecture/brd.md, extracts AC-1.1 context
L2  lessons-manager — pre-loads ~/.claude/lessons.md + repo .claude/lessons.md
L3  superpowers:writing-plans — actually drafts the plan structure
L3  gstack:autoplan + gstack:plan-eng-review — upstream review patterns
```

The L1 command file is ~50 lines. The L2 skill files own the SMOrchestra rules. The L3 skill files own the craft. **You never edit L3 in normal work.** You sometimes edit L2 (when a SMOrchestra rule changes). You frequently use L1.

---

## Part 2 — How the Layers Encapsulate Complexity

This is the *why*. The plugin exists because the unstructured alternative — every engineer remembering every rule, every guide, every server, every gate — failed (April 18 perfctl incident, three weeks of work lost). The layers exist to make compliance mechanical.

### 2.1 — GitHub as Single Source of Truth (L-009)

**The rule:** every meaningful artifact (code, plugins, SOPs, registries, guides, lessons) lives in a GitHub repo. No artifact lives only on a laptop or only on a server. Every work unit ends with commit + push.

**How the layers enforce it:**

| Enforcement point | Layer | Mechanism |
|---|---|---|
| Pre-commit hook blocks `.env`/secrets/large binaries | L1 (hook) | `secret-scanner-v2` + `destructive-blocker` installed by `eng-desktop.sh` |
| `/smorch-dev-start` Layer 2 flags uncommitted >1h, behind origin >24h | L2 `dev-start-bootstrap` | Reads `git status`, `git rev-list HEAD..origin/dev`, surfaces L-009 risk |
| `/smo-ship` blocks if working tree dirty or branch behind | L2 (in `/smo-ship` workflow) | Hard gate — no merge until clean |
| `app-drift.sh` cron flags server HEAD ≠ origin HEAD hourly | smorch-ops + cron | Telegram alert, blocks `/smo-deploy` |
| Sync-from-github cron pulls plugins + guides every 30 min | install scripts | Every machine reaches GitHub state without manual `git pull` |

**Practical effect:** an engineer can't develop on `main` (L-014), can't leave work uncommitted overnight, can't deploy stale code, can't read a stale guide.

### 2.2 — Global `~/.claude/CLAUDE.md` enforcement

**The rule:** every machine has `~/.claude/CLAUDE.md` with the canonical content (Mamoun's identity, server registry, gates, language defaults, deployment pattern). Loaded automatically at every session start.

**How the layers enforce it:**

| Enforcement point | Layer | Mechanism |
|---|---|---|
| `~/.claude/settings.json` SessionStart hook auto-loads `lessons.md` (and `CLAUDE.md` is auto-read by Claude Code itself) | install scripts + Claude Code | Installed by `patch-claude-md.sh` during `eng-desktop.sh` |
| `/smorch-dev-start` Layer 1 row checks file exists + hash matches canonical | L2 `dev-start-bootstrap` | Compares SHA-256 to `smorch-brain/canonical/manifest.json` — WARN on mismatch (sync may be in flight), FAIL on missing |
| Sync-from-github cron pulls latest canonical CLAUDE.md every 30 min | install + cron | Drift window ≤30 min |
| `/smo-drift --desktop` reports config divergence across machines | smorch-ops | Periodic audit |

**Practical effect:** Lana's Mac, Mamoun's Mac, every new hire — same global rules. Update once in `smorch-brain/canonical/claude-md/`, propagates everywhere.

### 2.3 — Project-level `CLAUDE.md` enforcement (Boris discipline)

**The rule:** every active repo has a 40–80 line `CLAUDE.md` at the root with: Stack, Non-negotiable rules, Command chain, Ship gates, Env vars, Deploy, Rollback SLA, Unique rules. The 2-file Boris discipline (CLAUDE.md + BRD) is the source of truth — everything else is derived.

**How the layers enforce it:**

| Enforcement point | Layer | Mechanism |
|---|---|---|
| `/smorch-dev-start` Layer 3 verifies `CLAUDE.md` exists + has 7 anchor sections | L2 `dev-start-bootstrap` | Greps for `Stack:`, `Non-negotiable rules:`, `Command chain:`, `Ship gates:`, `Env vars:`, `Deploy:`, `Rollback SLA:` |
| Layer 4 scores Completeness/Depth/Traceability/Freshness for CLAUDE.md | L2 `dev-start-bootstrap` | Weighted composite per file; weak files surface in weakest-3 report |
| `/smo-score` Architecture hat caps at 6 if CLAUDE.md missing or stale | L2 `smo-scorer` | Hard cap |
| `architecture/brd.md` companion is required (BRD AC-N.N tags drive everything downstream) | L2 `brd-traceability` | AC coverage <90% → Engineering Q2 caps at 6 |

**Practical effect:** every project Claude touches has the same shape. New engineer opens any repo — same place to find the stack, same place to find the deploy command. No tribal knowledge.

### 2.4 — SOPs (global) and project SOPs

**The rule:** SMOrchestra has ~35 SOPs (SOP-01 … SOP-35). They live in `smorch-brain/sops/` (canonical). Some apply globally (SOP-02 scoring gate, SOP-13 handover, SOP-14 plugin verb boundaries). Some apply per project type (SOP-23 weighted scoring per project profile, SOP-33 plugin selection).

**How the layers enforce it:**

| Enforcement point | Layer | Mechanism |
|---|---|---|
| `/smo-dev-guide sops` lists the SOP index + summaries | L2 `dev-guide-router` | Topic dispatch |
| `/smo-dev-guide sop-NN` returns specific SOP summary + file pointer | L2 `dev-guide-router` | `sop-\d+` regex match |
| `/smo-score` weights are read from `.smorch/project.json:qa.scoring_weights` (per SOP-23) | L2 `smo-scorer` | Project-type-specific top-3 critical hats × 80% weight |
| `/smorch-dev-start` Layer 3 verifies `dev_plugin` matches installed plugin (SOP-33) | L2 `dev-start-bootstrap` | Hard gate — RED if plugin missing |
| Project-specific SOPs live in `{repo}/architecture/adrs/` as ADRs | per-repo | ADR-NNN format, referenced from CLAUDE.md |

**Practical effect:** SOPs are findable, summarizable inline, and machine-checkable where they affect behavior.

### 2.5 — Project skills (per-repo overlays)

**The rule:** when a project needs project-specific skills (e.g., content-engine v2 needs `brand-voice-smorchestra` + asset×language skills injected at app runtime), they live in `{repo}/.smorch/skills/` — never in the global plugin. Plugin stays project-agnostic.

**How the layers enforce it:**

| Enforcement point | Layer | Mechanism |
|---|---|---|
| `.smorch/project.json:dev_plugin` declares which plugin owns the workflow (SOP-33) | per-repo + `dev-start-bootstrap` | Schema-checked on every session |
| `.smorch/skills/` discovered by Claude Code at session start | Claude Code native | Project-scope precedence over global skills |
| SOP-25 Skills Injection Gate — every project skill must pass external-agency eval ≥92 before injection | manual + retro | Quality gate |
| Project skills referenced from project CLAUDE.md "Stack" section | per-repo | Discoverable |

**Practical effect:** new project skills don't pollute the global plugin. Plugin upgrades don't break project-specific behavior.

### 2.6 — The composition diagram

```
                   YOU type a command (Layer 1)
                              │
                              ▼
               ┌──────────────────────────────┐
               │  /smorch-dev-start verifies: │
               │   • global CLAUDE.md         │  ← Section 2.2
               │   • project CLAUDE.md        │  ← Section 2.3
               │   • .smorch/project.json     │  ← Section 2.5
               │   • plugin match (SOP-33)    │  ← Section 2.4
               │   • git state (L-009)        │  ← Section 2.1
               │   • input quality scoring    │
               └──────────────────────────────┘
                              │ GREEN
                              ▼
               ┌──────────────────────────────┐
               │  /smo-* command invokes      │
               │   L2 SMOrchestra skill       │
               │   which calls                │
               │   L3 gstack/superpowers      │
               └──────────────────────────────┘
                              │
                              ▼
               artifact produced (BRD edit, score file,
               handover brief, PR, deploy log)
                              │
                              ▼
               commit + push (L-009)  → PR → merge → sync
                              │
                              ▼
               every other machine pulls within 30 min
```

This is the loop. The plugin's job is to make this loop *the only path that works*. Every shortcut (skip the bootstrap, work on `main`, edit on a server, commit without pushing, ship without scoring) is mechanically blocked or loudly flagged.

---

## Part 3 — Every Command, Briefly

### 3.1 — `smorch-dev` plugin commands (12)

| Command | One-line purpose | Owner | Inputs | Outputs |
|---|---|---|---|---|
| `/smorch-dev-start` | Mandatory session-start gate. 4 layers (machine, context, project, input quality). | Anyone | `~/.sync-profile`, cwd, project files | GREEN/YELLOW/RED + next-action |
| `/smo-dev-guide [topic]` | In-session router for "what command now?" + SOP/lesson lookup | Anyone | topic arg or empty | One topic block |
| `/smo-plan AC-N.N` | Plan a feature in plan mode. Reads BRD + lessons + overlay. | Engineer | feature name or AC | Plan structure, awaits approval |
| `/smo-code` | TDD-first coding. Test for AC → implementation → test passes. | Engineer | (in plan mode) | Code + tests + git commit |
| `/smo-score` | 5-hat rubric + auto-caps. Weighted top-3 (SOP-23). | Engineer | cwd repo state | `docs/qa-scores/YYYY-MM-DD-HHMM.md` |
| `/smo-bridge-gaps` | Auto-fix the weakest hat. Only when 80–91. | Engineer | latest score file | Updated code + new score |
| `/smo-handover` | Generate Lana's handover brief. SOP-13 5-dim ready. | Engineer | latest score + PR | `docs/handovers/YYYY-MM-DD-PR-N.md` |
| `/smo-qa-handover-score` | Lana scores handover 0-100 (5 dimensions × 20). | Lana | handover file | Accept (≥80) / send-back (60-79) / reject (<60) |
| `/smo-qa-run` | Execute QA: 4 scenarios per AC + axe + MENA + rollback drill. | Lana | staging URL | `docs/qa/YYYY-MM-DD-PR-N.md` PASS/FAIL |
| `/smo-ship` | Merge PR + tag release. 5 parallel gates (score, hat-floor, QA, handover, git-clean). | Engineer | passed gates | Merged PR + `vX.Y.Z` tag |
| `/smo-triage` | Live diagnostic when something is broken right now. | Engineer | symptom description | Hypothesis + evidence + fix path |
| `/smo-retro` | Weekly/monthly retrospective. Promotes lessons.md candidates. | Mamoun | `~/.claude/lessons.md` + per-repo lessons | Promotion PR for global lessons |

### 3.2 — `smorch-ops` plugin commands (7)

These are infrastructure verbs. Installed on every machine, including servers.

| Command | One-line purpose | Notes |
|---|---|---|
| `/smo-deploy --env staging\|production` | SSH + pm2 reload (or docker-compose up). GitHub → server. | Reads `.smorch/project.json:deploy.{env}`. Health check post-deploy. |
| `/smo-rollback --env <env>` | Revert deploy + restart. SLA 90s prod / 120s staging. | Audit-logged, Telegram-notified. |
| `/smo-drift` | 3-tier drift report (git, config, plugin). | Reports across all machines via heartbeat dashboard. |
| `/smo-health` | Server-side health (services + endpoints + disk + memory). | Distinct from `/smorch-dev-start` (client-side bootstrap). |
| `/smo-incident SEV{1-4} <slug>` | Post-mortem write-up. | Different verb from `/smo-triage` (live) — incident is *after* resolution. |
| `/smo-secrets [--list\|--rotate <type>\|--backup]` | 90-day SLA rotation, 1Password-backed. | `--backup` is L-001 enforcement (always before destructive maintenance). |
| `/smo-skill-sync` | Force pull canonical skills from `smorch-brain` to `~/.claude/skills/`. | Manual override of cron sync. |

### 3.3 — Two commands worth deep focus

#### `/smorch-dev-start` (the front door)

Run this FIRST every session. Period. 4 layers:

```
Layer 1 — Machine
  Tools (git, gh, node, claude, tailscale, docker per role) · plugins
  installed · ~/.claude/{CLAUDE.md, lessons.md, settings.json} present
  + valid · sync job registered

Layer 2 — Context
  cwd inside repo-workspace · remote is SMOrchestra-ai or
  smorchestraai-code · branch is `dev` (NOT main, L-014) · not behind
  origin >24h · no uncommitted >1h (L-009)

Layer 3 — Project (Boris)
  CLAUDE.md present + Boris-shaped · .smorch/project.json schema valid
  · architecture/brd.md with ≥1 AC · docs/ tree (6 subfolders)
  · .claude/settings.json wires lessons hook · .env.example sans secrets
  · .gitignore has required patterns · dev_plugin matches installed (SOP-33)

Layer 4 — Input inventory + quality scoring
  Per project-type (customer-facing-app / internal-tool / infrastructure
  / sold-product / automation-only / research-spike), enumerate expected
  inputs. Each PRESENT input scored 0-10 on 4 dimensions:
    Completeness 40% · Depth 30% · Traceability 20% · Freshness 10%
  Composite per input + overall input-readiness.
  Gate: ≥85 GREEN · 70-84 YELLOW · <70 RED.
```

**Flags:** `--fix` (auto-heal safe findings), `--quiet` (banner + next only), `--profile=<role>` (override auto-detect), `--layer=<N>` (run only layer N), `--skip-project` (machine-only).

**Exit codes:** 0 GREEN · 1 YELLOW · 2 RED · 3 --fix applied · 10 profile unknown.

**Auto-detected role** (writes `~/.sync-profile`): `eng-desktop` (Mac/Linux engineers), `qa-machine` (Lana / future QA), `dev-server` (smo-dev, smo-eo-qa), `prod-server` (smo-prod, eo-prod).

**Never auto-does:** force-push, reset --hard, secrets rotation, deploys, plugin uninstall, cross-repo edits.

#### `/smo-dev-guide` (the in-session router)

Inline help. Don't open a browser, don't context-switch — `/smo-dev-guide` answers in the session.

**Topics:**

```
Bootstrap & gates: start · overview · next · chain · score · handover
                   · qa · ship · deploy
Architecture:      architecture · plugins · overlay · skills · marketplace
                   · validators · hooks
Infrastructure:    infra · servers · install · sync · drift · secrets · incident
Config & policy:   locale · rollback · dirs · verbs
Meta:              sops · lessons · stuck · sop-NN · l-NNN
```

**Killer use case:** `/smo-dev-guide next` — reads your live state (last `/smorch-dev-start` result, current branch, latest score, latest handover, open PRs) and outputs the *one* command to run next, with the reason. No more "wait, did I score yet?"

---

## Part 4 — Every Skill, Briefly

### 4.1 — `smorch-dev` skills (11)

| Skill | What it does | Triggered by |
|---|---|---|
| `dev-start-bootstrap` | 4-layer session bootstrap + input scoring | `/smorch-dev-start` |
| `dev-guide-router` | Topic dispatch + context-aware "next" | `/smo-dev-guide [topic]` |
| `smo-scorer` | 5-hat rubric, auto-caps, weighted top-3 (SOP-23), per-project floors | `/smo-score`, also pre-flight in `/smo-plan` |
| `brd-traceability` | `architecture/brd.md` AC ↔ test coverage; emits scenario stubs | `/smo-plan`, `/smo-handover --validate`, `/smo-score` Engineering hat cap |
| `handover-generator` | SOP-13 brief auto-fill from latest score + PR + scenarios | `/smo-handover` |
| `qa-handover-scorer` | Lana's 5-dim rubric (Completeness/Testability/Repro/Risk/Rollback × 20) | `/smo-qa-handover-score` |
| `arabic-rtl-checker` | Cairo/Tajawal fonts, dir=rtl, BiDi isolation, icon mirror | `/smo-qa-run` when `locale=ar-MENA\|mixed`; `/smo-score` UX hat cap |
| `mena-mobile-check` | 375px viewport, AED/SAR/QAR/KWD currencies, Fri/Sat weekend, DD/MM/YYYY | `/smo-qa-run` MENA gate |
| `cost-tracker` | Claude/OpenAI/DB cost projections per PR; flag if >2× baseline | `/smo-plan` cost preview, `/smo-score` |
| `elegance-pause` | Pre-commit elegance review — "is this the simplest correct shape?" | Before `/smo-handover` |
| `lessons-manager` | lessons.md auto-promote (3+ project triggers → global) | `/smo-retro` |

### 4.2 — `smorch-ops` skills (7)

| Skill | What it does |
|---|---|
| `security-hardener` | UFW + fail2ban + SSH key-only + unattended-upgrades baseline |
| `incident-runbook` | SEV1-4 playbook + post-mortem template |
| `deploy-pipeline` | PM2 / docker-compose / systemd decision tree (L-004) |
| `rollback-runbook` | Per-orchestration rollback templates with SLA |
| `drift-detector` | Git + config + plugin 3-tier drift checks |
| `secrets-manager` | 90-day SLA rotation procedures per secret type |
| `codex-doctrine` | Code quality enforcer (per SOP-11) |

### 4.3 — How L2 delegates to L3

L2 skills are *thin*. They encode SMOrchestra-specific rules and delegate craft. Examples:

| L2 skill | Calls L3 |
|---|---|
| `/smo-plan` workflow → step 6 | `superpowers:writing-plans` (drafts plan structure) + `gstack:autoplan` (review pattern) |
| `/smo-code` workflow | `superpowers:test-driven-development` (RED-GREEN-REFACTOR cycle) |
| `/smo-triage` | `superpowers:systematic-debugging` (hypothesis → evidence → fix) |
| `/smo-handover --validate` | `superpowers:verification-before-completion` (pre-handover sanity) |
| `/smo-ship` | `gstack:ship` + `gstack:land-and-deploy` (release patterns) |
| Multi-repo work | `superpowers:using-git-worktrees` + `superpowers:dispatching-parallel-agents` |

**Why this matters:** when a `superpowers` upstream releases a better TDD pattern, we get it for free. When the SMOrchestra-specific rule changes (e.g., score floor moves from 92 to 90 for student projects), we change `smo-scorer` only — L3 stays put.

---

## Part 5 — Three Real Scenarios (start-to-finish sequences)

### Scenario A — Brand-new app

**Context:** Mamoun decides we need a new tool — say, a UAE legal-translation Arabic→English assistant. From zero to first prod deploy.

```
[Day 0 — decide + scaffold]

01. /smorch-dev-start
    → Mac, eng-desktop, GREEN. (run on a clean shell to confirm baseline.)

02. gh repo create SMOrchestra-ai/uae-legal-translator --private \
       --description "Arabic→English UAE legal translation assistant"
    gh repo edit ... --add-topic smo --add-topic status-dev \
       --add-topic distribution-internal

03. SHA=$(gh api repos/SMOrchestra-ai/uae-legal-translator/git/refs/heads/main --jq .object.sha)
    gh api repos/SMOrchestra-ai/uae-legal-translator/git/refs --method POST \
       -f ref="refs/heads/dev" -f sha="$SHA"

04. gh repo clone SMOrchestra-ai/uae-legal-translator \
       ~/Desktop/repo-workspace/smo/uae-legal-translator
    cd ~/Desktop/repo-workspace/smo/uae-legal-translator
    git checkout dev

05. Scaffold mandatory files (Guide 01 §3):
    - CLAUDE.md (copy template, fill Stack + Rules)
    - .smorch/{project.json (use template), README.md}
    - architecture/brd.md (Problem, ICP, MVP, ACs, OOS, metrics, deps)
    - .claude/{lessons.md, settings.json (SessionStart hook)}
    - docs/{handovers,qa-scores,qa,incidents,deploys,retros}/
    - .env.example, .gitignore, README.md, tests/
    git add . && git commit -m "feat(scaffold): Boris + .smorch + docs/" && git push

06. /smorch-dev-start
    → expect GREEN now. Layer 4 input-readiness ~70-85 (BRD has 1 AC,
      .env.example empty, tests/ empty — all expected for day 0).

[Day 1 — first feature]

07. /smo-plan AC-1.1
    → enters plan mode, reads BRD, drafts approach. You approve.

08. /smo-code
    → TDD: writes failing @AC-1.1 test, then implementation, then test passes.
    → commits incrementally. Pushes feat/SMO-XXX-translate-arabic-to-en branch.

09. /smo-score
    → composite + per-hat. Saved to docs/qa-scores/YYYY-MM-DD-HHMM.md.
    → if <92 or any hat <8.5 → /smo-bridge-gaps → re-score.

10. /smo-handover
    → reads latest score + open PR + BRD ACs, generates handover at
      docs/handovers/YYYY-MM-DD-PR-N.md.

[Day 1 — Lana picks up handover (could be same day or next)]

11. Lana: /smorch-dev-start --profile=qa-machine
    → her Mac, GREEN.

12. Lana: /smo-qa-handover-score docs/handovers/YYYY-MM-DD-PR-N.md
    → 5 dims × 20. ≥80 accept → continue. 60-79 send back. <60 reject.

13. Lana: /smo-qa-run --env staging --url https://staging-uae-legal-translator...
    → 4 scenarios × N AC + axe + MENA (since locale=ar-MENA) + rollback drill.
    → docs/qa/YYYY-MM-DD-PR-N.md PASS/FAIL.

[Day 1 — back to Engineer]

14. /smo-ship
    → 5 parallel gates (score, hat-floor, QA PASS, handover ≥80, git-clean).
    → merge PR to dev (squash), tag v0.1.0.

15. /smo-deploy --env staging
    → SSH smo-dev, pull tag, build, pm2 reload, /api/health 200.

16. Lana re-runs /smo-qa-run --env staging on the live staging URL
    → final pre-prod check.

17. Release PR dev → main, CEO approves, merge.
    /smo-deploy --env production
    → SSH smo-prod, pull tag, build, pm2 reload, /api/health 200.
    → Telegram heartbeat: 🚀 uae-legal-translator v0.1.0 deployed.

18. Add `status-dev` → `status-beta` topic flip when first customer touches it.
```

**Total wall-clock for first feature:** ~3 hours engineer + 30 min Lana. Steady state per feature thereafter: ~25 min handover→deploy (SOP-18 streamline).

### Scenario B — v2 of existing app (major version)

**Context:** Signal-Sales-Engine is at v1 in production. New scoring engine is a breaking change. v2 in-place upgrade (per Guide 02 v2 decision tree — same product, breaking API).

```
[Day 0 — decide + ADR]

01. /smorch-dev-start
    → cwd = ~/Desktop/repo-workspace/smo/Signal-Sales-Engine
    → Layer 3 GREEN, Layer 4 input-readiness 88 (mature repo).

02. /smo-dev-guide overlay
    → review .smorch/project.json conventions before bumping major.

03. git checkout dev && git pull --ff-only
    git checkout -b feat/v2-scoring-engine

04. Write architecture/adrs/ADR-007-v2-scoring-engine.md:
    - Why breaking
    - Migration path (auto/manual)
    - Backward compat window (zero — v2 supersedes v1 immediately)
    - Risk + rollback plan

05. Update architecture/brd.md:
    - Old AC-N.N preserved for trace
    - New AC-2.1, AC-2.2, ... for v2 scope

06. Update CLAUDE.md "Stack:" line + bump major in package.json
    (1.4.2 → 2.0.0-rc.1)

07. Write scripts/migrate-v1-to-v2.{sh,sql}:
    - Idempotent
    - Reversible
    - Test against staging DB snapshot first

[Day 1-N — implement v2]

08. /smo-plan AC-2.1
    → plan + Lana pre-flight check (handover-readiness from start).

09. /smo-code → /smo-score → loop until each AC composite ≥92.

10. Test harness covers v1→v2 data migration as a separate test category
    (tests/migration/) so you don't conflate feature tests with migration tests.

[Day N — handover + ship]

11. /smo-handover (mention BREAKING CHANGE in body, link ADR-007)

12. Lana: /smo-qa-handover-score → /smo-qa-run --env staging
    → MUST include rollback drill (qa.rollback_drill=required for breaking changes —
      DON'T flip to optional).

13. /smo-ship --major (bumps to v2.0.0, not patch)
    → CHANGELOG.md auto-updated with BREAKING note.

14. /smo-deploy --env staging
    → run migration: ssh smo-dev "cd /root/Signal-Sales-Engine && bash scripts/migrate-v1-to-v2.sh"
    → /smo-qa-run --env staging again (Lana confirms data migrated correctly).

15. Release PR dev → main with body containing:
    - ADR-007 link
    - Migration script path
    - Rollback procedure
    - Lana's QA report path

16. CEO approves release PR.
    /smo-deploy --env production
    → migration runs against prod DB (BACKUP FIRST: /smo-secrets --backup db).
    → /api/health 200 + manual smoke test.

17. Tag v2.0.0 (the major bump). Update repo topic if scope changed
    (e.g., add `breaking-change-2026-04` for trace).

18. /smo-retro — capture v2 lessons into per-project .claude/lessons.md.
    Anything cross-project candidate → flag for global promotion at month end.
```

### Scenario C — Patching + minor release + QA cycle

**Context:** customer reports a bug in EO-MENA — Arabic dates render in Gregorian on the dashboard. SEV3 (annoying, not blocking transactions). Standard fix path through `dev`.

```
[Hour 0 — triage]

01. /smorch-dev-start
    → cwd = ~/Desktop/repo-workspace/eo/eo-mena (Lana noticed; Mamoun assigns)
    → GREEN.

02. /smo-triage "Arabic dates rendering Gregorian on dashboard"
    → systematic-debugging (L3) walks hypothesis → evidence chain.
    → identifies: locale formatter not respecting locale=ar-AE.
    → suggests fix: src/lib/dateFormat.ts uses `new Date().toLocaleString()`
      without locale arg.

03. Linear ticket created: SMO-NNN. Branch:
    git checkout dev && git pull --ff-only
    git checkout -b fix/SMO-NNN-arabic-date-formatter

[Hour 1 — fix + score]

04. Write regression test FIRST (TDD discipline):
    tests/lib/dateFormat.test.ts with @AC-3.4 tag covering:
    - Arabic locale → Hijri or Latin-numeral Gregorian (per BRD AC-3.4)
    - Empty input → returns "—" (not crash)
    - Invalid date → throws DateFormatError (not silent NaN)
    - Edge: Friday/Saturday weekend display

05. Run test → RED.

06. Fix dateFormat.ts: pass `locale: 'ar-AE'` + `calendar: 'gregory'` with
    Latin numerals (per UAE government convention).

07. Run test → GREEN. Run full suite → all GREEN.

08. /smo-score
    → composite 94, all hats ≥8.5. Saved to docs/qa-scores/.

09. /smo-handover
    → brief auto-generated, scenarios filled (happy/empty/error/edge).
    → docs/handovers/YYYY-MM-DD-PR-N.md.

[Hour 2 — Lana's QA]

10. Lana: /smorch-dev-start --profile=qa-machine → GREEN.

11. Lana: /smo-qa-handover-score docs/handovers/...
    → 5 dims × 20. Says 84. Accept.

12. Lana: /smo-qa-run --env staging
    → 4 scenarios per AC + axe (English; Arabic axe skipped — locale=ar-MENA
      ⊕ docs-only-ish PR, but actually code change so MENA checks DO run)
    → arabic-rtl-checker: PASS
    → mena-mobile-check: PASS at 375px
    → /smo-rollback --dry-run: PASS (rollback drill required)
    → docs/qa/YYYY-MM-DD-PR-N.md → PASS.

[Hour 3 — ship + deploy]

13. /smo-ship (defaults to --patch since fix/, not feat/)
    → 5 parallel gates pass. Merge PR to dev. Tag v1.7.3 (was v1.7.2).

14. /smo-deploy --env staging
    → SSH eo-prod (eo-mena hosts here per .smorch/project.json), pull tag,
      docker compose pull && up -d eo-mena, /api/health 200.

15. Lana re-runs /smo-qa-run --env staging on the live URL — final smoke.

16. Release PR dev → main. CEO 1-click approval (status-production, 1 review).
    /smo-deploy --env production
    → same flow on production target.
    → /api/health 200, Telegram heartbeat.

17. Update Linear SMO-NNN to Done, link PR + handover + QA report.

18. Per-project lessons.md updated:
    L-EO-MENA-NNN: "Locale formatters need explicit locale + calendar args
    when defaulting to system locale isn't ar-AE."
```

**Wall-clock:** ~3 hours total. Hot fix path (SEV1) skips `dev` and goes branch → main directly with backport (Guide 02 §2).

---

## Part 6 — Newcomer Q&A (anticipated breaks + confusions)

### "I just opened the repo for the first time. What do I run?"

```bash
/smorch-dev-start
```

That's it. It tells you the next step. If you've never installed the plugin, run the install one-liner from Guide 04 first:

```bash
curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/eng-desktop.sh | bash
```

### "What's the difference between `/smorch-dev-start` and `/smo-dev-guide`?"

- `/smorch-dev-start` *checks* the world (machine + repo + project + inputs) and gates the session. You run it once at session start, and again whenever something changes (new repo, new branch, after install).
- `/smo-dev-guide` *answers questions* about how the system works. Topics like `next`, `stuck`, `score`, `sop-13`. You can run it any time without affecting state.

Quick test: bootstrap = "should I be allowed to start work?"; guide = "what should I do now?".

### "Why are there two plugins (`smorch-dev` + `smorch-ops`)?"

Verb boundaries (SOP-14):
- `smorch-dev` owns `plan`, `code`, `score`, `handover`, `ship`, etc. — engineer + QA workflow.
- `smorch-ops` owns `deploy`, `rollback`, `drift`, `health`, `incident`, `secrets`. — infra ops.

Why split? Because servers run `smorch-ops` (need deploy + drift + secrets) but DON'T need `smorch-dev` (servers don't write code). The split lets us install the right surface on the right machine.

### "I tried to commit and a hook blocked me. How do I bypass?"

**Don't use `--no-verify`.** Hooks block real risks (destructive ops, secrets in commits, direct push to main). The right move:

1. Read the error — it tells you exactly what triggered.
2. Fix the underlying issue (move the secret to `.env.local`, target a feature branch, not main, etc.).
3. Commit again.

If you're absolutely sure the hook is wrong (false positive), file an issue against `smorch-dev` — don't bypass silently.

### "I scored 88. Now what?"

`/smo-bridge-gaps`. It reads the latest score file, finds the lowest hat, and helps you fix that hat first (not the easiest one). Auto-caps tell you what dragged the score down — usually one of:
- Engineering Q2 → BRD `@AC-N.N` test coverage <90%. Add tests.
- Product Q1 → no `architecture/brd.md`. Write one.
- UX Q3 → MENA project missing `arabic-rtl-checker` pass. Run the checker.

### "Lana sent my handover back at 72. What does that mean?"

She scored 5 dimensions × 20 = 100 max. Below 80 = send back with specific list of what to fix. Read her comment on the handover file. Common gaps:
- Stub placeholders left in scenario sections (`{stub — replace with real steps}`)
- Rollback path not stated
- Risk section just says "none" without justification
- Repro steps don't include test account creds path (`~/.claude/secrets/test-accounts.env`)

Fix every item, run `/smo-handover --validate` (blocks commit if any stub remains), then ping her again.

### "I'm on `main`. `/smorch-dev-start` says RED. Why?"

L-014: production is sacred, never develop on `main` locally. `main` reflects what's deployed to prod. You always work on `dev` or `feat/*`/`fix/*`/`hotfix/*`.

```bash
git checkout dev && git pull --ff-only
git checkout -b feat/SMO-NNN-your-thing
```

The only legitimate reason to be on local `main` is to do a release PR review or to read deployed state — never to commit.

### "I deployed to staging but `/smo-deploy --env production` is blocked. Why?"

Several possible reasons (`/smo-deploy` lists the specific one):
- Lana hasn't re-run `/smo-qa-run --env staging` against the live staging URL yet.
- `/smo-drift` reports server HEAD ≠ origin HEAD (someone edited on the server — never do this).
- Health check on staging returns ≠200.
- `.env` backup older than 24h (L-001 enforcement) → run `/smo-secrets --backup` first.

Resolve the specific blocker and retry.

### "Where do my project-specific skills live?"

Inside the repo: `{repo}/.smorch/skills/`. Plugin stays project-agnostic — never put project-specific skills in `~/.claude/skills/` or in `smorch-dev/plugins/smorch-dev/skills/`.

Why? When you upgrade the plugin, project skills shouldn't break. When another project gets cloned, it shouldn't inherit your project's skills.

### "Where do SOPs live? How do I find one?"

Canonical: `smorch-brain/sops/` (synced to every machine via cron). Lookup inline:

```bash
/smo-dev-guide sops      # list all SOPs
/smo-dev-guide sop-13    # specific SOP summary + file pointer
```

### "Why does `/smorch-dev-start` Layer 4 say my BRD scored 6.5 on Depth?"

Read the rubric in `dev-start-bootstrap` SKILL.md. Common BRD depth issues:
- AC count <3 (too thin) or >30 (scope creep — split the project)
- ACs lack `given/when/then` structure
- ACs are not testable (e.g., "system should be fast" → not testable; "P95 latency <200ms" → testable)

Rewrite the weakest ACs and re-run `/smorch-dev-start --layer=4` to see the new score.

### "I'm on Windows. Does any of this work?"

Yes. Lana runs on Windows (PowerShell + Git Bash + Claude Desktop). `qa-machine.ps1` installs the toolkit. `/smorch-dev-start` auto-detects `qa-machine` profile and runs the bash logic under Git Bash.

A handful of L1 checks degrade gracefully on Windows (no `launchd` — uses Task Scheduler; no `tailscale` CLI on some setups — uses GUI status). Behavior is otherwise identical.

### "I want to use a non-`smorch-dev` plugin (e.g., for an EO student project). How?"

Set `.smorch/project.json:dev_plugin` to `eo-microsaas-dev` (or whatever). `/smorch-dev-start` Layer 3 verifies that plugin is installed; `/smo-*` commands refuse to run and direct you to `/eo-*` equivalents. See Guide 03.

### "What if `/smorch-dev-start` exits with code 10?"

Profile detection failed (no `~/.sync-profile` AND no hostname match AND no OS heuristic worked). Pass it explicitly:

```bash
/smorch-dev-start --profile=eng-desktop  # or qa-machine, dev-server, prod-server
```

It writes `~/.sync-profile` on success so you only do this once.

### "How do I know my machine is in sync with everyone else's?"

```bash
/smo-drift           # 3-tier (git, config, plugin) drift report
```

If this is silent for >45 min on the dashboard (`flow.smorchestra.ai/webhook/*-drift` heartbeats), Mamoun gets a Telegram alert.

### "Where are the guides themselves? I want to update one."

```
SMOrchestra-ai/smorch-dev/docs/guides/
```

Edit on `dev` branch → PR → merge to `main` → sync-from-github cron pushes to every machine within 30 min. Don't edit copies anywhere else (they're tombstoned).

### "My session-start hook isn't loading lessons.md. How do I check?"

```bash
cat ~/.claude/settings.json | jq '.hooks.SessionStart'
```

Should reference `~/.claude/lessons.md` via a python3 JSON wrapper. If it doesn't, run:

```bash
bash ~/Desktop/repo-workspace/smo/smorch-dev/install/shared/patch-claude-md.sh
```

Or the nuclear option: `/smorch-dev-start --fix` will reinstall the canonical `~/.claude/settings.json` (with confirm).

### "I committed to the wrong branch. How do I fix?"

```bash
git checkout dev
git cherry-pick <sha-of-your-commit>
git push origin dev   # or via PR if dev is protected
git checkout <wrong-branch>
git reset --hard HEAD~1   # removes the bad commit (only if you haven't pushed it)
```

If you already pushed: open PR from wrong-branch to dev, then revert the wrong-branch push (don't force-push without CEO approval — destructive op blocked by hook).

### "How do gstack and superpowers fit in? Do I ever invoke them directly?"

Rarely. You invoke `smorch-dev` commands; *those* commands' workflows include calls to gstack/superpowers skills. Direct invocation is fine if you know what you're doing (e.g., `superpowers:writing-skills` when authoring a new skill, `gstack:design-review` for a quick design pass), but in normal flow the L1 commands cover it.

The plugins exist as upstream forks under `smorchestraai-code` org so we get bug fixes without forking the whole world. Don't edit them — file upstream issues instead.

### "What is `smorch-brain`?"

The canonical store for cross-project artifacts:
- `canonical/` — repo registry, server registry, supabase registry, n8n topology, plugin registry, claude-md templates, lessons.md global
- `sops/` — SOP-NN documents
- `skills/` — global skills (mirrors `~/.claude/skills/` for sync)
- `docs/infra/` — phase reports, hardening evidence

It's a git repo (`SMOrchestra-ai/smorch-brain`) cloned to every machine at `~/smorch-brain` (engineer/QA) or `/root/smorch-brain` (server). The sync cron keeps it current.

### "Where's the cheat sheet for everything?"

You're reading it. For an even tighter inline version:

```bash
/smo-dev-guide overview
```

Or specific topics:

```bash
/smo-dev-guide start      # the bootstrap
/smo-dev-guide chain      # daily chain with wall-clock
/smo-dev-guide architecture  # 3-layer model
/smo-dev-guide stuck      # decision tree for common breaks
```

---

## Part 7 — One-Page Recap

```
3 layers:
  L1  commands you type (12 dev + 7 ops)
  L2  smorch-dev skills (SMOrchestra rules)
  L3  gstack + superpowers (general dev craft)

Always first:
  /smorch-dev-start    — 4-layer gate (machine + context + project + inputs)

Always know what's next:
  /smo-dev-guide next  — context-aware "run this next"

Daily chain:
  plan → code → score → bridge-gaps → handover → qa-handover-score
       → qa-run → ship → deploy

Hard gates:
  composite ≥92, no hat <8.5, handover ≥80, QA PASS, git clean,
  rollback drill ≥dry-run, .env backup ≤24h, branch ≠ main locally

3 SSOTs:
  GitHub                — code, plugins, guides, SOPs, registries
  ~/.claude/CLAUDE.md   — global discipline
  {repo}/CLAUDE.md      — project discipline (Boris 40-80 lines)

3 cron mechanicals:
  perfctl sentinel      */30 min  malware IOCs
  drift detectors       hourly    git/config/plugin
  sync-from-github      */30 min  pull canonical to every machine

If RED, run --fix. If stuck, /smo-dev-guide stuck. If lost, /smo-dev-guide next.
```

---

## See also

- [`00-MACRO-SUMMARY.md`](00-MACRO-SUMMARY.md) — Apr 22-23 infrastructure rebuild summary
- [`01-START-NEW-APP.md`](01-START-NEW-APP.md) — full new-app scaffold flow
- [`02-PATCH-V2-QA.md`](02-PATCH-V2-QA.md) — patch + v2 + QA operations
- [`03-CUSTOMIZE-DEV-PLUGIN.md`](03-CUSTOMIZE-DEV-PLUGIN.md) — non-default plugin selection
- [`04-SETUP-ENVIRONMENT.md`](04-SETUP-ENVIRONMENT.md) — fresh machine install (eng/QA/server)
- [`README.md`](README.md) — guides SSOT policy
- `smorch-dev/plugins/smorch-dev/commands/*.md` — every command's full spec
- `smorch-dev/plugins/smorch-dev/skills/*/SKILL.md` — every skill's full implementation
- `smorch-brain/sops/` — every SOP
- `~/.claude/lessons.md` — every global lesson (L-001 … L-NNN)
