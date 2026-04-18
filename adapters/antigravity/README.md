# Antigravity Adapter

Ports NEXTCORE skills to [Google Antigravity](https://antigravity.google) IDE.

## Antigravity specifics

- **Workflows live in** `.agent/workflows/*.md`
- **Frontmatter:** only `description:` is consumed (shown in slash-command picker)
- **Invocation:** user types `/workflow-name` in chat
- **Directives:** `// turbo-all` at top of workflow = run in turbo mode (apply-edits auto-accepted)
- **No hooks**, no subagent API, no `Skill` tool — workflow is plain prose the agent reads and follows
- **Callouts:** GitHub-flavor `> [!CAUTION]` / `> [!NOTE]` / `> [!TIP]` render nicely

## Conversion rules (Claude Code → Antigravity)

| Claude Code | Antigravity equivalent |
|---|---|
| `name: nc:brainstorm` | Filename `nc-brainstorm.md` (no frontmatter `name` field) |
| `argument-hint: "[topic]"` | Remove (use `$ARGUMENTS` inline instead) |
| `metadata.author/version` | Remove (lives in repo git history) |
| `license: MIT` | Remove (repo LICENSE covers) |
| `AskUserQuestion` tool call | "Ask user clarifying questions in chat" |
| `WebSearch` tool | "Use web search via the browser or search tool" |
| `Skill` tool invoke | "Follow the `workflow-name` workflow instructions" |
| Subagent `Task(...)` | "Delegate to the `ai-developer` workflow" (or inline the steps) |
| `.claude/.nc.json` config | `.agent/.nc.json` fallback — document defaults if absent |
| `## Naming` hook injection | Inline fallback: `plans/reports/{type}-{YYMMDD}-{HHMM}-{slug}.md` |

## Install (manual for now)

```bash
# From project root where .agent/ exists:
cp adapters/antigravity/workflows/*.md .agent/workflows/

# Or symlink (keeps adapter in sync if you pull repo updates):
for f in adapters/antigravity/workflows/*.md; do
  ln -sf "$(pwd)/$f" ".agent/workflows/$(basename $f)"
done
```

Automated install via `install.sh --ide=antigravity` is planned for Phase 2.5 v2.

## Available workflows

v1 ships 2 flagship skills as proof-of-concept:

- `nc-brainstorm.md` — trade-off analysis, architecture debates (fully portable)
- `nc-research.md` — multi-source tech research with Gemini/WebSearch (portable with config fallback)

Next wave (v2):

- `nc-plan`, `nc-debug`, `nc-scenario`, `nc-security`, `cook`, `fix`

## Antigravity-specific tips

1. **Agent Teams:** Antigravity's built-in `ai-team` workflows (ai-developer, ai-tester, ai-ux-reviewer) replace Claude Code subagents. Skills that need parallel dispatch should reference these.
2. **Project memory:** Antigravity reads `AGENTS.md` + `CLAUDE.md` + `GEMINI.md` at root. NEXTCORE skills inherit this context — no separate injection needed.
3. **Turbo mode:** Add `// turbo-all` directive at top of workflow for auto-apply edits. Use sparingly — only for low-risk workflows.
4. **Slash command scope:** workflow files at `.agent/workflows/*.md` are auto-discovered. Nested dirs (`.agent/workflows/ai-team/`) become namespaced commands.

## Known limitations

- No structured task management (Claude Code `TaskCreate/Update`) — workflows rely on markdown checklists
- No hook-injected dynamic context (CWD, timestamps, plan paths) — workflows must construct these inline
- `psql`, `gemini`, `gh` bash commands work if user's shell has them (no Antigravity wrapper)
