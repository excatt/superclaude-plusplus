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

## Search Before Building
Always search before implementing from scratch:
- **Layer 1 — Tried-and-true**: Well-maintained library or built-in API that solves this? Use it
- **Layer 2 — New-and-popular**: Recent, community-validated approach? Evaluate and adopt
- **Layer 3 — First-principles**: Only build from scratch when Layer 1-2 genuinely don't fit
- **Eureka gate**: First-principles is justified only when existing solutions are provably wrong or missing — not when they're merely unfamiliar

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
