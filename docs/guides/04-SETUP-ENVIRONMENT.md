# Guide 04 — Set up a new machine (Engineer or QA)

## After install: always verify with `/smorch-dev-start`

Every install script below ends with the machine ready — but "ready" is verified by one command:

```bash
/smorch-dev-start
```

It runs the 4-layer gate (machine tools + plugins + global config · repo-workspace context · project Boris discipline · input inventory + quality scoring) with GREEN/YELLOW/RED exit. This replaces the clunky manual "Verification checklist" table at the end of this guide — run `/smorch-dev-start` instead and fix whatever's RED. Re-run until GREEN. Full layer explainer: `/smo-dev-guide start`.

Installer sets `~/.sync-profile` to the right role (`eng-desktop` / `qa-machine` / `dev-server` / `prod-server`) so dev-start auto-detects without prompting.

---

## Engineer Desktop (Mac/Linux)

### One-liner install

```bash
curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/eng-desktop.sh | bash
```

### What the script does (read before piping to bash)

1. **Prereqs** — verify/install: git, gh CLI, node 20+ LTS, python 3.11+, docker, Tailscale
2. **Auth prompts** — `gh auth login`, `tailscale up`, `claude auth login`
3. **Clone canonical tree** to `~/Desktop/repo-workspace/{smo,eo,shared,external-forks}/` via `gh repo clone` (17 active repos)
4. **Checkout `dev` branch** on every active clone
5. **Install Claude Code plugins**:
   - `smorch-dev` (default dev workflow)
   - `smorch-ops` (deploy/drift/secrets)
   - `eo-microsaas-dev` (if `--eo-flag` passed, for student demo machines)
6. **Install MCP servers** (edit `~/.claude/.mcp.json`):
   - Supabase (supabase-sse, supabase-cre, supabase-saasnew, supabase-eo)
   - Contabo + SSH MCPs (from contabo-mcp-server monorepo)
   - GHL MCP, Linear MCP, Exa, Playwright, Clay, Instantly
7. **Install git hooks** in `~/.config/git/hooks/` (via `git config --global core.hooksPath`):
   - destructive-blocker (rejects `rm -rf` on protected paths)
   - secret-scanner-v2 (gitleaks-style pattern match pre-commit)
   - branch-protection-enforcer (rejects direct commit to main/dev)
   - commit-msg-enforcer (conventional commits)
   - drift-flagger (warn on local-ahead >1 day or dirty >1 hour)
8. **Wire sync-from-github** — copy `sync-from-github.sh` to `~/.claude/scripts/` + install launchd agent `ai.smorchestra.sync-from-github` (runs every 1800s)
9. **Wire github-drift** — copy + launchd agent `ai.smorchestra.github-drift` (daily 09:00)
10. **Provision `~/.claude/secrets/`** dir (700 perms) — empty. User fills via 1Password lookup.
11. **Shell profile** — append to `~/.zshrc`:
    - `source ~/.claude/secrets/supabase-creds.env` (if present)
    - `export PROJECT_ROOT=~/Desktop/repo-workspace`
    - `alias cp='cd ~/Desktop/repo-workspace'` (optional convenience)

### Post-install manual steps (can't be scripted)

1. Populate `~/.claude/secrets/supabase-creds.env` with PATs + service_role keys (from 1Password vault `SMOrchestra Infrastructure`)
2. Populate `~/.claude/secrets/contabo-creds.env` (CONTABO_CLIENT_ID, CLIENT_SECRET, API_USER, API_PASSWORD)
3. Populate `~/.claude/secrets/ghl-creds.env` (GHL_API_KEY, GHL_LOCATION_ID)
4. Restart Claude Code to pick up new MCPs
5. Verify: `claude plugin list` shows smorch-dev + smorch-ops
6. Verify: `launchctl list | grep smorchestra` shows sync-from-github + github-drift
7. Test: `cd ~/Desktop/repo-workspace/smo/smorch-brain && git pull` succeeds
8. First-time Lana-only: run `/smo-qa-handover-score --dry-run` against a fake handover to ensure tooling wired

