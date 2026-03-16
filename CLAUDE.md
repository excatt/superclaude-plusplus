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
| 구현 전 | `/confidence-check` | 구현, 만들어, implement, create, build |
| 완료 후 | `/verify` | 완료, done, finished, PR |
| 빌드 에러 | `/build-fix` | error TS, Build failed |
| React 리뷰 | `/react-best-practices` | .tsx + 리뷰, review |
| Python 리뷰 | `/python-best-practices` | .py + 리뷰, review |
| UI 리뷰 | `/web-design-guidelines` | UI 리뷰, 접근성, a11y |
| 위험 작업 | `/checkpoint` | 리팩토링, 삭제, refactor, delete |
| **커밋/PR** | **Two-Stage Review** | 커밋, PR, 머지, 리뷰해줘, commit, merge, review |
| **완료 주장** | **Verification Gate** | 됐어, 작동해, 통과, fixed, works, passes |
| **수정 3회 실패** | **Architecture Alert + Struggle Report** | (자동 감지) |
| **에이전트 스폰** | **Worker Template** | Task tool 사용 시 |
| 테스트 실패 | `/debug` | pytest FAILED, test failed |
| 복잡한 함수 | `/code-smell` | 50줄+ 함수 생성 |
| 에러 핸들링 누락 | `/error-handling` | async/await + no try-catch |
| Next.js 작업 | `/nextjs` | page.tsx, layout.tsx, route.ts |
| FastAPI 작업 | `/fastapi` | @router, APIRouter |
| 대규모 변경 | `/checkpoint` | 10+ 파일 수정 예정 |
| 프로젝트 규칙 검증 | `/audit` | commit, PR + `.claude/audit-rules/` 존재 시 |
| Harness 세션 종료 | `codebase-gc` (제안) | `--harness` 모드 세션 완료 시 |

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
| 새 패턴 도입 | `/audit manage` | 새 컨벤션, 아키텍처 패턴 |
| UI/UX 디자인 | `/ui-ux-pro-max` | landing page, 디자인 시스템, 스타일 |

**제안 강도**: `--suggest-all` (기본) | `--suggest-minimal` | `--suggest-off`

### By Domain (Suggest when relevant)
- **Analysis**: `/think`, `/debug`, `/code-review`, `/code-smell`
- **Architecture**: `/architecture`, `/api-design`, `/db-design`, `/design-patterns`
- **Security**: `/security-audit`, `/auth`, `/error-handling`
- **Performance**: `/perf-optimize`, `/caching`, `/scaling`
- **Frontend**: `/react-best-practices`, `/composition-patterns`, `/web-design-guidelines`, `/responsive`, `/a11y`, `/state`, `/seo`, `/ui-ux-pro-max`
- **Backend**: `/graphql`, `/websocket`, `/queue`, `/pagination`, `/rate-limit`
- **Python**: `/python-best-practices`, `/pytest-runner`, `/uv-package`, `/fastapi`
- **DevOps**: `/docker`, `/cicd`, `/monitoring`, `/env`
- **Git**: `/git-workflow`, `/commit-msg`, `/versioning`
- **Quality**: `/clean-code`, `/refactoring`, `/testing`, `/audit`

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
| 코드베이스 정리 | `codebase-gc` |

## Memory Management

### Auto Memory (내장)
Claude가 `~/.claude/projects/<project>/memory/`에 자동으로 학습 내용을 기록합니다.

**저장 내용**: 프로젝트 패턴, 디버깅 인사이트, 아키텍처 노트, 사용자 선호도

**명시적 저장 요청**:
- "이 프로젝트는 pnpm 사용한다고 기억해"
- "API 테스트는 로컬 Redis 필요하다고 저장해"
- "이 버그 해결 패턴 기억해둬"

**메모리 확인/편집**: `/memory` 명령어

### CLAUDE.md vs Auto Memory

| 용도 | 사용할 곳 |
|------|----------|
| 팀 공유 규칙 | `./CLAUDE.md` 또는 `.claude/rules/` |
| 개인 선호도 (전역) | `~/.claude/CLAUDE.md` |
| 개인 선호도 (프로젝트) | `./CLAUDE.local.md` |
| Claude가 학습한 것 | Auto Memory (자동) |

## Workflow Integration
- **Step 0**: Difficulty Assessment (Simple/Medium/Complex) → protocol branching
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed (Medium+)
- **Planning**: `/feature-planner` → `/architecture` (Complex: + reasoning templates)
- **Design**: `/ui-ux-pro-max` → `/frontend-design` → `/web-design-guidelines`
- **Implementation**: Domain-specific skills (Complex: + mid-checkpoint at 50%)
- **Review**: Two-Stage Review (Simple: Stage 1 only | Medium: Stage 1+2 | Complex: + Cascade Impact)
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Verification**: `/verify` → `/audit` (project rules)
- **Post-Implementation**: `/learn`

## Optional References (load on demand)
- `optional/REASONING_TEMPLATES.md` — 구조화된 추론 (디버깅, 아키텍처 결정, 성능 분석)
- `optional/CONTEXT_BUDGET.md` — 컨텍스트 예산 관리 (파일 읽기 전략, 오버플로우 대응)
- `optional/WORKER_TEMPLATES.md` — 워커 에이전트 4요소 프롬프트 템플릿

