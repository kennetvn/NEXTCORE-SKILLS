# Zed AI Adapter

Ports NEXTCORE skills to Zed AI IDE.

## Zed AI specifics

Zed is a fast native editor with built-in AI (Claude Sonnet/Haiku default)

- **Prompts** live in `.zed/prompts/*.md`
- **Invocation:** varies per IDE — check your IDE's slash command / prompt library docs
- Derived from Cursor adapter (single-agent model)

## Available prompts

59 prompts + reference files, same content as Cursor adapter.

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=zed
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide zed'
```

## Source of truth

Derived from `adapters/cursor/commands/`. Edit `skills/` and re-run converter pipeline to regenerate.

## Known limitations

- Prompt file format may evolve per IDE — check latest docs
- No hook system (Claude Code only concept)
- Subagent refs resolve to the IDE's general agent
