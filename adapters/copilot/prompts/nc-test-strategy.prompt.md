---
description: Design test strategy that catches real bugs without slowing dev. Use when starting a project, adding tests to legacy code, deciding what to mock vs not, balancing unit/integration/e2e, or fighting flaky tests.
mode: agent
---

# Test Strategy Skill

Tests are insurance. Too few = bugs ship. Too many (or wrong kind) = slow CI + brittle suite. Get the mix right.

## The test pyramid (still useful)

```
          ┌──────┐
          │ E2E  │  Few. Critical user flows. Slow but high confidence.
         ┌┴──────┴┐
         │ Integ. │  Some. Across layers (DB + API). Medium speed.
        ┌┴────────┴┐
        │  Unit    │  Many. Pure logic. Milliseconds.
       └───────────┘
```

Rough mix: 70% unit / 25% integration / 5% E2E.

Modern caveat: in many web apps, integration tests give the best ROI (test components with real DB). Pure unit tests of "trivial getters" waste time.

## What to test (by value)

| Code | Test? | Why |
|---|---|---|
| Business logic / algorithms | YES, unit | Cheapest place to catch bugs |
| Validation rules | YES, unit | High value, low cost |
| API endpoints | YES, integration | Catches contract bugs |
| Database queries | YES, integration | ORM lies; real DB tests reality |
| UI components (Storybook) | YES, visual snapshots | Catch regression visually |
| Critical user flows (login, checkout) | YES, E2E | If broken, business stops |
| Trivial getters/setters | NO | Test what could plausibly break |
| Constants | NO | If wrong, immediately obvious |
| Generated code | NO | Trust the generator |
| Third-party libs | NO | They have their own tests |

## What to mock vs use real

| Dependency | Default |
|---|---|
| Database | Use real (test DB or Testcontainers) |
| Internal APIs (own services) | Real if fast, mock if slow |
| External APIs (Stripe, etc.) | Mock (their test mode if possible) |
| Time | Inject (clock interface) — testing time-dependent code with real Date is flaky |
| Random | Inject seed |
| Filesystem | Use temp dirs (real) |
| Network | Real for E2E, mock for unit |

Excessive mocking = testing your mocks, not your code.

## Coverage targets

- 80%+ on business logic / domain code
- 60%+ overall
- 0% required on generated, trivial accessors

Coverage is a proxy. 100% coverage on bad tests catches nothing. Look at:
- Mutation testing (Stryker / mutmut) — change code, do tests catch it?
- Branch coverage > line coverage
- Test failures over time — are tests catching real bugs?

## Anti-flaky tests (the silent killer)

Flaky test = passes sometimes, fails sometimes, no code change. Costs trust.

Common causes + fixes:

| Cause | Fix |
|---|---|
| Time dependency | Inject clock; use deterministic dates |
| Random data | Seed RNG |
| Test order dependency | Reset state between tests; randomize order in CI |
| Race condition / async timing | Await the actual signal, not `setTimeout` |
| Network call to real service | Mock or use VCR/cassette pattern |
| Shared DB state | Transactional rollback per test |
| Browser timing (E2E) | Use auto-wait selectors, not arbitrary sleeps |
| Resource leaks | Tear down properly |

Quarantine flaky tests (skip + label) immediately. Fix or delete in 1 week. Never let them poison signal.

## Test naming

```
// BAD
test('user works', () => { ... })

// GOOD
test('createUser_throws_when_email_already_exists', () => { ... })
// or
describe('createUser', () => {
  it('throws when email already exists', () => { ... })
})
```

Pattern: `[unit]_[scenario]_[expected]` or `describe(unit) → it(scenario, expected)`.

## Fixtures + factories

Don't repeat user-creation 100 times. Factory:

```typescript
function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: randomUUID(),
    email: `test-${Date.now()}@example.com`,
    role: 'member',
    createdAt: new Date(),
    ...overrides
  };
}

// Usage
const admin = makeUser({ role: 'admin' });
```

Patterns: factory-bot (Ruby), Faker.js, Mimesis (Python).

## Testing legacy code (no tests exist)

1. Don't try to backfill 80% coverage
2. Add tests when you change code (Boy Scout Rule)
3. Add a "characterization test" first: capture current behavior even if buggy
4. Then refactor under test
5. Then fix bugs (now safely)

Working Effectively with Legacy Code (Feathers) — the canonical reference.

## CI strategy

```
On PR:
  - Lint (5s)
  - Type check (15s)
  - Unit tests (30s)
  - Integration tests (1-2 min)
  - Build (1 min)
  → Block merge if any fail

On merge to main:
  - All of above
  - E2E tests (5-10 min)
  - Visual regression (1-2 min)
  - Deploy to staging
  → Notify on failure, don't block

Nightly:
  - Full E2E across browsers
  - Performance benchmark
  - Security scan
```

Keep PR feedback under 5 min. >10 min and devs context-switch.

## Visual regression

Storybook + Chromatic / Percy / Playwright screenshots:
- Each component snapshotted in canonical states
- PR shows visual diff
- Approve or fix
- Catches CSS regressions humans miss

## Snapshot tests (use sparingly)

```typescript
expect(rendered).toMatchSnapshot();
```

Pros: catches accidental changes
Cons: noisy on intentional changes; "approve all to update" is rubber-stamping

Use for: rarely-changing structures, output of pure transforms.
Avoid for: rendered components (use visual regression instead), volatile data.

## Anti-patterns

- "We'll add tests later" (later = never; tests get harder, not easier)
- Tests that test implementation, not behavior (refactor breaks tests for no reason)
- One mega test class for everything in a file (small focused test files)
- Mock everything (you're testing the mocks)
- 100% coverage as the goal (gaming metric)
- Tests in production paths (`if (env === 'test')`)
- Sleep-based waits in E2E (always flaky)
- Skipping flaky tests forever (delete or fix)
- Test data that depends on real DB seed state

## Integration

- `nc-bug-triage` — recurring bugs reveal missing tests
- `nc-debugging-advanced` — write tests AFTER fixing hard bug (regression guard)
- `nc-ci-cd` — pipeline integration
- `nc-chaos-engineering` — fault injection complements unit tests
- `nc-web-testing` — Playwright/Vitest specifics
- `nc-ai-evaluation` — eval suites are tests for LLM apps
- `nc-company-os` — testing strategy is tech-lead concern
