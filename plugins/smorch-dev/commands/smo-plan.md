---
description: Plan a feature before coding. Reads BRD + lessons + project overlay. Multi-perspective L3 review (writing-plans + plan-eng-review + optional CEO/design). Internal workflow entry point.
---

# /smo-plan

**Pillar:** Boris #1 — Plan Mode Default
**When:** Before writing any code for a new feature.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill | When | Owner |
|------|----------|------|-------|
| Draft plan | `superpowers:writing-plans` | Always | superpowers |
| Architecture pass | `gstack:plan-eng-review` | Always | gstack |
| Strategy pass | `gstack:plan-ceo-review` | If BRD flags product-strategy ambiguity OR `--ceo` arg | gstack |
| Design pass | `gstack:plan-design-review` | If plan type = `fullstack-with-ui` | gstack |
| TDD handoff | `superpowers:test-driven-development` | After approval, via `/smo-code` | superpowers |

L2 wrappers: `brd-traceability` appends AC-N.N coverage map, `lessons-manager` prepends top-3 relevant past lessons.

## Workflow

1. Enter plan mode
2. Read `architecture/brd.md`, `.claude/lessons.md`, `.smorch/project.json`
3. If `.smorch/overrides/` exists, apply to rubric expectations
4. Extract ACs (`AC-N.N`) for the feature
5. Read `locale` from `.smorch/project.json` (default `"ar-MENA"`):
   - `"ar-MENA"` or `"mixed"` → note arabic-rtl-checker + mena-mobile-check + Arabic axe will apply at /smo-score and /smo-qa-run
   - `"en-US"` → MENA checks skipped downstream; English axe still runs
   - Also read `qa.rollback_drill` (default `"required"`) for /smo-qa-run gating awareness
6. Detect plan type from BRD signals + `.smorch/project.json`:
   - `backend` (no UI files in plan), `fullstack-with-ui` (any `.tsx`/`.jsx`/component changes), `refactor` (existing tests stay, no new ACs)
7. **L2 lessons-manager**: prepend top-3 relevant past lessons (filtered by feature keywords)
8. **L3 superpowers:writing-plans**: draft the plan, emit `docs/plans/{feature}.md` with bite-sized tasks
9. **L3 gstack:plan-eng-review**: opinionated architecture/data-flow/edge-case pass on the draft, append review block
10. **If product-strategy ambiguity** (BRD has open questions, or `$ARGUMENTS` includes `--ceo`):
    - **L3 gstack:plan-ceo-review**: CEO/founder rethink — scope expansion, hold, or reduction
11. **If plan type = `fullstack-with-ui`**:
    - **L3 gstack:plan-design-review**: design-dimension scoring + fixes
12. **L2 brd-traceability**: append AC-N.N → file coverage map at the bottom
13. Flag cost-tracker risk if PR will add Claude/OpenAI/DB paths
14. Present full plan with all review blocks, wait for user approval
15. On approval: exit plan mode, route to `/smo-worktree` then `/smo-code`

## Arguments

- `$ARGUMENTS` — feature name or BRD story reference
- `--ceo` — force CEO-review pass even if BRD has no flagged ambiguity
- `--no-design` — skip design-review pass on a fullstack-with-ui plan (rare; only for refactors)

## Output

```
## Feature plan: {name}

**BRD ACs:** AC-N.N, AC-N.N

**Project overlay:** {project from .smorch/project.json}
**Locale:** {ar-MENA | en-US | mixed} → MENA checks {apply | skip}
**Rollback drill:** {required | optional} → {enforced | skip — CEO-approved in flipping PR}

**Relevant lessons:**
- L-00X: {rule}

**Approach:**
- …

**Risks / unknowns:**
- …

**Cost-tracker pre-check:** {flagged / clean / N/A}

**Ready to /smo-code?** (y/n)
```
