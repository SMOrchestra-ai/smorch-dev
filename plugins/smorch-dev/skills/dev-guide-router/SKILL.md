---
name: dev-guide-router
description: |
  In-session guide router for smorch-dev + smorch-ops. Resolves topic queries from /smo-dev-guide. Covers command surface (17 commands + verb boundaries), daily chain + wall-clock targets, scoring gates (92/8.5), SOP-13 handover rubric, QA workflow + MENA/rollback gates, architecture (plugins + overlay + 2-tier skills + marketplace), infrastructure (4 servers + Tailscale + install profiles + cron sync + drift detection), deploy paths (PM2 vs docker-compose), incident response, secrets rotation, hooks, validators, lessons. Context-aware "next" resolves to a single command based on current repo state. Read-only. Never hallucinates commands or SOPs.
---

# dev-guide-router — In-Session Guide

**Invoked by:** `/smo-dev-guide [topic]`
**Consumes:** `.smorch/project.json`, latest files in `docs/qa-scores/`, `docs/handovers/`, `docs/qa/`, git branch/PR state, lessons.md pointers
**Produces:** Single topic section, printed inline. No files written.

---

## Routing contract

| Input | Action |
|---|---|
| empty | print `overview` |
| `next` | context-aware recommendation (reads live state) |
| known topic | print that topic section |
| `sop-NN` | print that SOP's summary + file pointer |
| `l-NNN` | print that lesson's rule + why + how-to-apply |
| unknown | print `no topic "{x}" — try: {full topic list}` |

One topic per invocation. If two are obviously linked, end with `also see: {topic}` — no more than two cross-links.

### Full topic list

Bootstrap & gates:
`start` · `overview` · `next` · `chain` · `score` · `handover` · `qa` · `ship` · `deploy`

Architecture:
`architecture` · `plugins` · `overlay` · `skills` · `marketplace` · `validators` · `hooks`

Infrastructure:
`infra` · `servers` · `install` · `sync` · `drift` · `secrets` · `incident`

Config & policy:
`locale` · `rollback` · `dirs` · `verbs`

Meta:
`sops` · `lessons` · `stuck` · `sop-NN` · `l-NNN`

---

## Topic: `start`

```
/smorch-dev-start — session bootstrap gate. Run FIRST every session.

Works on: Mac (Mamoun, engineers), Windows (Lana, QA), Linux, servers.
Auto-detects role from ~/.sync-profile OR hostname heuristic.
Roles: eng-desktop · qa-machine · dev-server · prod-server.

Four layers:

  Layer 1 — Machine
    tools (git/gh/node/claude/tailscale/docker per role)
    plugins (smorch-dev + smorch-ops installed)
    global config (~/.claude/{CLAUDE.md, lessons.md, settings.json})
    sync job (cron/launchd registered)

  Layer 2 — Context
    cwd inside ~/Desktop/repo-workspace/
    remote is SMOrchestra-ai or smorchestraai-code
    branch is dev (not main — L-014)
    local not >24h behind origin
    no uncommitted changes >1h (L-009)

  Layer 3 — Project (Boris enforcement)
    CLAUDE.md · .smorch/project.json · architecture/brd.md
    docs/ tree (6 subfolders) · .claude/settings.json
    .env.example (no secrets) · .gitignore (required patterns)
    dev_plugin match (SOP-33)

  Layer 4 — Input inventory + quality scoring (0-10 per dimension)
    Completeness (40%) · Depth (30%) · Traceability (20%) · Freshness (10%)
    Missing-input report per project type (customer-facing-app, internal-tool, etc.)
    INPUT-READINESS gate: ≥85 GREEN · 70-84 YELLOW · <70 RED

Flags:
  --fix              auto-heal safe findings
  --quiet            banner + next-action only
  --profile=<role>   override detection
  --skip-project     machine-only (Layers 1+2)
  --layer=<N>        run only layer N

Exit codes: 0 GREEN · 1 YELLOW · 2 RED · 3 --fix applied · 10 profile unknown

Never auto-does: force-push, reset --hard, secrets rotation, deploys.

also see: next · chain · score
```

---

## Topic: `overview`

