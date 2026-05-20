<!--
출처: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/ADR-FORMAT.md
원본 라이선스: MIT (Copyright (c) 2026 Matt Pocock) — LICENSE 참조
SuperClaude++ 통합 시 한국어 가이드 및 우리 프로젝트 예시를 보강함.
원본 본문은 verbatim에 가깝게 보존됨.
-->

# ADR Format

ADR(Architecture Decision Record)은 `docs/adr/`에 위치하며, 순차 번호 부여 규칙을 따른다: `0001-slug.md`, `0002-slug.md`, ...

`docs/adr/` 디렉토리는 **lazy 생성**한다 — 첫 ADR이 필요할 때만 만든다.

## Template

```md
# {결정의 짧은 제목}

{1~3 문장: 어떤 맥락이었고, 무엇을 결정했고, 왜인지.}
```

이것이 전부다. ADR은 한 단락이어도 된다. 가치는 *결정이 있었다는 사실*과 *왜* 그렇게 했는지를 기록하는 데 있다 — 섹션을 빼곡히 채우는 데 있지 않다.

## Optional Sections

진짜 가치를 더할 때만 포함한다. 대부분의 ADR은 필요 없다.

- **Status frontmatter** (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — 결정이 재검토될 때 유용
- **Considered Options** — 거부한 대안이 기억할 가치가 있을 때만
- **Consequences** — 비명시적 하류 영향을 짚어둘 필요가 있을 때만

## Numbering

`docs/adr/`를 스캔해 가장 높은 기존 번호를 찾아 +1 한다.

## When to Offer an ADR

다음 **세 조건 모두 참**일 때만:

1. **되돌리기 어렵다 (Hard to reverse)** — 마음을 바꿨을 때 비용이 의미 있게 크다
2. **컨텍스트 없이는 놀랍다 (Surprising without context)** — 미래의 독자가 코드를 보고 "왜 굳이 이렇게 했지?"라고 의아해할 것이다
3. **진짜 트레이드오프의 결과다 (Real trade-off)** — 진짜 대안이 있었고 특정 이유로 한쪽을 골랐다

쉽게 되돌릴 수 있다면 — 그냥 되돌릴 것이므로 ADR이 필요 없다.
놀랍지 않다면 — 아무도 이유를 묻지 않을 것이다.
진짜 대안이 없었다면 — "당연한 걸 했다" 외에 기록할 게 없다.

### 자격이 되는 결정

- **아키텍처 형태**: "모노레포로 간다." "Write 모델은 이벤트 소싱, Read 모델은 Postgres 프로젝션."
- **컨텍스트 간 통합 패턴**: "Ordering과 Billing은 동기 HTTP가 아닌 도메인 이벤트로 통신한다."
- **락인을 동반하는 기술 선택**: 데이터베이스, 메시지 버스, 인증 제공자, 배포 타겟. 모든 라이브러리가 아니라 *교체에 분기가 걸리는 것들*.
- **경계와 스코프 결정**: "Customer 데이터는 Customer 컨텍스트가 소유하며, 다른 컨텍스트는 ID로만 참조한다." 명시적 "안 한다"는 "한다"만큼 가치 있다.
- **명백한 길에서 의도적으로 벗어난 결정**: "X 이유로 ORM 대신 수동 SQL을 쓴다." 합리적인 독자가 반대를 가정할 만한 모든 결정. 이게 다음 엔지니어가 의도된 것을 "고치는" 일을 막는다.
- **코드에 보이지 않는 제약**: "컴플라이언스 요구사항 때문에 AWS를 못 쓴다." "파트너 API 계약 때문에 응답 시간이 200ms 미만이어야 한다."
- **거부 사유가 비명시적인 대안**: GraphQL을 검토했지만 미묘한 이유로 REST를 골랐다면 기록해두라 — 안 그러면 6개월 후 누군가 다시 GraphQL을 제안할 것이다.

## SuperClaude++ 적용 노트

- 우리 프로젝트는 단일 컨텍스트로 시작해도 충분하다. `docs/adr/` 하나만 만들면 된다.
- ADR 작성은 `/grill-with-docs` 세션 중 자연스럽게 제안된다. 평상시 의도적으로 만들 일은 거의 없다.
- 기존 RULES.md/PRINCIPLES.md의 *행동 규칙*은 ADR이 아니다 — 그건 프로젝트 헌법에 가깝다. ADR은 *특정 시점의 트레이드오프 선택*만 기록한다.
