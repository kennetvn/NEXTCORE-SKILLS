---
description: Plan + run user research without burning credibility. Use when planning user interviews, designing surveys, doing usability tests, deciding sample size, or interpreting qualitative findings. Default to lightweight, frequent research over big formal studies.
auto_execution_mode: 1
---

# User Research Skill

Most product mistakes are research mistakes. Cheap, frequent, real-user feedback beats elaborate one-off studies.

## Pick the right method

| Question | Method |
|---|---|
| "What problems do users have?" | 1:1 interviews (5-8 users) |
| "Which solution do they prefer?" | Prototype usability test (5 users) |
| "How big is this segment?" | Survey (n=100+) |
| "Why is this metric dropping?" | Funnel analysis + 5 user interviews |
| "Will they pay for it?" | Smoke test landing page + waitlist |
| "What's their workflow?" | Diary study or shadowing |
| "Are we accessible?" | Usability test with disabled users |

Mismatch ruins research. Don't survey when you need depth; don't interview to size a market.

## Interview structure (45-60 min)

```
0-5min:  Warm-up. "Tell me about yourself / your role."
5-15min: Context. "Walk me through the last time you did X." (story, not opinion)
15-40min: Deep dive. Follow up on pain, workarounds, surprises.
40-50min: Probe (only after they've shown the problem). Show prototype if relevant.
50-55min: Snowball. "Who else struggles with this?"
55-60min: Wrap. "What questions did I miss?"
```

## Question rules (golden rules)

- Past behavior > future intent. "What did you do?" not "Would you use?"
- Open > closed. "How did that feel?" not "Was that frustrating?"
- Specific > abstract. "Last Tuesday's meeting" not "in general"
- Listen 80% / talk 20%. Silence is your friend.
- Don't pitch. They'll be polite. Shows you're insecure about the idea.

Bad questions:
- "Do you like X?" (acquiescence bias)
- "Would you pay $20/month?" (intent ≠ behavior)
- "Wouldn't it be great if...?" (leading)
- Multiple questions in one breath

Good questions:
- "Tell me about the last time you tried to solve X."
- "What did you do before / after?"
- "Show me." (let them demo on their actual machine)
- "What was annoying about that?"
- "Who else is involved?"

## Sample size

| Method | Sample | Why |
|---|---|---|
| Generative interviews | 5-8 | Diminishing returns past 8 (Nielsen) |
| Usability test | 5 per persona | Catches ~85% of issues |
| Quant survey | 100+ for ±10% margin, 400+ for ±5% | Statistical power |
| A/B test | 1000+ per variant typical | Effect size dependent |

For pre-launch validation: 5 user interviews is enough to invalidate, not enough to validate. Negatives are reliable; "yes, I'd buy" needs more proof.

## Recruiting

- Existing users (waitlist, support contacts) — fastest, biased toward existing fit
- User Interviews / Respondent.io / Userlytics — pay for screened panels ($30-100/session)
- Twitter/LinkedIn cold outreach — slow, biased to your network
- Friends-of-friends — convenience sample, take findings with salt

Always screen with 3-5 questions. "Have you done X in the past 30 days?" filters fakers.

## Synthesis (after interviews)

Don't transcribe everything. Don't theme-and-grouping for 3 days. Use this process:

1. After each interview: write 5-10 bullet "what I learned" while fresh
2. After all interviews: cluster bullets into 3-5 themes
3. For each theme: write 1 sentence finding + 2 supporting quotes
4. List actions: what changes, what to investigate further, what to drop

Output: 1 page max. Long reports get unread.

## Usability test protocol

```
1. Set context: "I'm testing the design, not you. Speak your thoughts aloud."
2. Give a TASK, not an instruction. "Book a 2-night stay" not "Click Book Now."
3. Stay quiet during attempt. Resist the urge to help.
4. After: ask "what did you expect to happen at <step>?"
5. Severity-rank issues: blocker (can't complete) / friction (slow) / nit
```

## Survey design

- Lead with easy questions (commit them to finishing)
- Demographics LAST (or skip if not needed)
- 1 idea per question
- Likert (1-5) > binary for opinion; 5-point > 7-point (less analysis paralysis)
- Open-ended sparingly (max 2-3 in survey, can't synthesize 1000 free responses easily)
- Pilot with 5 people before mass-sending — typos and ambiguous wording always exist
- Estimate completion time honestly; tell respondents

## Interpretation traps

- **Confirmation bias**: hearing what supports your idea. Counter: actively look for disconfirming.
- **Loud minority**: 1 user with vivid story ≠ representative. Counter: count instances.
- **Recency**: last interview overweighted. Counter: synthesize with all on table.
- **Solutioning during research**: user said "I want X feature" — dig WHY first, X may not be the fix.
- **Polite participants**: many will say nice things. Reading body language / hesitation matters.

## Anti-patterns

- "Let's interview to validate the feature" (research is for learning, not validating)
- Showing prototype before understanding their problem
- Single interview → product decision
- Surveys with "How likely on a scale of 1-10..." NPS-style overuse
- Recruiting only your friends (will love everything you do)
- Note-taking during interview without recording (you'll miss things)
- Long reports that no one reads → 1-page findings + 1 video clip per insight

## Integration

- `nc-ux-writing` — research informs language users actually use
- `nc-accessibility-deep` — usability tests with disabled users
- `nc-company-os` — research is PM + Designer collaboration
- `nc-frontend-design` — designs informed by what you heard
- `nc-ai-evaluation` — eval datasets sourced from real user queries
- `nc-brainstorm` — bring research findings into ideation
