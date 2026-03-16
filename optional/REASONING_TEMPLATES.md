# Reasoning Templates

구조화된 추론이 필요할 때 사용하는 빈칸 채우기 템플릿.
Medium 난이도에서 선택적, Complex 난이도에서 필수 적용.

---

## 1. Debugging Hypothesis Loop

버그 원인을 찾을 때 반복. 3회 반복 후 미해결 → `3+ Fixes Architecture Rule` 트리거.

```
=== Hypothesis #{N} ===

Observation: {에러 메시지, 증상, 재현 조건}
Hypothesis: "{현상}은 {의심 원인}에 의해 발생한다"
Verification: {검증 방법 — 코드 읽기, 로그, 테스트 등}
Result: {실제 확인된 사실}
Verdict: Correct / Incorrect

Correct → Fix step으로 이동
Incorrect → Hypothesis #{N+1} 작성
```

**Example**:
```
=== Hypothesis #1 ===
Observation: "Cannot read property 'map' of undefined" in TodoList
Hypothesis: "API 응답 전 todos가 undefined 상태에서 .map() 호출"
Verification: TodoList 컴포넌트의 useState 초기값 확인
Result: useState()에 초기값 미설정 → undefined
Verdict: Correct → todos 기본값을 []로 설정
```

**SC++ 연동**: `RULES.md` Failure Investigation의 Phase 3 (Hypothesis)에서 이 템플릿 사용.

---

## 2. Architecture Decision Matrix

기술 선택 또는 설계 결정이 필요할 때. Assumption Transparency 규칙과 결합.

```
=== Decision: {결정할 사항} ===

Options:
  A: {옵션 A}
  B: {옵션 B}
  C: {옵션 C} (해당 시)

| Criterion              | A | B | C | Weight |
|------------------------|---|---|---|--------|
| Performance            |   |   |   | {H/M/L} |
| Implementation effort  |   |   |   | {H/M/L} |
| Existing code match    |   |   |   | {H/M/L} |
| Scalability            |   |   |   | {H/M/L} |
| Team/project familiarity |   |   |   | {H/M/L} |

Conclusion: {선택한 옵션}
Reason: {1-2줄 근거}
Trade-off: {포기하는 장점}
Reversibility: {되돌리기 쉬움 / 비용 큼 / 불가}
```

**Rule**: Weight가 H인 기준에서 최고점이 아닌 옵션 선택 시, 반드시 사유 명시.
**SC++ 연동**: Assumption Transparency — "No silent picks" 원칙 강화.

---

## 3. Cause-Effect Chain

복잡한 버그에서 실행 흐름을 단계별로 추적.

```
=== Execution Flow Trace ===

1. [Entry]      {file:function} — {입력값}
2. [Call]       {file:function} — {전달값}
3. [Process]    {file:function} — {변환/로직}
4. [Failure]    {file:function} — {예상과 다른 동작}
   - Expected: {기대 동작}
   - Actual:   {실제 동작}
   - Cause:    {왜 다른지}
5. [Result]     {에러 메시지 또는 잘못된 출력}
```

**SC++ 연동**: Failure Investigation Phase 1 (Root Cause)에서 이 템플릿으로 증거 수집.

---

## 4. Refactoring Judgment

코드 수정 중 "이것도 고칠까?" 판단. Change Scope Discipline 강화.

```
=== Refactoring Judgment ===

Issue found: {발견한 문제}
Relation to task: Directly related / Indirectly related / Unrelated

Directly related    → Fix it (현재 작업 범위)
Indirectly related  → Record in result, fix only if within scope
Unrelated           → Record only, never fix
```

**Litmus Test**: "Does every changed line trace directly to the user's request?"
**SC++ 연동**: Change Scope Discipline — "No drive-by refactoring" 원칙의 실행 도구.

---

## 5. Performance Bottleneck Analysis

"느리다" 보고에 대한 체계적 병목 분석.

```
=== Performance Bottleneck Analysis ===

Measurements:
  - Total response time:     {ms}
  - DB query time:           {ms} ({N} queries)
  - Business logic:          {ms}
  - Serialization/rendering: {ms}

Bottleneck: {가장 시간 소요 단계}
Cause: {N+1 query / heavy computation / large payload / missing index / ...}
Solution: {구체적 수정 방법}
Expected improvement: {X}ms → {Y}ms
Verification: {벤치마크 명령어 또는 테스트}
```

**Rule**: "느리다"는 Weak Criteria → 먼저 측정, 목표 수치 정의, 달성 후 완료.
**SC++ 연동**: Goal Definition Protocol — "Improve performance" → "Measure → Target → Achieve".

---

## 6. Requirement Decomposition

모호한 요청을 4요소 구조로 분해. Goal Definition Protocol의 실행 도구.

```
=== Requirement Decomposition ===

Original request: "{사용자 원문}"

1. Goal:        {무엇을 만들/바꿀/고칠 것인가}
2. Context:     {관련 파일, 에러, 기존 패턴}
3. Constraints: {아키텍처 규칙, 의존성 제약, 프로젝트 컨벤션}
4. Done When:   {검증 가능한 완료 기준}

Missing elements:
  - [ ] Goal: {충분 / "무엇을 구체적으로?" 질문 필요}
  - [ ] Context: {코드베이스 탐색으로 확보 / 사용자에게 질문 필요}
  - [ ] Constraints: {CLAUDE.md, CONVENTIONS.md에서 확인 / 없음}
  - [ ] Done When: {테스트 기준 제안 가능 / 사용자 확인 필요}
```

**Anti-patterns**:
- Goal만으로 구현 시작 (constraints, done-when 없이)
- 사용자가 명시하지 않은 constraints 발명
- "잘 작동하면 됨" 같은 모호한 done-when 수용

**SC++ 연동**: Goal Definition Protocol + Assumption Transparency의 통합 실행 도구.

---

## Usage Rules

1. **언제**: Medium 난이도에서 선택적, Complex에서 필수
2. **어디에**: 에이전트 결과 보고에 추론 과정 포함
3. **빈칸 못 채울 때**: 해당 정보 먼저 수집 (코드 읽기, 테스트, 로그)
4. **3회 반복 후 미해결**: `Status: blocked` + 추론 과정 포함하여 사용자 보고
