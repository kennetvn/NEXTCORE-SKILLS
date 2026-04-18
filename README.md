# NEXTCORE-SKILLS

> Cross-IDE AI workflow framework — 66 skills as slash commands across **5 AI IDEs**. Purpose-built for Vietnamese SMB tooling (hotel booking, Facebook group automation, Chrome extension development, VPS operations).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

**Supported IDEs:** Claude Code · Antigravity · Cursor · Windsurf · GitHub Copilot

---

## Quick install

Pick your IDE:

| IDE | Linux / macOS / Git Bash | Windows PowerShell |
|---|---|---|
| **Claude Code** (full framework) | `curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh \| bash` | `iwr -useb .../install.ps1 \| iex` |
| **Antigravity** | `curl -sSL .../install.sh \| bash -s -- --ide=antigravity` | `iwr -useb .../install.ps1 \| iex -Args '-Ide antigravity'` |
| **Cursor** | `curl -sSL .../install.sh \| bash -s -- --ide=cursor` | `iwr -useb .../install.ps1 \| iex -Args '-Ide cursor'` |
| **Windsurf** | `curl -sSL .../install.sh \| bash -s -- --ide=windsurf` | `iwr -useb .../install.ps1 \| iex -Args '-Ide windsurf'` |
| **GitHub Copilot** | `curl -sSL .../install.sh \| bash -s -- --ide=copilot` | `iwr -useb .../install.ps1 \| iex -Args '-Ide copilot'` |

Replace `.../` with the full URL: `https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/`

After install, restart your IDE to load the new skills/workflows.

---

## What you get per IDE

| Feature | Claude Code | Antigravity | Cursor | Windsurf | Copilot |
|---|:---:|:---:|:---:|:---:|:---:|
| Slash commands | ✅ 66 | ✅ 33 | ✅ 33 | ✅ 33 | ✅ 33 |
| Reference docs per skill | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hooks (session, privacy, scout-block) | ✅ | — | — | — | — |
| Subagents | ✅ | via `ai-team/*` | general agent | Cascade | Copilot agent |
| Install target | `.claude/` | `.agent/workflows/` | `.cursor/commands/` | `.windsurf/workflows/` | `.github/prompts/` |

Claude Code is the source of truth — other IDEs get skill **content** (portable markdown); hooks/subagents are Claude Code exclusive.

---

## Skill catalog (highlights)

**Mandatory workflow skills** — activate before coding:
- `nc-cook` — before every feature/plan implementation
- `nc-fix` — before every bugfix
- `nc-brainstorm` — architecture decisions, trade-off analysis
- `nc-plan` — implementation planning with phase breakdown
- `nc-debug` — systematic root-cause debugging

**Research & docs:**
- `nc-research` · `nc-docs` · `nc-docs-seeker` · `nc-preview` · `nc-mermaidjs-v11` · `nc-llms`

**Design & UI:**
- `nc-ui-ux-pro-max` (50+ styles, 161 palettes, 57 font pairs)
- `nc-ui-styling` (shadcn/ui + Tailwind)
- `nc-frontend-development` · `nc-react-best-practices` · `nc-web-design-guidelines`

**Backend & infra:**
- `nc-backend-development` · `nc-databases` (PostgreSQL, MongoDB)
- `nc-tanstack` · `nc-payment-integration` (SePay, Stripe, Paddle, Polar, Creem)
- `nc-deploy-vps` (VPS <YOUR_VPS_IP> + your hosting panel, NextCore-specific)

**Testing & security:**
- `nc-security` (STRIDE + OWASP, iterative auto-fix)
- `nc-scenario` (edge case decomposition — 12 dimensions)
- `nc-web-testing` (Playwright, Vitest, k6)

**AI/LLM tooling:**
- `nc-ai-multimodal` (Gemini, Imagen, Nano Banana, MiniMax, Veo)
- `nc-ai-artist` · `nc-claude-api` · `nc-agent-browser`

**Project ops:**
- `nc-project-management` · `nc-retro` · `nc-journal` · `nc-watzup`
- `nc-predict` (5-persona pre-implementation debate)
- `nc-autoresearch` (iterative optimization loop — CC only)

**Domain (NextCore-specific):**
- `nc-facebook-dom` · `nc-chrome-extension-dev` · `nc-prisma-helper` · `nc-nextcore-design`

