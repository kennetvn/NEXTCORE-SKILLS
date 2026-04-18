# Scenario: First-time install + analyze + use

**Triggers:** `nc-onboard`, `nc-memory`, `nc-persona`, `nc-skill-announce`
**User profile:** Brand new install, no `nc-memory` profile
**Setup:** `~/.nc-memory/_global/identity.json` does not exist

## Turn 1

**User:** "Tôi vừa cài NEXTCORE-SKILLS xong, bạn phân tích các skill này có tác dụng gì và giúp tôi cài đặt với."

**Expected behavior:**
- Detect no prior profile via `nc-memory` → activate `nc-onboard`
- Announce skill usage: `> Dùng nc-onboard để setup profile + giới thiệu ecosystem.`
- Reply in Vietnamese (mirror user's language)
- Run Step 1 survey: 3 short questions (role / level / style)
- Each question has multiple choice, ≤5 options
- Total message under 200 words

**Anti-patterns to avoid:**
- Wall of text listing all 110 skills upfront
- Switching to English when user wrote VN
- Skipping the announce line
- Asking 10 questions instead of 3
- Auto-installing tweaks before user expressed preference
- Lecturing "NEXTCORE-SKILLS is a comprehensive framework that..." preamble

## Turn 2

**User:** "1c (full-stack), 2c (senior), 3a (terse)"

**Expected behavior:**
- Save to `nc-memory._global/identity.json`: `{role: full-stack, level: senior, style: terse}`
- Calibrate `nc-persona`: senior + terse → 1-paragraph max responses, term of art OK
- Show Step 2 (overview) — categorize 110 skills into 5-7 groups, with 2-3 example skill names per group
- Show Step 3 (try-it) — 3 specific commands matching full-stack role: `/nc-cook`, `/nc-tanstack`, `/nc-deploy-vps`
- Show Step 4 (mention `nc-contribute` + `nc-install-tweaks` once each)
- Mark `nc-memory.last_onboarded = today`

**Anti-patterns to avoid:**
- Showing UI-only suggestions despite full-stack answer
- Switching back to verbose tone (user said terse)
- Re-asking survey questions
- Pushing `nc-contribute` aggressively (one mention only)

## Turn 3

**User:** "Thử /nc-cook 'add user authentication endpoint'"

**Expected behavior:**
- Announce: `> Pipeline: nc-plan → nc-cook → nc-test. Bắt đầu plan.`
- Use senior + terse persona — concise plan, no excessive justification
- Mirror user's "endpoint" terminology (don't switch to "route" or "handler")
- Reference `nc-company-os` if scope warrants org thinking, otherwise just engineer-mode

**Anti-patterns to avoid:**
- Re-onboarding (user already onboarded this session)
- Re-asking technical level (already in memory)
- Wall of text explaining what `nc-cook` does (already covered in onboarding)

## Pass criteria

- After Turn 1: user understands the system in <60 seconds of reading
- After Turn 2: profile saved, agent is calibrated to senior + terse + VN
- After Turn 3: agent works without re-introducing itself
- Memory persists: opening new session next day, agent says `> Loaded profile: full-stack senior, VN, terse.`
