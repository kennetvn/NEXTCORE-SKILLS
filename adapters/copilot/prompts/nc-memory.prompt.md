---
description: Long-term context retention across sessions. Use at session start to load user prefs and project history, at session end to save new info, or when user references past conversations or decisions.
mode: agent
---

# Long-term Memory

Persistent context across sessions. Stops the "Hi, I'm new here" problem on every start.

## Storage

```
~/.nc-memory/
├── _global/
│   ├── preferences.json    # cross-project user prefs (language, persona)
│   └── identity.json       # name, role, timezone
└── {project-slug}/
    ├── facts.json          # stable project facts (stack, conventions, constraints)
    ├── decisions.json      # past decisions + rationale
    ├── ongoing.json        # in-flight work, paused tasks
    └── people.json         # team members, roles, escalation paths
```

`{project-slug}` = derived from git remote URL or repo root path.

## Categories

| Category | Examples | Retention |
|---|---|---|
| `preferences` | language, terse vs verbose, no-emoji | Permanent until user changes |
| `facts` | "uses Prisma", "deploys via PM2", "VPS at 103.241.43.6" | Permanent |
| `decisions` | "chose Polar over Stripe because of MoR" | Permanent (with date) |
| `ongoing` | "VIP renewal phase 2 paused waiting on legal" | 90-day rolling |
| `people` | "Hảo = CTO, owns backend; Trung = ops" | Permanent |

## Retrieval (on session start)

1. Load `_global/preferences.json` — apply persona/language
2. Detect current project (git remote / cwd) → load `{project}/*.json`
3. Inject relevant subset into context (not everything — see budget rules)
4. Summarize loaded memory in 1 line: "Loaded: 4 facts, 2 ongoing items, persona=terse-VN"

## Save (during/end of session)

| Trigger | Save what |
|---|---|
| User says "remember X" / "for next time" | Explicit save to right category |
| Decision made with rationale | Append to `decisions.json` |
| New project fact discovered | Append to `facts.json` |
| Task paused mid-flow | Save to `ongoing.json` with state |
| Session end (`/nc-watzup`) | Snapshot ongoing → ongoing.json |

Never save:
- Secrets (API keys, passwords, tokens) — even if user asks
- One-off task details (covered by `plans/`)
- Conversation transcripts (too noisy)

## Privacy

User can inspect/delete anytime:
- `/nc-memory --inspect` — print all memory for current project
- `/nc-memory --clear preferences` — delete one category
- `/nc-memory --clear-all` — nuke everything (with confirm)
- All files are plain JSON, human-readable

## Budget discipline

Memory load on session start is NOT free. Rules:
- Inject `preferences` + `facts` always (small)
- Inject `decisions` only if user asks "why did we" or topic relates
- Inject `ongoing` only for matching project
- Skip `people` unless user mentions a name

If `nc-context-budget` reports tight context → load only `preferences` + last 3 `decisions`.

## Conflict resolution

When new info contradicts memory:
1. Verify in current code/state (memory may be stale)
2. If still true → update memory, note change date
3. If memory was wrong → mark with `corrected_at` + reason
4. Tell user: "Updated memory: was X, now Y"

## Anti-patterns

- Re-loading full memory on every turn (budget burner)
- Saving conversation summaries as "facts" (too volatile)
- Trusting memory over current file state for code claims
- Hoarding old `ongoing` items past 90 days

## Integration

- `nc-persona` — reads `preferences.persona.*` on start
- `nc-mirror` — reads `facts.vocab` for project terminology
- `nc-context-budget` — gates how much memory to load
- `nc-watzup` — writes `ongoing` + session decisions on shutdown
- `nc-clarify` — checks memory before asking ("we already decided X last session")