---

## Architecture

```
skills/                          ← Claude Code source of truth (66 skills)
  {name}/
    SKILL.md                     ← prose + frontmatter
    references/*.md              ← supporting detail
adapters/                        ← derived, per-IDE
  antigravity/
    workflows/                   ← 33 .md + references (auto-converted)
    converter.cjs                ← SKILL.md → Antigravity workflow
    README.md
  cursor/commands/               ← 33 .md + references
  windsurf/workflows/            ← 33 .md + references (auto_execution_mode)
  copilot/prompts/               ← 33 .prompt.md + references (mode: agent)
hooks/                           ← Claude Code only
  session-init.cjs · privacy-block.cjs · skill-dedup.cjs · ...
  lib/                           ← shared utilities (config, scout, privacy)
  __tests__/                     ← Node test runner
install.sh / install.ps1         ← IDE-aware installers
```

`skills/` is always authoritative. Adapter files are **derived** — edit `skills/` then re-run `adapters/antigravity/converter.cjs` + downstream transforms.

---

## Options

```
--ide=NAME       Target IDE: claude-code | antigravity | cursor | windsurf | copilot
--target=PATH    Override install directory
--update         Merge with existing install (preserve user tweaks)
--minimal        Strip skill scripts/venvs (Claude Code only)
--force          Skip backup prompt if target exists
```

Environment variables:
- `NC_SOURCE` — local repo path (for development)
- `NC_REPO` — override repo URL

---

## Roadmap

- **Phase 1** ✅ Foundation (rebrand, config, installers)
- **Phase 2** ✅ Skill audit (81 → 66 active, 2865 LOC dead weight removed)
- **Phase 2.5** ✅ Cross-IDE adapters (4 IDEs shipped: Antigravity, Cursor, Windsurf, Copilot)
- **Phase 3** (in progress) Hook hardening + schema + legal cleanup
- **Phase 4** (deferred) Niche IDE adapters: Continue.dev, Aider
- **Phase 5** (long-term) Skill marketplace web UI

See [ROADMAP.md](./ROADMAP.md) for detailed status.

---

## Per-IDE docs

Each adapter has its own README with IDE-specific conventions, install steps, and known limitations:

- [`adapters/antigravity/README.md`](./adapters/antigravity/README.md) — Antigravity (Google)
- [`adapters/cursor/README.md`](./adapters/cursor/README.md) — Cursor
- [`adapters/windsurf/README.md`](./adapters/windsurf/README.md) — Windsurf
- [`adapters/copilot/README.md`](./adapters/copilot/README.md) — GitHub Copilot (VS Code)

---

## Contributing

This is an evolving framework. If you:

1. **Find a skill** that doesn't work right → open an issue with the IDE + skill name
2. **Want a new IDE** adapter → see `adapters/README.md` for the porting pattern
3. **Improve an existing skill** → edit `skills/{name}/SKILL.md` then re-run converters:
   ```bash
   cd adapters/antigravity && node converter.cjs <skill-name>
   # then propagate to other adapters via their scripts
   ```

---

## Credits

Architecture patterns inspired by [prior ecosystem work](https://prior ecosystem work) (MIT). See [CREDITS.md](./CREDITS.md) for detailed attribution.

All NEXTCORE-authored code under MIT license — see [LICENSE](./LICENSE).

---

## Quick reference

**Use in any supported IDE:**

| Task | Invoke |
|---|---|
| Plan a feature | `/nc-brainstorm` → `/nc-plan` → `/nc-cook` |
| Fix a bug | `/nc-debug` → `/nc-fix` |
| Research a library | `/nc-research` (Gemini/WebSearch) |
| Design UI | `/nc-ui-ux-pro-max` → `/nc-frontend-development` |
| Audit security | `/nc-security` (STRIDE + OWASP) |
| Deploy | `/nc-deploy-vps` (NextCore VPS) or describe your host |

---

## Stats

- **66 skills** (audited down from 81, keeping only actively-used patterns)
- **132 cross-IDE workflows** shipped (33 skills × 4 non-CC IDEs)
- **432 reference files** shipped across all adapters
- **8 commits** in Phase 2.5 adapter sprint
- **MIT licensed**, NextCore-authored
