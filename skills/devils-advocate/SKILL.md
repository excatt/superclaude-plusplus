---
name: "devils-advocate"
description: "AI/사람의 결정, 계획, 코드, 설계를 구조화된 프레임워크로 도전하는 비판적 리뷰 레이어. Pre-mortem, Inversion, Socratic 질문을 활용하여 블라인드 스팟과 숨겨진 가정을 발견합니다."
user-invocable: true
---

# Devil's Advocate Skill

AI 생성 결과물과 의사결정에 대한 구조화된 비판적 리뷰를 수행합니다.

## Purpose

AI는 반박하지 않습니다. "그건 나쁜 아이디어야" 또는 "이 서비스가 다운되면 어떻게 되지?"라고 말하지 않습니다. 이 스킬은 **사고 자체를 도전**합니다 — 코드뿐만 아니라 계획, 아키텍처, 설계 결정 모두.

## When to Use

- 다른 스킬 실행 후 리뷰 레이어로 (e.g., `/architecture` → `/devils-advocate`)
- 아키텍처 결정 후 스트레스 테스트
- Feature plan 검증
- 코드 구현 후 놓친 부분 찾기
- 직접 호출: `/devils-advocate review the auth flow`

## Pairing Examples

```
/architecture  →  설계 완료          →  /devils-advocate  →  설계 도전
/api-design    →  API 설계           →  /devils-advocate  →  API 구멍 찾기
/feature-planner → 계획 수립         →  /devils-advocate  →  계획 스트레스 테스트
구현 완료      →  Two-Stage Review   →  /devils-advocate  →  결정 자체 검증
```

## Process

### Step 1: Steel-Man (먼저 인정)

비판 전에 현재 접근법이 합리적인 이유를 먼저 명확히 진술합니다. Straw man 공격 금지.

- 어떤 제약 조건 하에서 이 결정이 내려졌는지
- 이 접근법이 최적인 조건은 무엇인지
- 놓치고 있을 수 있는 컨텍스트는 무엇인지

### Step 2: Structured Frameworks 적용

레퍼런스 파일에 정의된 프레임워크를 상황에 맞게 적용합니다:

| Framework | 적용 시점 |
|-----------|----------|
| **Pre-Mortem** | 배포/출시 전 계획 검증 |
| **Inversion** | 설계 견고성 평가 |
| **Socratic Questioning** | 가정 탐색, 의사결정 검증 |
| **Five Whys (Reverse)** | 기술 결정의 근본 동기 추적 |
| **Six Thinking Hats** | 포괄적 설계 리뷰 |

레퍼런스 로딩: `@references/questioning-frameworks.md`

### Step 3: Blind Spot Check

11개 엔지니어링 블라인드 스팟 + 12개 AI 특유 약점을 점검합니다.

**Engineering Blind Spots**: Security, Scalability, Data Lifecycle, Integration Points, Failure Modes, Concurrency, Environment Gaps, Observability, Deployment, Multi-Tenancy, Edge Cases

**AI Blind Spots**: Happy Path Bias, Scope Acceptance, Confidence Without Correctness, Test Rewriting, Pattern Attraction, Reactive Patching, Context Rot, Library Hallucination, Architectural Inconsistency, XY Problem Blindness, Over-Abstraction, Security as Afterthought

레퍼런스 로딩: `@references/blind-spots.md`, `@references/ai-blind-spots.md`

### Step 4: Verdict

| Verdict | 의미 |
|---------|------|
| **Ship it** | 견고함. 진짜 좋은 작업은 인정 |
| **Ship with changes** | 아키텍처는 건전하나 특정 수정 필요 |
| **Rethink this** | 근본적 접근 재고 필요 |

## Output Rules

### Concern Format

각 concern은 반드시 포함:
- **Severity**: Critical / High / Medium
- **Framework**: 어떤 프레임워크로 발견했는지
- **What I see**: 구체적 관찰 (코드 라인, 설계 결정 지목)
- **Why it matters**: "so what?" 테스트 통과 — 무시하면 실제로 무슨 일이 발생하는지
- **What to do**: 구체적이고 실행 가능한 권장사항

### Constraints

- **최대 7개 concerns**, severity 순 정렬
- 각 concern은 **"so what?" 테스트** 통과 필수 (무시하면 실제로 문제 되는가?)
- 각 concern은 **actionability 테스트** 통과 필수 (권장사항이 구체적이고 실행 가능한가?)
- **제조된 비판 금지** — 문제 없으면 "Ship it"
- **코드 재작성 금지** — 도전하고 권장. 구현은 사용자/Claude 몫
- 직접적 표현: "This will break when..." (hedging 금지)

### Context Calibration

- **Prototype/MVP**: 가벼운 검토. 완벽함 요구 금지
- **Production system**: 엄격한 검토. 모든 블라인드 스팟 점검
- **Financial/medical/safety**: 최고 수준. 모든 프레임워크 적용

## Example Output

```
## Devil's Advocate Review

### Steel-man
이벤트 드리븐 알림 시스템 접근법은 합리적입니다 — 큐 기반 비동기 처리,
템플릿 렌더링, 멀티채널 전송. 관심사 분리가 잘 되어 있고 비동기에 적합한
선택입니다.

### Concern 1: 전송 보장/재시도 전략 부재
**Severity**: Critical
**Framework**: Pre-mortem

**What I see**: 큐 컨슈머가 알림을 처리하지만 dead-letter queue, 재시도
로직, idempotency key가 없습니다.

**Why it matters**: 사용자가 중요한 알림(비밀번호 재설정, 결제 확인)을
놓칩니다. 더 심각한 건 — 실패 알림이 없어서 문제 발생 자체를 모릅니다.

**What to do**: DLQ + 3회 재시도 + exponential backoff 추가.
notification_id + channel로 idempotency key 구성. DLQ depth > 0 알림.

### Concern 2: 큐 컨슈머 내 템플릿 렌더링
**Severity**: High
**Framework**: Inversion — "규모에서 실패를 보장하려면?"

**What I see**: 템플릿 렌더링이 메시지 디큐 프로세스 안에서 실행됩니다.

**Why it matters**: 하나의 잘못된 템플릿이 전체 알림 파이프라인을 차단합니다.

**What to do**: 인큐 전에 렌더링하거나(fail fast), 렌더링을 try/catch로
격리하여 실패를 DLQ로 라우팅.

### Verdict: Ship with changes
아키텍처는 건전하나 전송 파이프라인에 안전장치가 없습니다.
Concern 1, 2를 배포 전에 수정하세요.
```

---

위 프로세스에 따라 제공된 결정/계획/코드/설계를 비판적으로 리뷰하세요.
