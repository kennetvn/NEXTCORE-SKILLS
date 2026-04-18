---
description: Systematic refactoring patterns: extract method, rename symbol, impact analysis, dead code removal. Use for cross-file refactors, renaming APIs with many consumers, or restructuring without breaking behavior.
---

# Systematic Refactoring

Principle: **behavior-preserving transformations**. Tests pass before + after.

## Golden rule

Never combine refactor + feature change in same commit. Split:

1. Commit A: refactor (no behavior change)
2. Commit B: feature change (uses refactored structure)

## Common refactorings

### Extract method

Identify repeated logic or long function → extract to named method.

```ts
// Before
function processOrder(order) {
  // 30 lines of validation
  // 20 lines of tax calculation
  // 40 lines of saving
}

// After
function processOrder(order) {
  validateOrder(order);
  const tax = calculateTax(order);
  return saveOrder(order, tax);
}
```

### Rename symbol (cross-file)

1. Grep for all occurrences: `grep -rn "oldName" src/`
2. Check: direct refs, string refs (SQL, templates), comments
3. Rename in declaration first
4. Rename all usages
5. Run tests
6. Commit

IDE features (VS Code "Rename Symbol", IntelliJ refactor) handle TS/JS/Java accurately. For SQL strings, templates, config files — manual grep.

### Extract interface

```ts
// Before
function sendEmail(config: { host: string; port: number; user: string; pass: string }) {}

// After
interface EmailConfig {
  host: string;
  port: number;
  user: string;
  pass: string;
}
function sendEmail(config: EmailConfig) {}
```

### Replace conditional with polymorphism

```ts
// Before
function area(shape) {
  if (shape.type === "circle") return Math.PI * shape.r ** 2;
  if (shape.type === "square") return shape.side ** 2;
  if (shape.type === "rectangle") return shape.w * shape.h;
}

// After
abstract class Shape { abstract area(): number; }
class Circle extends Shape { constructor(public r: number) {} area() { return Math.PI * this.r ** 2; } }
class Square extends Shape { constructor(public side: number) {} area() { return this.side ** 2; } }
```

## Impact analysis

Before refactoring, measure blast radius:

```bash
# How many files reference this?
grep -rln "functionName" src/ | wc -l

# Which tests cover it?
grep -rln "functionName" tests/

# Who called recently (git)?
git log -p --all -S "functionName" | head
```

If > 20 files → plan incremental migration (see `nc-migration-patterns`).

## Dead code detection

```bash
# Unused exports (TS)
npx ts-prune

# Unused dependencies
npx depcheck

# Unused components
grep -rL "import.*ComponentName" src/  # files NOT importing

# Dead routes
# Diff routes declared vs analytics data (real traffic)
```

## Test-first refactoring

```
1. Write characterization tests — capture current behavior
2. Run tests, ensure green
3. Refactor
4. Run tests, ensure green
5. If test fails → refactor broke behavior, investigate
```

Without tests: safe refactor is impossible at scale. Add tests BEFORE touching the code.

## Large refactor strategy

For 1000+ line changes:

1. Feature-flag the new path
2. Implement new alongside old
3. Gradually route traffic (5% → 25% → 100%)
4. Remove old when confident
5. Remove flag

See `nc-migration-patterns` for expand+contract details.

## Refactoring smells to look for

- Function > 200 LOC → extract
- Copy-pasted code in 3+ places → extract
- Parameter list > 5 → group into object
- Deep nesting > 4 levels → early returns / extract
- Mutable module-level state → inject via constructor
- "Utils" file with unrelated functions → split by domain

## Anti-patterns

- Refactor + feature in same PR (hard to review, unsafe rollback)
- Refactor without tests (changes behavior silently)
- Massive rename in single commit across 100+ files (hard to review)
- Extract method for single-use short code (over-engineering)
- Premature abstraction (extract before seeing 3+ usages)

## Tools

- **ts-morph** — TypeScript AST manipulation (programmatic refactor)
- **jscodeshift** — JS codemods (Facebook)
- **comby** — language-agnostic structural search/replace
- **semgrep** — pattern-based code search + transform

## Integration

- `nc-migration-patterns` — strangler fig for big refactors
- `nc-test` — run tests before + after every refactor
- `nc-debug` — if test fails post-refactor, debug exact diff
