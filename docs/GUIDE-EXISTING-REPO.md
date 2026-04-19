# Guide — Working on an Existing Repo

**Audience:** Mamoun, Lana, new hires.
**Time:** ~5 minutes to first `/smo-plan` on an existing codebase.
**Prerequisites:** Plugins installed. Repo exists locally.

---

## 1. One-time: add `.smorch/` overlay to the repo

If the repo doesn't yet have `.smorch/`:

```bash
cd CodingProjects/{existing-project}
mkdir -p .smorch
cp $HOME/.claude/plugins/smorch-dev/templates/CLAUDE.md.internal.template .smorch/project.json.template
# Then write .smorch/project.json per template in EO-MENA or SSE
```

See `CodingProjects/EO-MENA/.smorch/project.json` for format. Commit via PR branch.

If overlay exists: skip, continue.

---

## 2. Start a session

```bash
cd CodingProjects/{project}
claude
```

Session auto-loads:
- `~/.claude/CLAUDE.md` (global)
- `{project}/CLAUDE.md` (project-specific)
- `.smorch/project.json` (plugin overlay)
- `.claude/lessons.md` (self-improvement loop)

First line you see in Claude: any existing lessons surface immediately.

---

## 3. Sync before you start (5 seconds)

```
/smo-health
```

Returns:
- Git state (local/remote match)
- Server health for your deploy targets
- Open PRs + review status
- Any drift detected recently

If anything red, triage before coding.

---

## 4. Pick the workflow

### (a) New feature

```
/smo-plan add {feature}

# Plugin reads BRD, finds AC-N.N, references lessons
# Approves plan → enters TDD

/smo-code
# Test-first loop per AC

/smo-score
# 5-hat composite. Goal: 92+

# If 85-91:
/smo-bridge-gaps

# If 92+:
/smo-handover
# Lana gets Telegram ping
```

### (b) Bug fix

```
/smo-triage {bug-description | error}

# Hypothesis → evidence → root cause → regression test → commit

# If post-mortem needed (production impact):
/smo-incident
```

### (c) Refactor / cleanup

```
/smo-plan refactor {area}
/smo-code
/smo-score
```

Same chain. Elegance pause is the key check — is this BETTER than what existed?

### (d) Ops-only change (config, deploy, server)

```
/smo-drift --target {host}   # confirm clean state first
# make change via PR
/smo-ship
/smo-deploy
```

Or for server hardening:
```
/smo-health --posture-only --target {host}
# Fix any 🔴 via security-hardener skill
```

---

## 5. End-of-day

```
git status                    # nothing uncommitted
git push origin {branch}      # everything on GitHub
```

**Never leave uncommitted work at end of day.** Enforced by git hooks (destructive-blocker warns on dirty state at exit).

---

## 6. End-of-sprint

```
/smo-retro
```

Aggregates scores + handovers + incidents across ALL projects. Surfaces cross-project patterns. Promotes lessons to `smorch-brain/canonical/lessons.md` if triggered across ≥3 projects.

---

## Common flows by role

### Mamoun (founder)
- Morning: `/smo-health` → scan Telegram for overnight alerts
- Daytime: primarily `/smo-plan` → `/smo-code` → `/smo-score` → `/smo-handover`
- End of day: quick `/smo-retro --days 1` if shipped to prod
- Friday: approve PRs (smorch-dist, eo-mena, others)

### Lana (half QA, half Dev)
- Morning: Telegram check for handover pings
- For each: `/smo-qa-handover-score` → if ≥80, `/smo-qa-run`
- Her own dev work: same chain as Mamoun (plan → code → score → handover → Mamoun scores HER handover)
- Week end: report via `/smo-retro`

### Future hire (post-onboarding)
- Follows Mamoun's flow initially, paired-review first 3 PRs
- Independent by Week 3 per SOP-17

---

## When the plugin feels heavy

If a PR is truly trivial (1-line typo in docs):

```
/smo-score --quick
# 2-min scan. Still requires 92+ but skips full rubric.
```

For emergency hotfix (SEV1):
```
/smo-plan hotfix {issue}  # brief plan
/smo-code                  # minimal change
/smo-score --quick         # 92+ still required, no bridge-gaps loop
/smo-ship --minor          # no QA gate for SEV1 (approved by Mamoun in Telegram)
/smo-deploy --force        # audit-logged
/smo-incident              # within 48h, per SOP-10
```

But: emergency hotfix path is the exception, NOT the default. If you're using it >1× per month, something's wrong upstream.

---

## When sync fails

If `sync-from-github.sh` errors in `~/.claude/sync.log`:
1. `cat ~/.claude/sync.log | tail -30` — see what failed
2. `/smo-drift --target $(hostname)` — diagnose
3. Manually: `cd ~/smorch-dev && git status && git pull origin main`
4. If conflicts: ask Mamoun (don't fight the sync)

---

## When a command doesn't resolve

1. `ls ~/.claude/plugins/` — is `smorch-dev` there?
2. If missing: `bash ~/Desktop/cowork-workspace/CodingProjects/smorch-dev/install/eng-desktop.sh`
3. If present but `/smo-plan` still not autocompleting: `claude` (restart session)
4. Persistent issue: file issue at `github.com/SMOrchestra-ai/smorch-dev/issues`

---

## Reference

- New project from scratch: see `GUIDE-NEW-PROJECT.md`
- QA workflow: see `GUIDE-QA-LANA.md`
- Command surface: SOP-14
- Cross-machine sync: SOP-15
