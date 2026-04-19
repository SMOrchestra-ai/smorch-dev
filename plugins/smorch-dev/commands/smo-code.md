---
description: Execute a planned feature via TDD. Writes test first, then minimal impl, then refactors with elegance pause.
---

# /smo-code

**Pillars:** Boris #2 (Subagent) + #5 (Elegance) — via superpowers TDD
**When:** After `/smo-plan` is approved.

## Workflow

1. Verify plan exists (from /smo-plan output or docs/plans/)
2. For each AC:
   a. Write failing test tagged `@AC-N.N` (red)
   b. Minimal impl to pass (green)
   c. Refactor (blue)
3. If >1 file affected → dispatch subagents (superpowers:subagent-driven-development)
4. Run elegance-pause before final commit
5. cost-tracker annotates any cost anomaly for Engineering Q8
6. Stage + commit with conventional message + @AC-N.N refs

## Arguments

`$ARGUMENTS` — optional specific AC to focus on

## Exit criteria

- All targeted ACs have passing tests
- Elegance pause block in commit message
- No `.skip` tests in committed range
- cost-tracker either clean or tradeoff documented in PR description
