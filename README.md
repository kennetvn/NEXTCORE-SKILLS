# NEXTCORE-SKILLS

> **Peak Agent Framework v3.0.0** — 133 curated skills as slash commands across **10 AI IDEs**. Full ecosystem: Agent UX (persona/memory/sentiment), community contribution loop, per-install customization, tech-company org modeling, sysadmin/devops depth, AI-aware engineering, design/QA depth, and meta-layer infrastructure (Context Protocol, rollback, streaming, telemetry, dep graph).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

**Supported IDEs (10):** Claude Code · Antigravity · Cursor · Windsurf · GitHub Copilot · Continue.dev · Aider · Codeium · Zed · JetBrains AI · Void

## What's new in v3.0.0 (April 2026)

- **Tier C — Dev deep**: nc-performance-profiling, nc-debugging-advanced, nc-code-archaeology
- **Tier D — Design deep**: nc-user-research, nc-ux-writing, nc-accessibility-deep
- **Tier E — Tester deep**: nc-bug-triage, nc-test-strategy, nc-chaos-engineering
- **Meta skills**: nc-working-memory (short-term), nc-cost-routing (Haiku/Sonnet/Opus)
- **Meta specs** (`docs/`): rollback-protocol · streaming-spec · telemetry-spec · skill-deps-graph
- **Skills dep graph**: `node scripts/skills-deps-graph.cjs` → Mermaid + circular check

## Earlier in v2.5.x

- **First-run onboarding** (`nc-onboard`) — 3-question survey calibrates persona, language, depth in <60s
- **Agent UX layer** (`nc-persona` · `nc-memory` · `nc-clarify` · `nc-explain` · `nc-mirror` · `nc-sentiment`) — agent acts like a teammate, not a wizard
- **Community contribution loop** (`nc-contribute`) — auto-detect skill gaps, drive upstream PRs via your GitHub
- **Per-install tweaks** (`nc-install-tweaks`) — local overrides survive updates
- **Org modeling** (`nc-company-os`) — agent embodies right role (PM/TL/Eng/SRE/QA/etc.) for the task
- **Skill announce protocol** (`nc-skill-announce`) — visible skill usage builds trust + discoverability
- **Context Protocol** (`docs/context-protocol.md`) — standardized cross-skill handoff via `plans/{session}/context/`
- **Test scenarios** (`tests/scenarios/`) — 7 simulated user flows for QA
- **Validator** (`scripts/validate-skills.cjs`) — static checks all 111 skills

---

## Quick install

Pick your IDE — each with one-command install:

```bash
# Linux / macOS / Git Bash
curl -sSL https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.sh | bash -s -- --ide=<IDE>

# Windows PowerShell
iwr -useb https://raw.githubusercontent.com/kennetvn/NEXTCORE-SKILLS/main/install.ps1 | iex -Args '-Ide <IDE>'
```

Replace `<IDE>` with one of: `claude-code` · `antigravity` · `cursor` · `windsurf` · `copilot` · `continue` · `aider` · `codeium` · `zed` · `jetbrains` · `void`

Default: `--ide=claude-code` (full framework: skills + hooks + subagents + commands)

After install, restart your IDE. Type `/nc-onboard` for the first-run setup (1-min profile), or `/nc-` to see available slash commands.

### First-time user

```
> /nc-onboard
```

Walks you through a 3-question survey (role / level / response style), saves preferences to `~/.nc-memory/`, suggests 3 commands to try based on what you do. Non-blocking — skip with "skip" anytime.

### Contribute back

```
> /nc-contribute
```

When you spot a missing skill or improvement, this drives a full GitHub PR via your account. The maintainer (`@kennetvn`) welcomes contributions — quality bar applies, frequency limit prevents spam.

---

## What you get per IDE

| IDE | Install target | Workflows | Hooks | Subagents |
|---|---|:---:|:---:|:---:|
| Claude Code | `.claude/` | ✅ 133 | ✅ 15 | ✅ |
| Antigravity | `.agent/workflows/` | ✅ 127 | — | via `ai-team/*` |
| Cursor | `.cursor/commands/` | ✅ 127 | — | general agent |
| Windsurf | `.windsurf/workflows/` | ✅ 127 | — | Cascade |
| GitHub Copilot | `.github/prompts/` | ✅ 127 | — | Copilot agent |
| Continue.dev | `.continue/prompts/` | ✅ 127 | — | general agent |
| Aider | `.aider/nextcore/` | ✅ 127 | — | CLI conversation |
| Codeium | `.codeium/prompts/` | ✅ 127 | — | general agent |
| Zed AI | `.zed/prompts/` | ✅ 127 | — | built-in Claude |
| JetBrains AI | `.idea/ai-prompts/` | ✅ 127 | — | Assistant agent |
| Void | `.void/prompts/` | ✅ 127 | — | native VS Code fork agent |

