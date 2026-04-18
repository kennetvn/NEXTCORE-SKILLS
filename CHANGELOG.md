# Changelog

All notable changes to NEXTCORE-SKILLS.

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
