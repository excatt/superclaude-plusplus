---
name: grill-with-docs
description: 사용자 계획을 기존 도메인 모델에 대해 stress-test하는 인터뷰 세션. 용어를 날카롭게 다듬고, 결정이 굳어질 때마다 CONTEXT.md(도메인 어휘 사전)와 ADR을 인라인으로 갱신한다. 새 기능 요구사항 탐색은 `/brainstorm`을, 기존 도메인 모델·용어와의 정합성 점검은 이 스킬을 사용한다.
user-invocable: true
argument-hint: "[plan-or-design-description]"
source:
  upstream: https://github.com/mattpocock/skills
  original-path: skills/engineering/grill-with-docs/
  license: MIT
  copyright: Copyright (c) 2026 Matt Pocock
---

# Grill-with-docs — Stress-Testing Plans Against the Domain Model

> **출처**: 이 스킬은 [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, Copyright (c) 2026 Matt Pocock)의 `engineering/grill-with-docs`를 SuperClaude++ 컨벤션에 맞게 포팅한 것이다. 라이선스 전문은 [`LICENSE`](LICENSE), 통합 변경 내역은 루트 [`NOTICE.md`](../../NOTICE.md) 참조.

## Role Boundary (vs. /brainstorm, /confidence-check, /feature-planner)

| 스킬 | 역할 |
|------|------|
| `/brainstorm` | **새 기능 아이디어** → 다영역 페르소나 협업으로 요구사항을 발굴 |
| `/grill-with-docs` | **기존 도메인 모델 stress-test** → 1대1 인터뷰로 용어·결정을 코드와 정렬하고 문서화 |
| `/confidence-check` | 정량적 5체크 (자동 평가, 인터뷰 X) |
| `/feature-planner` | Phase별 TDD 계획 문서 생성 (인터뷰 X) |

## What to Do

사용자의 계획·설계를 끈질기게 인터뷰하여 상호 이해에 도달할 때까지 진행한다. 디자인 트리의 각 가지를 따라 내려가며 결정 사이의 의존성을 하나씩 해결한다. **각 질문마다 추천 답변을 함께 제시**한다.

질문은 **한 번에 하나씩** 던지고, 사용자의 답을 받은 뒤에야 다음 질문으로 넘어간다.

질문이 **코드베이스 탐색으로 답할 수 있다면 사용자에게 묻지 말고 직접 탐색**한다.

## Supporting Information

### Domain Awareness

세션 중 코드 탐색 시, 다음 문서들도 함께 확인한다.

#### File Structure

대부분의 레포는 컨텍스트 1개를 가진다:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

루트에 `CONTEXT-MAP.md`가 있으면 멀티 컨텍스트 레포다. 맵이 각 컨텍스트의 위치를 가리킨다:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← 시스템 전반 결정
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← 컨텍스트 고유 결정
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

**파일은 lazy하게 생성**한다 — 쓸 내용이 생겼을 때만 만든다. `CONTEXT.md`가 없으면 첫 용어가 해결될 때 만들고, `docs/adr/`가 없으면 첫 ADR이 필요할 때 만든다.

### During the Session

#### 1. 어휘 사전과 충돌하는 용어 즉시 챌린지

사용자가 `CONTEXT.md`의 기존 정의와 충돌하는 방식으로 단어를 쓰면 **즉시 지적**한다.

> "어휘 사전은 '취소(cancellation)'를 X로 정의하는데, 방금 말씀하신 건 Y에 가깝습니다 — 어느 쪽인가요?"

#### 2. 모호한 언어를 정밀한 용어로 교정

사용자가 모호하거나 과중한 의미를 가진 단어를 쓰면, **정확한 정식 용어를 제안**한다.

> "'계정(account)'이라고 말씀하셨는데 — 고객(Customer)인가요, 사용자(User)인가요? 둘은 다른 개념입니다."

#### 3. 구체적 시나리오로 경계 압박

도메인 관계를 논의할 때는 **엣지 케이스 시나리오**를 만들어 사용자가 개념 간 경계를 정확히 말하도록 강제한다.

#### 4. 코드와 상호 검증

사용자가 "이건 이렇게 동작한다"고 진술하면, 코드가 동의하는지 확인한다. 모순을 발견하면 표면에 올린다.

> "코드는 주문(Order) 전체를 취소하는데, 방금 부분 취소가 가능하다고 하셨습니다 — 어느 쪽이 맞나요?"

#### 5. CONTEXT.md 인라인 갱신

용어가 합의되는 즉시 **그 자리에서** `CONTEXT.md`를 갱신한다. 모아두지 말고 발생 즉시 캡처한다. 형식은 [`CONTEXT-FORMAT.md`](./CONTEXT-FORMAT.md) 참조.

> **불변 규칙**: `CONTEXT.md`는 **구현 세부사항이 0%**여야 한다. 스펙도, 스크래치 패드도, 구현 결정 저장소도 아니다. **어휘 사전(glossary)일 뿐이며 그 이상도 그 이하도 아니다.**

#### 6. ADR은 드물게 제안

ADR 작성은 **세 조건이 모두 참**일 때만 제안한다:

1. **되돌리기 어렵다 (Hard to reverse)** — 마음을 바꿨을 때 비용이 의미 있게 크다.
2. **컨텍스트 없이는 놀랍다 (Surprising without context)** — 미래의 독자가 "왜 이렇게 했지?"라고 의아해할 것이다.
3. **진짜 트레이드오프의 결과다 (Real trade-off)** — 진짜 대안이 있었고 특정 이유로 한쪽을 골랐다.

셋 중 하나라도 빠지면 ADR을 만들지 않는다. 형식은 [`ADR-FORMAT.md`](./ADR-FORMAT.md) 참조.

## SuperClaude++ Workflow Integration

```
사용자: "기존 모듈 X에 Y 기능을 추가하려고 한다"
  ↓
/grill-with-docs
  ↓
질문 1 (+ 추천답)  ← 사용자가 "yes" 또는 보정
질문 2 (+ 추천답)  ← CONTEXT.md에서 충돌 용어 감지 → 챌린지
  ↓
용어 합의 → CONTEXT.md 인라인 패치
  ↓
질문 N ... (코드로 답할 수 있는 건 직접 grep)
  ↓
결정이 hard-to-reverse + surprising + real-trade-off → ADR 제안
  ↓
공유 이해 도달 → /confidence-check 또는 /feature-planner로 진입
```

### When NOT to Use

- 새 기능을 *처음부터* 탐색할 때 → `/brainstorm`
- 단순 버그 수정 / 타이포 → 직접 작업
- 단일 파일 단순 변경 (Simple 난이도) → 직접 작업

### Combinations

- `--ctx research` — 더 깊은 외부 자료 조사를 곁들이고 싶을 때
- `/confidence-check` 후속 — grill 세션 종료 후 정량 검증
- `/feature-planner` 후속 — grill로 합의된 결정을 phase 계획에 반영

## Boundaries

**Will:**
- 한 번에 한 질문씩, 추천답을 동반하여 인터뷰
- 코드베이스로 답 가능한 질문은 직접 탐색
- 용어/코드/결정의 모순을 즉시 표면화
- CONTEXT.md를 즉시·인라인으로 갱신
- ADR을 매우 보수적으로 제안 (3조건 충족 시만)

**Will Not:**
- CONTEXT.md에 구현 세부사항을 쓰는 행위 (스펙 아님)
- 진짜 트레이드오프 없는 결정에 ADR 강요
- 사용자 답을 받지 않고 다음 질문으로 넘어가는 행위
- 코드로 답할 수 있는 질문을 사용자에게 묻는 행위
