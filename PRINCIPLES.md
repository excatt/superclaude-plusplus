# Software Engineering Principles

**Core Directive**: Evidence > assumptions | Code > documentation | Efficiency > verbosity

Textbook principles the model already knows (SOLID, DRY, general risk/quality
frameworks) are not restated here — only the preferences that shape *when and
how* they get applied.

## Complexity Timing
- Design patterns and abstractions apply when complexity **actually exists**, not preemptively
- No Strategy pattern, ABC, Protocol for single-use code
- The second usage is the right time to abstract, not the first
- "The pattern is correct but not yet needed" → apply later

## Simplicity Checks (KISS/YAGNI)
- No abstractions for single-use code; no error handling for impossible scenarios
- Self-check: "Could 200 lines be 50?" → YES → rewrite
- Senior Engineer Test: "Would they call this overcomplicated?" → YES → simplify
- Implement current requirements only; no speculative features

## Build Ladder (Search Before Building)
Stop at the first rung that applies. Each rung that fires removes work the later rungs would have created.

| # | Gate | Action |
|---|------|--------|
| 0 | Does this need to exist at all? | Skip it — YAGNI |
| 1 | Already in this codebase? | Reuse it. Grep before writing |
| 2 | Stdlib / built-in API? | Use it |
| 3 | Native platform feature? | Use it |
| 4 | Already-installed dependency? | Use it |
| 5 | Tried-and-true library? | Adopt it (Layer 1) |
| 6 | New-and-popular, community-validated? | Evaluate, then adopt (Layer 2) |
| 7 | None of the above | Build the minimum that works (Layer 3) |

- **Eureka gate**: Rung 7 is justified only when existing solutions are provably wrong or missing — not when they're merely unfamiliar
- Scope limit, ordering rule, rung 3 case catalog: `optional/OVERENGINEERING_TRAPS.md`

## Harness Engineering

### Repository as Knowledge Base
- **Self-documenting Repo**: The repository itself is the single source of domain knowledge for agents
- **Code as Context**: Directory structure, naming, type system, and module boundaries convey domain intent
- **Agent Readability**: "Can an agent understand the full business domain from the repo alone?" → NO → improve the repo
- **Machine-readable Constraints**: Architectural rules enforced via linters, CI, and structural tests — not just prose

### Dependency Flow Principle
- **Unidirectional Flow**: `Types → Config → Domain → Service → Runtime → UI`
- **Violation = Signal**: Import direction violations indicate architectural debt, not just style issues
- **Automated Validation**: Prefer mechanical enforcement (linters, `/audit`) over manual review

### Continuous Harness Improvement
- **Struggle = Signal**: When agents fail, diagnose what's missing in the repo (tools, guardrails, docs, types)
- **No Autonomous Fix**: Repo improvements require human approval (prevent infinite loops)
- **Entropy Resistance**: Periodic codebase hygiene to maintain agent-readability over time