```
smorch-dev + smorch-ops — 19 commands, 2 plugins, 0 overlap.

Session bootstrap (run FIRST every session):
  /smorch-dev-start  — machine + context + project + input-quality (4 layers)
                       GREEN/YELLOW/RED gate, --fix for auto-heal

Workflow (smorch-dev, 12 commands):
  /smorch-dev-start /smo-plan /smo-code /smo-score /smo-bridge-gaps
  /smo-handover /smo-qa-handover-score /smo-qa-run
  /smo-ship /smo-triage /smo-retro
  /smo-dev-guide (this)

Ops (smorch-ops, 7 commands):
  /smo-deploy /smo-rollback /smo-drift /smo-health
  /smo-incident /smo-secrets /smo-skill-sync

Gates (non-negotiable):
  /smorch-dev-start = GREEN before /smo-plan (session bootstrap gate)
  composite ≥ 92, no hat < 8.5 before /smo-ship (SOP-02)
  handover score ≥ 80 before QA starts (SOP-13)
  all QA scenarios PASS + rollback drill before ship (SOP-01)
  L-009 push discipline every work unit
  destructive-blocker + secret-scanner hooks always on

Try: /smo-dev-guide start        — bootstrap + input-readiness details
     /smo-dev-guide next         — "what should I run now?"
     /smo-dev-guide architecture — plugin + overlay model
     /smo-dev-guide infra        — 4 servers + sync model
     /smo-dev-guide stuck        — troubleshooting decision tree

Full topic list: /smo-dev-guide (empty) then scroll.
```

---

## Topic: `next` (context-aware)

Read live state to decide. Halt on first matching rule; order matters.

### Context signals (read each one before deciding)
1. `git status --porcelain` → uncommitted changes + how old?
2. `git rev-parse --abbrev-ref HEAD` → on `main`, feature branch, detached?
3. Latest file in `docs/qa-scores/` → composite + per-hat scores
4. Latest file in `docs/handovers/` → handover score
5. Latest file in `docs/qa/` → Decision = PASS/FAIL
6. `.smorch/project.json` → `locale`, `qa.rollback_drill`, `deploy.orchestration`
7. `gh pr status --json state,number` → open PR? mergeable?
8. `architecture/brd.md` → exists? @AC tags covered?

### Rules (first match wins)

| Condition | Recommendation |
|---|---|
| Session-bootstrap never run (no `~/.claude/.last-dev-start` or >8h old) | `/smorch-dev-start` — always the first command per session |
| Most recent `/smorch-dev-start` result = RED or YELLOW | `/smorch-dev-start --fix` (or read remediation text) |
| Layer-4 input_readiness < 85 | fix weakest 3 inputs per the report |
| No `architecture/brd.md` | `/smo-plan` — write BRD first |
| BRD exists, no source files or tests touching it | `/smo-code` — TDD starts here |
| Code committed, no `docs/qa-scores/` file for this branch | `/smo-score --quick` |
| Composite < 92 OR any hat < 8.5 | `/smo-bridge-gaps` — fix weakest hat |
| Composite ≥ 92, no `docs/handovers/` file for this PR | `/smo-handover` |
| Handover exists but has `{stub — ...}` placeholders | fill stubs, then `/smo-handover --validate` |
| Handover score < 80 | fix per Lana's rejection notes, re-score |
| Handover ≥ 80, no QA report | `/smo-qa-handover-score` then `/smo-qa-run` (Lana) |
| QA Decision = PASS, PR not merged | `/smo-ship` |
| PR merged, server HEAD != origin HEAD | `/smo-deploy` |
| All done, clean tree, on main | `/smo-retro` if week ended; else start next feature |
| Uncommitted changes > 30 min | commit + push first (L-009) |

Output format:

```
→ /smo-handover
reason: composite=94 (docs/qa-scores/2026-04-21-1402.md), no handover file in docs/handovers/ for PR #47
next check: /smo-dev-guide handover
```

---

## Topic: `chain`

```
Daily chain — handover→deploy wall-clock targets (SOP-18):

  /smo-plan              ~10 min   plan mode + BRD read
  /smo-code              ~60 min   varies (excluded from streamline targets)
  /smo-score             ~5 min    --quick path
  /smo-bridge-gaps       ~10 min   only if hats < 8.5
  /smo-handover          ~2 min    ↓ from ~7 min (stubs auto-generated)
  /smo-qa-handover-score ~5 min    Lana scores 5 dims
  /smo-qa-run            ~5-6 min  ↓ from ~8 min (locale + rollback gated)
  /smo-ship              ~90 sec   ↓ from ~3 min (5 gates parallel)
  /smo-deploy            ~5 min    SSH + pm2 reload OR docker compose up

Baseline (v1.1.x):    ~53 min handover→deploy
Target (v1.2.0-dev+): ~25 min handover→deploy (≥50% cut)

Gate sequence unchanged: score ≥ 92 → handover ≥ 80 → QA PASS → ship → deploy.

also see: score · handover
```

---

## Topic: `score`

```
Scoring gates (SOP-02, internal calibration):

  Composite gate:  ≥ 92 to ship  (students: ≥ 90)
  Hat floor:       ≥ 8.5 every hat  (students: ≥ 8.0)
  Hats:            Product · Architecture · Engineering · QA · UX

What to do at each level:
  92+ and all hats ≥ 8.5  →  /smo-handover
  80–91 or any hat < 8.5  →  /smo-bridge-gaps (fix weakest first)
  < 80                    →  stop. Return to /smo-plan or /smo-code.

Auto-caps (honesty enforcers):
  — Engineering Q2 caps at 6 if brd-traceability AC coverage < 90%
  — Product Q1 caps at 4 if no architecture/brd.md
  — UX Q3 caps at 6 if locale=ar-MENA and no Arabic RTL check

Where scores live:
  docs/qa-scores/YYYY-MM-DD-HHMM.md
  never in .claude/, never loose in repo root

also see: handover · chain
```

