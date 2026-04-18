---
description: Workflow for Claude Design — Anthropic's prototype/slide/mockup generator that reads your codebase + design system. Use when preparing a repo for Claude Design ingestion, exporting outputs to production code, or deciding when Claude Design fits vs traditional design tools.
---

# Claude Design Skill

Anthropic launched Claude Design (April 2026) — generates prototypes, slides, one-pagers, pitch decks from prompts. Reads your codebase + design system to stay on-brand.

## What it is + isn't

| Is | Isn't |
|---|---|
| Idea → visual artifact in minutes | Replacement for designers on complex products |
| Reads your code/design tokens for consistency | Pixel-perfect production code generator |
| Export to PDF/PPTX/URL/Canva | Direct commit-to-prod |
| Prototyping speedrun | Branding strategy or research |
| Internal docs / pitch decks | Marketing creative direction |

Default mental model: **fast first draft**. Polish in real tool (Canva for slides, Figma for design, codebase for production UI).

## Plan availability

- Pro / Max / Team / Enterprise (research preview as of v3.0.1)
- Powered by Claude Opus 4.7
- Free tier: not available

If team isn't on a paid plan: skip this skill, use prompt + screenshot in ChatGPT/Claude as fallback.

## When to reach for Claude Design

| Task | Use Claude Design? |
|---|---|
| Pitch deck for fundraise | YES — fastest path |
| Internal "what if we built X" mockup | YES — explore cheap |
| Customer-facing marketing site visual | MAYBE — good first draft, polish in Figma |
| Exact production component | NO — use real component library |
| Brand identity / logo | NO — needs human creative |
| Quick wireframe to align team | YES |
| One-pager for sales | YES — export to PPTX |

## Codebase preparation

Before pointing Claude Design at your repo, surface:

```
your-project/
├── design-system/                    # ← THIS folder is the gold
│   ├── tokens.json                   # colors, spacing, typography as JSON
│   ├── components.md                 # written description of components
│   └── brand-guidelines.md           # voice, do/don't, color usage
├── src/styles/
│   ├── globals.css                   # CSS variables for tokens
│   └── theme.ts                      # JS/TS theme exports
├── tailwind.config.ts                # if Tailwind, this is canonical
├── public/brand/                     # logo SVGs, hero images
└── README.md                         # project context
```

Files Claude Design reads BEST:
- CSS custom properties (`--color-primary: #...`)
- Tailwind config (full color palette, spacing scale)
- `tokens.json` or design-tokens-w3c format
- README with brand voice + use case

Files Claude Design DOESN'T parse well:
- Figma files directly (unless exported to JSON)
- Adobe XD / Sketch files
- Compiled CSS (use source instead)
- Inline styles only (no system to read)

## Setup checklist (one-time per repo)

- [ ] Subscribe Pro/Max/Team plan
- [ ] Open claude.ai → Claude Design tab
- [ ] Connect GitHub: select repo
- [ ] Point at design files in repo settings:
  - CSS: `src/styles/globals.css` or equivalent
  - Tokens: `design-system/tokens.json` if exists
  - Tailwind: `tailwind.config.ts`
  - Components: `src/components/ui/` (skim, not exhaustive)
- [ ] Test prompt: "Generate landing page hero for [your product]"
- [ ] Verify output uses YOUR colors / fonts / spacing — if not, refine token files
- [ ] Save the project for repeated use

## Prompting patterns

### Generate prototype

```
Build a landing page hero for our VIP renewal product:
- Headline: "Renew your VIP, save 20%"
- 1 CTA button (primary)
- Hero image placeholder
- 3 feature bullets
Use our design system (colors, fonts, spacing).
Output as web page (URL).
```

### Generate slide deck

```
3-slide pitch:
1. Problem: <1 sentence>
2. Solution: <1 sentence + 1 visual>
3. Traction: <1 stat + 1 chart>
Use brand colors. Export PPTX.
```

### Generate one-pager

```
1-page sales sheet for hospitality SaaS:
- Top: logo + tagline
- Middle: 3 benefits with icons
- Bottom: customer quote + CTA
Use brand voice (friendly, professional).
PDF export.
```

## Export workflow

| Output | Best for |
|---|---|
| URL (web page) | Internal review, share link, click-test |
| PDF | Sales sheet, archive, print |
| PPTX | Sales deck, customer-facing presentation |
| Canva link | When you need to edit further with team |

Rule: Claude Design output is a DRAFT. If it's customer-facing, send to designer for polish before ship.

## Review checklist (don't ship raw)

Before any external use of Claude Design output:

- [ ] Brand voice matches (read aloud, do you sound like your brand?)
- [ ] No invented features (Claude Design may hallucinate features into mockup)
- [ ] No invented stats (verify every number)
- [ ] Accessible colors (contrast ratios — see `nc-accessibility-deep`)
- [ ] No copyrighted imagery (Claude Design can pick stock-like images — verify license)
- [ ] Logo is YOUR logo (sometimes generic gets inserted)
- [ ] Domain shown (in URL/footer) is yours
- [ ] No broken layouts at mobile width

## Codebase → Claude Design feedback loop

Improving Claude Design output = improving your design system docs:

1. Generate something with Claude Design
2. Output looks "off" (wrong shade, wrong spacing)
3. Fix the SOURCE: update `tokens.json` / `globals.css` / Tailwind config
4. Regenerate — should improve
5. Side benefit: real designers + dev team get better source of truth too

This is the same dynamic as RAG: improve the corpus, improve the answer.

## When NOT to use Claude Design

- Need exact pixel match to spec → use Figma
- Need designer-level visual hierarchy → use designer
- Need legally-cleared assets → use licensed library, not AI generation
- Need accessibility audit baked in → still need human + tools
- Building actual product UI → write components in code, not slides

## Cost / plan implications

- Each generation costs the underlying Claude Opus 4.7 inference
- Heavy usage during a deck-building session can burn credits fast
- For Team/Enterprise plans: track usage per teammate
- Consider: prompt clearly + iterate sparingly vs generate-50-variants

## Anti-patterns

- Treating Claude Design output as "the design" (it's a draft)
- Pointing it at messy / inconsistent CSS and complaining output is messy
- Generating without telling Claude Design which design system to use
- Ignoring the URL output (great for click-test before exporting heavyweight PPTX)
- Sharing a Claude Design URL with customers without polish (looks AI-y)
- Cancelling Figma subscription based on Claude Design (different tools, different jobs)

## Integration

- `nc-frontend-design` — for production UI code (Claude Design doesn't replace this)
- `nc-ui-styling` — Tailwind + shadcn config that Claude Design reads
- `nc-ux-writing` — copy in mockups should match real product voice
- `nc-accessibility-deep` — review Claude Design output for a11y
- `nc-user-research` — research drives WHAT to mockup; Claude Design generates faster
- `nc-claude-api` — programmatic Claude Opus 4.7 access (Claude Design is the UI)
- `nc-company-os` — Designer role uses this; PM uses for pitch decks
