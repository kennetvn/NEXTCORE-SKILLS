---
description: Integrate LLMs into application code (Anthropic/OpenAI/Gemini/local). Use when wiring up model calls, handling streaming, retries, rate limits, structured output, or building multi-provider abstractions.
auto_execution_mode: 1
---

# LLM Integration Skill

App-side patterns. The model is just an API call — most pain is in the wrapper.

## Provider matrix (April 2026)

| Provider | Strengths | Use when |
|---|---|---|
| Anthropic Claude | Reasoning, long context (1M), tool use, prompt caching | Default for agentic / reasoning-heavy |
| OpenAI GPT-4/o-series | Speed/quality, broad ecosystem, structured output strict mode | Multi-modal w/ images, structured output |
| Google Gemini | Best vision, long context | OCR, video, design extraction |
| Local (Llama 3+, Qwen) | Privacy, cost, offline | Sensitive data, edge, batch processing |

Pick based on task. Don't default to "the popular one".

## Minimal client (Anthropic example)

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

async function ask(prompt: string) {
  const res = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 1024,
    messages: [{ role: "user", content: prompt }]
  });
  return res.content[0].type === "text" ? res.content[0].text : "";
}
```

Don't ship this. You need: retry, timeout, error handling, observability, cost tracking.

## Production wrapper (~80 LOC)

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
  timeout: 60_000,           // 60s — generous for reasoning
  maxRetries: 3              // SDK handles 429/500 with backoff
});

interface AskOptions {
  system?: string;
  maxTokens?: number;
  model?: string;
  temperature?: number;
  cacheSystem?: boolean;     // prompt caching for stable system prompts
}

export async function ask(
  userMessage: string,
  opts: AskOptions = {}
): Promise<{ text: string; usage: { in: number; out: number; cost: number } }> {
  const start = Date.now();
  const model = opts.model || "claude-sonnet-4-6";

  const systemBlocks = opts.system
    ? [{ type: "text" as const, text: opts.system, ...(opts.cacheSystem && { cache_control: { type: "ephemeral" as const } }) }]
    : undefined;

  try {
    const res = await client.messages.create({
      model,
      max_tokens: opts.maxTokens || 2048,
      temperature: opts.temperature ?? 0.7,
      system: systemBlocks,
      messages: [{ role: "user", content: userMessage }]
    });

    const text = res.content
      .filter((b) => b.type === "text")
      .map((b: any) => b.text)
      .join("");

    const cost = computeCost(model, res.usage.input_tokens, res.usage.output_tokens);

    log("llm.call", {
      model,
      ms: Date.now() - start,
      in: res.usage.input_tokens,
      out: res.usage.output_tokens,
      cache_read: (res.usage as any).cache_read_input_tokens || 0,
      cost
    });

    return { text, usage: { in: res.usage.input_tokens, out: res.usage.output_tokens, cost } };
  } catch (e: any) {
    log("llm.error", { model, ms: Date.now() - start, error: e.message, status: e.status });
    throw e;
  }
}

function computeCost(model: string, inTokens: number, outTokens: number): number {
  const PRICES: Record<string, { in: number; out: number }> = {
    "claude-opus-4-7":    { in: 15.00, out: 75.00 },
    "claude-sonnet-4-6":  { in:  3.00, out: 15.00 },
    "claude-haiku-4-5":   { in:  0.80, out:  4.00 }
  };
  const p = PRICES[model] || { in: 0, out: 0 };
  return (inTokens * p.in + outTokens * p.out) / 1_000_000;
}
```

## Streaming

```typescript
const stream = await client.messages.stream({
  model: "claude-sonnet-4-6",
  max_tokens: 4096,
  messages: [{ role: "user", content: prompt }]
});

for await (const event of stream) {
  if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
    process.stdout.write(event.delta.text);
  }
}

const final = await stream.finalMessage();
```

For browser SSE: pipe through API route, not direct (key exposure).

## Retry strategy

SDKs handle 429/500 already. Add app-level retry for:
- Network errors (DNS, ECONNRESET)
- 5xx after SDK retries exhausted
- Specific 4xx that may be transient (e.g., overload)

