---
description: Short-term session memory — distinct from nc-memory (long-term). Use to track facts derived during the current session that are too volatile for permanent storage but valuable across turns. Auto-pruned when context budget tightens.
mode: agent
---

# Working Memory (Short-term)

Per-session scratchpad. Survives turns within a conversation; doesn't persist across sessions (that's `nc-memory`).

## Why distinct from nc-memory

| Aspect | nc-memory (long-term) | nc-working-memory (short-term) |
|---|---|---|
| Lifespan | Days, months, permanent | Current session only |
| Granularity | Stable facts, preferences, decisions | In-flight observations, intermediate results |
| Storage | `~/.nc-memory/` (filesystem) | `plans/.scratch/working-memory.md` or in-context |
| Auto-prune | Manual + 90-day rolling | Automatic at context pressure |
| Examples | "Uses pnpm", "deploys to VPS" | "User said port is 3001 not 3000", "branch name is feat/auth-x" |

If a session ends without writing to long-term, working memory dies — that's the point.

## What goes in working memory

- Numbers / IDs / paths user mentioned (so you don't re-ask)
- Intermediate analysis results (cached)
- Current focus / which feature being worked on
- Hypotheses being tested
- Files touched this session
- Errors encountered + workaround applied
- "Open questions" to revisit

NOT for:
- User identity / preferences (→ `nc-memory._global`)
- Project facts (→ `nc-memory.{project}.facts`)
- Decisions with long-term reasoning (→ `nc-memory.{project}.decisions`)

## Storage format

Working memory file (auto-managed):

```markdown
---
session_id: 260418-2046-foo
started: 2026-04-18T20:46:00+07:00
last_updated: 2026-04-18T21:12:00+07:00
context_pressure: medium
---

## Active focus
Adding nc-onboard feature — currently in step 3 (write-it section).

## Facts learned this session
- User runs API on port 3001 (not default 3000)
- Branch: feat/v3-onboard
- User prefers terse responses today (sentiment: focused/no chat)

## Open questions
- [x] What's the API base URL? → confirmed http://localhost:3001
- [ ] Does staging support feature X? → ASK

## Intermediate results
- Validator output: 0 errors, 175 warnings (cached at 21:05)
- Build time: ~4s with --skip-build

## Recently touched files
- skills/nc-onboard/SKILL.md (new)
- adapters/antigravity/converter.cjs (allowlist)
```

## Auto-prune rules

When context budget hits 50% capacity, prune by priority:

| Priority | Drop first | Keep |
|---|---|---|
| 1 (highest) | Stale intermediate results | Active focus + open questions |
| 2 | Files touched > 1 hour ago | Recent file activity |
| 3 | Old "facts learned" superseded | Current confirmed facts |
| 4 | Closed open questions | Open + answered for context |

If still tight: summarize entire working memory into 5 bullets, drop everything else.

## Read pattern

At each turn start (cheap), agent reads working memory if exists. Skip if:
- Empty file
- Trivial single-step request
- User explicitly says "fresh start"

## Write pattern

After significant turn, append/update working memory if:
- Learned a new fact that affects upcoming work
- Completed a step
- Hit a blocker
- Made a decision (small one — big ones go to `nc-memory.decisions`)

## Promotion to long-term

Working memory items earn promotion when:
- Same fact confirmed across 3+ turns → maybe a long-term fact
- User says "remember this" → explicit promote
- End of session via `nc-watzup` → review and promote

Promotion adds to `nc-memory`; original entry stays in working memory until session ends.

## Anti-patterns

- Bloating working memory with conversation transcript (it's not a log)
- Reading entire memory on every turn (load lazily)
- Writing speculative or low-confidence things (these belong in chat, not memory)
- Treating it as durable (it dies; that's the design)
- Manually managing — agent should do it automatically with light user override
- Same data in working AND long-term (decide which; pick one)

## Integration

- `nc-memory` — long-term counterpart; promotion target
- `nc-context-budget` — triggers auto-prune at pressure thresholds
- `nc-router` — checks working memory before re-asking
- `nc-clarify` — references working memory before asking clarifying Qs
- `nc-watzup` — session-end review promotes durable items
- `nc-skill-composition` — handoff between skills carries working memory
- Context Protocol (`docs/context-protocol.md`) — lives at `plans/{session}/context/working-memory.md`
