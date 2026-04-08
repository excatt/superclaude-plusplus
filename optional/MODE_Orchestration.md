# Orchestration Mode

**Purpose**: Intelligent tool selection mindset for optimal task routing and resource efficiency

## Activation Triggers
- Multi-tool operations requiring coordination
- Performance constraints (>75% resource usage)
- Parallel execution opportunities (>3 files)
- Complex routing decisions with multiple valid approaches

## Behavioral Changes
- **Smart Tool Selection**: Choose most powerful tool for each task type
- **Resource Awareness**: Adapt approach based on system constraints
- **Parallel Thinking**: Identify independent operations for concurrent execution
- **Efficiency Focus**: Optimize tool usage for speed and effectiveness

## Tool Selection Matrix

| Task Type | Best Tool | Alternative |
|-----------|-----------|-------------|
| UI components | Magic MCP | Manual coding |
| Deep analysis | Sequential MCP | Native reasoning |
| Symbol operations | Serena MCP | Manual search |
| Pattern edits | Morphllm MCP | Individual edits |
| Documentation | Context7 MCP | Web search |
| Browser testing | Playwright MCP | Unit tests |
| Multi-file edits | MultiEdit | Sequential Edits |
| Infrastructure config | WebFetch (official docs) | Assumption-based (❌ forbidden) |

## Infrastructure Configuration Validation

**Critical Rule**: Infrastructure and technical configuration changes MUST consult official documentation before making recommendations.

**Auto-Triggers for Infrastructure Tasks**:
- **Keywords**: Traefik, nginx, Apache, HAProxy, Caddy, Envoy, Docker, Kubernetes, Terraform, Ansible
- **File Patterns**: `*.toml`, `*.conf`, `traefik.yml`, `nginx.conf`, `*.tf`, `Dockerfile`
- **Required Actions**:
  1. **WebFetch official documentation** before any technical recommendation
  2. Activate MODE_DeepResearch for infrastructure investigation
  3. BLOCK assumption-based configuration changes

**Rationale**: Infrastructure misconfiguration can cause production outages. Always verify against official documentation (e.g., Traefik docs for port configuration, nginx docs for proxy settings).

**Enforcement**: This rule enforces the "Evidence > assumptions" principle from PRINCIPLES.md for infrastructure operations.

## Resource Management

**🟢 Green Zone (0-75%)**
- Full capabilities available
- Use all tools and features
- Normal verbosity

**🟡 Yellow Zone (75-85%)**
- Activate efficiency mode
- Reduce verbosity
- Defer non-critical operations

**🔴 Red Zone (85%+)**
- Essential operations only
- Minimal output
- Fail fast on complex requests

## Parallel Execution Triggers
- **3+ files**: Auto-suggest parallel processing
- **Independent operations**: Batch Read calls, parallel edits
- **Multi-directory scope**: Enable delegation mode
- **Performance requests**: Parallel-first approach

---

## Agent Chaining Workflows

Chain agents sequentially to handle complex tasks systematically.

### Predefined Workflows

| Workflow | Agent Chain | Use Case |
|----------|-------------|----------|
| **Feature** | planner → tdd-guide → code-reviewer → security-reviewer | New feature development |
| **Bugfix** | root-cause-analyst → tdd-guide → code-reviewer | Bug fix |
| **Refactor** | system-architect → code-reviewer → tdd-guide | Refactoring |
| **Security** | security-engineer → code-reviewer → system-architect | Security review |

### Handoff Document Template

Inter-agent handoff document:
```markdown
## Handoff: [Source Agent] → [Target Agent]

### Context
- Task: [task description]
- Progress: [completed work]

### Findings
- [finding 1]
- [finding 2]

### Modified Files
- `path/to/file.ts` - [change description]

### Open Questions
- [unresolved questions]

### Recommendations
- [recommendations for the next agent]
```

### Workflow Invocation
```
/sc:orchestrate feature "implement user auth system"
/sc:orchestrate bugfix "infinite loading on login failure"
/sc:orchestrate refactor "separate API layer"
/sc:orchestrate security "payment module security review"
```

---

## Model Selection Guide

Model selection based on task complexity and requirements:

### Model Matrix

| Model | Strengths | When to Use | Cost Efficiency |
|-------|-----------|-------------|-----------------|
| **Haiku** | Fast response, lightweight tasks | Pair programming, worker agents, simple edits | ⭐⭐⭐⭐⭐ |
| **Sonnet** | Balanced performance, coding-optimized | Primary dev work, workflow orchestration | ⭐⭐⭐⭐ |
| **Opus** | Best reasoning, architecture analysis | Architecture decisions, deep research, complex debugging | ⭐⭐⭐ |

### Selection Decision Tree
```
Task complexity?
├─ Simple (single file, clear change) → Haiku
├─ Medium (multi-file, logic changes) → Sonnet (default)
└─ Complex (architecture, system design) → Opus

Reasoning depth needed?
├─ --think → Sonnet
├─ --think-hard → Sonnet + extended context
└─ --ultrathink → Opus
```

### Context Window Strategy

**High-Sensitivity Operations** (avoid when context usage exceeds 80%):
- Large-scale refactoring
- Multi-file feature additions
- Complex interaction debugging

**Low-Sensitivity Operations** (safe when context is limited):
- Single file edits
- Utility function creation
- Documentation writing
- Simple bug fixes

### Cost Optimization
```
Typical dev session:
├─ Haiku: exploration, simple questions, worker tasks
├─ Sonnet: implementation, code writing, review
└─ Opus: architecture decisions, complex analysis (only when needed)

Recommended ratio: Haiku 30% / Sonnet 60% / Opus 10%
```