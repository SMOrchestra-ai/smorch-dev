# Runbook — smorch-dev v1.5.0 + EO v1.4.5 rollout

**Effective:** 2026-04-29
**For:** Mamoun (already done locally), Lana (laptop), smo-dev + eo-dev (servers)
**Tags:** [smorch-dev v1.5.0](https://github.com/SMOrchestra-ai/smorch-dev/releases/tag/v1.5.0) · [eo-microsaas-dev v1.4.5](https://github.com/smorchestraai-code/eo-microsaas-training/releases/tag/v1.4.5)

---

## Step 1 — Lana's Windows machine (~10 min)

Paste this in PowerShell or Git Bash. Lana doesn't need to know what it does — Claude Code on her machine will pick up everything on next session restart.

### 1.1 Pull latest marketplaces

```bash
# WSL/Git Bash on Windows
cd ~/.claude/plugins/marketplaces/smorch-dev && git pull origin main
cd ~/.claude/plugins/marketplaces/eo-microsaas-training && git pull origin main
```

### 1.2 Update plugin cache + install record

```bash
# Run inside Claude Code (no need to type the bash above):
/plugin marketplace update smorch-dev
/plugin update smorch-dev@smorch-dev
/plugin update smorch-ops@smorch-dev
/plugin marketplace update eo-microsaas-training
/plugin update eo-microsaas-dev@eo-microsaas-training
```

If the `/plugin update` commands don't exist on her version, fallback:
```bash
# Manual cache refresh (Git Bash / WSL)
cd ~/.claude/plugins/marketplaces/smorch-dev
mkdir -p ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0 ~/.claude/plugins/cache/smorch-dev/smorch-ops/1.1.0
rsync -a --delete plugins/smorch-dev/ ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/
rsync -a --delete plugins/smorch-ops/ ~/.claude/plugins/cache/smorch-dev/smorch-ops/1.1.0/
# Then edit ~/.claude/plugins/installed_plugins.json — bump version + installPath for both.
```

### 1.3 Restart Claude Code

Quit and reopen. New commands appear: `/smo-worktree`, `/smo-benchmark`, `/smo-review-pr`.

### 1.4 Verify

In a Claude Code session in any SMO repo:
```
/smo-dev-guide l3
```
Should print the L3 cascade map (the SOP-36 diagram).

```
bash ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/scripts/l3-health-check.sh
```
Should print `L3 ✓ gstack(29/29) superpowers(14/14)`.

If gstack or superpowers shows missing skills → see Step 1.5 below.

### 1.5 If L3 isn't fully wired on Lana's machine yet

**gstack:**
```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

**superpowers** (run inside Claude Code):
```
/plugin install superpowers@claude-plugins-official
```

Re-run health check from 1.4. Expect green.

---

## Step 2 — smo-dev server (62.171.165.57 / 100.83.242.99)

You said hostname rename is done. Skipping that. Bootstrapping the L3 stack.

### 2.1 SSH in
```bash
ssh root@62.171.165.57   # or via Tailscale IP 100.83.242.99
```

### 2.2 Verify Claude Code is installed
```bash
claude --version
```
If missing:
```bash
npm i -g @anthropic-ai/claude-code
```
Auth: use `claude login` with your Pro/Max subscription (device-code flow). NOT `ANTHROPIC_API_KEY` — that bills per-token. Subscription auth is what the laptop uses too.

### 2.3 Install gstack
```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

### 2.4 Pull marketplace + refresh cache
```bash
cd ~/.claude/plugins/marketplaces/smorch-dev && git pull origin main
mkdir -p ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0 ~/.claude/plugins/cache/smorch-dev/smorch-ops/1.1.0
rsync -a --delete plugins/smorch-dev/ ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/
rsync -a --delete plugins/smorch-ops/ ~/.claude/plugins/cache/smorch-dev/smorch-ops/1.1.0/
```

Then edit `~/.claude/plugins/installed_plugins.json` to bump version+installPath for `smorch-dev@smorch-dev` and `smorch-ops@smorch-dev`. (Or, easier: launch `claude` and run `/plugin update smorch-dev@smorch-dev` etc.)

### 2.5 Install superpowers (clone, no interactive prompt)
```bash
# Both dev servers already had this from earlier setup. To install fresh:
git clone --single-branch --depth 1 https://github.com/obra/superpowers.git ~/.claude/skills/_superpowers-repo
ln -sfn ~/.claude/skills/_superpowers-repo/skills ~/.claude/skills/superpowers
```
The l3-health-check.sh accepts the symlink at `~/.claude/skills/superpowers` pointing to the skills dir.

### 2.6 Set strict L3 mode
```bash
echo 'export SMORCH_STRICT_L3=1' >> /root/.bashrc
source /root/.bashrc
```

### 2.7 Verify
```bash
bash ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/scripts/l3-health-check.sh --strict
```
Must print `L3 ✓ gstack(29/29) superpowers(14/14)`.

---

## Step 3 — eo-dev server (84.247.172.113 / 100.99.145.22, hostname already renamed from smo-eo-qa)

Same as Step 2, just substitute the IP/Tailscale name. Update local `~/.ssh/config` first:

```
Host eo-dev
    HostName 84.247.172.113
    User root
    Port 22
    IdentityFile ~/.ssh/contabo_ed25519
    ServerAliveInterval 60
    KexAlgorithms +diffie-hellman-group14-sha256
```

(Adjust IdentityFile if eo-dev uses a different key.)

Then:
```bash
ssh eo-dev
# Repeat steps 2.2 → 2.7
```

Update `~/.claude/CLAUDE.md` SERVERS table on the local laptop AND on each server:
- Replace `smo-eo-qa  84.247.172.113  100.99.145.22  test/QA` 
- With `eo-dev     84.247.172.113  100.99.145.22  EO Oasis dev VPS (replica of smo-dev)`

Update `smorch-brain/canonical/repo-registry.md` with the same rename (commit + push).

---

## Step 4 — Final parity check from local laptop

```bash
# Once Lana's machine + both servers are bootstrapped:
/smo-skill-sync --verify --server all
```

Expected output: green row per server with `L3 ✓ gstack(29) superpowers(14)`, plugin versions matching local (`smorch-dev v1.5.0`, `smorch-ops v1.1.0`).

If any row red → re-run `/smo-skill-sync --server <name> --bootstrap` for that target.

---

## Done criteria

- [ ] Lana laptop: `/smo-dev-guide l3` prints L3 cascade map
- [ ] smo-dev: `bash ~/.claude/plugins/cache/smorch-dev/smorch-dev/1.5.0/scripts/l3-health-check.sh --strict` returns green
- [ ] eo-dev: same as above
- [ ] Local: `~/.claude/CLAUDE.md` SERVERS table updated (smo-eo-qa → eo-dev)
- [ ] smorch-brain canonical: repo-registry.md updated
- [ ] Smoke: run `/smo-plan throwaway-feature` — should invoke superpowers:writing-plans + gstack:plan-eng-review

---

## Rollback

If anything wedges on a server:
```bash
# Revert plugin cache to previous version
ls ~/.claude/plugins/cache/smorch-dev/smorch-dev/   # should show old + new versions
# Edit installed_plugins.json back to the old version+path
```

Plugin cache is non-destructive — old versions remain until manually cleaned.
