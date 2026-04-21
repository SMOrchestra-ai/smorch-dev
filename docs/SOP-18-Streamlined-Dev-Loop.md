# SOP-18 — Streamlined Dev Loop (draft)

> **Status:** Draft in smorch-dev. Promote to `SOPs/sops/SOP-18-Streamlined-Dev-Loop.md` after v1.2.0-dev lands and post-streamline metrics confirm the ≥50% wall-clock reduction target.
> **Last updated:** 2026-04-21
> **Applies to:** Mamoun's Mac + future engineering hires + Lana's QA machine (eng-desktop + qa-machine profiles).

---

## Why this SOP exists

SOP-14 defined the 17-command surface. SOP-13 defined the handover protocol. SOP-01/02 defined the scoring + QA gates. SOP-18 is how those pieces run **fast** — the ergonomics layer on top of the already-locked discipline.

Nothing in SOP-18 loosens a gate. Every gate from SOP-02 (92+ composite, 8.5 hat floor), SOP-13 (≥80 handover score), SOP-01 (QA scenario pass), and L-009 (commit + push + PR + merge + tag) still fires. SOP-18 removes friction **around** the gates, not the gates themselves.

---

## The streamlined chain

```
/smo-plan       →  reads locale + rollback_drill from .smorch/project.json; notes MENA applicability
/smo-code       →  unchanged (engineering depth is not on the optimization path)
/smo-score      →  unchanged
/smo-bridge-gaps →  unchanged (fires only on score 80–91)
/smo-handover   →  auto-emits 4 scenario stubs per AC via brd-traceability; dev fills real steps
/smo-qa-handover-score (Lana)  →  unchanged 5-dim rubric
/smo-qa-run (Lana)  →  locale-gated MENA checks; rollback drill per project policy; otherwise unchanged
/smo-ship       →  5 gate checks in parallel, then serial build/test/audit, then merge ceremony
/smo-deploy     →  unchanged
```

---

## What changed vs. v1.1.x

| # | Change | Commands affected | Saves per cycle |
|---|---|---|---|
| 1 | Parallel gate preamble in `/smo-ship` | smo-ship | ~90 sec |
| 2 | Scenario stubs auto-generated (4 per AC × N ACs) | brd-traceability, handover-generator, smo-handover | ~5 min |
| 3 | MENA checks skip on `locale=en-US` | smo-qa-run | ~2 min on non-MENA projects |
| 4 | Rollback drill optional per project | smo-qa-run | ~3 min when policy = optional |
| 5 | Cron sync observability (n8n heartbeat) | scripts/sync-from-github.sh | detection gap: days → ≤45 min |

**Target:** handover → deploy wall-clock drops from ~53 min baseline (docs/metrics/2026-04-21-pre-streamline.md) to ≤25 min. Re-measure after v1.2.0-dev ships.

---

## Per-project `.smorch/project.json` fields introduced

See canonical template at `plugins/smorch-dev/templates/smorch-project.json.template`.

### `locale`
- Values: `"ar-MENA"` (default) | `"en-US"` | `"mixed"`
- Controls: MENA checks in `/smo-qa-run` (arabic-rtl-checker, mena-mobile-check 375px, Arabic axe)
- Default preserves today's behavior — missing field = run MENA checks
- Flipping to `"en-US"` on an existing project requires Mamoun PR approval (policy decision, not a bug fix)

### `qa.rollback_drill`
- Values: `"required"` (default) | `"optional"`
- Controls: whether `/smo-qa-run` step 7 executes `/smo-rollback --dry-run` as a QA gate
- Default preserves today's behavior
- Flipping to `"optional"` requires Mamoun PR approval. Appropriate for doc-only, copy-only, or already-deployed-reverts projects. Inappropriate for anything touching customer data, auth, or payments.

### Policy flip discipline

Flips to `locale: "en-US"` or `qa.rollback_drill: "optional"` MUST go through a dedicated PR that **only** modifies `.smorch/project.json`. No bundling with feature work. This gives Mamoun a clean policy review — no tree of changes obscuring the gate weakening.

