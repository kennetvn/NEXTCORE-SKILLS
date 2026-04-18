# Aider Adapter

Ports NEXTCORE skills to [Aider](https://aider.chat) CLI.

## Aider specifics

- **CLI tool** (not IDE extension) — run `aider` in terminal
- **No slash commands directory** — workflows loaded via `--read` flag or `/read` command
- **Conventions:** `adapters/aider/conventions/nextcore-conventions.md` is a standing context file
- **Per-workflow prompts:** `adapters/aider/prompts/*.md` loaded on demand
- **No subagents** — Aider has one general conversation; multi-file work via `/add` + chat

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=aider
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide aider'
```

Manual:
```bash
mkdir -p .aider/nextcore
cp adapters/aider/conventions/*.md .aider/nextcore/
cp -r adapters/aider/prompts/* .aider/nextcore/prompts/
```

## Usage

Start Aider with NEXTCORE conventions loaded as standing context:

```bash
aider --read .aider/nextcore/nextcore-conventions.md
```

When starting a specific task, load the relevant workflow:

```
/read .aider/nextcore/prompts/nc-plan.md
Now plan: <your task>
```

Aider's LLM reads the workflow as instructions and follows it.

## Auto-load via .aider.conf.yml

Put in project root for auto-loading:

```yaml
read:
  - .aider/nextcore/nextcore-conventions.md
```

## Source of truth

Prompts are copied from `adapters/cursor/commands/` (single-agent model).
Conventions file is NEXTCORE-authored.

## Known limitations

- No built-in slash command picker — user must `/read` each workflow
- No visual workflow discovery — rely on README + `ls` in `.aider/nextcore/prompts/`
- Reference files stored alongside prompts; `/read` each as needed
