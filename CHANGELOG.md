# Changelog

All notable changes to NEXTCORE-SKILLS.

## [3.0.0] - 2026-04-18

**Peak Agent Framework** — full v3.0.0 release. Tiers C/D/E (9 skills) + 2 meta skills + 4 spec docs + dependency graph script.

### Added — Tier C: Dev deep (3)

- **nc-performance-profiling** — measurement-first patterns by domain (Node, Python, web, DB), bottleneck taxonomy, optimization protocol
- **nc-debugging-advanced** — heisenbugs, race conditions, distributed system failures, intermittent prod bugs; eBPF/strace/valgrind kit
- **nc-code-archaeology** — 5-question protocol before changing legacy code, git toolbox, codebase onboarding, intent recovery

### Added — Tier D: Design deep (3)

- **nc-user-research** — pick-the-method matrix, interview protocol, sample size, synthesis discipline
- **nc-ux-writing** — error/button/empty-state copy, voice vs tone, consistency rules, localization-friendly patterns
- **nc-accessibility-deep** — WCAG-aware semantic HTML, focus management, screen readers, mobile a11y, real-user testing

### Added — Tier E: Tester deep (3)

- **nc-bug-triage** — triage flow, severity vs priority, routing, backlog grooming, recurring-pattern detection
- **nc-test-strategy** — pyramid + modern caveats, what to test/mock, anti-flaky tactics, CI strategy
- **nc-chaos-engineering** — readiness checklist, fault injection by mode, game day structure, hypothesis-driven drills

### Added — Meta skills (2)

- **nc-working-memory** — short-term per-session memory (distinct from nc-memory long-term); auto-prune at context pressure; promotion to long-term
- **nc-cost-routing** — auto-select Claude tier (Haiku/Sonnet/Opus) by task class; budget guards; prompt caching + batch API patterns

### Added — Meta specs (4 docs)

- **docs/rollback-protocol.md** — `undoable: true|false|partial` frontmatter convention; auto-snapshot for destructive skills; /nc-undo command spec
- **docs/streaming-spec.md** — phase-update + token-streaming patterns; frontmatter `streams:` field; cancellation
- **docs/telemetry-spec.md** — opt-in privacy-first usage telemetry; what's collected (and explicitly NOT); trust contract
- **docs/skill-deps-graph.md** — `depends_on:` + `suggests:` frontmatter convention; viz via Mermaid/DOT; CI circular-check

### Added — Tooling

- **scripts/skills-deps-graph.cjs** — generates Mermaid/DOT graph; checks circular deps; outputs JSON; supports per-skill subgraph
- **docs/skills-graph.md** — auto-generated visualization of all 133 skills

### Coverage

- 11 new skills × 10 IDEs = 110 new adapter files
- Total: **133 skills** across 10 IDEs
- catalog.json bumped to v3.0.0
- jetbrains/void AGENTS.md aggregated to 126 sections
- Validator: 57/133 clean, 0 errors, 177 warnings (legacy)
- Dep graph: 0 circular deps (after fix to inferred-only check)

### v3.0.0 vs v2.5.0 — what changed across the arc

| Layer | v2.5.0 | v3.0.0 |
|---|---|---|
| Skills | 100 | 133 (+33) |
| Tiers | 1-5 (depth-only) | S/A/B/C/D/E + meta |
| Agent UX | None | Tier S (persona, memory, sentiment, etc.) |
| Community | Manual PRs | nc-contribute auto flow |
| Customization | Code-only | nc-install-tweaks (~/.nc/overrides/) |
| Org modeling | None | nc-company-os (25+ roles, frameworks, processes) |
| Onboarding | None | nc-onboard (3-q survey) |
| Test scenarios | None | 7 simulated user flows |
| Validator | None | scripts/validate-skills.cjs |
| Specs | None | Context Protocol + Rollback + Streaming + Telemetry + Deps |
| Dep graph | None | scripts/skills-deps-graph.cjs |

### Why 3.0.0

This release unifies "skills as workflows" (v1-v2.5) with "agent ecosystem framework" (v2.5.x → v3.0.0). It's no longer just a slash-command pack — it's a self-improving teammate framework. Major version reflects scope, not breaking changes (full backwards compat preserved).

