---
name: nc:skill-eval
description: "LLM-as-judge evaluation harness for skill quality. Use to score skill effectiveness, validate skill description triggers correctly, detect skill drift over time, or benchmark skill variants (A/B)."
license: MIT
argument-hint: "[skill-name|run-all|compare]"
---

# Skill Evaluation

Measure skill quality, detect regression, compare variants.

## What to evaluate

1. **Trigger accuracy** — does description activate skill on right queries?
2. **Output quality** — does skill produce useful, accurate output?
3. **Token efficiency** — is skill body justified by value added?
4. **Composition** — does skill chain well with related skills?

## Test harness structure

```
skills/nc-plan/evals/
  ├── cases.yaml        # test cases (query → expected behavior)
  ├── baseline.json     # previous run scores
  └── results/          # per-run output
```

## Cases YAML format

```yaml
- name: "plans a full feature"
  query: "plan a real-time notifications feature"
  expected_skill: nc-plan
  expected_output_contains:
    - "phases"
    - "success criteria"
  forbidden_output:
    - "I'll do it right now"  # shouldn't skip to implementation
  min_score: 7

- name: "doesn't trigger for trivial"
  query: "rename variable x to y"
  expected_skill: null  # should NOT invoke nc-plan
  min_score: 8
```

## Evaluation prompt (LLM-as-judge)

```
You are grading an AI coding assistant's response to a user query.

Query: {query}
Skill invoked: {skill_name}
Response: {response}
Expected behavior: {expected}

Score 0-10:
- 10: exactly as expected, high quality
- 7: right direction, minor issues
- 5: partially useful, significant gaps
- 2: wrong approach but no harm
- 0: harmful or completely wrong

Return: { score: N, reasoning: "..." }
```

## Running evals

```bash
# Single skill
node scripts/run-eval.js --skill nc-plan

# All skills
node scripts/run-eval.js --all

# Compare variant
node scripts/run-eval.js --skill nc-plan --variant experimental
```

## Metrics tracked

Per skill:
- **Precision** — when invoked, how often was it right?
- **Recall** — when it should have been invoked, was it?
- **Avg score** — LLM judge's quality rating
- **Tokens used** — p50, p95 per invocation
- **Time-to-complete** — from invoke to done

## Regression detection

```
Run new evaluation → compare vs baseline.json

If avg_score drops > 1 point OR any test fails:
  → fail CI
  → require review before accepting skill change
```

## Skill A/B testing

For iterating on descriptions or body:

1. Create `skills/nc-plan-v2/` variant
2. Route 50% of test queries to each variant
3. Compare scores after N queries
4. Promote winner to replace current

## Judge model choice

- **Claude Opus 4** — highest quality judge, best for nuanced cases
- **Claude Sonnet 4** — balanced, most cases
- **GPT-4o** — independent perspective, catches Claude-specific bias
- **Gemini 2.5 Pro** — large context for multi-file eval

Use 2-3 judges, average scores — single judge is biased.

## Baseline + drift

Record baseline per skill at release:

```json
{
  "skill": "nc-plan",
  "version": "2.0.0",
  "baseline_date": "2026-04-18",
  "avg_score": 8.2,
  "precision": 0.91,
  "recall": 0.87
}
```

Weekly/monthly: rerun → alert if drift > threshold.

## Anti-patterns

- Evaluating skill without baseline (no comparison point)
- Single judge (bias)
- Tiny eval set (< 10 cases — low confidence)
- No adversarial cases (only happy path tested)
- Human-graded only (doesn't scale)

## Integration

- `nc-skill-bench` — measures performance (speed, tokens), complements this
- `nc-usage-telemetry` — production data to inform test cases
- CI pipeline: fail on regression
