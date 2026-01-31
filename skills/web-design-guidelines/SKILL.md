---
name: web-design-guidelines
description: |
  Vercel의 Web Interface Guidelines 기반 UI 코드 리뷰 스킬.
  100+ 규칙으로 접근성, 성능, UX를 검사합니다.

  Use proactively when:
  - UI 코드 리뷰 요청
  - 접근성(a11y) 검사 요청
  - 디자인 감사 요청
  - UX 검토 요청
  - 베스트 프랙티스 체크 요청

  Triggers: review UI, check accessibility, audit design, review UX,
  check best practices, UI 리뷰, 접근성 검사, 디자인 검토, UX 검토,
  웹 가이드라인, a11y 체크

  Do NOT use for: 백엔드 코드, API 설계, 데이터베이스
user-invocable: true
argument-hint: <file-or-pattern>
metadata:
  author: vercel (adapted for SuperClaude)
  version: "1.0.0"
  source: https://github.com/vercel-labs/web-interface-guidelines
---

# Web Interface Guidelines

UI 코드를 Vercel Web Interface Guidelines에 따라 검토합니다.

## 사용법

```bash
/web-design-guidelines src/components/Button.tsx
/web-design-guidelines "src/**/*.tsx"
/web-design-guidelines                          # 파일 지정 요청
```

## 검토 규칙

### Accessibility (접근성)

- Icon-only 버튼에 `aria-label` 필수
- Form 컨트롤에 `<label>` 또는 `aria-label` 필수
- 인터랙티브 요소에 키보드 핸들러 필수 (`onKeyDown`/`onKeyUp`)
- 액션은 `<button>`, 네비게이션은 `<a>`/`<Link>` 사용 (`<div onClick>` 금지)
- 이미지에 `alt` 필수 (장식용이면 `alt=""`)
- 장식용 아이콘에 `aria-hidden="true"`
- 비동기 업데이트(토스트, 검증)에 `aria-live="polite"`
- ARIA보다 시맨틱 HTML 우선 (`<button>`, `<a>`, `<label>`, `<table>`)
- 헤딩 계층 유지 `<h1>`–`<h6>`; 메인 콘텐츠 스킵 링크 포함
- 앵커 헤딩에 `scroll-margin-top`

### Focus States (포커스 상태)

- 인터랙티브 요소에 visible focus 필수: `focus-visible:ring-*` 또는 동등
- `outline-none` / `outline: none` 사용 시 포커스 대체 필수
- `:focus`보다 `:focus-visible` 사용 (클릭 시 포커스 링 방지)
- 복합 컨트롤에 `:focus-within`으로 그룹 포커스

### Forms (폼)

- Input에 `autocomplete`와 의미 있는 `name` 필수
- 올바른 `type` 사용 (`email`, `tel`, `url`, `number`)과 `inputmode`
- paste 차단 금지 (`onPaste` + `preventDefault`)
- Label 클릭 가능 (`htmlFor` 또는 컨트롤 래핑)
- 이메일, 코드, 유저명에 spellcheck 비활성화 (`spellCheck={false}`)
- Checkbox/Radio: label + control 단일 히트 타겟 (dead zone 없음)
- Submit 버튼은 요청 시작까지 활성화; 요청 중 스피너 표시
- 에러는 필드 옆 인라인; submit 시 첫 에러로 포커스
- Placeholder는 `…`로 끝나고 예시 패턴 표시
- 비인증 필드에 `autocomplete="off"` (패스워드 매니저 트리거 방지)
- 저장되지 않은 변경 시 네비게이션 경고 (`beforeunload` 또는 라우터 가드)

### Animation (애니메이션)

- `prefers-reduced-motion` 존중 (축소 버전 제공 또는 비활성화)
- `transform`/`opacity`만 애니메이션 (컴포지터 친화적)
- `transition: all` 금지—속성 명시적 나열
- 올바른 `transform-origin` 설정
- SVG: `<g>` 래퍼에 transforms, `transform-box: fill-box; transform-origin: center`
- 애니메이션 중단 가능—애니메이션 중 사용자 입력 응답

### Typography (타이포그래피)

- `...` 대신 `…` 사용
- 직선 따옴표 `"` 대신 곡선 따옴표 `"` `"` 사용
- Non-breaking 공백: `10&nbsp;MB`, `⌘&nbsp;K`, 브랜드명
- 로딩 상태는 `…`로 끝남: `"Loading…"`, `"Saving…"`
- 숫자 컬럼/비교에 `font-variant-numeric: tabular-nums`
- 헤딩에 `text-wrap: balance` 또는 `text-pretty` (widow 방지)

### Content Handling (콘텐츠 처리)

- 텍스트 컨테이너가 긴 콘텐츠 처리: `truncate`, `line-clamp-*`, 또는 `break-words`
- Flex 자식에 `min-w-0` 필요 (텍스트 truncation 허용)
- 빈 상태 처리—빈 문자열/배열에 깨진 UI 렌더링 금지
- 사용자 생성 콘텐츠: 짧은, 평균, 매우 긴 입력 예상

### Images (이미지)

- `<img>`에 명시적 `width`와 `height` 필수 (CLS 방지)
- Below-fold 이미지: `loading="lazy"`
- Above-fold 중요 이미지: `priority` 또는 `fetchpriority="high"`

