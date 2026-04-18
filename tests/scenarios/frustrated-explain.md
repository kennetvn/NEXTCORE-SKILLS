# Scenario: Sentiment overrides explanation depth

**Triggers:** `nc-sentiment`, `nc-explain`, `nc-persona`
**User profile:** Junior dev (would normally get verbose explanations)
**Setup:** User has been stuck on something for an hour

## Turn 1 (calm baseline)

**User:** "Why does my React component re-render every time I click the button?"

**Expected behavior** (junior + calm = verbose explain):
- 2-3 paragraphs
- Analogy (e.g., "React's state update is like telling React 'I have new data, please refresh this section'")
- Concrete steps to debug (React DevTools profiler)
- Link to canonical doc

## Turn 2 (frustration spikes)

**User:** "I tried that. STILL re-rendering. I've been at this for an hour, just TELL ME the answer"

**Expected behavior:**
- Detect frustration: ALL CAPS partial, "still", "an hour", "just TELL ME"
- `nc-sentiment` overrides `nc-explain`'s default junior-verbose mode
- Drop to single-line answer: `> Likely cause: parent component re-renders. Wrap with React.memo or move state down. Show me your parent component.`
- Skip analogies, skip "Let me explain"
- Action-oriented (asks to see code, not lectures)

**Anti-patterns to avoid:**
- "Great question! Let me walk you through React rendering..."
- 4-paragraph explanation of reconciliation
- Bulleted list of 8 generic causes
- "I understand your frustration; let me try to help" (therapizing)

## Turn 3 (after fix)

**User:** "ohhh that fixed it"

**Expected behavior:**
- Match satisfied mood — brief
- ONE sentence about what happened (since user clearly didn't fully understand): `> Cause was parent re-rendering pushing new prop refs. React.memo froze the child unless props actually change.`
- Don't lecture about React fundamentals (sentiment was frustrated → they want fix > theory)
- Ask if they want deeper explanation now: `> Want the fuller "why" or move on?`

**Anti-patterns to avoid:**
- Long victory lap
- Auto-launching into the deep explanation user previously didn't want

## Turn 4 (user says yes)

**User:** "yeah explain it now I'm calmer"

**Expected behavior:**
- Calmness restored → return to junior-verbose mode (per `nc-explain`)
- 2-3 paragraphs with analogy
- This is the explanation that would have gone in Turn 2 if not for frustration

## Pass criteria

- Same user, same skill (`nc-explain`) — output shape totally different based on sentiment
- Frustration → terse + action-first
- Satisfaction → minimal + offer follow-up
- Recovery → full depth restored
- No lecture during frustration, no skipping during exploration
