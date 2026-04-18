# Parallel Exploration

Patterns for launching multiple subagents in parallel to scout codebase, verify implementation, and coordinate via native Tasks.

## Parallel Exploration (Scouting)

Launch multiple `Explore` subagents simultaneously when needing to find:
- Related files across different areas
- Similar implementations/patterns
- Dependencies and usage

**Pattern:**
```
Task(subagent_type="Explore", prompt="Find [X] in [area1]", description="Scout area1")
Task(subagent_type="Explore", prompt="Find [Y] in [area2]", description="Scout area2")
Task(subagent_type="Explore", prompt="Find [Z] in [area3]", description="Scout area3")
```

**Example - Multi-area scouting:**
```
// Launch in SINGLE message with multiple Task calls:
delegate to $1 agent
delegate to $1 agent
delegate to $1 agent
```

## Parallel Verification (Bash)

Launch multiple terminal command subagents to verify implementation from different angles.

**Pattern:**
```
Task(subagent_type="Bash", prompt="Run [command1]", description="Verify X")
Task(subagent_type="Bash", prompt="Run [command2]", description="Verify Y")
```

**Example - Multi-verification:**
```
// Launch in SINGLE message:
delegate to $1 agent
delegate to $1 agent
delegate to $1 agent
```

## Task-Coordinated Parallel (Moderate+)

For multi-phase fixes, use native Tasks to coordinate parallel agents.
See `references/task-orchestration.md` for full patterns.

**Pattern - Parallel issue trees:**
```
// Create separate task trees per independent issue
T_A1 = TaskCreate(subject="[Issue A] Debug", activeForm="Debugging A")
T_A2 = TaskCreate(subject="[Issue A] Fix",   activeForm="Fixing A",   addBlockedBy=[T_A1])
T_B1 = TaskCreate(subject="[Issue B] Debug", activeForm="Debugging B")
T_B2 = TaskCreate(subject="[Issue B] Fix",   activeForm="Fixing B",   addBlockedBy=[T_B1])
T_final = TaskCreate(subject="Integration verify", addBlockedBy=[T_A2, T_B2])

// Spawn agents per issue tree
delegate to $1 agent
delegate to $1 agent
```

Agents claim work via `TaskUpdate(status="in_progress")` and complete via `TaskUpdate(status="completed")`. Blocked tasks auto-unblock when dependencies resolve.

## When to Use Parallel

| Scenario | Parallel Strategy |
|----------|-------------------|
| Root cause unclear, multiple suspects | 2-3 Explore agents on different areas |
| Multi-module fix | Explore each module in parallel |
| After implementation | Bash agents for typecheck + lint + build |
| Before commit | Bash agents for test + build + lint |
| 2+ independent issues | Task trees per issue + fullstack-developer agents |

## Combining Explore + Tasks + Bash

**Step 1:** Parallel Explore to scout
**Step 2:** Sequential implementation (update Tasks as phases complete)
**Step 3:** Parallel Bash to verify

```
// Scout phase - parallel
delegate to $1 agent
delegate to $1 agent

// Wait for results, implement fix, TaskUpdate each phase

// Verify phase - parallel
delegate to $1 agent
delegate to $1 agent
delegate to $1 agent
```

## Resource Limits

- Max 3 parallel agents recommended (system resources)
- Each subagent has 200K token context limit
- Keep prompts concise to avoid context bloat
- Use `TaskList()` to check for available unblocked work
