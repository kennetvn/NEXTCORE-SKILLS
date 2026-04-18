# GitHub Copilot Adapter

Ports NEXTCORE skills to [GitHub Copilot](https://github.com/features/copilot) via VS Code extension.

## Copilot specifics

- **Prompt files** live in `.github/prompts/*.prompt.md`
- **Invocation:** user types `/promptname` in Copilot Chat
- **Frontmatter:**
  - `description:` — shown in slash-command picker
  - `mode:` — `agent` (full tool access), `edit` (file edits only), `ask` (chat only)
- NEXTCORE prompts ship with `mode: agent` for full capability
- **Parallel work:** Copilot's agent handles multi-file operations natively

## Available prompts

33 prompt files matching all NEXTCORE slash commands, same content as Antigravity/Cursor/Windsurf adapters.

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=copilot
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide copilot'
```

Manual:
```bash
mkdir -p .github/prompts
cp -r adapters/copilot/prompts/* .github/prompts/
```

## Enabling prompt files in VS Code

Prompt files are in preview. Enable via settings.json:

```json
{
  "chat.promptFiles": true,
  "chat.promptFilesLocations": [
    ".github/prompts"
  ]
}
```

Then reload VS Code. Type `/` in Copilot Chat to see available prompts.

## Source of truth

Derived from `adapters/cursor/commands/`. Edit `skills/` and re-run converter + Cursor+Copilot pipeline to regenerate.

## Known limitations

- Prompt files are a VS Code Copilot preview feature (2026) — syntax may evolve
- No hook system (CC-only concept)
- No structured task management (track via markdown checklists)
- Subagent refs resolve to "the agent" (Copilot's general agent)

## Alternative: copilot-instructions.md

If you want NEXTCORE guidance loaded **always** (not via slash commands), aggregate key skills into `.github/copilot-instructions.md`:

```bash
cat adapters/copilot/prompts/nc-brainstorm.prompt.md \
    adapters/copilot/prompts/nc-plan.prompt.md \
    adapters/copilot/prompts/nc-debug.prompt.md \
    > .github/copilot-instructions.md
```

This is **always-on** guidance, not slash-invoked. Use sparingly — too much bloat hurts response quality.
