# Macro Summary — April 22-23 Clean-Slate Infrastructure Rebuild

**Period:** 2026-04-22 → 2026-04-23
**Trigger:** April 18 perfctl malware incident + chaotic recovery
**Outcome:** 8 phases shipped, every drift path mechanical.

---

## What was broken before

- Apps fragmented across wrong servers (n8n on prod boxes, app code on dev boxes)
- No canonical DB/server/env mapping — teams built against different Supabase projects in parallel
- 16 `.env` files with duplicated/leaked secrets
- No dev→prod SOP — direct server edits, silent drift
- No cron backups → 3 weeks of work lost to malware rebuild
- L-009 violations everywhere — code on one laptop, one wipe = gone
- No perfctl re-infection tripwire

## What was done (phase-by-phase)

### Phase 0 — Hardening (all 4 servers)
UFW + fail2ban + SSH key-only + unattended-upgrades + swap baseline applied to smo-prod, smo-dev, eo-prod, smo-eo-qa. Evidence in `smorch-brain/docs/infra/hardening-2026-04-22.md`.

### Phase 1 — GitHub Single Source of Truth
- 27 repos audited across 2 orgs (SMOrchestra-ai, smorchestraai-code)
- Canonical 3-dimension tag taxonomy applied: domain × lifecycle × distribution
- Branch model locked: `main` = production (protected, 1-review PR), `dev` = active, `feat/*` / `fix/*` / `hotfix/*`
- 17 active repos protected on main + dev (force-push + deletion blocked)
- 2 missing `main` branches created, 7 missing `dev` branches created, 8 defaults flipped dev→main
- 6 SOPs shipped: SOP-20 Branch Model, SOP-21 Tag Taxonomy, SOP-22 Commit/Push Discipline, SOP-23 Weighted Scoring (top-3 = 80%), SOP-24 App Build Order (skills LAST), SOP-25 Skills Injection Gate
- Idempotent apply script: `smorch-dev/scripts/github-audit/phase-1-apply.sh`
- Gitleaks scan across all 17 active repos — 2 repos with findings flagged (Signal-Sales-Engine 61, contabo-mcp-server 4)

### Phase 2 — Global setup + EX-6 impact assessment
- Recovered SOPs 01-13 from smorch-brain/dev → main (were reference-drift targets)
- Cleaned brain repo root (5 `.plugin` binaries moved to dist/, duplicate sync-plugins.txt removed)
- Fixed global CLAUDE.md (L-009 duplication, `project-registry.md` filename drift)
- Cloned smorch-dist + smorch-context locally
- 3 dead repos deleted: eo-dashboard, ssh-mcp-server (merged into contabo-mcp-server monorepo), SSE-latest (empty stub)
- 1 kept-archived: Signal-Sales-Engine-v1 (unique React/Vite-era architecture docs)
- L-009 flush of 6 dirty local repos pushed to GitHub
- EO-MENA 115 untracked files committed + pushed (safety branch `backup/pre-phase2-fix-2026-04-22` created first)
- SOP-10/11/12/13 collisions resolved (second files renamed to SOP-26/27/28/29)

### Phase 3 — Canonical mapping (Repo → Server → DB → n8n)
- Perfctl sentinel shipped to all 4 servers — */30 cron detecting ld.so.preload, libgcwrap.so, perfclean cron, /tmp artifacts, xmrig/kdevtmpfsi processes
- 6 `.smorch/project.json` overlays written: content-automation, digital-revenue-score, gtm-fitness-scorecard, SaaSFast, EO-Scorecard-Platform + fixed SSE overlay (was pointing prod at smo-dev)
- 3 canonical registries in smorch-brain/canonical/: `server-role-registry.md`, `supabase-registry.md` (4 active projects + SSE-Temp slated removal), `n8n-topology.md`
- Supabase MCP wired for 3 projects (SSE, CRE, SAASNew) — creds in `~/.claude/secrets/supabase-creds.env` (600 perms, not committed)
- SSE-Temp paused (data + schema archived to `~/Desktop/smo-recovery-2026-04-21/supabase-sse-temp/`)

### Phase 4 — DEV↔APP layer separation
- ADR-004 formalizing: DEV-layer = engineer tools (CLAUDE.md, .smorch, smorch-dev plugins); APP-layer = runtime skills injected into deployed app's Claude API calls
- Skills injection rule (EX-2): LAST step of app build — only after frontend + automation + DB + end-to-end test all green
- Quality gate (EX-3): every runtime skill must pass external-agency-team eval with composite ≥92
- 4 canonical templates shipped: per-app-CLAUDE-template.md, per-app-settings-hook.json, runtime-skills-manifest-schema.json, ADR-004

