---
description: Conversion copywriting formulas, headline templates, email copy patterns, landing page structures, CTA optimization, and writing style extraction. Activate for writing high-converting copy, crafting headlines, email campaigns, landing pages, or applying custom writing styles from assets/writing-styles/ directory.
auto_execution_mode: 1
---

# Copywriting

Formulas, templates, patterns, and writing styles for high-converting copy.

## When to Use

- Writing headlines/subject lines, landing page copy, email campaigns
- Social posts, product descriptions, CTA optimization, A/B variations
- Applying custom writing styles from user documents

## Writing Styles

Load: `references/*.md` | Default catalog: `assets/writing-styles/default.md` (50 styles)

**Extract styles from multi-format files:**
```bash
python .claude/skills/copywriting/scripts/extract-writing-styles.py --list        # List files
python .claude/skills/copywriting/scripts/extract-writing-styles.py --style <name> # Extract style
```

**Formats:** `.md` `.txt` `.pdf` `.docx` `.xlsx` `.pptx` `.jpg` `.png` `.mp4` (docs/media need `GEMINI_API_KEY`)

## Copy Formulas

Load: `nc-copywriting/references/copy-formulas.md`

| Formula | Structure | Best For |
|---------|-----------|----------|
| AIDA | Attention → Interest → Desire → Action | Landing pages, ads |
| PAS | Problem → Agitate → Solution | Email, sales pages |
| BAB | Before → After → Bridge | Testimonials, case studies |
| 4Ps | Promise → Picture → Proof → Push | Long-form sales |
| 4Us | Urgent + Unique + Useful + Ultra-specific | Headlines |
| FAB | Feature → Advantage → Benefit | Product descriptions |

## Headlines

Load: `nc-copywriting/references/headline-templates.md`

Patterns: "How to [X] without [Y]" • "[Number] ways to [benefit]" • "The secret to [outcome]" • "Why [belief] is wrong"

## Email Copy

Load: `nc-copywriting/references/email-copy.md`

Subject lines: Curiosity gap • Benefit-driven • Question • Urgency

## Landing Pages & CTAs

Load: `nc-copywriting/references/landing-page-copy.md` | `nc-copywriting/references/cta-patterns.md`

Hero: Headline (promise) → Subheadline (how) → CTA (action) → Social proof
CTAs: "Start [verb]ing" • "Get [benefit]" • "Yes, I want [benefit]"

## Workflows

| Workflow | Purpose | Use When |
|----------|---------|----------|
| `nc-copywriting/references/workflow-cro.md` | CRO optimization (25 principles) + plan creation workflow | Conversion optimization & CRO plan requests |
| `nc-copywriting/references/workflow-enhance.md` | Copy enhancement | Improving existing copy |
| `nc-copywriting/references/workflow-fast.md` | Quick copy generation | Simple, time-sensitive requests |
| `nc-copywriting/references/workflow-good.md` | Quality copy with research | High-stakes content |

## References

| File | Purpose |
|------|---------|
| `nc-copywriting/references/writing-styles.md` | 30 writing styles quick reference |
| `nc-copywriting/references/copy-formulas.md` | AIDA, PAS, BAB, 4Ps, FAB formulas |
| `nc-copywriting/references/headline-templates.md` | Headline patterns & templates |
| `nc-copywriting/references/email-copy.md` | Email copy patterns |
| `nc-copywriting/references/landing-page-copy.md` | Landing page structure |
| `nc-copywriting/references/cta-patterns.md` | CTA optimization |
| `nc-copywriting/references/power-words.md` | Power words by emotion |
| `nc-copywriting/references/social-media-copy.md` | Platform-specific copy |
| `scripts/extract-writing-styles.py` | Extract styles from multi-format files |
| `templates/copy-brief.md` | Creative brief template |

## Agent Integration

**Primary:** fullstack-developer | **Related:** brand-guidelines, content-marketing, email-marketing

## Best Practices

1. Lead with benefit, not feature | 2. One CTA per piece
3. Specificity > vague claims | 4. Read aloud—if awkward, rewrite
5. Test headlines first | 6. Match copy to awareness level

## Outputs

**IMPORTANT:** follow the `nc-project-organization` workflow to organize the outputs.