Claude Code is source of truth — other IDEs get skill **content** (portable markdown). Hooks and subagent orchestration are Claude Code exclusive.

---

## Per-skill install (Claude Code)

Cherry-pick specific skills instead of the full 65:

```bash
./install.sh --ide=claude-code --skills=cook,fix,nc-plan,nc-debug,nc-brainstorm
```

Useful for: CI/CD lean installs, team-specific profiles, testing subsets.

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
- `nc-deploy-vps` (VPS + your hosting panel, NextCore-specific)

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

Full machine-readable index: [`skills/catalog.json`](./skills/catalog.json)

---

## Architecture

```
skills/                          ← Claude Code source of truth (65 skills)
  {name}/
    SKILL.md                     ← prose + frontmatter
    references/*.md              ← supporting detail
  catalog.json                   ← machine-readable skill index
adapters/                        ← derived, per-IDE
  antigravity/workflows/         ← 33 .md + references
    converter.cjs                ← SKILL.md → Antigravity workflow transformer
  cursor/commands/               ← 33 .md + references
  windsurf/workflows/            ← 33 .md + auto_execution_mode
  copilot/prompts/               ← 33 .prompt.md + mode:agent
  continue/prompts/              ← 33 .md
  aider/
    prompts/                     ← 33 .md
    conventions/                 ← standing context for aider --read
hooks/                           ← Claude Code only
  session-init.cjs · privacy-block.cjs · skill-dedup.cjs · scout-block.cjs · ...
  lib/                           ← shared utilities (config, scout, privacy)
  __tests__/                     ← Node test runner
install.sh / install.ps1         ← 7-IDE-aware installers
CONTRIBUTING.md                  ← community contribution guide
ATTRIBUTION.md                   ← clean-room audit
```

`skills/` is authoritative. Adapter files are **derived** — edit `skills/` then re-run `adapters/antigravity/converter.cjs` + downstream transforms.

---

## Install options

```
--ide=NAME       Target IDE: claude-code (default) | antigravity | cursor |
                 windsurf | copilot | continue | aider
--target=PATH    Override install directory
--update         Merge with existing install (preserve user tweaks)
--minimal        Strip skill scripts/venvs (Claude Code only)
--force          Skip backup prompt if target exists
--skills=LIST    Comma-separated skill names (Claude Code only)
```

Environment variables:
- `NC_SOURCE` — local repo path (for development)
- `NC_REPO` — override repo URL

---

## Roadmap

All phases complete. Future additions happen via community contributions (see CONTRIBUTING.md).

- **Phase 1** ✅ Foundation (rebrand, config, installers)
- **Phase 2** ✅ Skill audit (81 → 65 active, 2865 LOC dead weight removed)
- **Phase 2.5** ✅ Cross-IDE adapters part 1 (Antigravity, Cursor, Windsurf, Copilot)
- **Phase 3** ✅ Clean-room audit + LICENSE/CREDITS cleanup
- **Phase 4** ✅ Niche IDE adapters (Continue.dev, Aider)
- **Phase 5** ✅ Skill ecosystem foundation (catalog.json + per-skill install + CONTRIBUTING)

See [ROADMAP.md](./ROADMAP.md) for detail.

---

## Per-IDE docs

Each adapter has IDE-specific conventions, install steps, known limitations:

- [`adapters/antigravity/README.md`](./adapters/antigravity/README.md)
- [`adapters/cursor/README.md`](./adapters/cursor/README.md)
- [`adapters/windsurf/README.md`](./adapters/windsurf/README.md)
- [`adapters/copilot/README.md`](./adapters/copilot/README.md)
- [`adapters/continue/README.md`](./adapters/continue/README.md)
- [`adapters/aider/README.md`](./adapters/aider/README.md)
- [`adapters/codeium/README.md`](./adapters/codeium/README.md)
- [`adapters/zed/README.md`](./adapters/zed/README.md)
- [`adapters/jetbrains/README.md`](./adapters/jetbrains/README.md)
- [`adapters/void/README.md`](./adapters/void/README.md)

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for:
- Adding new skills (workflow + review checklist)
- Improving existing skills
- Adding new IDE adapters (template via Cursor pattern)
- Issue templates + PR conventions
- Versioning rules

---

## Credits

Architecture patterns inspired by prior art in the Claude Code ecosystem. No code derived — see [ATTRIBUTION.md](./ATTRIBUTION.md) for the clean-room audit.

NEXTCORE-SKILLS licensed under [MIT](./LICENSE) — self-contained, no upstream notice required.

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

- **65 skills** curated (audited from 81, keeping only actively-used patterns)
- **590 cross-IDE workflows (59 × 10 non-CC IDEs)** shipped (33 skills × 6 non-CC IDEs)
- **~5,900 reference files** shipped across all adapters
- **11 IDEs supported** with one-command install
- **15 commits** across Phases 2-5 in single-day sprint
- **MIT licensed**, NextCore-authored, clean-room audited
