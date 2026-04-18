# Scenario: Big feature → org-mode

**Triggers:** `nc-company-os`, `nc-plan`, `nc-skill-announce`
**User profile:** Tech Lead at small startup, 4-person team
**Setup:** Mid-session, planning a new feature

## Turn 1

**User:** "We need to add subscription billing to our SaaS. How should we approach this?"

**Expected behavior:**
- Detect "big feature" signals: subscription billing = compliance + architecture + UX + ops
- Activate `nc-company-os` — embody role chain
- Announce: `> Activating nc-company-os: PM → Tech Lead → Eng → DevOps. Big feature scope.`
- Output structured plan covering all roles:
  - **PM lens**: write 1-pager (problem, users, success metric)
  - **Designer lens**: pricing page + checkout flow + customer portal
  - **Tech Lead lens**: integration choice (Stripe / Polar / Paddle), webhooks, idempotency
  - **Eng lens**: schema (subscriptions, invoices, payment_methods), migrations
  - **SRE lens**: webhook delivery monitoring, retry queue
  - **Legal lens**: T&C update, tax handling, MoR vs direct
  - **CS lens**: rollout plan, support docs, churn handling

**Anti-patterns to avoid:**
- Jumping straight to code without role-based decomposition
- Skipping legal / CS lenses (common dev blindspot)
- Suggesting just one payment provider without trade-offs

## Turn 2

**User:** "We're 4 people, can't do all that. What's the MVP?"

**Expected behavior:**
- Apply MoSCoW from `nc-company-os` decision frameworks:
  - **Must:** Stripe-or-Polar integration, single plan, working checkout, basic invoices
  - **Should:** Customer portal, payment failure handling, basic dunning
  - **Could:** Multiple plans, prorated upgrades, usage metering
  - **Won't (this iteration):** Tax automation (use provider built-in), dunning automation, refund self-service
- Apply Reversibility: payment provider choice = Type 1 (one-way door) → write RFC first
- Suggest single Tech Lead writes 1-page RFC, gets 24h review window from team

**Anti-patterns to avoid:**
- Listing same plan as before, just smaller (didn't actually re-prioritize)
- Skipping the RFC suggestion for the Type 1 decision
- Suggesting they "just pick Stripe" without acknowledging it's a one-way door

## Turn 3

**User:** "OK let's go with Polar (MoR matters for us). Start the integration."

**Expected behavior:**
- Announce role switch: `> Switching from Tech Lead hat to Senior Eng hat — implementing Polar integration.`
- Activate `nc-payment-integration` (existing skill)
- Update `context/decisions.md` (Context Protocol):
  > 2026-04-18 — Chose Polar over Stripe
  > Decision: Polar (MoR)
  > Why: handles tax + global compliance for us
  > Trade-offs: smaller ecosystem vs Stripe; webhook patterns differ
  > Reversibility: costly — would require migration + customer notification
- Begin implementation following `nc-payment-integration` Polar reference

**Anti-patterns to avoid:**
- Re-debating Stripe vs Polar (decision was made)
- Forgetting to log decision (loses context for future sessions)
- Not announcing the role switch (user loses thread)

## Pass criteria

- Initial response covers ≥5 distinct roles, not just engineering
- MoSCoW prioritization is meaningfully different from initial plan
- Reversibility check happens for payment-provider choice
- Role switches are announced legibly
- Decision logged to Context Protocol for cross-session continuity
