---
description: Environment variables + secrets management. Use when setting up .env files, rotating API keys, managing secrets across dev/staging/prod, or integrating with HashiCorp Vault / AWS Secrets Manager / Doppler.
auto_execution_mode: 1
---

# Env & Secrets Management

## Golden rules

1. **Never commit secrets** — `.env*` in `.gitignore`; commit `.env.example` with dummy values only
2. **Rotate on exposure** — if leaked, assume compromised; rotate immediately
3. **Least privilege** — API keys scoped to minimum needed operation
4. **Per-environment separation** — dev/staging/prod have distinct secrets
5. **Audit trail** — log who accessed what secret when (enterprise)

## File conventions

```
.env                    # local dev (gitignored)
.env.example            # committed, lists required vars with dummy values
.env.development        # committed OK if no secrets (public config)
.env.production         # NEVER commit — use secret manager
.env.test               # committed OK (test-only dummy values)
```

## .env.example format

```bash
# Database
DATABASE_URL=postgres://user:password@localhost:5432/myapp

# API keys (get from https://dashboard.example.com/keys)
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxx
SENDGRID_API_KEY=SG.xxxxxxxxxx

# Feature flags
ENABLE_NEW_DASHBOARD=false

# URLs
PUBLIC_APP_URL=http://localhost:3000
```

## Validation at boot

```ts
// lib/env.ts (Next.js / Node)
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  STRIPE_SECRET_KEY: z.string().startsWith("sk_"),
  NODE_ENV: z.enum(["development", "production", "test"]),
});

export const env = envSchema.parse(process.env);
// Fails fast on missing/invalid vars at boot
```

## Secret manager integration

### HashiCorp Vault

```bash
export VAULT_ADDR=https://vault.example.com
vault login
vault kv get secret/myapp/prod
```

### AWS Secrets Manager

```bash
aws secretsmanager get-secret-value \
  --secret-id prod/myapp/db --query SecretString --output text
```

### Doppler (modern SaaS)

```bash
doppler setup
doppler run -- npm start
# Injects secrets into process.env at runtime
```

### GitHub Actions (CI)

```yaml
env:
  STRIPE_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
steps:
  - run: npm run deploy
    env:
      DEPLOY_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
```

## Rotation workflow

When rotating a secret:

1. Generate new secret at provider dashboard
2. Add to secret manager as `FOO_NEW`
3. Deploy code that reads `FOO_NEW || FOO` (dual-read)
4. Verify new value works
5. Remove old `FOO`
6. Rename `FOO_NEW` → `FOO`
7. Revoke old secret at provider

## Audit checklist

- [ ] `.gitignore` includes `.env*` (with `!.env.example` exception)
- [ ] `.env.example` up-to-date with all required vars
- [ ] All secrets loaded via env (no hardcoded in source)
- [ ] `git log --all -S'password' -S'api_key'` returns clean
- [ ] Production secrets in manager (not committed, not in CI plaintext)
- [ ] Rotation schedule documented (e.g., every 90 days)

## Anti-patterns

- Committing `.env` accidentally → use pre-commit hook to block
- Hardcoding secrets in code "temporarily" → permanent risk
- Sharing secrets via Slack/email → use secret manager invite
- Same secret across environments → compromise in staging = prod leak
- No validation at boot → silent failures in prod

## Integration

- `nc-docker` — pass secrets via `--env-file` or orchestrator
- `nc-ci-cd` — use CI secret stores, never echo
- `nc-security` — audit for leaked secrets in git history
