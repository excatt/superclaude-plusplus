# OVERENGINEERING_TRAPS.md

Build Ladder(`PRINCIPLES.md`)의 **적용 규칙 3종**과, **rung 3 — "네이티브 플랫폼 기능이 있는가?"** 를 실제로 통과시키기 위한 사례 카탈로그.

원칙만으로는 행동이 바뀌지 않는다. "YAGNI를 지켜라"는 이미 알고 있고 그럼에도 date picker를 400줄로 만든다. 바뀌는 건 **"이건 `<input type="date">`다"** 라는 구체적 대응 관계를 알 때다. 이 문서는 그 대응 관계 목록이다.

**로딩 시점**: UI 컴포넌트 구현 전 / `/distill`·`/critique` 실행 시 / 의존성 추가 결정 시 / 코드 리뷰에서 "이거 직접 만들 필요 있었나?" 판단 시 / 래더를 어디까지 적용할지 판단이 필요할 때.

---

## 래더 적용 규칙 3종

`PRINCIPLES.md`에는 표만 상주한다. 표를 **잘못 적용하는 방법**이 세 가지 있고, 그것을 막는 규칙이 아래다.

### 1. Ordering rule — 래더는 문제를 *이해한 후에* 돈다

해결책에 게으르되, **코드 읽기에는 절대 게으르지 않는다.** rung 0만 코드를 읽지 않고 답할 수 있고, rung 1("이미 이 코드베이스에 있는가")부터는 코드베이스를 읽었어야 답이 나온다. 래더는 *무엇을 만들지*를 줄이지 *얼마나 읽을지*를 줄이지 않는다.

이해 전에 래더를 돌리면 나오는 것: "필요 없어 보이니 생략"(실은 필요했음), "stdlib으로 되겠지"(실은 엣지 케이스가 다름).

### 2. Scope limit — 디버깅에는 적용하지 않는다

**최소 diff 편향을 버그 수정에 적용하면 증상 패치가 나온다.** 지목된 경로만 막고 형제 경로를 방치하는 형태다.

> 버그 리포트: "송금 시 잔액 초과 가능". `transfer()`와 `withdraw()`가 `_debit()`을 공유한다.
> 최소 diff: `transfer()`에 가드 추가 → 리포트는 닫히고 `withdraw()`는 여전히 초과 인출된다.
> 옳은 수정: `_debit()`에 가드 → 두 경로 모두 해결.

root-cause-first 디버깅은 `RULES.md` 서두가 밝힌 **하네스 보장 항목**이며 래더보다 우선한다. 근본 원인을 끝까지 추적한 *다음에* 래더를 내려간다. 3회 수정 실패 시에는 Circuit Breaker가 래더와 무관하게 발동한다.

### 3. No compression rung — "한 줄로 만들어라"는 없다

래더에 압축 단계를 의도적으로 넣지 않았다. 래더는 ***삭제*를 보상하지 *밀도*를 보상하지 않는다.** 404줄 date picker를 `<input type="date">` 23줄로 바꾸는 것은 삭제고, 30줄 함수를 읽을 수 없는 3줄로 접는 것은 압축이다. LOC 지표는 둘을 구분하지 못하지만 사람은 구분해야 한다.

볼륨 체크는 `PRINCIPLES.md`의 **Simplicity Checks** 소관이며, 그쪽은 양방향(과설계 AND 과압축)으로 작동한다.

---

## 판별 3문

컴포넌트나 유틸리티를 직접 만들기 직전에 묻는다.

1. **이 위젯의 이름을 HTML/CSS/stdlib이 이미 알고 있는가?** — date, color, dialog, details, progress, range… 이름이 있으면 구현도 있다.
2. **내가 만들려는 것이 "플랫폼 것 + 스타일"인가, "플랫폼에 없는 동작"인가?** — 전자면 스타일만 쓴다.
3. **의존성을 추가하는 이유가 "기능"인가 "디자인 통제권"인가?** — 후자라면 그건 트레이드오프지 필요가 아니다. 명시하고 선택하라(→ 아래 "역함정").

