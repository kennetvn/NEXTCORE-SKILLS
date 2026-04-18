---
description: Bootstrap new projects with research, tech stack, design, planning, and implementation. Modes: full (interactive), auto (default), fast (skip research), parallel (multi-agent).
---

# Bootstrap - New Project Scaffolding

End-to-end project bootstrapping from idea to running code.

**Principles:** YAGNI, KISS, DRY | Token efficiency | Concise reports

## Usage

```
/nc-bootstrap <user-requirements>
```

**Flags** (optional, default `--auto`):

| Flag | Mode | Thinking | User Gates | Planning Skill | Cook Skill |
|------|------|----------|------------|----------------|------------|
| `--full` | Full interactive | Ultrathink | Every phase | `--hard` | (interactive) |
| `--auto` | Automatic | Ultrathink | Design only | `--auto` | `--auto` |
| `--fast` | Quick | Think hard | None | `--fast` | `--auto` |
| `--parallel` | Multi-agent | Ultrathink | Design only | `--parallel` | `--parallel` |

**Example:**
```
/nc-bootstrap "Build a SaaS dashboard with auth" --fast
/nc-bootstrap "E-commerce platform with Stripe" --parallel
```

## Workflow Overview

```
[Git Init] → [Research?] → [Tech Stack?] → [Design?] → [Planning] → [Implementation] → [Test] → [Review] → [Docs] → [Onboard] → [Final]
```

Each mode loads a specific workflow reference + shared phases.

## Mode Detection

If no flag provided, default to `--auto`.

Load the appropriate workflow reference:
- `--full`: Load `nc-bootstrap/references/workflow-full.md`
- `--auto`: Load `nc-bootstrap/references/workflow-auto.md`
- `--fast`: Load `nc-bootstrap/references/workflow-fast.md`
- `--parallel`: Load `nc-bootstrap/references/workflow-parallel.md`

All modes share: Load `nc-bootstrap/references/shared-phases.md` for implementation through final report.

## Step 0: Git Init (ALL modes)

Check if Git initialized. If not:
- `--full`: Ask user if they want to init → `git-manager` subagent (`main` branch)
- Others: Auto-init via `git-manager` subagent (`main` branch)

## Skill Triggers (MANDATORY)

After early phases (research, tech stack, design), trigger downstream skills:

### Planning Phase
Activate **nc-plan** skill with mode-appropriate flag:
- `--full` → `/nc-plan --hard <requirements>` (thorough research + validation)
- `--auto` → `/nc-plan --auto <requirements>` (auto-detect complexity)
- `--fast` → `/nc-plan --fast <requirements>` (skip research)
- `--parallel` → `/nc-plan --parallel <requirements>` (file ownership + dependency graph)

Planning skill outputs a plan path. Pass this to cook.

### Implementation Phase
Activate **nc-cook** skill with the plan path and mode-appropriate flag:
- `--full` → `/nc-cook <plan-path>` (interactive review gates)
- `--auto` → `/nc-cook --auto <plan-path>` (skip review gates)
- `--fast` → `/nc-cook --auto <plan-path>` (skip review gates)
- `--parallel` → `/nc-cook --parallel <plan-path>` (multi-agent execution)

## Role

Elite software engineering expert specializing in system architecture and technical decisions. Brutally honest about feasibility and trade-offs.

## Critical Rules

- follow the `relevant` workflows from catalog during the process
- Keep all research reports ≤150 lines
- All docs written to `./docs` directory
- Plans written to `./plans` directory using naming from `## Naming` section (if injected; otherwise fallback: `plans/reports/{type}-{YYMMDD}-{HHMM}-{slug}.md`)
- DO NOT implement code directly — delegate through planning + cook skills
- Sacrifice grammar for concision in reports
- List unresolved questions at end of reports
- Run `/nc-journal` to write a concise technical journal entry upon completion

## References

- `nc-bootstrap/references/workflow-full.md` - Full interactive workflow
- `nc-bootstrap/references/workflow-auto.md` - Auto workflow (default)
- `nc-bootstrap/references/workflow-fast.md` - Fast workflow
- `nc-bootstrap/references/workflow-parallel.md` - Parallel workflow
- `nc-bootstrap/references/shared-phases.md` - Common phases (implementation → final report)
