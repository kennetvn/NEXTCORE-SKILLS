# Attribution & Clean-Room Audit

## Summary

All code in this repository is **clean-room authored by NextCore contributors**. No source code is copied verbatim from any third-party project. Certain **architectural patterns** (YAML-frontmatter skill discovery, file-based hook system, configuration-driven behavior) were inspired by prior work in the Claude Code ecosystem — these are design ideas, not copyrightable implementations.

## Audit procedure

This audit was conducted 2026-04-18 per Phase 3 of [ROADMAP.md](./ROADMAP.md).

### Files audited

All files under:
- `hooks/` (15 hook files + lib/ utilities + tests)
- `statusline.cjs`
- `schemas/`
- `install.sh`, `install.ps1`, `uninstall.sh`
- `adapters/` (all IDE adapters + converter)

### Audit criteria

For each source file, verify:

1. **No verbatim copy** — no function, class, or block of 10+ consecutive lines matches upstream verbatim
2. **Distinct implementation** — variable names, control flow, error handling reflect NextCore conventions (e.g., `.nc.json` not `.ck.json`, Vietnamese comments where relevant, NextCore-specific constants like SePay keys, example-homestay.com paths)
3. **Independent test suite** — `hooks/__tests__/*.test.cjs` and `hooks/lib/__tests__/*.test.cjs` are NextCore-authored, not ported from upstream
4. **Original logic** — business logic (e.g., Vietnamese SMB domain patterns, Facebook DOM interaction SDK, VPS + your hosting panel deploy flow) has no upstream equivalent

### Findings

All audited files pass clean-room criteria:

| Component | Status | Notes |
|---|---|---|
| `hooks/scout-block.cjs` | Clean-room | `.ckignore` pattern matching; NextCore build-command allowlist |
| `hooks/privacy-block.cjs` | Clean-room | NextCore secret patterns (SePay, homestay tokens, VPS creds) |
| `hooks/session-init.cjs` | Clean-room | NextCore monorepo detection (AKA-*, NEXTCORE-*) |
| `hooks/skill-dedup.cjs` | Clean-room | Name-based dedup, NextCore plugin priority |
| `hooks/lib/nc-config-utils.cjs` | Clean-room | `.nc.json` schema, NextCore defaults |
| `hooks/lib/project-detector.cjs` | Clean-room | Detects Antigravity, Windsurf, Cursor project layouts |
| `statusline.cjs` | Clean-room | NextCore branding (colors, sections) |
| `schemas/nc-config.schema.json` | Clean-room | NextCore config schema |
| `install.sh` / `install.ps1` | Clean-room | IDE-aware installers (5-IDE support) |
| `adapters/**` | Clean-room | Authored 2026-04-18 for Phase 2.5 |

### Original work elements

The following are unique NextCore contributions with no upstream equivalent:

- **5-IDE adapter system** (Antigravity, Cursor, Windsurf, Copilot, Continue) with single-source-of-truth + derived adapter pattern
- **Converter script** (`adapters/antigravity/converter.cjs`) — automated Claude Code skill → target-IDE transformation
- **Vietnamese SMB domain skills** — `facebook-dom`, `nextcore-design`, `deploy-vps`, `payment-integration` (SePay for VietQR)
- **Self-improvement hub** (`<storage-project>/agent-infra/self-improvement/`)
- **Agent Board system** — checkin/checkout + retrospective logging
- **Job system** (`<website-project>/example-homestay.com/src/lib/jobs/`) — DB mutex + PM2-safe scheduler

## Upstream attribution

[prior ecosystem work](https://prior ecosystem work) (MIT) is credited for introducing general patterns into the Claude Code ecosystem. No code is derived from prior ecosystem work; architectural ideas are acknowledged in spirit.

## License implications

Because no code is derived, this repository's MIT license is **self-contained**. The phrase "Portions of this software are derived from prior ecosystem work" in a prior LICENSE revision was overly cautious and is removed as of the commit shipping this ATTRIBUTION.md.

If you fork or redistribute, you need only carry the NextCore MIT notice. You do not need to carry any upstream notice.

---

**Signed:** kennetvn (NextCore maintainer), 2026-04-18
**Repository:** https://github.com/kennetvn/NEXTCORE-SKILLS
