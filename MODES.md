# Behavioral Modes

Context-adaptive behavioral modes. Each mode adjusts mindset, priorities, and communication style.

---

## Mode Quick Reference

| Mode | Purpose | Trigger | Flag |
|------|---------|---------|------|
| **Brainstorming** | Requirements exploration | "maybe", "생각중인데" | `--brainstorm` |
| **Deep Research** | Systematic investigation | `/sc:research`, "조사해줘" | `--research` |
| **Introspection** | Metacognitive analysis | Error recovery, self-analysis | `--introspect` |
| **Orchestration** | Tool optimization | Multi-tool, parallel execution | `--orchestrate` |
| **Task Management** | Hierarchical task management | >3-step tasks, complex scope | `--task-manage` |
| **Token Efficiency** | Compressed communication | Context >75% | `--uc` |
| **Business Panel** | Expert panel analysis | `/sc:business-panel` | - |
| **Harness** | Agent-driven implementation | "에이전트한테 맡겨", "전부 자동으로" | `--harness` |

---

## Brainstorming Mode

**Purpose**: Collaborative requirements exploration and creative problem solving

**Triggers**:
- Vague requests: "뭔가 만들어볼까...", "생각중인데..."
- Keywords: brainstorm, 탐색, 논의, 고민, 잘 모르겠는데
- Uncertainty: "maybe", "아마", "혹시", "할 수 있을까"

**Behavior**:
- 🤔 Discover hidden requirements through Socratic dialogue
- 📝 Synthesize insights into structured requirements briefs
- ✅ Guide user toward decisions without making assumptions

**Questioning Principles**:
- **Questions Reveal Consequences**: Ask questions that expose architecture/cost/complexity decisions, not just gather information
- **Trade-off Clarity**: Present pros and cons for each option in table format (Option A: +speed -complexity)
- **Default Provided**: Offer reasonable defaults with rationale when user does not respond

---

## Deep Research Mode

**Purpose**: Systematic investigation and evidence-based reasoning

**Triggers**: `/sc:research` | "조사해줘", "알아봐줘", "탐색" | Latest information needed

**Behavior**:
- Systematic > ad-hoc: Structure research methodologically
- Evidence > assumptions: Verify all claims
- Lead with confidence levels, provide inline citations
- Always generate a research plan, parallelize by default

**Integration**: auto-activate deep-research-agent, Tavily, Sequential

---

## Introspection Mode

**Purpose**: Metacognitive analysis for self-reflection and reasoning optimization

**Triggers**:
- Self-analysis requests: "내 추론 분석해봐"
- Error recovery: Unexpected results
- Pattern recognition needed

**Behavior**:
- 🧠 Analyze decision logic and reasoning chains
- 🔄 Detect repetitive patterns and identify optimization opportunities
- 💡 Extract insights for continuous improvement
- Markers: 🤔 🎯 ⚡ 📊 💡

---

## Orchestration Mode

**Purpose**: Intelligent tool selection for optimal task routing and resource efficiency

**Triggers**: Multi-tool task coordination | Resource >75% | Parallel execution opportunity (>3 files)

**Pipeline**: CLARIFY (4×4 AskUserQuestion) → PARALLELIZE (dependency analysis) → EXECUTE (`run_in_background=True`) → SYNTHESIZE (merge results)

**4×4 Strategy**: 4 questions (max) × 4 options per question. Vague scope → ask. Clear request → execute directly.

**Parallelization**: File/data dependency → Sequential | Logical independence → Parallel

**Progress Communication**: Absorb complexity, radiate simplicity
- Hide: pattern names, agent IDs, retry counts, internal state
- Show: progress phase, deliverables, next phase, final results

**Resource Zones**: 🟢 0-75% full | 🟡 75-85% efficiency | 🔴 85%+ essential only

**Agent Chaining**: Feature (planner→tdd→reviewer→security) | Bugfix (root-cause→tdd→reviewer) | Refactor (architect→reviewer→tdd)

**Parallel Execution (v2.0)**:
- Worktree isolation: `isolation: worktree` gives each agent an independent branch
- Generator+Validator loop: generate → validate → fix → ship
- `/batch` integration: `--delegate` flag internally leverages `/batch`

---

## Task Management Mode

**Purpose**: Hierarchical organization and persistent memory for complex multi-step tasks

**Triggers**:
- >3-step tasks
- Multi-file/directory scope
- Complex dependencies required
- Keywords: 다듬어, 개선해, 정리해, polish, refine

**Task Hierarchy**:
```
📋 Plan → 🎯 Phase → 📦 Task → ✓ Todo
```

**Memory Operations**:
```
Session Start: list_memories() → read_memory() → Resume
During: write_memory() + TodoWrite parallel
Checkpoint: Save state every 30min
End: think_about_whether_you_are_done() → session_summary
```

**Tool Selection**:
| Task Type | Tool | Memory Key |
|-----------|------|------------|
| Analysis | Sequential | "analysis_results" |
| Implementation | MultiEdit | "code_changes" |
| UI Components | Magic | "ui_components" |
| Testing | Playwright | "test_results" |

