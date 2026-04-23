# smorch-dev — Documentation Index

**All guides, SOPs, and artifacts created during the internal dev plugin rollout.**
Last updated: 2026-04-23 — `docs/guides/` promoted to canonical SSOT for all dev guides.

## Canonical guides (start here)

All dev-related how-to guides live at **`docs/guides/`**. No dev guide lives outside this repo.

| File | Purpose |
|---|---|
| [`docs/guides/00-MACRO-SUMMARY.md`](guides/00-MACRO-SUMMARY.md) | Infrastructure state + session-bootstrap policy |
| [`docs/guides/01-START-NEW-APP.md`](guides/01-START-NEW-APP.md) | Zero-to-shippable for a new app |
| [`docs/guides/02-PATCH-V2-QA.md`](guides/02-PATCH-V2-QA.md) | Bug fix · v2 upgrade · QA operations |
| [`docs/guides/03-CUSTOMIZE-DEV-PLUGIN.md`](guides/03-CUSTOMIZE-DEV-PLUGIN.md) | When to use a non-`smorch-dev` plugin |
| [`docs/guides/04-SETUP-ENVIRONMENT.md`](guides/04-SETUP-ENVIRONMENT.md) | Fresh machine install (eng / QA / server) |
| [`docs/guides/README.md`](guides/README.md) | Guides SSOT policy + update flow |

---

## 🎯 Start here — depending on who you are

| Who | First read | Second read |
|-----|-----------|-------------|
| **Mamoun** (founder) | YOUTUBE-10-STEPS.md | GUIDE-EXISTING-REPO.md |
| **Lana** (half QA, half Dev) | GUIDE-QA-LANA.md | GUIDE-EXISTING-REPO.md |
| **New engineering hire** | SOP-17 → GUIDE-NEW-PROJECT.md | GUIDE-EXISTING-REPO.md |
| **EO student** | eo-microsaas-dev README (separate repo) | EO-Brain phases 0-5 |
| **Cowork team** | COWORK-REVAMP docs (in EO-Students/) | — |

---

## 📘 User-facing guides

| Name | Location | Description |
|------|----------|-------------|
| **Starting a new project** | `smorch-dev/docs/GUIDE-NEW-PROJECT.md` | 8-step scaffold (~15 min): repo creation, `.smorch/` overlay, BRD, first feature |
| **Working on an existing repo** | `smorch-dev/docs/GUIDE-EXISTING-REPO.md` | Daily workflow + role flows (Mamoun / Lana / new hire), emergency hotfix path |
| **QA workflow (Lana)** | `smorch-dev/docs/GUIDE-QA-LANA.md` | Direct format: 5-dim handover scorecard, Linear integration, timeboxing, escalation ladder |
| **YouTube — 10 Steps** | `smorch-dev/docs/YOUTUBE-10-STEPS-ULTIMATE-CLAUDE-CODE.md` | Step-by-step script outline for a "set up Claude Code from scratch" video |
| **YouTube — 2-File Framework** | `smorch-dev/docs/YOUTUBE-BORIS-2-FILE-FRAMEWORK-BRD-CLAUDEMD.md` | Companion video — zooms into the 2 files that matter most: CLAUDE.md (Boris discipline) + BRD (AC-N.N tagging contract) |
| **GitHub Actions setup** | `smorch-dev/docs/GITHUB-ACTIONS-SETUP.md` | One-time: add 3 secrets, wire sync-to-machines workflow |
| **Coding toolkit overview** | `smorch-dev/docs/PLUGIN-SKILLS-COMMANDS-GUIDE.md` | Single reference: what each plugin owns, what each skill does, when to call each command |

---

## 🧭 SOPs created / updated

| SOP | File | Status | Purpose |
|-----|------|:------:|---------|
| SOP-14 | `SOPs/sops/SOP-14-Plugin-Workflow.md` | NEW | Command surface (18 commands incl. /smo-dev-guide) + verb boundaries |
| SOP-15 | `SOPs/sops/SOP-15-Cross-Machine-Sync.md` | NEW | Cron + GitHub webhook sync model |
| SOP-16 | `SOPs/sops/SOP-16-Secrets-Rotation.md` | NEW | 90-day SLA across 4 servers |
| SOP-17 | `SOPs/sops/SOP-17-Hire-Onboarding-Engineering.md` | NEW | Day 1 → Month 1 hire ramp |
| SOP-01 | `SOPs/sops/SOP-01-QA-Protocol.md` | UPDATED | Pre-QA handover score gate added |
| SOP-02 | `SOPs/sops/SOP-02-Pre-Upload-Scoring.md` | UPDATED | Internal gate 92+ (vs 90 students), 8.5 hat floor |
| SOP-09 | `SOPs/sops/SOP-09-Skill-Injection-Registry.md` | UPDATED | smorch-dev + smorch-ops plugins registered |
| SOP-13 | `SOPs/sops/SOP-13-Lana-Handover-Protocol.md` | UPDATED | Scoring gate added for handover acceptance |
| DevOps Manual §11 | `SOPs/SMOrchestra-DevOps-Operations-Manual.md` | UPDATED | Plugin architecture section rewritten |

