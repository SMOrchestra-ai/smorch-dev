---
name: cost-tracker
description: |
  Flags token/API spend anomalies per PR. Reads usage logs from Claude API (Anthropic
  console export), OpenAI (if used), and infra costs (Supabase, Vercel, server billing).
  Surfaces any PR that causes a >2× spend delta vs 7-day rolling average. Rejected idea
  of a separate hat — this is a signal surfaced during /smo-score Engineering hat.
---

# cost-tracker — Spend Anomaly Detection per PR

**Why:** MicroSaaS margin is tight. A feature that works but 5×'s Claude API cost isn't shippable without conscious tradeoff. This skill surfaces that tradeoff before the PR merges.

**Invoked by:** `/smo-score` (automatic during Engineering hat Q8 if PR touches Claude/OpenAI/DB paths)
**Consumes:** 7-day rolling spend from Anthropic console, Supabase dashboard, Vercel analytics
**Produces:** `docs/cost-reports/YYYY-MM-DD-{pr}.md` + annotation on Engineering hat score

---

## What it checks

### 1. Claude API token spend
- Compare this PR's branch deploy vs main (7-day avg)
- Metric: tokens/request, cache hit rate, request count/minute
- **Flag if:** >2× token-per-request OR cache hit <30% on paths that were >70%

### 2. OpenAI spend (if project uses it)
- Same as Claude — comparative

### 3. Database cost signals (Supabase)
- Read rows/request (N+1 query detection)
- Write rows/request (bulk insert bloat)
- Egress bytes (large JSON payloads)
- **Flag if:** any >3× delta

### 4. Frontend bundle size (if UI PR)
- Compare `.next/analyze` output vs main
- **Flag if:** >50KB net add without justification in PR description

### 5. Server cost (if deploy PR)
- PM2 memory footprint (`pm2 list --json`)
- CPU % at steady state
- **Flag if:** memory >1.5× OR CPU sustained >70% (headroom lost)

---

## Signal, not gate

This skill does NOT block the PR. It annotates Engineering hat Q8 in `/smo-score` with a cost flag:

```
Q8 (deps + cost): 7 → cost-tracker flags 3.2× Claude token spend on /api/draft
Action required: document tradeoff OR optimize before ship
```

Dev must either:
- **Justify in PR description** (e.g., "new feature uses longer context, accepted tradeoff") — Q8 returns to 9+ with comment
- **Optimize** (batch calls, cache responses, reduce context window) — Q8 returns to 10

---

## Integration with /smo-retro

Monthly, `/smo-retro` aggregates cost-tracker flags across projects. Pattern surfaces:
- "3 PRs last month doubled SSE's Claude spend. Time to evaluate alternate model or prompt compression."

This becomes a lesson in `smorch-brain/canonical/lessons.md` (cross-project).

---

## Data sources + how to pull

### Anthropic console
Export usage CSV from `console.anthropic.com/billing/usage` manually OR via API:
```bash
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
  "https://api.anthropic.com/v1/organizations/{org}/usage?start=2026-04-12&end=2026-04-19"
```

Store 7-day rolling window in `~/.claude/cost-baseline/claude-7d.csv`.

### Supabase
```sql
SELECT date, SUM(db_size_bytes) as size, SUM(egress_bytes) as egress, SUM(db_operations) as ops
FROM supabase_usage
WHERE date > NOW() - INTERVAL '7 days'
GROUP BY date ORDER BY date;
```

### Vercel
`vercel inspect {deployment-url} --token $VERCEL_TOKEN` → JSON with function invocations + bandwidth.

### Server (PM2)
Run on the target server via `/smo-deploy --dry-run` or SSH:
```bash
pm2 list --json | jq '.[] | {name, monit}'
```

---

## Configuration

Per-project in `.smorch/project.json`:
```json
{
  "cost_tracking": {
    "claude_multiplier_threshold": 2.0,
    "supabase_ops_threshold": 3.0,
    "bundle_size_kb_threshold": 50,
    "exclude_paths": ["/api/seed"]
  }
}
```

Omitted = defaults above.

---

## What this skill does NOT do

- It does not STOP a deploy. Just flags.
- It does not manage budget alerts (those live in Anthropic/Stripe/Supabase dashboards).
- It does not predict future cost — only compares PR-vs-baseline.
- It does not audit third-party pricing changes. (That's a monthly review in /smo-retro.)

---

## First run setup

```bash
mkdir -p ~/.claude/cost-baseline
# Pull 7 days of historical data once:
bash ~/.claude/plugins/smorch-dev/skills/cost-tracker/scripts/seed-baseline.sh
# Subsequent runs auto-refresh
```

Seed script (to be created) pulls from all configured sources and stores baseline CSVs.