---

## Topic: `handover`

```
Handover brief (SOP-13) — dev → QA contract.

Lana scores 5 dimensions via qa-handover-scorer:
  1. Completeness    (BRD ACs covered, PR URL, staging URL)         0-20
  2. Testability     (4 scenarios per AC: happy/empty/error/edge)   0-20
  3. Repro-ability   (env vars, seed data, test accounts)           0-20
  4. Risk disclosure (known issues, untested areas, regression)     0-20
  5. Rollback readiness (command, SLA, data reversibility)          0-20
  Total: 0-100

Acceptance:
  ≥ 80  →  Lana starts QA (/smo-qa-run)
  60-79 →  sends back with specific fix list
  < 60  →  auto-reject + pings Mamoun

Scenario stubs (v1.2.0-dev+):
  brd-traceability --emit-scenarios auto-seeds 4 stubs per AC.
  Dev replaces every {stub — ...} placeholder with real steps.
  /smo-handover --validate blocks commit if any placeholder remains.

Brief lives at: docs/handovers/YYYY-MM-DD-PR-{n}-handover.md

also see: qa · score
```

---

## Topic: `qa`

```
QA workflow (SOP-01) — Lana's side.

  1. /smo-qa-handover-score {path}   → score 5 dims, accept/reject
  2. /smo-qa-run                     → execute test scenarios
  3. Decision: PASS / FAIL / ESCALATE

Scenario order: happy → empty → error → edge

Locale gate (.smorch/project.json → locale):
  ar-MENA or mixed  →  arabic-rtl-checker + mena-mobile-check (375px) + Arabic axe
  en-US             →  skip all three. Report: "MENA checks: SKIPPED (locale=en-US)"

axe-core English pass: ALL locales. Always runs.

Rollback drill (.smorch/project.json → qa.rollback_drill):
  required (default) → /smo-rollback --dry-run must succeed
  optional           → skip. Report names flipping PR for audit.

Staging health: curl {project}.staging.smorchestra.ai/api/health

QA report: docs/qa/YYYY-MM-DD-PR-{n}-qa-report.md

also see: handover · locale
```

---

## Topic: `ship`

```
/smo-ship = merge PR + tag release. Local → GitHub. NOT deploy.

Parallel gate preamble (v1.2.0-dev+, 5 gates concurrent):
  GATE_score:      composite ≥ 92 (docs/qa-scores/)
  GATE_hat_floor:  no hat < 8.5
  GATE_qa:         Decision = PASS (docs/qa/)
  GATE_handover:   score ≥ 80 (docs/handovers/)
  GATE_git_clean:  no uncommitted, branch up-to-date

Then serial:
  npm run build && npm test && npm audit --audit-level=high
  gh pr create + merge + tag (semver bump, default patch)
  git push origin v{tag}

Failure surface: names the specific gate(s) that failed + evidence path.

Version bump flags:
  --minor  (new feature)
  --major  (breaking)
  default: patch

also see: deploy · verbs
```

---

## Topic: `deploy`

```
/smo-deploy = SSH + pm2 reload OR docker compose up. GitHub → server.

Reads .smorch/project.json → deploy:
  target        smo-dev | smo-prod | eo-prod | smo-eo-qa
  orchestration docker-compose | pm2 | systemd
  path          /opt/apps/{project}  (L-003)
  health        /api/health endpoint

Decision tree (L-004):
  1. Is there a docker-compose.yml at project root?
     YES → docker compose up -d  (NEVER PM2 on compose projects)
     NO  → check orchestration field → PM2 or systemd path

Port conflicts (L-005):
  If docker-compose includes nginx AND host runs system nginx:
    remove compose nginx → app binds 127.0.0.1:{port} → system nginx proxies

Port ghosts (L-006):
  If docker bind fails after restart: network prune -f; if still stuck, offset +100

Health verification (L-007):
  Post-deploy: docker exec {svc} + curl /api/health + count records
  "Looks fine" is NOT restoration confirmation.

Rollback: /smo-rollback {deploy-id}

also see: incident · rollback
```

---

## Topic: `architecture`

