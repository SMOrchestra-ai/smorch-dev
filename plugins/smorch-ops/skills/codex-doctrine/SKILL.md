---
name: codex-doctrine
description: |
  SOP-11 enforcement. Default to Claude Code for all architecture + planning + review work.
  Codex (GPT) only with Mamoun's explicit approval and logged audit. This skill prevents silent
  Codex usage that introduces tool-mix inconsistency.
---

# codex-doctrine — SOP-11 Enforcement

**Purpose:** SMOrchestra standardizes on Claude Code. Codex is not banned — it's gated.

## The rule

- **Claude Code (us)** — architecture, planning, review, scoring, handovers, SOPs, CLAUDE.md work
- **Codex** — allowed only for: high-volume repetitive refactors where Claude Code would cost too much, with Mamoun's explicit approval

## When Codex is tempting

- "Rename 500 instances of foo → bar across 40 files" — tempting, but ripgrep + sed works and is auditable
- "Convert 200 test files to new framework" — tempting, but superpowers:subagent-driven-development handles it cleanly
- "Generate boilerplate for 50 new API endpoints" — tempting, but a scaffold template + one-time generation beats N Codex runs

## When Codex is actually justified

- Translating/internationalizing 1000+ strings (mechanical, Codex is cheap + fast)
- Parsing 10GB+ of logs into structured data (token cost matters here)
- Generating synthetic test data at large scale

## The audit gate

Before invoking Codex:
1. Write down the task in 1 sentence
2. Estimate Claude Code cost (tokens × rate)
3. Estimate Codex cost (tokens × rate)
4. If Codex < 30% of Claude cost AND task is mechanical → Mamoun approval OK
5. Log to `docs/codex-audit.csv`:
   ```
   date,task,claude_estimate,codex_estimate,actual_cost,outcome
   ```

## Enforcement in the workflow

- `/smo-plan` checks current task: if task description matches Codex-tempting patterns but no audit row exists → warns
- `/smo-score` Engineering hat Q5 (elegance): if Codex was used without audit, pause skipped → caps Engineering at 7
- `/smo-retro` aggregates codex-audit.csv monthly: consistent Codex use for non-mechanical work → SOP review

## Skill behavior

This skill is NOT invoked as a command. It's a policy enforced at scoring + planning time.

When a PR's commit messages or PR description mention "used Codex for X":
1. `/smo-score` checks `docs/codex-audit.csv` for a matching entry
2. If not found → flags as SOP-11 violation → Engineering hat -2 points
3. If found but task pattern doesn't match approved patterns → flags for Mamoun review

## Rule

Default to Claude Code. Question every Codex urge. Document the cases where Codex wins. Over time, we should see Codex usage DECREASE as our Claude Code workflows get tighter (skills do more, prompt engineering reduces token spend).

## Integration with SOP-07

SOP-07 (Agentic Coding Orchestration) defines the Claude Code vs Codex routing logic. This skill is the runtime enforcement of that policy. See SOP-07 for the full decision tree.

## Reference

- SOP-07: Agentic Coding Orchestration
- SOP-11: Codex Doctrine (full policy)
- `docs/codex-audit.csv`: audit log
