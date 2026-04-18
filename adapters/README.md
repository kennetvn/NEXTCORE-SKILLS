# NEXTCORE-SKILLS — Cross-IDE Adapters

Skills are authored in **Claude Code** format (`skills/{name}/SKILL.md`), but skill *content* is plain markdown — portable to any IDE that loads instructional markdown.

This directory holds per-IDE adapters that package NEXTCORE skills for other AI coding IDEs.

## Layered architecture

```
skills/{name}/
  SKILL.md              ← Source of truth (Claude Code frontmatter + content)
  references/*.md       ← Portable content (no IDE-specific syntax)
adapters/
  antigravity/
    workflows/          ← Converted .agent/workflows/ markdown
    README.md           ← Install + quirks
  cursor/               ← (planned) .cursor/rules/*.mdc
  windsurf/             ← (planned) .windsurfrules fragments
  copilot/              ← (planned) .github/copilot-instructions.md pieces
```

## What's portable vs. not

| Capability | Portable? | Notes |
|---|---|---|
| Instructional content (prose, process, principles) | Yes | 1:1 copy with syntax adjustments |
| Frontmatter `description` | Yes | Most IDEs use similar hint |
| Slash command invocation | Partial | Name differs per IDE (`/nc:plan` vs workflow filename) |
| Claude Code `Skill` tool | No | Convert to "invoke workflow X" prose |
| Subagent dispatch (`Task`/`Agent`) | No | Map to IDE's equivalent or inline the steps |
| Hooks (session-init, post-edit) | No | IDE-specific; skip for other IDEs |
| `.claude/.nc.json` config reads | Partial | Document fallback if config absent |

## Per-skill portability status

Quick take (formal manifest per skill forthcoming):

- **Fully portable** (content-only, no tool calls): brainstorm, research, docs, docs-seeker, mermaidjs-v11, ui-ux-pro-max, react-best-practices
- **Portable with rewrite** (light subagent refs): nc-plan, nc-debug, nc-scenario, nc-security, cook, fix
- **Claude Code only** (heavy hook/subagent dependency): team, nc-autoresearch, kanban, plans-kanban

## Adding a new adapter

1. Create `adapters/{ide}/`
2. Write `README.md` documenting IDE-specific file paths, frontmatter format, slash command conventions
3. Convert skills one at a time — start with "fully portable" list
4. Update `install.sh` / `install.ps1` to handle `--ide={ide}` flag

## Source of truth

`skills/` is always authoritative. Adapters are **derived** — if a skill changes, re-convert the adapter file. Never edit adapter files as primary.
