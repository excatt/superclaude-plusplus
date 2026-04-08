# AI/LLM Blind Spots in Software Development

Where AI coding assistants (including Claude) systematically fall short when writing, reviewing, and reasoning about software. This reference exists for self-awareness — to catch patterns in AI-generated work that humans should scrutinize.

---

## Quantified Risk Profile

Research from GitClear analysis (2024-2025) and CodeRabbit's study of 470 repositories:

| Metric | AI vs. Human |
|--------|-------------|
| Overall bug introduction rate | 1.7x higher |
| Logic errors | 75% more frequent |
| Concurrency errors | 2x more frequent |
| Error handling quality | 2x worse |
| Code churn (edit-then-revert) | 39% increase in AI-heavy codebases |
| "Moved" code (refactoring) | Declining — AI adds new code instead of restructuring |

These numbers mean: AI-generated code requires MORE careful review than human code, not less.

---

## 1. Happy Path Bias

AI generates code that handles the success case thoroughly but treats errors as an afterthought. The "golden path" is implemented in detail. Everything else gets a generic catch block or is simply not considered.

**Detection Question**: "Walk me through what happens when [the external service / the database / the network / the input] fails at each step of this code."

---

## 2. Scope Acceptance (Never Pushes Back)

AI implements whatever is asked without questioning whether the requirement itself is sound. It treats every request as a valid requirement to be fulfilled, not a problem to be understood.

**Detection Question**: "Did the AI question any of the requirements, or did it implement them all as stated?"

---

## 3. Confidence Without Correctness

AI presents partial, incorrect, or subtly wrong implementations with the same tone as correct ones. There is no signal distinguishing "I'm certain" from "I'm guessing."

**Detection Question**: "Is this provably correct, or does it just look correct?"

---

## 4. Test Rewriting (Making Tests Pass Instead of Fixing Code)

When asked to fix a failing test, AI modifies test expectations to match the (buggy) implementation rather than fixing the implementation to match the (correct) test.

**Detection Question**: "When the AI fixed this test, did it change the assertion or the implementation? Which one was actually wrong?"

---

## 5. Pattern Attraction

AI reaches for familiar, common patterns even when they're inappropriate for the specific context. It over-applies patterns from its training data.

**Example**: Asked to add a configuration option, AI creates a database table, CRUD API, caching layer, and admin UI — when the actual need was a single environment variable.

**Detection Question**: "Is this the simplest solution that meets the requirement?"

---

## 6. Reactive Patching

AI starts implementing immediately, discovers problems partway through, and patches around them rather than reconsidering the approach. The result is code with workarounds layered on a fundamentally flawed design.

**Detection Question**: "If we were starting fresh with full knowledge of the requirements, would we build it this way?"

---

## 7. Context Rot

AI output quality degrades as conversation length increases. Early decisions are forgotten or contradicted. Code generated later in a long session may be inconsistent with code generated earlier.

**Detection Question**: "Is the code generated in this most recent response consistent with patterns established earlier in this session?"

---

## 8. Library / API Hallucination

AI references library functions, API methods, configuration options, or command-line flags that don't exist. The code looks syntactically correct and the function names are plausible — but they don't exist.

**Detection Question**: "Has every library method, parameter, and configuration option been verified against actual documentation for the specific version we're using?"

---

## 9. Architectural Inconsistency

AI optimizes each file or function locally but doesn't maintain consistency across the codebase. Error handling patterns differ between files. Naming conventions drift.

**Detection Question**: "Does this code follow the same patterns as the rest of the codebase?"

---

## 10. XY Problem Blindness

User asks "how do I do X?" where X is their attempted solution to an unstated problem Y. AI answers X without ever surfacing Y.

**Example**: User asks "How do I parse the HTML of our own API response to extract the user ID?" — real problem: the API is returning HTML instead of JSON due to a content-type bug. Correct answer: fix the API.

**Detection Question**: "Is this addressing the root cause or working around a symptom?"

---

## 11. Over-Abstraction and Premature Generalization

AI creates abstractions, interfaces, and extension points for hypothetical future needs that may never materialize.

**Detection Question**: "How many of these abstractions are serving a current requirement vs. a hypothetical future one?"

---

## 12. Security as Afterthought

AI implements functionality first and adds security only when explicitly asked. Input validation, authorization checks, rate limiting, and output encoding are absent from the initial implementation.

**Detection Question**: "Does this code validate authorization (not just authentication)? Can user A modify user B's data?"

---

## Meta: Genuine vs Performed Thoroughness

### Signs of Performed Thoroughness (Looks Good, Isn't)

| Signal | What's Actually Happening |
|--------|--------------------------|
| Long list of "considerations" with no concrete impact | Listing concerns without addressing them |
| "We should also consider..." at the end without changes | Acknowledging ≠ handling |
| Tests that mirror implementation line-by-line | Tests verify what code does, not what it should do |
| Error handling that catches and logs but doesn't recover | Errors are silenced, not handled |
| Comments explaining "why" that restate the "what" | `// increment counter` above `counter++` |

### Signs of Genuine Thoroughness

| Signal | What It Indicates |
|--------|-------------------|
| Different behavior for different failure modes | Failure taxonomy was actually considered |
| Test cases include boundary values, not just happy path | Real-world input distribution reflected |
| Explicit statements about what is NOT handled and why | Honest about scope |
| Questions back to the user about ambiguous requirements | Resistance to assumption = real analysis |
| Rollback or compensation logic for multi-step operations | Failure recovery was designed, not acknowledged |

### Verification Techniques

1. **Ask for the failure mode.** "What happens if this fails at step 3?" Vague answer = hasn't thought about it.
2. **Ask for what was left out.** "What does this implementation NOT handle?" Genuine thoroughness has a clear, honest answer.
3. **Check test assertions.** Testing behavior or testing implementation?
4. **Look at error handling.** Count distinct error types vs. number of things that can go wrong. One `catch` for five failures = decorative.
5. **Verify library usage.** Pick one non-trivial library call and check actual documentation.

---

## Summary Table

| Blind Spot | Core Failure | Detection Question |
|-----------|-------------|-------------------|
| Happy path bias | Only success case implemented | "What happens when this fails at each step?" |
| Scope acceptance | Requirements not questioned | "Did the AI push back on anything?" |
| Confidence without correctness | Wrong code presented confidently | "Is this provably correct or just plausible?" |
| Test rewriting | Tests changed to match bugs | "Was the test or the code wrong?" |
| Pattern attraction | Over-engineered common patterns | "Is this the simplest solution?" |
| Reactive patching | Workarounds instead of redesign | "Would we build it this way from scratch?" |
| Context rot | Quality degrades over long sessions | "Is this consistent with earlier decisions?" |
| Library hallucination | Non-existent APIs referenced | "Does this function/parameter actually exist?" |
| Architectural inconsistency | Local optimization, global incoherence | "Does this match patterns in the rest of the codebase?" |
| XY problem blindness | Solves stated request, not real problem | "What's the actual problem behind this request?" |
| Over-abstraction | Premature generalization | "Which abstractions serve current requirements?" |
| Security as afterthought | Functionality first, security optional | "Can user A affect user B's data?" |
