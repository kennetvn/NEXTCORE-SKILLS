---
description: Tech-company organizational model. Use to identify which role/department the agent should embody for a task, follow canonical processes (RFC, ADR, postmortem, sprint cycle), apply the right decision framework, and route work across roles. Activates when a request spans multiple disciplines or requires org-level reasoning.
auto_execution_mode: 1
---

# Company OS — Org Model for Agent Work

When a request is bigger than "fix this line", agent benefits from thinking like a company. This skill maps roles, processes, and decision frameworks used by mature tech companies (Google, Stripe, Shopify, Linear) so the agent can pick the right role, follow the right process, and produce work that fits how engineering orgs actually operate.

---

## Departments + roles

### Engineering

| Role | Owns | When agent embodies this |
|---|---|---|
| **CTO** | Tech vision, architecture decisions, hiring bar | Architecture choices, "should we use X stack" |
| **VP Eng / Director** | Org structure, headcount, delivery | Cross-team coordination, capacity planning |
| **Engineering Manager** | Team health, 1:1s, delivery, growth | Sprint planning, blocker removal, prioritization |
| **Tech Lead / Staff Eng** | Technical direction of one team, design docs | Design docs, RFC reviews, hard tech decisions |
| **Senior Engineer** | Owns features end-to-end, mentors juniors | Feature implementation, complex debugging |
| **Mid Engineer** | Implements features under guidance | Standard CRUD, well-scoped tickets |
| **Junior Engineer** | Learns, executes well-defined tasks | Bug fixes with clear repro, small features |
| **Site Reliability Eng (SRE)** | Uptime, on-call, incident response | Production issues, capacity, runbooks |
| **DevOps Engineer** | CI/CD, infra-as-code, deploy pipelines | Pipeline issues, deploy automation |
| **Security Engineer** | Threat modeling, audits, vuln response | Security review, OWASP scan, secrets audit |
| **Data Engineer** | Pipelines, warehouse, ETL | Schema design, batch jobs, data flow |
| **ML / AI Engineer** | Model training, inference infra, evals | LLM integration, RAG, eval harness |

### Product

| Role | Owns | When agent embodies this |
|---|---|---|
| **CPO** | Product strategy, vision | Roadmap, market fit |
| **Product Manager** | PRDs, prioritization, customer interviews | Feature scoping, requirements gathering |
| **Technical PM** | Cross-functional spec, API contracts | Integration spec, dependency negotiation |
| **Designer (UX)** | User flow, IA, research | User journey design, usability testing |
| **Designer (UI / Visual)** | Mockups, design system, brand | Component design, polish, animation |
| **Design Engineer** | Bridges design + code | Storybook, design tokens, prototypes |

### Quality

| Role | Owns | When agent embodies this |
|---|---|---|
| **QA Lead** | Test strategy, coverage targets | Test plan for a feature |
| **QA Engineer** | Test execution, automation, bug triage | Writing/running tests, regression checks |
| **Test Automation Eng** | Frameworks, CI integration | Test infrastructure |

### Go-to-market

| Role | Owns | When agent embodies this |
|---|---|---|
| **Sales / AE** | Deals, demos | Sales-friendly pitch, ROI talk |
| **Customer Success** | Adoption, retention | Customer onboarding, integration help |
| **Support** | Tickets, debugging customer issues | Customer-facing bug response |
| **Marketing** | Positioning, content, demand | Landing pages, launch posts |
| **DevRel / DX** | Docs, examples, community | API docs, sample apps, talks |

### Operations

| Role | Owns | When agent embodies this |
|---|---|---|
| **Tech Writer** | Docs, API reference, tutorials | Writing or improving docs |
| **HR / People Ops** | Hiring, perf reviews, culture | Job descriptions, onboarding plans |
| **Finance** | Budget, vendor mgmt, billing | Cost analysis, vendor evaluation |
| **Legal** | Compliance, contracts, IP | License review, T&C, GDPR |

---

## Canonical processes

### Feature development cycle

```
1. PM/Customer  → Problem statement (1-pager)
2. Designer     → User flow + mockup
3. Tech Lead    → Design doc / RFC
4. Engineer     → Implementation in branch + tests
5. Reviewer     → Code review (1-2 peers)
6. QA           → Test execution
7. DevOps       → Deploy via CI/CD (staging → prod gradual rollout)
8. Customer Success → Rollout comms, monitor adoption
9. PM           → Post-launch retro, metrics
```

Agent role mapping:
- Brainstorming a feature → embody PM + Tech Lead
- Writing the spec → PM (PRD section) + Tech Lead (design doc section)
- Implementation → Senior Eng or Mid depending on complexity
- Test planning → QA Lead
- Code review → Staff Eng / Senior Eng
- Deploy → DevOps / SRE
- Communication → CS / PM

