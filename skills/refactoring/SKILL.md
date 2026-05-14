---
name: "refactoring"
description: "Detects code smells (long methods, duplication, large classes) and applies targeted refactoring patterns with test-verified safety at each step. Use when: refactor, clean up, code smell, simplify, restructure, technical debt, extract method, reduce complexity, DRY, decompose. Do NOT use for: feature changes, bug fixes, adding new behavior."
user-invocable: true
argument-hint: [scope-or-file]
---

## Dynamic Context

Recent refactoring commits:
!`git log --oneline -5 --grep="refactor" 2>/dev/null || echo "No recent refactoring commits found"`

# Refactoring Skill

## Purpose

Safely restructure code without changing behavior, using small verified steps with test gates at each stage.

## Usage

```bash
/refactoring src/services/payment.ts   # refactor specific file
/refactoring src/api/                   # refactor directory
/refactoring                            # analyze current context
```

## Workflow

### Step 1: Verify Baseline

Before any change, confirm all tests pass:

```bash
# Run existing test suite
pnpm test          # JS/TS
pytest              # Python
go test ./...       # Go
```

**Gate**: If tests fail, fix them first. Do not refactor on a broken baseline.

### Step 2: Identify Code Smells

Analyze the target scope for these high-impact smells:

| Smell | Detection Signal | Typical Fix |
|-------|-----------------|-------------|
| Long method (>30 lines) | Line count, multiple concerns | Extract Function |
| Duplicate code | Similar blocks across files | Extract shared function |
| Large class | Many fields/methods, multiple responsibilities | Extract Class |
| Deep nesting (>3 levels) | Nested conditionals | Guard Clauses, Early Return |
| Feature envy | Method uses another class's data heavily | Move Method |
| Long parameter list (>4 params) | Function signatures | Introduce Parameter Object |

### Step 3: Plan Refactoring Sequence

Order changes by:
1. **Dependency**: refactor leaf functions before callers
2. **Risk**: low-risk changes first (renames, extractions)
3. **Impact**: highest smell severity first

### Step 4: Apply Changes (One at a Time)

For each refactoring:
1. Make ONE small structural change
2. Run tests immediately
3. If tests pass → commit
4. If tests fail → **revert immediately**, investigate why, adjust approach

```bash
# Commit each successful step
git add -A && git commit -m "refactor: [describe structural change]"
```

**Error recovery**: If a refactoring breaks something non-obvious, use `git diff` to review the change, identify the coupling, and either fix the test or choose a different refactoring approach.

### Step 5: Verify Completion

After all changes:
- [ ] All tests pass
- [ ] No new warnings introduced
- [ ] Code coverage unchanged or improved
- [ ] Behavior identical (no functional changes)

## Output Format

```
## Refactoring Plan

### Code Smells Detected
| Smell | Location | Severity |
|-------|----------|----------|
| Long Method | file:line | High |

### Refactoring Steps

#### Step 1: [Pattern Applied]
- Target: file:line
- Change: [description]
- Tests: PASS

#### Step 2: ...

### Test Verification
- [ ] All existing tests pass
- [ ] No behavior change
- [ ] Coverage: [before]% → [after]%

### Risk Assessment
- Impact scope: [files/modules affected]
- Estimated time: [estimate]
```

## Related Skills

- `/code-review` - Review refactored code
- `/test` - Add missing test coverage before refactoring
- `/clean-code` - Clean code principles reference