### Pending v3.x

- Adoption of `depends_on:` frontmatter (currently 0 declared, 9 inferred)
- Adoption of `undoable:` frontmatter (currently 0 declared)
- LLM-graded scenario test runner (`scripts/eval-scenarios.cjs`)
- Telemetry hook implementation (spec ready)
- 177 legacy skill warnings cleanup (community PR opportunity)

## [2.6.0] - 2026-04-18

Two new tiers — Sysadmin/DevOps (Tier A, 6 skills) + AI-aware (Tier B, 5 skills) — plus converter regex fix that ends years of CRLF noise.

### Added — Tier A: Sysadmin/DevOps (6)

- **nc-kubernetes** — k8s deploy/debug/scale/secure patterns. Manifest skeletons, debug ladder, common failures, HPA/VPA, helm vs raw decision matrix
- **nc-terraform** — IaC with Terraform/OpenTofu. Project layout, remote state, modules, importing existing infra, multi-env strategies, drift recovery
- **nc-linux-sysadmin** — diagnostic-first-hour playbook, systemd services + timers, users/perms/SSH, disk/memory/network tuning, hardening checklist
- **nc-networking** — diagnostic ladder by OSI layer, DNS/TLS/cert ops, nginx + Caddy reverse proxy, VPC topology, CDN considerations
- **nc-backup-recovery** — RPO/RTO design, 3-2-1 rule, DB-specific dump/restore, restic for files, restore drills (the only test that matters)
- **nc-incident-response** — 4-phase playbook (detect/mitigate/root-cause/postmortem), severity matrix, IC roles, blameless postmortem template, communication norms

### Added — Tier B: AI-aware (5)

- **nc-prompt-engineering** — production prompt design (system msg structure, few-shot patterns, CoT, tool-calling, injection defense, compression)
- **nc-llm-integration** — app-side LLM patterns (production wrapper, streaming, retry, structured output, multi-provider abstractions, cost guards)
- **nc-rag-patterns** — chunking strategies, embedding choice, hybrid retrieval, reranking, citation pattern, scaling problems + fixes
- **nc-vector-db** — pgvector / Pinecone / Qdrant / Chroma decision matrix, index types (HNSW/IVF), metadata filtering, multi-tenancy, cost watch-points
- **nc-ai-evaluation** — eval datasets, grader options (exact/partial/semantic/LLM-judge), CI regression detection, production monitoring, anti-patterns

### Fixed

- **Converter regex**: bare `nc:foo` (without backticks) now properly rewrites to `nc-foo` in adapter output. Frontmatter `description:` field also processed. Eliminates ~300-file CRLF noise diff on every build forever. Also handles backticked forms with args (e.g., `` `nc:autoresearch --fix` ``).

### Changed

- `install.sh` and `install.ps1`: added tail message suggesting `/nc-onboard` for first-run profile setup

### Coverage

- 11 new skills × 10 IDEs = 110 new adapter files
- Total: **122 skills** across 10 IDEs
- catalog.json bumped to v2.6.0; catalog.html regenerated
- jetbrains/void AGENTS.md aggregated to 115 sections
- Validator: 48/122 clean, 0 errors, 175 warnings (all legacy)

### Why minor bump (not patch)

Two new tiers worth of capability + a foundational converter fix that changes adapter output for many files. Patch bumps don't reflect the breadth.

## [2.5.4] - 2026-04-18

Polish + QA layer. Onboarding skill, scenario tests, validator, and refreshed README.

### Added

- **nc-onboard** — first-run experience for new users. 3-question survey calibrates persona/language/depth, suggests 3 try-it commands based on user role. Skip-friendly, runs once per user.
- **Scenario test harness** (`tests/scenarios/`) — 7 simulated user flows covering Tier S Agent UX + ecosystem skills:
  - `onboard-new-user.md` — first-run + persona calibration + memory persistence
  - `frustration-pattern.md` — sentiment overrides verbosity
  - `vocab-mirror.md` — terminology + language preservation
  - `community-contribute.md` — gap detection → PR flow
  - `company-os-feature-cycle.md` — multi-role embodiment for big features
  - `install-tweaks-pnpm.md` — per-install customization persisting across updates
  - `multilang-vn-en.md` — mixed VN/EN with identifier preservation
  - `frustrated-explain.md` — sentiment dynamically overrides explanation depth
