# NEXTCORE Context Protocol

**Status:** Draft v0.1 (targeting v3.0.0)
**Audience:** skill authors, framework maintainers
**Goal:** Skills hand off via structured files, not re-analysis.

---

## Why this exists

Today, when `nc-plan` finishes and `nc-cook` starts, Claude re-reads the conversation, re-derives the plan, and often loses nuance. Cross-skill state lives only in the rolling chat context — fragile, expensive, and lossy under compaction.

The Context Protocol fixes this by making skill output **first-class artifacts on disk**. The next skill in the pipeline reads from a known path with a known shape, and works from that — not from chat reconstruction.

---

## Directory layout

For every multi-phase task, skills write to:

```
plans/{session-slug}/
├── plan.md                    # nc-plan output
├── context/
│   ├── research.md            # nc-research / nc-scout aggregated findings
│   ├── debug-findings.md      # nc-debug root-cause analysis
│   ├── decisions.md           # design decisions w/ rationale
│   ├── working-memory.md      # short-term facts (Meta Feature 6)
│   └── handoffs.md            # explicit phase-to-phase notes
├── reports/
│   ├── implement-{slug}.md    # nc-cook implementation reports
│   ├── test-{slug}.md         # nc-test results
│   └── review-{slug}.md       # nc-code-review findings
└── visuals/                   # nc-preview output (optional)
```

`{session-slug}` follows the existing convention: `{YYMMDD}-{HHMM}-{slug}`. Already injected by hook (`## Naming` section).

If no active plan exists (single-shot work), context files write to `plans/.scratch/{date}/` with same shape.

---

## File contracts

Each context file has a required schema. Skills MUST conform when writing; downstream skills MAY rely on these fields when reading.

### `plan.md`

```yaml
---
title: <feature name>
status: pending | in-progress | complete | abandoned
created: <ISO date>
phases:
  - id: phase-01
    name: <phase title>
    status: pending | in-progress | done | blocked
    file: phase-01-<slug>.md
---

# Plan: <title>

## Goal
<1 sentence>

## Phases
1. <phase 1> — <1-line>
2. <phase 2> — <1-line>
...

## Dependencies
- <ext lib / API>

## Risks
- <risk + mitigation>
```

Owners: `nc-plan` writes; `nc-cook`, `nc-debug`, `nc-test` read.

### `context/research.md`

```yaml
---
topic: <what was researched>
sources: [<url>, <url>, ...]
confidence: high | medium | low
gathered: <ISO date>
---

# Research: <topic>

## TL;DR
<2-3 sentences>

## Findings
1. <finding> — source: <url>
2. <finding> — source: <url>

## Recommendation
<actionable, specific>

## Open questions
- <thing not yet answered>
```

Owners: `nc-research`, `nc-scout` write; `nc-plan`, `nc-cook` read.

### `context/debug-findings.md`

```yaml
---
bug: <symptom title>
status: investigating | rooted | fixed
severity: critical | high | medium | low
detected: <ISO date>
---

# Debug: <bug>

## Symptom
<observable behavior>

## Reproduction
1. <step>
2. <step>

## Root cause
<file:line + 1-2 sentence explanation>

## Call chain
<user action> → <fn:line> → <fn:line> → <failure>

## Fix direction
<what change is needed; details belong in nc-fix output>
```

Owners: `nc-debug` writes; `nc-fix`, `nc-test` read.

### `context/decisions.md`

Append-only log of design choices with rationale. Each entry:

```markdown
## <YYYY-MM-DD> — <decision title>

**Context:** <what triggered the decision>
**Decision:** <what was chosen>
**Alternatives considered:** <what was rejected and why>
**Trade-offs:** <what we accept by this choice>
**Reversibility:** <cheap | costly | one-way>
**Owner:** <who decided>
```

Owners: any skill writes; `nc-brainstorm`, `nc-predict`, `nc-plan`, `nc-cook` read on next session start.

### `context/handoffs.md`

When phase A finishes and phase B starts in a new agent invocation, A writes a handoff note:

