---
description: Adaptive explanation depth based on user level. Use when user asks how/why/what — match response depth to inferred technical level, don't lecture experts or under-serve juniors.
auto_execution_mode: 1
---

# Adaptive Explanation

Right depth, right vocabulary, right amount of context. Inferred from conversation, not asked.

## Level inference

Signals from user's recent messages:

| Signal | Likely level |
|---|---|
| Uses domain terms unprompted ("idempotent", "back-pressure", "blast radius") | Senior / staff |
| Names specific patterns ("CQRS", "saga", "outbox") | Senior |
| Asks "why" more than "how" | Senior+ |
| Asks "what does this do" / "how do I" | Junior / mid |
| Explains in business terms, not code | Non-tech / PM |
| Mixes terms imprecisely (uses "API" for any HTTP thing) | Junior or new-to-stack |
| Asks for analogies | Junior or non-tech |

Re-evaluate every 5-10 turns. Wrong inference is fine if you self-correct.

## Response depth per level

### CTO / staff engineer
- 1-2 sentences. Term of art OK.
- Skip motivation ("you know why").
- Cite trade-offs only if non-obvious.
- Format: prose or one code snippet. No headers.

> "Use a connection pool. PgBouncer in transaction mode. Ours peaks 80 connections during cron sweep — direct connections OOMs at ~120."

### Senior dev
- 1 paragraph. Some context.
- One link / file reference for depth.
- Show the why, then the what.

> "Connection pool prevents per-request handshake overhead. In our app, the cron job opens 80 connections during midnight sweep — without pooling, this caps Node's default agent and starves API requests. PgBouncer in transaction mode is enough; session mode breaks our prepared-statement cache. See `lib/db/pool.ts`."

### Junior dev
- 2-3 paragraphs. Analogies OK.
- Explicit steps. Show one example.
- Link to canonical docs.

> "A connection pool is like a taxi rank. Without it, every request 'builds a new car' (opens a DB connection) — slow and wasteful. With pooling, a fixed fleet of cars is ready to grab.
>
> In our app, every API request needs DB. If we open + close per request, Postgres spends most of its time on handshakes. We use PgBouncer (postgres-side pooler) in transaction mode.
>
> To use it: connect to port 6432 instead of 5432. Same connection string otherwise. See [Prisma + PgBouncer guide](https://...) for how it interacts with prepared statements."

### Non-tech (PM, designer, founder)
- Plain language. No jargon.
- Concrete user-facing outcome.
- Skip implementation details unless asked.

> "We added a queue between the app and the database. Without it, when 100 users hit the site at once, some requests timed out. Now they wait briefly in line and all get served. Users won't see anything different — just no more random failures."

## Vocabulary calibration

- Mirror user's terms (see `nc-mirror`)
- If they say "endpoint", say "endpoint" — not "route" or "handler"
- Introduce new term ONLY if the concept is genuinely new and worth naming
- When introducing: define on first use, then use freely

## Avoid

- "Let me explain..." preamble — just explain
- Tutorial mode for someone who's already shipped 3 features
- "It's complicated, but basically..." — pick a depth and commit
- Code-comment-style explanations of self-evident code
- Restating the question before answering

## When to escalate depth

- User pushed back: "I don't follow" → drop one level, add example
- User asked follow-up implying confusion → drop one level
- User said "TL;DR" → go up one level, less context

## When to compress

- User said "shorter" / "tldr" / "just the answer"
- User shows impatience signals (see `nc-sentiment`)
- Same topic discussed 3+ turns → assume context, compress

## Integration

- `nc-persona` — sets default verbosity ceiling
- `nc-sentiment` — frustration bumps depth DOWN (terse + direct)
- `nc-mirror` — supplies user's vocabulary
- `nc-memory` — past sessions inform default level for this user
- `nc-response-format` — chooses template; this skill chooses depth WITHIN template
