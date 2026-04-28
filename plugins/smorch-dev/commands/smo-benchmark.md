---
description: Performance regression detection. Run before /smo-ship if any UI/API code changed.
allowed-tools: Bash, Read, Write
---

# /smo-benchmark

**When:** Before `/smo-ship` on PRs that touch UI components or API routes.
**Skip:** doc-only PR, build/CI changes, infra-only PR.

## L3 cascade (hard-required, see SOP-36)

| Step | L3 Skill |
|------|----------|
| Page load + Core Web Vitals + bundle size | `gstack:benchmark` |

L2: none. Benchmark output is consumed by `/smo-ship` `GATE_benchmark` directly.

## Workflow

1. **L3 gstack:benchmark** — runs the gstack benchmark suite via the browse daemon:
   - Page load times for tracked routes (read from `docs/benchmarks/routes.json` if present, else top-3 routes from `next.config.js` / `app/` structure)
   - Core Web Vitals (LCP, FID/INP, CLS) for each route
   - JS/CSS bundle size from build output
   - API response time (50/95/99 percentile) for tracked endpoints
2. If `docs/benchmarks/baseline.json` does not exist → write current run as baseline, exit 0 (no regression possible on first run)
3. Compare current run vs baseline:
   - Block (exit 1) if any tracked metric regressed >10%
   - Warn (exit 0 with notes) if 5-10% regression
   - Pass (exit 0) if <5% delta
4. Write report to `docs/benchmarks/YYYY-MM-DD-{branch}.md`:
   - Per-metric table (current, baseline, delta %, verdict)
   - Linked screenshots from gstack:browse (where applicable)
   - Recommendation: "Update baseline" / "Investigate regression" / "Pass"

## Arguments

- `$ARGUMENTS` — optional route subset (default: all tracked routes)
- `--update-baseline` — explicit baseline refresh (use when intentional perf change e.g. new feature with known cost)
- `--threshold N` — override 10% block threshold (rare; document in PR why)

## Output

```
## Benchmark — feat/draft-endpoint vs baseline

| Route | Metric | Current | Baseline | Δ% | Verdict |
|-------|--------|---------|----------|---:|---------|
| /     | LCP    | 1.8s    | 1.7s     | +5.9% | warn |
| /     | CLS    | 0.04    | 0.05     | -20% | pass (better) |
| /api/draft | p95 | 240ms | 220ms  | +9.1% | warn |
| Bundle | main.js | 184KB | 170KB  | +8.2% | warn |

Verdict: PASS (no metric >10% regression)
Recommendation: investigate +9% on /api/draft p95 — likely fixable.

Wrote: docs/benchmarks/2026-04-29-feat-draft-endpoint.md
```

## When baseline drifts

Baseline is committed to the repo (not gitignored). Update with `--update-baseline`
on intentional perf changes (e.g. switching from RSC to client-fetched, adding
new Claude API call). The PR diff shows the baseline change → reviewer can
confirm the new floor is acceptable.

## Why 10% threshold

Soft gate that catches accidental N+1 queries, large bundle imports, missing
memoization. Below 10% is noise. Above 10% nearly always indicates a real
regression worth investigating.
