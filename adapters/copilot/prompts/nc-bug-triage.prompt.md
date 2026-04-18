---
description: Triage bug reports — sort signal from noise, assign severity, route correctly, write actionable issues. Use when bug backlog is overwhelming, when reproducing reports, or when bugs keep slipping through to wrong owners.
mode: agent
---

# Bug Triage Skill

Untriaged backlog = noise. Triaged backlog = work queue. The difference is discipline.

## Triage flow (per bug)

```
New bug arrives
   │
   ↓
1. Reproducible? ── no ──→ Ask reporter for steps; close if no response in 7d
   │ yes
   ↓
2. Already known? ── yes ──→ Link as duplicate, close
   │ no
   ↓
3. In scope? ── no ──→ Move to "won't fix" with reason
   │ yes
   ↓
4. Set severity (S1-S4)
   ↓
5. Set priority (P0-P3) — based on severity × impact × business
   ↓
6. Assign owner (or label for team to claim)
   ↓
7. Add reproducer info (steps, env, screenshots, logs)
   ↓
8. Close labels: "triaged"
```

Time per bug: 2-5 min. Backlog of 500 → 1-2 days of focused triage.

## Severity vs Priority (these are different)

**Severity** = how broken (technical impact)
**Priority** = how soon to fix (business impact)

A typo on the marketing site (S4) can be P0 if launching today.
A rare edge case crash (S1) can be P3 if affects 0.01% of users on deprecated path.

| Sev | What |
|---|---|
| S1 / Critical | Data loss, security breach, complete failure |
| S2 / High | Major feature broken for many users |
| S3 / Medium | Workaround exists, affects subset |
| S4 / Low | Cosmetic, edge case, easy workaround |

| Pri | When |
|---|---|
| P0 | Drop everything, fix now |
| P1 | This week |
| P2 | This sprint / month |
| P3 | Backlog, opportunistic |

## The reproduction script

Bugs without reproduction steps are wishes. Always require:

```
**Environment**
- Browser/OS/version
- App version (or commit SHA)
- User role / permissions
- Date/time of occurrence

**Steps to reproduce**
1. ...
2. ...
3. ...

**Expected result**
...

**Actual result**
...

**Frequency**: always | sometimes | once
**Workaround**: ...
**Logs / screenshots**: ...
```

If reporter doesn't provide → ask once. If silent for 7 days → close as "Insufficient info".

## Routing

Look at the bug. Where does it live?

| Symptom | Route to |
|---|---|
| 500 error from API | Backend team |
| Layout broken in Safari | Frontend / browser-test |
| Email not sending | Notifications + email provider check |
| DB query slow | Backend + DBA |
| Webhook missing | Integrations team + provider status |
| Onboarding step blank | Frontend + analytics check |
| Permission denied for valid user | Auth + roles |

Not sure → assign to "needs-routing" label, weekly grooming meeting decides.

## Duplicates

Search before triaging:
- Title keywords
- Stack trace fingerprint (if available)
- Error message exact text
- Reporter said "I think this is similar to..."

Mark dupes with comment "Duplicate of #123, closing this one. Subscribe to #123 for updates." Don't merge silently — reporter loses thread.

## Backlog grooming (weekly, 30 min)

For piles of stale bugs:

1. Sort by oldest open
2. For each:
   - Still relevant? (Was the affected feature removed? Closed)
   - Still reproducible? (Try it; if not → "Cannot reproduce, please reopen with new info")
   - Still important? (Has user complained again? Drop priority)
3. Update labels, severity, priority
4. Close stale (no activity 90d, low priority)

This compounds — discipline now means less noise later.

## Bug report quality grading (for reporters)

When inviting external reports, share a template + grading:

- 🟢 Great: video repro + env + expected/actual
- 🟡 Usable: text steps + env
- 🔴 Useless: "It's broken"

Educate users to file better bugs. Internal: lead by example in your own bug filings.

## Recurring bug patterns (root cause analysis)

Same kind of bug appearing 3+ times = systemic. Don't just fix the instance.

Examples:
- 5 bugs about timezone display → no timezone strategy → write ADR
- 3 bugs about validation messages → no validation framework → adopt one
- Multiple "missing translation" bugs → no i18n CI check → add one

Track via labels (e.g., `pattern:timezone`, `pattern:validation`).

## Anti-patterns

- "We'll triage later" (later = never; backlog accumulates)
- Severity = priority (lose nuance)
- Closing without explanation (reporter feels ignored)
- Reopen wars (user → "this is broken!", agent → "WORKSFORME"). Talk first.
- 50 labels (use 5-10, opinionated)
- Triaging in panic during incidents (separate process — see `nc-incident-response`)
- Ignoring "edge case" bugs that hint at deeper issue
- Silent prioritization decisions (write WHY P3 not P0 in comment)

## Integration

- `nc-incident-response` — P0 incidents bypass normal triage
- `nc-test-strategy` — recurring bugs → missing test category
- `nc-debugging-advanced` — for hard reproducers
- `nc-company-os` — bug triage is QA + EM workflow
- `nc-debug` — engineer's debugging starts after triage
- `nc-journal` — postmortem-worthy bugs noted here
