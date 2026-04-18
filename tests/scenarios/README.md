# Scenario Tests

Manual / LLM-graded test scenarios. Each file = one user-flow simulation.

## Format

```markdown
# Scenario: <name>

**Triggers:** which skills should activate
**User profile:** persona, language, level
**Setup:** state before the conversation

## Turn 1
**User:** <input>
**Expected behavior:**
- <bullet 1>
- <bullet 2>
**Anti-patterns to avoid:**
- <thing agent must NOT do>

## Turn 2
...

## Pass criteria
- <observable outcome 1>
- <observable outcome 2>
```

## Index

| File | Tests | Skills |
|---|---|---|
| `onboard-new-user.md` | First-run UX | nc-onboard, nc-persona, nc-memory |
| `frustration-pattern.md` | Sentiment + clarity under stress | nc-sentiment, nc-clarify |
| `vocab-mirror.md` | Terminology mirroring | nc-mirror, nc-explain |
| `community-contribute.md` | Gap detection + PR flow | nc-contribute, nc-skill-announce |
| `company-os-feature-cycle.md` | Org-roles for big feature | nc-company-os, nc-plan, nc-cook |
| `install-tweaks-pnpm.md` | Per-install customization | nc-install-tweaks |
| `multilang-vn-en.md` | Mixed VN/EN persistence | nc-persona, nc-mirror, nc-memory |
| `frustrated-explain.md` | Sentiment overrides explain depth | nc-sentiment, nc-explain |

## Running

For now: manual. Read each scenario, run the prompt against an agent that has the skills installed, compare outcome to expectations.

Future: LLM-graded harness via `scripts/eval-scenarios.cjs` (planned v3.0.0).
