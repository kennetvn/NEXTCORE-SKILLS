# NEXTCORE Telemetry Spec

**Status:** Draft v0.1 (targeting v3.0.0)
**Goal:** Opt-in skill usage telemetry that improves the framework over time. Privacy-first.

---

## Principle: opt-in, anonymized, transparent

- Off by default
- One command to enable: `/nc-install-tweaks --add --skill nc-telemetry --directive "enable"`
- Once enabled, user can inspect every record before sending
- Strictly: skill names + invocation outcomes + counts. Never user content.

## What's collected (when opt-in)

```json
{
  "schema_version": 1,
  "anonymous_id": "<random-uuid-per-install>",
  "events": [
    {
      "ts": "2026-04-18T20:46:00Z",
      "event": "skill.invoked",
      "skill": "nc-cook",
      "ide": "claude-code",
      "outcome": "completed | error | abandoned",
      "duration_sec": 47,
      "ide_version": "1.2.3"
    }
  ]
}
```

Explicitly NOT collected:
- File contents, file names, directory paths
- User prompts or model responses
- IP address, hostname, real name, email
- Project name, repo URL
- Any input or output text

## Where it lives

```
~/.nc-telemetry/
├── pending.jsonl           # buffered records awaiting send
├── sent.jsonl              # archive of what was sent (for audit)
└── identity.txt            # anonymous_id (UUID, generated once)
```

User can read, edit, or delete anytime. Files are plain text.

## Send cadence

- Buffer locally in `pending.jsonl`
- Send batch every 24 hours when IDE is open and user is active
- Send to `https://telemetry.nextcore-skills.dev/v1/events` (TBD endpoint)
- HTTP failures: keep in buffer, retry next cycle
- Buffer cap: 1000 events; oldest dropped beyond that

## Hook implementation

```javascript
// hooks/skill-invocation-log.cjs (Claude Code only initially)
const fs = require('fs');
const path = require('path');
const HOME = require('os').homedir();
const TELEMETRY_DIR = path.join(HOME, '.nc-telemetry');

function isEnabled() {
  const overrides = path.join(HOME, '.nc/overrides/overrides.json');
  if (!fs.existsSync(overrides)) return false;
  const o = JSON.parse(fs.readFileSync(overrides, 'utf8'));
  return o.tweaks?.some(t => t.skill === 'nc-telemetry' && t.directive === 'enable');
}

module.exports = function onSkillInvocation(event) {
  if (!isEnabled()) return;
  // ... append to pending.jsonl
};
```

## How users opt out (or never opt in)

Default state. Or:

- `/nc-install-tweaks --remove enable-telemetry` — disable
- Delete `~/.nc-telemetry/` — wipes all data
- `--directive "send-only-counts"` — even more minimal mode

## How insights flow back

Aggregated insights surface in:

- Public dashboard at `https://nextcore-skills.dev/usage` (anonymized totals)
- Quarterly community report ("most-used skills", "skills with high failure rate need investigation")
- Issue auto-creation: if a skill error rate > 20% across many users, maintainer is alerted

This drives:
- Which skills to deprecate (no usage)
- Which skills need bug fixes (high error rate)
- Which gaps to fill (related to `nc-contribute` data)

## Trust contract

The framework promises:
1. No collection without explicit opt-in
2. No content of files / prompts / outputs ever sent
3. Open-source ingestion code (auditable)
4. Open public dashboard (you see what we see)
5. Right to delete: removing `~/.nc-telemetry/` is sufficient
6. No correlation across users (anonymous_id is per-install, not per-user)

If trust contract is violated, project loses credibility — that's the existential risk maintainer accepts.

## Anti-patterns

- Auto-enabling on install (breaks opt-in promise)
- Sending content "for analytics" (slippery slope)
- Sending IP / device fingerprints (still identifies)
- Aggregating per-account stats (re-identifiable)
- Selling data (single line of revenue would tank trust)

## Status

Spec ready. Implementation lands as `nc-skill-telemetry` skill + opt-in hook in v3.0.x. Existing `nc-usage-telemetry` skill describes the user-facing pattern; this spec describes the framework hook.
