---
description: Live diagnostic for a bug or failing test. Hypothesis → evidence → root cause → regression test. Renamed from /smo-debug to avoid verb collision with /smo-incident.
---

# /smo-triage

**Pillar:** Boris #6 — Autonomous Bug Fixing
**When:** Bug report, failing test, production issue with a live repro.

## Why renamed from /smo-debug

Too similar to `/smo-incident` (post-mortem). This is LIVE diagnostic. Incident is write-up. See SOP-14 verb boundaries.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill | Owns |
|------|----------|------|
| Investigate | `gstack:investigate` | Filesystem + git history scan, hypothesis generation |
| Debug | `superpowers:systematic-debugging` | Hypothesis → evidence → root cause → regression test |

L2 wrappers: `elegance-pause` on the fix, `lessons-manager` records new pattern.

## Workflow

1. Capture failure: exact error, repro steps, environment
2. **L3 gstack:investigate** — filesystem + git history scan, surface candidate causes from recent PRs / blame / logs
3. **L3 superpowers:systematic-debugging** — hypothesis → evidence → root cause → regression test
4. Form ≤3 hypotheses, ranked by likelihood
5. Gather evidence (logs, git blame, recent PRs, `/smo-drift` check)
6. Confirm root cause
7. Minimal fix at root cause (not symptom)
8. Add regression test tagged `@bug-NNN` or `@AC-N.N`
9. **L2 elegance-pause** on fix
10. Commit: `fix({scope}): description`
11. **L2 lessons-manager** appends if pattern recurring (≥2 prior triggers across projects)
12. Handoff: if post-mortem needed, proceed to `/smo-incident`

## Arguments

`$ARGUMENTS` — bug description, error, or repro URL

## Output

```
## Triage: {title}

**Reproduction:** {steps}

**Hypotheses considered:**
1. (LIKELY) race condition in loading state
2. (MEDIUM) stale cache
3. (UNLIKELY) upstream API change — ruled out via curl

**Evidence for #1:**
- console shows 2x state updates in 50ms
- git blame: PR #42 introduced useEffect without cleanup

**Root cause:** useEffect missing dependency + no cleanup in unmount

**Fix:** src/lib/loading.ts:34 — add cleanup fn + correct deps

**Regression test:** tests/loading.test.ts tagged `@bug-NNN`

**Elegance pause:** Yes. Considered using useMemo — cleanup pattern is simpler.

**Lesson L-00X appended?** Yes (recurring useEffect pattern)
```

## Anti-patterns blocked

- Fix without root cause → rejected
- Fix without regression test → blocked
- "Works on my machine" with no evidence → blocked
- Symptom patch ("just add a try/catch") → rejected, find root cause