```
smorch-dev architecture — 3 layers:

  1. Canonical (smorch-brain)
     — source of truth for shared skills, manifests, SOPs
     — lives at: ~/Desktop/cowork-workspace/CodingProjects/smorch-brain/

  2. Plugins (smorch-dev repo)
     — smorch-dev (workflow): 10 workflow commands + 9 skills
     — smorch-ops (infra):    7 ops commands + 7 skills
     — dev-guide-router + /smo-dev-guide added v1.3.0-dev

  3. Project overlay ({project}/.smorch/)
     — per-project config, skills, templates, overrides
     — plugin stays project-agnostic; overlay carries project specifics
     — ADR-002 convention

2-tier skills (SOP-09):
  global (canonical)     → cross-project patterns (TDD, debugging)
  plugin-scoped          → smorch-dev / smorch-ops skills
  project-scoped overlay → {project}/.smorch/skills/

Discovery (L-008):
  Claude Code auto-discovers commands/ and skills/ folders.
  plugin.json MUST NOT contain commands[] or skills[] arrays.
  Registration: `claude plugin marketplace add` then `claude plugin install`.

also see: plugins · overlay · marketplace
```

---

## Topic: `plugins`

```
Two plugins, clear boundaries:

  smorch-dev   (workflow)  — installed on eng-desktop + qa-machine
  smorch-ops   (infra)     — installed on ALL machines incl. servers

Verb boundaries (SOP-14):
  dev plugin owns: plan, code, score, bridge-gaps, handover,
                   qa-handover-score, qa-run, ship, triage, retro, dev-guide
  ops plugin owns: deploy, rollback, drift, health, incident, secrets, skill-sync

Rules:
  — "ship" = merge + tag.  "deploy" = server push.  Never conflate.
  — "triage" = live diagnostic.  "incident" = post-mortem write-up.
  — No command lives in both plugins.

Schema:
  plugins/{name}/
    .claude-plugin/plugin.json   (NO commands[]/skills[] — L-008)
    commands/*.md                (auto-discovered)
    skills/*/SKILL.md            (auto-discovered)
    templates/                   (optional)
    architecture/brd.md          (how the plugin was designed)

also see: architecture · marketplace · skills
```

---

## Topic: `overlay`

```
.smorch/ — per-project overlay convention (ADR-002).

Project structure:
  {project}/
    .smorch/
      project.json       (required — see template)
      skills/            (optional, project-specific)
      templates/         (optional)
      overrides/         (optional, rubric overrides)

project.json schema (canonical template at
plugins/smorch-dev/templates/smorch-project.json.template):

  project          kebab-case name
  stack            nextjs-supabase | fastapi-postgres | n8n | other
  locale           ar-MENA (default) | en-US | mixed
  mena             true/false (deprecated — use locale)
  deploy.target          smo-dev | smo-prod | eo-prod | smo-eo-qa
  deploy.orchestration   docker-compose | pm2 | systemd
  deploy.path            /opt/apps/{project}
  deploy.health_endpoint /api/health
  qa.rollback_drill      required (default) | optional
  qa.scenarios_auto_generate  true (default)
  scoring.composite_gate 92 (internal) | 90 (student)
  scoring.hat_floor      8.5 (internal) | 8.0 (student)
  cost_tracker.monthly_budget_usd
  cost_tracker.alert_threshold_pct

Missing fields → safe defaults (preserve pre-v1.2.0 behavior).
Policy flips (locale=en-US, rollback_drill=optional) require dedicated PR.

also see: locale · rollback · architecture
```

---

## Topic: `skills`

```
Skills per plugin:

smorch-dev (11 skills):
  smo-scorer            5-hat rubric + auto-caps
  lessons-manager       lessons.md auto-promote
  elegance-pause        pre-commit elegance review
  arabic-rtl-checker    MENA Arabic RTL checks
  mena-mobile-check     MENA 375px mobile check
  brd-traceability      AC ↔ test coverage + scenario stub emit
  handover-generator    SOP-13 brief auto-fill
  qa-handover-scorer    Lana's 5-dim rubric
  cost-tracker          Claude/OpenAI/DB cost caps
  dev-guide-router      /smo-dev-guide router
  dev-start-bootstrap   /smorch-dev-start 4-layer bootstrap (v1.4.0-dev)

smorch-ops (7 skills):
  security-hardener     UFW + fail2ban + SSH posture
  incident-runbook      SEV 1-4 playbook
  deploy-pipeline       PM2 / docker-compose / systemd
  rollback-runbook      rollback template + SLA
  drift-detector        3-tier drift check
  secrets-manager       90-day rotation (SOP-16)
  codex-doctrine        code quality enforcer

also see: architecture · plugins
```

---

## Topic: `marketplace`

```
Claude Code marketplace registration (L-008):

Install flow:
  claude plugin marketplace add SMOrchestra-ai/smorch-dev
  claude plugin install smorch-dev@smorch-dev
  claude plugin install smorch-ops@smorch-dev

NEVER cp/rsync plugin files directly — Claude Code won't discover them.

plugin.json schema (the only valid keys):
  name, version, description, author, homepage,
  repository, license, keywords

Explicitly DO NOT include: commands[], skills[] — those are auto-discovered
from commands/ and skills/*/SKILL.md folders.

Marketplace file:
  .claude-plugin/marketplace.json at repo root (required)

Validator (scripts/validate-plugins.sh) enforces L-008:
  fails if commands[] or skills[] arrays appear in plugin.json.

also see: plugins · validators
```

