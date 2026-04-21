---
name: handover-generator
description: |
  Generates the dev→QA handover brief from SOP-13 template. Auto-fills BRD refs, PR URL,
  staging URL, test scenarios, known risks, and rollback path. Output is what Lana scores
  via qa-handover-scorer. Brief that scores below 80 is rejected back to dev.
---

# handover-generator — dev→QA Handover Brief

**Invoked by:** `/smo-handover`
**Consumes:** Current PR branch, `architecture/brd.md`, `docs/qa-scores/` latest report, git log
**Produces:** `docs/handovers/YYYY-MM-DD-{pr-number}-handover.md`

## Why this skill exists

Lana rejecting weak handovers is a documented SOP-13 pattern. Without a generator, every dev writes a different format, Lana spends 20 min interpreting, the handover score suffers. Auto-generation = consistent format + 2 min to fill in what the generator can't infer.

## Template output (matches `templates/handover-brief.template.md`)

```markdown
# Handover — {pr-title} (#PR-{number})

**Date:** {today}
**Dev:** {git config user.name}
**Branch:** {current-branch}
**Base:** {base-branch}
**Last commit:** {short-sha} — {commit-message-first-line}

## 1. Completeness

- **BRD ACs covered:** AC-{N.N}, AC-{N.N}, ... (list from @AC tags in tests)
- **BRD ACs deferred:** {list or "none"}
- **PR URL:** {gh pr view --json url}
- **Staging URL:** {from .smorch/project.json → deploy.staging_url}

## 2. Testability

> Auto-generated from `brd-traceability --emit-scenarios`. One block per AC, four scenarios each. Dev reviews + replaces `{stub — ...}` placeholders with real steps before committing. `--validate` fails on any remaining `{stub — ...}` text.

### AC-{N.N} — {AC text}

#### Happy path
- **Setup:** {stub — minimal valid state}
- **Actions:** {stub — primary user action}
- **Expected:** {stub — paraphrase of AC outcome}

#### Empty state
- **Setup:** {stub — preconditions absent}
- **Actions:** {stub — same flow}
- **Expected:** {stub — graceful empty-state UI}

#### Error state
- **Setup:** {stub — one upstream dep fails}
- **Actions:** {stub — same flow}
- **Expected:** {stub — user-facing error + recovery}

#### Edge
- **Setup:** {stub — boundary input}
- **Actions:** {stub — same flow}
- **Expected:** {stub — handled per AC limits}

{repeat AC block for every AC-N.N in BRD}

## 3. Repro-ability

- **Env vars needed:** {list from .env.example diff}
- **Seed data:** {command or N/A}
- **Test accounts:** {credentials or pointer to 1Password}
- **Feature flags:** {list or N/A}

## 4. Risk disclosure

- **Known issues:** {list or "none"}
- **Areas I did NOT test:** {honest list}
- **Recently-touched nearby code (regression risk):** {list}
- **Third-party dependencies affected:** {list}

## 5. Rollback readiness

- **Rollback command:** `/smo-rollback {deploy-id}` or manual steps
- **Rollback SLA:** {e.g., 2 min}
- **Data migration reversibility:** {yes/no/partial + plan}
- **Monitor during first 24h:** {Telegram alerts to watch, log queries}

## Score report
- **Dev self-score:** {composite from latest docs/qa-scores/}
- **Score report:** {path to docs/qa-scores/YYYY-MM-DD-HHMM.md}

## Dev signs off
I attest this brief is accurate. Gaps are documented, not hidden.
```

## Auto-fill logic

The generator populates what it can from git + filesystem:
- PR number + URL: `gh pr view --json number,url`
- Branch + base: `git rev-parse --abbrev-ref HEAD`, `git merge-base HEAD main`
- BRD ACs covered: `grep -oE '@AC-[0-9]+\.[0-9]+' tests/ | sort -u`
- Env vars needed: diff `.env.example` vs base
- Score report: latest file in `docs/qa-scores/`
- Rollback command: reads `.smorch/project.json` → `deploy.rollback_template`
- Scenario stubs (Section 2): invokes `brd-traceability --emit-scenarios` to produce 4 scenarios × N ACs. Dev reviews + replaces placeholders; `--validate` blocks commit if any `{stub — ...}` text remains.

## What the dev must fill manually

- Replace scenario stubs (the generator seeds 4 stubs per AC — dev fills real steps, expected observable outcomes, and actions. Stubs obviously flagged as placeholders.)
- Known issues + untested areas (honesty required)
- Seed data + feature flags (project-specific)
- Sign-off attestation

## Gate

After generation:
1. Dev reviews + fills manual sections — replaces every `{stub — ...}` placeholder with real test steps
2. `/smo-handover --validate` checks: all 5 sections have content, rollback is defined, PR URL resolves, **no `{stub — ...}` placeholders remain** in Section 2
3. Dev commits handover to `docs/handovers/` (tracked in git for audit)
4. `/smo-handover --notify` pings Lana (Telegram) with link

## Integration with qa-handover-scorer

Lana's `/smo-qa-handover-score` reads the generated handover, scores 5 dimensions:
1. Completeness
2. Testability
3. Repro-ability
4. Risk disclosure
5. Rollback readiness

≥80 → accepts. 60-79 → sends back with specific fixes. <60 → auto-rejects + pings Mamoun.

## Don't skip this

Shipping without a handover brief = SOP-13 violation = -1 Product hat on next score. The workflow isn't optional.
