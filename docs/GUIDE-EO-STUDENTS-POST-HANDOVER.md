# EO Students — What Happens AFTER Code Handover (Phase 5)

**Audience:** EO MicroSaaS students who just finished EO-Brain phases 0-5 in Cowork.
**You now have:** A complete spec (5 folders of Phase 0-4 artifacts + `5-CodeHandover/` bundle).
**You DO NOT have yet:** A running product. This guide takes you from spec → shipped MVP.

**Time from here to first deployed feature:** 2-4 hours first time, 30-60 min every subsequent feature.

---

## Quick map

```
DONE (Cowork / EO-Brain)                    NEXT (Claude Code / eo-microsaas-dev)
──────────────────────                      ─────────────────────────────────────
Phase 0 — Scorecards                →   Phase 5.1 — Install Claude Code + plugin
Phase 1 — ProjectBrain              →   Phase 5.2 — Scaffold project from handover
Phase 2 — GTM assets                →   Phase 5.3 — First feature (/eo-plan → /eo-ship)
Phase 3 — Newskills                 →   Phase 5.4 — Deploy to Contabo
Phase 4 — Architecture (BRD)        →   Phase 5.5 — Weekly retro → next sprint
Phase 5 — CodeHandover (spec done)  →   Phase 5.6 — Launch + distribute
```

---

## Step 1 — Install the Claude Code toolkit (15 min, once)

On your Mac/Linux:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/smorchestraai-code/eo-microsaas-training/main/install.sh)
```

On Windows (PowerShell as Admin):
```powershell
iwr -useb https://raw.githubusercontent.com/smorchestraai-code/eo-microsaas-training/main/install.sh | iex
```
(or use WSL and run the bash command above)

What it installs:
- Claude Code CLI + Node 22 + Bun + git + gh
- gstack + superpowers plugins (zero-maintenance upstream)
- **eo-microsaas-dev plugin** (8 commands + 7 skills — your workflow)
- Global `~/.claude/CLAUDE.md` student template

Verify:
```bash
claude plugin list | grep eo-microsaas-dev
# Expected: eo-microsaas-dev@eo-microsaas-training v1.0.0
```

---

## Step 2 — Create your code repo (5 min)

Open a Claude Code session in your EO-Brain folder:
```bash
cd ~/Desktop/EO-Brain  # wherever your EO-Brain lives
claude
```

Then **paste this bootstrap prompt**:

```
I just finished EO-Brain phases 0-4 in Cowork. My spec is in:
- 1-ProjectBrain/ (ICP, positioning, voice)
- 2-GTM/output/ (GTM assets)
- 4-Architecture/ (tech-stack-decision.md, brd.md, db-architecture.md, mcp-integration-plan.md)
- 5-CodeHandover/artifacts/ (product-demo.jsx, onboarding-flow.jsx, admin-dashboard.jsx)

Please run the `handover-bridge` skill from the eo-microsaas-dev plugin to:
1. Create a new Claude Code project at ~/Desktop/{project-name}/
2. Copy the BRD + tech stack + UX artifacts into the proper locations
3. Generate placeholder tests tagged @AC-N.N from my BRD
4. Seed .claude/lessons.md and install the SessionStart hook
5. Create the first commit

After the bridge is complete, I'll run /eo-plan for my first feature.

My tech stack (from 4-Architecture/tech-stack-decision.md): [LET CLAUDE READ IT]
My ICP (from 1-ProjectBrain/): [LET CLAUDE READ IT]
My language: [ar / en / bilingual]

