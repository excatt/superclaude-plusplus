# Task Management Mode

**Purpose**: Hierarchical task organization with persistent memory for complex multi-step operations

## Activation Triggers
- Operations with >3 steps requiring coordination
- Multiple file/directory scope (>2 directories OR >3 files)
- Complex dependencies requiring phases
- Manual flags: `--task-manage`, `--delegate`
- Quality improvement requests: polish, refine, enhance

## Task Hierarchy with Memory

📋 **Plan** → write_memory("plan", goal_statement)
→ 🎯 **Phase** → write_memory("phase_X", milestone)
  → 📦 **Task** → write_memory("task_X.Y", deliverable)
    → ✓ **Todo** → TodoWrite + write_memory("todo_X.Y.Z", status)

## Memory Operations

### Session Start
```
1. list_memories() → Show existing task state
2. read_memory("current_plan") → Resume context
3. think_about_collected_information() → Understand where we left off
```

### During Execution
```
1. write_memory("task_2.1", "completed: auth middleware")
2. think_about_task_adherence() → Verify on track
3. Update TodoWrite status in parallel
4. write_memory("checkpoint", current_state) every 30min
```

### Session End
```
1. think_about_whether_you_are_done() → Assess completion
2. write_memory("session_summary", outcomes)
3. delete_memory() for completed temporary items
```

## Execution Pattern

1. **Load**: list_memories() → read_memory() → Resume state
2. **Plan**: Create hierarchy → write_memory() for each level  
3. **Track**: TodoWrite + memory updates in parallel
4. **Execute**: Update memories as tasks complete
5. **Checkpoint**: Periodic write_memory() for state preservation
6. **Complete**: Final memory update with outcomes

## Tool Selection

| Task Type | Primary Tool | Memory Key |
|-----------|-------------|------------|
| Analysis | Sequential MCP | "analysis_results" |
| Implementation | MultiEdit/Morphllm | "code_changes" |
| UI Components | Magic MCP | "ui_components" |
| Testing | Playwright MCP | "test_results" |
| Documentation | Context7 MCP | "doc_patterns" |

## Memory Schema

```
plan_[timestamp]: Overall goal statement
phase_[1-5]: Major milestone descriptions
task_[phase].[number]: Specific deliverable status
todo_[task].[number]: Atomic action completion
checkpoint_[timestamp]: Current state snapshot
blockers: Active impediments requiring attention
decisions: Key architectural/design choices made
```

## Examples

### Session 1: Start Authentication Task
```
list_memories() → Empty
write_memory("plan_auth", "Implement JWT authentication system")
write_memory("phase_1", "Analysis - security requirements review")
write_memory("task_1.1", "pending: Review existing auth patterns")
TodoWrite: Create 5 specific todos
Execute task 1.1 → write_memory("task_1.1", "completed: Found 3 patterns")
```

### Session 2: Resume After Interruption
```
list_memories() → Shows plan_auth, phase_1, task_1.1
read_memory("plan_auth") → "Implement JWT authentication system"
think_about_collected_information() → "Analysis complete, start implementation"
think_about_task_adherence() → "On track, moving to phase 2"
write_memory("phase_2", "Implementation - middleware and endpoints")
Continue with implementation tasks...
```

### Session 3: Completion Check
```
think_about_whether_you_are_done() → "Testing phase remains incomplete"
Complete remaining testing tasks
write_memory("outcome_auth", "Successfully implemented with 95% test coverage")
delete_memory("checkpoint_*") → Clean temporary states
write_memory("session_summary", "Auth system complete and validated")
```

## Token Efficiency Architecture

### 5-Layer Progressive Context Loading

Maximize token efficiency by progressively loading context based on request complexity:

```yaml
Layer 0: Bootstrap (150 tokens) - always active
  - Time awareness + repo detection + session init

Layer 1: Minimal (500-800 tokens)
  - Triggers: "progress", "status", "update"
  - Simple status checks, progress reports

Layer 2: Target (500-1K tokens)
  - Triggers: "typo", "rename", "comment"
  - Single-file small changes

Layer 3: Related (3-4.5K tokens)
  - Triggers: "bug", "fix", "refactor"
  - Related file analysis needed

Layer 4: System (8-12K tokens)
  - Triggers: "feature", "architecture"
  - Full system understanding needed
  - User confirmation recommended

Layer 5: External (20-50K tokens)
  - Triggers: "redesign", "migration"
  - External docs/API references needed
  - WARNING display required
```

### Intent Classification

```python
def classify_intent(request: str) -> Layer:
    ultra_light = ["progress", "status", "update", "check"]
    light = ["typo", "rename", "comment", "format"]
    medium = ["bug", "fix", "refactor", "improve"]
    heavy = ["feature", "implement", "add", "create"]
    ultra_heavy = ["redesign", "migration", "rewrite", "overhaul"]

    # Match keywords to determine appropriate layer
    # → Load only the minimum required context
```

### Token Budget Management

| Task Type | Baseline Tokens | After Optimization | Savings |
|-----------|-----------------|-------------------|---------|
| Typo fix | 200-500 | 150-200 | 60% |
| Bug fix | 2,000-5,000 | 1,000-2,000 | 50% |
| Feature add | 10,000-50,000 | 5,000-15,000 | 60% |
| Wrong direction | 50,000+ | 100-200 (prevented) | 99%+ |

**Key insight**: Prevention (confidence check) saves more tokens than optimization