---
description: Manage agent token budget per session. Use when context usage exceeds 60%, before loading large refs, when deciding parallel vs serial dispatch, or when agent notices slow responses from context bloat.
mode: agent
---

# Context Budget Management

Maximize agent effectiveness by treating context as a finite resource — not free memory.

## Core principle

**Every token loaded is a token NOT available for reasoning.** Context discipline = faster, better agent output.

## Budget tiers (approximate)

| Usage | State | Action |
|---|---|---|
| 0-40% | Healthy | Full capability, load refs liberally |
| 40-60% | Watch | Avoid loading large refs unless needed, prefer summaries |
| 60-80% | Warning | Dispatch subagents for heavy work, don't load new large files |
| 80-95% | Critical | Close investigation phase, execute only, dump stale context |
| 95%+ | Overflow | Auto-compact likely imminent — finalize current step, defer rest |

## Quick check pattern

Before any heavy operation (loading ref, reading large file, starting new skill), ask:

1. Is this actively needed for the NEXT decision?
2. Can I get away with a summary instead of full content?
3. Can I dispatch this to a subagent instead (isolated context)?

If any answer is "not sure", prefer the lighter option.

## Anti-patterns

- **Preloading "just in case"** — load refs only when actually consulted
- **Re-reading files multiple times** — cache conclusions in notes, re-read only when code changed
- **Verbose tool output** — always pipe through `| tail -N` or `| head -N` for bash
- **Ignoring hook system-reminders** — they signal context state; respond to warnings

## Short-circuit decisions

If user asks trivial question (single function signature, file existence, simple refactor):
- Don't invoke `nc-brainstorm`, `nc-plan`, or heavy skills
- Direct answer/action
- Skip sub-dispatch

## When to dispatch subagent

Dispatch when:
- Research phase (fresh context window is valuable)
- Exploration of unknown codebase area (results summarized to lead)
- Parallel independent tasks (each gets 200K budget)
- Heavy doc read (subagent summarizes back, ~90% context saving)

Do NOT dispatch when:
- You already have the answer
- Task is trivial (<3 steps)
- Dispatch overhead > direct execution

## When to dump stale context

At phase boundaries (research → implement, plan → cook, debug → fix):
- Summarize phase output into 1-paragraph note
- Signal to next phase "research done, see summary"
- Stop re-reading research phase content

## Integration

- `nc-parallel-dispatch` — concrete dispatch patterns (this skill tells you WHEN)
- `nc-router` — short-circuit trivial queries before spending budget
- `nc-skill-composition` — chain skills without duplicating context
