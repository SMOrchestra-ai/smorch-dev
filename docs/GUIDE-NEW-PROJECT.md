# Guide — Starting a New Project

**Audience:** Mamoun, Lana, new hires.
**Time:** ~15 minutes from empty folder to first `/smo-plan`.
**Prerequisites:** `smorch-dev` + `smorch-ops` installed (run `install/eng-desktop.sh` if not).

---

## 1. Create the repo

```bash
# Inside CodingProjects/
cd ~/Desktop/cowork-workspace/CodingProjects

# Create GitHub repo + local clone in one step
gh repo create SMOrchestra-ai/{project-name} --public --clone --description "{one-line description}"
cd {project-name}
```

Branch: `main` protected. Work in `dev` or `feat/*`.

```bash
git checkout -b dev
git push -u origin dev
```

---

## 2. Scaffold the structure (mandatory)

```
{project-name}/
  CLAUDE.md                  # project context (40-60 lines)
  .smorch/                   # plugin overlay
    project.json             # identity + stack + deploy + scoring
    README.md                # what overlay does
  docs/                      # EVERYTHING non-code
    qa-scores/               # /smo-score reports
    handovers/               # /smo-handover briefs
    qa/                      # /smo-qa-run reports
    incidents/               # /smo-incident post-mortems
    deploys/                 # deploy logs
    retros/                  # /smo-retro outputs
    ux-reference/            # (optional) HTML artifacts from EO-Brain Phase 5
  src/                       # application code
  tests/                     # @AC-N.N tagged tests
  .claude/                   # session-scoped (gitignored except settings.json)
    lessons.md               # seeded empty, accrues
    settings.json            # SessionStart hook
  architecture/
    brd.md                   # Business Requirements Doc with AC-N.N tags
  ecosystem.config.js        # PM2 config if deploys to a server
  .env.example               # placeholder vars
  .gitignore                 # exclude .env.local, node_modules/, .next/, docs/secrets/
  package.json
  README.md
```

**Quick scaffold:**

```bash
mkdir -p .smorch docs/{qa-scores,handovers,qa,incidents,deploys,retros,ux-reference} \
         architecture tests src .claude

# Copy templates from smorch-dev plugin
PLUGIN=$HOME/.claude/plugins/smorch-dev
cp $PLUGIN/templates/CLAUDE.md.internal.template CLAUDE.md
cp $PLUGIN/templates/lessons.md.template .claude/lessons.md
cp $PLUGIN/templates/settings.json.template .claude/settings.json
cp $PLUGIN/templates/trend.csv docs/qa-scores/trend.csv
echo "No lessons yet." > .claude/lessons.md
```

Then customize `CLAUDE.md` and `.smorch/project.json` — see step 3.

---

## 3. Write `.smorch/project.json` (required)

```json
{
  "project": "{project-name}",
  "display_name": "{Human-Readable Name}",
  "locale": "ar-MENA",
  "qa": {
    "rollback_drill": "required"
  },
  "stack": "nextjs-14 + supabase + claude + ghl",
  "language_primary": "english",
  "language_secondary": "arabic",
  "rtl": true,
  "currencies": ["AED", "SAR"],
  "weekend": ["friday", "saturday"],
  "deploy": {
    "staging": {
      "host": "smo-dev",
      "tailscale_ip": "100.83.242.99",
      "path": "/root/{project-name}",
      "pm2_name": "{project-name}-staging",
      "branch": "dev",
      "health_url": "https://{subdomain}-staging.smorchestra.com/api/health",
      "rollback_sla_seconds": 120,
      "migration_reversibility": "manual"
    },
    "production": {
      "host": "eo-prod | smo-prod",
      "tailscale_ip": "100.89.148.62 | 100.108.44.127",
      "path": "/opt/apps/{project-name}",
      "pm2_name": "{project-name}",
      "branch": "main",
      "health_url": "https://{domain}/api/health",
      "rollback_sla_seconds": 90,
      "migration_reversibility": "auto"
    }
  },
  "cost_tracking": {
    "claude_multiplier_threshold": 2.0,
    "bundle_size_kb_threshold": 50
  }
}
```

