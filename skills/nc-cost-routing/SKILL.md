---
name: nc:cost-routing
description: "Auto-select Claude model tier (Haiku / Sonnet / Opus) based on task complexity. Use to keep cost in check without sacrificing quality on hard tasks. Complements nc-router (skill selection) — this skill picks the model."
license: MIT
argument-hint: "[--classify|--estimate|--config]"
---

# Cost-Aware Model Routing

Same task, different models, 10-20x cost difference. Pick right model per task class.

## Default tier mapping (April 2026)

| Tier | Model | $/1M in | $/1M out | Best for |
|---|---|---|---|---|
| **Light** | Haiku 4.5 | $0.80 | $4 | Classification, extraction, simple Q&A, formatting |
| **Standard** | Sonnet 4.6 | $3 | $15 | Most production work — coding, reasoning, agents |
| **Heavy** | Opus 4.7 | $15 | $75 | Hard reasoning, novel problems, multi-step planning, code generation in unfamiliar codebases |

Default to Standard. Move down for trivial, up only when Standard provably fails.

## Classification rules

```
Inputs to classify:
- Task description / first prompt
- Has tools? How many?
- Requires multi-step?
- Domain familiarity (in-distribution or weird)?
- Required output length

Classify (sample heuristic):
  if extraction_or_classification AND output_short:
    → Light
  if reasoning_required OR coding OR multi-step:
    → Standard
  if novel_problem OR multi-component_system_design OR proven_failure_at_standard:
    → Heavy
```

Implement as a small classifier prompt to Light model (cheap) → outputs tier, cost ~ $0.001 per routing decision.

## Routing decision tree

```
Request → 
   │
   ├─ User explicitly specified model? ── yes → use it
   │   no
   ↓
   ├─ User override config in install-tweaks? ── yes → use it
   │   no
   ↓
   ├─ Cost budget hit? ── yes → forced downgrade + warn user
   │   no
   ↓
   ├─ Task class match high-confidence rule? ── yes → use that tier
   │   no
   ↓
   └─ Default to Standard tier
```

## When to escalate (auto-detect)

Sometimes Standard struggles. Auto-escalate when:
- Standard model says "I'm not sure" / "this is complex" 
- Output fails schema validation 2+ times
- Task involves N+ steps (long agent loops)
- User explicitly retries asking same thing different way (`nc-sentiment` frustration signal)

Escalation pattern:
```typescript
let tier = classify(prompt);
let result = await ask(tier, prompt);
if (looksUncertain(result) && tier !== "heavy") {
  result = await ask("heavy", prompt + "\n\nGive a definitive answer.");
}
```

## When to downgrade (cost optimization)

- Repeated similar tasks (e.g., 1000 extractions) → benchmark Light first
- Internal/dev tools (no user waiting) → Light is fine
- Background batch jobs → Light + Anthropic batch API (50% off)
- Cached / templated outputs → Light + prompt caching = ultra-cheap

## Per-task budget guards

```typescript
const BUDGETS = {
  per_request_max_usd: 0.50,       // single user request shouldn't cost more
  per_user_per_day_usd: 5.00,      // free tier
  org_per_day_usd: 200.00          // hard cap
};

function canSpend(estimated: number, ctx: { user, org }): boolean {
  if (estimated > BUDGETS.per_request_max_usd) return false;
  if (todaySpentByUser(ctx.user) + estimated > BUDGETS.per_user_per_day_usd) return false;
  if (todaySpentByOrg(ctx.org) + estimated > BUDGETS.org_per_day_usd) return false;
  return true;
}
```

When over budget: degrade gracefully (use Light), warn (UI banner), or refuse (paid tier upsell).

## Prompt caching (huge cost reducer)

For stable system prompts: cache them. 90%+ cost reduction on cache hits.

```typescript
{
  model: "claude-sonnet-4-6",
  system: [
    { type: "text", text: STABLE_SYSTEM_PROMPT, cache_control: { type: "ephemeral" } }
  ],
  messages: [...]
}
```

Cache TTL is ~5 min. Pattern: keep system prompt stable; vary only user message.

## Batch API (50% off)

For non-realtime workloads (overnight processing, eval runs):

```typescript
const batch = await client.messages.batches.create({
  requests: [
    { custom_id: "1", params: { model: "claude-sonnet-4-6", ... } },
    { custom_id: "2", params: { ... } }
  ]
});
// Results in ~24h, half price
```

Use for: nightly evals, document indexing, summaries-at-scale.

## Visibility

User should see (optionally):
```
> [Standard / Sonnet 4.6 · $0.0034 · 2.1s]
```

Builds trust + helps user understand why some queries are slow/expensive.

Set via `nc-install-tweaks`:
- `show_model_per_response`: bool
- `show_cost_per_response`: bool
- `daily_budget_warn_pct`: 0.8

## Multi-provider routing (advanced)

If using multiple providers (Anthropic + OpenAI + Gemini):

| Task | Provider |
|---|---|
| Vision-heavy | Gemini Pro (best vision) |
| Reasoning + tools | Anthropic Claude (default) |
| Speed-critical | OpenAI o-mini or Haiku |
| Creative writing | Claude Opus or GPT-4 |
| Long context (>500k) | Claude (1M context) |

Don't add complexity unless meaningful cost/quality difference.

## Anti-patterns

- Always Opus "to be safe" → 5x cost for 5% quality bump on most tasks
- Always Haiku "to save money" → user loses trust when answers are wrong
- No budget guards → one bug burns $1000 in an hour
- Hidden classifier failures → silently downgrades hard tasks
- Reclassifying every turn → wasteful; cache classification per session
- No fallback when chosen model is rate-limited / down
- Budget refuse without offering upgrade path (frustrating UX)

## Integration

- `nc-router` — picks the SKILL; this picks the MODEL
- `nc-llm-integration` — implements the wrapping layer
- `nc-claude-api` — Anthropic-specific (caching, batch, files)
- `nc-install-tweaks` — user override for default tier
- `nc-context-budget` — large context → Claude (1M); small fits anywhere
- `nc-ai-evaluation` — measure quality per tier on YOUR tasks before locking in
- `nc-observability` — track cost per route over time