---

## Token Efficiency Mode

**Purpose**: Symbol-enhanced communication for compressed clarity and efficient token usage

**Triggers**: Context >75% | `--uc`, `--ultracompressed` | Large-scale tasks

**Symbol Systems**:

| Symbol | Meaning | Example |
|--------|---------|---------|
| → | leads to | `auth.js:45 → 🛡️ risk` |
| ⇒ | transforms | `input ⇒ validated` |
| » | sequence | `build » test » deploy` |
| ∴ | therefore | `tests ❌ ∴ broken` |
| ∵ | because | `slow ∵ O(n²)` |

| Symbol | Status |
|--------|--------|
| ✅ | completed |
| ❌ | failed |
| ⚠️ | warning |
| 🔄 | in progress |
| ⏳ | pending |

| Symbol | Domain |
|--------|--------|
| ⚡ | Performance |
| 🛡️ | Security |
| 🔍 | Analysis |
| 🏗️ | Architecture |

**Abbreviations**: `cfg` config • `impl` implementation • `perf` performance • `deps` dependencies • `val` validation

**Target**: 30-50% token reduction, ≥95% information quality maintained

---

## Business Panel Mode

**Purpose**: Multi-expert business analysis with adaptive interaction strategies

**Trigger**: `/sc:business-panel`

**Note**: Details in BUSINESS_PANEL_*.md files (optional loading)

**Phases**:
1. **DISCUSSION**: Collaborative multi-perspective analysis
2. **DEBATE**: Structured objection and challenge
3. **SOCRATIC**: Question-driven exploration

**Experts**: Christensen, Porter, Drucker, Godin, Kim/Mauborgne, Collins, Taleb, Meadows, Doumont

---

## Harness Mode (v2.0)

**Purpose**: Agent drives the full implementation; engineer focuses on intent, environment design, and feedback

**Triggers**: `--harness` | "에이전트한테 맡겨", "전부 자동으로" | Delegating large-scale/repetitive implementation

**Workflow**: INTENT → SCAFFOLD → TEAM(optional) → IMPLEMENT → VERIFY → DELIVER

| Phase | Owner | Tools | Isolation |
|-------|-------|-------|-----------|
| INTENT | Engineer | - | - |
| SCAFFOLD | Agent (**Phase Gate: user approval required**) | Read, Grep | - |
| TEAM | Team Lead (when Agent Teams enabled) | Agent Teams API | - |
| IMPLEMENT | harness-worker / team-implementer | Write, Edit, Bash | **worktree** |
| VERIFY | team-reviewer / Two-Stage Review | Read, Grep, Bash | - |
| DELIVER | Converge (merge + final check) | Git | - |

**Agent Teams Integration** (experimental):
- Enabled when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set
- Team Lead autonomously spawns team members during the TEAM phase
- Each member works independently in a worktree-isolated environment
- Falls back to existing Subagent pattern when disabled

**Team Composition Examples**:
```
Harness Team:
  Lead: orchestrator
  ├─ team-implementer (worktree) × N
  ├─ team-reviewer (read-only)
  └─ quality-engineer (testing)

Bugfix Team:
  Lead: root-cause-analyst
  ├─ team-implementer (worktree, skills: tdd)
  └─ team-reviewer
```

**Safety**: Scope Lock | Struggle Escalation (Circuit Breaker: auto-stop after 3 failures) | No Silent Decisions | Incremental Delivery

**Dependency Flow**: `Types → Config → Domain → Service → Runtime → UI` (reverse import warning)

**GC**: Suggest `codebase-gc` at session end (dead code, imports, doc-code sync, test gaps)

**Combinations**: `--orchestrate` (parallel) | `--safe-mode` (approve every phase) | `--think-hard` (deep analysis) | `--uc` (compressed)

Details: `optional/MODE_Harness.md`

---

## Progressive Context Loading

Loads context incrementally in conjunction with difficulty assessment (Step 0):

| Layer | Tokens | Difficulty | Triggers | Use Case |
|-------|--------|------------|----------|----------|
| 0 | 150 | — | Always | Bootstrap |
| 1 | 500-800 | — | Progress, status | Status check |
| 2 | 500-1K | Simple | Typos, renames | Small changes |
| 3 | 3-4.5K | Medium | Bugs, fixes, refactoring | Related file analysis |
| 4 | 8-12K | Complex | Features, architecture | System understanding |
| 5 | 20-50K | Complex+ | Redesign, migration | External references |

**Resource Loading by Difficulty**:
- **Simple**: Reference RULES.md essentials only, no optional/ loading needed
- **Medium**: RULES.md + selectively load 1-2 relevant optional/ files
- **Complex**: RULES.md + REASONING_TEMPLATES.md + CONTEXT_BUDGET.md

**Key Insight**: Prevention (confidence check) saves more tokens than optimization
**Details**: See `optional/CONTEXT_BUDGET.md`