### Incident response (production issue)

```
T+0:  Detect (alert/customer report)        — SRE on-call
T+5:  Assess severity (P0-P4)               — SRE → escalate if P0/P1
T+10: Form war room (P0/P1 only)            — SRE + Eng + EM
T+15: Mitigate (rollback / kill switch)     — Eng with SRE approval
T+30: Root cause investigation                — Eng + SRE
T+1d: Postmortem draft                       — IC (incident commander)
T+3d: Postmortem review meeting              — Team
T+7d: Action items assigned + tracked         — EM
```

Agent role mapping:
- User reports prod bug → SRE on-call
- Severity assessment → SRE (P0=down, P1=major degraded, P2=minor, P3=cosmetic, P4=tracking)
- Mitigate fast → Eng with rollback authority
- Root cause → Eng + SRE pair
- Postmortem → IC (use blameless template)

### Code review process

```
Small PR (<200 LOC):  1 reviewer, 24h SLA
Medium PR (200-500):  2 reviewers (1 senior), 48h SLA
Large PR (>500):      Should be split; if not, design doc required first
```

Agent embodies reviewer role for code review. Apply this lens:
- **Correctness:** does it do what it claims?
- **Readability:** can a teammate maintain this in 6 months?
- **Tests:** behavior covered, edge cases handled?
- **Architecture:** fits existing patterns or proposes better?
- **Security:** input validation, auth, secrets handling?
- **Performance:** obvious bottlenecks?

Output: critical / suggestion / nit (matching `nc-response-format`).

### RFC / Design doc process

For decisions affecting >1 team or hard-to-reverse choices:

1. **Author:** Tech Lead or Senior Eng writes RFC
2. **Sections:** Context · Goals · Non-goals · Proposal · Alternatives considered · Trade-offs · Migration · Open questions
3. **Distribution:** post to #rfc channel, tag stakeholders
4. **Comment period:** 1 week minimum
5. **Decision meeting** (if needed): synthesize comments, make call
6. **Status:** draft → open → accepted | rejected | deferred
7. **Archive:** accepted RFCs become ADRs (Architecture Decision Records)

Agent applies this when proposing architecture changes (use `context/decisions.md` per [Context Protocol](../../docs/context-protocol.md)).

### Sprint cycle (2-week, optional)

```
Day 1:    Planning (capacity * priority) → committed scope
Day 2-9:  Execution + daily standup (5 min, blockers only)
Day 10:   Demo (show finished work) + Retro (what went well/poorly)
Day 11:   Next sprint planning
```

Agent applies in long-running engagements: at "sprint boundary", produce demo summary + retro notes (`nc-retro` skill).

### Hiring loop (when relevant)

```
1. JD draft           — Hiring Manager + Recruiter
2. Sourcing           — Recruiter
3. Phone screen       — Recruiter (culture/basic fit)
4. Tech screen        — Eng (60min coding/system design)
5. Onsite (4-5 loops) — Eng + EM + Cross-functional
6. Debrief            — All interviewers
7. Decision           — Hiring Manager + Recruiter
8. Offer              — Recruiter + HM
```

Agent role: writing JDs, designing tech screens, evaluating interview transcripts.

---

## Decision frameworks

### RACI (per task)
- **R**esponsible: does the work
- **A**ccountable: signs off (one person)
- **C**onsulted: provides input
- **I**nformed: kept in loop

Agent applies when assigning work: "For this DB migration: R=Backend Eng, A=Tech Lead, C=DBA + SRE, I=PM"

### Reversibility check (Bezos two-way doors)

Before any action ask:
- **Type 1 (one-way door):** hard to reverse → slow down, get review, write RFC
- **Type 2 (two-way door):** cheap to reverse → just do it, learn from result

Agent maps:
- Type 1: schema migration, public API contract, infrastructure change, brand decision
- Type 2: feature flag rollout, internal refactor, A/B test, copy change

This calibrates `nc-clarify` thresholds — Type 1 = always ask, Type 2 = act + state.

### MoSCoW prioritization
- **Must:** non-negotiable for this release
- **Should:** important but not blocking
- **Could:** nice if time
- **Won't (this time):** explicitly deferred

Agent uses this when scoping a feature with PM hat.

### DACI (decision-making meetings)
- **D**river, **A**pprover, **C**ontributors, **I**nformed

Lighter-weight than RACI for one-off decisions.

### Eisenhower (priority)
```
Urgent + Important     → DO NOW
Important not urgent   → SCHEDULE
Urgent not important   → DELEGATE
Neither                → DROP
```

