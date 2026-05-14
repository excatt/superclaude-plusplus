---
name: "tdd"
description: "Test-Driven Development workflow with RED-GREEN-REFACTOR cycle enforcement. Ensures tests are written before production code, with Git checkpoints at each phase. Use proactively when: new feature implementation with testable behavior, bug fix (write reproduction test first), user explicitly requests TDD approach. Triggers: TDD, test-driven, test first, red green refactor, write test first, failing test, reproduction test. Do NOT use for: config changes, documentation, simple renames, UI-only changes."
user-invocable: true
argument-hint: [feature-or-bug-description]
---

## Dynamic Context

Recent TDD commits:
!`git log --oneline -5 --grep="red:\|green:\|refactor:" 2>/dev/null || echo "No TDD commits found"`

Test infrastructure:
!`ls tests/ __tests__/ test/ 2>/dev/null | head -10 || echo "No test directory found"`

# TDD Workflow Skill

## Purpose
Enforce disciplined RED-GREEN-REFACTOR cycle with Git checkpoints to prevent skipping steps.

## Usage

```bash
/tdd "user login validation"      # new feature
/tdd "fix: timeout on large files" # bug reproduction
/tdd                               # prompt for description
```

## The Cycle

```
RED → GREEN → REFACTOR → (repeat)
 │      │        │
 │      │        └─ git commit "refactor: ..."
 │      └─ git commit "green: ..."
 └─ git commit "red: ..."
```

## Phase 1: RED (Write Failing Test)

**Goal**: Write a test that describes the desired behavior. It MUST fail.

### Rules
- Write the test FIRST — before any production code
- Test should be minimal: one behavior per test
- Run the test suite and confirm failure

### RED Gate (CRITICAL)
```
DO NOT edit production code until RED state is confirmed.
```

Acceptable RED states:
- Test fails with assertion error (expected behavior not implemented)
- Test fails with compile/import error (function/class doesn't exist yet)

NOT acceptable:
- Test fails because of typo in test code
- Test fails because test framework misconfigured

### Checkpoint
```bash
git add -A && git commit -m "red: [describe expected behavior]"
```

## Phase 2: GREEN (Make It Pass)

**Goal**: Write the MINIMUM production code to make the test pass. Nothing more.

### Rules
- Only write code that the failing test requires
- No premature optimization
- No extra features
- "Fake it till you make it" is valid (hardcoded returns → generalize later)

### GREEN Gate
```
ALL tests must pass. No new test failures introduced.
```

### Checkpoint
```bash
git add -A && git commit -m "green: [describe what was implemented]"
```

## Phase 3: REFACTOR (Clean Up)

**Goal**: Improve code quality without changing behavior. Tests stay green throughout.

### Rules
- Extract duplications
- Rename for clarity
- Simplify logic
- Run tests after EVERY change — if any test breaks, revert immediately

### Checkpoint
```bash
git add -A && git commit -m "refactor: [describe improvement]"
```

## Cycle Completion

After REFACTOR, evaluate:
- More behaviors to implement? → Start new RED phase
- All requirements met? → Run full test suite → Report coverage

## Coverage Gate

After all cycles complete:

```bash
# JavaScript/TypeScript
pnpm test -- --coverage

# Python
pytest --cov --cov-report=term-missing
```

**Minimum threshold**: Report actual coverage. Flag untested paths. Do not set arbitrary percentage targets unless the project defines one.

## Anti-patterns — Must Avoid

- Writing production code before test (defeats TDD purpose)
- Writing test that already passes (not RED)
- Skipping REFACTOR phase ("it works, ship it")
- Testing implementation details instead of behavior
- Brittle selectors (CSS classes, DOM structure) in tests
- Test-to-test dependencies (each test must be independent)
- Large RED→GREEN jumps (write too much code at once)

## Output Format

```
## TDD Cycle 1: [behavior]

### RED
- Test: `test/auth.test.ts` — `should reject empty password`
- Status: FAIL ✓ (assertion error: expected rejection)
- Commit: `red: reject empty password validation`

### GREEN
- Implementation: `src/auth.ts:validatePassword()`
- Status: ALL PASS ✓
- Commit: `green: implement password validation`

### REFACTOR
- Change: extracted validation rules to constants
- Status: ALL PASS ✓
- Commit: `refactor: extract validation constants`

## Coverage: 87% (src/auth.ts: 100%)
```

## Related Skills

- `/testing` - General test strategy and patterns
- `/pytest-runner` - Python test execution
- `/verify` - Post-implementation verification
- `/confidence-check` - Pre-implementation assessment
