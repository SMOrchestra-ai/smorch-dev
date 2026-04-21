# 10 Steps to Set Up the Ultimate Claude Code from Scratch

**Video title draft:** "I turned Claude Code into a $500K engineering team (10 steps)"
**Alt title:** "The Ultimate Claude Code Setup — 10 steps no one talks about"
**Audience:** Founders + solo devs who ship real product (not hello-world).
**Duration target:** 15-22 min (each step = ~90s).
**Proof asset:** before/after screenshot — ad-hoc prompting vs `/smo-plan` → `/smo-deploy` in one flow.

---

## The hook (first 30 seconds)

"Claude Code out of the box is a $20/month toy. In 10 steps I'll turn it into a $500K engineering team that plans, codes, tests, scores itself, deploys, rolls back, and never ships a bug without a post-mortem. Every step I'm showing you is what we run at SMOrchestra today across 4 servers and 11 projects. Save this — you'll come back."

**B-roll:** terminal with `/smo` autocomplete dropping 18 commands. Split screen: left = default Claude, right = 18-command setup.

---

## Step 1 — Foundation: install the base tools

**What:** Node 22 + Bun + Claude Code CLI + git + gh.

**Why:** Without this, nothing else works. 5 min one-time.

**Command:**
```bash
# Mac
brew install node@22 bun gh git
npm install -g @anthropic-ai/claude-code
# Or single-line via our install script:
bash <(curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/eng-desktop.sh)
```

**Show on screen:** the install script output — each dependency landing green.

**Pitfall to call out:** using Node 20 — some plugins need 22.

---

## Step 2 — Global configuration: the 120-line CLAUDE.md

**What:** `~/.claude/CLAUDE.md` is your global "how I work" file. Most people skip it or bloat it.

