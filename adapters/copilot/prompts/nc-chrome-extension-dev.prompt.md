---
description: Chrome Extension Manifest V3 development patterns, content scripts for Facebook automation, anti-detection, and IIFE patterns. Use when working on files in <extensions-project>/ or <extensions-project>/.
mode: agent
---

# Chrome Extension Development (Manifest V3)

## Key Patterns
- Service Worker (NOT background.html)
- Content scripts with IIFE pattern (no remote script execution)
- Anti-detection patterns for Facebook automation
- Message passing between content script <-> service worker <-> popup

## Facebook DOM Interaction
Read detailed selectors and patterns from:
- `<storage-project>/resources/skill-library/facebook-dom/SKILL.md` — Selector library, popup handling, scroll orchestration
- `<storage-project>/resources/skill-library/chrome-extension/SKILL.md` — Manifest V3 patterns, service workers

## Design
- Follow AKA Design System: `<storage-project>/resources/skill-library/aka-design-system/SKILL.md`
- Popup/options pages must match the shared design language

## Content Script Template
```javascript
(function() {
  'use strict';

  // Wait for Facebook SPA to load
  const waitForElement = (selector, timeout = 10000) => {
    return new Promise((resolve, reject) => {
      const el = document.querySelector(selector);
      if (el) return resolve(el);

      const observer = new MutationObserver((mutations, obs) => {
        const el = document.querySelector(selector);
        if (el) { obs.disconnect(); resolve(el); }
      });
      observer.observe(document.body, { childList: true, subtree: true });
      setTimeout(() => { observer.disconnect(); reject(new Error('Timeout')); }, timeout);
    });
  };

  // Extension logic here...
})();
```

## Rules
- No eval() or remote code execution
- All permissions must be declared in manifest.json
- Use chrome.storage.local for state (not localStorage)
- Anti-detection: randomize delays, mimic human scroll patterns
