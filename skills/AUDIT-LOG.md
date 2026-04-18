# Skill Audit Log

Progressive audit per [ROADMAP.md](../../ROADMAP.md) Phase 2. Each cluster reviewed against 4 criteria: applicability, logic quality, reference docs, research correctness (2026).

---

## 2026-04-18 — Documentation cluster

Reviewed: `docs`, `docs-seeker`, `mintlify`, `llms`, `preview`, `markdown-novel-viewer`

| Skill | Decision | Reason |
|---|---|---|
| `docs` | Keep | Generic high-level (init/update/summarize). Unique scope. Used in example-homestay.com docs/ directory. |
| `docs-seeker` | Keep | Narrow focus: external lib research via llms.txt + context7. Used when onboarding new libraries. |
| `mintlify` | **DELETE** | Not used. NextCore doesn't host on Mintlify — own docs live inside project repos. 123 lines of unused tool-specific guidance. |
| `llms` | Keep | Future use: generate llms.txt for example-homestay.com/docs for AI SEO indexing. |
| `preview` | Keep | Main user-facing. View + visual generation (slides/explain/diagram/HTML). Core daily-use tool. |
| `markdown-novel-viewer` | Keep (internal) | Backend HTTP server for `preview` view mode. Marked `user-invocable: false` — users invoke via `/nc:preview`. |

### Changes
- Deleted `skills/mintlify/`
- Updated `skills/markdown-novel-viewer/SKILL.md` frontmatter: `user-invocable: false`, updated description, added audit metadata

### Net result
6 → 5 active + 1 internal. -123 lines dead weight.

---

## Next clusters (priority order)

1. **Core workflow** — nc-plan, nc-debug, nc-predict, nc-scenario, nc-security, nc-autoresearch, nc-help (daily use, audit last)
2. **Stack-specific** — frontend-development, backend-development, tanstack, react-best-practices, nextjs-api (verify 2026 currency)
3. **Infrastructure** — deploy, deploy-vps, devops, worktree, git
4. **Design** — design, nextcore-design, frontend-design, ui-styling, ui-ux-pro-max, stitch (suspected 3-4 redundant)
5. **AI/LLM** — ai-artist, ai-multimodal, claude-api, google-adk-python, agent-browser
6. **Niche** — shader, threejs, remotion, shopify, better-auth, mobile-development (most likely DELETE)
