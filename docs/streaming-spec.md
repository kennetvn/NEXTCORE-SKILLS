# NEXTCORE Streaming Output Spec

**Status:** Draft v0.1 (targeting v3.0.0)
**Goal:** Long-running skills emit progressive output so user knows work is happening.

---

## When to stream

| Skill type | Stream? |
|---|---|
| Single-step quick (Read, lint, search) | No — overhead exceeds benefit |
| Multi-phase (`nc-research`, `nc-plan`, `nc-cook`, `nc-debug`) | Yes — phase boundary updates |
| Long-running tools (build, deploy, test suites) | Yes — pipe tool output |
| Code generation > 200 LOC | Yes — model-level streaming |
| Document generation > 500 words | Yes — model-level streaming |

## Two streaming mechanisms

### 1. Phase-boundary updates (skill-level)

Skill emits a 1-line update at each major phase. User sees motion, not silence.

```
> Pipeline: nc-research → nc-plan → nc-cook
> [1/3] Researching... (gathering 5 sources)
> [1/3] Research done — 5 findings, 3 recommended approach
> [2/3] Planning... (designing phases)
> [2/3] Plan done — 4 phases, ETA 2h
> [3/3] Implementing phase 1/4...
> [3/3] Phase 1 complete (3 files modified)
> [3/3] Phase 2/4...
```

Format: `> [<step>/<total>] <action>...` then `> [<step>/<total>] <result>`.

### 2. Token streaming (model-level)

For prose / code output where the model itself streams. Use SDK streaming API.

```typescript
const stream = await client.messages.stream({...});
for await (const event of stream) {
  if (event.type === "content_block_delta") {
    process.stdout.write(event.delta.text);
  }
}
```

User sees text appear word-by-word. Critical for chat UIs.

## Frontmatter convention

```yaml
---
name: nc:foo
description: "..."
streams: phase | tokens | both | none
typical_duration_sec: 30
---
```

| Value | Meaning |
|---|---|
| `phase` | Emits phase updates (default for multi-step skills) |
| `tokens` | Streams generated text (default for content-generation skills) |
| `both` | Phase updates + token streaming within phases |
| `none` | Atomic, single response |

## Update frequency

- Don't update every 100ms — feels jittery
- Don't update every 30s — feels stuck
- Sweet spot: every 2-5s OR at phase boundary

## Cancellation

Streaming implies user can cancel mid-flow. Skill should:
- Be cancellable (no permanent state mid-step)
- On cancel: report "Stopped at <phase>. Partial output preserved at <path>."
- Be idempotent if re-run

## Anti-patterns

- "Working..." with no progress info (useless)
- Spamming progress lines every 200ms
- Streaming output that contains incomplete syntax (broken JSON)
- Phase updates in wrong order ("Phase 1 done" after "Phase 2 starting")
- No final "DONE" marker (user doesn't know it's complete)
- Streaming + then dumping summary at end (just stream the summary)

## Implementation notes

- IDE adapters vary in streaming support. Most modern AI IDEs (Claude Code, Cursor, Antigravity, Windsurf) handle SSE streams natively.
- For non-streaming IDEs (some prompt-only setups): fall back to chunked emission with explicit "..." markers.
- Skill author writes to standard pattern; runtime handles delivery per IDE.

## Status

Draft. Existing multi-phase skills (nc-cook, nc-plan, nc-debug, nc-research) will adopt phase-update pattern in v3.0.x patches.