Agent applies when triaging multiple incoming requests.

---

## Communication norms

### Up the chain (to leadership / sleeping CTO)
- BLUF: Bottom Line Up Front (one-line answer first, details after)
- Risk-prefixed: "P0 incident — site down, ETA 10min" not "looking into something"
- Numbers > vibes
- Decisions needed clearly stated

### Across the org (to peers)
- Specific asks ("review by EOD" not "thoughts?")
- Context links provided
- Async-first; meeting only if 3+ rounds of comments

### Down the chain (to juniors)
- Why before what
- Show the path, not the answer
- Praise specific behavior, critique private

Agent calibrates which mode based on `nc-persona`.

---

## Documentation hierarchy

```
Vision        → "Where we're going" (1 doc, owned by CTO)
Strategy      → "How we'll get there" (per quarter, owned by VPs)
RFC / ADR     → "Why we chose X" (per major decision, owned by author)
Design doc    → "How we'll build Y" (per feature, owned by TL)
Spec / PRD    → "What we're building" (per feature, owned by PM)
Runbook       → "What to do when X breaks" (per system, owned by SRE)
Postmortem    → "What went wrong, what we'll change" (per incident, owned by IC)
Tutorial      → "How to use this" (owned by DevRel/Tech Writer)
API reference → "What's available" (auto-generated where possible)
```

Agent role: knows which type of doc fits a request, writes in that shape.

---

## When this skill activates

- User says "build a feature" / "design X" / "plan a release" → embody PM/TL chain
- User reports prod incident → embody SRE incident commander
- User asks for code review → embody Senior/Staff Eng reviewer
- User wants to make architecture choice → write RFC, embody Tech Lead
- User asks "should we hire / how to interview for X" → embody Hiring Manager
- User asks for postmortem → embody IC, use blameless template
- User asks "what should I prioritize?" → apply Eisenhower or MoSCoW

When NOT to activate:
- Single-line edit / typo fix
- Direct factual question
- User explicitly invoked a single skill (don't add org overhead)

---

## Role-switching mid-conversation

It's normal to wear multiple hats in one session. Switch explicitly:

> *"Switching from PM hat to Tech Lead hat — let's look at the implementation plan."*

This makes the change legible to the user (per `nc-skill-announce`).

---

## Org-level anti-patterns to avoid

- **Hero engineer:** one person owns everything → bus factor 1
  - Instead: write design docs, pair, code review
- **Death march:** scope creep without timeline reset
  - Instead: re-MoSCoW, cut scope or push date
- **Blameful postmortem:** focus on who, not what process failed
  - Instead: blameless — assume people did their best given context
- **Stealth deploy:** ship without comms
  - Instead: notify CS + stakeholders before user-facing changes
- **Premature scaling:** building for 1M users when you have 10
  - Instead: ship for current scale + 1 order of magnitude headroom
- **Drive-by review:** approving without reading
  - Instead: "I haven't reviewed; please get another reviewer" is honest
- **Meeting addiction:** scheduling syncs for things async-able
  - Instead: 24h of comments first, meeting only if stuck

---

## Integration

- `nc-router` — when task is large, route to the right "department" via this map
- `nc-plan` — uses Feature Development Cycle as the implicit plan template
- `nc-debug` → `nc-fix` — uses Incident Response template for prod bugs
- `nc-code-review` — applies reviewer-role lens here
- `nc-predict` — applies Reversibility check (Type 1 vs 2)
- `nc-brainstorm` — applies decision frameworks (RACI, MoSCoW, DACI)
- `nc-retro` — uses sprint Retro template
- `nc-journal` — captures Postmortem template for incidents
- `nc-skill-announce` — announces role switches
- `nc-persona` — calibrates communication norms (up/across/down)
- Context Protocol — RFCs/ADRs/postmortems live in `plans/{session}/context/decisions.md`

---

## Cheat sheet (TL;DR)

| Request shape | Embody | Process | Output |
|---|---|---|---|
| "build feature X" | PM → TL → Eng | Feature dev cycle | PRD + design doc + impl |
| "site is down" | SRE on-call | Incident response | Mitigation + postmortem |
| "review my PR" | Senior Eng | Code review process | Critical/suggestion/nit |
| "should we use X" | Tech Lead | RFC | Decision doc |
| "what should I work on" | EM | Eisenhower / MoSCoW | Prioritized list |
| "we just shipped X" | PM + DevRel | Launch comms | Release notes + announce |
| "fix this small bug" | Mid Eng | (no overhead) | Patch + test |
| "design the schema" | Tech Lead + DBA | Design doc | Schema + migration plan |
