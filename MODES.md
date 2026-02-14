# Behavioral Modes

상황별 행동 변경 모드. 각 모드는 사고방식, 우선순위, 커뮤니케이션 스타일을 조정합니다.

---

## Mode Quick Reference

| Mode | Purpose | Trigger | Flag |
|------|---------|---------|------|
| **Brainstorming** | 요구사항 탐색 | "maybe", "생각중인데" | `--brainstorm` |
| **Deep Research** | 체계적 조사 | `/sc:research`, "조사해줘" | `--research` |
| **Introspection** | 메타인지 분석 | 에러 복구, 자기 분석 | `--introspect` |
| **Orchestration** | 도구 최적화 | 다중 도구, 병렬 실행 | `--orchestrate` |
| **Task Management** | 계층적 작업 관리 | >3단계 작업, 복잡한 스코프 | `--task-manage` |
| **Token Efficiency** | 압축된 커뮤니케이션 | 컨텍스트 >75% | `--uc` |
| **Business Panel** | 전문가 패널 분석 | `/sc:business-panel` | - |

---

## Brainstorming Mode

**Purpose**: 협업적 요구사항 탐색 및 창의적 문제 해결

**Triggers**:
- 모호한 요청: "뭔가 만들어볼까...", "생각중인데..."
- 키워드: brainstorm, 탐색, 논의, 고민, 잘 모르겠는데
- 불확실성: "maybe", "아마", "혹시", "할 수 있을까"

**Behavior**:
- 🤔 소크라틱 대화로 숨겨진 요구사항 발견
- 📝 인사이트를 구조화된 요구사항 브리프로 합성
- ✅ 가정 없이 사용자가 방향 결정하도록 유도

---

## Deep Research Mode

**Purpose**: 체계적 조사 및 증거 기반 추론

**Triggers**: `/sc:research` | "조사해줘", "알아봐줘", "탐색" | 최신 정보 필요

**Behavior**:
- 체계적 > 즉흥: 방법론적으로 조사 구조화
- 증거 > 가정: 모든 주장 검증
- 신뢰도 수준 선행, 인라인 인용 제공
- 항상 조사 계획 생성, 병렬 작업 기본

**Integration**: auto-activate deep-research-agent, Tavily, Sequential

---

## Introspection Mode

**Purpose**: 자기 성찰 및 추론 최적화를 위한 메타인지 분석

**Triggers**:
- 자기 분석 요청: "내 추론 분석해봐"
- 에러 복구: 예상치 못한 결과
- 패턴 인식 필요

**Behavior**:
- 🧠 의사결정 로직 및 추론 체인 분석
- 🔄 반복 패턴 감지 및 최적화 기회 식별
- 💡 지속적 개선을 위한 인사이트 추출
- 마커 사용: 🤔 🎯 ⚡ 📊 💡

---

## Orchestration Mode

**Purpose**: 최적의 작업 라우팅 및 리소스 효율을 위한 지능적 도구 선택

**Triggers**:
- 다중 도구 작업 조율
- 성능 제약 (리소스 >75%)
- 병렬 실행 기회 (>3 파일)

### Orchestration Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: CLARIFY (AskUserQuestion)                          │
│  ↓ Clarify requirements - 4×4 strategy                     │
├─────────────────────────────────────────────────────────────┤
│  Step 2: PARALLELIZE (dependency analysis)                  │
│  ↓ Separate independent vs dependent tasks                 │
├─────────────────────────────────────────────────────────────┤
│  Step 3: EXECUTE (parallel spawn)                           │
│  ↓ run_in_background=True                                   │
├─────────────────────────────────────────────────────────────┤
│  Step 4: SYNTHESIZE (merge results)                         │
│  → Integrate agent outputs, deliver to user                 │
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Clarify (AskUserQuestion 4×4)

On vague requests, **maximize utilization** to define scope:

| Dimension | Question Example | Options Example |
|-----------|----------|-------------|
| **Scope** | "What scope do you want?" | Production / MVP / Prototype / Design only |
| **Priority** | "What matters most?" | UX / Performance / Maintainability / Ship speed |
| **Constraints** | "Any technical constraints?" | Existing patterns / Specific tech / Backward compat / Free |
| **Edge cases** | "Edge case handling?" | Comprehensive / Happy path / Fail fast / Graceful |

**4×4 Strategy**:
- **4 questions** (max) - Explore all relevant dimensions
- **4 options** per question - Provide diverse choices
- **Rich descriptions** - Explain trade-offs, examples, implications (no char limit)
- **multiSelect: true** - When multiple selections allowed

**When to ask**: Vague scope, multiple valid paths, user preference matters
**When NOT to ask**: Clear request, follow-up work, single path obvious → Execute directly

### Step 2: Parallelize (dependency analysis)

Separate tasks based on clarified requirements:

```
Task Analysis
├─ Independent tasks (parallel group)
│   ├─ Task A ──┐
│   ├─ Task B ──┼── Execute concurrently
│   └─ Task C ──┘
│
└─ Dependent tasks (sequential chain)
    Task D → Task E → Task F
```

