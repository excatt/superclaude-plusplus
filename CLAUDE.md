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
| **커밋/PR** | **Two-Stage Review** | commit, PR, 머지, 리뷰해줘 |
| **완료 주장** | **Verification Gate** | 됐어, 작동해, fixed, 통과 |
| **수정 3회 실패** | **Architecture Alert** | (자동 감지) |
| **에이전트 스폰** | **Worker Template** | Task tool 사용 시 |
| 테스트 실패 | `/debug` | pytest FAILED, test failed |
| 복잡한 함수 | `/code-smell` | 50줄+ 함수 생성 |
| 에러 핸들링 누락 | `/error-handling` | async/await + no try-catch |
| Next.js 작업 | `/nextjs` | page.tsx, layout.tsx, route.ts |
| FastAPI 작업 | `/fastapi` | @router, APIRouter |
| 세션 시작 | **Context Restore** | 새 세션 시작 |
| 세션 종료 | **Session Summary** | 끝, 오늘은 여기까지 |
| 대규모 변경 | `/checkpoint` | 10+ 파일 수정 예정 |

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

## Session Chaining (NEW)

**세션 간 연속성 보장** - 이전 작업 컨텍스트를 다음 세션에서 자동 활용

| 시점 | 자동 행동 |
|------|----------|
| 세션 시작 | `.claude/context.md` 로드, 이전 세션 요약 표시 |
| 작업 중 | 의사결정 자동 기록, 에러 해결 패턴 추출 |
| 세션 종료 | Session Summary 생성, TODO 이관 |

**저장 계층**:
- `~/.claude/sessions/` - 세션별 요약 (30일)
- `.claude/context.md` - 프로젝트 상태 (영구)
- `~/.claude/skills/learned/` - 학습 패턴 (영구)

**Commands**: `/session-save`, `/session-load`, `/session-end`, `/context-show`

**Flags**: `--chain-full` (기본) | `--chain-minimal` | `--chain-off`

## Workflow Integration
- **Session Start**: Auto-restore context → `/context-show`
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed
- **Planning**: `/feature-planner` → `/architecture`
- **Implementation**: Domain-specific skills
- **Review**: `/code-review`, `/security-audit`, `/web-design-guidelines`
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Post-Implementation**: `/verify`, `/learn`
- **Session End**: `/session-end` → Auto-summary → Pattern extraction
