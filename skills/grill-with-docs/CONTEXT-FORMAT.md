<!--
출처: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/CONTEXT-FORMAT.md
원본 라이선스: MIT (Copyright (c) 2026 Matt Pocock) — LICENSE 참조
SuperClaude++ 통합 시 한국어 가이드 및 우리 도메인 예시를 보강함.
-->

# CONTEXT.md Format

`CONTEXT.md`는 하나의 컨텍스트(도메인 경계) 안에서 통용되는 **공유 어휘 사전(glossary)** 이다. 다른 무엇도 아니다.

## 절대 규칙

1. **어휘 사전일 뿐**이다. 스펙도, 스크래치 패드도, 구현 결정 저장소도 아니다.
2. **구현 세부사항은 0%**여야 한다. 어떻게 동작하는지(how)는 코드와 ADR에 있다. 여기에는 **무엇을 의미하는지(what)** 만 적는다.
3. **lazy 생성**: 첫 용어가 해결될 때 만든다. 빈 CONTEXT.md를 미리 만들지 않는다.

## 위치

| 컨텍스트 수 | 위치 |
|------------|------|
| 단일 컨텍스트 | 루트 `CONTEXT.md` |
| 멀티 컨텍스트 | 루트 `CONTEXT-MAP.md` + 각 컨텍스트 폴더의 `CONTEXT.md` |

## 항목 형식

각 용어는 다음 골격을 따른다:

```md
### {Term Name}

{한두 문장 정의. 이 컨텍스트 안에서 이 단어가 정확히 무엇을 의미하는지.}

{필요 시: 같은 단어가 다른 컨텍스트에서 다른 의미로 쓰이는 경우 명시.}
{필요 시: 자주 혼동되는 유사 용어와의 구분.}
```

- **표제어**: PascalCase 또는 영어 표기 그대로. 정식 용어가 한국어라면 한국어로 적되 영문 별칭 병기.
- **정의는 짧게**: 한두 문장. 길어진다면 그건 스펙이고, 다른 파일에 가야 한다.
- **모호한 동의어 금지**: "비슷한 거" 같은 표현은 챌린지 대상.

## 절대 들어가면 안 되는 것

- 함수/클래스 이름, 파일 경로
- 데이터베이스 스키마, 컬럼 타입
- API 엔드포인트, HTTP 메서드
- 코드 스니펫
- 의사결정 과정 ("X와 Y를 비교했는데 Y로 갔다") → ADR로 옮긴다
- TODO, FIXME, 임시 메모

## 예시: 단일 컨텍스트

```md
# CONTEXT — Ordering Domain

### Order

고객이 1개 이상의 상품을 구매하기로 약정한 트랜잭션 단위. 결제 완료 전후 모두 Order로 지칭한다. 결제 완료 전을 별도로 표현하려면 *Pending Order* 라 한다.

### Cancellation

이미 생성된 Order의 전체를 무효화하는 행위. **부분 취소는 Cancellation이 아니라 Refund Line으로 표현**한다.

### Customer

이 컨텍스트에서 Customer는 결제 정보를 가진 자연인 또는 법인을 지칭한다. 로그인 자격을 가진 주체는 User이며, 한 Customer가 여러 User를 가질 수 있다.

### Refund Line

이미 결제된 Order의 일부 라인 아이템을 환불 처리한 기록. Order는 그대로 유효하다.
```

## 예시: 멀티 컨텍스트 (CONTEXT-MAP.md)

```md
# CONTEXT MAP

이 레포는 다음 컨텍스트로 분할되어 있다. 각 컨텍스트는 자체 어휘 사전을 가지며, 같은 단어가 다른 의미일 수 있다.

| Context | Path | Glossary |
|---------|------|----------|
| Ordering | `src/ordering/` | [src/ordering/CONTEXT.md](src/ordering/CONTEXT.md) |
| Billing | `src/billing/` | [src/billing/CONTEXT.md](src/billing/CONTEXT.md) |
| Identity | `src/identity/` | [src/identity/CONTEXT.md](src/identity/CONTEXT.md) |

## 컨텍스트 간 통합 패턴

시스템 전반 결정은 `docs/adr/`에 기록한다. 컨텍스트 고유 결정은 각 컨텍스트의 `docs/adr/`에 기록한다.
```

## 갱신 규칙

- 용어가 합의되는 **즉시** 추가한다. 세션 끝나고 한꺼번에 정리하지 않는다.
- 정의가 바뀌면 옛 정의를 지우지 말고 ADR로 변경 이유를 남긴다 (3조건 충족 시).
- 알파벳 순 또는 도메인 그룹 순으로 정렬한다. 발생 순서로 쌓아두지 않는다.

## 챌린지 트리거

`/grill-with-docs` 세션 중 다음 신호가 보이면 즉시 챌린지:

- 사용자가 CONTEXT.md에 정의된 용어를 다른 의미로 사용
- 같은 개념에 두 개 이상의 단어를 혼용
- "그냥 비슷한 거예요" 류의 모호한 동치
- 코드가 정의와 다르게 동작
