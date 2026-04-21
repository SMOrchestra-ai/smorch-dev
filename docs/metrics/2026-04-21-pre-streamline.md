# Pre-Streamline Baseline — 2026-04-21

Captured before WS2–WS7 of the smorch-dev streamline plan land. Re-measure after v1.2.0-dev ships to validate the ≥50% wall-clock target.

## Command step counts (ground truth for "parallelization" claims)

These are the instruction counts in the command `.md` files as Claude Code executes them. Not wall-clock, but a sharp proxy: every step maps to at least one file read + validation.

| Command | File | Numbered steps | Gate preamble serial steps | Observed cycle time (est.) |
|---|---|---|---|---|
| `/smo-ship` | `plugins/smorch-dev/commands/smo-ship.md` | 9 | 5 (steps 1–5) | ~3 min |
| `/smo-qa-run` | `plugins/smorch-dev/commands/smo-qa-run.md` | 8 | 6 (steps 1–6) before drill | ~8 min (MENA) / ~6 min (non-MENA forced today) |
| `/smo-handover` | `plugins/smorch-dev/commands/smo-handover.md` | 7 | 3 dev-author prompts | ~7 min (dev authoring dominates) |
| `/smo-qa-handover-score` | `plugins/smorch-dev/commands/smo-qa-handover-score.md` | — | 5-dim rubric | ~5 min per review |

## Chain wall-clock (typical feature, today)

```
/smo-plan        ~10 min
/smo-code        ~60 min   (varies wildly — excluded from streamline targets)
/smo-score       ~5 min
/smo-bridge-gaps ~10 min   (when triggered)
/smo-handover    ~7 min    ← WS3 target: ~2 min
/smo-qa-handover-score (Lana)  ~5 min
/smo-qa-run      ~8 min    ← WS4+WS5 target: ~5 min (non-MENA) / ~6 min (MENA, no drill)
/smo-ship        ~3 min    ← WS2 target: ~90 sec
/smo-deploy      ~5 min
────────────────────────
Feature wall-clock (excl. /smo-code): ~53 min handover→deploy
Streamline target:                    ~25 min handover→deploy (≥50% cut)
```

## Fixed gates (unchanged by streamline)

These stay intact and are NOT on the velocity-optimization path:

- Score gate: composite ≥ 92, no hat < 8.5
- QA handover score gate: ≥ 80
- QA run: all scenarios must pass
- L-009 push discipline: commit + push + PR + merge + tag every work unit
- Secret/destructive hooks: always on

## Server drift state at baseline

All 4 servers: `f230ed8` (origin/main). Closed via manual sync at 2026-04-21T18:03 UTC.

## Re-measure protocol (after streamline ships)

1. Pick the first feature to land after v1.2.0-dev tag.
2. Record wall-clock per command in `docs/metrics/2026-XX-XX-post-streamline.md`.
3. Compare total handover→deploy time vs this baseline's 53 min.
4. Hat count by hat: confirm no hat dropped below its baseline score.

## Honest caveat

Claude-driven commands don't have clean `time` wrappers — these are observed/estimated, not instrumented. Step counts are the sharper proxy. If after streamline the step counts drop as designed AND the feature doesn't slip in any hat, the plan worked.
