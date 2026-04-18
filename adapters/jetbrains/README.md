# JetBrains AI (Junie) Adapter

Ports NEXTCORE skills to JetBrains IDEs via [Junie](https://junie.jetbrains.com) (the AI Assistant in IntelliJ, WebStorm, PyCharm, GoLand, Rider, etc.).

## JetBrains/Junie specifics

**Junie does NOT use per-workflow slash commands** (unlike Cursor, Antigravity, Windsurf). Instead, Junie loads a **single guidelines file** at project start:

- Primary: `.junie/AGENTS.md` (preferred standard)
- Fallback: `.junie/guidelines.md`
- Global: Custom path in Settings → Tools → Junie → Project Settings

## How NEXTCORE works here

Two install modes (choose ONE):

### Mode 1: Standing guidelines (recommended)

`.junie/AGENTS.md` aggregates all 59 workflows into a single standing-context file. Junie reads it at session start; your prompts can reference workflow names like "follow nc-plan workflow" and Junie will recall the relevant section.

### Mode 2: UI prompt library import

Individual workflows are available at `.junie/prompts/nc-*.md`. You can import them manually into Junie's UI Prompt Library (Settings → Tools → AI Assistant → Prompt Library → Add prompt).

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=jetbrains
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide jetbrains'
```

Manual:
```bash
mkdir -p .junie/prompts
cp adapters/jetbrains/.junie/AGENTS.md .junie/
cp -r adapters/jetbrains/.junie/prompts/* .junie/prompts/
```

## Supported JetBrains IDEs

Junie is available in:
- IntelliJ IDEA · WebStorm · PyCharm · PhpStorm · Rider · GoLand · RubyMine · CLion · DataGrip · AppCode

## Source of truth

Derived from `adapters/cursor/commands/` aggregated into AGENTS.md.
Individual prompt files preserved in `.junie/prompts/` for UI import.

## Known limitations

- Junie has no slash-command picker — reference workflows by name in prompts
- AGENTS.md size affects context budget — large file may push out other context
- MCP config goes in `.junie/mcp/mcp.json` (separate from NEXTCORE)
