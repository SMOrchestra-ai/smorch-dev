---
name: secrets-manager
description: |
  Secrets rotation orchestration per SOP-16. Audit mode + rotate mode. Drives /smo-secrets command.
  Does NOT store secret values (prohibited by safety rules). Operates on a manifest (smorch-brain/canonical/secrets-manifest.yaml)
  tracking name + type + last-rotated + used-by + owner.
---

# secrets-manager — Rotation Orchestration

**Invoked by:** `/smo-secrets`
**Governed by:** SOP-16 (90-day default rotation SLA)
**Prohibited actions apply:** we DO NOT generate, store, or transmit secret values.

## The manifest

`smorch-brain/canonical/secrets-manifest.yaml`:

```yaml
secrets:
  - name: anthropic_api_key_prod
    type: api_key
    provider: anthropic
    last_rotated: 2026-02-19
    rotation_sla_days: 90
    used_by:
      - eo-prod:/opt/apps/eo-mena/.env.local
      - smo-prod:/opt/apps/saasfast/.env.local
    owner: mamoun
    rotation_procedure_doc: docs/procedures/rotate-anthropic.md

  - name: smo_ssh_deploy_key
    type: ssh_key
    path_local: ~/.ssh/smo_deploy_key
    last_rotated: 2026-01-05
    rotation_sla_days: 365
    used_by: [smo-dev, smo-prod, eo-prod]
    owner: mamoun
    rotation_procedure_doc: docs/procedures/rotate-ssh-deploy-key.md

  - name: supabase_service_role_eo
    type: api_key
    provider: supabase
    last_rotated: 2025-10-14
    rotation_sla_days: 90
    used_by:
      - eo-prod:/opt/apps/eo-mena/.env.local
      - eo-prod:/opt/apps/eo-scoring/.env.local
    owner: mamoun
```

## Audit workflow

```
1. Parse manifest
2. For each secret:
   - age = today - last_rotated
   - sla = rotation_sla_days
   - Status: ok (age < sla-30), due-soon (age < sla), overdue (age < sla+30), critical (age >= sla+30)
3. Generate docs/secrets/YYYY-MM-DD-audit.md
4. Telegram summary if any overdue/critical
```

## Rotate workflow (safety-critical)

```
1. Confirm operator is the owner (from manifest)
2. Open rotation_procedure_doc (e.g., docs/procedures/rotate-anthropic.md)
3. GUIDE operator through provider console steps (do NOT automate)
4. After operator confirms new value deployed:
   - Update manifest last_rotated = today
   - Commit manifest change (smorch-brain main)
5. Trigger dependent machines to pull new .env values:
   - For each "used_by" entry, operator updates the .env.local file manually
   - We do NOT SSH + edit .env files (prohibited)
6. Verify propagation:
   - /smo-health --app {app} → confirms app still green with new secret
7. Revoke old secret at provider (operator does manually)
8. Confirm revocation:
   - We attempt old secret → expect 401/403
   - Log: docs/secrets/YYYY-MM-DD-rotation-{name}.md
```

## Rotation procedure docs (per secret type)

Create these one-time in `docs/procedures/`:

### `rotate-anthropic.md`
1. Go to console.anthropic.com → Settings → API Keys
2. Generate new key (name it `prod-YYYYMMDD`)
3. Copy to 1Password + to each .env file listed in manifest.used_by
4. Deploy each app (/smo-deploy --force, audit logged)
5. Verify with /smo-health
6. Revoke old key in console
7. Update manifest

### `rotate-ssh-deploy-key.md`
1. Generate: `ssh-keygen -t ed25519 -C "smo-deploy-YYYYMMDD" -f ~/.ssh/smo_deploy_key_new`
2. Add new public key to each server in used_by: `~/.ssh/authorized_keys`
3. Verify SSH with new key works on each server
4. Remove old key from `~/.ssh/authorized_keys` on each server
5. Replace local `~/.ssh/smo_deploy_key` with `_new` version
6. Update manifest

### `rotate-supabase-service-role.md`
1. Supabase dashboard → Project → API → reset service_role key
2. Update manifest.used_by entries in .env files
3. Deploy dependent apps
4. Verify /smo-health

## Rotation calendar

Monthly cron: `/smo-secrets --audit --notify` → Telegram report.
Quarterly: operator runs a scheduled rotation block (all 90-day SLA secrets).
Annually: SSH keys rotated.

## Engineering hat Q11 integration

smo-scorer reads this manifest. Any PR deploying to a server where:
- 1 secret critical → Q11 caps at 4
- 1 secret overdue → Q11 caps at 7
- All within SLA → Q11 potentially 10

Thus secrets hygiene shows up in every scoring round, not just the quarterly audit.

## Anti-patterns

- Rotating without updating manifest timestamp (invisible to audit)
- Storing new secret in wrong place (1Password vs .env diverge)
- Skipping revocation of old key (both keys live = 2x attack surface)
- Rotating all secrets at once (if one breaks, harder to debug which)

## Rule

No secret has been in production >180 days. Ever. If the audit shows one, it's a SEV3 (not SEV4 — this is how malware stays resident).
