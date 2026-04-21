# smorch-dev

**Two Claude Code plugins + 4 machine install profiles + cron sync. Single source of truth: this repo.**

Internal SMOrchestra dev + ops toolkit. Built after we shipped `eo-microsaas-dev` for students and applied what we learned.

## What's in here

| Path | Purpose |
|------|---------|
| `plugins/smorch-dev/` | **Workflow plugin** — 11 commands (plan, code, score, bridge-gaps, handover, qa-handover-score, qa-run, ship, triage, retro, dev-guide) + 10 skills. Installed on dev + QA machines. |
| `plugins/smorch-ops/` | **Infra plugin** — 7 commands (deploy, rollback, drift, health, incident, secrets, skill-sync) + 7 skills. Installed on all machines incl. servers. |
| `install/` | One script per machine profile — `qa-machine.ps1` (Lana, Windows), `eng-desktop.sh` (dev desktops), `dev-server.sh`, `prod-server.sh` |
| `scripts/` | `validate-plugins.sh` (CI), `sync-from-github.sh` (cron-invoked) |
| `docs/` | ADRs + machine install matrix + retirement plan |

## Install matrix

| Profile | smorch-dev | smorch-ops | gstack | superpowers | Cron sync |
|---------|:---:|:---:|:---:|:---:|:---:|
| qa-machine (Lana, Windows) | ✅ | ✅ | ✅ | ✅ | ✅ |
| eng-desktop (Mamoun's Mac + future hires) | ✅ | ✅ | ✅ | ✅ | ✅ |
| dev-server (smo-dev, smo-eo-qa) | ❌ | ✅ | ❌ | ❌ | ✅ |
| prod-server (eo-prod, smo-prod) | ❌ | ✅ | ❌ | ❌ | ✅ |

## Quick install

```bash
# Mac / Linux
bash <(curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/eng-desktop.sh)

# Windows (PowerShell as admin)
iwr -useb https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/qa-machine.ps1 | iex

# Server (run on the server)
bash <(curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/prod-server.sh)
```

## Command surface — 18 total, no overlap

### Workflow (smorch-dev)
`/smo-plan` · `/smo-code` · `/smo-score` (--quick / --full) · `/smo-bridge-gaps` · `/smo-handover` · `/smo-qa-handover-score` · `/smo-qa-run` · `/smo-ship` (merge + tag) · `/smo-triage` (live debug) · `/smo-retro` · `/smo-dev-guide` (in-session cheat-sheet)

### Ops (smorch-ops)
`/smo-deploy` · `/smo-rollback` · `/smo-drift` · `/smo-health` · `/smo-incident` (post-mortem) · `/smo-secrets` · `/smo-skill-sync`

## Verb boundaries (documented in SOP-14)

- `ship` = merge + tag · `deploy` = SSH + pm2 reload · `rollback` = revert + restart
- `triage` = live diagnostic · `incident` = SEV1-4 post-mortem write-up
- `score` = rubric scoring (review IS scoring — one command)

## Project overlay convention

Projects declare their own overlay at `{project}/.smorch/`. Plugin is project-agnostic. See `docs/ADR-002-project-overlay-convention.md`.

```
eo-mena/
  .smorch/
    project.json       # {"project":"eo-mena","mena":true,"stack":"nextjs-supabase"}
    skills/            # project-specific skills (optional)
    templates/         # project-specific templates (optional)
    overrides/         # rubric overrides for smo-scorer (optional)
```

## Sync model

1. Mamoun pushes to `main`
2. GitHub webhook → n8n on `flow.smorchestra.ai`
3. n8n triggers `smorch-sync-all --repo smorch-dev`
4. Each machine runs `scripts/sync-from-github.sh` (also fires hourly via cron as fallback)
5. Hash check vs `canonical/smorch-dev-manifest.json` in smorch-brain
6. Drift → Telegram alert (CHAT_ID 311453473) + auto-rollback

## Non-negotiables

- No ship without 92+ composite score (see SOP-02 gap-bridge)
- No handover accepted by QA without ≥80 handover score (see SOP-13)
- No command-name collisions (verbs documented in SOP-14)
- No edits directly on servers — local → GitHub → server pull
- Pre-commit drift hook blocks commits that would land on drifted machines

## SOP references

| SOP | What |
|-----|------|
| SOP-01 | QA Protocol — `/smo-qa-handover-score` + `/smo-qa-run` |
| SOP-02 | Pre-upload scoring (92+ gate) — smo-scorer |
| SOP-09 | Skill injection registry — both new plugins registered |
| SOP-13 | Lana handover protocol — `/smo-handover` + score |
| SOP-14 | Plugin workflow (NEW) |
| SOP-15 | Cross-machine sync (NEW) |
| SOP-16 | Secrets rotation (NEW) |
| SOP-17 | Hire onboarding engineering (NEW) |

## Version

v1.0.0 (repo + plugins). Target: take SMOrchestra from ad-hoc workflows to a 10/10 dev + ops discipline. No sloppiness.
