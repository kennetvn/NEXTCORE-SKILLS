# NEXTCORE Conventions for Aider

Include this file in Aider sessions via: `aider --read adapters/aider/conventions/nextcore-conventions.md`

## Principles

- **YAGNI · KISS · DRY** — simplest solution that works, no speculation
- **Be honest, brutal, concise** — say when something is wrong or over-engineered
- **Trust internal code** — validate at system boundaries only (user input, external APIs)
- **No emojis unless requested** — default terse engineering mode

## Code standards

- File size under 200 LOC (split when growing)
- kebab-case for JS/TS/Python/shell; respect language conventions elsewhere
- Self-documenting names over comments
- No trailing summaries, no narration — show the diff and stop

## Skill slash commands (prompt library)

Load specific NEXTCORE workflows via `/load` or `--read`:

| Workflow | Purpose | File |
|---|---|---|
| Brainstorm | Trade-off analysis | `adapters/aider/prompts/nc-brainstorm.md` |
| Plan | Feature implementation plan | `adapters/aider/prompts/nc-plan.md` |
| Debug | Root cause analysis | `adapters/aider/prompts/nc-debug.md` |
| Fix | Bugfix workflow | `adapters/aider/prompts/nc-fix.md` |
| Cook | Feature implementation | `adapters/aider/prompts/nc-cook.md` |
| Research | Multi-source tech research | `adapters/aider/prompts/nc-research.md` |
| Security | STRIDE + OWASP audit | `adapters/aider/prompts/nc-security.md` |

See `adapters/aider/prompts/` for full list (33 prompts).

## Aider-specific workflow integration

1. Start Aider with NextCore conventions loaded:
   ```bash
   aider --read adapters/aider/conventions/nextcore-conventions.md
   ```

2. When starting a task, load relevant workflow:
   ```bash
   /read adapters/aider/prompts/nc-plan.md
   ```

3. Then describe your task. Aider's agent will follow the NEXTCORE workflow.

## File output conventions

Reports go to `plans/reports/{type}-{YYMMDD}-{HHMM}-{slug}.md`.

Plans go to `plans/{YYMMDD-HHMM}-{slug}/`.

Use kebab-case slugs.