- **Skill validator** (`scripts/validate-skills.cjs`) — static checks for frontmatter, broken refs, naming consistency, integration sections. Exit codes: 0=clean, 1=errors, 2=warnings.

### Fixed

- `databases` skill: removed broken reference to non-existent `db-design.md`

### Changed

- README refreshed for v2.5.4: "Peak Agent Framework" framing, 111 skills × 10 IDEs, first-run + contribute callouts

### Coverage

- 1 new skill × 10 IDEs = 10 adapter files
- Total: **111 skills** across 10 IDEs
- catalog.json bumped to v2.5.4
- jetbrains/void AGENTS.md aggregated to 105 sections
- Validator: 0 errors, 175 warnings (legacy skills missing 'Use when' phrasing or Integration sections — opportunistic cleanup)

## [2.5.3] - 2026-04-18

Ecosystem layer — community + transparency + org modeling. 4 new skills + response-format upgrade.

### Added

- **nc-skill-announce** — visible skill-usage announcement protocol; agent says which skill it's running before doing work, building trust + discoverability
- **nc-contribute** — community contribution loop; detects gaps, asks user consent ("Sếp Hảo welcomes contributions"), then drives full GitHub PR flow via user's account
- **nc-install-tweaks** — per-install customization layer at `~/.nc/overrides/`; tweaks survive updates, can promote to upstream via nc-contribute
- **nc-company-os** — tech-company organizational model (roles, departments, RFC/ADR/postmortem/sprint processes, RACI/MoSCoW/Reversibility frameworks); agent embodies the right "role" for the task

### Changed

- **nc-response-format** — added Standard Agent Message Envelope (announce → body → footer); integrates with nc-skill-announce + Context Protocol handoffs

### Coverage

- 4 new skills + 1 upgrade × 10 IDEs = 50 adapter files refreshed
- Total: **110 skills** across 10 IDEs
- catalog.json bumped to v2.5.3; catalog.html regenerated
- jetbrains/void AGENTS.md aggregated 104 sections

### Why this layer matters

v2.5.2 made the agent a teammate (Tier S Agent UX). v2.5.3 makes the agent a teammate **inside a company that has standards, contributes upstream, and adapts to local norms**. That's the difference between a useful tool and a self-improving framework.

## [2.5.2] - 2026-04-18

Tier S — Agent UX layer. 6 conversational-quality skills that make the agent feel like a teammate.

### Added

- **nc-persona** — tone/language/expertise-level adaptation (CTO ↔ junior, terse ↔ verbose, VN/EN)
- **nc-memory** — long-term context retention across sessions (`~/.nc-memory/{project}/`)
- **nc-clarify** — minimal clarifying questions; default to assume + state
- **nc-explain** — adaptive explanation depth based on inferred user level
- **nc-mirror** — reflect user's domain vocabulary, don't introduce competing jargon
- **nc-sentiment** — detect frustration/urgency/satisfaction/exploration, adjust speed + depth

### Coverage

- 6 new skills × 10 IDEs = 60 new adapter files
- Total: **106 skills** across 10 IDEs
- catalog.json bumped to v2.5.2; catalog.html regenerated
- jetbrains/void AGENTS.md aggregated 100 sections

## [2.0.0] - 2026-04-18

Massive expansion: 11 IDEs, 590 cross-IDE workflows, full ecosystem foundation.

### Added

- **11 IDE support** (up from 1): Claude Code, Antigravity, Cursor, Windsurf, GitHub Copilot, Continue.dev, Aider, Codeium, Zed, JetBrains AI, Void
- **59 workflows per non-CC IDE** (up from 33): expanded portable skill coverage
- **Auto IDE detection** in installer — detects existing `.cursor/`, `.agent/`, `.continue/`, etc.
- **Unified build script** `adapters/build-all.cjs` — regenerates all 11 adapters from single source
- **Per-skill install flag** `--skills=a,b,c` for cherry-picked Claude Code installs
- **Machine-readable catalog** `skills/catalog.json` v1.1.0 with per-skill IDE support matrix
- **CONTRIBUTING.md** — community contribution guide (how to add skills, adapters, PR conventions)
- **ATTRIBUTION.md** — clean-room audit declaration for legal clarity
- **Per-adapter READMEs** — IDE-specific install instructions and quirks