---

## 카탈로그

### HTML 네이티브 — 컴포넌트 라이브러리를 부르기 전에

| 만들려는 것 | 네이티브 | 비고 |
|-------------|----------|------|
| Date / time picker | `<input type="date">` `datetime-local` `month` `week` `time` | 키보드·로케일·모바일 네이티브 UI 무료 |
| Color picker | `<input type="color">` | |
| 슬라이더 | `<input type="range">` | |
| 자동완성 드롭다운 | `<input list>` + `<datalist>` | 단순 제안 목록 한정 |
| 아코디언 / 접기 | `<details>` `<summary>` | JS 0줄. `name` 속성으로 배타 그룹 |
| 모달 | `<dialog>` + `showModal()` | 포커스 트랩·`Esc`·backdrop 내장 |
| 툴팁 / 팝오버 | `popover` 속성 + `popovertarget` | light-dismiss 내장 |
| 진행 표시 / 게이지 | `<progress>` `<meter>` | |
| 폼 검증 | `required` `pattern` `min` `max` `:invalid` + `setCustomValidity()` | 검증 라이브러리 이전 단계 |
| 파일 드롭존 | `<input type="file">` + `drop` 이벤트 | 업로더 라이브러리는 청크/재개가 필요할 때만 |
| 지연 로딩 이미지 | `loading="lazy"` `decoding="async"` | |
| 반응형 이미지 | `<picture>` `srcset` `sizes` | |

### CSS 네이티브 — JS를 쓰기 전에

| 만들려는 것 | 네이티브 |
|-------------|----------|
| 캐러셀 스냅 | `scroll-snap-type` / `scroll-snap-align` |
| 스티키 헤더 | `position: sticky` |
| 스크롤 등장 애니메이션 | `animation-timeline: view()` (미지원 시 `IntersectionObserver`) |
| 텍스트 말줄임 | `text-overflow: ellipsis` / `line-clamp` |
| 다크 모드 | `prefers-color-scheme` + CSS 변수 |
| 컨테이너 반응형 | `@container` |
| 종횡비 박스 | `aspect-ratio` |
| 부드러운 스크롤 | `scroll-behavior: smooth` |

### JS stdlib — 유틸 라이브러리를 부르기 전에

| 만들려는 것 | 네이티브 |
|-------------|----------|
| 날짜 포맷 / 상대 시간 | `Intl.DateTimeFormat` / `Intl.RelativeTimeFormat` |
| 숫자·통화·단위 포맷 | `Intl.NumberFormat` |
| 로케일 정렬 | `Intl.Collator` |
| 복수형 처리 | `Intl.PluralRules` |
| 딥 클론 | `structuredClone()` |
| 쿼리스트링 파싱 | `URL` / `URLSearchParams` |
| 요청 취소 / 타임아웃 | `AbortController` / `AbortSignal.timeout()` |
| UUID | `crypto.randomUUID()` |
| 해시 | `crypto.subtle.digest()` |
| 그룹핑 | `Object.groupBy()` / `Map.groupBy()` |
| 이벤트 발행/구독 | `EventTarget` |

### Python stdlib — 의존성을 추가하기 전에

| 만들려는 것 | 네이티브 |
|-------------|----------|
| CLI 인자 파싱 | `argparse` |
| 설정 객체 / DTO | `dataclasses` (검증까지 필요하면 그때 pydantic) |
| 캐시 | `functools.lru_cache` / `cache` |
| 경로 조작 | `pathlib` |
| CSV 처리 | `csv` (통계까지 가면 그때 pandas) |
| 열거형 | `enum.Enum` / `StrEnum` |
| 카운팅 / 기본값 딕셔너리 | `collections.Counter` / `defaultdict` |
| 재시도 백오프 | `time.sleep` + 루프 (복잡해지면 tenacity) |
| 임시 파일 | `tempfile` |
| 배치 처리 | `itertools.batched` |

### 백엔드·인프라