---

## Topic: `validators`

```
4-point validation (SOP-15):

  1. local pre-commit hook    destructive-blocker + secret-scanner + drift
  2. CI (GitHub Actions)      .github/workflows/validate.yml runs validate-plugins.sh
  3. cron sync (every 30 min) sync-from-github.sh re-validates on pull
  4. drift detector           compares local/CI/server hashes vs canonical manifest

scripts/validate-plugins.sh checks:
  — plugin.json valid JSON with required keys (name, version, description)
  — plugin.json has NO commands[] or skills[] (L-008)
  — all command .md files have `description:` frontmatter
  — all skill SKILL.md have YAML frontmatter fence
  — no dead script references in commands/skills content

Run locally: bash scripts/validate-plugins.sh

also see: hooks · sync · marketplace
```

---

## Topic: `hooks`

```
Git hooks (pre-commit, enforced):

  destructive-blocker
    blocks: rm -rf /, git push --force to main/master, git reset --hard (staged),
            DROP TABLE, TRUNCATE without WHERE, etc.

  secret-scanner-v2
    blocks: AWS keys, GHL API keys, Supabase service keys, Claude/OpenAI keys,
            private keys, .pem files, real .env.* content to non-env paths

  SQL-guard-v2
    blocks: DELETE without WHERE, UPDATE without WHERE, schema drops in migrations

  auto-formatter
    runs: prettier + black + shfmt before commit (advisory, does not block)

  branch-protection-enforcer
    blocks: direct commits to main without PR (unless explicit override)

Bypass discipline:
  NEVER use --no-verify unless user explicitly requests.
  If a hook fails, investigate the root cause. Do NOT work around it.

also see: validators · sops
```

---

## Topic: `infra`

```
Infrastructure — 4 servers + Mamoun's Mac + Lana's Windows.

  eo-prod      89.117.62.131    100.89.148.62     EO production + smorch-brain
  smo-dev      62.171.165.57    100.83.242.99     dev/staging + n8n testflow
  smo-prod     62.171.164.178   100.108.44.127    production + n8n flow
  smo-eo-qa    84.247.172.113   100.99.145.22     test/QA

Tailscale mesh: all 4 servers accessible via 100.x.x.x IPs (private).
Public IPs are ingress only, hardened by security-hardener skill.

Install profiles (install/ directory):
  eng-desktop.sh   Mamoun's Mac + future hires (smorch-dev + smorch-ops + gstack + superpowers)
  qa-machine.ps1   Lana's Windows PowerShell (same toolkit, winget-based)
  dev-server.sh    smo-dev + smo-eo-qa (smorch-ops only, no IDE plugins)
  prod-server.sh   eo-prod + smo-prod (smorch-ops + security-hardener baseline)

Sync: 30-min cron on every server runs scripts/sync-from-github.sh
      + GitHub webhook triggers immediate sync (sub-60s typical)

also see: servers · sync · install
```

---

## Topic: `servers`

```
Server registry (canonical list in smorch-brain/canonical/project-registry.md):

  eo-prod (Contabo VDS, 89.117.62.131 / 100.89.148.62)
    role: EO production + smorch-brain canonical
    runs: eo-mena, eo-scoring, smorch-brain (read-only mirror)
    deploy target for: EO student apps

  smo-dev (Contabo VDS, 62.171.165.57 / 100.83.242.99)
    role: development + staging + test n8n
    runs: n8n at testflow.smorchestra.ai, staging copies of prod apps
    deploy target for: anything with deploy.target=smo-dev

  smo-prod (Contabo VDS, 62.171.164.178 / 100.108.44.127)
    role: production
    runs: SalesMfast, SaaSfast, n8n at flow.smorchestra.ai
    deploy target for: customer-facing prod apps

  smo-eo-qa (Contabo VDS, 84.247.172.113 / 100.99.145.22)
    role: test / QA server
    runs: Lana's QA staging environment

Access:
  SSH via Tailscale: ssh root@100.x.x.x
  Public IP access: hardened (key-only, fail2ban, UFW)
  NEVER edit files directly on a server. Local → GitHub → server pull.

Canonical directory layout per L-003:
  /opt/apps/{project}/     app code
  /opt/config/{project}/   config files
  /opt/logs/{project}/     logs
  /opt/backups/            backup dump location
  /root/smorch-dev/        plugin repo (sync target)

also see: infra · install · dirs
```

---

## Topic: `install`

