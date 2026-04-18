---
description: Pattern library for spawning multiple subagents in parallel. Use when facing 2+ independent tasks, large scouting across multiple files/dirs, parallel research on different sub-topics, or when serial execution would blow context budget.
---

# Parallel Dispatch Patterns

Maximize throughput + context efficiency by spawning subagents for independent work.

## When to use parallel

**YES parallel when:**
- Tasks are truly independent (no shared state, no output-input chain)
- Each task benefits from fresh 200K context window
- Combined serial cost > overhead of dispatch

**NO parallel when:**
- Task B needs task A's output
- Tasks conflict on same files (write conflict)
- Single task small enough (< 50 lines of work)

## Dispatch patterns

### Pattern 1: Parallel scout

Scenario: find files related to a feature across 5 directories.

Spawn 5 scout subagents — each assigned one directory. Each reports a file list summary (not full content). Lead synthesizes.

### Pattern 2: Parallel research

Scenario: evaluating 3 database options (Postgres, Mongo, DynamoDB).

Spawn 3 research subagents — each researches ONE option deeply. Each returns pros/cons + currency check. Lead compares + recommends.

### Pattern 3: Parallel implementation

Scenario: 3 isolated components need building.

Spawn 3 implementer subagents — each owns distinct files (glob patterns). No cross-component deps. Lead merges at end (or use git worktrees per agent).

### Pattern 4: Parallel verification

Scenario: after implementation, verify typecheck + lint + build.

Parallel Bash calls (not subagents, lighter weight). Lead waits for all, summarizes status.

## Coordination

### File ownership (critical)

If 2 subagents touch same file → corruption. Assign:
- Owner patterns: `src/api/*` → agent-A, `src/components/*` → agent-B
- Shared files (package.json, tsconfig.json): lead owns, subagents read-only

### Dependency ordering

Even in parallel dispatch, some tasks have implicit dependencies. Draw DAG first:

```
Research DB options (parallel) → Pick DB → Implement schema → Tests (parallel: unit + integration + e2e)
```

### Result aggregation

Subagents return structured summaries:

- **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
- **Summary:** 1-2 sentences
- **Artifacts:** file paths produced
- **Concerns/Blockers:** if applicable

Lead synthesizes without re-doing the work.

## Max concurrency

- **2 subagents:** safe default, linear speedup
- **3-5 subagents:** requires careful file ownership, good for scout/research
- **6+ subagents:** overhead exceeds benefit for most cases; reserve for bulk classification

Respect system-reminder warnings about CPU/memory usage.

## Token efficiency math

Serial: 200K × N tasks = 200K used by lead  
Parallel: 200K × N tasks in subagents + 20K summary in lead = ~10x context savings

## Anti-patterns

- **Spawning subagent for trivial task** — direct execution faster
- **Spawning without clear ownership** — file conflicts corrupt work
- **Lead doing the work AND dispatching** — duplicated effort
- **Ignoring subagent summaries and re-reading their work** — defeats purpose

## Integration

- `nc-context-budget` — decide WHEN to dispatch
- `nc-skill-composition` — compose multi-step pipelines
- `nc-response-format` — standardize subagent output