### Performance (성능)

- 큰 리스트 (>50 아이템): 가상화 (`virtua`, `content-visibility: auto`)
- 렌더에서 레이아웃 읽기 금지 (`getBoundingClientRect`, `offsetHeight` 등)
- DOM 읽기/쓰기 배치; 인터리빙 방지
- Uncontrolled input 선호; controlled input은 키스트로크당 저렴해야 함
- CDN/에셋 도메인에 `<link rel="preconnect">` 추가
- 중요 폰트: `<link rel="preload" as="font">`와 `font-display: swap`

### Navigation & State (네비게이션 & 상태)

- URL이 상태 반영—필터, 탭, 페이지네이션, 확장 패널을 쿼리 파람에
- 링크는 `<a>`/`<Link>` 사용 (Cmd/Ctrl+click, 중간클릭 지원)
- 모든 상태 UI 딥링크 (`useState` 사용 시 nuqs 등으로 URL 동기화 고려)
- 파괴적 액션은 확인 모달 또는 실행 취소 창 필요—즉시 실행 금지

### Touch & Interaction (터치 & 인터랙션)

- `touch-action: manipulation` (더블탭 줌 지연 방지)
- `-webkit-tap-highlight-color` 의도적 설정
- 모달/드로어/시트에 `overscroll-behavior: contain`
- 드래그 중: 텍스트 선택 비활성화, 드래그 요소에 `inert`
- `autoFocus` 신중히 사용—데스크탑만, 단일 주요 입력; 모바일 피함

### Safe Areas & Layout (안전 영역 & 레이아웃)

- Full-bleed 레이아웃에 노치용 `env(safe-area-inset-*)` 필요
- 원치 않는 스크롤바 방지: 컨테이너에 `overflow-x-hidden`, 콘텐츠 오버플로우 수정
- JS 측정보다 Flex/grid 선호

### Dark Mode & Theming (다크 모드 & 테마)

- 다크 테마에 `<html>`에 `color-scheme: dark` (스크롤바, 입력 수정)
- `<meta name="theme-color">`가 페이지 배경과 일치
- 네이티브 `<select>`: 명시적 `background-color`와 `color` (Windows 다크 모드)

### Locale & i18n (로케일 & 국제화)

- 날짜/시간: 하드코딩 포맷 대신 `Intl.DateTimeFormat` 사용
- 숫자/통화: 하드코딩 포맷 대신 `Intl.NumberFormat` 사용
- 언어 감지: IP 대신 `Accept-Language` / `navigator.languages`

### Hydration Safety (하이드레이션 안전)

- `value` 있는 Input에 `onChange` 필요 (또는 uncontrolled용 `defaultValue` 사용)
- 날짜/시간 렌더링: 하이드레이션 불일치 방지 (서버 vs 클라이언트)
- `suppressHydrationWarning`은 정말 필요한 곳에만

### Hover & Interactive States (호버 & 인터랙티브 상태)

- 버튼/링크에 `hover:` 상태 필요 (시각적 피드백)
- 인터랙티브 상태가 대비 증가: hover/active/focus가 rest보다 눈에 띔

### Content & Copy (콘텐츠 & 카피)

- 능동태: "Install the CLI" not "The CLI will be installed"
- 헤딩/버튼에 Title Case (Chicago 스타일)
- 카운트에 숫자: "8 deployments" not "eight"
- 구체적 버튼 라벨: "Save API Key" not "Continue"
- 에러 메시지에 수정/다음 단계 포함, 문제만 말고
- 2인칭 사용; 1인칭 피함
- 공간 제한 시 "and"보다 `&`

## Anti-patterns (안티패턴) - 반드시 플래그

- `user-scalable=no` 또는 `maximum-scale=1` (줌 비활성화)
- `onPaste`와 `preventDefault`
- `transition: all`
- focus-visible 대체 없는 `outline-none`
- `<a>` 없는 인라인 `onClick` 네비게이션
- 클릭 핸들러 있는 `<div>` 또는 `<span>` (`<button>` 사용해야 함)
- 치수 없는 이미지
- 가상화 없는 큰 배열 `.map()`
- 라벨 없는 폼 입력
- `aria-label` 없는 아이콘 버튼
- 하드코딩 날짜/숫자 포맷 (`Intl.*` 사용해야 함)
- 명확한 정당화 없는 `autoFocus`

## 출력 형식

파일별 그룹화. `file:line` 형식 (VS Code 클릭 가능). 간결한 발견 사항.

```text
## src/Button.tsx

src/Button.tsx:42 - icon button missing aria-label
src/Button.tsx:18 - input lacks label
src/Button.tsx:55 - animation missing prefers-reduced-motion
src/Button.tsx:67 - transition: all → list properties

## src/Modal.tsx

src/Modal.tsx:12 - missing overscroll-behavior: contain
src/Modal.tsx:34 - "..." → "…"

## src/Card.tsx

✓ pass
```

이슈 + 위치 명시. 수정이 명확하지 않으면 설명 생략. 서문 없음.

## 관련 스킬

- `/react-best-practices` - React/Next.js 성능 최적화
- `/a11y` - 접근성 심층 분석
- `/frontend-design` - 프론트엔드 UI 생성
- `/responsive` - 반응형 디자인 검토
