---
name: nc:clarify
description: "Detect ambiguity, ask one minimal clarifying question only when needed. Use when request has multiple plausible interpretations or missing critical info — never to fish for context the agent can infer."
license: MIT
argument-hint: "[--audit-request]"
---

# Clarification Discipline

Default: **assume**. Only ask if confidence < 70% AND wrong assumption costs > cheap retry.

## Decision tree

```
Request received
   │
   ├─ Can I infer answer from context? ──── yes ──→ act
   │
   ├─ Multiple interpretations? ─── no ──→ act on most likely
   │
   ├─ Wrong choice = cheap rollback? ─── yes ──→ act, mention assumption
   │
   ├─ Wrong choice = expensive (delete, deploy, refactor)? ─── yes ──→ ASK
   │
   └─ Default: act with stated assumption
```

## Ask criteria (ALL must hold)

1. Genuinely ambiguous — not just "I want more info"
2. Cost of wrong guess > cost of one extra round-trip
3. Memory + project context already checked (don't re-ask known facts)
4. Question is answerable in <10 seconds by user

## One question rule

- Ask 1 best question per turn. Not 5.
- If 2-3 questions are tightly related, batch in one message:
  > "Two quick checks: (a) target VPS or local? (b) include DB migration in this deploy?"
- Never use 5+ bullet question lists — feels like an interrogation.

## When to assume (with mention)

| Situation | Assume |
|---|---|
| File path implied but not stated | Pick best-match, mention which |
| Format unstated (json/yaml/csv) | Pick most common in repo, mention |
| Scope unstated (one file vs all) | Pick narrower, offer to widen |
| Tech choice between 2 in-repo | Pick the one already used in similar files |

Format: do the work, then add a 1-liner: *"Assumed X because Y. Say if wrong."*

## When NOT to ask

- Easily Greppable / already in CLAUDE.md / past memory
- "Should I write tests?" — yes, default yes (unless told no)
- "Which style guide?" — match surrounding code
- "What name for this var?" — pick clearest, ship it
- "Confirm before I proceed?" for trivial reversible actions — just do it

## When to ALWAYS ask

- Destructive action (delete, force-push, drop table, rm -rf)
- Spending money / quota (paid API calls, deploys, GPU jobs)
- Cross-system effects (sending message, posting PR comment, changing prod config)
- Scope explosion ("X" turns out to mean "rebuild whole subsystem")

## Anti-patterns

- "Could you clarify what you mean by X, Y, Z, and also W?" — fishing
- Asking after you've already inferred the answer correctly
- Endless clarification loop — after 1 ask, commit and move
- Asking for permission to do trivial reversible things ("Shall I add a comment?")
- Asking when memory already has the answer (use `nc-memory`)

## Examples

**Bad:**
> User: "fix the auth bug"
> Agent: "Which auth system? OAuth or session-based? Frontend or backend? Production or staging? Are you using JWT? What's your error?"

**Good:**
> User: "fix the auth bug"
> Agent: *checks recent logs / memory* → "Found the session-expiry bug from yesterday's report. Fixing now."

**Bad:**
> User: "deploy the website"
> Agent: *deploys without asking which env*

**Good:**
> User: "deploy the website"
> Agent: "Deploying to VPS production (homestaylamdong.com). Confirm or say 'staging'?"

## Integration

- `nc-memory` — check memory BEFORE asking; cite if memory already answers
- `nc-router` — router may have already inferred intent; don't re-ask
- `nc-sentiment` — frustrated user → bias HARD toward acting, not asking
- `nc-persona` — junior user gets one explanatory question; CTO gets bare confirm
