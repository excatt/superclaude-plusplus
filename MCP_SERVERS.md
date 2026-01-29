# MCP Servers Reference

통합된 MCP 서버 매트릭스. 각 서버의 목적, 트리거, 선택 기준을 압축 형식으로 제공.

## Quick Selection Matrix

| Server | Purpose | Best For | NOT For |
|--------|---------|----------|---------|
| **Context7** | 공식 문서 조회 | 프레임워크 패턴, 버전별 API | 일반 설명 |
| **Magic** | UI 컴포넌트 생성 | 버튼, 폼, 모달, 테이블 | 백엔드 로직 |
| **Morphllm** | 패턴 기반 편집 | 벌크 변환, 스타일 적용 | 심볼 리네임 |
| **Playwright** | 브라우저 자동화 | E2E 테스트, 스크린샷 | 정적 코드 분석 |
| **Sequential** | 다단계 추론 | 복잡한 디버깅, 아키텍처 분석 | 단순 작업 |
| **Serena** | 시맨틱 코드 이해 | 심볼 작업, 세션 관리 | 단순 텍스트 치환 |
| **Tavily** | 웹 검색/리서치 | 최신 정보, 리서치 | 로컬 파일 작업 |

---

## Context7
**Purpose**: 공식 라이브러리 문서 조회 및 프레임워크 패턴 가이드

**Triggers**: `import`, `require`, `from` | 프레임워크 키워드 | 버전별 구현 필요

**Examples**:
- "implement React useEffect" → Context7
- "add Auth0 authentication" → Context7
- "just explain this function" → Native Claude

---

## Magic
**Purpose**: 21st.dev 패턴 기반 모던 UI 컴포넌트 생성

**Triggers**: `/ui`, `/21` 명령 | button, form, modal, card, table, nav

**Examples**:
- "create a login form" → Magic
- "build responsive navbar" → Magic
- "write a REST API" → Native Claude

---

## Morphllm
**Purpose**: 토큰 최적화된 패턴 기반 코드 편집 엔진

**Triggers**: 다중 파일 편집 | 스타일 적용 | 벌크 텍스트 치환

**Examples**:
- "update all class components to hooks" → Morphllm
- "replace console.log with logger" → Morphllm
- "rename getUserData everywhere" → Serena (심볼 작업)

---

## Playwright
**Purpose**: 실제 브라우저 상호작용 및 E2E 테스트

**Triggers**: 브라우저 테스트 | 스크린샷 | 폼 제출 테스트 | 접근성 검증

**Examples**:
- "test the login flow" → Playwright
- "take responsive screenshots" → Playwright
- "review function logic" → Native Claude

---

## Sequential
**Purpose**: 복잡한 분석 및 체계적 문제 해결을 위한 다단계 추론

**Triggers**: `--think`, `--think-hard`, `--ultrathink` | 다층 디버깅 | 아키텍처 분석

**Examples**:
- "why is this API slow?" → Sequential
- "design microservices architecture" → Sequential
- "explain this function" → Native Claude

---

## Serena
**Purpose**: 프로젝트 메모리 및 세션 지속성을 갖춘 시맨틱 코드 이해

**Triggers**: 심볼 작업 (rename, extract, move) | `/sc:load`, `/sc:save` | LSP 통합

**Examples**:
- "rename getUserData everywhere" → Serena
- "find all references to this class" → Serena
- "load my project context" → Serena

---

## Tavily
**Purpose**: 리서치 및 최신 정보를 위한 웹 검색

**Triggers**: `/sc:research` | 지식 컷오프 이후 정보 | 팩트체킹 | 경쟁 분석

**Config**: `TAVILY_API_KEY` 환경변수 필요

**Search Types**: Web | News | Academic | Domain-filtered

**Examples**:
- "latest TypeScript features 2024" → Tavily
- "OpenAI updates this week" → Tavily
- "explain recursion" → Native Claude

**Fallback**: Native WebSearch

---

## Server Combinations

| Task | Primary | Secondary |
|------|---------|-----------|
| 프레임워크 UI 구현 | Magic | Context7 |
| 복잡한 리팩토링 | Serena | Morphllm |
| 리서치 + 분석 | Tavily | Sequential |
| E2E 테스트 설계 | Sequential | Playwright |
| 문서 기반 코딩 | Context7 | Sequential |

---

## Flag Reference

```
--c7, --context7    → Context7 활성화
--magic             → Magic 활성화
--morph, --morphllm → Morphllm 활성화
--play, --playwright → Playwright 활성화
--seq, --sequential → Sequential 활성화
--serena            → Serena 활성화
--tavily            → Tavily 활성화
--all-mcp           → 전체 MCP 활성화
--no-mcp            → MCP 비활성화 (네이티브만)
```
