---
name: nc:ux-writing
description: "Write UI copy that respects users — error messages, button labels, empty states, onboarding, microcopy. Use when text in the product feels generic, condescending, or makes users feel dumb. Tone-of-voice consistency across product."
license: MIT
argument-hint: "[errors|buttons|empty|onboarding]"
---

# UX Writing Skill

The text IS the interface. Bad copy adds friction; good copy disappears.

## Principles (in order of priority)

1. **Clear over clever** — "Delete account" not "Wave goodbye 👋"
2. **Concise** — every word earns its place
3. **Conversational** — read aloud test: would a person say this?
4. **Consistent** — same idea = same word, every time
5. **Caring** — never blame the user

## Voice + tone

- **Voice** stays constant (your brand). Friendly? Formal? Witty?
- **Tone** adapts to context. Friendly + error = warmer. Friendly + success = celebratory.

Define voice in 3 axes:
- Formal ↔ Casual
- Serious ↔ Playful
- Reserved ↔ Enthusiastic

Document in a tone-of-voice doc. Audit randomly.

## Error messages

Bad: "Error: Invalid input."
Good: "Phone number must be 10 digits. You entered 9."

Formula: **What happened + Why + How to fix.**

| Bad | Good |
|---|---|
| "Something went wrong." | "We couldn't save your changes. Check your internet and try again." |
| "Invalid email." | "Email address needs an @ symbol. Like name@example.com." |
| "User already exists." | "An account with this email already exists. Sign in instead?" |
| "Authentication failed." | "Wrong password. Forgot it?" |
| "404 Not Found" | "We can't find that page. It may have moved. Search instead?" |

Never use:
- "Oops!" (childish for serious errors)
- "Sorry for any inconvenience" (generic, dismissive)
- "Please contact administrator" (who? how?)
- All caps, multiple ! 
- Stack traces in user-facing UI

## Buttons

- Verb + Noun. "Save changes" not "Submit" or "OK"
- Match the action. Cancel button cancels. Don't make Cancel mean "go back"
- Pair clearly. ["Cancel" | "Delete account"] — destructive on right with strong color
- Loading state: "Saving…" not "Loading…" (specific = trust)
- Disabled state: tooltip explaining why ("Add at least 1 item to checkout")

Bad button labels: "OK", "Submit", "Continue", "Click here", "Yes/No"
Good: "Save draft", "Send invitation", "Delete file", "Got it", "Maybe later"

## Empty states

Don't waste them. Empty = teaching moment.

Pattern:
1. Headline (what this is)
2. 1-line description (why empty)
3. Primary action (what to do next)
4. Optional secondary (alternative path)

Example (empty inbox):
> 📥 You're all caught up.
> No messages right now. New invites land here.
> [Invite someone]

## Onboarding microcopy

- **First impression** — welcome them, set expectation: "Let's get you set up. ~3 minutes."
- **Progress visibility** — "Step 2 of 4"
- **Skip path** — always offer "Skip for now"
- **Completion celebration** — light, not over-the-top
- **Don't over-explain** — if a field is obvious, no helper text

## Form labels + helpers

- Labels above the field (not floating, accessibility win)
- Optional fields marked optional. Required is default expectation.
- Helper text BELOW field, before validation: "We'll never email this."
- Error replaces helper text in red, with clear fix

Anti: putting hint inside placeholder (disappears when typing)

## Tone for delicate moments

| Moment | Tone |
|---|---|
| Account deletion | Calm, confirms intent, mentions what's lost |
| Payment failure | Concrete, not anxious — "Card was declined. Check details or try another card." |
| Subscription cancel | No guilt-trip; offer pause; thank for trying |
| Privacy / data export | Plain language, not legalese |
| Unavailable feature | Honest reason + ETA if known |

## Consistency rules

Pick one. Stick with it.

- "Sign in" OR "Log in" — never both in same product
- "Email" OR "Email address" — pick one
- "Cancel" OR "Discard" for losing changes
- Title Case OR Sentence case for buttons (sentence case modern)
- Em dash OR en dash for ranges

Maintain a glossary doc.

## Localization-friendly copy

- Avoid puns / idioms / pop refs (don't translate)
- Leave room for German (30-50% longer than English)
- Don't concatenate: "You have {n} {item}{s}" breaks for many languages → use ICU MessageFormat
- Date/number formats locale-specific (`Intl` APIs in JS)
- Avoid culturally-specific imagery in word choice

## Reading-level check

Aim for grade 6-8 reading level for consumer products. Tools: Hemingway Editor, readable.com.

Long sentences, jargon, passive voice → cut.

| Before | After |
|---|---|
| "Your account has been successfully deactivated." | "Your account is deactivated." |
| "Please be advised that..." | (delete) |
| "In order to..." | "To..." |
| "Utilize" | "Use" |
| "Approximately" | "About" |

## Anti-patterns

- "Are you sure?" 5x (warn once, well)
- Apologizing for things that aren't problems
- Brand voice taking over functional copy ("Whoops, looks like our hamsters are taking a nap!")
- Empty states with no CTA
- Disabled buttons without explanation
- "Click here" (links should be the action: "Read the docs")
- Silently failing (user doesn't know it didn't work)

## Integration

- `nc-user-research` — copy uses words real users say
- `nc-accessibility-deep` — copy supports screen readers, clear language
- `nc-frontend-design` — copy reviewed alongside design
- `nc-copywriting` — marketing copy, more emotional, related skillset
- `nc-mirror` — agent should mirror user's vocabulary
- `nc-persona` — voice/tone analogous to agent persona work
