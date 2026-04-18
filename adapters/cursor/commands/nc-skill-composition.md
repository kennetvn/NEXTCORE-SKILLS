---
description: Chain multiple skills without duplicate analysis. Use when a task spans multiple skill domains (plan + debug + fix + test), when composing workflows, or when skills would repeat each other's work.
---

# Skill Composition Patterns

Chain skills so each phase builds on prior output — no redundant re-analysis.

## Canonical pipelines

### Full feature pipeline

`nc-brainstorm` → `nc-plan` → `nc-predict` → `nc-cook` → `nc-test` → `nc-security` → ship

Each phase:
1. Reads prior phase output (plan.md, research-report.md)
2. Adds its own layer (plan adds phases, cook adds code, test adds tests)
3. Writes structured output for next phase

### Bug fix pipeline

`nc-debug` → `nc-fix` → `nc-test` → commit

Short-circuit for trivial bugs: skip brainstorm, skip plan.

### Research-heavy pipeline

`nc-research` (subagent) → `nc-brainstorm` → `nc-plan` → implementation

Research produces summary; brainstorm consumes summary (not raw research output).

## Context handoff protocol

### Shared state files

Skills communicate via project files, NOT re-analysis:

- `plans/{YYMMDD-HHMM}-{slug}/plan.md` — plan-level context
- `plans/reports/research-*.md` — research conclusions
- `plans/reports/debug-*.md` — debug findings
- `plans/reports/predict-*.md` — pre-implementation debate

Each skill:
1. Reads prior artifacts
2. Trusts them (don't re-verify unless evidence of staleness)
3. Writes its own artifact for next skill

### What NOT to pass via prompt

Don't re-summarize research into the next skill's invocation prompt. Instead:

- Pass: file path reference ("see plans/reports/research-260418-foo.md")
- Skill reads file directly — one source of truth

## Anti-duplication patterns

### Don't re-scout

If `nc-scout` ran 5 minutes ago, trust its findings. Re-scout only if code changed or findings seem stale.

### Don't re-brainstorm after plan

Plan is the commitment. Don't revisit options mid-implementation unless hard blocker emerges.

### Don't re-debug after fix

Fix verifies via test. Don't re-run debug workflow unless test reveals misdiagnosis.

## Composition decision tree

```
Is task trivial (<3 steps)? → Direct execute, skip composition
Is task bounded (1 domain)? → Single skill
Is task multi-phase? → Compose pipeline
  Is research needed? → nc-research first
  Is design decision needed? → nc-brainstorm
  Is implementation planned? → nc-plan
  Is risk high? → nc-predict before cook
  Is implementation? → nc-cook
  Is testing? → nc-test
  Is security sensitive? → nc-security
```

## Short-circuit patterns

### Quick fix (<30 lines)

User says "fix X typo" → direct edit, no composition needed.

### Pure research

User says "research X" → `nc-research` alone, no plan/cook.

### Pure design

User says "design X" → `nc-brainstorm` alone, terminate when design approved.

## Composition size limits

Long pipelines burn context. Budget per phase:

- Research phase: 20-30K tokens
- Plan phase: 10-20K
- Implementation phase: 40-60K (largest)
- Test phase: 10-20K
- Total per feature: 80-130K

If budget exceeds 60%, split into 2 sessions:
- Session 1: brainstorm + plan + research → save plan
- Session 2: fresh session → cook + test from saved plan

## Anti-patterns

- **Re-running skill that already ran with same input** — cache output via file
- **Full pipeline for trivial task** — skip to direct action
- **Ignoring prior artifacts** — defeats composition purpose
- **Verbose handoff prompts** — use file references instead

## Integration

- `nc-context-budget` — when to split pipeline across sessions
- `nc-parallel-dispatch` — parallelize independent phases (e.g., research + predict)
- `nc-router` — route user intent to correct starting skill
