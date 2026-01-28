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

요청 복잡도에 따라 컨텍스트를 점진적으로 로드하여 토큰 효율성 극대화:

```yaml
Layer 0: Bootstrap (150 tokens) - 항상 활성
  - 시간 인식 + 레포 감지 + 세션 초기화

Layer 1: Minimal (500-800 tokens)
  - Triggers: "progress", "status", "update"
  - 간단한 상태 확인, 진행 보고

Layer 2: Target (500-1K tokens)
  - Triggers: "typo", "rename", "comment"
  - 단일 파일 작은 변경

Layer 3: Related (3-4.5K tokens)
  - Triggers: "bug", "fix", "refactor"
  - 관련 파일들 분석 필요

Layer 4: System (8-12K tokens)
  - Triggers: "feature", "architecture"
  - 시스템 전체 이해 필요
  - 사용자 확인 권장

Layer 5: External (20-50K tokens)
  - Triggers: "redesign", "migration"
  - 외부 문서/API 참조 필요
  - WARNING 표시 필수
```

### Intent Classification

```python
def classify_intent(request: str) -> Layer:
    ultra_light = ["progress", "status", "update", "check"]
    light = ["typo", "rename", "comment", "format"]
    medium = ["bug", "fix", "refactor", "improve"]
    heavy = ["feature", "implement", "add", "create"]
    ultra_heavy = ["redesign", "migration", "rewrite", "overhaul"]

    # 키워드 매칭으로 적절한 레이어 결정
    # → 최소 필요 컨텍스트만 로드
```

### Token Budget Management

| 작업 유형 | 일반 토큰 | 최적화 후 | 절약률 |
|----------|----------|----------|--------|
| 오타 수정 | 200-500 | 150-200 | 60% |
| 버그 수정 | 2,000-5,000 | 1,000-2,000 | 50% |
| 기능 추가 | 10,000-50,000 | 5,000-15,000 | 60% |
| 잘못된 방향 | 50,000+ | 100-200 (방지) | 99%+ |

**핵심 인사이트**: 예방(confidence check)이 최적화보다 더 많은 토큰 절약