**Why:** Boris Cherny (Anthropic's Claude Code team) says keep it ~100 lines. Mine is 116. If it's longer, you're putting project context in the wrong file.

**What goes in:**
- Who you are (3 lines)
- What you build (5 bullets)
- Your core thesis (1 line)
- Servers / infra (table)
- How you work (5 principles)
- Command chain you follow (1 paragraph)
- Non-negotiable gates (5 bullets)

**What DOESN'T go in:**
- Project tech stacks → project CLAUDE.md
- Detailed rules per project → `.smorch/project.json`
- History / rationale → SOPs

**Show on screen:** my trimmed `~/.claude/CLAUDE.md` — scroll through showing all fits on one page.

**Pitfall:** copying the Anthropic template and leaving it unchanged. The value is YOUR thesis + YOUR gates.

---

## Step 3 — Safety hooks: 6 of them

**What:** `~/.claude/settings.json` defines hooks that run automatically. Mine has 6.

**Why:** Without hooks, Claude Code runs any command you let it. With hooks, destructive commands get blocked, secrets get scrubbed, code gets formatted, context gets injected.

**The 6 hooks:**
1. **destructive-blocker** — blocks `rm -rf`, `git reset --hard`, etc. on important paths
2. **SQL-guard-v2** — blocks `DROP TABLE` / `TRUNCATE` without confirmation
3. **secret-scanner-v2** — scrubs secrets in tool output before they're written anywhere
4. **auto-formatter** — formats files after edit (Prettier/Black/gofmt per file type)
5. **SessionStart context** — injects `.claude/lessons.md` + git state at session start
6. **branch-protection-enforcer** — blocks commits from protected branches locally

**Show on screen:** the moment a hook blocks a destructive command — visual block message.

**Pitfall:** manually running dangerous commands to bypass hooks. If hook blocks, there's a reason.

---

## Step 4 — The 4 plugins that change everything

**What:** Plugins extend Claude Code. Don't install 30 — install the 4 that orchestrate everything.

**The 4:**
1. **gstack** (upstream, free) — engineering utilities
2. **superpowers** (upstream, free) — TDD, debugging, subagents
3. **Your workflow plugin** — I use `smorch-dev` (internal). Students use `eo-microsaas-dev`. You can fork either.
4. **Your ops plugin** — I use `smorch-ops` for deploy/rollback/drift/incidents.

Install all 4 in one command via the install profile (shown in Step 1).

**Show on screen:** `ls ~/.claude/plugins/` after install — the 4 plugin folders.

**What each does in 1 line:**
- gstack: `/review`, `/ship`, `/qa` primitives (battle-tested)
- superpowers: `test-driven-development`, `systematic-debugging`, `subagent-driven-development`
- smorch-dev: `/smo-plan → /smo-code → /smo-score → /smo-handover → /smo-ship` (your workflow)
- smorch-ops: `/smo-deploy → /smo-rollback → /smo-drift → /smo-incident` (your ops)

**Pitfall:** building your own plugin from scratch before using gstack + superpowers for a month. They're 90% of what you need.

---

## Step 5 — Project structure (the overlay pattern)

**What:** Every project gets a `.smorch/` folder alongside its `CLAUDE.md`. The plugin reads the overlay at session start.

**Why:** Inverted convention. Plugin stays project-agnostic. New projects = no plugin PR.

**The scaffold (8 folders):**
```
my-project/
  CLAUDE.md                  # 40-60 lines, project-specific
  .smorch/project.json       # {"project":"...","mena":true,"deploy":{...}}
  docs/
    qa-scores/               # your 5-hat reports
    handovers/               # dev → QA briefs
    qa/                      # QA execution reports
    incidents/               # post-mortems
    deploys/                 # deploy logs
    retros/                  # sprint retros
  architecture/brd.md        # BRD with AC-N.N tags
  .claude/lessons.md         # self-improvement loop
  src/ tests/                # standard
  .env.example              # placeholders only
```

**Show on screen:** `tree` output of a real project (EO-MENA).

**Pitfall:** skipping BRD + tests + docs folders "because it's small." Small projects grow. The structure is the discipline.

---

## Step 6 — The self-improvement loop (the biggest lever)

**What:** Per-project `.claude/lessons.md`. Every correction, every bug, every "I should have known" gets captured here as a rule tied to a rubric question.

**Why:** This is Boris pillar #3 — the single biggest quality multiplier over time. Most teams skip it. That's why they hit the same bugs every month.

**Format:**
```markdown
### L-001 — Don't self-score immediately after building
- Captured: 2026-04-19
- Trigger: scored own PR 95, reality was 60
- Rule: run manual smoke test BEFORE scoring
- Check: QA hat Q1 (happy path manually tested)
- Last triggered: 2026-04-19
```

**Auto-load:** SessionStart hook `cat .claude/lessons.md` at every session. Claude reads it before any work.

**Show on screen:** a real lessons.md with 5-10 entries.

**Pitfall:** writing "be more careful" as a lesson. Must be CHECKABLE and tied to a rubric question.

---

## Step 7 — The 5-hat quality rubric

**What:** Every PR scored 1-10 on 5 dimensions: Product, Architecture, Engineering, QA, UX. Composite = sum × 2. Gate 90+ (students) or 92+ (internal) to ship.

**Why:** "Looks good" is not a gate. Numbers are. This rubric removes emotional decision-making.

**Internal calibration (harder bar):**
- Ship gate: 92
- Minimum hat: 8.5
- Engineering hat has 3 bonus questions (UFW / CVE / secrets rotation)
- Calibration examples are REAL SMO PRs

**Show on screen:** a real score report from `docs/qa-scores/` — with each hat's rationale.

**Pitfall:** inflation. If you give yourself 95 and Lana gives the handover 70, you're lying to yourself. Honest scoring is the whole thing. I call this out as "L-001" in my lessons.

---

## Step 8 — Handover discipline (dev → QA)

**What:** Every PR generates a brief via `/smo-handover`. QA scores the BRIEF on 5 dimensions BEFORE testing. ≥80 accepts, 60-79 sends back, <60 auto-rejects.

**Why:** Without this, QA silently works around weak handovers and quality regresses. With this, weak handovers get REJECTED — dev learns fast.

**The 5 dimensions:**
1. Completeness (BRD + PR + staging URLs)
2. Testability (happy/empty/error/edge scenarios)
3. Repro-ability (env vars + seed data + test accounts)
4. Risk disclosure (known issues + untested areas + nearby code)
5. Rollback readiness (command + SLA + reversibility)

**Show on screen:** a real handover brief → Lana's score report → decision output.

**Linear integration:** every decision maps to a Linear status (In QA / Needs clarification / Ready to ship / Blocked).

**Pitfall:** accepting 75-score handovers "to unblock." Kills the entire system.

---

## Step 9 — Cross-machine sync

**What:** Single source of truth in GitHub. All machines (desktops + servers) auto-sync within 60s of push.

**Three tiers:**
1. **GitHub webhook / Actions** — on push, SSH to all servers, trigger sync
2. **30-min cron** — fallback pull on each machine
3. **Drift detection** — hourly config drift + 6h skill drift → Telegram alert

**Secrets to add (one-time):**
- `SMO_DEPLOY_KEY` (SSH private)
- `TS_OAUTH_CLIENT_ID` + `TS_OAUTH_SECRET` (Tailscale CI access)
- `TELEGRAM_BOT_TOKEN` (alerts)

**Show on screen:** GitHub Actions run → 4 servers synced in 40 seconds + green checkmark.

**Pitfall:** editing files directly on servers. Always local → GitHub → server pull. Otherwise drift fires daily.

---

## Step 10 — Production ops (deploy, rollback, incidents, secrets)

**What:** Four ops commands that take you from "it works locally" to "it runs in production with discipline."

**The 4:**
- `/smo-deploy` — SSH + pm2 reload + health check + drift check pre/post
- `/smo-rollback` — revert deploy in <90s, handles DB migration reversibility
- `/smo-incident` — SEV1-4 post-mortem generator (SOP-10 structure)
- `/smo-secrets` — 90-day rotation tracking across all servers

**The security baseline (from post-malware lessons):**
- UFW enabled, minimal allowlist
- fail2ban on sshd
- SSH key-only, no password auth
- Unattended security upgrades

**Show on screen:** `/smo-health` all-green across 4 servers → `/smo-deploy` logs → `/smo-rollback` drill within SLA.

**Pitfall:** deploying without a rollback plan. If you don't know your rollback command + SLA, don't deploy.

---

## Outro / CTA (last 60 seconds)

"That's the ultimate Claude Code setup. Ten steps. Takes about 2 hours one-time. Saves you hundreds of hours over a year. The repo with all the code is in the description — fork it, customize, ship better software."

**Hard CTA:** "If you want me to review your setup, drop your GitHub in the comments. I'll pick 3 and audit live in next week's video."

**Soft CTA:** "Subscribe for the next one: 'How Lana — a half-QA half-Dev — 3x'd my quality gate with ONE rubric.'"

---

## Assets to produce (for cowork)

### Slides (12-15 slides)
1. Hook ("Claude Code is a $20 toy until...")
2. The 10 steps at-a-glance (1 slide, all 10 as icons)
3-12. One slide per step (title + 1 quote + 1 key screenshot area)
13. The gates summary (non-negotiables)
14. Before/after split (ad-hoc vs structured)
15. CTA slide (repo URL + subscribe)

### Script
- Voice-over: 18-22 min duration
- B-roll opportunities per step (see "show on screen" notes above)
- One pattern-interrupt every 2 min (screen flash, zoom, question to audience)

### Screenshots needed
- `/smo` autocomplete showing 18 commands
- 120-line `~/.claude/CLAUDE.md` scroll
- A destructive-blocker hook firing
- `ls ~/.claude/plugins/` showing 4 plugins
- `tree` of a real project folder
- A real `.claude/lessons.md`
- A real 5-hat score report (94 composite example)
- A handover brief + score report
- GitHub Actions run showing 4 servers synced
- `/smo-health` green output

### Thumbnail concept
Split thumbnail:
- Left: "BEFORE — chaos" terminal showing random Claude prompting
- Right: "AFTER — 18 commands" showing `/smo` autocomplete
- Big text: "10 STEPS" in orange
- Small tag: "real setup, no theory"

---

## Source material for the host (me)

- This doc = script skeleton
- `PLUGIN-SKILLS-COMMANDS-GUIDE.md` = full reference if needed mid-recording
- `GUIDE-NEW-PROJECT.md` = Step 5 deep dive
- `GUIDE-EXISTING-REPO.md` = Step 6-7 deep dive
- `GUIDE-QA-LANA.md` = Step 8 deep dive
- `GITHUB-ACTIONS-SETUP.md` = Step 9 deep dive
- SOP-14/15/16/17 = backup for questions in Q&A

---

## Recording checklist

- [ ] Clear Claude Code session cache so demos are fresh
- [ ] Pre-scaffold a dummy project to show in step 5
- [ ] Pre-populate `.claude/lessons.md` with 5 realistic entries for step 6
- [ ] Pre-record a `/smo-deploy` run so step 10 demo is <15s
- [ ] B-roll: screen recording of the `/smo` autocomplete (15s loop)
- [ ] Mic test in Dubai studio
- [ ] 4K export for YouTube
- [ ] Arabic subtitle pass (MENA audience) via smorch-gtm-engine:arabic-translator skill