### Changed

- **README.md** — rewritten for 11-IDE support with install matrix, feature comparison, skill catalog highlights
- **LICENSE** — cleaned to self-contained MIT (removed "Portions derived from prior ecosystem work" clause after clean-room audit confirmed no verbatim copy)
- **CREDITS.md** — restructured to clarify pattern inspiration vs. code derivation
- **ROADMAP.md** — marked Phases 1, 2, 2.5, 3, 4, 5 complete; added 5.1 deferred
- **installer scripts** — 11-IDE branches with shared logic for bonus IDEs (codeium/zed/jetbrains/void)

### Removed

- **15 dead-weight skills** from Phase 2 audit (ask, sequential-thinking, problem-solving, shader, threejs, remotion, shopify, better-auth, mobile-development, google-adk-python, design, stitch, mintlify, deploy, devops)
- **~2,865 lines** of unused skill content

### Commits this release

- `cebad8e` audit(infra-cluster): delete generic deploy + devops
- `9222d6c` audit(niche-cluster): delete 7 unused stack-specific skills
- `9015147` audit(cognitive-cluster): delete ask/sequential-thinking/problem-solving
- `936f263` feat(adapters): Antigravity adapter v1
- `0e0c5f6` feat(adapters): Antigravity v2 — 20 portable
- `3f5f66c` feat(adapters): Antigravity v3 — 11 subagent-heavy
- `4b65f13` feat(adapters): Antigravity v4 — install automation
- `0b1c8c0` feat(adapters): Cursor adapter (33 commands)
- `75cf75d` feat(adapters): Windsurf adapter (33 workflows)
- `4ea3028` feat(adapters): GitHub Copilot adapter (33 prompts)
- `d885a95` docs(roadmap): Phase 2.5 complete
- `00457ab` docs(readme): optimized for 5-IDE support
- `da3c3b8` feat(phase-3): clean-room audit + LICENSE cleanup
- `84be499` feat(phase-4): Continue.dev + Aider adapters
- `92fef64` feat(phase-5): skills catalog + per-skill install + CONTRIBUTING
- `cdbf8e3` docs(readme): final version (7 IDEs)
- `9d1b34b` feat(adapters): Tier 1+5 — 26 more skills + 4 bonus IDEs
- `9b4e8bb` docs(readme): 11-IDE matrix

### Migration from v1.x

If you have an existing Claude Code install:
```bash
./install.sh --ide=claude-code --update
```

For adding a second IDE:
```bash
./install.sh --ide=<new-IDE>
```

---

## [1.0.0] - pre-session

Initial release (prior ecosystem work fork rebase, pre-audit state):
- 81 skills
- Claude Code only
- Install scripts (bash + PowerShell)

## [2.2.0] - 2026-04-18

Tier 1 shipped: 5 agent-performance skills.

### Added skills

- `nc-context-budget` — token budget management per session, when to dispatch vs execute, when to dump stale context
- `nc-parallel-dispatch` — patterns for spawning multiple subagents (scout/research/implement/verify)
- `nc-skill-composition` — chain skills without duplicate analysis, canonical pipelines, context handoff protocol
- `nc-router` — intent classifier for fast routing, short-circuit for trivial tasks
- `nc-response-format` — structured output templates per task type (plan/debug/review/research/implement)

### Changed

- Total skills: 65 → 70
- Per-IDE workflow count: 59 → 64 on all 10 IDEs
- catalog.json v2.2.0 regenerated
- catalog.html regenerated

## [2.3.0] - 2026-04-18

Tier 2 shipped: 13 core missing skills (backend + infrastructure + patterns).

### Added skills

