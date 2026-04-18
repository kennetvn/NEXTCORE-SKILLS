---
name: nc:usage-telemetry
description: "Opt-in usage telemetry for skills. Use when enabling anonymized tracking to inform skill optimization, detect broken skills in field, or prioritize maintenance. Privacy-respecting by design."
license: MIT
argument-hint: "[enable|disable|view|opt-out]"
---

# Usage Telemetry (opt-in)

**Privacy-first:** disabled by default. User explicitly enables. No PII. Anonymized. Revocable.

## What we track (when opted in)

- Skill invocations (which skill, when)
- Model used (opus/sonnet/haiku)
- Session duration for skill
- Success/failure signal (not content)
- Approximate token usage bucket (small/medium/large)
- IDE (claude-code/cursor/etc)

## What we DON'T track

- User prompts/queries
- Code content
- File paths
- Error messages
- API keys or secrets
- Any PII

## Consent flow

### First-time prompt

```
┌─────────────────────────────────────────────────────────────┐
│ NEXTCORE Telemetry                                          │
├─────────────────────────────────────────────────────────────┤
│ Help improve NEXTCORE by sharing anonymous usage data?     │
│                                                             │
│ We track: skill invocations, success rate, duration.        │
│ We NEVER track: your code, prompts, files, or PII.          │
│                                                             │
│ [ Allow ]  [ Decline ]  [ Learn more ]                      │
└─────────────────────────────────────────────────────────────┘
```

Choice saved to `~/.nc.json`:

```json
{
  "telemetry": { "enabled": true, "userId": "anon-abc123..." }
}
```

## Data format

```json
{
  "event": "skill_invoked",
  "skill": "nc-plan",
  "userId": "anon-abc123...",
  "sessionId": "sess-xyz789",
  "timestamp": "2026-04-18T10:30:00Z",
  "ide": "cursor",
  "model": "claude-opus-4-7",
  "success": true,
  "duration_bucket": "30-60s",
  "token_bucket": "10k-20k",
  "version": "2.4.0"
}
```

Events: `skill_invoked`, `skill_completed`, `skill_failed`, `session_start`, `session_end`.

## Opt-out

Disable anytime:

```bash
nc telemetry --disable
# or edit ~/.nc.json:
# "telemetry": { "enabled": false }
```

Existing data NOT retroactively collected. After opt-out, no new data sent.

## Data retention

- 90 days rolling window
- Aggregated stats retained longer (no per-user data)
- User can request deletion via email → anon ID removed within 30 days

## Collection endpoint

```
POST https://telemetry.nextcore.dev/v1/events
```

- HTTPS only
- Rate-limited (100 events/min per user)
- Failed sends retry once, then drop (no blocking user)
- Opt-out check before every send

## What telemetry enables

### For maintainers

- **Most-used skills** — prioritize maintenance
- **Broken skills** — error rate spike → investigate
- **Slow skills** — p95 > threshold → optimize
- **Model drift** — same skill slower on new model → report bug
- **IDE adoption** — which IDEs have active users

### For users (opt-in dashboard)

- Personal stats: skills used this week, time saved estimate
- Suggestions: "You haven't tried nc-predict — useful for big refactors"
- Cost tracking (if model API used directly)

## Privacy architecture

- **Client-side aggregation** — send daily batches, not per-event when possible
- **No IP logging** — strip at ingestion
- **No device fingerprinting**
- **Anon ID rotatable** — user can reset via command
- **Open-source telemetry code** — auditable at `scripts/telemetry.js`

## GDPR / CCPA compliance

- Explicit consent required
- Right to access (`nc telemetry --export`)
- Right to delete (`nc telemetry --delete`)
- Data processing agreement published
- EU data residency (if required)

## Dashboard example (for maintainers)

```
Weekly skill usage (anonymous)
┌─────────────────────────────────────┐
│ nc-plan:       4,230 invocations    │
│ nc-cook:       3,890                │
│ nc-debug:      2,100                │
│ nc-brainstorm: 1,800                │
│ ...                                 │
│                                     │
│ Error rate by skill                 │
│ nc-security:   1.2% (high!)         │
│ nc-cook:       0.3%                 │
└─────────────────────────────────────┘
```

## Anti-patterns

- Tracking without consent (illegal in most jurisdictions)
- Tracking content (privacy violation)
- No opt-out path
- Requiring telemetry for skill function
- Sharing individual user data publicly
- Retention forever

## Integration

- `nc-skill-eval` — telemetry informs eval case selection
- `nc-skill-bench` — real-world perf data supplements synthetic bench
- `nc-observability` — uses same stack internally (OpenTelemetry)
