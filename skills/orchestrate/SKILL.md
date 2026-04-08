---
name: orchestrate
description: 에이전트 체이닝 워크플로우를 실행합니다. 복잡한 작업을 여러 전문 에이전트가 순차적으로 처리합니다.
user-invocable: true
argument-hint: "<workflow> <task-description>"
---

# Agent Chaining Workflow

에이전트를 순차적으로 연결하여 복잡한 작업을 체계적으로 처리합니다.

## Usage

```
/sc:orchestrate <workflow> <task-description>
/sc:orchestrate custom <agent1,agent2,agent3> <task-description>
```

## Predefined Workflows

### feature - 새 기능 개발
```
Chain: planner → tdd-guide → code-reviewer → security-reviewer

적용 상황:
- 새로운 기능 구현
- 다중 파일 변경이 필요한 작업
- 테스트와 보안이 중요한 기능
```

### bugfix - 버그 수정
```
Chain: root-cause-analyst → tdd-guide → code-reviewer

적용 상황:
- 원인 불명의 버그
- 회귀 버그
- 복잡한 상호작용 문제
```

### refactor - 리팩토링
```
Chain: system-architect → code-reviewer → quality-engineer

적용 상황:
- 코드 구조 개선
- 기술 부채 해소
- 아키텍처 변경
```

### security - 보안 검토
```
Chain: security-engineer → code-reviewer → system-architect

적용 상황:
- 인증/인가 기능
- 결제 처리
- 민감 데이터 처리
```

### custom - 커스텀 체인
```
/sc:orchestrate custom <agents> <task>

예시:
/sc:orchestrate custom "performance-engineer,code-reviewer" "API 응답 시간 최적화"
```

## Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│                    ORCHESTRATION                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Task Description]                                     │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐                                       │
│  │  Agent 1    │ ──→ Handoff Document                  │
│  │  (planner)  │                                       │
│  └─────────────┘                                       │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐                                       │
│  │  Agent 2    │ ──→ Handoff Document                  │
│  │ (tdd-guide) │                                       │
│  └─────────────┘                                       │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐                                       │
│  │  Agent 3    │ ──→ Handoff Document                  │
│  │ (reviewer)  │                                       │
│  └─────────────┘                                       │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐                                       │
│  │ Final Report│                                       │
│  └─────────────┘                                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Handoff Document

에이전트 간 전달되는 표준 문서:

```markdown
## Handoff: [Source Agent] → [Target Agent]

### Context
- Task: [작업 설명]
- Progress: [완료된 작업]
- Time Spent: [소요 시간]

### Findings
- [발견 사항 1]
- [발견 사항 2]

### Modified Files
| File | Changes |
|------|---------|
| `src/auth/login.ts` | 인증 로직 추가 |
| `tests/auth.test.ts` | 테스트 케이스 작성 |

### Open Questions
- [ ] [해결되지 않은 질문 1]
- [ ] [해결되지 않은 질문 2]

### Recommendations for Next Agent
- [권장사항 1]
- [권장사항 2]

### Quality Metrics
- Test Coverage: 85%
- Type Errors: 0
- Lint Errors: 0
```

## Final Report

워크플로우 완료 시 생성되는 최종 보고서:

```markdown
## Orchestration Report

### Summary
- Workflow: feature
- Task: 사용자 인증 시스템 구현
- Duration: 45 minutes
- Agents: 4

### Agent Summaries

#### 1. Planner
- Status: ✅ Complete
- Output: 5-phase implementation plan
- Key Decisions: JWT 기반 인증 선택

#### 2. TDD Guide
- Status: ✅ Complete
- Tests Written: 12
- Coverage: 87%

#### 3. Code Reviewer
- Status: ✅ Complete
- Issues Found: 3 (all resolved)
- Code Quality: A

#### 4. Security Reviewer
- Status: ✅ Complete
- Vulnerabilities: 0
- Recommendations: 2 implemented

### Changed Files
- `src/auth/login.ts` (new)
- `src/auth/middleware.ts` (new)
- `src/types/auth.ts` (new)
- `tests/auth.test.ts` (new)

### Test Results
- Total: 12
- Passed: 12
- Failed: 0
- Coverage: 87%

### Security Status
- Critical: 0
- High: 0
- Medium: 0
- Low: 0

### Recommendation
🚀 **SHIP** - Ready for PR

---
Alternatives:
- ⚠️ **NEEDS WORK** - Issues require attention
- 🚫 **BLOCKED** - Cannot proceed without resolution
```

## Examples

### Feature Development
```
/sc:orchestrate feature "소셜 로그인 기능 추가 (Google, GitHub)"
```

### Bug Fix
```
/sc:orchestrate bugfix "로그인 후 세션이 유지되지 않는 문제"
```

### Refactoring
```
/sc:orchestrate refactor "API 레이어를 Repository 패턴으로 분리"
```

### Security Review
```
/sc:orchestrate security "결제 처리 모듈 전체 보안 검토"
```

### Custom Workflow
```
/sc:orchestrate custom "performance-engineer,quality-engineer,technical-writer" "대시보드 페이지 최적화 및 문서화"
```

## Available Agents

| Agent | Specialty |
|-------|-----------|
| `planner` | 작업 계획 및 분해 |
| `system-architect` | 시스템 설계 |
| `backend-architect` | 백엔드 아키텍처 |
| `frontend-architect` | 프론트엔드 아키텍처 |
| `security-engineer` | 보안 분석 |
| `quality-engineer` | 품질 보증 |
| `performance-engineer` | 성능 최적화 |
| `root-cause-analyst` | 원인 분석 |
| `code-reviewer` | 코드 리뷰 |
| `technical-writer` | 문서화 |
| `tdd-guide` | 테스트 주도 개발 |

## Best Practices

1. **복잡한 작업에 사용**: 단순 작업은 직접 처리가 효율적
2. **항상 planner로 시작**: 복잡한 기능은 계획 먼저
3. **code-reviewer 포함**: 머지 전 항상 리뷰 단계 포함
4. **민감 기능은 security-reviewer**: 인증, 결제, 데이터 처리
5. **핸드오프 문서 검토**: 각 단계 결과 확인 후 진행

## Interruption Handling

워크플로우 중단 시:
1. 현재 에이전트 작업 저장
2. 핸드오프 문서 생성
3. 재시작 가능한 상태 유지

```
/sc:orchestrate resume  # 마지막 워크플로우 재개
```
