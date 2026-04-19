# The 2 Files That Decide If Claude Code Ships Real Product — Boris's Framework

**Video title drafts:**
- "I studied Boris Cherny's Claude Code setup — these 2 files do 90% of the work"
- "The 2-File Framework: BRD + CLAUDE.md (Stop Prompting, Start Configuring)"
- "Why Your Claude Code Projects Fail — the 2 Missing Files"

**Audience:** Founders / solo devs / small teams who already use Claude Code but struggle to ship consistent quality.
**Duration target:** 12-16 min (each section ~60-90s).
**Companion video:** "10 Steps to Set Up the Ultimate Claude Code" (this zooms into Steps 2 + 5 of that).

---

## The hook (first 30 seconds)

"If I gave you one week to turn Claude Code from a toy into a shipping machine, I'd tell you to ignore 90% of the docs and focus on just TWO files: your `CLAUDE.md` and your `BRD`. Get these right and every `/smo-plan`, every test, every score, every rollback flows from them. Get them wrong and you're just prompting harder. I'm going to break down EXACTLY what goes in each — straight from Boris Cherny's framework at Anthropic, applied to the 11 projects we ship at SMOrchestra."

**B-roll:** side-by-side: chaotic prompting screenshot on left, a clean `CLAUDE.md` + `BRD.md` on the right. Title card: "THE 2-FILE FRAMEWORK".

---

## Why these 2 files — and nothing else — matter at project start

Every Claude Code session loads 3 things before ANY work:

1. **`~/.claude/CLAUDE.md`** (global — who you are, how you work)
2. **`{project}/CLAUDE.md`** (project — what this project is, what rules apply)
3. **`{project}/architecture/brd.md`** (feature — what we're building, what done looks like)

Plus per-project: `.claude/lessons.md` (corrections you've already captured).

**These are YOUR system prompts, persisted.** Every token Claude reads before writing code comes from here. Inflate them → you pay for noise. Starve them → Claude guesses at intent.

Boris Cherny (Anthropic, Claude Code team) says ~100 lines for CLAUDE.md. Mine is 116. If yours is 400 — you're not configuring, you're journaling.

**Script note:** this is the "stop prompting, start configuring" thesis of the video.

---

## File 1 — `CLAUDE.md` — the Boris discipline

### The 7 sections (what goes IN)

1. **Who you are** — 3 lines. Name, role, location if relevant. No bio.
2. **What you build** — 5 bullets max. Business lines. One line each.
3. **Core thesis** — 1 line. The filter for every decision. Example: "Signal-based trust engineering, not relationship selling."
4. **Infra table** — servers, databases, key APIs. A single table.
5. **How you work** — 5 operating principles. E.g., "Don't ask 'shall I proceed' after every step."
6. **Command chain** — the single pipeline. E.g., `/smo-plan → /smo-code → /smo-score → /smo-handover → /smo-ship → /smo-deploy`
7. **Non-negotiable gates** — 5 bullets max. Score threshold, handover threshold, branch protection.

**That's it.** If you have anything else, it belongs somewhere else (see next section).

**Show on screen:** my real `~/.claude/CLAUDE.md` scrolled top-to-bottom — fits on one screen.

### The 4 anti-patterns (what DOESN'T go in)

| Anti-pattern | Fix |
|--------------|-----|
| Project-specific tech stack ("we use Next.js 14 + Supabase") | → `{project}/CLAUDE.md` |
| Detailed rubrics / scoring criteria | → plugin's `smo-scorer` skill |
| Operational procedures ("how to deploy to eo-prod") | → SOP files |
| Bio / philosophy / history | → your personal notes, not here |

### The 3 scope levels — global / project / overlay

```
~/.claude/CLAUDE.md              ← 120 lines. GLOBAL. Every session reads this.
{project}/CLAUDE.md              ← 40-60 lines. Per project.
{project}/.smorch/project.json   ← Machine-readable config (plugin reads this).
```

**Rule:** a new line is added WHERE? Run this question:
- Does this apply to EVERY project? → global
- Does this apply to ONE project? → project CLAUDE.md
- Is it a config value (deploy target, flags, thresholds)? → `.smorch/project.json`

**Show on screen:** the 3 files side-by-side, color-coded.

### The 120-line rule (Boris's law)

If your global `CLAUDE.md` is >120 lines, you're:
- Duplicating content from SOPs
- Journaling your philosophy
- Putting project-specific rules in the wrong place

**Fix:** every week, run `wc -l ~/.claude/CLAUDE.md`. If >120 → audit + prune.

---

## File 2 — the BRD — the build contract

### The user story format (3 lines, non-negotiable)

```markdown
## Story 1: Password Reset

**As a** logged-out founder
**I want to** reset my password via email
**So that** I can regain access if I forget it
```

If you can't write these 3 lines → you don't understand the feature yet. Stop. Talk to a user.

### The AC-N.N tagging contract (the biggest lever)

Every acceptance criterion is **numbered + testable**:

```markdown
### Acceptance Criteria
- **AC-1.1** User enters email, receives reset link within 60 seconds
- **AC-1.2** Link expires after 1 hour
- **AC-1.3** Password must be ≥8 chars with 1 number
- **AC-1.4** Success page shows login CTA
```

Each one:
1. **Testable** — observable pass/fail, not "should be fast"
2. **Specific** — numbers, timeouts, states, not "works correctly"
3. **Independent** — doesn't require another AC to be true

Every test is tagged:
```typescript
it('sends reset email within 60s @AC-1.1', async () => { ... });
it('expires link after 1 hour @AC-1.2', async () => { ... });
```

This lets you grep:
```bash
grep -oE '@AC-[0-9]+\.[0-9]+' tests/ | sort -u
```
...and mechanically verify coverage. If BRD has 12 ACs and tests have 9 @AC tags → you're 75% covered. The rubric knows.

**Show on screen:** live grep on a real project showing 100% coverage, then delete a test and re-run — coverage drops.

### Out-of-scope block (explicit)

```markdown
### Out of scope (explicit)
- Magic-link (no password) login — future sprint
- Password strength meter UI — Story 3 owns this
- SSO integration — separate project
```

**Why:** without this, every PR creates scope creep. With it, rejections are citable.

### The 4 parts of every BRD entry

For each story:
1. Story (As a / I want / So that)
2. Acceptance Criteria (numbered)
3. Out of scope (explicit)
4. Known constraints (MENA? Arabic? offline? low-bandwidth?)

**Show on screen:** a real BRD from EO-MENA with 3 stories, each following this exact structure.

---

## How the 2 files work together — the handshake

At session start, Claude reads:

1. Your `CLAUDE.md` → knows the CHAIN (plan → code → score → ship)
2. Your project CLAUDE.md → knows THIS project's stack + ICP + rules
3. `.smorch/project.json` → knows deploy targets, thresholds
4. BRD → knows WHAT to build and HOW DONE IS DEFINED

Then `/smo-plan` uses ALL of them:
- Picks AC-N.N to address
- Applies project-specific checks (MENA? RTL? mobile?)
- Surfaces relevant lessons from `.claude/lessons.md`
- Drafts approach using the command chain from CLAUDE.md

If ANY of these 4 inputs is missing, Claude guesses — and guessing is where bugs enter.

**Pattern interrupt:** "This is why your 'just add X' prompts fail. You're not giving Claude the contract."

---

## The enforcement layer — one plugin, zero discipline required

Writing CLAUDE.md + BRD is step 1. Enforcing them PR after PR is step 2.

That's what a workflow plugin is for. Ours is `smorch-dev` (internal) and `eo-microsaas-dev` (students). Either enforces:

- `/smo-plan` → refuses to start without BRD
- `/smo-score` Engineering hat Q2 → caps at 6 if `@AC-N.N` coverage <90%
- `/smo-ship` → blocks merge if composite <92 (internal) / <90 (students)

**Show on screen:** real score report — Engineering hat dropped to 7 because of missing tags, then fixed after bridge-gaps.

---

## 5 common failure modes (each 20s to explain)

### 1. "CLAUDE.md is my journal"
Symptom: 400+ lines, includes personal philosophy.
Fix: split — journal stays in notes app. CLAUDE.md is OPERATING INSTRUCTIONS.

### 2. "BRD is one big wall of text"
Symptom: no numbered ACs, no out-of-scope, no user story.
Fix: refactor into the 4-part structure above. Yes, now. Before any code.

### 3. "Tests exist but not tagged"
Symptom: `describe('password reset')` but no `@AC-1.1` in test name.
Fix: rename tests to include the tag. 5-min task, unblocks traceability forever.

### 4. "Every project looks the same"
Symptom: project CLAUDE.md is a copy of another project's.
Fix: project CLAUDE.md should have 10+ lines UNIQUE to this project (ICP, stack quirks, deploy target). If it doesn't → you're not serious about the project yet.

### 5. "I update CLAUDE.md every session"
Symptom: Git history shows CLAUDE.md edited on every PR.
Fix: CLAUDE.md should be STABLE. New learnings go to `.claude/lessons.md`. Project-specific rules go to project CLAUDE.md. If CLAUDE.md changes weekly, you're using it as scratch space.

---

## Templates — steal these

**Provided in our repo** (`github.com/SMOrchestra-ai/smorch-dev`):

| Template | Location | Lines |
|----------|----------|:-----:|
| Global CLAUDE.md | `plugins/smorch-dev/templates/CLAUDE.md.internal.template` | ~120 |
| Project CLAUDE.md | Example at `CodingProjects/EO-MENA/CLAUDE.md` | ~60 |
| BRD | Example at `CodingProjects/EO-MENA/architecture/brd.md` | variable |
| `.smorch/project.json` | `CodingProjects/EO-MENA/.smorch/project.json` | ~30 |
| `.claude/lessons.md` | `plugins/smorch-dev/templates/lessons.md.template` | seeded empty |

Fork. Customize. Ship.

---

## Outro / CTA (last 60 seconds)

"Two files. CLAUDE.md. BRD. That's the framework. Boris Cherny, me, every team shipping real product — we all come back to these two. Everything else — plugins, scores, handovers, deploys — is downstream.

Links to my templates in the description. If you've got a CLAUDE.md that's 400 lines and a BRD that's 3 sentences, tag me when you cut it in half. I'll pick 3 and audit live next week."

**CTA chips:** "Watch the 10-Step Ultimate Setup video next" + "Subscribe for: 'Why Lana's 5-Dimension Handover Rubric Killed Our QA Bottleneck'."

---

## Assets to produce (for cowork)

### Slides (10-12 slides)
1. Hook (the 2-file framework title)
2. Why these 2 files (the 3-file context load)
3. CLAUDE.md — the 7 sections (table)
4. CLAUDE.md — the 4 anti-patterns
5. CLAUDE.md — 3 scope levels (global / project / overlay diagram)
6. CLAUDE.md — the 120-line rule
7. BRD — user story format
8. BRD — AC-N.N tagging contract (before/after)
9. BRD — out-of-scope block
10. How they work together (handshake diagram)
11. 5 common failure modes (single slide, 5 mini-boxes)
12. CTA + links

### Script structure
- Intro + hook (45s)
- Why these 2 files (75s)
- CLAUDE.md deep dive (4 min — 7 sections + anti-patterns + scope + 120-line rule)
- BRD deep dive (4 min — user story + AC-N.N + out-of-scope + 4 parts)
- Handshake (90s)
- Enforcement layer (60s)
- 5 failure modes (2 min — 20s each with visual)
- Outro + CTA (60s)
- **Total voice-over: ~14-16 min**

### Screenshots / B-roll needed
1. My actual `~/.claude/CLAUDE.md` scrolled (116 lines, one screen)
2. A real project `CLAUDE.md` (EO-MENA, 60 lines)
3. A real `.smorch/project.json`
4. A real BRD with Story 1 + AC-N.N + out-of-scope block
5. Live grep command showing @AC coverage check
6. `/smo-plan` in action reading the BRD + overlay
7. Score report with Engineering Q2 = 6 because of missing tags
8. Same after bridge-gaps → Engineering Q2 = 10
9. Split-screen: "bloated CLAUDE.md (400 lines)" vs "disciplined (116 lines)"
10. The 3-scope-level diagram

### Thumbnail concept
- Split thumbnail: left = "CHAOS" (random Claude prompts) right = "2 FILES"
- Big text: "2 FILES" in orange
- Small tag: "Boris's framework"
- Face: looking at camera, pointing at the 2-file stack

---

## Companion content opportunities

Once this video ships, these follow-ups are pre-staged:

| Next video | Focus |
|-----------|-------|
| "The Lessons.md Loop — How I Stopped Repeating Bugs" | Boris pillar #3 deep dive |
| "The 5-Hat Score Rubric — Ship 92 or Don't Ship" | Scoring + calibration |
| "The 5-Dimension Handover Rubric" | QA / Lana's workflow |
| "The Elegance Pause — Boris's Non-Negotiable Commit Check" | Pillar #5 |

Each reuses same assets + plugin. Content factory from one rollout.

---

## Recording checklist

- [ ] Pre-fork the "bloated vs disciplined" CLAUDE.md demo (live split-screen)
- [ ] Pre-record the `@AC` grep demo (15s loop)
- [ ] Pre-record `/smo-plan` reading the BRD (30s clip)
- [ ] Screenshot + animate the 3-scope-level diagram
- [ ] Mic test
- [ ] 4K export
- [ ] Arabic subtitle pass via smorch-gtm-engine:arabic-translator skill (MENA audience)
- [ ] Description includes: GitHub repo link, the 10-Steps companion video, template links

---

## Source material I pull from (host's reference)

- `~/.claude/CLAUDE.md` — live demo
- `CodingProjects/EO-MENA/CLAUDE.md` — project example
- `CodingProjects/EO-MENA/architecture/brd.md` — BRD example (if not present, use SSE)
- `CodingProjects/EO-MENA/.smorch/project.json` — overlay example
- `CodingProjects/smorch-dev/plugins/smorch-dev/skills/brd-traceability/SKILL.md` — the rubric the plugin uses
- `CodingProjects/smorch-dev/docs/GUIDE-NEW-PROJECT.md` — step 5 (BRD writing)
- `CodingProjects/smorch-dev/docs/PLUGIN-SKILLS-COMMANDS-GUIDE.md` — where these fit in the broader toolkit
- Boris Cherny's talks/posts (reference cue — quote "CLAUDE.md is ~100 lines" directly)

---

## The one-liner to open with

> "90% of 'Claude Code isn't working' problems are really 'my CLAUDE.md and BRD aren't configured' problems. Fix these 2 files and 90% of your bugs disappear before you write a single test."

Use this as your second-sentence hook after the visual cold-open.