| 만들려는 것 | 먼저 확인할 것 |
|-------------|----------------|
| 커스텀 인증 | 프레임워크 내장 auth / 기존 IdP |
| 자체 큐 | DB 테이블 + `SELECT ... FOR UPDATE SKIP LOCKED` |
| 자체 캐시 계층 | HTTP 캐시 헤더 / CDN / 이미 있는 Redis |
| 자체 마이그레이션 러너 | Alembic / Prisma Migrate |
| 자체 rate limiter | 리버스 프록시(nginx/Cloudflare) 설정 |
| 자체 페이지네이션 프로토콜 | 프레임워크 페이지네이터 |

---

## 역함정 — 네이티브를 버려야 할 때

이 카탈로그는 **"항상 네이티브를 써라"가 아니다.** 그렇게 읽으면 rung 3이 rung 0~2보다 강해져서 새로운 과설계가 된다. 아래는 라이브러리가 정답인 경우다.

| 상황 | 판단 |
|------|------|
| **디자인 시스템 준수가 요구사항** | `<input type="date">`는 브라우저별 UI가 다르고 스타일 통제가 제한적이다. `DESIGN.md`가 특정 캘린더 UI를 규정하면 라이브러리가 맞다 |
| **접근성 요구가 네이티브를 넘어설 때** | 스크린리더 동작이 브라우저마다 갈리는 위젯(복합 combobox 등)은 검증된 라이브러리가 더 안전하다 |
| **타깃 브라우저 미지원** | `popover`, `@container`, `animation-timeline` 등은 지원 범위 확인 필수. 폴리필 비용 > 라이브러리 비용이면 라이브러리 |
| **동작이 실제로 다를 때** | 멀티 날짜 범위 + 예약 불가일 + 타임존 표시 = `<input type="date">`가 아니다. 이건 rung 5다 |
| **이미 그 라이브러리를 쓰고 있을 때** | rung 4가 rung 3보다 먼저다. 일관성이 줄 수보다 중요하다 |

**핵심**: 라이브러리를 고르는 건 괜찮다. **고르지 않고 미끄러져 들어가는 것**이 함정이다. 위 표 중 하나를 근거로 댈 수 있으면 rung 3을 통과한 것이다.

---

## 근거와 한계

이 카탈로그의 착안점은 [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)(MIT)의 agentic 벤치마크다. 실측된 항목은 **2개뿐**이다.

| 태스크 | baseline | ponytail arm | 원인 |
|--------|----------|--------------|------|
| Date picker | 404줄 | 23줄 | 컴포넌트 의존성 대신 네이티브 `<input>` |
| Color picker | 287줄 | 23줄 | 동일 |

**측정 조건과 한계** (인용 시 반드시 동반):
- 저자 자체 벤치마크. **Haiku 4.5 단일 모델**, 태스크당 **n=4**, 표준편차·신뢰구간 미보고, timeout 데이터 손실 4건.
- 상위 티어 모델에 대한 이전 가능성은 저자도 유보 — *"Bigger models may close the over-build gap (they need less hand-holding) or widen it."*
- 백엔드 태스크는 전 arm이 17–44줄로 수렴 — **이득 없음**. 이 함정은 주로 프론트엔드 위젯에서 발생한다.
- 위 표의 2건을 제외한 나머지 항목은 **벤치마크된 것이 아니라 같은 종류의 함정을 일반화한 것**이다. "−54%" 같은 수치를 이 카탈로그 전체에 적용하지 말 것.

**따라서 이 문서의 용도**: 수치 근거가 아니라 **점검 목록**이다. rung 3에서 "혹시 이 중에 있나?"를 훑는 데 쓴다.

---

## 관련 문서

- `PRINCIPLES.md` — Build Ladder 표 (상시 로드). 이 문서는 그 적용 규칙 + rung 3 부속
- `PRINCIPLES.md` — Simplicity Checks (볼륨 체크, 양방향)
- `RULES.md` — Circuit Breaker (3회 수정 실패 시 래더보다 우선 발동)
- `/distill` — 기존 코드에서 불필요한 복잡도 제거
- `/critique` — 디자인 관점 평가 (네이티브 위젯의 디자인 한계 판단)