### Onboarding timebox: 15 min

If it takes longer, something's broken — file Linear ticket in `engineering-onboarding` project.

---

## QA Machine (Lana — Mac or Windows)

### Mac: same eng-desktop.sh with `--role qa`

Adds on top of engineer profile:
- `playwright install chromium firefox webkit` (full browser matrix)
- `npm install -g @axe-core/cli lighthouse`
- MENA checker CLIs: `arabic-rtl-checker`, `mena-mobile-check` (from smorch-dev plugin)
- Linear MCP (QA ticket management)
- Telegram CLI (for incident notifications)
- Skip MCP installs that engineer-only needs (contabo, ssh — QA doesn't deploy)
- Sets default branch for local clones to `main` (Lana QAs production builds, not dev)

### Windows: `qa-machine.ps1`

```powershell
iwr -useb https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/qa-machine.ps1 | iex
```

Same outcome, PowerShell-native. Uses Chocolatey for prereqs. Installs Claude Desktop app + extension for Chrome.

### smo-eo-qa server provisioning (external QA environment)

Separate — not a personal machine. Run on the server itself:

```bash
ssh root@100.99.145.22  # Tailscale
curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/qa-machine.sh | bash
```

This installs:
- Playwright + axe + Lighthouse headless
- n8n (docker, for qa.smorchestra.ai — nightly smoke workflows)
- Caddy (reverse proxy for qa.smorchestra.ai)
- Drift + sync crons (same as other servers)
- Perfctl sentinel

---

## Server provisioning (new VPS for a production deploy)

```bash
ssh root@{new-vps-ip}
curl -fsSL https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dev/main/install/prod-server.sh | bash
```

Runs Phase 0 hardening baseline + docker + pm2 + nginx + deploy user + perfctl sentinel + drift cron + sync cron. ~10 min on fresh Ubuntu 24.04.

Then register the server:
1. Add row to `smorch-brain/canonical/server-role-registry.md`
2. Add Tailscale IP
3. Update DNS for any domain that should resolve here
4. Run `/smo-drift --host {new-server}` to confirm baseline green

---

## Verification (any machine, after install) — one command

```bash
/smorch-dev-start
```

Runs the full 4-layer gate. Exit `0` (GREEN) = machine is ready, move on. Exit `1` (YELLOW) = warnings, review before starting real work. Exit `2` (RED) = blockers, run `/smorch-dev-start --fix` or follow the remediation text printed under each ✗ row. Exit `10` = profile couldn't auto-detect, pass `--profile=<role>`.

**What Layer 1 covers** (replaces the old manual checklist):

| What was manual | Now auto-verified by Layer 1 |
|---|---|
| `claude plugin list` | ✓ smorch-dev + smorch-ops installed (role-conditional) |
| `cat ~/.claude/.mcp.json \| jq '.mcpServers \| keys'` | ✓ required MCPs registered |
| `tailscale status` | ✓ tailscale up, not flapping |
| `gh auth status` | ✓ gh authenticated with required scopes |
| `ls -la ~/.claude/secrets/` | ✓ 700/600 perms confirmed |
| `launchctl list \| grep smorchestra` / `crontab -l` | ✓ sync + drift agents registered |
| `ls ~/Desktop/repo-workspace/smo` | ✓ canonical tree present |
| Pre-commit hook runs on empty commit | ✓ hook install path validated |
| `/smo-drift` = 0 findings | ✓ quick drift subset runs inside Layer 2 |

If any of the above fails, the `/smorch-dev-start` report names the exact row + remediation. No more hunting through a checklist.

**Manual verifications that still need a human:**
1. Populate `~/.claude/secrets/*.env` from 1Password (dev-start can't — secrets are human-touched only)
2. Answer first-time auth prompts: `gh auth login`, `claude auth login`, `tailscale up` (done during install)
3. For Lana's Windows: confirm Claude Desktop + Chrome extension are both open and authenticated (dev-start flags if Claude CLI not reachable)

## Enforcement

See `SOP-34 Desktop-Setup-Discipline` (created in this phase) which details which install script runs on which machine + verification gates.
