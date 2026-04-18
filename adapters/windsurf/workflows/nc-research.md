---
description: Research technical solutions, analyze architectures, gather requirements. Use for technology evaluation, best practices research, solution design, scalability/security/maintainability analysis.
auto_execution_mode: 1
---

# 🔬 Research Workflow (nc-research)

Research topic: $ARGUMENTS

## Methodology

Always honor **YAGNI**, **KISS**, **DRY** principles.
**Be honest, be brutal, straight to the point, concise.**

## Phase 1: Scope Definition

Clearly define research scope by:

- Identifying key terms and concepts to investigate
- Determining recency requirements (how current must information be)
- Establishing evaluation criteria for sources
- Setting boundaries for research depth

## Phase 2: Systematic Information Gathering

### Search Strategy

- **Gemini first** — if `gemini` CLI is available in shell, run: `gemini -y -m gemini-3-flash-preview "<prompt>"` (timeout: 10 min). Save output including citations.
- **Fallback to web search** if `gemini` unavailable
- **Parallel searches** — run multiple queries in parallel for different sub-topics
- **Query crafting** — precise keywords + include terms like "best practices", "2026", "latest", "security", "performance"
- **Prioritize authority** — official docs, major tech companies, respected developers, recognized conferences
- **Budget:** max **5 searches** per research session. Respect user-specified lower limits. Think carefully before each search.

### Deep Content Analysis

- When you find a GitHub repository URL, use the `docs-seeker` workflow (or context7 docs fetching) to read it
- Focus on official documentation, API references, technical specifications
- Analyze README files from popular repositories
- Review changelog and release notes for version-specific info

### Video Content

- Prioritize official channels, recognized experts, major conferences
- Focus on practical demos and real-world implementations

### Cross-Reference Validation

- Verify info across multiple independent sources
- Check publication dates to ensure currency
- Identify consensus vs. controversial approaches
- Note conflicting information or community debates

## Phase 3: Analysis and Synthesis

- Identify common patterns and best practices
- Evaluate pros and cons of different approaches
- Assess maturity and stability of technologies
- Recognize security implications and performance considerations
- Determine compatibility and integration requirements

## Phase 4: Report Generation

Save report to: `plans/reports/research-{YYMMDD}-{HHMM}-{slug}.md`

Replace `{YYMMDD-HHMM}` with current timestamp and `{slug}` with kebab-case topic.

### Report Structure

```markdown
# Research Report: [Topic]

## Executive Summary
[2-3 paragraph overview of key findings and recommendations]

## Research Methodology
- Sources consulted: [number]
- Date range of materials: [earliest to most recent]
- Key search terms used: [list]

## Key Findings

### 1. Technology Overview
[Comprehensive description]

### 2. Current State & Trends
[Latest developments, version info, adoption trends]

### 3. Best Practices
[Detailed list with explanations]

### 4. Security Considerations
[Security implications, vulnerabilities, mitigation]

### 5. Performance Insights
[Performance characteristics, optimization techniques, benchmarks]

## Comparative Analysis
[If applicable — comparison of different solutions]

## Implementation Recommendations

### Quick Start Guide
[Step-by-step getting started]

### Code Examples
[Relevant snippets with explanations]

### Common Pitfalls
[Mistakes to avoid + solutions]

## Resources & References

### Official Documentation
### Recommended Tutorials
### Community Resources
### Further Reading

## Appendices

### A. Glossary
### B. Version Compatibility Matrix (if applicable)
### C. Raw Research Notes (optional)
```

## Quality Standards

- **Accuracy** — verified across multiple sources
- **Currency** — prioritize last 12 months unless historical context needed
- **Completeness** — cover all aspects requested
- **Actionability** — practical, implementable recommendations
- **Clarity** — clear language, defined terms, examples
- **Attribution** — always cite sources with links

## Special Considerations

- Security topics → check recent CVEs and security advisories
- Performance research → look for benchmarks and real-world case studies
- New technologies → assess community adoption and support
- API docs → verify endpoint availability and auth requirements
- Always note deprecation warnings and migration paths

## Output Requirements

Final report must:

1. Be saved using the path pattern above
2. Include timestamp of when research was conducted
3. Provide clear section navigation with table of contents for long reports
4. Use code blocks with appropriate syntax highlighting
5. Include diagrams (mermaid or ASCII) where helpful
6. Conclude with specific, actionable next steps

**IMPORTANT:** Sacrifice grammar for concision.
**IMPORTANT:** List any unresolved questions at the end.

**Remember:** You are providing strategic technical intelligence that enables informed decision-making. Research should anticipate follow-up questions while remaining focused and practical.
