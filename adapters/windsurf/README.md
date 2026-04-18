# Windsurf Adapter

Ports NEXTCORE skills to [Windsurf](https://windsurf.com) IDE.

## Windsurf specifics

- **Workflows** live in `.windsurf/workflows/*.md`
- **Rules** live in `.windsurf/rules/*.md` (not used by NEXTCORE adapter)
- **Invocation:** user types `/filename` in chat (e.g. `/nc-brainstorm`)
- **Frontmatter:**
  - `description:` — shown in slash-command picker
  - `auto_execution_mode:` — 1=manual (default), 2=auto-execute commands, 3=auto-accept edits
- NEXTCORE workflows ship with `auto_execution_mode: 1` for safety — user approves each step
- **No built-in subagents** — Windsurf's Cascade handles parallel work via multi-tab sessions

## Install

Automated:
```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=windsurf
```

Windows PowerShell:
```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide windsurf'
```

Manual:
```bash
mkdir -p .windsurf/workflows
cp -r adapters/windsurf/workflows/* .windsurf/workflows/
```

## Available workflows

33 workflows same as Cursor adapter — identical content, only frontmatter differs (Windsurf adds `auto_execution_mode`).

## Turbo mode

Change `auto_execution_mode: 1` → `2` or `3` per workflow if you want auto-execution:

- `1` = Manual (default, safest) — user reviews each action
- `2` = Auto-execute bash/tool commands without approval
- `3` = Auto-accept all edits + commands (aggressive, only for low-risk workflows)

## Source of truth

Derived from `adapters/cursor/commands/` which is derived from `adapters/antigravity/workflows/` which is converted from `skills/`. Don't edit adapter files as primary — update `skills/` and re-run the chain.

## Known limitations

- No hook system (CC-only concept)
- No structured task management (track via markdown checklists)
- `.claude/.nc.json` config references fall back to defaults inline
