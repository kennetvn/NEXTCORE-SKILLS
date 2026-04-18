# Job System Rule (MANDATORY)

## Rule

Any work that must run on a schedule (hourly/daily/weekly/monthly sweep, cleanup, aggregation, reminder, digest, health check) **MUST** be implemented as a job in `src/lib/jobs/definitions/`.

**Do NOT:**
- Create a new VPS crontab entry
- Use PM2 `cron_restart` or spawn a standalone PM2 cron worker
- Create a MySQL `EVENT`
- Write a one-off shell script triggered by external cron
- Add a `setInterval()` in app code outside the jobs system

## Applies to

- `<website-project>/example-homestay.com` — all periodic work
- Does NOT apply to: browser extensions (`<extensions-project>/`), PHP API (`api.example.com`), windows desktop apps, agent infrastructure

## How

1. Read `<storage-project>/resources/skill-library/job-system/SKILL.md` for template + checklist.
2. Create `src/lib/jobs/definitions/<kebab-name>.ts`.
3. Register via `import './<kebab-name>';` in `definitions/index.ts`.
4. Deploy. Job appears at `/dashboard/jobs` automatically.

## Exception: backward-compat endpoints

If an existing external cron is already hitting `/api/cron/*`, you MAY keep the route (for rollback safety / emergency trigger without admin login). The route should **delegate** to the job handler, not duplicate logic.

Example: `src/app/api/cron/expire-pending-vip/route.ts` delegates to `expirePendingVipHandler` from `src/lib/jobs/definitions/expire-pending-vip.ts`.

## Why

- Visibility — devs and admins see all jobs at `/dashboard/jobs`
- Safety — PM2 cluster double-execution prevented by DB mutex
- Observability — every run logged in `SystemJobRun` for 30 days
- Self-documenting — `description` field required per job, shown in admin UI
- Portable — no infrastructure config drift across dev/staging/prod

## Reference

- Architecture: `docs/jobs-system.md`
- Agent template: `<storage-project>/resources/skill-library/job-system/SKILL.md`
- Code: `<website-project>/example-homestay.com/src/lib/jobs/`
