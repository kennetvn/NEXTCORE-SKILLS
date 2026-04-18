---
description: Migration strategies: framework upgrades (Next.js 15→16), DB schema migrations, API v1→v2, breaking refactors. Use when planning any migration or upgrade that can't be done in single PR.
auto_execution_mode: 1
---

# Migration Patterns

## Principle: Expand + Contract

Never break. Always:

1. **Expand** — add new alongside old
2. **Migrate** — gradually move consumers to new
3. **Contract** — remove old when no consumers remain

## Framework upgrade (e.g., Next.js 15 → 16)

1. **Read migration guide** — list all breaking changes
2. **Branch + codemod** — run official codemods first (`@next/codemod`)
3. **Incremental** — if possible, pin portions to old version
4. **Test in canary** — deploy to 5% traffic, monitor errors
5. **Roll forward** — if stable, 100%; if not, rollback image tag

## DB schema migration

### Additive changes (safe)

- Add new column (nullable, no default) → deploy → backfill → add constraint
- Add new table → deploy → populate lazily
- Add index → `CREATE INDEX CONCURRENTLY` (Postgres) to avoid lock

### Breaking changes (multi-step)

Example: rename column `user_name` → `username`:

```
Step 1: Add column "username"
Step 2: Deploy code that writes to BOTH (dual-write)
Step 3: Backfill: UPDATE users SET username = user_name WHERE username IS NULL
Step 4: Deploy code that reads from "username" only
Step 5: Deploy code that writes to "username" only
Step 6: Drop column "user_name"
```

Never: drop + add in same migration (data loss).

### Prisma safe pattern

```bash
# Dev
npx prisma migrate dev --name add_username

# Prod (non-destructive)
npx prisma migrate deploy
```

For destructive changes: raw SQL in a new migration, manually reviewed.

## API v1 → v2 migration

### URL versioning

```
/api/v1/users  (existing, keep alive)
/api/v2/users  (new shape)
```

### Migration workflow

1. Ship v2 alongside v1
2. Add `Deprecation: true` + `Sunset: 2027-01-01` headers on v1
3. Update docs to point to v2
4. Monitor v1 usage per client (log `user-agent` or API key)
5. Email v1 consumers: deadline, migration guide
6. After sunset date + 30 day grace, remove v1

### Dual-read, single-write transition

If v2 backend is incompatible:

```ts
app.get("/api/v1/users/:id", async (req, res) => {
  const user = await v2_getUser(req.params.id);
  res.json(v1_transform(user));  // adapter layer
});
```

v1 endpoint becomes a thin wrapper over v2 logic.

## Large refactor strategy

### Strangler fig pattern

1. New code written alongside old
2. Feature by feature, route traffic to new
3. Old code "strangled" as consumers migrate
4. Delete old when 0 consumers

Origin: Martin Fowler, Strangler Fig Application.

### Feature flag guarded

```ts
if (flags.USE_NEW_CHECKOUT) {
  return newCheckout(order);
}
return oldCheckout(order);
```

Benefits: instant rollback, gradual rollout per user cohort.

## Data backfill

### Large table (millions of rows)

Bad: `UPDATE users SET ...` — locks table, blocks writes for hours.

Good: batched + throttled:

```sql
-- Postgres: update in chunks
DO $$
DECLARE
  batch_size INT := 1000;
  max_id INT;
  current_id INT := 0;
BEGIN
  SELECT MAX(id) INTO max_id FROM users WHERE new_col IS NULL;
  WHILE current_id < max_id LOOP
    UPDATE users SET new_col = compute(old_col)
    WHERE id BETWEEN current_id AND current_id + batch_size
      AND new_col IS NULL;
    current_id := current_id + batch_size;
    COMMIT;
    PERFORM pg_sleep(0.1);  -- throttle
  END LOOP;
END $$;
```

Or: dedicated backfill job (background queue).

## Rollback checklist

Before shipping migration:

- [ ] Can I rollback the code? (yes if dual-read enabled)
- [ ] Can I rollback the DB? (usually no — design forward-compatible)
- [ ] Health check covers new path?
- [ ] Monitoring alerts on error rate spike?
- [ ] Backup snapshot before migration executes?

## Anti-patterns

- Dropping column in same PR that adds it (no migration path)
- Big-bang cutover (all users at once, no rollback window)
- Skipping dual-write phase
- No backward compat period after v2 ships
- Breaking change without versioning API
- Migrating without backup

## Integration

- `nc-ci-cd` — automated migration in deploy pipeline (with gate)
- `nc-prisma-helper` — safe Prisma workflow
- `nc-observability` — track migration progress (rows migrated, errors)
