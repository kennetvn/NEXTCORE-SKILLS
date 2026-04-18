---
description: Per-install customization layer. Use when user has install-specific preferences, local overrides, or repeated workflow tweaks that shouldn't be upstreamed but should persist across sessions and updates.
---

# Per-Install Customization

NEXTCORE-SKILLS ships opinionated defaults. Real teams need adjustments that don't belong upstream. This skill captures those adjustments locally and survives updates.

## Why this exists

| Scenario | Why upstream is wrong |
|---|---|
| Team uses `pnpm` not `npm` | Local convention, not universal |
| Deploy script targets `103.241.43.6` | One specific VPS |
| Vietnamese as default response language | User-specific |
| Custom commit prefix `[VIP-XXX]` | Team-specific |
| `nc-cook` should always run tests | Personal discipline preference |
| Skip `nc-clarify` consent for X actions | Trust level personal |

These belong locally. Upstreaming them would corrupt defaults for everyone else.

## Storage

```
~/.nc/overrides/
├── overrides.json          # global tweaks (apply to all projects)
├── {project-slug}/
│   ├── overrides.json      # project-specific tweaks
│   └── README.md           # human note on why these tweaks exist
└── _backup/                # snapshots before each `--add` operation
```

## Override schema

```json
{
  "version": "1.0",
  "tweaks": [
    {
      "id": "use-pnpm",
      "scope": "global",
      "skill": "nc-cook",
      "directive": "Use pnpm instead of npm for all install commands",
      "added": "2026-04-18",
      "rationale": "Team standard"
    },
    {
      "id": "auto-test-after-cook",
      "scope": "project:homestaylamdong",
      "skill": "nc-cook",
      "directive": "Always invoke nc-test after nc-cook completes, no confirm",
      "added": "2026-04-18"
    },
    {
      "id": "default-vn",
      "scope": "global",
      "skill": "nc-persona",
      "directive": "Default response language is Vietnamese unless user explicitly switches"
    }
  ]
}
```

## How tweaks apply

Every skill invocation reads `overrides.json` (global + project) at start:
1. Filter to tweaks matching the invoked skill
2. Inject directives into the skill's effective behavior
3. Tweaks are additive: defaults still apply unless explicitly overridden
4. Conflicts: project scope wins over global; later wins over earlier

`nc-context-budget` keeps overrides cheap — they're small, load always.

## Adding a tweak

User-visible flow:

```
> /nc-install-tweaks --add

Bro, mình thấy bạn vừa làm thao tác X 3 lần rồi. Lưu thành tweak nhé?

  → Skill: nc-cook
  → Directive: "Always pipe build output to | tail -20 instead of full dump"
  → Scope: project (chỉ áp dụng repo này) hoặc global (mọi repo)?

(yes-project / yes-global / no)
```

Or explicit add via command:

```
> /nc-install-tweaks --add --skill nc-cook --directive "Use bun instead of npm"
```

## Listing tweaks

```
> /nc-install-tweaks --list

Active tweaks (5 global, 3 project:homestaylamdong):

GLOBAL:
  [use-pnpm] nc-cook → Use pnpm instead of npm
  [no-emoji] nc-persona → Never use emoji in any response
  [vn-default] nc-persona → Default to Vietnamese
  [terse] nc-response-format → Always use minimal template
  [skip-confirm-deploy] nc-clarify → Skip confirm for staging deploys

PROJECT (homestaylamdong):
  [auto-test] nc-cook → Always run nc-test after cook
  [vps-target] nc-deploy-vps → Target 103.241.43.6 only
  [prisma-safe] nc-fix → Use .agent/scripts/prisma-safe.ps1 for any prisma cmd
```

## Removing / disabling

```
> /nc-install-tweaks --remove use-pnpm

Removed tweak [use-pnpm]. Snapshot saved to ~/.nc/overrides/_backup/.
```

## Surviving updates

When user updates NEXTCORE-SKILLS to a new version:
1. Installer detects existing `~/.nc/overrides/`
2. Validates each tweak against new skill versions:
   - Skill still exists? → keep
   - Skill renamed? → migrate (with confirm)
   - Skill removed? → flag, ask user
   - New conflicting default? → flag, ask user
3. Overrides survive intact unless explicitly broken

## Promotion to upstream

If a tweak proves universally useful:
- `nc-contribute` may pick it up and propose adding as a SKILL flag or default
- User keeps local tweak; upstream addition makes it available to all
- Both can coexist; local override always wins

## Sharing tweaks within a team

Export bundle:
```
> /nc-install-tweaks --export team-config.json
```

Teammate imports:
```
> /nc-install-tweaks --import team-config.json
```

Useful for onboarding new devs to team conventions.

## Anti-patterns

- Putting secrets in tweaks (use env vars / vault, not overrides.json)
- Tweaks that contradict each other silently — installer must flag
- Tweaks that disable safety checks for risky operations (require explicit ack)
- Stuffing complex logic into a tweak — if logic is needed, write a real skill
- Forgetting to document rationale (`rationale` field strongly recommended)

## Inspection / debug

```
> /nc-install-tweaks --debug nc-cook

Effective behavior of nc-cook (after applying tweaks):
  Default: install → build → test → report
  +[use-pnpm]: replace `npm` with `pnpm` in install step
  +[auto-test-after-cook]: skip "run tests?" confirm, always yes
  +[no-emoji]: response template strips emoji

Final pipeline: pnpm install → build → test (auto) → report (no emoji)
```

## Integration

- All skills — read overrides at start, apply matching directives
- `nc-memory` — overrides are config, not memory; separate concern
- `nc-contribute` — promotion path for universal-useful tweaks
- `nc-context-budget` — overrides always-on (small, important)
- Installer (`install.sh` / `install.ps1`) — preserves `~/.nc/overrides/` on update
- `nc-persona` — common tweaks live here (language, terseness, emoji)
