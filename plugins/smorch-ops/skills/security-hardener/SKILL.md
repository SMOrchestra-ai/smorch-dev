---
name: security-hardener
description: |
  Post-perfctl server hardening skill. Codifies the UFW + fail2ban + SSH key-only + unattended-upgrades
  baseline that every SMOrchestra server must meet. Run once at server provisioning, then verified
  by /smo-health on every deploy. Engineering hat Q9 caps at 3 if any rule is violated.
---

# security-hardener — Server Hardening Baseline

**Trigger:** Server provisioning, post-incident hardening, pre-deploy posture check.
**Enforces:** Non-negotiable baseline that prevents perfctl-class compromises.

## The 8 non-negotiable rules

### 1. UFW enabled + minimal allowlist
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow in on tailscale0
ufw enable
```
- No other ports open to public internet
- App ports (3000, 3100, etc.) are localhost-only, nginx fronts them

### 2. fail2ban active on sshd
```bash
apt install fail2ban -y
cat > /etc/fail2ban/jail.local <<'EOF'
[sshd]
enabled = true
port = ssh
maxretry = 5
bantime = 3600
findtime = 600
EOF
systemctl restart fail2ban
```

### 3. SSH key-only (no password auth)
In `/etc/ssh/sshd_config`:
```
PasswordAuthentication no
PermitRootLogin without-password
MaxAuthTries 3
LoginGraceTime 20
```
Plus `Match` block: root login only from Tailscale subnet.

### 4. Unattended security upgrades
```bash
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
```

### 5. No world-writable files in /opt/apps/
```bash
find /opt/apps -type f -perm -002 | head -1
# Empty output = clean
```

### 6. No masquerading processes
```bash
# perfctl hid as kernel process. Check for PIDs with empty cmdline:
for pid in $(pgrep -x ' '); do echo "SUSPICIOUS PID: $pid"; done
# Also check:
ps auxf | grep -v "^\[" | awk '{print $11}' | sort -u | head -20
```
Unknown binaries = investigate immediately.

### 7. Tailscale running + auth healthy
```bash
tailscale status | grep -q "Logged in" || echo "TAILSCALE DOWN"
```

### 8. Known-good kernel
```bash
uname -r
# Compare to expected per server. Unexpected = investigate.
```

## Verification protocol

Run as `/smo-health --posture-only` or as part of `/smo-drift`:

```bash
# Returns 0 if all 8 pass, non-zero otherwise
bash security-hardener/scripts/verify-posture.sh
```

Output:
```
✅ UFW active, 4 rules
✅ fail2ban sshd jail active
✅ SSH password auth disabled
✅ Unattended upgrades configured
✅ /opt/apps world-writable scan clean
✅ No masquerading processes detected
✅ Tailscale up
✅ Kernel 6.8.0-48-generic (expected)

8/8 PASS — server posture green
```

## What broke during perfctl

Documented in `QA/reference/INCIDENT-perfctl-malware-2026-04-18.md`. Root causes:
- SSH password auth was enabled temporarily and not reverted
- UFW had a permissive rule for "testing"
- Unknown process (perfctl) ran as kernel-masquerade, exfiltrating data
- Drift detection would have caught it — but drift cron was off for 3 days

Lessons encoded here:
- No temporary rules (all UFW rules committed to canonical)
- Drift cron NEVER paused without SEV ticket
- Masquerade process check added to /smo-health

## Integration with scoring

Engineering hat Q9 uses this skill's output:
- 8/8 green → Q9 = 10
- 7/8 with documented reason → Q9 = 8
- 6/8 → Q9 = 6 (caps hat at 7)
- <6/8 → Q9 = 3 (caps hat at 6 — critical)

## Rule

No PR that deploys to a server ships without running this verification. Skipping = Engineering hat ≤ 6 regardless of other strengths. Never again a perfctl.
