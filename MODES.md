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
| **Harness** | 에이전트 주도 구현 | "에이전트한테 맡겨", "전부 자동으로" | `--harness` |

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

**Questioning Principles**:
- **Questions Reveal Consequences**: 단순 정보 수집이 아닌, 아키텍처/비용/복잡도 결정을 드러내는 질문
- **Trade-off 명시**: 선택지마다 장단점 표로 제시 (Option A: +속도 -복잡도 형식)
- **Default 제공**: 사용자 미응답 시 진행 가능한 합리적 기본값과 근거 제시

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

**Triggers**: 다중 도구 작업 조율 | 리소스 >75% | 병렬 실행 기회 (>3 파일)

**Pipeline**: CLARIFY (4×4 AskUserQuestion) → PARALLELIZE (dependency analysis) → EXECUTE (`run_in_background=True`) → SYNTHESIZE (merge results)

**4×4 Strategy**: 4 questions (max) × 4 options per question. Vague scope → ask. Clear request → execute directly.

**Parallelization**: File/data dependency → Sequential | Logical independence → Parallel

**Progress Communication**: Absorb complexity, radiate simplicity
- Hide: pattern names, agent IDs, retry counts, internal state
- Show: progress phase, deliverables, next phase, final results

**Resource Zones**: 🟢 0-75% full | 🟡 75-85% efficiency | 🔴 85%+ essential only

**Agent Chaining**: Feature (planner→tdd→reviewer→security) | Bugfix (root-cause→tdd→reviewer) | Refactor (architect→reviewer→tdd)

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

## Harness Mode

**Purpose**: 에이전트가 전체 구현을 주도하고, 엔지니어는 의도 명시/환경 설계/피드백에 집중

**Triggers**: `--harness` | "에이전트한테 맡겨", "전부 자동으로" | 대규모/반복 구현 위임

**Workflow**: INTENT (엔지니어) → SCAFFOLD (에이전트, **Phase Gate: 사용자 확인 필수**) → IMPLEMENT (에이전트 자율) → VERIFY (Two-Stage Review) → DELIVER (합류)

**Safety**: Scope Lock | Struggle Escalation (3회 실패 → Report) | No Silent Decisions | Incremental Delivery

**Dependency Flow**: `Types → Config → Domain → Service → Runtime → UI` (역방향 import 경고)

**GC**: 세션 종료 시 `codebase-gc` 제안 (dead code, import, doc-code sync, test gaps)

**결합**: `--orchestrate` (병렬) | `--safe-mode` (전 Phase 확인) | `--think-hard` (깊은 분석) | `--uc` (압축)

Details: `optional/MODE_Harness.md`

---

## Progressive Context Loading

난이도 평가(Step 0)와 연동하여 컨텍스트를 점진적으로 로딩:

| Layer | Tokens | Difficulty | Triggers | Use Case |
|-------|--------|------------|----------|----------|
| 0 | 150 | — | 항상 | Bootstrap |
| 1 | 500-800 | — | 진행상황, 상태 | 상태 확인 |
| 2 | 500-1K | Simple | 오타, 이름변경 | 소규모 변경 |
| 3 | 3-4.5K | Medium | 버그, 수정, 리팩토링 | 관련 파일 분석 |
| 4 | 8-12K | Complex | 기능, 아키텍처 | 시스템 이해 |
| 5 | 20-50K | Complex+ | 재설계, 마이그레이션 | 외부 참조 |

**난이도별 리소스 로딩**:
- **Simple**: RULES.md 핵심만 참조, optional/ 로딩 불필요
- **Medium**: RULES.md + 관련 optional/ 1-2개 선택적 로딩
- **Complex**: RULES.md + REASONING_TEMPLATES.md + CONTEXT_BUDGET.md 로딩

**핵심**: 예방(confidence check)이 최적화보다 토큰을 더 절약함
**상세**: `optional/CONTEXT_BUDGET.md` 참조
