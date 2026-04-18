# NEXTCORE-SKILLS

> File-based enhancement framework for Claude Code — 81 skills, 15 hooks, slash commands, agents, output styles. Purpose-built for Vietnamese SMB tooling (hotel booking, Facebook group automation, Chrome extension development, VPS operations).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

---

## Quick install

### Linux / macOS / Git Bash

```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash
```

### Windows PowerShell

```powershell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex
```

### Manual clone

```bash
git clone https://github.com/kennetvn/NEXTCORE-SKILLS.git /tmp/ncskills
bash /tmp/ncskills/install.sh --target=./.claude
```

After install, **restart Claude Code** to load new skills/hooks.

---

## What's inside

```
.claude/                         (target directory after install)
├── settings.json                # Hook registration + statusline command
├── statusline.cjs               # Custom status line renderer
├── .nc.json                     # Project config (plan naming, limits, flags)
├── metadata.json                # Install metadata + file deletions tracker
├── .env.example                 # Optional env vars template
│
├── hooks/                       # 15 Node CJS scripts on CC events
│   ├── session-init.cjs
│   ├── dev-rules-reminder.cjs
│   ├── skill-dedup.cjs
│   ├── privacy-block.cjs
│   ├── scout-block.cjs
│   ├── plan-format-kanban.cjs
│   └── lib/nc-config-utils.cjs
│
├── skills/                      # 81 specialized skills
│   ├── nc-plan/                 # Planning with phases
│   ├── nc-debug/                # Systematic debugging
│   ├── nc-security/             # STRIDE/OWASP audit
│   ├── nc-scenario/             # Edge case generation
│   ├── nc-predict/              # Pre-implementation review
│   ├── nc-autoresearch/         # Iterative optimization loop
│   ├── nc-help/                 # Skill discovery
│   ├── nextcore-design/         # NextCore CSS class convention
│   ├── nextjs-api/              # Next.js 16 API + Prisma + CORS
│   ├── prisma-helper/           # Safe Prisma migrations
│   ├── facebook-dom/            # FB DOM interaction SDK
│   ├── chrome-extension-dev/    # Manifest V3 patterns
│   ├── deploy-vps/              # VPS deployment workflows
│   └── ... (73 more)
│
├── agents/                      # 14 subagent definitions
├── commands/                    # Custom slash commands
├── output-styles/               # Tone presets
├── rules/                       # Auto-injected rules
└── schemas/                     # JSON schemas
```

---

## Core slash commands

| Command | Purpose |
|---|---|
| `/nc:plan <task>` | Create implementation plan with phases |
| `/nc:debug <issue>` | Root-cause analysis before fix |
| `/nc:predict <change>` | 5-persona adversarial review |
| `/nc:scenario <feature>` | Generate edge cases across 12 dimensions |
| `/nc:security` | STRIDE + OWASP vulnerability audit |
| `/nc:autoresearch` | Autonomous iterative optimization loop |
| `/nc:help` | Skill discovery and quick reference |

---

## Configuration

Edit `.claude/.nc.json`:

```json
{
  "$schema": "./schemas/nc-config.schema.json",
  "statusline": "full",
  "docs": { "maxLoc": 800 },
  "plan": {
    "namingFormat": "{date}-{issue}-{slug}",
    "dateFormat": "YYMMDD-HHmm"
  },
  "privacyBlock": true,
  "codingLevel": -1
}
```

---

## Compatibility matrix

| IDE / Agent | Status | Notes |
|---|---|---|
| **Claude Code** CLI / desktop / web | ✅ Full support | Primary target — all features work |
| **Claude Code** VS Code / JetBrains plugin | ✅ Full support | Same `.claude/` directory |
| **Cursor** | ⚠️ Skills only (Phase 2) | Port to `.cursor/rules/*.mdc`. Hooks not portable |
| **Continue.dev** | ⚠️ Skills only (Phase 2) | Port to Continue slash format |
| **Windsurf** | ⚠️ Skills only (Phase 2) | Port to `.windsurfrules` |
| **GitHub Copilot** | ⚠️ Content only (Phase 2) | Port to `.github/copilot-instructions.md` |
| **Aider / Claude API apps** | ℹ️ Reference only | Skills as prompt templates |

### Why hooks don't cross-port

Hooks are Node CJS scripts fired by Claude Code's specific event lifecycle (SessionStart, UserPromptSubmit, PreToolUse, Stop, SubagentStart). Other IDEs don't expose equivalent hook points — runtime behaviors (rule injection, secret blocking, skill dedup) are Claude Code-exclusive.

**Skill content** (prompts, playbooks, references) IS portable — Phase 2 adapters will extract skill markdown into each IDE's native format.

---

## How skills work

Claude Code scans `.claude/skills/*/SKILL.md` at startup. YAML frontmatter:

```yaml
---
name: nc:your-skill
description: What it does + when to trigger. Max 200 chars.
license: MIT
metadata:
  author: yourname
  version: "1.0.0"
---

# Body — markdown Claude follows when triggered
```

Claude picks skills by `description` matching user query. Good descriptions have:
- Clear verb (build, debug, audit, generate)
- Domain keywords (API, React, MySQL, SSH)
- Trigger phrases

### Creating a new skill

1. Create folder `.claude/skills/nc-myskill/`
2. Add `SKILL.md` with frontmatter + body
3. Restart Claude Code → auto-discovered

---

## How hooks work

Hooks are JS files in `settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup|resume|clear|compact",
      "hooks": [{
        "type": "command",
        "command": "node .claude/hooks/session-init.cjs"
      }]
    }]
  }
}
```

Each script:
- Reads JSON event from stdin
- Exit 0=continue, non-zero=block
- Prints to stdout → injected into Claude context
- Uses `hooks/lib/nc-config-utils.cjs` for config

---

## Update

```bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --update
```

Update mode preserves `.nc.json`, `.env`, `settings.local.json`, user-added skills/hooks.

---

## Uninstall

```bash
bash .claude/uninstall.sh              # moves to .claude.removed.<timestamp>
bash .claude/uninstall.sh --keep-config  # preserves user config
```

---

## Contributing

PRs welcome. Each new skill should:
- Have focused, non-overlapping scope
- Have a precise description matching natural queries
- Work offline (no required API keys)
- Not duplicate existing skills

See [ROADMAP.md](./ROADMAP.md) for the path toward full independence and cross-IDE support.

---

## Roadmap

### Phase 1 — NOW (Claude Code complete)
- ✅ Rebrand ck → nc (75 skills)
- ✅ Duplicate consolidation
- ✅ Install scripts (bash + PowerShell)
- ✅ Attribution (LICENSE + CREDITS)

### Phase 2 — Q3 2026 (Cross-IDE)
- [ ] Cursor adapter
- [ ] Continue.dev adapter
- [ ] Windsurf adapter
- [ ] Copilot adapter
- [ ] Skill marketplace UI

### Phase 3 — TBD (Platform)
- [ ] Community skill registry
- [ ] Version pinning + compat matrix

---

## License

MIT. See [LICENSE](./LICENSE). Upstream attribution in [CREDITS.md](./CREDITS.md).

---

## Links

- **Repo:** https://github.com/kennetvn/NEXTCORE-SKILLS
- **Issues:** https://github.com/kennetvn/NEXTCORE-SKILLS/issues
- **Roadmap:** [ROADMAP.md](./ROADMAP.md)
- **Claude Code:** https://docs.claude.com/claude-code