```
Install profiles — which script for which machine:

  eng-desktop.sh
    target: Mamoun's Mac + future engineering hires (Mac/Linux)
    installs: Node 22, Bun, Claude Code, gh CLI, gstack, superpowers,
              smorch-dev + smorch-ops plugins, cron sync
    propagates: ~/.claude/CLAUDE.md + ~/.claude/lessons.md with L-009

  qa-machine.ps1
    target: Lana's Windows (PowerShell as admin)
    installs: winget-based toolkit + same plugin set + Task Scheduler sync
    propagates: L-009 discipline

  dev-server.sh
    target: smo-dev + smo-eo-qa (Contabo)
    installs: smorch-ops only (no IDE plugins on servers)
    propagates: L-009 + cron sync

  prod-server.sh
    target: eo-prod + smo-prod (Contabo)
    installs: smorch-ops + security-hardener baseline (UFW + fail2ban + SSH key-only)
    propagates: L-009 + cron sync

One-liners (curl + bash):
  Mac/Linux: bash <(curl -fsSL {raw-url}/install/eng-desktop.sh)
  Windows:   iwr -useb {raw-url}/install/qa-machine.ps1 | iex
  Server:    bash <(curl -fsSL {raw-url}/install/prod-server.sh)

also see: infra · sync
```

---

## Topic: `sync`

```
Cross-machine sync (SOP-15) — 3-tier model:

  Tier 1: GitHub webhook → n8n (flow.smorchestra.ai)
          triggers smorch-sync-all on push to main. Sub-60s typical.

  Tier 2: Cron (every 30 min on every machine)
          runs scripts/sync-from-github.sh:
            git fetch + ff-only pull
            re-install plugins (idempotent)
            run validate-plugins.sh
            fire heartbeat to n8n (v1.2.0-dev+)

  Tier 3: Drift detector (hourly)
          compares local hashes vs canonical manifest in smorch-brain
          Telegram alert (CHAT_ID 311453473) + auto-rollback on divergence

Heartbeat (v1.2.0-dev+):
  POST https://flow.smorchestra.ai/webhook/smorch-sync-heartbeat
  body: {host, sha, timestamp, profile, sync_outcome}
  outcomes: up_to_date | synced | pull_failed | validate_failed
  5-sec timeout, non-blocking

Failure visibility:
  Dashboard shows last-sync-per-host.
  Alerts fire if any host silent >45 min.

also see: drift · infra · validators
```

---

## Topic: `drift`

```
Drift detection — 3 scopes:

  Git drift:    local HEAD vs origin HEAD vs server HEAD
    resolve via: git pull ff-only (never reset --hard without CEO approval)

  Config drift: ~/.claude/CLAUDE.md vs canonical template
    resolve via: re-run install script (idempotent)

  Plugin drift: plugin hashes vs smorch-brain/canonical manifest
    resolve via: sync-from-github.sh + validate-plugins.sh
    escalate: Telegram alert if unresolved after 2 sync cycles

/smo-drift command reports all 3 scopes.

Pre-commit drift hook:
  Blocks commits that would land on drifted machines (e.g., local ahead of
  origin, CI/server lagging). Bypass ONLY with explicit "--force-drift" flag
  after CEO approval.

also see: sync · validators
```

---

## Topic: `secrets`

```
Secrets rotation (SOP-16) — 90-day SLA across 4 servers.

Per-secret-type procedures in secrets-manager skill:
  Supabase service keys   rotate via Supabase dashboard → update .env.local on all 4
  Postgres passwords      rotate via psql ALTER USER + update .env on app servers
  GHL API keys           rotate via GHL dashboard → update env + n8n credentials
  Claude/OpenAI keys     rotate via platform console → update env + n8n
  SSH keys               rotate via ssh-keygen + ~/.ssh/authorized_keys update
  GitHub PATs            rotate via GitHub settings → update workflow secrets

/smo-secrets command:
  --list       show all tracked secrets + age
  --rotate X   rotate secret of type X (guides through steps)
  --backup     tar+encrypt all /opt/apps/*/.env* + push to object storage (L-001)

L-001 enforcement:
  Before ANY server rebuild/reinstall → /smo-secrets --backup first.
  Lost .env.local files = incident.

Storage locations (never commit these):
  /opt/apps/{project}/.env.local
  /root/{project}/.env
  ~/.ssh/id_ed25519 (never cloud-sync this file)

also see: incident · infra
```

---

## Topic: `incident`

```
Incident response (SOP-10, smorch-ops):

/smo-incident severity levels:
  SEV1  customer-facing outage, data loss, security breach
        response: immediate. Telegram + phone. Post-mortem within 24h.

  SEV2  degraded production, workaround exists
        response: 1 hour. Telegram. Post-mortem within 48h.

  SEV3  staging issue, non-blocking prod issue
        response: business hours. Log. Post-mortem optional.

  SEV4  internal tooling, developer-facing
        response: next business day. Log only.

/smo-incident workflow:
  1. Detect → Telegram (auto from drift-detector, health checks)
  2. /smo-triage — live diagnostic (what's broken, where)
  3. /smo-rollback if mitigation needs instant revert
  4. Fix (via normal chain: plan → code → score → ship → deploy)
  5. Post-mortem write-up (incident-runbook skill template)
     lives at: docs/incidents/YYYY-MM-DD-SEV{n}-{slug}.md

Verb boundaries:
  /smo-triage   = live diagnostic (still happening)
  /smo-incident = post-mortem write-up (after resolution)

also see: deploy · rollback · secrets
```

