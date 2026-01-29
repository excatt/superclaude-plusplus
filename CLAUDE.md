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
| 위험 작업 | `/checkpoint` | 리팩토링, 삭제 |

### By Domain (Suggest when relevant)
- **Analysis**: `/think`, `/debug`, `/code-review`, `/code-smell`
- **Architecture**: `/architecture`, `/api-design`, `/db-design`, `/design-patterns`
- **Security**: `/security-audit`, `/auth`, `/error-handling`
- **Performance**: `/perf-optimize`, `/caching`, `/scaling`
- **Frontend**: `/react-best-practices`, `/responsive`, `/a11y`, `/state`, `/seo`
- **Backend**: `/graphql`, `/websocket`, `/queue`, `/pagination`, `/rate-limit`
- **Python**: `/python-best-practices`, `/pytest-runner`, `/poetry-package`, `/fastapi`
- **DevOps**: `/docker`, `/cicd`, `/monitoring`, `/env`
- **Git**: `/git-workflow`, `/commit-msg`, `/versioning`
- **Quality**: `/clean-code`, `/refactoring`, `/testing`

## Workflow Integration
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed
- **Planning**: `/feature-planner` → `/architecture`
- **Implementation**: Domain-specific skills
- **Review**: `/code-review`, `/security-audit`
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Post-Implementation**: `/verify`, `/learn`
