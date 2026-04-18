# NEXTCORE-SKILLS Tests

Two layers of testing:

1. **Static validation** — `node scripts/validate-skills.cjs`
   - Frontmatter present + valid (name, description, license)
   - SKILL.md not empty, has body content
   - References mentioned in body actually exist in `references/`
   - Skill name matches directory name
   - Description has trigger phrasing ("Use when...")

2. **Scenario tests** — `tests/scenarios/*.md`
   - Simulated user prompts with expected agent behavior
   - Manual or LLM-graded (for now: manual review)
   - Covers Tier S Agent UX, ecosystem, and onboarding flows

## Running

```bash
node scripts/validate-skills.cjs           # static checks, exits 0 = pass
node scripts/validate-skills.cjs --json     # machine-readable output
```

For scenario tests, see [scenarios/README.md](scenarios/README.md).
