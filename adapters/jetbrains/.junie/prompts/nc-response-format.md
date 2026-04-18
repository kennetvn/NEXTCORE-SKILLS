---
description: Response templates per task type (plan, debug, review, research, implement). Use when agent output would benefit from structured form, when consistency matters across multi-phase work, or when subagent summaries need standard format.
---

# Response Format Templates

Structured output per task type — reduces agent reasoning overhead, enables downstream parsing.

## Plan response

```markdown
# Plan: [feature name]

## Goal
[1 sentence — what success looks like]

## Phases
1. **[Phase name]** — [1-line description]
2. **[Phase name]** — [1-line description]
...

## Dependencies
- [External lib, API, service]

## Risks
- [Top 2-3 risks, with mitigation]

## Success criteria
- [Measurable outcome 1]
- [Measurable outcome 2]

## Estimated scope
[Hours or relative size: S/M/L/XL]
```

## Debug response

```markdown
# Debug report: [bug title]

## Symptom
[What user/test observes]

## Reproduction
1. [Step]
2. [Step]

## Root cause
[1-2 sentences — be specific, cite file:line]

## Call chain
[user action] → [function A:L42] → [function B:L87] → [failure point]

## Fix direction
[High-level — actual fix goes in nc-fix output]

## Related issues
- [If similar bugs exist elsewhere]
```

## Review response

```markdown
# Review: [scope]

## Critical (must fix before merge)
- [file:line] — [issue]

## Suggestions (improve if time)
- [file:line] — [issue]

## Nits (optional)
- [file:line] — [issue]

## Overall
[1-line: approve / request-changes / block]
```

## Research response

```markdown
# Research: [topic]

## TL;DR
[2-3 sentence summary of recommendation]

## Key findings
1. [Finding with source link]
2. [Finding with source link]

## Options evaluated
| Option | Pros | Cons | Fit |
|---|---|---|---|
| A | | | Good/Bad/Neutral |

## Recommendation
[Specific, actionable]

## Sources
- [URL 1]
- [URL 2]
```

## Implementation report

```markdown
# Implemented: [feature/fix]

## Changes
- [file1]: [what changed]
- [file2]: [what changed]

## Tests
- [x] Unit
- [x] Integration
- [ ] E2E (not applicable / TODO)

## Verification
[How you verified it works — command run, output observed]

## Open items
- [Anything incomplete or deferred]
```

## Subagent return format

When a subagent reports back to lead:

```
**Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
**Summary:** [1-2 sentences, concrete]
**Artifacts:** [file paths produced/modified]
**Concerns/Blockers:** [if applicable]
**Next step:** [optional recommendation]
```

## Routing rules for format choice

| Task type | Format |
|---|---|
| User asked to plan | Plan template |
| User reported a bug | Debug template |
| Reviewing code/PR | Review template |
| Researching tech | Research template |
| Delivered implementation | Implementation report |
| Subagent reporting back | Subagent return format |
| Free-form question | No template — direct answer |

## When NOT to use a template

- User asks a direct question expecting direct answer
- Response is under 50 words
- Conversation is casual/exploratory
- Template would bloat a simple response

## Principles

- **Concision over completeness** — missing sections are fine if not applicable
- **File:line citations** — make issues actionable
- **Action-oriented** — every finding should lead to a concrete next step
- **No padding** — no "Executive Summary" for < 200 word reports

## Integration

- Every skill output should conform to one of these templates
- `nc-parallel-dispatch` subagents return in Subagent format
- `nc-skill-composition` handoffs use Implementation/Debug reports as shared state
- Lead agent synthesizes subagent outputs using these templates
