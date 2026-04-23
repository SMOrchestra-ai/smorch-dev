# Guide 03 — Customize Dev Plugin per Project

## 0. Session bootstrap

```bash
/smorch-dev-start
```

Required before any plugin-selection work. Layer 1 verifies BOTH `smorch-dev` AND any custom plugin declared by `.smorch/project.json:dev_plugin` are installed. Layer 4 verifies CLAUDE.md plugin-overlay declaration matches.

## The problem

Default dev workflow = `smorch-dev` plugin (/smo-* commands, 92+ gate, MENA checks).

**Not every project uses this.** Examples:
- EO MicroSaaS student demo → uses `eo-microsaas-dev` plugin (/eo-* commands, 90+ gate, Arabic-first)
- External client engagement → uses their plugin conventions
- Research spike / one-off → may use no plugin at all

## The rule (enforced by SOP-33)

Plugin selection is declared in **exactly one place**: `{repo}/.smorch/project.json` field `dev_plugin`. Everything else flows from this.

```json
{
  "project": "eo-student-{name}",
  "dev_plugin": "eo-microsaas-dev",
  "plugin_marketplace": "smorchestraai-code/eo-microsaas-training",
  ...
}
```

Valid values for `dev_plugin`:
- `smorch-dev` (default — SMO internal team, 92+ gate)
- `eo-microsaas-dev` (EO students, 90+ gate, `/eo-*` commands)
- `none` (research spike — no gates, no plugin)
- `{custom-plugin-id}` (for client engagements; must be registered in `smorch-brain/canonical/plugin-registry.md`)

## How it's enforced

1. **`/smorch-dev-start` Layer 3** reads `.smorch/project.json:dev_plugin` and verifies the declared plugin is installed in `~/.claude/plugins/`. Mismatch = RED (blocker). This is the earliest gate — before any `/smo-*` or `/eo-*` command can run this session.
2. **Pre-commit hook** validates `.smorch/project.json` against schema. `dev_plugin` field required for any repo with `status-production` or `status-beta`.
3. **`/smo-*` commands** check `dev_plugin` field on invocation — if value is not `smorch-dev`, they refuse and print: "This project uses {plugin}. Run `/{eo|custom}-{command}` instead."
4. **CLAUDE.md line 1** must state which plugin is active (copy-paste format below). `/smorch-dev-start` Layer 4 scores CLAUDE.md completeness — plugin overlay declaration is a required anchor.
5. **`/smo-drift --desktop`** flags any local clone whose `~/.claude/plugins/` doesn't include the plugin declared in `.smorch/project.json` (secondary gate, periodic).

## CLAUDE.md top-of-file pattern (enforced)

```markdown
# {Project Name}

## Plugin overlay
This project uses the **{plugin-id}** plugin (NOT smorch-dev).
Commands: /{eo|custom}-plan, /{eo|custom}-code, /{eo|custom}-score, ...
Ship gate: {90 for eo | 92 for smo | N/A for spike}
Marketplace: {plugin marketplace source}
```

If this block is missing or contradicts `.smorch/project.json`, pre-commit hook rejects.

## Setting up a student demo with eo-microsaas-dev

### 1. Install the plugin on student's machine

```bash
claude plugin marketplace add smorchestraai-code/eo-microsaas-training
claude plugin install eo-microsaas-dev@eo-microsaas-training
```

Verify:
```bash
claude plugin list | grep eo-microsaas-dev
```

### 2. Student's CLAUDE.md (project-scope)

```markdown
# {Student's Project}

## Plugin overlay
This project uses the **eo-microsaas-dev** plugin.
Commands: /eo-plan, /eo-code, /eo-score, /eo-review, /eo-ship, /eo-debug, /eo-bridge-gaps, /eo-retro
Ship gate: 90+ composite, no hat below 8.0 (relaxed vs SMO internal 92+)
Marketplace: smorchestraai-code/eo-microsaas-training

## Stack
- ...
```

### 3. Student's `.smorch/project.json`

```json
{
  "project": "student-demo-{name}",
  "dev_plugin": "eo-microsaas-dev",
  "plugin_marketplace": "smorchestraai-code/eo-microsaas-training",
  "qa": {
    "composite_floor": 90,
    "min_critical_hat": 8.0,
    "min_supporting_hat": 6.5
  },
  "deploy": { ... }
}
```

### 4. Validate

```bash
cd {student-project}
/eo-guide    # EO plugin's context-aware helper — proves plugin is active
```

## Where skills vs plugins live

| Kind | Home | Who uses |
|---|---|---|
| **DEV-layer plugin commands** (`/smo-*`, `/eo-*`) | `~/.claude/plugins/{plugin-id}/commands/` | Engineer while coding |
| **DEV-layer skills** (test-driven-development, systematic-debugging) | `~/.claude/plugins/{plugin-id}/skills/` OR `smorch-brain/skills/dev-meta/` | Engineer invokes directly or auto-triggered by commands |
| **APP-layer runtime skills** (injected into deployed app's Claude API calls) | `{repo}/skills/` + declared in `{repo}/skills/runtime-skills.json` | Deployed app at runtime — users never see a command, it happens inside the app's own AI calls |
| **Templates** (content templates, asset blueprints) | `smorch-brain/skills/{category}/templates/` | Called by app-layer or dev-layer skills |
| **Context files** (project-brain, brand voice, ICP) | `{repo}/project-brain/` | Loaded into prompt by dev-layer commands OR bundled into app-layer skills |

## Do NOT put DEV-layer skills in `{repo}/skills/`

`{repo}/skills/` is for **runtime skills the deployed app injects into its own Claude API calls** (APP-layer per ADR-004). Dev-layer skills live in the plugin or in smorch-brain.

Common mistake: copying smorch-dev's scoring skill into a repo's `skills/` dir. Don't. It bloats the deployed app bundle. Dev skills live in plugins; they travel with the engineer, not the app.

## When to write a new plugin vs extend smorch-dev

- **Extend smorch-dev**: adding a new `/smo-*` command or skill that helps SMO internal team dev work. PR to `SMOrchestra-ai/smorch-dev`.
- **New plugin**: different audience (students, external clients, different gate thresholds). PR new plugin to appropriate repo (`smorchestraai-code` for distributed, `SMOrchestra-ai` for internal).

## Migration — changing an existing repo from smorch-dev to another plugin

1. Update `.smorch/project.json`: `dev_plugin` field
2. Rewrite CLAUDE.md line 1 block to match new plugin
3. Update `docs/` references from `/smo-*` to `/{new}-*` commands
4. Commit + push
5. `/smo-drift --desktop` will auto-refresh the plugin check next run

## Enforcement details

See `SOP-33 Plugin-Customization-Per-Project` (created in this phase) for the full enforcement script.

Pre-commit hook at `smorch-dev/scripts/hooks/validate-plugin-overlay.sh`:

```bash
#!/bin/bash
# Called from .git/hooks/pre-commit
[ ! -f .smorch/project.json ] && { echo "ERROR: .smorch/project.json missing"; exit 1; }
PLUGIN=$(jq -r .dev_plugin .smorch/project.json)
[ "$PLUGIN" = "null" ] && { echo "ERROR: dev_plugin not declared in .smorch/project.json"; exit 1; }
grep -q "This project uses the \*\*$PLUGIN\*\* plugin" CLAUDE.md || {
  echo "ERROR: CLAUDE.md missing plugin declaration matching .smorch (should state: 'This project uses the **$PLUGIN** plugin')"
  exit 1
}
```
