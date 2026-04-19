---
description: Plan a feature before coding. Reads BRD + lessons + project overlay. Internal workflow entry point.
---

# /smo-plan

**Pillar:** Boris #1 — Plan Mode Default
**When:** Before writing any code for a new feature.

## Workflow

1. Enter plan mode
2. Read `architecture/brd.md`, `.claude/lessons.md`, `.smorch/project.json`
3. If `.smorch/overrides/` exists, apply to rubric expectations
4. Extract ACs (`AC-N.N`) for the feature
5. If MENA project (overlay says so) → note arabic-rtl-checker + mena-mobile-check will apply at /smo-score time
6. Use superpowers:writing-plans to draft approach
7. Flag cost-tracker risk if PR will add Claude/OpenAI/DB paths
8. Present plan, wait for user approval
9. On approval: exit plan mode, begin superpowers:test-driven-development

## Arguments

`$ARGUMENTS` — feature name or BRD story reference

## Output

```
## Feature plan: {name}

**BRD ACs:** AC-N.N, AC-N.N

**Project overlay:** {project from .smorch/project.json}
**MENA:** yes/no → checks that will apply

**Relevant lessons:**
- L-00X: {rule}

**Approach:**
- …

**Risks / unknowns:**
- …

**Cost-tracker pre-check:** {flagged / clean / N/A}

**Ready to /smo-code?** (y/n)
```
