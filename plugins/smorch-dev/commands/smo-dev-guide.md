---
description: In-session cheat-sheet. Answers "what command do I run now", "what does this gate mean", "where is SOP-X". Context-aware via .smorch/project.json + latest docs/.
---

# /smo-dev-guide

**For:** anyone using smorch-dev or smorch-ops commands who needs a pointer without leaving the session.
**When:** stuck, onboarding, or checking "what's the verb boundary between ship and deploy again?"

## Workflow

1. Invoke `dev-guide-router` skill with `$ARGUMENTS` (topic or empty)
2. Router resolves topic:
   - **empty** → print overview + table of topics
   - **`start`** → `/smorch-dev-start` 4-layer bootstrap explainer (machine · context · project · input-quality)
   - **`next`** → context-aware recommendation (reads `~/.claude/.last-dev-start` + latest `docs/qa-scores/` + `docs/handovers/` + `docs/qa/` + `.smorch/project.json` + branch/PR state — outputs the next command to run. If dev-start not run or >8h old, recommends `/smorch-dev-start` first.)
   - **`chain`** → daily chain visualization with wall-clock targets
   - **`score`** → scoring gates (92/8.5) + what to do at each level
   - **`handover`** → SOP-13 5-dim rubric + how Lana scores
   - **`qa`** → /smo-qa-run steps + MENA / rollback-drill gates
   - **`ship`** → ship vs deploy verb boundary (SOP-14)
   - **`locale`** → .smorch/project.json schema for `locale` field
   - **`rollback`** → rollback drill policy + how to flip to optional
   - **`sops`** → SOP index (SOP-01…SOP-18)
   - **`lessons`** → lessons.md pointer (global + project)
   - **`stuck`** → troubleshooting decision tree
   - **`{command}`** (e.g., `ship`, `handover`) → that command's usage + gates
3. Router prints the section, no more, no less
4. Suggests one follow-up topic if obvious ("also see: chain")

## Arguments

- `$ARGUMENTS` — topic name (see list above) or empty for overview
- Case-insensitive. `/smo-dev-guide NEXT` = `/smo-dev-guide next`.

## Examples

```
/smo-dev-guide                     # overview
/smo-dev-guide start               # /smorch-dev-start explainer (4 layers)
/smo-dev-guide next                # "run /smorch-dev-start first — never run this session"
/smo-dev-guide score               # scoring gates
/smo-dev-guide stuck               # decision tree for common blockers
/smo-dev-guide sop-13              # SOP-13 summary + file pointer
/smo-dev-guide l-009               # L-009 push discipline
```

## Non-goals

- NOT a full SOP copy. Surfaces the key rule + pointer to the source file.
- NOT a code generator. Read-only.
- NOT a scoring tool. That's `/smo-score`.

## Rule

If a topic isn't covered, router says so explicitly: `no topic "{x}" — try overview, chain, score, ...`. Never guess or hallucinate a command.
