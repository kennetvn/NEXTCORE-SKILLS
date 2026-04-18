# Continue.dev Adapter

Ports NEXTCORE skills to [Continue.dev](https://continue.dev) IDE extension.

## Continue.dev specifics

- **Prompts** live in `.continue/prompts/*.md` (or `.prompt.md`)
- **Rules** live in `.continue/rules/*.md` (not used by NEXTCORE adapter)
- **Invocation:** user types `/filename` in Continue chat
- **Frontmatter:** `description:` shown in slash picker; content is plain markdown
- **Config:** managed via `config.yaml` or `config.json` at workspace/global level
- **No built-in subagents** — Continue has one general agent

## Available prompts

33 prompts, same content as Cursor adapter (single-agent model).

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=continue
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide continue'
```

Manual:
```bash
mkdir -p .continue/prompts
cp -r adapters/continue/prompts/* .continue/prompts/
```

## Enabling prompt files in Continue

Ensure your `config.yaml` includes (default paths are usually auto-discovered):

```yaml
prompts:
  - name: nextcore
    path: .continue/prompts
```

Restart Continue. Type `/` in chat to see available prompts.

## Source of truth

Derived from `adapters/cursor/commands/` (single-agent compatible).

## Known limitations

- Continue.dev config schema evolves — check latest docs
- No structured task management (track via markdown checklists)
- Subagent refs resolve to "the agent" (Continue's general agent)
