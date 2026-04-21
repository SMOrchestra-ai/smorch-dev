# Changelog

## [1.2.0-dev] - 2026-04-21

### Added
- `/smo-ship` parallel gate preamble — 5 read-only gates (score, hat-floor, QA, handover, git-clean) fire concurrently, build+test+audit stays serial, merge ceremony stays serial. Failure surface still names the specific gate that blocked.
- `brd-traceability --emit-scenarios` — emits 4 scenario stubs (happy/empty/error/edge) per AC in BRD. `handover-generator` embeds stubs in Section 2 of the handover brief. Dev replaces `{stub — ...}` placeholders with real steps; `/smo-handover --validate` blocks commit if any placeholder remains.
- `.smorch/project.json` schema extended: `locale` (ar-MENA | en-US | mixed, default ar-MENA) drives MENA check gating in `/smo-qa-run`; `qa.rollback_drill` (required | optional, default required) gates the dry-run drill. Canonical template at `plugins/smorch-dev/templates/smorch-project.json.template`.
- `scripts/sync-from-github.sh` observability heartbeat — fire-and-forget POST to n8n webhook at each exit point (up_to_date | synced | pull_failed | validate_failed). 5-sec timeout, non-blocking; dashboard shows last-sync-per-host, alerts on >45 min silence.
- `docs/SOP-18-Streamlined-Dev-Loop.md` (draft) — documents the streamlined flow; promote to SOPs/ after post-streamline metrics confirm ≥50% wall-clock cut.
- `docs/metrics/2026-04-21-pre-streamline.md` — baseline step counts + estimated wall-clock for post-streamline comparison.

### Changed
- `/smo-plan` now reads both `locale` and `qa.rollback_drill` from `.smorch/project.json` (replaces binary "MENA: yes/no" prompt).
- `/smo-qa-run` step 4 (MENA checks) gated on `locale`; step 7 (rollback drill) gated on `qa.rollback_drill`. SKIPPED entries in QA report name the flipping PR per CEO audit trail.
- `/smo-handover` auto-embeds scenario stubs + validation refuses remaining placeholder text.

### Removed
- `scripts/grep-audit-rename.sh` — one-shot rename audit from the smorch-builders ↔ smorch-dev rename. Historical entries in README + inventory.csv + INDEX.md also cleaned.

### Policy
- Flipping `locale` to `en-US` or `qa.rollback_drill` to `optional` on an existing project requires a dedicated PR that modifies only `.smorch/project.json` — no bundling with feature work. CEO reviews the policy flip in isolation. The resulting QA report records the flipping PR number for audit.

### Non-negotiables preserved
- 92+ composite + 8.5 hat floor before `/smo-ship`
- ≥80 handover score before Lana accepts QA
- L-009 push discipline (commit + push + PR + merge + tag each work unit)
- Secret-scanner + destructive-blocker hooks always on

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
