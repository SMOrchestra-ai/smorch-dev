# SMOrchestra Dev Guides — Single Source of Truth

**Canonical location:** `SMOrchestra-ai/smorch-dev/docs/guides/` (this folder).

All previous copies (working docs in `~/Desktop/repo-workspace/_workspace/`, scratch notes on personal machines, Cowork drafts) are **superseded**. This folder is what every engineer, QA, and future hire reads.

## Contents

| File | Purpose | Audience |
|---|---|---|
| `00-MACRO-SUMMARY.md` | Apr 22-23 infrastructure-rebuild summary + current mechanical watchers + session-bootstrap policy | Everyone |
| `01-START-NEW-APP.md` | Zero-to-shippable flow for a new app (Boris discipline + command chain + `/smorch-dev-start` gate) | Engineers |
| `02-PATCH-V2-QA.md` | Bug fix / v2 upgrade / QA operations (hotfix + regular fix + v2 decision tree + Lana's QA) | Engineers + Lana |
| `03-CUSTOMIZE-DEV-PLUGIN.md` | When a project uses `eo-microsaas-dev` or a custom plugin instead of `smorch-dev` (SOP-33) | Engineers working on EO students or client engagements |
| `04-SETUP-ENVIRONMENT.md` | Fresh machine install (eng desktop Mac/Linux, QA Mac/Win, new VPS) + `/smorch-dev-start` verify | Every new hire (Day 1) |

## Rule (L-026 candidate)

**No dev-related guide lives outside this folder.**

- Edit a guide? PR into `smorch-dev/docs/guides/` on `dev` branch → merge to `main` via release PR.
- Reference a guide elsewhere? Link to the GitHub URL, don't copy the content.
- New guide? Add here with `NN-TITLE.md` numbering + update this README.

Guides in `_workspace/`, `Downloads/`, Cowork drafts, etc. are scratch — not authoritative. If you find one, either promote it here via PR or delete it.

## Enforcement

- `/smorch-dev-start` Layer 1 checks that `~/Desktop/repo-workspace/smo/smorch-dev/docs/guides/` exists and is current (synced via cron `sync-from-github.sh`).
- `/smo-drift --desktop` flags any local machine whose guides hash diverges from `origin/main` by more than 24h.

## Related canonical stores

| Store | Path | What it owns |
|---|---|---|
| Plugin code | `SMOrchestra-ai/smorch-dev/plugins/` | `smorch-dev` + `smorch-ops` commands + skills |
| SOPs | `SMOrchestra-ai/smorch-brain/sops/` | SOP-NN numbered standard operating procedures |
| Canonical registries | `SMOrchestra-ai/smorch-brain/canonical/` | repo-registry, server-role-registry, supabase-registry, n8n-topology, plugin-registry |
| Global lessons | `~/.claude/lessons.md` (synced from `smorch-brain/canonical/lessons-global-*`) | Cross-project L-NNN lessons |
| Per-project lessons | `{repo}/.claude/lessons.md` | Repo-scoped lessons (promote to global via `/smo-retro`) |

## Updating a guide

```bash
cd ~/Desktop/repo-workspace/smo/smorch-dev
git checkout dev && git pull --ff-only
git checkout -b fix/guide-NN-{slug}
# edit docs/guides/NN-*.md
git add docs/guides/NN-*.md
git commit -m "docs(guides): fix/add {what} in NN-TITLE"
git push -u origin fix/guide-NN-{slug}
gh pr create --base dev --title "docs(guides): ..."
```

After merge to `dev` → release PR to `main` → sync-from-github cron (≤30 min) pulls to every machine.
