---
description: Analyze codebase and manage project documentation — init, update, summarize.
auto_execution_mode: 1
---

# Documentation Management

Analyze codebase and manage project documentation through scouting, analysis, and structured doc generation.

**IMPORTANT:** follow the `nc-project-organization` workflow to organize the outputs.

## Default (No Arguments)

If invoked without arguments, ask the user in chat to present available documentation operations:

| Operation | Description |
|-----------|-------------|
| `init` | Analyze codebase & create initial docs |
| `update` | Analyze changes & update docs |
| `summarize` | Quick codebase summary |

Present as options via chat question with header "Documentation Operation", question "What would you like to do?".

## Subcommands

| Subcommand | Reference | Purpose |
|------------|-----------|---------|
| `/nc-docs init` | `nc-docs/references/init-workflow.md` | Analyze codebase and create initial documentation |
| `/nc-docs update` | `nc-docs/references/update-workflow.md` | Analyze codebase and update existing documentation |
| `/nc-docs summarize` | `nc-docs/references/summarize-workflow.md` | Quick analysis and update of codebase summary |

## Routing

Parse `$ARGUMENTS` first word:
- `init` → Load `nc-docs/references/init-workflow.md`
- `update` → Load `nc-docs/references/update-workflow.md`
- `summarize` → Load `nc-docs/references/summarize-workflow.md`
- empty/unclear → chat question (do not auto-run `init`)

## Shared Context

Documentation lives in `./docs` directory:
```
./docs
├── project-overview-pdr.md
├── code-standards.md
├── codebase-summary.md
├── design-guidelines.md
├── deployment-guide.md
├── system-architecture.md
└── project-roadmap.md
```

Use `docs/` directory as the source of truth for documentation.

**IMPORTANT**: **Do not** start implementing code.
