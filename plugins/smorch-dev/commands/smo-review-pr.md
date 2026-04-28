---
description: External adversarial code review of an open PR. Distinct from /smo-score (internal calibration).
allowed-tools: Bash, Read
---

# /smo-review-pr

**When:** After `/smo-score` returned ≥92 (internal calibration), before `/smo-ship`.
**Why distinct from /smo-score:** /smo-score is internal multi-hat calibration. /smo-review-pr is external adversarial review by a fresh reviewer subagent that hasn't seen the session history.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill | When |
|------|----------|------|
| Reviewer dispatch | `superpowers:requesting-code-review` | Always |
| Pre-landing check | `gstack:review` | If `--deep` flag (SQL safety, LLM trust, side effects) |
| Security focus | `gstack:security-review` (built-in Claude command) | If `--security` flag or PR touches auth/secrets |
| Author response | `superpowers:receiving-code-review` | If reviewer returned non-trivial feedback |

L2: `brd-traceability` re-validates AC coverage if reviewer suggested changes that touched test files.

## Workflow

1. Resolve PR target:
   - `$ARGUMENTS` is a PR number → `gh pr view {n}` to fetch
   - `$ARGUMENTS` is a branch name → `gh pr list --head {branch}` to resolve
   - empty → use current branch
2. **L3 superpowers:requesting-code-review** — dispatch reviewer subagent with crafted context:
   - Diff (unified, with surrounding context)
   - BRD ACs covered (from `docs/handovers/`)
   - Score report (from `docs/qa-scores/`)
   - Architecture overview (3-5 sentences from `architecture/`)
   - NOT session history. Reviewer is fresh — never sees coordinator chatter.
3. Reviewer returns structured feedback with severity (critical / blocker / suggestion / nit)
4. **If `--deep` flag**: also run **L3 gstack:review** for pre-landing checks (SQL safety, LLM trust boundaries, conditional side effects)
5. **If `--security` flag** OR PR touches `auth/`, `secrets/`, `*.env*`, or RLS policies: also run **L3 gstack:security-review**
6. Aggregate all reviewer outputs into a single decision:
   - **Critical/Blocker**: block /smo-ship until addressed
   - **Suggestion**: surface to author, non-blocking
   - **Nit**: collapsed in report
7. **If non-trivial feedback** (≥1 blocker or ≥3 suggestions):
   - Author runs **L3 superpowers:receiving-code-review** — technical evaluation, not emotional response. Verify each item before implementing. Ask for clarification on unclear feedback.
8. **L2 brd-traceability** re-validates AC coverage if test-file changes happened
9. Output to `docs/reviews/YYYY-MM-DD-PR-{n}.md`

## Arguments

- `$ARGUMENTS` — PR number or branch name (default: current branch)
- `--deep` — also run gstack:review (pre-landing pass)
- `--security` — also run gstack:security-review
- `--auto-address` — author automatically applies non-controversial suggestions (still requires manual review of blockers)

## Output

```
## Code review — PR #47 feat/draft-endpoint

### Reviewer subagent (superpowers:requesting-code-review)
- BLOCKER: src/lib/draft.ts:42 — Claude API call missing timeout. Will hang on
  upstream slowdown. Recommend AbortController + 30s timeout + toast on abort.
- SUGGESTION: src/components/Draft.tsx:88 — useEffect deps array missing
  `userId`. Stale closure risk if user switches account mid-render.
- NIT: src/lib/draft.ts:7 — type alias could be const enum.

### gstack:review (--deep)
- SQL safety: ✓ no raw SQL constructed from user input
- LLM trust: ✓ all Claude responses validated against zod schema
- Side effects: ✓ no conditional toast / log / db-write

### Verdict: BLOCKED
1 blocker, 1 suggestion, 1 nit. Address blocker before /smo-ship.

Wrote: docs/reviews/2026-04-29-PR-47.md
```

## How this differs from /smo-score

| | /smo-score | /smo-review-pr |
|--|------------|----------------|
| Scope | Internal calibration | External review |
| Reviewer | 5 hat-scorers (in-session) | Fresh subagent (no history) |
| Output | Composite + hat scores (0-100) | Severity-tagged feedback |
| Gate | 92+ to ship | 0 blockers to ship |
| Cadence | Run before bridge-gaps | Run before ship |

Both are required. /smo-score catches calibration drift; /smo-review-pr catches
blind spots a self-rater can't see.
