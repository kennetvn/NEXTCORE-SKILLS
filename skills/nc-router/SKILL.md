---
name: nc:router
description: "Intent classifier that routes user request to the right skill fast. Use at session start to avoid brainstorm overhead for trivial requests, or when user intent is ambiguous between multiple skills."
license: MIT
argument-hint: "[user-request]"
---

# Intent Router

Route user request → correct skill in <5 seconds. Bypass heavy deliberation for obvious cases.

## Routing rules

### Direct action (no skill invocation)

| User says | Action |
|---|---|
| "fix typo in X" | Direct edit, skip all skills |
| "what does X do?" | Read file, summarize — no workflow |
| "show me Y" | Show content — no workflow |
| "rename X to Y" | Direct refactor via search + replace |
| "delete unused Z" | Direct delete after confirmation |
| Question with known answer | Direct answer |

### Single-skill routing

| User intent | Route to |
|---|---|
| "help me think about X" / "trade-offs of X" | `nc-brainstorm` |
| "research X library" | `nc-research` |
| "plan how to build X" | `nc-plan` |
| "fix this bug: <description>" | `nc-debug` → `nc-fix` |
| "implement X feature" | `nc-cook` |
| "is this approach safe?" | `nc-predict` |
| "audit security" | `nc-security` |
| "what could go wrong?" | `nc-scenario` |
| "write tests for X" | `nc-test` |
| "deploy this" | `nc-deploy-vps` (if NextCore VPS) or ask host |
| "add DB schema for X" | `nc-databases` |
| "design the UI for X" | `nc-ui-ux-pro-max` → `nc-frontend-development` |

### Multi-skill pipelines

| User intent | Pipeline |
|---|---|
| "build a new feature X" | `nc-brainstorm` → `nc-plan` → `nc-cook` → `nc-test` |
| "production bug in X" | `nc-debug` → `nc-fix` → `nc-test` → deploy |
| "weekly review" | `nc-retro` → `nc-journal` |
| "session ending, save state" | `nc-journal` → `nc-watzup` |

## Decision signals

### Signals for LIGHT routing (direct action, no skill)

- Request under 10 words
- Specific file + specific change mentioned
- User is in flow mode ("quickly fix...")
- Agent has full context already

### Signals for HEAVY routing (pipeline)

- Request uses words like "design", "architect", "plan"
- Scope unclear
- Multiple unknowns
- User is exploring options

### Signals for AMBIGUOUS (ask 1 question)

- Request spans multiple domains (UI + backend + DB)
- "Let's build a platform/system/product" (too large)
- "Fix the performance" (which area?)

**Ask maximum 1 clarifying question**, then route decisively.

## Anti-patterns

- **Invoking nc-brainstorm for "rename this variable"** — massive overhead waste
- **Pipeline for "show me X"** — single tool call suffices
- **Routing to multiple skills in parallel when serial pipeline expected** — corrupts handoff
- **Endless clarification loop** — after 1 question, commit to route

## Short-circuits

If session already has a plan (`plans/{YYMMDD}.../plan.md` exists and is active):
- Skip `nc-brainstorm` and `nc-plan`
- Route new requests to `nc-cook` with plan context
- Only re-plan if user explicitly says "replan"

If debugging session active (`plans/reports/debug-*.md` exists recent):
- Skip re-debug
- Route to `nc-fix` with debug context

## Lead-in phrases to listen for

- "help me think" → brainstorm
- "I want to understand" → research / scout
- "I don't know how to" → plan or brainstorm
- "this is broken" → debug
- "make it work" → fix (after debug)
- "ship it" → deploy

## Integration

- `nc-context-budget` — router checks budget, short-circuits when tight
- `nc-skill-composition` — router hands off to pipeline
- `nc-response-format` — router's own response is concise (no over-explanation of routing choice)
