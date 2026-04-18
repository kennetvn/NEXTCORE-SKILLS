---
name: prisma-helper
description: Safe Prisma schema updates, migrations, and database operations for example-homestay.com. Use when editing schema.prisma, running migrations, or troubleshooting database errors like EPERM or missing models.
paths: "**/prisma/**,**/schema.prisma"
---

# Prisma Safe Operations

## Critical Rules
- NEVER run `npx prisma generate` or `npx prisma db push` directly
- ALWAYS use the safe script: `.agent/scripts/prisma-safe.ps1`

## Commands

| Task | Command |
|------|---------|
| Generate client | `.agent/scripts/prisma-safe.ps1 "generate"` |
| Push schema | `.agent/scripts/prisma-safe.ps1 "db push"` |
| Create migration | `.agent/scripts/prisma-safe.ps1 "migrate dev --name <name>"` |
| Open Studio | `npx prisma studio` (port 5555) |

## Schema Update Workflow
1. Edit `prisma/schema.prisma`
2. Run `.agent/scripts/prisma-safe.ps1 "generate"` to validate
3. Run `.agent/scripts/prisma-safe.ps1 "db push"` to apply
4. If data migration needed, create a script in `prisma/` directory
5. Verify with Prisma Studio

## Common Errors

| Error | Fix |
|-------|-----|
| `EPERM: operation not permitted` | Script handles this — stops server, clears cache, restarts |
| `prisma.X does not exist` | Run generate first |
| `Environment variable not found: DATABASE_URL` | Check `.env` file exists |

## Reference
Read full patterns: `<storage-project>/resources/skill-library/testing-strategy/SKILL.md` for DB testing
