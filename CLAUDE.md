# SuperClaude Entry Point

## Language
- **ALWAYS respond in Korean (한글)**
- Code comments/variables: English
- Technical terms: English when common (WebSocket, API, etc.)

## Core Framework
@FLAGS.md
@RULES.md
@PRINCIPLES.md
@MODES.md
@MCP_SERVERS.md
@CONVENTIONS.md

## Skill Quick Reference

**Skills are 0-token when idle. Suggest proactively when context matches.**

### Auto-Invoke (No confirmation)
| Trigger | Skill | Keywords |
|---------|-------|----------|
| 구현 전 | `/confidence-check` | 구현, 만들어, implement |
| 완료 후 | `/verify` | 완료, done, PR |
| 빌드 에러 | `/build-fix` | error TS, Build failed |
| React 리뷰 | `/react-best-practices` | .tsx + 리뷰 |
| Python 리뷰 | `/python-best-practices` | .py + 리뷰 |
| UI 리뷰 | `/web-design-guidelines` | UI 리뷰, 접근성, a11y |
| 위험 작업 | `/checkpoint` | 리팩토링, 삭제 |

### Proactive Suggestions (Confirm before run)
**💡 적극 제안 모드**: 관련 도구를 자동 감지하여 제안 (실행 전 확인)

| 상황 | 제안 도구 | 트리거 |
|------|----------|--------|
| 복잡한 함수 | `/code-review`, `/code-smell` | 50줄+ 함수 |
| API 설계 | `/api-design`, `backend-architect` | endpoint, REST |
| 성능 이슈 | `performance-engineer` | 느림, slow, optimize |
| 보안 관련 | `security-engineer`, `/auth` | 로그인, JWT, 보안 |
| 프레임워크 | **Context7** MCP | React, Next.js, Vue |
| UI 컴포넌트 | **Magic** MCP | button, form, modal |
| 복잡한 분석 | **Sequential** MCP | 디버깅 3회+, 설계 |

**제안 강도**: `--suggest-all` (기본) | `--suggest-minimal` | `--suggest-off`

### By Domain (Suggest when relevant)
- **Analysis**: `/think`, `/debug`, `/code-review`, `/code-smell`
- **Architecture**: `/architecture`, `/api-design`, `/db-design`, `/design-patterns`
- **Security**: `/security-audit`, `/auth`, `/error-handling`
- **Performance**: `/perf-optimize`, `/caching`, `/scaling`
- **Frontend**: `/react-best-practices`, `/composition-patterns`, `/web-design-guidelines`, `/responsive`, `/a11y`, `/state`, `/seo`
- **Backend**: `/graphql`, `/websocket`, `/queue`, `/pagination`, `/rate-limit`
- **Python**: `/python-best-practices`, `/pytest-runner`, `/poetry-package`, `/fastapi`
- **DevOps**: `/docker`, `/cicd`, `/monitoring`, `/env`
- **Git**: `/git-workflow`, `/commit-msg`, `/versioning`
- **Quality**: `/clean-code`, `/refactoring`, `/testing`

### Agent Auto-Suggestion
| 작업 유형 | 추천 에이전트 |
|----------|--------------|
| 프론트엔드 | `frontend-architect` |
| 백엔드/API | `backend-architect` |
| 시스템 설계 | `system-architect` |
| Python 작업 | `python-expert` |
| 테스트/QA | `quality-engineer` |
| 보안 검토 | `security-engineer` |
| 성능 최적화 | `performance-engineer` |
| 문서 작성 | `technical-writer` |
| 문제 분석 | `root-cause-analyst` |
| 리팩토링 | `refactoring-expert` |

## Workflow Integration
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed
- **Planning**: `/feature-planner` → `/architecture`
- **Implementation**: Domain-specific skills
- **Review**: `/code-review`, `/security-audit`, `/web-design-guidelines`
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Post-Implementation**: `/verify`, `/learn`