### Phase 5 — Drift + cron (3 layers LIVE)
- `infra-drift.sh` hourly × 4 servers (disk, services, UFW, perfctl, swap, SSH, n8n container)
- `app-drift.sh` hourly × smo-prod + eo-prod (git HEAD vs origin, uncommitted, env files)
- `github-drift.sh` daily 09:00 × Mamoun's Mac via launchd (branch protection, default branch, topics, Dependabot)
- All heartbeat to `flow.smorchestra.ai/webhook/*-drift`
- SOP-30 Drift Enforcement shipped
- First sweep across all layers: 0 drift findings

### Phase 6 — Per-app deep dive + EX-7 multi-machine sync
- `sync-from-github.sh` deployed to all 4 servers (cron */30) + Mamoun's Mac (launchd 1800s) — pulls smorch-brain + smorch-dev without overwriting local changes
- Per-app TEMPLATE + MASTER-REGISTRY (17 repos × 3 tiers)
- Tier-1 SSE deep-dive (9 gaps ranked, 30-day roadmap)
- Remaining 16 per-app deep dives run iteratively per-repo-as-ready (EX-2: can't write skill manifest until app fundamentals green)

### Phase 7 — Desktop Workspace Clean-Slate
- 5.2 GB safety tar at `~/Desktop/_phase7-safety/`
- New canonical tree at `~/Desktop/repo-workspace/` with 21 repos cloned into tiered dirs (smo/eo/shared/external-forks)
- Every active repo checked out to `dev` (L-014: main = production, don't work on locally)
- Old `cowork-workspace` preserved at `_archive/cowork-workspace-pre-phase7-2026-04-23/` (non-destructive mv, reversible)
- Triple safety net: tar + archive + GitHub

---

## What is now mechanical (no human diligence required)

| Watcher | Cadence | Scope |
|---|---|---|
| perfctl sentinel | */30 min | all 4 servers — malware IOCs |
| infra drift | hourly | all 4 servers — services/UFW/swap/n8n |
| app drift | hourly | smo-prod + eo-prod — /opt/apps/* vs GitHub |
| github drift | daily 09:00 | org-wide — branch protection, topics, Dependabot |
| sync-from-github | */30 min | all 4 servers + Mac — smorch-brain + smorch-dev |
| `/smorch-dev-start` | every session | every SMOrchestra machine — 4-layer bootstrap (machine + context + project + input-quality scoring) |

All 5 watchers POST heartbeats to `flow.smorchestra.ai/webhook/*`. `/smorch-dev-start` is engineer/QA-invoked at session start (never automatic) and gates every downstream `/smo-*` and `/eo-*` command.

## Session bootstrap — always first (every machine, every session)

```bash
/smorch-dev-start
```

Runs four layers with GREEN/YELLOW/RED gate + `--fix` auto-heal. Works on Mac (Mamoun, engineers), Windows (Lana, QA), Linux, servers — auto-detects role from `~/.sync-profile`. Scores existing project inputs on 4 dimensions (Completeness/Depth/Traceability/Freshness), reports missing-input inventory per project type, emits an overall input-readiness score. Replaces the old 9-row manual verification checklist. Full explainer: `/smo-dev-guide start`. Guide 04 has the install-then-verify flow.

## What remains on you

1. Rotate Supabase PAT + 3 service_role keys + 3 anon keys (chat history = exposure)
2. Signal-Sales-Engine secret rotation + history rewrite (61 gitleaks findings; force-push needs CEO approval)
3. SSE-Temp permanent delete via Supabase dashboard after 7-day verification window (~2026-04-30)
4. 16 remaining per-app Phase-6 deep dives (iterative, as each repo hits build-step-4 green)
5. Write SOP-14/15/16/17 OR remap global CLAUDE.md references (current files renumbered SOP-26-29)

## Core principles enforced

1. Boris discipline — BRD + CLAUDE.md = 2 source-of-truth files per project
2. GitHub SSoT — commit + push end of every work unit (L-009)
3. Rebuild any server in ≤30 min from GitHub + 1Password + Supabase + Contabo
4. One asset, one canonical home — no duplication
5. Hardening before services (L-007)
6. Every change scored (/smo-score ≥92 composite, ≥8.5 per critical hat)
7. Every dev→prod goes through Lana (/smo-qa-handover-score ≥80)
8. Every server state change = evidence committed to git
9. Lessons.md self-learning — every failure becomes L-NNN rule
10. Production is sacred — no dev on `main` branch

## Evidence trail (in smorch-brain/docs/infra/)

- hardening-2026-04-22.md
- phase-1-github-ssot-audit-2026-04-22.md
- phase-2-impact-assessment-2026-04-22.md
- phase-3-canonical-mapping-2026-04-22.md
- phase-4-dev-app-layers-2026-04-23.md
- phase-5-drift-cron-deploy-2026-04-23.md
- phase-6-per-app-2026-04-23.md
- phase-7-desktop-clean-slate-2026-04-23.md