Copy from `CodingProjects/EO-MENA/.smorch/project.json` and customize.

---

## 4. Write `CLAUDE.md` (~50 lines)

Use template at `smorch-dev/plugins/smorch-dev/templates/CLAUDE.md.internal.template`. Fill in:
- Project name + one-line description
- ICP (who the user is)
- Tech stack (concrete libraries, not "modern JS")
- Design tokens (colors, fonts)
- Env vars needed (list `.env.example` keys)
- Deploy target + command
- Unique rules (e.g., "All Stripe webhooks must use idempotency key")

Don't copy global rules — they're in `~/.claude/CLAUDE.md`. Only project-specific content.

---

## 5. Write `architecture/brd.md` (mandatory before any code)

```markdown
# {Project} — Business Requirements

## Story 1: {verb-led title}

**As a** {role}
**I want to** {capability}
**So that** {outcome}

### Acceptance Criteria
- **AC-1.1** {testable, specific, numbered}
- **AC-1.2** {testable, specific}
- ...

### Out of scope (explicit)
- {what we are NOT building}
```

**Every AC has a test.** Tests tagged `@AC-N.N`. This is enforced by `smorch-dev/skills/brd-traceability`.

---

## 6. Initial commit + push

```bash
git add .
git commit -m "feat: scaffold {project-name} with smorch-dev overlay

- CLAUDE.md + .smorch/ project overlay
- docs/ + architecture/ + tests/ structure
- BRD seeded with Story 1 and AC-1.N tags
- .claude/lessons.md ready to accrue
"
git push origin dev
```

Open PR to main when first feature is ready to ship.

---

## 7. Register in the team registry

Add a row to `smorch-brain/canonical/project-registry.md` (single source of truth):

```markdown
| {project-name} | SMOrchestra-ai/{repo-name} | dev | {server} | /opt/apps/{name} | {pm2_name} |
```

Commit + push smorch-brain. Drift detection cron will see the new project within 6h.

---

## 8. First feature

```bash
claude  # start session
```

In session:
```
/smo-plan add email-draft endpoint for signal engine
```

That's it. Plugin reads BRD, reads lessons, proposes plan, waits for approval. Standard chain from there:

```
/smo-plan → /smo-code → /smo-score → /smo-bridge-gaps (if 85-91) → /smo-handover → /smo-qa-handover-score (Lana) → /smo-qa-run (Lana) → /smo-ship → /smo-deploy
```

Unsure what to run next mid-flow? `/smo-dev-guide next` reads live state and tells you.

---

## Common mistakes

- **Skipping `.smorch/project.json`** → plugin can't determine deploy target, `/smo-deploy` fails
- **BRD without `AC-N.N` tags** → `brd-traceability` skill caps Engineering Q2 at 6
- **CLAUDE.md > 80 lines** → pull non-project-specific content out
- **Creating `smorch-brain` entry without PR** → canonical diverges, drift alert fires
- **No `.env.example`** → engineering Q7 caps at 6, secrets Q11 flagged

---

## What NOT to do

- Don't clone from a template that doesn't have `.smorch/` — it'll miss the plugin
- Don't skip BRD "because the feature is small" — skill enforces
- Don't commit `.env.local`, `node_modules/`, `.next/`, `docs/secrets/`
- Don't initialize git inside another git repo (home dir, CodingProjects/) — `.git` must be at project root

---

## References

- SOP-14 Plugin Workflow
- SOP-17 Hire Onboarding
- Template: `smorch-dev/plugins/smorch-dev/templates/CLAUDE.md.internal.template`
- Example: `CodingProjects/EO-MENA/.smorch/project.json`
