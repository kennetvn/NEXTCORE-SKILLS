---
name: nc:ai-evaluation
description: "Evaluate LLM app quality empirically. Use when comparing models/prompts/RAG strategies, building eval datasets, choosing automated graders, detecting regressions in CI, or reporting accuracy to stakeholders."
license: MIT
argument-hint: "[design|grade|regress|report]"
---

# AI Evaluation Skill

If you can't measure it, you can't improve it. Vibes-based "this prompt is better" is how teams ship regressions.

## What you're measuring

| Metric | Question | When |
|---|---|---|
| **Accuracy** | Is the answer correct? | Q&A, extraction, classification |
| **Faithfulness** | Does the answer match the source? | RAG, summarization |
| **Format adherence** | Does output match schema? | Structured extraction |
| **Safety** | Refuses bad requests? | Jailbreak resistance |
| **Latency** | p50/p95 response time | UX-critical apps |
| **Cost per query** | $ per call | Budget planning |
| **Pass@K** | Does answer pass tests in K tries? | Code generation |

Pick 1-2 primary metrics + cost/latency. More than that, dashboard becomes noise.

## Eval dataset (the foundation)

Without a dataset, you have opinions. Build one before optimizing prompts.

### Construction

- **Size**: 50 examples minimum to detect changes; 200+ for confident decisions
- **Coverage**: include EASY, EDGE, and HARD cases (~40/40/20 split)
- **Diversity**: different lengths, languages, topics, edge cases
- **Source**: real user queries (anonymized) > synthetic
- **Labels**: ground-truth answers, written by domain expert
- **Versioning**: dataset is code; version it; track which model+prompt scored what

### File format

```yaml
# evals/booking-extraction-v1.yaml
description: "Extract booking ID, guest name, nights from natural-language messages"
metric: structured_match
examples:
  - id: easy-1
    input: "Booking #1234 for John, 2 nights"
    expected: { booking_id: "1234", guest_name: "John", nights: 2 }

  - id: edge-no-id
    input: "John booked 2 nights"
    expected: { booking_id: null, guest_name: "John", nights: 2 }

  - id: hard-multi
    input: "Cancel my prior booking 5678 and create new one for Maria, 4 nights"
    expected: { booking_id: "5678", guest_name: "Maria", nights: 4 }  # picks newest
```

## Grader options

### Exact match (cheapest)
```python
score = 1.0 if predicted == expected else 0.0
```
For structured output, classification, multiple-choice.

### Partial credit (structured)
```python
def grade(predicted: dict, expected: dict) -> float:
    keys = expected.keys()
    matches = sum(1 for k in keys if predicted.get(k) == expected[k])
    return matches / len(keys)
```

### Semantic similarity (for prose)
```python
score = cosine_similarity(embed(predicted), embed(expected))
# Threshold: typically > 0.85 = match
```

### LLM-as-judge (for free-form)
```
SYSTEM: You are an evaluator. Given a question, expected answer, and predicted
answer, score the prediction 0-5 on these criteria:
- Factual accuracy (matches expected facts)
- Completeness (covers all expected points)
- No hallucination (no facts not supported)

Output: { "accuracy": N, "completeness": N, "hallucination": N, "explanation": "..." }
```

LLM-as-judge: cheap to scale, but biased toward verbose / confident answers. Use cheaper model than what you're evaluating. Sample 20% of LLM-judged with humans to calibrate.

### Rule-based (regex / heuristics)
For format checks: "answer must contain a date in YYYY-MM-DD", "answer must be < 200 words", "answer must cite at least 2 sources".

## Regression detection in CI

```yaml
# .github/workflows/eval.yml
name: LLM Evals
on: [pull_request]
jobs:
  eval:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install -r evals/requirements.txt
      - run: python evals/run.py --dataset booking-v1 --against new
      - run: python evals/run.py --dataset booking-v1 --against baseline
      - run: python evals/compare.py --threshold 0.02  # fail if >2pp regression
```

Block merge on regression > threshold. Investigate before merging.

## Comparing prompts / models / RAG configs

```
For each variant (prompt-A, prompt-B, model-haiku, model-sonnet):
  For each eval example:
    predicted = run_pipeline(variant, example.input)
    score = grade(predicted, example.expected)
  Record: variant, mean_score, p25, p75, cost_total, latency_p95

Output table sorted by mean_score desc.
```

Don't just pick highest mean — also check:
- Cost: is the +2pp accuracy worth 5x cost?
- Latency: does p95 exceed UX budget?
- Worst-case: does it FAIL catastrophically on any example?
- Variance: is it reliable or "lucky on average"?

## Dataset hygiene

- **Train/eval split**: never include eval examples in your few-shot prompts (data leakage)
- **Refresh quarterly**: real-world distribution drifts
- **Track failure modes**: tag examples by failure category for targeted improvement
- **Anonymize**: no PII in eval datasets stored in repo
- **Hold-out test set**: separate ~10% never used for tuning, only for final report

## Reporting to non-technical stakeholders

Translate metrics into impact:

- "Accuracy went from 78% → 84%" → "Wrong answer rate cut from 1 in 5 to 1 in 6"
- "Latency p95 = 2.3s" → "95% of requests answer in under 2.3 seconds"
- "Cost = $0.0012/query" → "$1,200 per million queries"
- "Hallucination rate 4%" → "1 in 25 answers may contain unsupported claims"

Show progress over time as line chart. Show distribution (not just mean).

## Continuous eval (production monitoring)

For deployed apps, sample real traffic for ongoing eval:

```
1. Sample 1% of queries (PII-redacted) → log to eval bucket
2. Daily job: LLM-as-judge scores them
3. Weekly: dashboard of accuracy trend
4. Alert on: 7-day rolling accuracy drops > 3pp
```

Catches drift from: model API changes, user behavior shifts, retrieval staleness.

## Anti-patterns

- "Eval = trying 3 examples manually and feeling good"
- Same examples in few-shot AND eval (data leakage; inflated scores)
- LLM-as-judge with same model under test (self-rating bias)
- Optimizing for benchmark while UX gets worse
- One number ("85%") with no breakdown by category / difficulty
- No human spot-check on LLM-judged scores
- Eval that only runs locally (regressions ship to prod)
- Changing eval dataset to "fix" a regression (move the goalposts)

## Tool / framework picks

| Tool | When |
|---|---|
| **Hand-rolled Python** | <500 examples, simple metrics |
| **Inspect** (UK AISI) | Multi-step agent eval, structured |
| **Promptfoo** | Quick comparison across providers |
| **Phoenix / Arize** | Production observability + eval |
| **LangSmith** | If using LangChain |
| **Ragas** | RAG-specific (faithfulness, context recall) |

Start hand-rolled. Adopt a framework when you outgrow it.

## Integration

- `nc-prompt-engineering` — what you're evaluating (prompt variants)
- `nc-llm-integration` — the wrapper being tested
- `nc-rag-patterns` — eval RAG-specific metrics (recall, faithfulness)
- `nc-vector-db` — eval retrieval quality
- `nc-ci-cd` — CI integration for regression blocking
- `nc-observability` — production eval pipeline
- `nc-claude-api` — Anthropic message batching for cheap eval runs