Ship gate: composite score ≥ 90 before any merge.
```

Claude will:
- Scaffold a new repo at `~/Desktop/{project-name}/`
- Copy BRD, UX artifacts, project-brain context
- Generate placeholder tests for every `AC-N.N` in your BRD
- Initialize git + create first commit

---

## Step 3 — Create GitHub repo (2 min)

```bash
cd ~/Desktop/{project-name}
gh repo create {project-name} --public --source=. --remote=origin --push
```

Now your spec is on GitHub. Every future PR goes through this repo.

---

## Step 4 — Your first feature (30-60 min)

Still in Claude Code, run:

```
/eo-plan add user signup flow
```

What happens:
1. Plugin reads `architecture/brd.md` → finds Story 1 (signup) + AC-1.1 through AC-1.N
2. Reads `project-brain/icp.md` (context) + `.claude/lessons.md` (empty, ready to grow)
3. If MENA ICP → flags that `arabic-rtl-checker` + `mena-mobile-check` will apply at `/eo-score` time
4. Drafts approach, asks for approval
5. On approval → exits plan mode, TDD begins

Then:
```
/eo-code
```

Writes a failing test first (tagged `@AC-1.1`), then minimal code to pass, then refactors. Runs through each AC in the story.

Then:
```
/eo-score
```

5-hat rubric. Each hat 1-10:
- **Product** — matches BRD + ICP, no buzzwords
- **Architecture** — clean modules, explainable data flow
- **Engineering** — tests + types + error handling + elegance pause
- **QA** — happy/empty/error/edge all tested + evidence
- **UX** — mobile 375px + Arabic RTL + loading states + axe clean

**Composite = sum × 2** (10-100). **Gate: 90+ to ship.**

If 90+: run `/eo-ship` to create PR.
If 80-89: run `/eo-bridge-gaps` to fix weakest hat.
If <80: back to `/eo-plan`, something foundational is off.

---

## Step 5 — Ship + deploy the first feature

```
/eo-ship
```

Creates a PR on GitHub with:
- Score report inline
- BRD AC coverage list
- Elegance pause block from commit
- Links to your QA notes

Merge the PR.

Deploy (if you're past MVP scaffolding):
```bash
# Your tech-stack-decision.md defines deployment. Default: Contabo + Coolify
ssh root@your-contabo-vps "cd /opt/apps/{project-name} && git pull && npm ci && npm run build && pm2 reload ecosystem.config.js"
```

Verify:
```bash
curl https://{your-domain}/api/health
# Expected: {"status":"ok","commit":"..."}
```

---

## Step 6 — Every bug: /eo-debug

Something breaks? Don't guess. Run:

```
/eo-debug {description} {error} {reproduction-steps}
```

Plugin:
1. Forms 3 hypotheses
2. Gathers evidence (git blame, recent PRs, logs)
3. Confirms root cause
4. Writes a minimal fix
5. Adds a regression test tagged `@bug-NNN`
6. Appends to `.claude/lessons.md` if the pattern is likely to recur

Never skip the regression test. That's how you stop the same bug repeating.

---

## Step 7 — Every week: /eo-retro

End of sprint (Sunday evening, Dubai time):

```
/eo-retro
```

Plugin aggregates:
- Scores trend per hat (improving? declining?)
- Lessons triggered this week
- Stale lessons to archive (>90 days untriggered)
- Proposed new lessons from patterns

Write the retro to `docs/retros/YYYY-MM-DD.md`. Next sprint focuses on the weakest hat.

---

## Step 8 — Ongoing: the self-improvement loop

`.claude/lessons.md` is your compounding edge. Every time:
- You correct Claude on something
- A bug surfaces
- A score dropped because of a pattern

→ **Add a lesson**. Format:

```markdown
### L-00X — Short rule title (<10 words)
- Captured: YYYY-MM-DD
- Trigger: {what happened, specific}
- Rule: {single imperative sentence}
- Check: {which hat question enforces this}
- Last triggered: YYYY-MM-DD
```

SessionStart hook loads this file at every new Claude session. Your project gets smarter every week.

---

## What success looks like at month 1

- [ ] MVP deployed with 5-7 features from BRD Stories 1-7
- [ ] Avg composite score > 85 across all shipped PRs
- [ ] `.claude/lessons.md` has 8-15 entries
- [ ] First real user testing the live product
- [ ] Triple Assessment score shown on any product listing
- [ ] At least 1 sprint retro documented

---

## Common mistakes (avoid these)

| Mistake | Fix |
|---------|-----|
| "Let me just code without /eo-plan" | Plugin catches this — /eo-code refuses without plan |
| Tests without `@AC-N.N` tags | Engineering Q2 caps at 6. Re-tag then re-score. |
| Scoring yourself 95 when reality is 70 | L-001 lesson — honest scoring = honest learning |
| Skipping the elegance pause on a new dep | Engineering Q5 caps at 7. Add bundle comment in PR. |
| MENA product, not testing Arabic | UX hat caps at 6. Test RTL + Cairo/Tajawal fonts every PR. |
| Not adding lessons | No compounding. Same bugs repeat. |
| Shipping at 82 because "close enough" | You're breaking the gate. Bridge the gaps. |

---

## When you're stuck

1. **Read `.claude/lessons.md`** — maybe you captured this before
2. **Read `architecture/brd.md`** — maybe the AC is ambiguous, clarify in BRD first
3. **Run `/eo-debug`** with specific error output
4. **Ask in the EO Discord / Slack** (or WhatsApp group for MENA students)

---

## The 8 commands — daily reference

| Command | When |
|---------|------|
| `/eo-plan` | Before writing code for any feature |
| `/eo-code` | After plan approved — TDD loop |
| `/eo-review` | Self-review before /eo-score |
| `/eo-score` | Full 5-hat rubric. Gate 90+. |
| `/eo-bridge-gaps` | Score 80-89 → fix lowest hat |
| `/eo-ship` | 90+ → create PR |
| `/eo-debug` | Anytime a bug surfaces |
| `/eo-retro` | End of sprint (weekly) |

---

## References

- **Your spec:** `EO-Brain/1-ProjectBrain/` + `4-Architecture/` + `5-CodeHandover/`
- **Your plugin:** `~/.claude/plugins/cache/eo-microsaas-training/eo-microsaas-dev/1.0.0/`
- **Lessons source of truth:** `{project}/.claude/lessons.md`
- **Score history:** `{project}/docs/qa-scores/trend.csv`
- **Install script:** `github.com/smorchestraai-code/eo-microsaas-training`

---

## The single principle

**Don't prompt harder. Configure better.** Your BRD is your contract, your lessons.md is your memory, your 5-hat rubric is your quality gate. Use them every feature, every bug, every sprint. Over 3 months, you'll ship more quality than 90% of solo founders who "just code."

From spec → shipped MVP. That's Phase 5. Go.
