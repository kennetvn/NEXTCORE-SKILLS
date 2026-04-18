# Scenario: User customizes install (use pnpm not npm)

**Triggers:** `nc-install-tweaks`, `nc-cook`
**User profile:** Mid dev, team uses pnpm
**Setup:** Default agent assumes npm

## Turn 1

**User:** "Whenever you suggest a package install, use pnpm instead of npm. Always."

**Expected behavior:**
- Recognize this as a per-install tweak (not a one-off request)
- Activate `nc-install-tweaks` — propose saving
- Announce: `> Sẽ lưu thành global tweak nhé — Skill nc-install-tweaks lo việc này.`
- Show what will be saved:
  ```
  Tweak: [use-pnpm]
  Scope: global (mọi repo)
  Skill: nc-cook (and any skill suggesting installs)
  Directive: "Replace npm with pnpm in install commands"
  ```
- Ask: confirm save? (yes/project-only/cancel)

## Turn 2

**User:** "yes global"

**Expected behavior:**
- Write to `~/.nc/overrides/overrides.json`
- Confirm: `> Saved. Bây giờ mọi suggestion sẽ dùng pnpm. /nc-install-tweaks --list để xem.`
- Going forward in this session, all package commands use pnpm

## Turn 3

**User:** "Add lodash to my project"

**Expected behavior:**
- Apply tweak — output: `pnpm add lodash` not `npm install lodash`
- No need to re-confirm preference

## Turn 4 (next session)

**User:** "Add zod to project"

**Expected behavior:**
- Tweak persists across sessions (read from `~/.nc/overrides/overrides.json` at start)
- Output: `pnpm add zod` immediately, without re-asking

## Turn 5 (after a NEXTCORE-SKILLS update)

**Setup:** User runs `install.sh` to update from v2.5.3 to v2.5.4

**Expected behavior:**
- Installer detects existing `~/.nc/overrides/`
- Validates `[use-pnpm]` tweak still applies (skill `nc-cook` still exists)
- Preserves the override
- Reports: `> Updated. 1 tweak preserved: [use-pnpm].`

## Pass criteria

- Tweak saved on first ask, with clear scope
- Applied immediately + persists across sessions
- Survives skill-pack update
- User can `--list` and `--remove` anytime
