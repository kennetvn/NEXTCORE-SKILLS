---
description: Understand legacy / unfamiliar code. Use when inheriting a codebase, investigating why some weird code exists, finding the original requirement behind a feature, or before refactoring code older than your tenure.
mode: agent
---

# Code Archaeology

Code that looks weird usually had a reason. Find the reason before "fixing" it.

## The 5-question protocol before changing legacy code

1. **When was it added?** — `git blame`, `git log -- <file>`
2. **Why was it added?** — commit message, PR description, linked ticket
3. **Who owns it?** — `git shortlog`, CODEOWNERS file, current team
4. **What broke last time someone "improved" it?** — search closed issues, postmortems
5. **Is the original requirement still valid?** — confirm with PM / stakeholder

Skipping any of these = inviting a regression that already happened once.

## Git archaeology toolbox

```bash
# Who wrote this line and when?
git blame -L 42,50 src/auth.ts

# Follow the line through history (across renames!)
git log --follow -p -- src/auth.ts | less

# Why was this file changed?
git log --oneline --all -- src/auth.ts | head -20
git log -p -- src/auth.ts | head -100

# Find when a string appeared / disappeared
git log -S "specificString" --oneline               # added or removed
git log -G "regex.*pattern" --oneline               # any change matching regex

# What did this file look like at version X?
git show v1.2.0:src/auth.ts

# Bisect for behavior introduction
git bisect start; git bisect bad HEAD; git bisect good v1.0.0

# Show all commits touching a function (best-effort)
git log -L :functionName:src/auth.ts
```

## Reading commit messages

Good messages have:
- WHY (the bug, the request, the constraint)
- Linked ticket / issue
- Tradeoff considered

Bad messages: `fix`, `update`, `wip`, `as discussed`. When you see these:
- Check the merge commit — maybe the PR description has the why
- Check linked issues / PRs in repo platform
- Check Slack/Linear/Jira around the date
- Ask the author (still around?) — but only after exhausting written sources

## Finding original intent

For features whose purpose isn't obvious:

1. **Ticket archaeology**: search Jira/Linear/GitHub issues by date range + keywords
2. **PR description**: github/gitlab UI, look at the merge that introduced
3. **Old design docs**: search Confluence/Notion/Google Drive for keywords
4. **Slack archive**: search messages around merge date
5. **Postmortems**: maybe this code IS the fix to a past incident
6. **Tests as documentation**: tests often encode invariants the code enforces

If still mystery: respect Chesterton's Fence. Don't remove until you know why it's there.

## Codebase onboarding (fresh repo)

When you join a project:

```
Day 1:
- Read README, CONTRIBUTING, top-level docs
- Run the project locally — feel the dev loop
- git log --oneline | head -50 — recent activity
- find . -name CODEOWNERS -o -name .github/CODEOWNERS — who owns what
- ls docs/ adr/ rfc/ — design decisions

Day 2-3:
- Read 5 most-changed files: git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head
- Trace a happy-path request end-to-end (entry → DB → response)
- Trace one auth flow
- Identify the hot paths via observability dashboards

Week 1:
- Pick a small bug, fix it, ship it (forces touching the dev loop)
- Map services + dependencies on a whiteboard
- Document gaps in onboarding for next person
```

## Identifying load-bearing code

Some files are sacred — touching them breaks things. Spot them:

| Signal | Meaning |
|---|---|
| Many recent commits across many authors | Active hot zone, careful |
| Few commits, all old | Stable foundation OR forgotten swamp |
| `.bak`, `.old`, `_v2`, `final_FINAL` versions | Past refactor scar |
| TODO / FIXME with year > 2 | Tech debt, low priority |
| Test files that test obscure invariants | Past bug enshrined, don't break |
| `// DO NOT REMOVE`, `// hack for ticket-1234` | Read the linked ticket BEFORE touching |

## Tracking down "why is this slow / broken / weird"

```
1. Reproduce the behavior (capture exact input + output)
2. git blame the suspect line(s)
3. Read the commit that introduced it
4. Read the commit message + PR description
5. If unclear → check linked ticket
6. If still unclear → ask author
7. Document findings in current PR (so future you doesn't redo this)
```

Your refactor PR description should include "WHY this code exists today: <link to original PR>; WHY it can be changed now: <link to obsoleted ticket / changed requirement>".

## When to NOT remove "weird" code

Even after archaeology, sometimes leave it:
- Workaround for external bug still present (link the upstream issue in a comment)
- Edge case for a customer that pays a lot
- Compatibility shim for a deprecation path not yet complete
- Performance optimization that benchmarks confirmed

If you must change: add tests that prove the behavior stays correct.

## Anti-patterns

- "This code is bad, let me clean it up" without checking why it's there
- Mass refactor PRs touching unrelated files
- Removing comments that document non-obvious behavior
- Trusting `// TODO` from 5 years ago (often already done elsewhere)
- Bypassing CODEOWNERS to ship faster (you'll get reverted)
- Asking "who owns this?" before doing 30 min of archaeology yourself
- "git blame is mean" — git blame is informational, use it

## Integration

- `nc-debugging-advanced` — when bug is in unfamiliar code
- `nc-debug` — root cause sometimes lives in commit history
- `nc-refactor` — archaeology before touch
- `nc-company-os` — code review uses CODEOWNERS / RACI
- `nc-docs` — document findings as ADRs for next archaeologist
- `nc-incident-response` — postmortems as archaeology source
