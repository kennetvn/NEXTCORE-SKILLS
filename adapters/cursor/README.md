# Cursor Adapter

Ports NEXTCORE skills to [Cursor](https://cursor.com) IDE.

## Cursor specifics

- **Slash commands** live in `.cursor/commands/*.md`
- **Rules** live in `.cursor/rules/*.mdc` (MDC format, not used by NEXTCORE yet)
- **Invocation:** user types `/filename` in chat (e.g. `/nc-brainstorm`)
- **Frontmatter:** plain markdown + YAML frontmatter with `description:` (matches Antigravity)
- **No built-in subagents** — Cursor has one general agent; parallel work uses explicit agent invocation

## Available commands

33 slash commands ported from NEXTCORE skills:

**Core workflow:** nc-brainstorm, nc-research, nc-plan, nc-debug, nc-predict, nc-cook, nc-fix, nc-scout

**Documentation:** nc-docs, nc-docs-seeker, nc-mermaidjs-v11, nc-llms

**Design & UI:** nc-ui-styling, nc-ui-ux-pro-max, nc-web-design-guidelines, nc-frontend-development, nc-react-best-practices

**Backend & Infra:** nc-backend-development, nc-databases, nc-tanstack, nc-payment-integration

**Testing & Security:** nc-security, nc-scenario, nc-web-testing

**Media & AI:** nc-media-processing, nc-ai-multimodal, nc-copywriting, nc-preview

**Project ops:** nc-project-management, nc-project-organization, nc-retro, nc-journal, nc-watzup

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=cursor
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide cursor'
```

Manual:
```bash
mkdir -p .cursor/commands
cp -r adapters/cursor/commands/* .cursor/commands/
```

## Subagent mapping (Cursor has one general agent)

Content has been translated from Antigravity's built-in workflows to Cursor's single-agent model:

| Antigravity | Cursor equivalent |
|---|---|
| `ai-developer` workflow | the coding agent (Cursor's main agent) |
| `ai-tester` workflow | the testing agent (write + run tests) |
| `ai-ux-reviewer` workflow | the code review agent |

For parallel work (e.g. multi-file research), instruct Cursor to spawn sub-conversations or use multi-tab workflow.

## Source of truth

Adapter content is **derived** from `skills/` via `adapters/antigravity/converter.cjs` + additional Cursor-specific transforms. Don't edit adapter files as primary — update `skills/` and re-run the adapter build.

## References subdirectories

15 commands include a `references/` subdirectory (e.g. `nc-backend-development/references/`). Cursor's agent will read these when the main command points at them. They're copied automatically during install.

## Known limitations

- No structured task management (track via markdown checklists in chat)
- No hook system (CC-only concept)
- `.claude/.nc.json` config references fall back to defaults inline
- Some commands reference Claude Code-specific agents (e.g. `ai-team/*`) — content is interpretable but exact equivalents don't exist
