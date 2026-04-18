---
name: facebook-dom
description: Facebook DOM selectors, popup handling, scroll orchestration, and user info extraction for Chrome Extension content scripts. Use when writing Facebook automation code.
paths: "**/<extensions-project>/**/content*.js,**/<extensions-project>/**/facebook*.js"
---

# Facebook DOM Patterns

## Key Capabilities
- Selector library for Facebook UI elements (verified 2026-01-30)
- User info extraction (name, avatar, profile URL)
- Popup/dialog detection and handling
- Scroll orchestration for lazy-loaded content
- Anti-detection patterns (human-like delays, scroll simulation)

## Critical Rules
- Facebook changes DOM frequently — selectors may break
- Always use `data-*` attributes over class names when possible
- Use MutationObserver for SPA navigation detection
- Randomize all delays (never fixed intervals)
- Test selectors manually before committing

## Full Reference
Read the complete selector library and patterns:
`<storage-project>/resources/skill-library/facebook-dom/SKILL.md`

## Related Skills
- Extension patterns: `<storage-project>/resources/skill-library/chrome-extension/SKILL.md`
- Design system: `<storage-project>/resources/skill-library/aka-design-system/SKILL.md`
