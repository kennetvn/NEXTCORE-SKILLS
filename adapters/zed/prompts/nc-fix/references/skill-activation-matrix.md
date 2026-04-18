# Skill Activation Matrix

When to activate each skill and tool during fixing workflows.

## Always Activate

| Skill/Tool | Reason |
|------------|--------|
| `nc-debug` | Core to all fix workflows - find root cause first |

## Task Orchestration (Moderate+ Only)

| Tool | Activate When |
|------|---------------|
| `TaskCreate` | After complexity assessment, create all phase tasks upfront |
| `TaskUpdate` | At start/completion of each phase |
| `TaskList` | Check available unblocked work, coordinate parallel agents |
| `TaskGet` | Retrieve full task details before starting work |

Skip Tasks for Quick workflow (< 3 steps). See `references/task-orchestration.md`.

## Conditional Activation

| Skill | Activate When |
|-------|---------------|
| `nc-brainstorm` | Multiple valid approaches, architecture decision, stuck on approach |
| `nc-context-engineering` | Fixing AI/LLM/agent code, context window issues |
| `nc-ai-multimodal` | UI issues, screenshots provided, visual bugs |
| `nc-project-management` | Moderate+ workflows — task hydration, sync-back, progress tracking |

## Subagent Usage

| Subagent | Activate When |
|----------|---------------|
| `debugger` | Root cause unclear, need deep investigation |
| `Explore` (parallel) | Scout multiple areas simultaneously |
| terminal command (parallel) | Verify implementation (typecheck, lint, build) |
| `researcher` | External docs needed, latest best practices |
| `planner` | Complex fix needs breakdown, multiple phases |
| `tester` | After implementation, verify fix works |
| `nc-code-review` | After fix, verify quality and security |
| `git-manager` | After approval, commit changes |
| `docs-manager` | API/behavior changes need doc updates |
| `project-manager` | Major fix impacts roadmap/plan status |
| `fullstack-developer` | Parallel independent issues (each gets own agent) |

## Parallel Patterns

See `references/parallel-exploration.md` for detailed patterns.

| When | Parallel Strategy |
|------|-------------------|
| Root cause unclear | 2-3 `Explore` agents on different areas |
| Multi-module fix | `Explore` each module in parallel |
| After implementation | terminal command agents: typecheck + lint + build |
| Before commit | terminal command agents: test + build + lint |
| 2+ independent issues | Task trees + `fullstack-developer` agents per issue |

## Workflow → Skills Map

| Workflow | Skills Activated |
|----------|------------------|
| Quick | `nc-debug`, `nc-code-review`, parallel terminal command verification |
| Standard | Above + Tasks, `nc-project-management`, `tester`, parallel `Explore` |
| Deep | All above + `nc-brainstorm`, `nc-context-engineering`, `nc-project-management`, `researcher`, `planner` |
| Parallel | Per-issue Task trees + `nc-project-management` + `fullstack-developer` agents + coordination via `TaskList` |

## Detection Triggers

| Keyword/Pattern | Skill to Consider |
|-----------------|-------------------|
| "AI", "LLM", "agent", "context" | `nc-context-engineering` |
| "which approach", "options", "stuck" | `nc-brainstorm` |
| "latest docs", "best practice" | `researcher` subagent |
| Screenshot attached | `nc-ai-multimodal` |