---

## 🧩 Plugin artifacts (source in github repo)

| Artifact | Location | Contents |
|----------|----------|----------|
| smorch-dev plugin | `smorch-dev/plugins/smorch-dev/` | 11 commands + 10 skills + templates |
| smorch-ops plugin | `smorch-dev/plugins/smorch-ops/` | 7 commands + 7 skills + templates |
| Install scripts | `smorch-dev/install/` | qa-machine.ps1, eng-desktop.sh, dev-server.sh, prod-server.sh |
| Validator | `smorch-dev/scripts/validate-plugins.sh` | Schema + frontmatter + dead-ref check (runs in CI) |
| Sync script | `smorch-dev/scripts/sync-from-github.sh` | Cron-invoked pull + install + validate |

---

## 📝 Planning + analysis artifacts (historical)

| Name | Location | Description |
|------|----------|-------------|
| Plugin architecture plan | `~/.claude/plans/expressive-sparking-cascade.md` | Approved plan for the rollout (7 phases) |
| Framework analysis | `smorch-dev/plugins/smorch-dev/architecture/brd.md` | BRD/analysis that produced the 7-pillar workflow |
| Pilot week ranking plan | `EO-Students/docs/PILOT-WEEK-RANKING-PLAN.md` | How we rank hat scores post-rollout (evidence required per hat) |

---

## 🧑‍🎓 EO Students (separate track)

| Name | Location | Description |
|------|----------|-------------|
| eo-microsaas-dev plugin | `EO-Students/eo-microsaas-dev/` | Student-facing workflow plugin (v1.0.0, public fork of smorch-dev) |
| Install script | `EO-Students/install.sh` | Student-facing install (gstack + superpowers + eo-microsaas-dev) |
| Student CLAUDE.md template | `EO-Students/CLAUDE.md` | Template for students' global config |
| BorisFramework reference | `EO-Students/BorisFramework/` | Source material (Boris Cherny's 6 pillars) |
| Cowork — OS revamp | `EO-Students/docs/COWORK-REVAMP-EO-MICROSAAS-OS.md` | For cowork to update `4-eo-tech-architect` + `4-eo-code-handover` |
| Cowork — slides revamp | `EO-Students/docs/COWORK-REVAMP-CLAUDE-CODE-SLIDES.md` | For cowork to update EO-05-ClaudeCode slide deck |

---

## 🏠 Configs modified

| File | Scope | Change |
|------|-------|--------|
| `~/.claude/CLAUDE.md` | global | 251 → 116 lines (Boris discipline) |
| `CodingProjects/EO-MENA/CLAUDE.md` | project | Plugin overlay header block added |
| `CodingProjects/EO-MENA/.smorch/project.json` | project | NEW — overlay config |
| `CodingProjects/Signal-Sales-Engine/CLAUDE.md` | project | Plugin overlay header block added |
| `CodingProjects/Signal-Sales-Engine/.smorch/project.json` | project | NEW — overlay config |

---

## 📦 Inventory as CSV

See `smorch-dev/docs/inventory.csv` for the same data in spreadsheet form — open in Excel/Numbers for filtering, sorting, sharing with the team.

---

## 🔗 Live references

- GitHub: `github.com/SMOrchestra-ai/smorch-dev`
- Plugins installed: `~/.claude/plugins/smorch-dev/` + `~/.claude/plugins/smorch-ops/`
- Servers (all have smorch-ops installed): eo-prod, smo-dev, smo-prod, smo-eo-qa
- CI: GitHub Actions `validate.yml` + `sync-to-machines.yml`

---

## Search cheat sheet

```bash
# Find a guide quickly
find ~/Desktop/cowork-workspace/CodingProjects -maxdepth 4 -name "GUIDE-*.md"

# Find a SOP
ls ~/Desktop/cowork-workspace/CodingProjects/SOPs/sops/

# Find your lessons
cat .claude/lessons.md  # per-project
cat ~/Desktop/cowork-workspace/CodingProjects/smorch-brain/canonical/lessons.md 2>/dev/null  # cross-project (if exists)
```
