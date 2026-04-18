# JetBrains AI Adapter

Ports NEXTCORE skills to JetBrains AI IDE.

## JetBrains AI specifics

JetBrains AI Assistant supports prompt library in IntelliJ/WebStorm/PyCharm

- **Prompts** live in `.idea/ai-prompts/*.md`
- **Invocation:** varies per IDE — check your IDE's slash command / prompt library docs
- Derived from Cursor adapter (single-agent model)

## Available prompts

59 prompts + reference files, same content as Cursor adapter.

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=jetbrains
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide jetbrains'
```

## Source of truth

Derived from `adapters/cursor/commands/`. Edit `skills/` and re-run converter pipeline to regenerate.

## Known limitations

- Prompt file format may evolve per IDE — check latest docs
- No hook system (Claude Code only concept)
- Subagent refs resolve to the IDE's general agent
