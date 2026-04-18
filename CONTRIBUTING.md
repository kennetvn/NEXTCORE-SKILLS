# Contributing to NEXTCORE-SKILLS

Thanks for your interest! This doc covers: adding a new skill, improving an existing skill, adding a new IDE adapter, and PR conventions.

## Quick reference

| I want to... | See section |
|---|---|
| Add a new skill | [Adding a skill](#adding-a-skill) |
| Improve an existing skill | [Improving a skill](#improving-a-skill) |
| Add a new IDE adapter | [Adding an IDE adapter](#adding-an-ide-adapter) |
| Report a bug | [Issue templates](#issue-templates) |
| Request review on a PR | [PR conventions](#pr-conventions) |

## Adding a skill

1. **Brainstorm first.** Is your skill truly needed? Check existing skills in `skills/` — avoid duplicates.
2. **Create the skill directory:** `skills/my-new-skill/`
3. **Write `SKILL.md` with frontmatter:**
   ```markdown
   ---
   name: nc:my-new-skill
   description: "One-sentence description that triggers the skill on relevant user queries."
   license: MIT
   argument-hint: "[main argument]"
   metadata:
     author: your-github-username
     version: "1.0.0"
   ---

   # My New Skill

   Purpose, principles, process, output format.
   ```
4. **Optional: add references:** `skills/my-new-skill/references/*.md` for supporting docs
5. **Regenerate adapters:**
   ```bash
   cd adapters/antigravity && node converter.cjs my-new-skill
   # then propagate to cursor/windsurf/copilot/continue/aider via their scripts or manual copy
   ```
6. **Update `skills/catalog.json`** by running the catalog generator (see `adapters/antigravity/converter.cjs` for the node pattern)
7. **Test your skill** — install via `./install.sh --ide=<your-ide>` and invoke it
8. **Submit PR** with the conventions below

## Improving a skill

1. Edit `skills/<skill-name>/SKILL.md` or `references/*.md`
2. Re-run adapter converters for affected IDEs
3. Test the skill invocation in your target IDE
4. Submit PR describing what changed and why

**Do NOT** edit adapter files (`adapters/**`) directly — they're derived from `skills/`.

## Adding an IDE adapter

Existing adapters: Antigravity, Cursor, Windsurf, Copilot, Continue, Aider.

1. **Research the IDE's convention** — where slash commands / prompts / workflows live, frontmatter format, invocation pattern
2. **Create `adapters/<ide>/README.md`** documenting specifics
3. **Create `adapters/<ide>/<commands-dir>/`** — start by copying from Cursor (single-agent compatible)
4. **Adapt frontmatter + paths** as the IDE requires
5. **Extend `install.sh` + `install.ps1`** with a new `--ide=<ide>` branch (follow existing pattern)
6. **Test end-to-end** with a clean install
7. **Submit PR** with adapter + install changes + README

## Per-skill install

Install specific skills only (Claude Code full framework):

```bash
./install.sh --ide=claude-code --skills=nc-plan,nc-debug,nc-brainstorm
```

For non-CC IDEs, all workflows are copied by default. Cherry-picking non-CC workflows requires manual copy from `adapters/<ide>/<dir>/`.

## Issue templates

Use these labels when opening issues:

- `bug` — something's broken
- `enhancement` — improve existing skill/adapter
- `new-skill` — proposal for a new skill
- `new-ide` — proposal for a new IDE adapter
- `docs` — docs issue

Include: IDE, skill name, expected vs actual behavior, screenshots/logs.

## PR conventions

- **Title:** conventional commits (`feat(skills): add nc-foo`, `fix(adapter-antigravity): ...`, `docs: ...`)
- **Body:**
  - What changed (1-3 bullets)
  - Why (motivation, bug reference, skill gap)
  - Test plan (how you verified)
  - Breaking changes (if any)
- **Scope:** one feature per PR. Don't bundle skill additions with adapter changes.
- **No AI references in commit messages** — write as if you wrote the code yourself

## Skill review checklist

Before PR, verify:

- [ ] `SKILL.md` has valid frontmatter (name, description, license)
- [ ] Description is specific enough to trigger correctly
- [ ] No duplicates of existing skills
- [ ] References in `references/` subdir are useful and not redundant with main body
- [ ] Adapters regenerated for ALL supported IDEs
- [ ] `skills/catalog.json` updated
- [ ] Tested in at least one IDE (preferably Claude Code + one other)
- [ ] No sensitive data (API keys, passwords) in examples

## Community code of conduct

- Be kind, direct, and technical
- Assume good intent, but call out mistakes promptly
- Vietnamese or English both welcome in issues/PRs
- Don't waste maintainer time — do the homework before asking

## Versioning

- Skills use semantic versioning in `metadata.version`
- Breaking changes to a skill bump major (2.0.0)
- Content additions bump minor (1.1.0)
- Typo fixes bump patch (1.0.1)
- Repo as a whole uses git tags for release snapshots
