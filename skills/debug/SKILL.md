---
name: "debug"
description: "Reproduces bugs, analyzes stack traces, isolates root causes using binary search (git bisect) and breakpoints, and applies structured hypothesis testing with iterative verification. Use when: bug, error, crash, exception, not working, unexpected behavior, stack trace, failing test, broken, regression. Do NOT use for: code style review, feature requests, refactoring without a bug."
user-invocable: true
argument-hint: [bug-description-or-error]
---

## Dynamic Context

Recent errors and failing tests:
!`git log --oneline -5 --grep="fix\|bug\|error\|crash" 2>/dev/null || echo "No recent bug-fix commits found"`

# Debug Skill

## Purpose

Systematic debugging through structured hypothesis testing and iterative root cause isolation. Follows a 5-step framework with explicit feedback loops to prevent wasted effort.

## Usage

```bash
/debug "TypeError in user login flow"    # specific error
/debug "API returns 500 intermittently"  # intermittent bug
/debug                                    # prompt for description
```

## Debugging Framework

### Step 1: Define the Problem

Capture these before investigating:
- **Expected**: What should happen?
- **Actual**: What happens instead?
- **Repro**: Exact steps to reproduce (if possible)
- **Since when**: Last known working state (commit, date, or version)

### Step 2: Gather Information

```bash
# Find when it broke
git log --oneline --since="2 weeks ago" -- <suspected-path>

# Search for related errors
grep -rn "ERROR\|WARN\|Exception" logs/ | tail -20
```

Collect: full error message, stack trace, relevant logs (chronological), input data, and recent changes to affected files.

### Step 3: Hypothesize and Prioritize

Rank hypotheses by likelihood:
1. Most recently changed code in the affected path
2. Simplest explanation (Occam's razor)
3. Similar past bugs in the same area
4. External dependency changes

**Limit**: Test max 3 hypotheses before broadening scope.

### Step 4: Isolate and Verify

```bash
# Binary search through commits
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-commit>
# Test at each step, then: git bisect good/bad
```

**Feedback loop**: If hypothesis fails, return to Step 3 with updated information. After 3 failed hypotheses, broaden information gathering in Step 2.

### Step 5: Fix and Confirm

```
Checklist:
- [ ] Root cause fixed (not just symptom)
- [ ] Reproduction test written and passing
- [ ] No side effects (run full test suite)
- [ ] Regression test added
```

## Output Format

```
## Debug Report

### Problem Statement
- Expected: [expected behavior]
- Actual: [actual behavior]
- Repro: [reproduction steps]

### Investigation

#### Hypothesis 1: [hypothesis]
- Verification: [method used]
- Result: CONFIRMED / REJECTED

#### Root Cause
- File: path/to/file:line
- Cause: [root cause explanation]
- Evidence: [log output, stack trace, or test result]

### Solution
- Fix: [description of change]
- Test: [regression test added]
- Verified: [full test suite passes]

### Prevention
- [ ] Regression test added
- [ ] Related code paths checked
```

## Related Skills

- `/test` - Write tests for the fix
- `/troubleshoot` - Broader troubleshooting (infra, config)
- `/explain` - Understand unfamiliar code before debugging
