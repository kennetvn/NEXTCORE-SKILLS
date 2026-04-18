# Void Editor Adapter

Ports NEXTCORE skills to [Void](https://voideditor.com) — open-source VS Code fork with native AI support.

## Void specifics

Void is a VS Code fork — it inherits VS Code's conventions where possible but exposes its own Agent Mode with MCP tool support.

**No first-class prompts directory yet (as of 2026-04):** Void uses VS Code–style settings.json + its own Agent Mode. NEXTCORE ships both:

1. `AGENTS.md` at project root — standing context (similar to Aider/JetBrains pattern), picked up by Void agents as session guidance
2. `.vscode/prompts/nc-*.md` — individual workflow files (placeholder — Void may adopt the Copilot prompt file format over time)

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=void
```

Manual:
```bash
mkdir -p .vscode/prompts
cp adapters/void/AGENTS.md .
cp -r adapters/void/.vscode/prompts/* .vscode/prompts/
```

## Usage

In Void's Agent Mode chat, reference workflows by name:
- "Follow the nc-plan workflow to design X"
- "Use nc-debug to investigate this bug"

Void reads `AGENTS.md` as session context; the agent will look up the relevant workflow section.

## Source of truth

Derived from `adapters/cursor/commands/` + `adapters/jetbrains/.junie/AGENTS.md`.

## Known limitations

- Void is evolving fast — prompt file format may change
- No slash command picker for NEXTCORE-specific workflows
- If Void adopts Copilot's `.prompt.md` format, these files will work natively
