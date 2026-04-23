#!/bin/bash
# SOP-34 — Verify install gate; run at end of eng-desktop.sh / qa-machine / prod-server scripts
ROLE="${1:---role=engineer}"
PASS=0; FAIL=0
check() {
  if eval "$2" >/dev/null 2>&1; then
    echo "✓ $1"; PASS=$((PASS+1))
  else
    echo "✗ $1"; FAIL=$((FAIL+1))
  fi
}
echo "=== SOP-34 Install Verification (role=$ROLE) ==="

# All machines
check "git installed" "command -v git"
check "gh CLI installed" "command -v gh"
check "git hooks path set" "git config --global core.hooksPath | grep -q scripts/hooks"
check "~/.claude/secrets/ exists with 700 perms" "stat -c %a ~/.claude/secrets 2>/dev/null | grep -q 700 || stat -f %A ~/.claude/secrets 2>/dev/null | grep -q 700"
check "tailscale up" "tailscale status 2>/dev/null | head -1 | grep -qv 'stopped'"

case "$ROLE" in
  --role=engineer|--role=qa)
    check "claude plugin smorch-dev" "claude plugin list 2>/dev/null | grep -q smorch-dev"
    check "claude plugin smorch-ops" "claude plugin list 2>/dev/null | grep -q smorch-ops"
    check "~/.claude/.mcp.json has ≥8 servers" "python3 -c 'import json; d=json.load(open(\"$HOME/.claude/.mcp.json\")); exit(0 if len(d[\"mcpServers\"])>=8 else 1)'"
    check "~/Desktop/repo-workspace exists" "[ -d ~/Desktop/repo-workspace/smo ]"
    check "launchd sync-from-github loaded" "launchctl list 2>/dev/null | grep -q sync-from-github"
    check "launchd github-drift loaded" "launchctl list 2>/dev/null | grep -q github-drift"
    check "gh auth with admin:org scope" "gh auth status 2>&1 | grep -q admin:org"
    ;;
  --role=server-prod|--role=server-dev|--role=server-qa)
    check "UFW active" "ufw status 2>/dev/null | grep -q 'Status: active'"
    check "fail2ban active" "systemctl is-active --quiet fail2ban"
    check "docker running" "systemctl is-active --quiet docker"
    check "SSH password auth disabled" "grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config"
    check "unattended-upgrades installed" "dpkg -l unattended-upgrades 2>/dev/null | grep -q '^ii'"
    check "swap present" "[ $(free | awk '/^Swap:/{print \$2}') -gt 0 ]"
    check "/opt/scripts/perfctl-sentinel.sh" "[ -x /opt/scripts/perfctl-sentinel.sh ]"
    check "/opt/scripts/infra-drift.sh" "[ -x /opt/scripts/infra-drift.sh ]"
    check "/opt/scripts/sync-from-github.sh" "[ -x /opt/scripts/sync-from-github.sh ]"
    check "sentinel cron scheduled" "crontab -l 2>/dev/null | grep -q perfctl-sentinel"
    check "infra-drift cron scheduled" "crontab -l 2>/dev/null | grep -q infra-drift"
    check "sync cron scheduled" "crontab -l 2>/dev/null | grep -q sync-from-github"
    check "/root/smorch-brain clone" "[ -d /root/smorch-brain/.git ]"
    check "/root/smorch-dev clone" "[ -d /root/smorch-dev/.git ]"
    ;;
esac

echo ""
echo "=== Result: $PASS passed / $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🟢 SOP-34 baseline met." || echo "🔴 SOP-34 gaps — fix before considering this machine provisioned."
exit $FAIL
