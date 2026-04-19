# GitHub Actions Sync Setup — One-time

**Purpose:** When you push to `smorch-dev` main, all 4 servers auto-sync within 60s via the `.github/workflows/sync-to-machines.yml` workflow.

**Fallback:** 30-min cron on each machine (always runs). Actions just accelerates the push path.

---

## Required secrets (add once)

Go to `github.com/SMOrchestra-ai/smorch-dev/settings/secrets/actions` → New repository secret.

### Secret 1: `SMO_DEPLOY_KEY`

The SSH private key used to SSH to all 4 servers as root.

```bash
# On your Mac:
cat ~/.ssh/smo_deploy_key   # copy the full key (BEGIN ... END)
```

Paste into secret value. Name: `SMO_DEPLOY_KEY`.

### Secret 2: `TS_OAUTH_CLIENT_ID` + `TS_OAUTH_SECRET`

Tailscale OAuth client for GitHub Actions to join the tailnet (needed to reach Tailscale IPs).

1. Go to `login.tailscale.com/admin/settings/oauth`
2. Click "Generate OAuth client"
3. Scopes: `auth_keys`
4. Tags: `tag:ci` (create the tag if it doesn't exist under Tags)
5. Copy Client ID → GitHub secret `TS_OAUTH_CLIENT_ID`
6. Copy Client Secret → GitHub secret `TS_OAUTH_SECRET`

### Secret 3: `TELEGRAM_BOT_TOKEN`

Existing drift alert bot token (from smorch-brain config):

```bash
# Pull from your local smorch-brain config or Telegram BotFather
```

Name: `TELEGRAM_BOT_TOKEN`. Value: `{your-bot-token}`.

---

## Test it

After adding all 3 secrets:

1. Go to `github.com/SMOrchestra-ai/smorch-dev/actions`
2. Click "Sync to Machines" workflow
3. Click "Run workflow" → Branch: main → target: leave empty (= all)
4. Run. Should succeed on all 4 servers within 60s

On success: each machine's `~/.claude/sync.log` shows the new sync entry.
On failure: Telegram alert fires with which server + short SHA.

---

## Troubleshooting

**"Host key verification failed"** → SSH can't authenticate. Check `SMO_DEPLOY_KEY` is correct.

**"Permission denied (publickey)"** → the deploy key's public half isn't in `/root/.ssh/authorized_keys` on the server. SSH to server manually, add it.

**"Could not resolve hostname"** → Tailscale didn't join. Check `TS_OAUTH_*` secrets + `tag:ci` exists.

**"fatal: Not a git repository: /root/smorch-dev"** → server didn't have the repo cloned. Run `install/{profile}.sh` on that server first.

---

## Manual trigger (anytime)

```bash
gh workflow run sync-to-machines.yml --repo SMOrchestra-ai/smorch-dev
```

Or filter to one server:

```bash
gh workflow run sync-to-machines.yml --repo SMOrchestra-ai/smorch-dev -f target=smo-dev
```

---

## Why not n8n?

Considered + rejected for MVP:
- n8n webhook needs SSH node + credentials + tailnet access anyway
- GitHub Actions is native to the repo, no separate infra to maintain
- Logs live in GitHub (audit trail)
- Failure notifications land in same Telegram channel either way
- n8n is a premium option later if we need conditional logic (e.g., deploy only if CI passed)

When to switch to n8n: if we need deploy gating, multi-step orchestration (deploy app A before app B), or cross-repo sync triggers.

---

## Skip condition

The workflow is defensive — if any server is unreachable, matrix `fail-fast: false` lets the others succeed. Cron sync catches the straggler within 30 min.
