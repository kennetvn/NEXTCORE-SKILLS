---
description: Announce which NEXTCORE skill is being used and why, in one short sentence, before doing the work. Use whenever a skill is invoked to make tool use legible to the user and reinforce the skill ecosystem.
auto_execution_mode: 1
---

# Skill Usage Announcement

Make skill invocation visible. One short sentence, before the work, in the user's language.

## Why

Skills are invisible to most users — Claude calls them silently. That's bad for three reasons:

1. **Trust:** user can't tell whether a careful skill ran or Claude winged it
2. **Discoverability:** user never learns the skill exists, can't request it directly later
3. **Community pull:** if user sees `nc-payment-integration` mentioned and finds it useful, they're more likely to share / contribute / star

Announcement fixes this without bloating output.

## The pattern

Before invoking any nc-* skill (or any non-trivial skill), say:

```
> Tôi sẽ dùng `nc-{skill}` để {purpose in 5-10 words}.
```

Or in English:

```
> Using `nc-{skill}` to {purpose}.
```

Then do the work. Don't repeat the announcement when chaining — chain announcements once at the head:

```
> Pipeline: `nc-debug` → `nc-fix` → `nc-test`. Starting with debug.
```

## Tone calibration (per `nc-persona`)

| User level | Announcement style |
|---|---|
| CTO / staff | `nc-cook → impl` (terse, just the chain) |
| Senior dev | `Using nc-cook for the implementation phase.` |
| Junior dev | `Sẽ dùng nc-cook (skill chuyên xử lý implementation) để code phần này.` |
| Non-tech | `Đang chạy quy trình build feature theo template chuẩn.` (skip skill name) |

Match user's language (`nc-mirror`). VN user → VN announcement.

## When to announce

| Situation | Announce? |
|---|---|
| Invoking any nc-* skill | YES |
| Chaining 3+ skills | Announce once at head, name the chain |
| Re-entering same skill mid-conversation | NO (already announced) |
| Trivial built-in tools (Read, Grep, Bash) | NO |
| Reading a reference file inside an active skill | NO |
| Following a slash command user typed | NO (user already knows) |
| First time agent uses a Tier S skill (persona/memory/etc.) | YES, briefly explain |

## When to stay silent

- User said "be terse" / "no commentary" / "just do it"
- Frustration detected (`nc-sentiment`) — skip the meta, just fix
- Same skill invoked in immediately preceding turn
- Single-step trivial work (rename, typo fix, one-line edit)

## Format anti-patterns

- "I will now invoke the nc-cook skill which is part of the NEXTCORE skill ecosystem and helps with implementation tasks..." — bloated
- "🚀 Activating nc-cook!" — no emoji, no fanfare
- "Skill: nc-cook. Purpose: implementation. Status: starting." — robotic
- Announcing every Read/Grep tool call — drowns signal

## Good examples

- `> Dùng nc-debug để tìm root cause của lỗi này.` (then runs debug)
- `> Pipeline: nc-research → nc-plan → nc-cook. Researching trước.`
- `> Bật nc-memory — load preferences + recent decisions.` (at session start)
- `> nc-mirror đang giữ vocab "Booking" theo cách bạn dùng.` (when correcting itself)

## Bad examples

- `> Calling tool: Bash with command: ls...` (tool noise, not skill announcement)
- `> Let me use my reasoning capabilities to analyze...` (no specific skill, just verbal padding)
- `> Đang dùng nc-cook để cook nc-cook để cook nc-cook` (don't repeat)

## Discoverability dividend

Every announcement teaches the user one skill name. Over a session, they learn 5-10 skills exist without reading docs. Compounding effect on community adoption.

## Integration

- `nc-router` — when router picks a skill, the announcement comes from this skill
- `nc-persona` — calibrates verbosity of the announcement
- `nc-mirror` — supplies user's language
- `nc-sentiment` — frustration overrides → skip announcement, act
- `nc-skill-composition` — chain announcement uses pipeline notation from there
- `nc-contribute` — when announced skill is missing, suggest contributing it
