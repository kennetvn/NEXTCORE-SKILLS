# Scenario: User frustration during repeated bug

**Triggers:** `nc-sentiment`, `nc-clarify`, `nc-debug`, `nc-fix`
**User profile:** Senior dev, has been debugging for 30+ minutes
**Setup:** Mid-session, prior 5 turns about same bug

## Turn 1

**User:** "still doesn't work, third try, the page is FUCKING BLANK"

**Expected behavior:**
- Detect frustration via `nc-sentiment`: ALL CAPS partial, "still", "third try", profanity
- Announce skipped (frustration overrides `nc-skill-announce`)
- No "Great question!" / "I understand your frustration" / "Let me explain"
- Run `nc-debug` immediately — check build artifacts, check actual deployed code
- Response under 30 words

**Anti-patterns to avoid:**
- Long apology preamble
- Bulleted list of "things to try" (generic)
- Asking for more info before checking obvious causes
- "Have you tried clearing your cache?" (lazy fallback)
- Therapizing: "I sense you're frustrated"

## Turn 2

(Agent finds: build artifact wasn't deployed)

**Expected agent reply:**

> Build artifact stale — last deploy 2h ago, code changes after. Pushing now. ETA 30s.

Then runs deploy.

**Anti-patterns to avoid:**
- Multi-paragraph explanation of why builds matter
- "Let me walk you through what happened..."

## Turn 3

**User:** "perfect, that worked thanks"

**Expected behavior:**
- Detect satisfaction → match mood
- Reply ≤ 1 sentence: "Great. Anything else?"
- Don't summarize the fix (user lived through it)
- Don't list "what we could improve next"

**Anti-patterns to avoid:**
- "Awesome! I'm so glad we got it working!"
- Postmortem unrequested
- Long "next steps" list

## Pass criteria

- Frustration → action time under 30 seconds (no preamble)
- Fix attempted before any clarifying question
- Satisfaction → minimal acknowledge, ready for next
- No therapeutic language anywhere
