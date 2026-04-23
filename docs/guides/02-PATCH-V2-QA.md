# Guide 02 — Patch / v2 / QA operations

## 0. Session bootstrap (every patch/QA session)

```bash
/smorch-dev-start
```

MUST be GREEN before any patch or QA work. Hotfix path below still requires this gate — skip means you risk committing stale CLAUDE.md, missing plugins, or to the wrong branch. Exit 2 (RED) halts; run `/smorch-dev-start --fix`.

For Lana specifically: dev-start auto-detects `qa-machine` role and runs the QA-subset of Layer 1 checks (Playwright, axe, MENA tools installed).

---

## PATCHING A PRODUCTION APP (bug fix)

### 1. Classify the bug
- **SEV1** (prod broken, customer impact) → hotfix path (bypass dev branch)
- **SEV2-4** → regular feat/fix path through dev

### 2. SEV1 hotfix (ONLY for prod-breaking)

```bash
cd ~/Desktop/repo-workspace/{tier}/{repo}
git checkout main && git pull
git checkout -b hotfix/PROD-SEV1-{short-slug}
# fix + test
git add {specific files}
git commit -m "hotfix(scope): description"
git push -u origin hotfix/PROD-SEV1-{short-slug}
gh pr create --base main --title "hotfix: ..." --body "SEV1 incident #N"
# CEO approves immediately
gh pr merge {n} --squash
# deploy
/smo-deploy --env production
# backport to dev
gh pr create --base dev --head hotfix/PROD-SEV1-{short-slug} --title "backport: hotfix"
gh pr merge {n} --squash
# incident writeup
/smo-incident SEV1 {short-slug}
```

Enforcement: branch name `hotfix/PROD-SEV{1-4}-*` is the ONLY pattern that can PR into `main` without going through `dev`. Branch protection blocks any other direct-to-main PR.

### 3. Regular bug fix (SEV2-4)

```bash
git checkout dev && git pull --ff-only
git checkout -b fix/SMO-{linear-id}-{slug}
# test-first (TDD): write regression test that fails → fix → test passes
/smo-code
/smo-score    # must hit ≥92
/smo-handover
# Lana
/smo-qa-handover-score    # ≥80
/smo-qa-run
# ship
/smo-ship
/smo-deploy --env staging
# Lana re-runs on staging URL
/smo-qa-run --env staging
# prod
/smo-deploy --env production
```

### 4. Rollback if deploy breaks prod

```bash
/smo-rollback --env production
# SLA: 90s to return /api/health 200
# automatically opens incident ticket
/smo-incident SEV{n}
```

---

## DEVELOPING v2 OF AN EXISTING APP

### Decision tree: in-place upgrade vs new repo

| Scenario | Path |
|---|---|
| Breaking API change, same product | new major version IN PLACE (`v2.0.0` tag, CHANGELOG.md entry, breaking note in README) |
| Ground-up rewrite, same brand | new major version IN PLACE, archive old code in `_archive/` subfolder, flag via ADR |
| Different product / different target customer | NEW REPO (tag old as `status-archived`, add ADR pointing to new repo) |

### In-place v2 flow

```bash
cd ~/Desktop/repo-workspace/{tier}/{repo}
git checkout dev && git pull --ff-only
git checkout -b feat/v2-{descriptor}
```

1. Write `architecture/adrs/ADR-NNN-v2-{descriptor}.md` explaining the break
2. Update `architecture/brd.md` with new ACs (keep old AC numbers for historical trace)
3. Update CLAUDE.md line "Stack:" + bump major version in package.json
4. Migration script: `scripts/migrate-v1-to-v2.{sh,sql}` — must be idempotent + reversible
5. Test harness covers v1 → v2 data migration separately from new feature tests
6. Full /smo-plan → /smo-deploy chain (same gates). Ship gate ≥92 still.
7. Tag `vX.0.0` with CHANGELOG note prominently flagging BREAKING.

### New-repo v2 flow

Follow Guide 01 — Start a New App. In the old repo:
1. Flip lifecycle tag: `gh repo edit {repo} --add-topic status-archived --remove-topic status-production`
2. Update README.md top: "⚠️ DEPRECATED — see {new-repo}"
3. ADR in old repo pointing to new repo
4. `gh repo archive {repo}` (after 30-day buffer for any in-flight work)

---

## QA PROCESS (Lana's workflow)

### Before accepting handover

`/smo-qa-handover-score` runs 5-dimension rubric on the handover brief:
1. Completeness (all fields filled)
2. Testability (scenarios reproducible)
3. Repro-ability (steps unambiguous)
4. Risk disclosure (known edge cases flagged)
5. Rollback readiness (path + SLA stated)

**≥80 accept** → proceed to QA run
**60-79 send back** → comment on handover, block /smo-ship
**<60 auto-reject + escalate to CEO**

### QA run (on smo-eo-qa server)

```bash
# SSH to smo-eo-qa (100.99.145.22) OR run locally
/smo-qa-run --url https://staging-{project}.smorchestra.ai
```

Runs automatically:
1. **4 scenarios per AC**: happy / empty / error / edge
2. **Playwright** across Chromium + Firefox + WebKit
3. **axe-core**: 0 violations (cap UX hat at 6 if >0)
4. **Lighthouse**: performance ≥85, a11y ≥95
5. **MENA checks** (if `mena: true` in overlay):
   - `arabic-rtl-checker`: dir=rtl, Cairo/Tajawal fonts, icon mirror, BiDi isolation
   - `mena-mobile-check`: 375px viewport, AED/SAR/QAR/KWD currencies, Fri/Sat weekend logic, DD/MM/YYYY dates
6. **/api/health** returns 200 with expected JSON

### QA decision states

| Result | Action |
|---|---|
| ALL PASS | `/smo-qa-run --confirm-pass` — unblocks /smo-deploy --env production |
| FAIL (any scenario) | QA report with failure details → back to dev, blocks /smo-ship |
| ESCALATE (ambiguous AC) | Linear ticket assigned to CEO for clarification |

### Nightly smoke on smo-eo-qa

Automated cron runs at 03:00 UTC:
- curl /api/health on every production URL → 200
- Playwright happy-path scenario
- Lighthouse performance ≥85
- Failure → Telegram #smo-alerts + Linear incident ticket auto-created

---

## Stuck at any step?

First: `/smorch-dev-start` — the 4-layer session bootstrap catches 80%+ of "stuck" cases (missing plugin, wrong branch, stale CLAUDE.md, orphan project inputs).

Then `/smo-dev-guide` (in-session cheat sheet, part of `smorch-dev` plugin). Pass a topic for targeted help:
- `/smo-dev-guide start` — `/smorch-dev-start` explainer (4 layers + input scoring rubric)
- `/smo-dev-guide next` — context-aware "next command to run" (reads last dev-start result + branch + last score + last handover)
- `/smo-dev-guide stuck` — troubleshooting decision tree
- `/smo-dev-guide rollback` — rollback drill policy
- `/smo-dev-guide sops` — SOP index

## Enforcement

See `SOP-32 App-Patching-And-Versioning` (created in this phase) for mechanical gates.