**Analysis Criteria**:
- File dependency: Same file modifications → Sequential
- Data dependency: Output needed as input → Sequential
- Logical independence: Unrelated work → Parallel

### Step 3: Execute (parallel spawn)

**Required Rules**:
```python
# ✅ ALWAYS
Task(..., run_in_background=True)

# ❌ NEVER (blocking)
Task(...)  # no run_in_background
```

**Spawn Patterns**:
| Complexity | Agent Count | Example |
|--------|------------|------|
| Simple query/edit | 1-2 | Typo fix + doc review |
| Multi-faceted question | 2-3 | Function analysis + usage + tests |
| Full feature | 4+ | Design + implement + test + docs |

### Step 4: Synthesize (merge results)

On agent completion:
1. Read output files (for synthesis)
2. Integrate and verify results
3. Deliver clear summary to user

### Progress Communication

**Core Principle**: Absorb complexity, radiate simplicity

**Communication Rules**:
| Rule | Description |
|------|------|
| **Celebrate progress** | Visual feedback at each milestone |
| **Never expose machinery** | Hide internal mechanisms |
| **Natural language** | Use natural language over technical terms |

**상황별 표현**:
| 상황 | ❌ 기술적 표현 | ✅ 자연스러운 표현 |
|------|---------------|---------------|
| 작업 시작 | "에이전트 3개 스폰 중..." | "시작합니다. 분석해볼게요..." |
| 병렬 탐색 | "Fan-out 패턴 실행 중..." | "여러 각도에서 살펴보고 있어요..." |
| 진행 중 | "Agent-2 처리 중..." | "세부 사항 작업하고 있어요..." |
| 재시도 | "프롬프트 조정 후 재시도..." | "다른 접근법으로 시도해볼게요..." |
| 결과 전달 | "출력 집계 중..." | 통합된 깔끔한 결과물 |

**Milestone Box** (on phase completion):
```
┌────────────────────────────────────────┐
│  ✓ Phase 1 Complete                    │
│                                        │
│  Database schema ready                 │
│  3 tables created, relationships set   │
│                                        │
│  Moving to Phase 2: API Routes         │
└────────────────────────────────────────┘
```

**Hide This** (internal machinery):
- Pattern names (Fan-out, Map-reduce, etc.)
- Agent count, IDs
- TaskCreate IDs, internal state
- Retry counts, failure details

**Show This** (user value):
- Current progress phase
- Completed deliverables
- Next phase preview
- Final results

---

**Tool Selection Matrix**:
| Task | Best Tool | Alternative |
|------|-----------|-------------|
| UI components | Magic | Manual coding |
| Deep analysis | Sequential | Native |
| Symbol operations | Serena | Manual search |
| Pattern editing | Morphllm | Individual edits |
| Browser testing | Playwright | Unit tests |

**Resource Zones**:
- 🟢 0-75%: Full capabilities
- 🟡 75-85%: Efficiency mode, abbreviate
- 🔴 85%+: Essential tasks only, minimal output

**Agent Chaining**:
| Workflow | Chain |
|----------|-------|
| Feature | planner → tdd-guide → code-reviewer → security |
| Bugfix | root-cause → tdd-guide → code-reviewer |
| Refactor | architect → code-reviewer → tdd-guide |

---

## Task Management Mode

**Purpose**: 복잡한 다단계 작업을 위한 계층적 조직 및 영속 메모리

**Triggers**:
- >3단계 작업
- 다중 파일/디렉토리 스코프
- 복잡한 의존성 필요
- 키워드: 다듬어, 개선해, 정리해, polish, refine

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

**Purpose**: 압축된 명확성과 효율적 토큰 사용을 위한 심볼 강화 커뮤니케이션

**Triggers**: 컨텍스트 >75% | `--uc`, `--ultracompressed` | 대규모 작업

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

**Purpose**: 적응적 상호작용 전략을 활용한 다중 전문가 비즈니스 분석

**Trigger**: `/sc:business-panel`

**Note**: Details in BUSINESS_PANEL_*.md files (optional loading)

**Phases**:
1. **DISCUSSION**: Collaborative multi-perspective analysis
2. **DEBATE**: Structured objection and challenge
3. **SOCRATIC**: Question-driven exploration

**Experts**: Christensen, Porter, Drucker, Godin, Kim/Mauborgne, Collins, Taleb, Meadows, Doumont

---

## Progressive Context Loading

요청 복잡도에 따른 점진적 컨텍스트 로딩:

| Layer | Tokens | Triggers | Use Case |
|-------|--------|----------|----------|
| 0 | 150 | 항상 | Bootstrap |
| 1 | 500-800 | 진행상황, 상태 | 상태 확인 |
| 2 | 500-1K | 오타, 이름변경 | 소규모 변경 |
| 3 | 3-4.5K | 버그, 수정, 리팩토링 | 관련 파일 분석 |
| 4 | 8-12K | 기능, 아키텍처 | 시스템 이해 |
| 5 | 20-50K | 재설계, 마이그레이션 | 외부 참조 |

**핵심**: 예방(confidence check)이 최적화보다 토큰을 더 절약함