```typescript
async function withRetry<T>(fn: () => Promise<T>, attempts = 3): Promise<T> {
  for (let i = 0; i < attempts; i++) {
    try { return await fn(); }
    catch (e: any) {
      if (i === attempts - 1) throw e;
      if (e.status && e.status >= 400 && e.status < 500 && e.status !== 429) throw e; // don't retry 4xx
      await new Promise(r => setTimeout(r, Math.pow(2, i) * 1000)); // 1s, 2s, 4s
    }
  }
  throw new Error("unreachable");
}
```

## Structured output

### Tool-calling for guaranteed structure

```typescript
const res = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 1024,
  tools: [{
    name: "extract_booking",
    description: "Extract booking details from text",
    input_schema: {
      type: "object",
      properties: {
        booking_id: { type: "string" },
        guest_name: { type: "string" },
        nights: { type: "number" }
      },
      required: ["booking_id", "guest_name", "nights"]
    }
  }],
  tool_choice: { type: "tool", name: "extract_booking" },
  messages: [{ role: "user", content: text }]
});

const block = res.content.find((b) => b.type === "tool_use");
if (block?.type === "tool_use") {
  const data = block.input as { booking_id: string; guest_name: string; nights: number };
}
```

Better than parsing JSON from text — schema enforced.

### Repair loop (when parsing fails)

```typescript
async function extractJson<T>(prompt: string, schema: ZodSchema<T>, maxAttempts = 3): Promise<T> {
  let lastError = "";
  for (let i = 0; i < maxAttempts; i++) {
    const augmented = i === 0 ? prompt : `${prompt}\n\nPrevious attempt failed validation: ${lastError}\nReturn corrected JSON.`;
    const { text } = await ask(augmented);
    try {
      const json = JSON.parse(text.match(/\{[\s\S]*\}/)?.[0] || "{}");
      return schema.parse(json);
    } catch (e: any) {
      lastError = e.message;
    }
  }
  throw new Error(`Failed to extract valid JSON after ${maxAttempts} attempts: ${lastError}`);
}
```

## Multi-provider abstraction

Don't over-engineer until you need 2+ providers in production. When you do:

```typescript
interface LLMProvider {
  ask(prompt: string, opts?: AskOptions): Promise<LLMResult>;
  stream(prompt: string, opts?: AskOptions): AsyncIterable<string>;
}

class AnthropicProvider implements LLMProvider { ... }
class OpenAIProvider implements LLMProvider { ... }

function pickProvider(task: string): LLMProvider {
  // task-based routing — vision → openai/gemini, reasoning → anthropic
}
```

Avoid LangChain unless you need its abstractions for a reason. Hand-rolled is usually clearer at this scale.

## Cost / rate-limit guards

```typescript
const COST_PER_DAY_LIMIT_USD = 50;

let dailyCost = 0;
const resetDaily = setInterval(() => { dailyCost = 0; }, 24 * 60 * 60 * 1000);

async function askWithBudget(prompt: string) {
  if (dailyCost > COST_PER_DAY_LIMIT_USD) throw new Error("Daily LLM budget exhausted");
  const res = await ask(prompt);
  dailyCost += res.usage.cost;
  return res;
}
```

For per-user limits: track in DB / Redis.

## Anti-patterns

- API key in client-side code (proxy through your backend)
- No timeout (LLM call hangs → request thread starved)
- Retrying 4xx errors (wasted calls + cost)
- Hardcoded model name everywhere (centralize + make configurable)
- No usage logging (can't debug cost spikes)
- One mega-call when streaming would improve UX
- Reusing same prompt for different tasks (drift over time)
- No fallback for model deprecation
- Storing full prompts in user DB without hash (privacy / size)

## Integration

- `nc-prompt-engineering` — what to send IN
- `nc-rag-patterns` — context construction
- `nc-vector-db` — embedding storage
- `nc-ai-evaluation` — measure quality before/after changes
- `nc-claude-api` — Anthropic-specific advanced features (batches, files, citations)
- `nc-observability` — logging, cost tracking, latency tracking
- `nc-security` — API key handling, injection defense
