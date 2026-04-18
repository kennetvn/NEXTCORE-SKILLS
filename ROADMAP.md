# NEXTCORE-SKILLS Roadmap

Progressive path from inherited-inspired framework to 100% NextCore-authored codebase + cross-IDE support.

---

## Phase 1 — Foundation ✅ (Complete)

- [x] Rebrand ck: → nc: prefix across 75 skills
- [x] Folder rename ck-* → nc-*
- [x] Config file rename .ck.json → .nc.json + schema
- [x] Hook utility rename ck-config-utils → nc-config-utils
- [x] Consolidation: remove duplicate nc-loop, empty template-skill
- [x] Install scripts (bash + PowerShell)
- [x] Attribution files (LICENSE, CREDITS.md)
- [x] Public repo + end-to-end install verification

---

## Phase 2 — Skill Audit + Optimization (1-2 months)

Goal: review every skill against 4 criteria, keep only what's valuable for NextCore work.

### Review criteria per skill

1. **Real-world applicability** — Has this been used in actual NextCore work in the past 30 days?
2. **Logic quality** — Does the skill give correct, current, non-obvious guidance?
3. **Reference docs** — Are linked docs up-to-date? Are examples accurate?
4. **Research correctness** — Does it reflect 2026 best practices? (many inherited skills may reflect 2024-2025 patterns)

### Decision matrix

| Applicability | Logic | Docs | Action |
|---|---|---|---|
| High | Good | Current | **Keep** |
| High | Good | Outdated | **Refine** (update docs/examples) |
| High | Weak | Any | **Rewrite** (keep name, replace body) |
| Low | Any | Any | **Delete** |

### Skill clusters to audit (priority order)

1. **Core workflow** (nc-plan, nc-debug, nc-predict, nc-scenario, nc-security, nc-autoresearch, nc-help) — daily use
2. **Stack-specific** (frontend-development, backend-development, tanstack, react-best-practices, nextjs-api) — check currency for 2026
3. **Infrastructure** (deploy, deploy-vps, devops, worktree, git) — verify commands still work
4. **Testing** (test, web-testing, scout) — check for overlap, consolidate if needed
5. **Documentation** (docs, docs-seeker, mintlify, llms, preview, markdown-novel-viewer) — 6 skills is too many, likely 3-4 needed
6. **Design** (design, nextcore-design, frontend-design, ui-styling, ui-ux-pro-max, stitch) — merge where appropriate
7. **AI/LLM** (ai-artist, ai-multimodal, claude-api, google-adk-python, agent-browser) — research currency
8. **Niche** (shader, threejs, remotion, shopify, better-auth, mobile-development) — delete if unused

### Output

Each audited skill gets one of:
- `skill/STATUS.md` — audit notes, last verified date, action taken
- Deletion commit with reasoning
- Rewrite commit with NextCore-authored body

---

## Phase 3 — Core Framework Rewrite (2-4 months)

Goal: replace inherited framework code with NextCore originals. After this, `LICENSE` upstream attribution becomes optional.

### Components to rewrite from scratch

- [ ] `hooks/lib/nc-config-utils.cjs` — rewrite using [Claude Code official hook docs](https://docs.claude.com/claude-code/hooks). Cleaner API, better TypeScript types.
- [ ] `hooks/session-init.cjs` — own project detection logic tailored to NextCore monorepo structure
- [ ] `hooks/skill-dedup.cjs` — own dedup algorithm based on usage data
- [ ] `hooks/scout-block.cjs` — configurable size + path blocker
- [ ] `hooks/privacy-block.cjs` — NextCore-specific secret patterns (SePay keys, example-homestay.com tokens, etc.)
- [ ] `statusline.cjs` — custom NextCore design (color scheme, brand elements)
- [ ] `schemas/nc-config.schema.json` — own JSON schema

### Quality gates

- Each rewrite has unit tests (`hooks/__tests__/`)
- Behavior parity verified against old version before swap
- Documented in commit message: "replaces prior ecosystem work-inherited X with NextCore-authored Y"

---

## Phase 4 — Cross-IDE Adapters (3-6 months)

Goal: skill content (not hooks) portable to non-Claude-Code environments.

### Adapters

- [ ] **Cursor** — Convert skills to `.cursor/rules/*.mdc` format
- [ ] **Continue.dev** — Convert to Continue slash command format
- [ ] **Windsurf** — Convert to `.windsurfrules` format
- [ ] **GitHub Copilot** — Generate `.github/copilot-instructions.md` from key skills
- [ ] **Aider** — Generate prompt template library

### Install script enhancement

```bash
./install.sh --ide=cursor     # copies adapted skills to .cursor/
./install.sh --ide=continue   # copies to Continue config
./install.sh --ide=claude-code  # default (full framework)
./install.sh --ide=all        # copies all compatible adapters
```

### Constraints

- Hook system remains Claude Code only (other IDEs don't expose equivalent)
- Slash commands portable where syntax matches (`/nc:plan` in Cursor via `.cursor/commands/`)
- Agents (subagent spec) likely Claude Code only unless Cursor/Continue add equivalent

---

## Phase 5 — Skill Marketplace (6-12 months, optional)

Goal: Web UI for browsing + installing individual skills.

- [ ] Web catalog at `skills.nextcore.com` or similar
- [ ] Install per-skill: `./install.sh --skills=nc-plan,nc-debug,prisma-helper`
- [ ] Community contribution flow
- [ ] Version pinning (`nc-plan@1.2.0`)
- [ ] Compatibility matrix (skill × IDE × CC version)

This phase is only considered if Phases 1-4 show adoption traction.

---

## Measurement

Track independence progress via:

```bash
# Count prior ecosystem work-inherited lines vs NextCore-authored
git log --all --format='%ae' | sort -u  # contributor list
wc -l hooks/lib/nc-config-utils.cjs     # before/after rewrite
```

Target: Phase 3 completion = 0 lines of inherited code in `hooks/`, all skills either audited or rewritten.

---

## Principles

- **Attribution remains legally required** until inherited code is fully replaced — MIT compliance is non-negotiable while any upstream code exists
- **No fake independence** — we don't misrepresent inherited work as original
- **Gradual > rushed** — quality rewrites take time; don't delete working code prematurely
- **Real-world driven** — skills earn their keep by being used in actual work, not theoretical utility
