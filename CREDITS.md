# Credits

## Architecture inspiration

Some early architectural patterns in this repo (YAML-frontmatter skill discovery, Node CJS hook system, file-based configuration) were inspired by [prior ecosystem work](https://prior ecosystem work) (MIT licensed). We credit prior ecosystem work for pioneering these patterns in the Claude Code ecosystem.

Per MIT license requirements, the original copyright notice is preserved in `LICENSE`.

## NEXTCORE-SKILLS own contributions

This repo is actively evolving toward full independence. Current custom work:

### Framework (NextCore-authored)
- Install system (`install.sh`, `install.ps1`, `uninstall.sh`) with update/minimal modes
- Directory structure + naming conventions (`nc:` prefix, `.nc.json` config)
- Skill consolidation (duplicate detection, typo fixes, env cleanup)
- Cross-IDE compatibility roadmap (see ROADMAP.md)

### Domain skills (NextCore-authored)
- **nextcore-design** — NextCore CSS class convention (`.nextcore-ext-*`)
- **nextjs-api** — Next.js 16 API route patterns with Prisma + CORS for Chrome Extension access
- **prisma-helper** — Safe Prisma migrations for production MySQL/PostgreSQL
- **facebook-dom** — Facebook DOM interaction SDK (Manifest V3 content scripts)
- **chrome-extension-dev** — Manifest V3 patterns + service worker debugging
- **deploy-vps** — VPS deployment workflows with backup/rollback/health-check

### Agents + Commands (NextCore-authored)
- Custom commands: `/pair`, `/standup`, `/ux-audit`, `/tm`, `/team-stop`, `/website`, `/extensions`
- Output styles (God Mode Level 5, terse engineering mode)
- Project rules (`development-rules.md`, `orchestration-protocol.md`, `agent-workspace-policy.md`)

## Related open-source projects used

- **Claude Code** (Anthropic) — the CLI this framework extends
- **lucide-react** (ISC) — icon references in design skills
- **mermaid** (MIT) — diagram syntax in `mermaidjs-v11` skill

## Roadmap to independence

See [ROADMAP.md](./ROADMAP.md) for the plan to progressively replace inherited components with NextCore-authored originals. Current target: ~12 months to 100% independent codebase.
