---
description: Replay failed workflows from snapshot with fixes applied. Use when a multi-step workflow failed partway, to recover and retry with corrections, or to debug what went wrong.
---

# Replay Failed Workflows

Resume a failed or interrupted workflow from snapshot, applying fixes.

## Use cases

- Deploy pipeline failed at step 5 → fix + replay from step 5 (not start)
- Multi-file refactor half-done → agent crashed → replay from checkpoint
- CI/CD failure → replicate locally + investigate
- User cancelled → want to resume later

## Requires `nc-snapshot`

Replay depends on snapshots being taken. No snapshot = no replay.

## Replay workflow

```
1. Identify failed snapshot
   → ls <storage-project>/agent-infra/snapshots/
   → find most recent "failed" marker in meta.yaml

2. Read snapshot context
   → agent-notes.md: what was being done
   → git-state.txt: where we were
   → uncommitted.diff: in-progress changes

3. Restore workspace
   → git checkout <commit>
   → git apply uncommitted.diff

4. Identify failure point
   → What step failed?
   → What error?
   → What's the fix?

5. Apply fix
   → Manual edit, or update plan, or change config

6. Resume from checkpoint
   → Run steps N..end (not 1..end)
   → Agent picks up mid-pipeline

7. On success: snapshot new state
   On failure: snapshot again, iterate
```

## Replay vs re-run

| Replay | Re-run |
|---|---|
| Resume from mid-pipeline | Start from beginning |
| Preserves partial work | Discards partial work |
| Needs snapshot | No prerequisites |
| Good for long workflows | Good for short workflows |

Use replay when restart-from-zero costs > 10 min.

## Pipeline checkpoints

Workflows should emit checkpoint markers:

```
nc-cook pipeline:
  [x] Step 1: research done → checkpoint saved
  [x] Step 2: plan approved → checkpoint saved
  [x] Step 3: phase 1 implemented → checkpoint saved
  [ ] Step 4: phase 2 implementation (FAILED)
  [ ] Step 5: tests
  [ ] Step 6: review
```

On failure: next session starts by reading last checkpoint.

## Replay with modifications

Common: original plan had a flaw, replay with updated plan.

```
1. Load snapshot
2. Edit plan.md (fix phase 4's approach)
3. Re-run nc-cook with updated plan
4. nc-cook detects existing phases 1-3 done, skips to phase 4
```

Plans should have per-phase status:

```yaml
phase-1: done
phase-2: done
phase-3: done
phase-4: failed  # will be replayed
phase-5: pending
phase-6: pending
```

## Deployment replay

```
Deploy failed at "health check":
  1. snapshot taken automatically on failure
  2. Inspect logs → DB migration didn't apply correctly
  3. Apply migration manually
  4. Replay deploy from "post-migration health check" step
  5. If green: mark success
```

## CI/CD replay locally

```bash
# GitHub Actions failed → replicate locally
act -j deploy --secret-file .env.ci

# Or: download failed job artifacts
gh run download <run-id>
# Investigate with full context
```

## Failure analysis from snapshot

Before replay, understand why it failed:

```
1. Read agent-notes.md for the failed snapshot
2. Check error message in meta.yaml
3. Git diff between last success snapshot and failed snapshot
4. What changed? What's the minimal fix?
```

If root cause unclear → run `nc-debug` first, fix, then replay.

## Replay safety

- Don't replay destructive operations without review
- DB migrations: verify idempotent before replay
- External API calls: check if already processed (use `nc-queues` idempotency keys)
- Deploys: verify current state matches snapshot expectation before resuming

## Anti-patterns

- Replaying without understanding failure (repeats same mistake)
- Replaying destructive ops that aren't idempotent
- Skipping human review on important pipelines
- Replaying days-old snapshots (codebase drifted too much)
- No checkpoint granularity (can only replay from start)

## Integration

- `nc-snapshot` — required dependency, provides checkpoints
- `nc-debug` — investigate failure before replay
- `nc-migration-patterns` — ensure DB migrations are replay-safe (idempotent)
