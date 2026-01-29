# Behavioral Modes

상황별 행동 변경 모드. 각 모드는 사고방식, 우선순위, 커뮤니케이션 스타일을 조정합니다.

---

## Mode Quick Reference

| Mode | Purpose | Trigger | Flag |
|------|---------|---------|------|
| **Brainstorming** | 요구사항 탐색 | "maybe", "thinking about" | `--brainstorm` |
| **Deep Research** | 체계적 조사 | `/sc:research`, "investigate" | `--research` |
| **Introspection** | 메타인지 분석 | 에러 복구, 자기 분석 | `--introspect` |
| **Orchestration** | 도구 최적화 | 다중 도구, 병렬 실행 | `--orchestrate` |
| **Task Management** | 계층적 작업 관리 | >3단계 작업, 복잡한 스코프 | `--task-manage` |
| **Token Efficiency** | 압축된 커뮤니케이션 | 컨텍스트 >75% | `--uc` |
| **Business Panel** | 전문가 패널 분석 | `/sc:business-panel` | - |

---

## Brainstorming Mode

**Purpose**: 협업적 요구사항 탐색 및 창의적 문제 해결

**Triggers**:
- 모호한 요청: "build something...", "thinking about..."
- 키워드: brainstorm, explore, discuss, figure out, not sure
- 불확실성: "maybe", "possibly", "could we"

**Behavior**:
- 🤔 소크라틱 대화로 숨겨진 요구사항 발견
- 📝 인사이트를 구조화된 요구사항 브리프로 합성
- ✅ 가정 없이 사용자가 방향 결정하도록 유도

---

## Deep Research Mode

**Purpose**: 체계적 조사 및 증거 기반 추론

**Triggers**: `/sc:research` | "investigate", "explore", "discover" | 최신 정보 필요

**Behavior**:
- 체계적 > 캐주얼: 조사를 방법론적으로 구조화
- 증거 > 가정: 모든 주장에 검증 필요
- 신뢰도 수준 선행, 인라인 인용 제공
- 항상 조사 계획 생성, 병렬 작업 기본

**Integration**: deep-research-agent, Tavily, Sequential 자동 활성화

---

## Introspection Mode

**Purpose**: 자기 성찰 및 추론 최적화를 위한 메타인지 분석

**Triggers**:
- 자기 분석 요청: "analyze my reasoning"
- 에러 복구: 예상치 못한 결과
- 패턴 인식 필요

**Behavior**:
- 🧠 의사결정 로직 및 추론 체인 분석
- 🔄 반복 패턴 감지 및 최적화 기회 식별
- 💡 지속적 개선을 위한 인사이트 추출
- 마커 사용: 🤔 🎯 ⚡ 📊 💡

---

## Orchestration Mode

**Purpose**: 최적 작업 라우팅 및 리소스 효율성을 위한 지능적 도구 선택

**Triggers**:
- 다중 도구 작업 조율 필요
- 성능 제약 (리소스 >75%)
- 병렬 실행 기회 (>3 파일)

**Tool Selection Matrix**:
| Task | Best Tool | Alternative |
|------|-----------|-------------|
| UI 컴포넌트 | Magic | 수동 코딩 |
| 심층 분석 | Sequential | 네이티브 |
| 심볼 작업 | Serena | 수동 검색 |
| 패턴 편집 | Morphllm | 개별 편집 |
| 브라우저 테스트 | Playwright | 유닛 테스트 |

**Resource Zones**:
- 🟢 0-75%: 전체 기능
- 🟡 75-85%: 효율 모드, 축약
- 🔴 85%+: 필수 작업만, 최소 출력

**Agent Chaining**:
| Workflow | Chain |
|----------|-------|
| Feature | planner → tdd-guide → code-reviewer → security |
| Bugfix | root-cause → tdd-guide → code-reviewer |
| Refactor | architect → code-reviewer → tdd-guide |

---

## Task Management Mode

**Purpose**: 복잡한 다단계 작업을 위한 계층적 조직 및 지속적 메모리

**Triggers**:
- >3단계 작업
- 다중 파일/디렉토리 스코프
- 복잡한 의존성 필요
- 키워드: polish, refine, enhance

**Task Hierarchy**:
```
📋 Plan → 🎯 Phase → 📦 Task → ✓ Todo
```

**Memory Operations**:
```
Session Start: list_memories() → read_memory() → Resume
During: write_memory() + TodoWrite 병렬
Checkpoint: 30분마다 상태 저장
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

**Purpose**: 압축된 명확성 및 효율적 토큰 사용을 위한 심볼 강화 커뮤니케이션

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

**Target**: 30-50% 토큰 감소, ≥95% 정보 품질 유지

---

## Business Panel Mode

**Purpose**: 적응형 상호작용 전략을 갖춘 다중 전문가 비즈니스 분석

**Trigger**: `/sc:business-panel`

**Note**: 상세 내용은 BUSINESS_PANEL_*.md 파일 참조 (선택적 로딩)

**Phases**:
1. **DISCUSSION**: 협업적 다관점 분석
2. **DEBATE**: 구조화된 이의 제기 및 도전
3. **SOCRATIC**: 질문 주도 탐색

**Experts**: Christensen, Porter, Drucker, Godin, Kim/Mauborgne, Collins, Taleb, Meadows, Doumont

---

## Progressive Context Loading

요청 복잡도에 따른 점진적 컨텍스트 로딩:

| Layer | Tokens | Triggers | Use Case |
|-------|--------|----------|----------|
| 0 | 150 | 항상 | Bootstrap |
| 1 | 500-800 | progress, status | 상태 확인 |
| 2 | 500-1K | typo, rename | 작은 변경 |
| 3 | 3-4.5K | bug, fix, refactor | 관련 파일 분석 |
| 4 | 8-12K | feature, architecture | 시스템 이해 |
| 5 | 20-50K | redesign, migration | 외부 참조 |

**핵심**: 예방(confidence check)이 최적화보다 더 많은 토큰 절약
