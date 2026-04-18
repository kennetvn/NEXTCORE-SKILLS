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

---

## 2026-04-18 — Niche cluster

Reviewed: `shader`, `threejs`, `remotion`, `shopify`, `better-auth`, `mobile-development`, `google-adk-python`

All 7 skills checked against: NextCore stack (Next.js 16, Prisma, MySQL, Chrome ext, VPS, Facebook automation, example-homestay.com). Grep across rules/, commands/, CLAUDE.md, package.json — **zero references**.

| Skill | LOC | Decision | Reason |
|---|---|---|---|
| `shader` | 115 | **DELETE** | GLSL fragment shaders. Not in NextCore stack. |
| `threejs` | 144 | **DELETE** | 3D WebGL. Not in NextCore stack. |
| `remotion` | 46 | **DELETE** | React video generation. Not used. |
| `shopify` | 323 | **DELETE** | E-commerce platform. Not used (homestay ≠ e-commerce). |
| `better-auth` | 207 | **DELETE** | Auth library. NextCore uses different auth stack. |
| `mobile-development` | 215 | **DELETE** | React Native / Swift / Kotlin. No mobile native in NextCore. |
| `google-adk-python` | 135 | **DELETE** | Google Agent Dev Kit Python. NextCore uses Node ecosystem. |

### Net result
7 skills deleted. -1185 LOC dead weight.

---

## 2026-04-18 — Infrastructure cluster

Reviewed: `deploy`, `deploy-vps`, `devops`, `worktree`, `git`, `ship`

NextCore stack: VPS only (example-homestay.com, <YOUR_VPS_IP>). No Cloudflare Workers/D1, no GCP, no K8s, no Docker orchestration.

| Skill | LOC | Decision | Reason |
|---|---|---|---|
| `deploy-vps` | 110 | Keep | NextCore-specific with backup/rollback/health-check. Primary deploy workflow. |
| `worktree` | 99 | Keep | Used by `/ck:team` + `/pair` for parallel flows. |
| `git` | 116 | Keep | Conventional commits + PR + security scans. Daily use. |
| `ship` | 119 | Keep | Higher-abstraction ship pipeline (merge → test → review → commit → push → PR). |
| `deploy` | 157 | **DELETE** | Generic multi-platform (Vercel, Netlify, CF, Railway, AWS, Heroku, 13 platforms). NextCore uses VPS only — `deploy-vps` covers it. |
| `devops` | 99 | **DELETE** | Cloudflare Workers/R2/D1, Docker, GCP/GKE, Kubernetes/Helm. None used in NextCore. |

### Net result
6 → 4 active. -2 skills, -256 LOC.

---

## Session 2026-04-18 total

| Cluster | Before | After | Deleted | LOC removed |
|---|---|---|---|---|
| Documentation | 6 | 5+1 internal | -1 | -123 |
| Design | 6 | 4 | -2 | -471 |
| Niche | 7 | 0 | -7 | -1185 |
| Infrastructure | 6 | 4 | -2 | -256 |
| **Total** | **81** | **69 active** | **-12** | **-2035 LOC** |
