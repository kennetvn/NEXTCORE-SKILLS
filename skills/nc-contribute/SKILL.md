---
name: nc:contribute
description: "Detect skill gaps, propose additions to NEXTCORE-SKILLS upstream. Use when user asks for a workflow that should exist but doesn't, when a manual pattern repeats 3+ times, or when an improvement would benefit other users — then ask user consent to contribute via their GitHub."
license: MIT
argument-hint: "[--gap|--improvement|--bug]"
---

# Community Contribution Loop

NEXTCORE-SKILLS grows when users contribute. This skill turns useful one-off work into upstream value.

## Detection: when something is contribution-worthy

| Signal | Type | Action |
|---|---|---|
| User asks for a skill that doesn't exist (and 2+ users likely want it) | New skill | Propose adding |
| Same manual pattern done 3+ times across sessions | New skill or upgrade | Propose extracting |
| Existing skill has a bug or gap user just hit | Bug / improvement | Propose fix |
| User invented a clever pattern in their own workflow | New skill | Propose contributing |
| User's edge case isn't covered by existing skill | Improvement | Propose extending |
| User sets a tweak in their install repeatedly | Configurability | Propose making it a flag |

If any signal fires, this skill activates the consent flow.

## Consent flow (mandatory — never push without)

```
Bro, vừa rồi mình thấy một pattern hay (hoặc thiếu sót) ở NEXTCORE-SKILLS:

  → {1-line description of the gap/improvement}

Sếp Hảo (tác giả NEXTCORE-SKILLS) mong nhận đóng góp tích cực từ cộng đồng
để bộ skill ngày càng tốt cho mọi người. Nếu bạn đồng ý, mình có thể giúp
bạn submit contribution này qua GitHub account của bạn (fork → branch →
commit → PR).

Đồng ý đóng góp không? (yes / no / tell me more)
```

User responses:
- `yes` → proceed to "Contribution flow" below
- `no` → drop it, never re-ask this session, log a "deferred" note
- `tell me more` → explain what would be in the PR, what review looks like, then re-ask

## Contribution flow (after consent)

1. **Verify gh auth**
   - `gh auth status` — confirm user logged in to their GitHub
   - If not: guide them through `gh auth login`, return to step 1

2. **Fork upstream**
   - `gh repo fork kennetvn/NEXTCORE-SKILLS --remote=false --clone=false`
   - Clone fork to a temp working directory

3. **Create branch**
   - `feat/nc-{slug}` for new skill
   - `fix/nc-{name}-{issue}` for bug
   - `improve/nc-{name}-{aspect}` for improvement

4. **Apply the change**
   - For new skill: scaffold `skills/nc-{slug}/SKILL.md` using v2.5 template (frontmatter + purpose + pattern + examples + anti-patterns + integration)
   - For improvement: edit existing skill, run converter + build-all to regenerate adapters
   - For bug: minimal targeted fix, regen if needed
   - Update `CHANGELOG.md` under `[Unreleased]`

5. **Local verification**
   - `node adapters/build-all.cjs` — must succeed
   - `node scripts/generate-catalog-html.cjs` — must succeed
   - Diff review with user before commit

6. **Commit**
   - Conventional commit message
   - Body explains the WHY (the gap user hit)
   - Co-author trailer if user wants attribution: `Co-authored-by: <user> <email>`

7. **Push to fork**
   - `git push origin feat/nc-{slug}`

8. **Open PR**
   - `gh pr create --repo kennetvn/NEXTCORE-SKILLS --title "..." --body "..."`
   - PR body includes: motivation (real user scenario), what's added, how it integrates with existing skills, test plan
   - Tag PR as `community-contribution`

9. **Confirm + handoff**
   - Print PR URL to user
   - Tell user: "Sếp Hảo sẽ review. You'll get GitHub notifications. Cảm ơn đã đóng góp!"
   - Save contribution record to `nc-memory` under `contributions.{date}`

## What NOT to contribute

- Personal/secrets/private business logic
- Changes that only fit one user's repo
- Drive-by refactors not requested
- Cosmetic-only changes (whitespace, lint preferences)
- Breaking changes without prior discussion in an issue

For these: suggest user keep the change local in their `~/.nc/overrides/` (see `nc-install-tweaks`).

## Frequency limit

- Max 1 contribution proposal per user session (don't be pushy)
- If user said `no` to contribution this session, don't re-ask for 7 days
- Track refusals in `nc-memory.preferences.contribute_opt_out`
- If user opts out permanently → respect it, never bring up again

## Quality bar (so we don't spam upstream)

Before proposing, check:
- [ ] Pattern has been useful at least once in real work
- [ ] Skill follows naming convention (`nc-{kebab-case}`)
- [ ] Description is specific (trigger words user would actually type)
- [ ] No overlap with existing skill (use `nc-find-skills` to check)
- [ ] Under 200 LOC (per file size policy)
- [ ] No emoji unless explicitly part of the topic

If quality bar fails → don't propose, log to local notes for later refinement.

## Anti-patterns

- Suggesting contribution when user is mid-frustration (read `nc-sentiment` first)
- Pushing through even after `no` (one ask per session, period)
- Submitting a PR without showing user the diff first
- Using maintainer's account or generic credentials — must be user's GitHub
- Auto-merging or pinging maintainer aggressively
- Contributing partial/half-baked work — better to skip than spam

## Tracking outcomes

Save to `nc-memory.contributions`:

```json
{
  "contributions": [
    { "date": "2026-04-18", "type": "new-skill", "name": "nc-foo", "pr": "https://...", "status": "open" }
  ],
  "preferences": {
    "contribute_opt_out": false,
    "last_proposal": "2026-04-18"
  }
}
```

On future sessions, agent can mention: "Your nc-foo PR was merged — thanks for contributing!"

## Integration

- `nc-skill-announce` — when announcing a skill that's a recent gap, hint contribution
- `nc-find-skills` — used to check for overlap before proposing
- `nc-memory` — stores opt-out preference + contribution log
- `nc-install-tweaks` — local-only changes route here, NOT to contribute flow
- `nc-persona` — calibrates the consent message tone
- `nc-sentiment` — frustration → skip the ask entirely
