# NEXTCORE Rollback Protocol

**Status:** Draft v0.1 (targeting v3.0.0)
**Goal:** Every skill declares whether its effects are undoable. Destructive skills auto-snapshot before running.

---

## Frontmatter convention

Every SKILL.md may declare:

```yaml
---
name: nc:foo
description: "..."
license: MIT
undoable: true | false | partial
snapshot_before: true | false       # auto-snapshot before invoking?
---
```

Defaults if absent: `undoable: true`, `snapshot_before: false` (most skills don't change disk).

## Values

| `undoable` | Meaning | Examples |
|---|---|---|
| `true` | Effects fully reversible from snapshot or git | nc-cook, nc-fix, nc-refactor (all live in source tree) |
| `partial` | Some side effects external/non-trivial to reverse | nc-deploy-vps (rollback exists but not free), nc-databases migration, nc-payment-integration test charges |
| `false` | Cannot reasonably reverse | sending real email, public PR open, Slack message, paid API call non-refundable |

## Auto-snapshot rule

For any skill with `snapshot_before: true` or `undoable: false`:

1. Before invocation: trigger `nc-snapshot` to capture working tree state
2. Snapshot stored at `~/.nc/snapshots/{session}/{timestamp}/`
3. If skill fails or user requests undo within 1 hour → `nc-replay` reverses
4. Snapshots auto-pruned after 7 days

## /nc-undo command

Slash command runs:
1. Look up most recent snapshot in current session
2. Diff current state vs snapshot
3. Show user the changes about to be reverted
4. Confirm
5. Apply reversal via `nc-replay`

If irreversible action happened (e.g., email sent), tell user explicitly: "Reverted local changes. The X you did at HH:MM cannot be undone."

## Confirmation gates

Skills with `undoable: false` MUST ask explicit confirmation before running, even when user has set "skip-confirm" tweak. Cannot be silenced.

```
About to <action>. This is NOT reversible (reason: <why>).
Confirm? (yes / no)
```

## Validator integration

`scripts/validate-skills.cjs` checks:
- If skill mentions destructive words ("delete", "drop", "force", "rm -rf", "send", "publish") in body → expect `undoable: false` or `partial`
- If `undoable: false` → expect explicit confirmation pattern in body
- Warning if frontmatter doesn't declare (default assumed but explicit better)

## Catalog reflects

`catalog.json` and `catalog.html` show `undoable` status per skill. Users can filter by "fully reversible only" for high-stakes work.

## Migration

Existing v2.5.x and v2.6.x skills don't yet have the field. Adoption is opportunistic — when a skill is touched, add the field. CHANGELOG tracks coverage.

## Anti-patterns

- Setting `undoable: true` for skills that send emails / open PRs (they're not)
- Setting `snapshot_before: true` for read-only skills (waste of disk)
- Skipping the confirmation gate via `nc-install-tweaks` for `undoable: false` (must always ask)
- Treating snapshot as a backup (it's a 1-hour escape hatch, not durable)

## Open questions

- Should snapshots be incremental (cheap) or full (slow)? Lean: incremental via git stash semantics.
- Cross-session undo: should snapshots from yesterday's session be undoable? Lean: no, would surprise.
- For partial: how to communicate which parts are reversible? Lean: skill body must list which side effects are reversible vs not.

## Status

Draft. First implementation lands as v3.0.0-rc with `nc-deploy-vps` and `nc-payment-integration` as opt-in pilots.