---

## Topic: `locale`

```
.smorch/project.json → locale — drives MENA check gating.

Values:
  "ar-MENA"  (default) — arabic-rtl-checker + mena-mobile-check + Arabic axe run
  "en-US"             — all three skipped; English axe still runs
  "mixed"             — all three run (safe for bilingual apps)

Missing field → defaults to "ar-MENA" (preserves pre-v1.2.0 behavior).

Policy flip (to en-US):
  Dedicated PR modifying ONLY .smorch/project.json.
  CEO reviews in isolation — no bundling with feature work.
  QA report records the flipping PR number for audit.

Template: plugins/smorch-dev/templates/smorch-project.json.template

also see: qa · overlay
```

---

## Topic: `rollback`

```
.smorch/project.json → qa.rollback_drill — per-project rollback drill policy.

Values:
  "required" (default) — /smo-rollback --dry-run must succeed in /smo-qa-run
  "optional"           — drill skipped; report notes flipping PR

When optional is appropriate:
  — doc-only PRs (README, ADR, SOP edits)
  — copy-only PRs (UI strings, email templates)
  — already-deployed-reverts (rollback of a rollback)

When optional is NOT appropriate (keep required):
  — customer data, auth, payments, migrations
  — first deploy of a new surface
  — anything you'd lose sleep over at 3am

Policy flip:
  Dedicated PR, .smorch/project.json only. CEO approves.

Rollback runbook skill (smorch-ops/skills/rollback-runbook/):
  has the canonical rollback command template per deploy orchestration.

also see: qa · incident · deploy
```

---

## Topic: `dirs`

```
Canonical directory layout (L-003, enforced):

Local (Mamoun's Mac):
  ~/Desktop/cowork-workspace/
    CodingProjects/
      smorch-dev/         plugin repo
      smorch-brain/       canonical store
      SOPs/               SOP library
      EO-Students/        student-facing fork
      EO-MENA/            EO prod project
      Signal-Sales-Engine/  customer project
      ...

Server (L-003):
  /opt/apps/{project}/     app code (kebab-case name)
  /opt/config/{project}/   config files
  /opt/logs/{project}/     logs
  /opt/backups/            backup dumps
  /root/smorch-dev/        plugin repo (sync target, NOT app code)
  /root/{tool}/            tooling clones ONLY, never apps

Claude Code:
  ~/.claude/
    CLAUDE.md              global instructions
    lessons.md             cross-project lessons (L-001 … L-009)
    settings.json          hooks, shell env, MCP servers
    plugins/               auto-populated by marketplace install
    skills/                auto-populated + canonical mirrors

Project scoped:
  {project}/.claude/       session-scoped artifacts (NOT for handovers/scores)
  {project}/.smorch/       plugin overlay (see overlay topic)
  {project}/docs/          handovers/qa-scores/qa/incidents/deploys/retros

L-003 enforcement:
  validate-plugins.sh checks for stray /root/*-{Repo,REPO,...}/ paths.
  Apps ONLY in /opt/apps/.

also see: overlay · architecture
```

---

## Topic: `verbs`

```
Verb boundaries (SOP-14) — words matter:

  ship      merge PR + tag release. Local → GitHub.
  deploy    SSH + pm2 reload / docker compose up. GitHub → server.
  rollback  revert deploy + restart. Server-side recovery.
  triage    live diagnostic. Problem still happening.
  incident  post-mortem write-up. After resolution.
  score     rubric scoring. Review IS scoring — one command.
  handover  dev → QA contract document. Not a verb for deployment.

Never conflate:
  "shipped" ≠ "deployed". Shipped means merged; deployed means live.
  "triage" ≠ "incident". Triage is active diagnostic; incident is write-up.
  "rollback" ≠ "revert". Rollback is a deploy-layer action;
    git revert is a merge-layer action. They compose, not overlap.

also see: ship · deploy · incident
```

---

## Topic: `sops`

```
SOP index (CodingProjects/SOPs/sops/):

  SOP-01  QA Protocol                    Lana's QA execution rules
  SOP-02  Pre-Upload Scoring             92+ ship gate, 8.5 hat floor
  SOP-03  Github Standards               branch naming, commit format
  SOP-05  Dev Roles Hierarchy            who decides what
  SOP-07  Agentic Coding Orchestration   multi-agent workflow
  SOP-09  Skill Injection Registry       plugin + skill registration
  SOP-10  Incident Response              SEV 1-4 classification
  SOP-11  Codex Doctrine                 code quality non-negotiables
  SOP-12  Project Onboarding Auto        new project scaffold
  SOP-13  Lana Handover Protocol         handover score gate (≥80)
  SOP-14  Plugin Workflow                17-command surface + verb boundaries
  SOP-15  Cross-Machine Sync             cron + GitHub webhook
  SOP-16  Secrets Rotation               90-day SLA
  SOP-17  Hire Onboarding Engineering    Day 1 → Month 1
  SOP-18  Streamlined Dev Loop (draft)   streamline flow (v1.2.0-dev)

DevOps Manual:
  CodingProjects/SOPs/SMOrchestra-DevOps-Operations-Manual.md

Query specific SOP: /smo-dev-guide sop-13

also see: lessons
```

