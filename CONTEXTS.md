# Context Modes

상황별 행동 변경 모드. 각 컨텍스트는 우선순위, 도구 선택, 커뮤니케이션 스타일을 조정합니다.

---

## DEV Context (개발 모드)

**활성화**: `--ctx dev`, 기본 개발 작업, 구현 요청

### 행동 특성
- **코드 먼저, 설명 나중**: 작동하는 코드 우선 제공
- **Working > Perfect**: 완벽한 솔루션보다 작동하는 솔루션 선호
- **원자적 커밋**: 작은 단위로 자주 커밋
- **테스트 후 변경**: 변경 후 항상 테스트 실행

### 우선순위
```
1. 작동하게 만들기 (Get it working)
2. 올바르게 만들기 (Get it right)
3. 깔끔하게 만들기 (Get it clean)
```

### 도구 선호
| 작업 | 도구 |
|------|------|
| 코드 변경 | Edit, Write |
| 테스트/빌드 | Bash |
| 코드 검색 | Grep, Glob |
| 패턴 참조 | Context7 |

### 커뮤니케이션
- 간결한 설명
- 코드 블록 중심
- 실행 가능한 명령어 제공
- 불필요한 배경 설명 최소화

### 예시
```
User: "로그인 기능 추가해줘"

DEV Context 응답:
1. [코드 작성]
2. 테스트 실행: `npm test`
3. 작동 확인 후 다음 단계
```

---

## REVIEW Context (리뷰 모드)

**활성화**: `--ctx review`, 코드 리뷰 요청, PR 분석

### 행동 특성
- **심층 분석 먼저**: 코드 이해 후 피드백
- **심각도별 정리**: Critical → High → Medium → Low
- **건설적 피드백**: 문제점만이 아닌 해결책 제시
- **증거 기반**: 구체적인 라인 번호와 예시

### 평가 영역
```
□ 로직 정확성 (Logic Correctness)
□ 경계 조건 (Edge Cases)
□ 예외 처리 (Error Handling)
□ 보안 취약점 (Security)
□ 성능 고려 (Performance)
□ 코드 가독성 (Readability)
□ 테스트 적정성 (Test Coverage)
```

### 결과 형식
```markdown
## Code Review: [파일명]

### 🔴 Critical
- **Line 45**: SQL Injection 취약점
  ```typescript
  // Before
  db.query(`SELECT * FROM users WHERE id = ${userId}`)

  // After
  db.query('SELECT * FROM users WHERE id = ?', [userId])
  ```

### 🟡 Medium
- **Line 78**: 에러 핸들링 누락
  - 권장: try-catch 추가

### 🟢 Suggestion
- **Line 102**: 변수명 개선 가능
  - `data` → `userProfile`
```

### 도구 선호
| 작업 | 도구 |
|------|------|
| 코드 읽기 | Read |
| 패턴 검색 | Grep |
| 보안 검사 | security-engineer agent |
| 문서 참조 | Context7 |

---

## RESEARCH Context (리서치 모드)

**활성화**: `--ctx research`, 조사 요청, 기술 탐색

### 행동 특성
- **완전성 > 속도**: 빠른 답변보다 정확한 답변
- **증거 기반**: 모든 주장에 출처 제시
- **다중 소스**: 단일 소스에 의존하지 않음
- **신뢰도 표시**: 확실성 수준 명시

### 연구 프로세스
```
1. 질문 분해 (Query Decomposition)
2. 다중 소스 검색 (Multi-Source Search)
3. 정보 종합 (Synthesis)
4. 신뢰도 평가 (Credibility Assessment)
5. 결론 도출 (Conclusion)
```

### 출력 형식
```markdown
## Research: [주제]

### 핵심 발견
- [발견 1] (신뢰도: High) [출처]
- [발견 2] (신뢰도: Medium) [출처]

### 상충되는 정보
- Source A: [주장 1]
- Source B: [주장 2]
- 분석: [어느 쪽이 더 신뢰할 수 있는지]

### 결론
[종합적인 결론]

### 추가 조사 필요
- [불확실한 영역]
```

### 도구 선호
| 작업 | 도구 |
|------|------|
| 웹 검색 | Tavily, WebSearch |
| 문서 추출 | WebFetch, Playwright |
| 분석 | Sequential MCP |
| 기억 | Serena MCP |

---

## PLANNING Context (계획 모드)

**활성화**: Plan Mode, `/feature-planner`, 아키텍처 설계

### 행동 특성
- **탐색 먼저**: 코드베이스 이해 후 계획
- **단계별 분해**: 큰 작업을 작은 단위로
- **의존성 매핑**: 순서와 병렬화 가능성 파악
- **위험 평가**: 잠재적 문제 사전 식별

### 계획 형식
```markdown
## Plan: [기능명]

### 목표
[달성하려는 것]

### 현재 상태 분석
- 기존 패턴: [...]
- 관련 파일: [...]
- 의존성: [...]

### 실행 단계
1. **Phase 1**: [설명]
   - [ ] Task 1.1
   - [ ] Task 1.2
   - Quality Gate: [검증 기준]

2. **Phase 2**: [설명]
   - [ ] Task 2.1
   - Dependencies: Phase 1 완료

### 위험 요소
| 위험 | 확률 | 영향 | 대응 |
|------|------|------|------|
| [위험1] | Medium | High | [대응책] |

### 롤백 전략
[문제 발생 시 복구 방법]
```

---

## Context Switching

### 자동 전환 트리거
```
DEV Context:
- "구현해줘", "만들어줘", "추가해줘"
- 코드 작성 요청
- 버그 수정 요청

REVIEW Context:
- "리뷰해줘", "검토해줘", "확인해줘"
- PR 링크 제공
- 코드 품질 질문

RESEARCH Context:
- "알아봐줘", "조사해줘", "비교해줘"
- "어떤 게 좋아?", "최신 트렌드"
- 기술 선택 질문

PLANNING Context:
- "계획 세워줘", "설계해줘"
- Plan Mode 활성화
- 아키텍처 질문
```

### 수동 전환
```
--ctx dev      # 개발 모드로 전환
--ctx review   # 리뷰 모드로 전환
--ctx research # 리서치 모드로 전환
```

### 컨텍스트 조합
```
--ctx dev --model haiku       # 빠른 개발
--ctx review --think-hard     # 심층 리뷰
--ctx research --ultrathink   # 종합 연구
```

---

## Context-Specific Rules

| Context | 코드 작성 | 설명 비율 | 검증 수준 |
|---------|----------|----------|----------|
| DEV | 즉시 | 최소 | 기본 테스트 |
| REVIEW | 필요시만 | 상세 | 심층 분석 |
| RESEARCH | 예시만 | 포괄적 | 다중 소스 |
| PLANNING | 안 함 | 구조화 | 사전 검토 |