**Infrastructure:**
- `nc-docker` — containerization, multi-stage builds, dev containers
- `nc-ci-cd` — GitHub Actions, GitLab CI, matrix builds, secrets
- `nc-env-secrets` — .env management, rotation, Vault/Doppler integration
- `nc-observability` — logging (pino), metrics (Prometheus), tracing (OpenTelemetry), Sentry

**Communication:**
- `nc-caching` — HTTP headers, Redis patterns, LRU, stampede protection
- `nc-websockets` — SSE + WebSocket patterns, Redis pub/sub for scale
- `nc-queues` — BullMQ, background jobs, retry+DLQ, NextCore job pattern
- `nc-api-contracts` — OpenAPI, tRPC, GraphQL, gRPC, versioning

**Patterns:**
- `nc-auth-patterns` — OAuth2, JWT, session, passwordless, MFA, RBAC
- `nc-state-management` — Zustand, Jotai, TanStack Store, Redux decision tree
- `nc-migration-patterns` — expand+contract, framework upgrade, DB schema
- `nc-microservices` — service boundaries, saga, outbox, service mesh
- `nc-event-sourcing` — event stores, CQRS, snapshots, projections

### Stats

- Skills: 70 → 83
- Per-IDE workflows: 64 → 77 on all 10 IDEs
- Total cross-IDE: 704 → 847

## [2.4.0] - 2026-04-18

Tier 3 shipped: 10 platform coverage skills (mobile + desktop + backend langs).

### Added skills

**Mobile:**
- `nc-react-native` — cross-platform mobile with Expo/bare workflow, navigation, native modules
- `nc-flutter` — Dart + Flutter, Riverpod/BLoC, platform channels
- `nc-ios-swift` — native iOS with SwiftUI, UIKit interop, App Store
- `nc-android-kotlin` — native Android with Compose, Jetpack, Play Store

**Desktop:**
- `nc-electron` — Node+web desktop, security model, auto-update, packaging
- `nc-tauri` — Rust+web desktop, small bundle, Tauri 2 mobile support

**Backend languages:**
- `nc-go-backend` — Chi/Gin/Fiber, sqlx/sqlc, goroutines, context
- `nc-rust-backend` — Axum/Tokio/sqlx, ownership, async Rust
- `nc-python-fastapi` — FastAPI+Pydantic+SQLAlchemy, async Python
- `nc-dotnet-core` — ASP.NET Core minimal APIs, EF Core, JWT

### Stats

- Skills: 83 → 93
- Per-IDE workflows: 77 → 87 on all 10 IDEs
- Total cross-IDE: 847 → 957

## [2.5.1] - 2026-04-18 — Sanitization release

**Privacy + attribution cleanup.** No functional changes.

### Removed personal/private info

Replaced across all files (skills, adapters, docs, installers):

- Business domains (`example-homestay.com`, `api.example.com`) → `example-homestay.com`, `api.example.com`
- Production IP (`<YOUR_VPS_IP>`) → `<YOUR_VPS_IP>`
- VPS deploy paths (`/www/wwwroot/example-homestay.com`) → `/var/www/<your-project>`
- Windows local path (`F:/workspace/...`) → `<YOUR_WORKSPACE>`
- Username (`developer`) → `developer`
- Vietnamese business titles (`the CTO`) → `the CTO`
- Personal email → `dev@example.com`
- Panel brand (`your hosting panel`) → generic `your hosting panel`
- Workspace dirs (`<website-project>`, `<extensions-project>`, `<storage-project>`) → generic placeholders

### Removed prior ecosystem work references

- LICENSE: already clean (previous release)
- CREDITS.md: rewritten — only NextCore's own contributions listed
- ATTRIBUTION.md: rewritten — clean-room statement without upstream attribution
- README.md + ROADMAP.md + CHANGELOG.md: prior ecosystem work mentions removed
- No legal change — clean-room audit already confirmed no derived code

### Removed build artifacts

- `.coverage` SQLite files (Python coverage traces) deleted — were mistakenly committed

### Kept

- `kennetvn` GitHub username in install URLs (public handle, required for install commands)
- `nextcore-ext-*` CSS class convention (framework naming, not personal)
