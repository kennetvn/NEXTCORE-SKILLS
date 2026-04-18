---
name: nc:incident-response
description: "Production incident playbook. Use when something is breaking in prod — coordinates the response (assess, mitigate, root-cause, postmortem) and prevents common screw-ups under stress."
license: MIT
argument-hint: "[detect|assess|mitigate|postmortem]"
---

# Incident Response

Stress makes people skip steps. This is the ladder. Don't skip rungs.

## Severity (decide in <5 min)

| Severity | Definition | Response |
|---|---|---|
| **P0 / SEV-1** | Site down, data loss, security breach in progress | War room now. Page CTO. All hands. |
| **P1 / SEV-2** | Major degradation: significant feature broken, payment failing, >25% error rate | War room. Page on-call manager. |
| **P2 / SEV-3** | Minor degradation: one feature broken, <10% users affected | On-call handles, no escalation. |
| **P3 / SEV-4** | Cosmetic: typo in error msg, slow but working | Backlog ticket. |
| **P4** | Tracking only (e.g., one customer complaint) | Investigate when calm. |

Err high. Demoting later is fine; promoting after calling P3 wastes time.

## The 4-phase playbook

### Phase 1 — DETECT (T+0 to T+5)

You got paged or saw an alert. Confirm:

- [ ] Reproduce the symptom (can you observe it yourself?)
- [ ] Check status page / dashboards — anything else broken?
- [ ] Check most recent deploy / config change (`git log --since="2 hours ago"`)
- [ ] Check upstream services (cloud provider status, dependencies)
- [ ] Confirm severity (don't guess)

**Output:** open an incident channel/doc with: symptom, severity, time started, IC (incident commander = whoever's driving).

### Phase 2 — MITIGATE (T+5 to T+30)

Stop the bleeding. Root cause LATER.

Mitigation options ordered by reversibility:

1. **Rollback the last change** (deploy, config, feature flag). Cheapest, often the answer.
2. **Disable the affected feature** (feature flag off, route disabled).
3. **Failover to standby** (DB replica, secondary region).
4. **Throttle / rate-limit** the bad actor or affected endpoint.
5. **Scale up** if it's load-related.
6. **Restart** affected services (last resort — may hide the cause).

Rules:
- Mitigations are CHEAP and REVERSIBLE
- Document every action with timestamp
- If a mitigation makes it worse → revert immediately, try next option
- Never use `rm -rf`, `DROP`, `--force` during incident without IC approval

### Phase 3 — ROOT CAUSE (after stable, before next incident)

Now investigate. Don't skip — same incident WILL recur.

Use `nc-debug` skill discipline. Ask:
- What was the trigger? (Deploy? Traffic spike? Cron job? External change?)
- What broke first? (Find the call-chain origin, not the surface symptom)
- Why did our defenses (monitoring, tests, canaries) miss it?
- What signal could we have had earlier?

Document findings in the incident doc.

### Phase 4 — POSTMORTEM (within 5 business days)

**Blameless.** Assume people did their best given the info they had. The system failed, not the person.

Template:
```markdown
# Postmortem: <incident title>

**Date:** YYYY-MM-DD
**Severity:** P<N>
**Duration:** <minutes>
**Impact:** <users affected, $ lost, SLA hit>

## Summary
<2-3 sentences: what happened, what we did, current state>

## Timeline
| Time (UTC) | Event |
|---|---|
| HH:MM | First alert fired |
| HH:MM | IC assigned |
| HH:MM | Mitigation A attempted (failed) |
| HH:MM | Rollback successful |
| HH:MM | Verified stable |
| HH:MM | All clear |

## Root cause
<specific, file:line, mechanism — not "we made a mistake">

## What went well
- <thing 1>
- <thing 2>

## What went poorly
- <thing 1 — the system / process, not people>
- <thing 2>

## Action items
| # | Action | Owner | Due | Priority |
|---|---|---|---|---|
| 1 | Add alert for X | @alice | YYYY-MM-DD | P0 |
| 2 | Add automated rollback for Y | @bob | YYYY-MM-DD | P1 |

## Detection gap
<could we have caught it sooner? what signal did we miss?>

## Process improvements
<runbook updates, training, etc.>
```

## During-incident communication

| Audience | What | Cadence |
|---|---|---|
| Engineering team | Technical updates | Every 15 min via channel |
| Leadership | Status + ETA | Every 30 min via DM |
| Customers (status page) | "We're investigating" → "Cause identified" → "Resolved" | At each phase change |
| Support team | Talking points | Once at start, updates as they happen |

Templates (status page):

```
INVESTIGATING: We're investigating reports of <symptom>. Updates every 30 min.

IDENTIFIED: We've identified the cause as <generic — never specific tech>. Working on a fix. ETA <time> or next update by <time>.

MONITORING: A fix has been applied. Monitoring for full recovery.

RESOLVED: Issue resolved as of <time>. Postmortem to follow within 5 business days.
```

## Roles in an incident

- **Incident Commander (IC)** — decides what to do. Not necessarily most senior. Does not type commands; coordinates.
- **Tech Lead / Operator** — actually runs the commands. Reports to IC before destructive actions.
- **Communications** — owns external comms (status page, customer support brief, leadership updates).
- **Scribe** — writes the timeline as events happen. Crucial for postmortem.

For small teams: one person can wear 2 hats but never IC + Operator (you'll skip the "did I just break it more?" check).

## What to NEVER do during an incident

- Solo decision on destructive action ("Let me just drop this table")
- Multiple people running commands in parallel without coordination
- Deploying a fix you didn't peer-review
- Hiding info from leadership / customers
- Taking the system down to "investigate cleanly" when partial degradation is acceptable
- Disabling alerting "because it's noisy right now"
- Skipping the timeline — you WILL forget when writing postmortem

## Pre-incident prep (calm time)

Worth more than any during-incident skill:

- [ ] On-call rotation defined, paging configured + tested
- [ ] Runbooks for top 5 failure modes (DB down, deploy failed, traffic spike, payment provider down, region failover)
- [ ] Rollback procedure tested in last 90 days
- [ ] Status page exists and team knows how to update
- [ ] Communication channels pre-defined (where do we converge?)
- [ ] Decision authority clear (who can call P0? who approves rollback?)
- [ ] Backup / restore drill done in last 90 days (`nc-backup-recovery`)

## Anti-patterns

- "Hero mode": one engineer fixes alone, no doc trail, no learning for team
- Postmortem as performance review (drives suppression of future incidents)
- "Action items" with no owner or no due date
- Postmortem written but never read (assign to discuss in next team meeting)
- Same root cause appearing in 3+ postmortems (you didn't actually fix it)
- "Just deploy the fix" without canary/staging — incidents on top of incidents

## Integration

- `nc-debug` — root-cause investigation discipline
- `nc-fix` — applies the fix once root cause known
- `nc-company-os` — incident response is THE canonical SRE/IC workflow
- `nc-backup-recovery` — restore is sometimes the mitigation
- `nc-observability` — alerts that triggered + signals during incident
- `nc-journal` — postmortem write-up template
- `nc-retro` — post-postmortem team learning
