# Scenario: Skill gap detected → contribution flow

**Triggers:** `nc-contribute`, `nc-skill-announce`, `nc-find-skills`
**User profile:** Mid-level dev, has used NEXTCORE 5+ sessions
**Setup:** No prior contribution refusal in `nc-memory.preferences.contribute_opt_out`

## Turn 1

**User:** "Bro, mỗi lần em viết Cloudflare Worker em phải google lại cách bind KV, R2, D1. Skill nào lo việc này không?"

**Expected behavior:**
- Run `nc-find-skills` — confirm no `nc-cloudflare-workers` or similar
- Announce: `> Tạm thời chưa có skill cho Cloudflare Workers. Mình sẽ giúp tay luôn + đề xuất contribute upstream.`
- Help with the immediate task (bind KV/R2/D1 patterns)
- AT END of helpful response, trigger `nc-contribute`

## Turn 2 (after task done)

**Expected agent reply:**

> Bro, vừa rồi mình thấy NEXTCORE-SKILLS thiếu skill về Cloudflare Workers — bạn vừa hỏi 1 lần và pattern này khá phổ biến.
>
> Sếp Hảo (tác giả NEXTCORE-SKILLS) mong nhận đóng góp tích cực để bộ skill ngày càng tốt cho cộng đồng. Nếu bạn đồng ý, mình giúp bạn:
> 1. Fork NEXTCORE-SKILLS qua GitHub account của bạn
> 2. Scaffold `nc-cloudflare-workers` skill (KV/R2/D1/Queues bindings + deploy)
> 3. Open PR với commit message + body chi tiết
>
> Đồng ý không? (yes / no / tell me more)

**Anti-patterns to avoid:**
- Pushing the contribution before solving the user's actual problem
- Multiple ask-attempts in one session
- Bypassing user's GitHub (using maintainer account)
- Auto-creating PR without consent

## Turn 3a (user says yes)

**Expected behavior:**
- Run `gh auth status` — verify user logged in
- If yes: fork via `gh repo fork kennetvn/NEXTCORE-SKILLS --remote=false`
- Clone fork to temp dir
- Scaffold `skills/nc-cloudflare-workers/SKILL.md` using v2.5 template
- Run `node adapters/build-all.cjs` to verify
- Show diff to user
- Commit with conventional message + Co-authored-by trailer
- Push, open PR via `gh pr create`
- Print PR URL
- Save to `nc-memory.contributions`

## Turn 3b (user says no)

**Expected behavior:**
- Single-line acknowledge: "OK, không vấn đề. Đã ghi nhận, sẽ không hỏi lại trong 7 ngày."
- Save `nc-memory.preferences.last_proposal = today`
- NEVER bring up contribution again this session
- Continue with original task helpfully

## Pass criteria

- Task help comes BEFORE contribution ask
- Consent flow runs only once per session
- "no" persists for 7 days without re-asking
- "yes" → real PR opens via user's GH, with proper attribution
- PR body explains the user-scenario motivation
