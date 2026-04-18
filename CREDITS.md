# Credits & Attribution

NEXTCORE-SKILLS is a fork and evolution of [prior ecosystem work](https://prior ecosystem work),
an open-source Claude Code enhancement framework licensed under MIT.

## Upstream: prior ecosystem work

- **Project:** prior ecosystem work / prior ecosystem work-engineer
- **License:** MIT
- **Website:** https://prior ecosystem work

We gratefully acknowledge the foundational work by prior ecosystem work authors, including:

- Core hook system for Claude Code event integration
- Skill framework with frontmatter + auto-discovery
- Statusline system
- Config loader utilities (originally ck-config-utils.cjs)
- Session state + orchestration patterns
- Many of the generic skills shipped in this repo

## What NEXTCORE-SKILLS adds/changes

This fork focuses on Vietnamese SMB tooling (hotel booking, Facebook group
automation, Chrome extension development, VPS deployment).

### Rebrand
- Prefix `ck:` -> `nc:` across 75+ skill identifiers
- Renamed `ck-*` folders -> `nc-*`
- Renamed `ck-config-utils.cjs` -> `nc-config-utils.cjs`
- Renamed `.ck.json` -> `.nc.json`
- Brand strings `prior ecosystem work` -> `nextcoreskill`

### Consolidation
- Removed duplicate `nc-loop` (identical to `nc-autoresearch`)
- Removed placeholder `template-skill`
- Fixed typo `ckm:design` -> `nc:design`
- Cleaned legacy CLAUDEKIT_API_KEY env var

### Additions
- **nextcore-design** - NextCore CSS class convention
- **nextjs-api** - Next.js 16 API + Prisma + CORS patterns
- **prisma-helper** - Safe Prisma migrations
- **facebook-dom** - FB DOM interaction SDK
- **chrome-extension-dev** - Manifest V3 patterns
- **deploy-vps** - VPS deployment with rollback
- **install.sh** / **install.ps1** - one-command installer
- Hook tests in hooks/__tests__/

## Attribution policy

When using, modifying, or redistributing:

1. Retain the MIT license notice in LICENSE
2. Retain this CREDITS.md file
3. Do not misrepresent the origin - it is a fork of prior ecosystem work