---

## Topic: `lessons`

```
Lessons — cross-project + per-project.

Global (~/.claude/lessons.md, auto-loaded at SessionStart):
  L-001  Back up .env before server rebuild         (2026-04-21)
  L-002  Verify canonical state before "complete"    (2026-04-21)
  L-003  Apps in /opt/apps/, not /root/              (2026-04-21)
  L-004  docker-compose apps ≠ PM2 apps              (2026-04-21)
  L-005  Port conflict: system vs compose nginx      (2026-04-21)
  L-006  Port ghosts survive docker restart          (2026-04-21)
  L-007  "Already restored" needs evidence           (2026-04-21)
  L-008  Plugins auto-discover — no arrays in plugin.json  (2026-04-20)
  L-009  GitHub is single source of truth — commit AND push (2026-04-21)

Per-project (.claude/lessons.md in each repo).

Promotion (3+ projects trigger → global):
  /smo-retro auto-flags candidates for promotion.
  Mamoun approves the promotion PR.

Query specific lesson: /smo-dev-guide l-009

also see: sops
```

---

## Topic: `stuck` (decision tree)

```
Stuck? Find your row:

  "Opening a session and things feel wrong / new machine"
    → /smorch-dev-start (4-layer bootstrap: machine + context + project + inputs)
    → /smorch-dev-start --fix (auto-heal safe findings)
    → if exit 10: /smorch-dev-start --profile=eng-desktop (or qa-machine)

  "Input-readiness score too low (<70)"
    → read Layer 4 output, fix weakest 3 inputs
    → scaffold missing mandatory files: /smorch-dev-start --fix
    → rewrite shallow BRD: /smo-plan re-engages BRD

  "Score stuck at 88"
    → /smo-bridge-gaps — fix weakest hat first
    → Engineering Q2 low? brd-traceability coverage < 90%. Add tests.
    → UX Q3 low on MENA project? Run arabic-rtl-checker locally.

  "Lana rejected my handover (score 72)"
    → read her specific fix list
    → replace every {stub — ...} placeholder in Section 2
    → /smo-handover --validate → --notify

  "npm test fails in /smo-ship but passes locally"
    → node version drift. Check .nvmrc + CI workflow node version.
    → flaky test? Run 3x locally. 1/3 fail = flaky. Fix the test.

  "/smo-qa-run rollback drill fails"
    → doc-only PR? Flip qa.rollback_drill=optional (dedicated PR, CEO).
    → else fix the rollback path (rollback-runbook skill template).

  "Staging down (/smo-qa-run step 6)"
    → /smo-incident + Telegram. Don't work around it.

  "I broke main"
    → /smo-rollback {deploy-id} first. Then /smo-triage root cause.

  "I forgot to push yesterday's work"
    → push now (L-009). Flag drift risk until origin matches local.

  "Plugin commands not resolving"
    → L-008. Check .claude-plugin/marketplace.json + plugin.json
      has NO commands[]/skills[] arrays. Reinstall via marketplace.

  "Server rebuild wiped .env files"
    → L-001 breach. Restore from 1Password or secure backup.
      Next time: /smo-secrets --backup BEFORE rebuild.

  "Apps landed in /root/ not /opt/apps/"
    → L-003 breach. Move via rsync + update deploy.path in .smorch.

also see: score · handover · qa · deploy · incident
```

---

## Topic: `sop-NN` and `l-NNN` specific lookup

If input matches `/^sop-\d+$/i` → print SOP summary + full path to `CodingProjects/SOPs/sops/SOP-NN-*.md`.
If input matches `/^l-\d+$/i` → print rule + **Why** + **How to apply** from `~/.claude/lessons.md`.

If SOP/lesson doesn't exist: `no SOP-NN found — see topic "sops" for the current list`.

---

## Anti-patterns

- **Do not concatenate topics.** One topic per invocation. If two link, `also see: {topic}` (max 2 cross-links).
- **Do not invent commands.** If user asks about `/smo-xyz` that doesn't exist, say so + list the 17 real commands.
- **Do not rewrite SOPs.** Summarize + point to the file. SOPs are canonical.
- **Do not recommend on stale evidence.** `next` MUST read current files, not memory.
- **Do not claim server state without verification.** If recommending a server action, say "verify via /smo-health first" rather than asserting current state.
