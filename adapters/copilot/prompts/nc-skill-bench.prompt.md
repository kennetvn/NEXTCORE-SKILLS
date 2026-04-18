---
description: Performance benchmarks for skills: token cost, time-to-complete, memory usage. Use before releasing skill changes, comparing variants, or detecting performance regression.
mode: agent
---

# Skill Benchmarking

Quantitative performance measurement per skill.

## Metrics

Per invocation:

- **Tokens used** — input + output tokens (cost indicator)
- **Time-to-complete** — wall-clock from start to finish
- **Steps** — number of tool calls / subagents
- **Memory** — peak context size during execution
- **Success rate** — % of runs completing without errors

## Baseline benchmark run

```bash
node scripts/bench-skill.js --skill nc-plan --iterations 10 --model claude-opus-4-7
```

Output:

```json
{
  "skill": "nc-plan",
  "model": "claude-opus-4-7",
  "iterations": 10,
  "tokens": { "p50": 12500, "p95": 18000, "mean": 13200 },
  "time_sec": { "p50": 45, "p95": 72, "mean": 51 },
  "steps": { "p50": 8, "p95": 12, "mean": 9 },
  "success_rate": 1.0,
  "date": "2026-04-18T18:30:00Z"
}
```

## Regression detection

Compare new run to baseline:

```
If tokens.p95 > baseline.p95 * 1.20:   # 20% worse
  → FAIL: token regression
If time.p95 > baseline.time_p95 * 1.30:
  → WARN: latency regression
If success_rate < baseline.success_rate - 0.05:
  → FAIL: reliability regression
```

## Cost analysis

Track $/invocation across models:

| Model | Tokens p95 | $/invoke |
|---|---|---|
| claude-opus-4-7 | 18000 | $0.27 |
| claude-sonnet-4-6 | 16500 | $0.05 |
| claude-haiku-4-5 | 15000 | $0.009 |

Decide: do we need Opus for this skill? Or is Sonnet enough?

## Variant comparison

Test 2 versions of same skill side-by-side:

```bash
node scripts/bench-skill.js --skill nc-plan --variant a --variant b --iterations 20
```

Outputs comparison table, statistical significance (t-test):

```
                  Variant A    Variant B   Diff (%)  Significant?
tokens (p50)      12,500       10,200      -18.4%    Yes (p<0.01)
time (p50)        45s          38s         -15.6%    Yes (p<0.05)
success_rate      1.00         0.95        -5.0%     No (p=0.12)
```

## Benchmarks over time

```
.github/workflows/bench.yml runs weekly:
  - Bench all active skills
  - Upload results to benchmarks.json
  - Generate trend chart (over N weeks)
  - Alert if any skill degrades > 20%
```

## Test harness (minimal)

```js
// scripts/bench-skill.js
import { performance } from 'perf_hooks';

async function benchSkill(skillName, query, iterations = 10) {
  const results = [];
  for (let i = 0; i < iterations; i++) {
    const start = performance.now();
    const r = await runClaudeWithSkill(skillName, query);
    results.push({
      tokens: r.usage.input + r.usage.output,
      time_ms: performance.now() - start,
      success: r.success,
    });
  }
  return summarize(results);  // p50, p95, mean
}
```

## Benchmark queries

Each skill has a canonical "benchmark query" in `skills/{name}/bench.yaml`:

```yaml
queries:
  - name: "small feature"
    prompt: "plan a single-endpoint CRUD for blog posts"
    expected_time_p95: 45  # seconds
    expected_tokens_p95: 12000

  - name: "large feature"
    prompt: "plan multi-service payment integration with webhooks"
    expected_time_p95: 120
    expected_tokens_p95: 25000
```

## Cost tracking dashboard

```
┌────────────────────────┐
│ Weekly skill cost      │
├────────────────────────┤
│ nc-plan:    $4.20      │
│ nc-cook:    $12.80     │
│ nc-debug:   $2.10      │
│ nc-research: $1.50     │
│ Total:      $20.60     │
└────────────────────────┘
```

Optimize top 3 spenders first.

## Anti-patterns

- Benchmarking on single run (high variance)
- Ignoring p95 (outliers matter more than median)
- Not normalizing query complexity (unfair skill comparison)
- No model-specific baseline (Opus baseline ≠ Sonnet)
- Benchmarking without production data (synthetic may not match real use)

## Integration

- `nc-skill-eval` — quality metric complements performance
- `nc-usage-telemetry` — production data to inform bench queries
- CI: weekly bench + drift alert
