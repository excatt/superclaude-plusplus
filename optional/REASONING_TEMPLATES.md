# Reasoning Templates

Fill-in-the-blank templates for structured reasoning.
Optional for Medium difficulty; mandatory for Complex difficulty.

---

## 1. Debugging Hypothesis Loop

Iterate when finding bug causes. After 3 iterations without resolution, trigger `3+ Fixes Architecture Rule`.

```
=== Hypothesis #{N} ===

Observation: {error message, symptoms, reproduction conditions}
Hypothesis: "{phenomenon} is caused by {suspected cause}"
Verification: {verification method -- code reading, logs, tests, etc.}
Result: {actually confirmed facts}
Verdict: Correct / Incorrect

Correct → Proceed to Fix step
Incorrect → Write Hypothesis #{N+1}
```

**Example**:
```
=== Hypothesis #1 ===
Observation: "Cannot read property 'map' of undefined" in TodoList
Hypothesis: "todos is undefined when .map() is called before API response"
Verification: Check useState initial value in TodoList component
Result: useState() has no initial value → undefined
Verdict: Correct → Set todos default to []
```

**SC++ Integration**: Use this template in Phase 3 (Hypothesis) of `RULES.md` Failure Investigation.

---

## 2. Architecture Decision Matrix

Use when a technology choice or design decision is needed. Combine with the Assumption Transparency rule.

```
=== Decision: {matter to decide} ===

Options:
  A: {Option A}
  B: {Option B}
  C: {Option C} (if applicable)

| Criterion              | A | B | C | Weight |
|------------------------|---|---|---|--------|
| Performance            |   |   |   | {H/M/L} |
| Implementation effort  |   |   |   | {H/M/L} |
| Existing code match    |   |   |   | {H/M/L} |
| Scalability            |   |   |   | {H/M/L} |
| Team/project familiarity |   |   |   | {H/M/L} |

Conclusion: {chosen option}
Reason: {1-2 line rationale}
Trade-off: {advantages sacrificed}
Reversibility: {easy to revert / costly / irreversible}
```

**Rule**: When choosing an option that does not score highest on a High-weight criterion, the rationale must be explicitly stated.
**SC++ Integration**: Strengthens the Assumption Transparency "No silent picks" principle.

---

## 3. Cause-Effect Chain

Step-by-step execution flow tracing for complex bugs.

```
=== Execution Flow Trace ===

1. [Entry]      {file:function} — {input values}
2. [Call]       {file:function} — {passed values}
3. [Process]    {file:function} — {transformation/logic}
4. [Failure]    {file:function} — {behavior differs from expectation}
   - Expected: {expected behavior}
   - Actual:   {actual behavior}
   - Cause:    {why they differ}
5. [Result]     {error message or incorrect output}
```

**SC++ Integration**: Use this template for evidence collection in Failure Investigation Phase 1 (Root Cause).

---

## 4. Refactoring Judgment

Decision framework for "should I fix this too?" during code modification. Strengthens Change Scope Discipline.

```
=== Refactoring Judgment ===

Issue found: {discovered problem}
Relation to task: Directly related / Indirectly related / Unrelated

Directly related    → Fix it (within current task scope)
Indirectly related  → Record in result, fix only if within scope
Unrelated           → Record only, never fix
```

**Litmus Test**: "Does every changed line trace directly to the user's request?"
**SC++ Integration**: Execution tool for the Change Scope Discipline "No drive-by refactoring" principle.

---

## 5. Performance Bottleneck Analysis

Systematic bottleneck analysis for "it's slow" reports.

```
=== Performance Bottleneck Analysis ===

Measurements:
  - Total response time:     {ms}
  - DB query time:           {ms} ({N} queries)
  - Business logic:          {ms}
  - Serialization/rendering: {ms}

Bottleneck: {step consuming the most time}
Cause: {N+1 query / heavy computation / large payload / missing index / ...}
Solution: {specific fix}
Expected improvement: {X}ms → {Y}ms
Verification: {benchmark command or test}
```

**Rule**: "It's slow" is a Weak Criteria -- measure first, define a target metric, then mark complete upon achievement.
**SC++ Integration**: Goal Definition Protocol -- "Improve performance" → "Measure → Target → Achieve".

---

## 6. Requirement Decomposition

Decompose vague requests into the 4-element structure. Execution tool for the Goal Definition Protocol.

```
=== Requirement Decomposition ===

Original request: "{user's original text}"

1. Goal:        {what to build/change/fix}
2. Context:     {related files, errors, existing patterns}
3. Constraints: {architecture rules, dependency limits, project conventions}
4. Done When:   {verifiable completion criteria}

Missing elements:
  - [ ] Goal: {sufficient / need to ask "specifically what?"}
  - [ ] Context: {obtainable via codebase exploration / need to ask user}
  - [ ] Constraints: {found in CLAUDE.md, CONVENTIONS.md / none}
  - [ ] Done When: {can propose test criteria / need user confirmation}
```

**Anti-patterns**:
- Starting implementation with only Goal (no constraints, no done-when)
- Inventing constraints the user did not specify
- Accepting vague done-when like "should just work"

**SC++ Integration**: Unified execution tool for Goal Definition Protocol + Assumption Transparency.

---

## Usage Rules

1. **When**: Optional for Medium difficulty, mandatory for Complex
2. **Where**: Include reasoning process in agent result reports
3. **Cannot fill a blank**: Collect the information first (code reading, tests, logs)
4. **Unresolved after 3 iterations**: `Status: blocked` + include reasoning process in user report
