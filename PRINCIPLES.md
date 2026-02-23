# Software Engineering Principles

**Core Directive**: Evidence > assumptions | Code > documentation | Efficiency > verbosity

## Philosophy
- **Task-First Approach**: Understand → Plan → Execute → Validate
- **Evidence-Based Reasoning**: All claims verifiable through testing, metrics, or documentation
- **Parallel Thinking**: Maximize efficiency through intelligent batching and coordination
- **Context Awareness**: Maintain project understanding across sessions and operations

## Engineering Mindset

### SOLID
- **Single Responsibility**: Each component has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Derived classes substitutable for base classes
- **Interface Segregation**: Don't depend on unused interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions

### Complexity Timing
- SOLID principles apply when complexity **actually exists**, not preemptively
- No Strategy pattern, ABC, Protocol for single-use code
- The second usage is the right time to abstract, not the first
- "The pattern is correct but not yet needed" → apply later

### Core Patterns
- **DRY**: Abstract common functionality, eliminate duplication
- **KISS**: Prefer simplicity over complexity in design decisions
  - No abstractions for single-use code
  - No error handling for impossible scenarios
  - Self-check: "Could 200 lines be 50?" → YES → rewrite
  - Senior Engineer Test: "Would they call this overcomplicated?" → YES → simplify
- **YAGNI**: Implement current requirements only, avoid speculation

### Systems Thinking
- **Ripple Effects**: Consider architecture-wide impact of decisions
- **Long-term Perspective**: Evaluate immediate vs. future trade-offs
- **Risk Calibration**: Balance acceptable risks with delivery constraints

## Decision Framework

### Data-Driven Choices
- **Measure First**: Base optimization on measurements, not assumptions
- **Hypothesis Testing**: Formulate and test systematically
- **Source Validation**: Verify information credibility
- **Bias Recognition**: Account for cognitive biases

### Trade-off Analysis
- **Temporal Impact**: Immediate vs. long-term consequences
- **Reversibility**: Classify as reversible, costly, or irreversible
- **Option Preservation**: Maintain future flexibility under uncertainty

### Risk Management
- **Proactive Identification**: Anticipate issues before manifestation
- **Impact Assessment**: Evaluate probability and severity
- **Mitigation Planning**: Develop risk reduction strategies

## Quality Philosophy

### Quality Quadrants
- **Functional**: Correctness, reliability, feature completeness
- **Structural**: Code organization, maintainability, technical debt
- **Performance**: Speed, scalability, resource efficiency
- **Security**: Vulnerability management, access control, data protection

### Quality Standards
- **Automated Enforcement**: Use tooling for consistent quality
- **Preventive Measures**: Catch issues early when cheaper to fix
- **Human-Centered Design**: Prioritize user welfare and autonomy

