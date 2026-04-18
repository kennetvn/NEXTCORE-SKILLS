---
description: Session snapshot patterns: save workspace state, decisions, context for later rollback or recovery. Use before risky operations, at phase boundaries, or when agent may need to restart with context.
---

# Session Snapshot

Capture workspace state + agent context at key moments. Enables rollback and recovery.

## What to snapshot

- **Git state** — current branch, commit SHA, uncommitted diff
- **File inventory** — which files agent has touched
- **Agent notes** — key decisions, open questions, findings
- **Plan + progress** — active plan, completed phases, current step
- **Environment** — relevant env vars, running processes

## Snapshot structure

```
<storage-project>/agent-infra/snapshots/
  260418-1835-before-prisma-migration/
    ├── meta.yaml
    ├── git-state.txt
    ├── uncommitted.diff
    ├── agent-notes.md
    └── context-refs.txt
```

### meta.yaml

```yaml
name: before-prisma-migration
created: 2026-04-18T18:35:00Z
trigger: manual | phase-boundary | risky-op
reason: About to run destructive DB migration
agent: claude-opus-4-7
session-id: abc123
plan-ref: plans/260418-1700-vip-redesign/
```

### git-state.txt

```bash
git branch --show-current
git log -1 --format="%H %s"
git status --short
```

### uncommitted.diff

```bash
git diff > uncommitted.diff
git diff --cached > uncommitted-staged.diff
```

### agent-notes.md

Markdown file with:
- Key decisions made this session
- Findings from research phase
- Known blockers
- Next planned step
- Relevant file references

### context-refs.txt

List of files the agent read + modified:

```
read: src/api/vip/route.ts
read: src/lib/db.ts
modified: src/api/vip/route.ts
modified: prisma/schema.prisma
```

## When to snapshot

**Manual (user-triggered):**
- Before destructive operation (DB migration, mass delete)
- Before major refactor starts
- At end of session (for resumption later)

**Auto (on phase boundary):**
- After research phase completes (before planning)
- After plan approved (before implementation)
- After implementation (before testing)
- Before deploy

**Auto (on risk trigger):**
- Detected schema drift → snapshot first
- Large diff (> 500 LOC) → snapshot first
- Multi-file refactor → snapshot first

## Restoration workflow

```bash
# List snapshots
ls <storage-project>/agent-infra/snapshots/

# Review snapshot before restore
cat .../260418-1835-before-prisma-migration/meta.yaml
cat .../260418-1835-before-prisma-migration/agent-notes.md

# Restore git state
git checkout <commit-from-git-state.txt>
git apply .../uncommitted.diff

# Agent loads notes
cat .../agent-notes.md  # becomes context for new session
```

## Snapshot-on-failure

If a workflow fails (tests broken, deploy failed):

```ts
async function onFailure(error: Error) {
  await snapshot({
    reason: "workflow-failure",
    error: error.message,
    trigger: "auto"
  });
  // Agent can resume with full context after fix
}
```

## Diff-only snapshots

Full snapshots are heavy. Most cases: just `meta.yaml + uncommitted.diff + agent-notes.md` is enough.

```
~/.nc-snapshots/ (local, gitignored)
  260418-1835/
    meta.yaml              # 500 bytes
    uncommitted.diff       # 5KB
    agent-notes.md         # 2KB
  = 7.5KB per snapshot
```

Keep last 20 snapshots per project. Auto-delete older.

## Cross-session recovery

If agent session crashes:

1. New agent starts
2. Reads latest snapshot's `meta.yaml`
3. Reviews `agent-notes.md` — what was being done
4. Checks git state — is branch still valid?
5. Offers to user: "Last session was working on X at step Y. Resume?"

## Anti-patterns

- Snapshot everything all the time (disk + time cost)
- No expiration (old snapshots pile up)
- Snapshot without notes (just state, no "why")
- Restoring without reviewing meta (may restore to broken state)
- Snapshots in git (should be `.gitignored`)

## Integration

- `nc-replay` — snapshots enable replay of failed workflows
- `nc-context-budget` — snapshot is dumping strategy for long sessions
- `nc-journal` — snapshot summary written to journal
