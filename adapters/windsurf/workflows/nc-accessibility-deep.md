---
description: Build accessibility into UI — not as audit afterthought. Use when designing components, planning a11y testing, fixing audit findings, supporting screen readers / keyboard nav, or going beyond WCAG checklist into real user impact.
auto_execution_mode: 1
---

# Accessibility Skill

Accessibility shipped early is cheap. Bolted on at audit is expensive and incomplete.

## The 4 disability categories (don't optimize for one)

| Category | Includes | Key needs |
|---|---|---|
| Visual | Blindness, low vision, color blindness | Screen readers, contrast, zoom |
| Auditory | Deaf, hard of hearing | Captions, transcripts, no audio-only signals |
| Motor | Limited dexterity, tremor, paralysis | Keyboard nav, large hit targets, no precise gestures required |
| Cognitive | Dyslexia, ADHD, memory issues | Simple language, clear structure, no time pressure |

WCAG 2.2 AA is minimum. AAA is gold. Beyond standards: real user testing.

## Semantic HTML first (free 60% accessibility)

```html
<!-- BAD: divs everywhere, no meaning -->
<div onclick="..." class="btn">Submit</div>

<!-- GOOD: native semantics -->
<button type="submit">Submit</button>
```

Native elements give you for free:
- Keyboard support (button = Enter/Space activates)
- Screen reader semantics ("button, Submit")
- Focus states
- Form integration

Custom div widgets need ALL the wiring + ARIA + tests. Use native HTML when it exists.

## Focus management

```css
/* Visible focus ring — never `outline: none` without replacement */
:focus-visible {
  outline: 2px solid #007aff;
  outline-offset: 2px;
}

/* Skip link for keyboard users */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
}
.skip-link:focus { top: 0; }
```

```html
<a href="#main" class="skip-link">Skip to main content</a>
<header>...</header>
<main id="main">...</main>
```

Modal dialogs:
- Focus moves to dialog on open
- Tab cycles within dialog (focus trap)
- Escape closes
- Focus returns to trigger on close

```typescript
// React: use react-focus-trap or radix-ui Dialog
import * as Dialog from '@radix-ui/react-dialog';
// Handles all focus management correctly
```

## Color + contrast

- Text contrast: ≥ 4.5:1 (normal), ≥ 3:1 (large 18pt+ or 14pt bold)
- UI components: ≥ 3:1 against background
- Don't rely on color alone — pair with icon, text, or pattern

```
Color blind safe palette:
- Avoid red/green only signaling (most common color blindness)
- Pair colors with icons (✓ green check, ✗ red cross)
- Use shape + color (filled vs outlined, solid vs dashed)
```

Test: Chrome DevTools → Rendering → Emulate vision deficiencies. Or stark.co plugin.

## Screen reader patterns

```html
<!-- Visible text always best -->
<button>Save</button>

<!-- When icon-only, visible label or aria-label -->
<button aria-label="Save document">
  <svg>...</svg>
</button>

<!-- Decorative images -->
<img src="divider.png" alt="">  <!-- empty alt = decorative, screen reader skips -->

<!-- Meaningful images -->
<img src="chart.png" alt="Sales grew 23% in Q2 2026">

<!-- Live regions for dynamic updates -->
<div aria-live="polite">{statusMessage}</div>
<div aria-live="assertive">{urgentError}</div>
```

ARIA rules:
1. **First rule of ARIA**: don't use ARIA. Use semantic HTML.
2. **Second rule**: when you must, don't change semantics. `<button role="link">` is wrong.
3. Test with actual screen reader (VoiceOver on Mac, NVDA on Windows). Reading aloud is the test.

## Forms

```html
<!-- Label associated correctly -->
<label for="email">Email address</label>
<input type="email" id="email" name="email" required aria-describedby="email-hint email-error" />
<p id="email-hint">We'll never share your email.</p>
<p id="email-error" role="alert">{errorMessage}</p>
```

Rules:
- Every input has a `<label for=>` (visible, top placement)
- Required fields: visually marked + `aria-required="true"`
- Errors via `aria-describedby` + `role="alert"` for screen reader
- Error focus: move focus to first error on submit
- Group related: `<fieldset><legend>...`

## Keyboard navigation

Every interactive element must be reachable + operable by keyboard alone.

Test: unplug mouse for 30 minutes. Use only keyboard. What can't you do? Fix that.

Standard keys:
- Tab / Shift+Tab — move focus
- Enter — activate buttons/links
- Space — activate buttons, check checkboxes
- Arrow keys — within composite widgets (radio groups, menus, tabs)
- Escape — close dialog/menu

Custom widgets need explicit keyboard handlers.

## Mobile accessibility

- Tap targets ≥ 44×44 px (Apple HIG) / 48×48 dp (Material)
- Don't rely on hover (no hover on touch)
- Don't require multi-finger gestures (single-finger required)
- Pinch-to-zoom NEVER disabled (`<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=yes">`)
- Voiceover/TalkBack support: test with screen reader on physical device

## Auditing tools (don't ship without)

- **axe DevTools** (browser ext) — automated catches ~30-50% of issues
- **Lighthouse** (Chrome) — accessibility section, aim ≥95
- **WAVE** (browser ext) — visual overlay
- **NVDA** (Windows, free) — screen reader test
- **VoiceOver** (Mac built-in) — Cmd+F5
- **Pa11y** — CLI for CI integration
- **Manual keyboard test** — irreplaceable

In CI:
```bash
npx pa11y https://staging.example.com/page  # fails build on errors
```

## Cognitive accessibility

Often forgotten. Quick wins:

- Plain language (grade 6-8 reading level)
- Don't auto-advance carousels (user controls pace)
- No flashing content (>3 flashes/sec = seizure risk — WCAG)
- Animations: respect `prefers-reduced-motion`
  ```css
  @media (prefers-reduced-motion: reduce) {
    * { animation: none !important; transition: none !important; }
  }
  ```
- No time limits on form completion (or: extend on request)
- Clear error recovery (don't lose form data on validation fail)

## Testing with real users

Lab tests with users who use assistive tech catch what tools miss.

- Recruit 3-5 users per disability category
- Pay them ($75-150/hr typical)
- Compensate fairly even if their device couldn't access your site (the finding IS the value)

Organizations to recruit through: Fable, AccessibilityWorks, NFB, AFB.

## Anti-patterns

- "We'll add accessibility in v2" (it gets harder, not easier)
- Lighthouse 100 ≠ accessible (false confidence)
- ARIA-everywhere (often makes worse than no ARIA)
- `tabindex="-1"` to "fix" focus issues (hides, doesn't fix)
- Custom toggles/dropdowns when native exists
- Ignoring screen reader output (must hear it to know)
- Color contrast issues "we'll style around it" (no, fix the colors)
- Disabling zoom on mobile
- Auto-playing audio/video with sound

## Integration

- `nc-frontend-design` — bake a11y into design system from day 1
- `nc-ui-styling` — shadcn/ui has accessible primitives
- `nc-ux-writing` — clear copy IS accessibility
- `nc-user-research` — test with disabled users
- `nc-web-design-guidelines` — broader UX rules
- `nc-test-strategy` — automated a11y in CI
- `nc-react-best-practices` — Radix UI is a11y-first
