---
description: Git operations with conventional commits. Use for staging, committing, pushing, PRs, merges. Auto-splits commits by type/scope. Security scans for secrets.
mode: agent
---

# Git Operations

## Default (No Arguments)

If invoked without arguments, ask the user in chat to present available git operations:

| Operation | Description |
|-----------|-------------|
| `cm` | Stage files & create commits |
| `cp` | Stage files, create commits and push |
| `pr` | Create Pull Request |
| `merge` | Merge branches |

Present as options via chat question with header "Git Operation", question "What would you like to do?".

Execute git workflows via `git-manager` subagent to isolate verbose output.
follow the `nc-context-engineering` workflow.

**IMPORTANT:**
- Sacrifice grammar for the sake of concision.
- Ensure token efficiency while maintaining high quality.
- Pass these rules to subagents.

## Arguments
- `cm`: Stage files & create commits
- `cp`: Stage files, create commits and push
- `pr`: Create Pull Request [to-branch] [from-branch]
  - `to-branch`: Target branch (default: main)
  - `from-branch`: Source branch (default: current branch)
- `merge`: Merge [to-branch] [from-branch]
  - `to-branch`: Target branch (default: main)
  - `from-branch`: Source branch (default: current branch)

## Quick Reference

| Task | Reference |
|------|-----------|
| Commit | `nc-git/references/workflow-commit.md` |
| Push | `nc-git/references/workflow-push.md` |
| Pull Request | `nc-git/references/workflow-pr.md` |
| Merge | `nc-git/references/workflow-merge.md` |
| Standards | `nc-git/references/commit-standards.md` |
| Safety | `nc-git/references/safety-protocols.md` |
| Branches | `nc-git/references/branch-management.md` |
| GitHub CLI | `nc-git/references/gh-cli-guide.md` |

## Core Workflow

### Step 1: Stage + Analyze
```bash
git add -A && git diff --cached --stat && git diff --cached --name-only
```

### Step 2: Security Check
Scan for secrets before commit:
```bash
git diff --cached | grep -iE "(api[_-]?key|token|password|secret|credential)"
```
**If secrets found:** STOP, warn user, suggest `.gitignore`.

### Step 3: Split Decision

**NOTE:**
- Search for related issues on GitHub and add to body.
- Only use `feat`, `fix`, or `perf` prefixes for files in `.claude` directory (do not use `docs`).

**Split commits if:**
- Different types mixed (feat + fix, code + docs)
- Multiple scopes (auth + payments)
- Config/deps + code mixed
- FILES > 10 unrelated

**Single commit if:**
- Same type/scope, FILES ≤ 3, LINES ≤ 50

### Step 4: Commit
```bash
git commit -m "type(scope): description"
```

## Output Format
```
✓ staged: N files (+X/-Y lines)
✓ security: passed
✓ commit: HASH type(scope): description
✓ pushed: yes/no
```

## Error Handling

| Error | Action |
|-------|--------|
| Secrets detected | Block commit, show files |
| No changes | Exit cleanly |
| Push rejected | Suggest `git pull --rebase` |
| Merge conflicts | Suggest manual resolution |

## References

- `nc-git/references/workflow-commit.md` - Commit workflow with split logic
- `nc-git/references/workflow-push.md` - Push workflow with error handling
- `nc-git/references/workflow-pr.md` - PR creation with remote diff analysis
- `nc-git/references/workflow-merge.md` - Branch merge workflow
- `nc-git/references/commit-standards.md` - Conventional commit format rules
- `nc-git/references/safety-protocols.md` - Secret detection, branch protection
- `nc-git/references/branch-management.md` - Naming, lifecycle, strategies
- `nc-git/references/gh-cli-guide.md` - GitHub CLI commands reference
