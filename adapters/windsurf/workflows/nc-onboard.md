---
description: First-run experience for new users. Use when user has just installed NEXTCORE-SKILLS, says 'help me get started', asks to 'phân tích / explain skills', or when no nc-memory profile exists yet for this user. Walks user through the ecosystem, sets preferences, suggests first useful skills.
auto_execution_mode: 1
---

# Onboarding

Brand new install → confident user in <5 minutes. Don't drown them in 110 skills; show the path.

## Trigger

This skill activates when:
- `nc-memory` reports no `_global/identity.json` for this user
- User says "I just installed", "phân tích các skill", "help me get started", "what can you do", "explain NEXTCORE"
- User runs `/nc-onboard` explicitly

If `_global/identity.json` exists AND `last_onboarded` is within 30 days → skip; respond with "Welcome back. Continue?"

## The 4-step flow

### Step 1 — Quick survey (3 questions, 1 minute)

```
Chào bro! NEXTCORE-SKILLS đã được cài. Trước khi vào việc, mình hỏi nhanh
3 câu để config trải nghiệm phù hợp với bạn:

1. Bạn chủ yếu làm gì? (chọn 1)
   a) Frontend / UI
   b) Backend / API
   c) Full-stack
   d) DevOps / Infra
   e) AI / ML
   f) Data
   g) Mixed / khác

2. Trình độ? (chọn 1)
   a) Mới học code (junior / non-tech)
   b) 1-3 năm exp
   c) Senior / staff
   d) CTO / tech lead

3. Style trả lời ưu tiên?
   a) Terse — 1-2 câu, code thẳng
   b) Balanced — vừa đủ context
   c) Verbose — giải thích kỹ
```

Save answers to `nc-memory._global/identity.json` + `preferences.json`. Calibrate `nc-persona` defaults from these.

If user says "skip", set sensible defaults: full-stack / senior / balanced.

### Step 2 — Show what they get (30 seconds)

```
Bạn vừa unlock 110 skills. Phân theo nhóm:

  Workflow chính:     /nc-cook (build) · /nc-debug (fix) · /nc-plan (design)
  Agent UX:           /nc-persona · /nc-memory · /nc-mirror · /nc-sentiment
  Stack chuyên sâu:   /nc-backend · /nc-frontend · /nc-databases · /nc-payment
  Quality:            /nc-test · /nc-code-review · /nc-security
  Community:          /nc-contribute · /nc-install-tweaks
  Org model:          /nc-company-os (when working on big features)

Tất cả 110 skills: /nc-find-skills hoặc xem catalog.html.
```

Calibrate which skills to highlight based on Step 1 answer (frontend → show UI skills first; DevOps → show infra/deploy first).

### Step 3 — Suggest 3 first commands (the "try it" moment)

Based on user role, suggest 3 specific commands they can try right now:

| Role | Try first |
|---|---|
| Frontend | `/nc-frontend-design` (sample component), `/nc-ui-styling`, `/nc-web-testing` |
| Backend | `/nc-backend-development` (sample API), `/nc-databases`, `/nc-security` |
| Full-stack | `/nc-cook` (sample feature), `/nc-tanstack`, `/nc-deploy-vps` |
| DevOps | `/nc-deploy-vps`, `/nc-ci-cd`, `/nc-observability` |
| AI / ML | `/nc-ai-multimodal`, `/nc-llm-integration`, `/nc-rag-patterns` |

Show command + 1-line outcome:

```
Thử ngay 3 lệnh này để cảm nhận:

  /nc-frontend-design "responsive nav bar"
    → tạo navbar production-grade theo design system

  /nc-ui-styling "dark mode toggle"
    → component shadcn/ui chuẩn, có theme switching

  /nc-web-testing
    → Playwright setup + sample test
```

### Step 4 — Tell them about contribution + tweaks

```
Hai tính năng đặc biệt:

  /nc-contribute     → khi bạn thấy skill nào thiếu hoặc có thể cải thiện,
                       skill này giúp bạn submit PR upstream qua GitHub
                       của bạn. Sếp Hảo (tác giả) khuyến khích contribution.

  /nc-install-tweaks → tùy chỉnh defaults cho riêng máy bạn (vd dùng pnpm
                       thay npm, default tiếng Việt, skip confirm cho 1 số
                       action). Tweaks survive khi update skill pack.

Done. Bắt đầu được rồi. Bạn muốn làm gì đầu tiên?
```

Mark `nc-memory.last_onboarded = today` so this doesn't re-run.

## Variants

### `--quick` mode

Skip the survey. Just show step 2 (overview) + step 3 (try-it). 30 seconds total.

Used when user says "tldr" or "just show me the skills".

### `--full` mode

Adds:
- Walk through the Context Protocol (`docs/context-protocol.md`)
- Show how skills compose (point to `nc-skill-composition`)
- Demo a full pipeline live (`nc-research → nc-plan → nc-cook` mini-example)
- 5-10 minutes total

Used when user says "I want to deeply understand" or `/nc-onboard --full`.

### `--skip-survey` mode

For returning users on a new machine — uses prior preferences from synced `~/.nc-memory/_global/`.

## Calibration after onboarding

After Step 1 survey:
- `nc-persona`: load level → CTO/senior/junior/nontech mapping
- `nc-mirror`: language preference baked in (VN/EN)
- `nc-response-format`: terse/balanced/verbose default
- `nc-memory.preferences`: persisted

Future sessions skip onboarding entirely — agent already knows the user.

## Anti-patterns

- Long welcome wall of text — onboarding should feel like 4 short messages, not an essay
- Listing all 110 skills upfront — overwhelming; show 5-10 relevant
- Forcing the survey — `skip` always available, defaults are sane
- Re-onboarding every session — once per user-machine, not per session
- Assuming user reads docs — explain in chat, link docs as "later"
- Pushing `nc-contribute` aggressively — mention once, never again
- Pretending the system is simpler than it is — be honest about scale

## Re-onboarding (intentional)

User can re-trigger onboarding anytime:
- `/nc-onboard --reset` → clear memory, redo survey (e.g., role changed)
- `/nc-onboard --full` → deeper walkthrough (different from initial)

## Integration with installer

After `install.sh` / `install.ps1` succeeds, last line should suggest:

```
Installed 110 skills. Run `/nc-onboard` in your IDE to set up your profile (1 min).
```

Don't auto-trigger from installer — let user invoke when they're ready.

## Integration with skills

- `nc-memory` — stores profile, identity, last_onboarded; checks before re-running
- `nc-persona` — calibrated from survey answers
- `nc-mirror` — language preference
- `nc-router` — knows when to suggest onboarding (e.g., user asks vague meta-questions)
- `nc-response-format` — terse/verbose default from survey
- `nc-find-skills` — referenced in Step 2 as the discovery tool
- `nc-contribute` — mentioned in Step 4, never auto-pushed
- `nc-install-tweaks` — mentioned in Step 4 as the customization layer
