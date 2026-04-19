# Changelog

## [1.0.0] - 2026-04-19

### Added
- New monorepo hosting two Claude Code plugins: `smorch-dev` (workflow) + `smorch-ops` (infra)
- 10 workflow commands + 8 workflow skills (smo-scorer, lessons-manager, elegance-pause, arabic-rtl-checker, mena-mobile-check, brd-traceability, handover-generator, qa-handover-scorer, cost-tracker)
- 7 ops commands + 7 ops skills (security-hardener, incident-runbook, deploy-pipeline, rollback-runbook, drift-detector, secrets-manager, codex-doctrine)
- 4 machine install profiles: qa-machine.ps1 (Lana, Windows), eng-desktop.sh (dev desktops), dev-server.sh, prod-server.sh
- `scripts/validate-plugins.sh` — schema-checks both plugin.json files, runs in CI
- `scripts/sync-from-github.sh` — cron-invoked pull + install + hash-check
- `scripts/grep-audit-rename.sh` — one-shot rename audit tool
- `.github/workflows/validate.yml` runs validate-plugins.sh on every PR
- QA handover scoring rubric (5 dimensions, ≥80 to accept) per Mamoun's explicit ask
- Project overlay convention at `{project}/.smorch/` (plugin-agnostic)

### Deprecated
- Old `smorch-brain/plugins/smorch-dev/` (misnamed — actually MCP/n8n builder) renamed to `smorch-builders` v2.0.0
- `smorch-dist/plugins/smorch-dev-scoring/` v1.0.0 archived (functionality absorbed into smo-scorer)

### Replaces
- `smorch-dev-scoring` (scoring) → `plugins/smorch-dev/skills/smo-scorer/`
- `eo-microsaas-dev` eo-scorer (student-facing) stays as-is; smo-scorer is the internal hardened fork

### Security
- Post-perfctl malware incident: `security-hardener` skill encodes UFW, fail2ban, SSH key-only posture
- `secrets-manager` skill drives 90-day rotation across 4 servers per SOP-16
- Pre-commit drift hook prevents commits landing on drifted machines
