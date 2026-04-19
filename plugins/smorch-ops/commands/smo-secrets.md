---
description: Secrets rotation + audit across 4 servers + Lana's machine. Enforces SOP-16 90-day rotation. Not a password manager — orchestrates rotation workflow.
---

# /smo-secrets

**Scope:** Audit + rotate: SSH keys, API keys (Anthropic, OpenAI, GHL), DB creds, .env values.
**When:** Monthly audit. Triggered by rotation cron. Post-incident if secrets exposure suspected.

## Workflow

### Audit mode (`--audit`, default)

1. Read `smorch-brain/canonical/secrets-manifest.yaml` (declared secrets + last-rotation date)
2. For each secret:
   - Compute age (today minus last-rotation)
   - Compare to SLA (default 90 days per SOP-16)
   - Flag: ok | due-soon (<30d) | overdue | critical (>120d)
3. Write `docs/secrets/YYYY-MM-DD-audit.md` + Telegram summary if any overdue
4. Do NOT rotate in audit mode

### Rotate mode (`--rotate {secret-name}`)

1. Confirm operator has authority (secret owner from manifest)
2. Generate new value (per secret type — API keys via provider CLI, SSH keys via ssh-keygen, DB creds via Supabase dashboard prompt)
3. Update in secret-store (user does this manually per prohibited-actions rule — we don't touch creds)
4. Trigger rolling update across dependent machines (prompt-guided)
5. Verify old key revoked
6. Update `smorch-brain/canonical/secrets-manifest.yaml` with new rotation date
7. Commit manifest update
8. Write `docs/secrets/YYYY-MM-DD-rotation-{secret}.md`

## secrets-manifest.yaml format (in smorch-brain/canonical/)

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

  - name: smo_ssh_deploy_key
    type: ssh_key
    path_local: ~/.ssh/smo_deploy_key
    last_rotated: 2026-01-05
    rotation_sla_days: 365
    used_by:
      - smo-dev
      - smo-prod
    owner: mamoun
```

## Arguments

- `--audit` (default) — report only, no changes
- `--rotate {name}` — begin rotation workflow
- `--verify {name}` — smoke-test that current secret works (e.g., curl Anthropic API)
- `--revoke {name}` — mark as revoked in manifest (after rotation elsewhere)

## Output example

```
## Secrets audit — 2026-04-19

| Secret | Age | SLA | Status |
|--------|----:|----:|--------|
| anthropic_api_key_prod | 59d | 90d | 🟢 ok |
| smo_ssh_deploy_key | 104d | 365d | 🟢 ok |
| ghl_api_key | 97d | 90d | 🟡 overdue (rotate this sprint) |
| supabase_service_role_eo | 188d | 90d | 🔴 critical (rotate now) |

Next actions:
1. /smo-secrets --rotate ghl_api_key
2. /smo-secrets --rotate supabase_service_role_eo
```

## Prohibited actions (safety rules apply)

- Claude **does not generate or store actual secret values**
- Claude **does not SSH into machines to edit .env files** for secrets
- Operator rotates the secret at the provider console, then Claude updates the manifest timestamp
- Claude CAN: propose rollout order, verify propagation via /smo-health, flag stragglers

## Integration

- Monthly cron runs `/smo-secrets --audit --notify` → Telegram summary
- SOP-16 documents full rotation procedure per secret type
- Engineering hat Q11 in smo-scorer checks rotation compliance (caps at 4 if critical overdue)

## Rule

Secrets are the most dangerous thing on the servers. Rotation cadence is non-negotiable. A "reminder missed" here = the next SEV1.
