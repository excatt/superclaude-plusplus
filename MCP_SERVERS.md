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

## Server Details

| Server | Triggers | Key Examples |
|--------|----------|-------------|
| **Context7** | `import`, `require`, `from`, 프레임워크 키워드, 버전별 구현 | React useEffect → C7, Auth0 → C7 |
| **Magic** | `/ui`, `/21`, button, form, modal, card, table, nav | login form → Magic, navbar → Magic |
| **Morphllm** | 다중 파일 편집, 스타일 적용, 벌크 치환 | class→hooks → Morph, console.log→logger → Morph |
| **Playwright** | 브라우저 테스트, 스크린샷, 폼 제출, 접근성 | login flow test → Play, screenshots → Play |
| **Sequential** | `--think*`, 다층 디버깅, 아키텍처 | API slow → Seq, microservices → Seq |
| **Serena** | 심볼 작업, LSP, `/sc:load`, `/sc:save` | rename everywhere → Serena, find refs → Serena |
| **Tavily** | `/sc:research`, 최신 정보, 팩트체킹, 경쟁 분석. Requires `TAVILY_API_KEY` | latest TS features → Tavily. **Fallback**: WebSearch |

## Server Combinations

| Task | Primary | Secondary |
|------|---------|-----------|
| Framework UI | Magic | Context7 |
| Complex refactoring | Serena | Morphllm |
| Research + analysis | Tavily | Sequential |
| E2E test design | Sequential | Playwright |
| Doc-based coding | Context7 | Sequential |