```markdown
## Handoff: <from-skill> → <to-skill> — <ISO timestamp>

### Done
- <thing completed>
- <thing completed>

### Pending
- <what next skill should do>

### Files changed
- <path>
- <path>

### Watch out for
- <gotcha specific to this state>
```

Owners: every multi-phase skill writes a handoff before exiting. Next skill reads first.

### `context/working-memory.md` (Meta Feature 6 preview)

Short-term session-local facts auto-extracted from conversation. Auto-pruned when context budget hits 50%. Schema TBD in Meta Feature 6 spec.

---

## Read order on session start

1. Detect active plan via hook (`## Plan Context` injection)
2. Read `plans/{session}/plan.md` — overall structure
3. Read most recent `context/handoffs.md` entry — what was just done
4. Read `context/decisions.md` — accumulated rationale (cheap, useful)
5. Lazy-load other files only when relevant (don't dump research.md into every turn)

`nc-context-budget` enforces the lazy-load rule.

---

## Write order during work

| Skill | Writes | After |
|---|---|---|
| `nc-research` / `nc-scout` | `context/research.md` | research finishes |
| `nc-plan` | `plan.md` + `phase-XX-*.md` | plan accepted |
| `nc-debug` | `context/debug-findings.md` | root cause identified |
| `nc-cook` | `reports/implement-*.md` + appends to `context/handoffs.md` | phase complete |
| `nc-test` | `reports/test-*.md` + updates `plan.md` phase status | tests run |
| `nc-code-review` | `reports/review-*.md` | review complete |
| `nc-predict` / `nc-brainstorm` | `context/decisions.md` (append) | decision reached |

Every writer ALSO appends a handoff note before exiting if downstream skills will run.

---

## Cross-session continuity

When user starts a new session:
1. Hook detects active plan from filesystem
2. Loads `plan.md`, last handoff, recent decisions into context
3. `nc-router` uses this to pick up where left off without re-asking
4. `nc-memory` long-term facts (project-level) load alongside

This is what makes the agent feel "continuous" rather than amnesiac.

---

## Compatibility with existing skills

- `nc-plan` already writes plans to `plans/{session}/`. This protocol formalizes naming + adds `context/` subdir.
- `nc-cook` already reports to `plans/reports/`. Move to `plans/{session}/reports/`.
- `nc-debug` already writes debug reports. Standardize path to `context/debug-findings.md`.
- `nc-skill-composition` documents pipelines — add explicit "writes/reads" per node.
- `nc-context-budget` gates which context files load eagerly vs lazily.

Existing v2.5.x skills work unchanged. Tier S `nc-memory` and `nc-mirror` integrate naturally — both already think in terms of persisted state.

Migration: no breaking changes. Old `plans/reports/` paths still work as fallback. New skills should adopt the protocol; old skills get updated opportunistically.

---

## Anti-patterns

- Writing context files for single-turn tasks ("fix this typo") — overhead exceeds benefit
- Stuffing entire conversation transcripts into `context/` files — defeats the purpose
- Reading every context file on every turn — burns budget, breaks `nc-context-budget` discipline
- Treating `context/` files as authoritative over current code — code is truth, context is annotation
- Long-form prose in `decisions.md` — keep entries terse, link to detailed write-ups elsewhere

---

## Open questions

- Should `context/` files be gitignored or committed? Default: commit `plan.md` + `decisions.md`, gitignore the rest (working state).
- Schema validation: enforce via JSON Schema or trust skill discipline? Lean: trust + lint.
- Multi-agent teams (Meta Feature 7): does each teammate get own `context/<agent>/` namespace, or shared? Lean: shared with attribution per entry.
- Compaction interaction: when chat compacts, does it re-read context files or rely on summary? Lean: re-read fresh.

---

## Status

This is a **draft spec**. Implementation lands across v3.0.0-rc commits as individual skills adopt the protocol. Tracked in [phase-07-meta-layer.md](../plans/260418-1905-nextcore-skills-v3-peak-agent/phase-07-meta-layer.md).
