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

## Phase 2.5 — Cross-IDE Adapters ✅ (Complete: 2026-04-18)

Goal: port skill *content* to other AI coding IDEs one at a time, optimized for each IDE's native format. Pulled earlier from Phase 4 so Phase 2 audit doesn't create CC-only debt that needs redoing.

### Strategy

1. Separate skill *content* (portable markdown) from *packaging* (IDE-specific slash cmd / hook / subagent syntax)
2. `skills/` stays authoritative (Claude Code source format)
3. `adapters/{ide}/` holds derived, pre-converted files
4. Ship IDE adapters incrementally — one IDE fully before the next

### IDE priority — all shipped except niche IDEs

1. **Antigravity** ✅ shipped — 33 workflows + install automation
2. **Cursor** ✅ shipped — 33 slash commands + install automation
3. **Windsurf** ✅ shipped — 33 workflows + install automation
4. **GitHub Copilot** ✅ shipped — 33 prompt files + install automation
5. **Continue.dev / Aider** (deferred to Phase 4 — niche, lower user count)

### Per-skill portability matrix (evolving)

| Category | Count | Portability |
|---|---|---|
| Fully portable (content-only) | ~15 | brainstorm, research, docs, docs-seeker, mermaidjs-v11, ui-ux-pro-max, react-best-practices, copywriting, … |
| Portable with rewrite (light subagent refs) | ~10 | nc-plan, nc-debug, nc-scenario, nc-security, cook, fix, … |
| Claude Code only (heavy hook/subagent) | ~5 | team, nc-autoresearch, kanban, plans-kanban, skill-creator |

### Deliverables per IDE

- [ ] `adapters/{ide}/README.md` — install + IDE quirks + conversion rules
- [ ] `adapters/{ide}/workflows/` (or equivalent) — converted files for "fully portable" skills first
- [ ] Second wave: "portable with rewrite" skills with IDE-specific subagent mapping
- [ ] `install.sh --ide={ide}` flag wiring (currently scaffolded, only `claude-code` works)
- [ ] Optional: auto-converter script (`adapters/{ide}/converter.cjs`) to regenerate from `skills/`

### Antigravity status

**v1 (shipped):** `nc-brainstorm`, `nc-research` — 2 manually-converted workflows proving the pattern works.

**v2 (next):** batch-convert all "fully portable" skills. Target: 15 Antigravity workflows shipped.

**v3:** subagent-heavy rewrites (cook, fix, nc-plan, nc-debug) mapping to Antigravity's `ai-developer`, `ai-tester`, `ai-ux-reviewer` built-ins.

**v4:** `install.sh --ide=antigravity` automation.

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

## Phase 4 — Cross-IDE Adapters, completion wave (superseded by Phase 2.5, retained for niche IDEs)

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