The resulting `/smo-qa-run` QA report names the flipping PR in the "SKIPPED" note so the audit trail is explicit:

```
- Rollback drill: SKIPPED (qa.rollback_drill=optional per .smorch/project.json, CEO-approved PR #{flip-pr})
```

---

## Scenario stub contract (handover brief Section 2)

`handover-generator` embeds 4 stubs per AC in Section 2 of the handover brief. Each stub contains literal placeholder text `{stub — ...}`. Dev replaces every placeholder with real reproduction steps before committing.

`/smo-handover --validate` refuses to pass if any `{stub — ...}` text remains. This is the "gaps are documented, not hidden" discipline from SOP-13: Lana sees 4 scenarios per AC because 4 stubs were seeded, not because dev invented them — and the validation blocks fake completion.

---

## Gate surface after parallelization

`/smo-ship` emits one of:

```
GATE_score: PASS
GATE_hat_floor: PASS
GATE_qa: PASS
GATE_handover: PASS
GATE_git_clean: PASS
→ proceed to build/test/audit
```

or on failure:

```
GATE_score: FAIL — composite=88 < 92 (docs/qa-scores/2026-04-21-1402.md)
GATE_handover: FAIL — score=74 < 80 (docs/handovers/2026-04-21-PR-47-handover.md)
→ 2 gates failed. Build NOT attempted. Fix both and re-run.
```

**Rule:** the error message always names which gate failed AND where the evidence lives. Parallelization must not muddle error surfacing.

---

## Observability — cron sync heartbeat

Every cron-invoked `sync-from-github.sh` POSTs to `https://flow.smorchestra.ai/webhook/smorch-sync-heartbeat` at each exit point:

| Outcome | Meaning |
|---|---|
| `up_to_date` | pulled nothing, already at origin/main |
| `synced` | pulled + installed + validated successfully |
| `pull_failed` | `git pull --ff-only` refused (non-ff or conflict) |
| `validate_failed` | pulled ok but `validate-plugins.sh` failed |

The POST is fire-and-forget: 5-sec timeout, non-blocking. If n8n is down, the sync still succeeds; the dashboard just shows the host as "stale" until n8n recovers. This does not introduce new SEV-risk surface.

A simple n8n workflow writes each heartbeat to a sheet/table; the dashboard shows last-sync-per-host. Alerts fire if any host is silent for >45 min (30-min cron cadence + 15-min grace).

---

## Non-negotiables preserved

Unchanged from SOP-02 + SOP-13 + L-009:

- **Composite ≥ 92, no hat < 8.5** before `/smo-ship`
- **Handover score ≥ 80** before Lana accepts QA
- **All QA scenarios pass** before Lana marks QA PASS
- **Commit + push + PR + merge + tag** every work unit (L-009)
- **Never edit files directly on a server** (local → GitHub → server pull)
- **Secret-scanner hook** + **destructive-blocker hook** always on

---

## Rollback if SOP-18 proves wrong

- Revert the smorch-dev PR that introduced the streamlined commands. `.smorch/project.json` fields stay (harmless — commands re-added later would read them again).
- Hosts: next cron (≤30 min) picks up the revert automatically. No manual server intervention.
- Metrics: re-measure in docs/metrics/YYYY-MM-DD-rollback.md to confirm we're back at baseline.

---

## Related

- SOP-01 QA Protocol — QA gate and scenario pass requirement
- SOP-02 Pre-Upload Scoring — 92+ composite + 8.5 hat floor
- SOP-13 Lana Handover Protocol — handover score gate
- SOP-14 Plugin Workflow — command surface + verb boundaries
- SOP-15 Cross-Machine Sync — cron cadence the heartbeat observes
- L-009 (lessons.md) — push discipline
- docs/metrics/2026-04-21-pre-streamline.md — baseline numbers
- plugins/smorch-dev/templates/smorch-project.json.template — canonical overlay schema
