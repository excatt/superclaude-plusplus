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
| Before implementation | `/confidence-check` | implement, create, build |
| After completion | `/verify` | done, finished, PR |
| Build error | `/build-fix` | error TS, Build failed |
| React review | `/react-best-practices` | .tsx + review |
| Python review | `/python-best-practices` | .py + review |
| UI review | `/web-design-guidelines` | UI review, accessibility, a11y |
| Risky operation | `/checkpoint` | refactor, delete |
| **Commit/PR** | **Two-Stage Review** | commit, PR, merge, review |
| **Completion claim** | **Verification Gate** | fixed, works, passes |
| **3+ fix failures** | **Architecture Alert** | (auto-detect) |
| **Agent spawn** | **Worker Template** | When using Task tool |
| Test failure | `/debug` | pytest FAILED, test failed |
| Complex function | `/code-smell` | 50+ line function created |
| Missing error handling | `/error-handling` | async/await + no try-catch |
| Next.js work | `/nextjs` | page.tsx, layout.tsx, route.ts |
| FastAPI work | `/fastapi` | @router, APIRouter |
| Large-scale change | `/checkpoint` | 10+ files to modify |
| Project rule validation | `/audit` | commit, PR + `.claude/audit-rules/` exists |

### Proactive Suggestions (Confirm before run)
**💡 Active suggestion mode**: Auto-detect relevant tools and suggest (confirm before run)

| Situation | Suggested Tool | Trigger |
|------|----------|--------|
| Complex function | `/code-review`, `/code-smell` | 50+ line function |
| API design | `/api-design`, `backend-architect` | endpoint, REST |
| Performance issue | `performance-engineer` | slow, optimize |
| Security related | `security-engineer`, `/auth` | login, JWT, security |
| Framework | **Context7** MCP | React, Next.js, Vue |
| UI component | **Magic** MCP | button, form, modal |
| Complex analysis | **Sequential** MCP | 3+ debug attempts, design |
| New pattern adoption | `/audit manage` | new convention, architecture pattern |

**Suggestion intensity**: `--suggest-all` (default) | `--suggest-minimal` | `--suggest-off`

### By Domain (Suggest when relevant)
- **Analysis**: `/think`, `/debug`, `/code-review`, `/code-smell`
- **Architecture**: `/architecture`, `/api-design`, `/db-design`, `/design-patterns`
- **Security**: `/security-audit`, `/auth`, `/error-handling`
- **Performance**: `/perf-optimize`, `/caching`, `/scaling`
- **Frontend**: `/react-best-practices`, `/composition-patterns`, `/web-design-guidelines`, `/responsive`, `/a11y`, `/state`, `/seo`
- **Backend**: `/graphql`, `/websocket`, `/queue`, `/pagination`, `/rate-limit`
- **Python**: `/python-best-practices`, `/pytest-runner`, `/uv-package`, `/fastapi`
- **DevOps**: `/docker`, `/cicd`, `/monitoring`, `/env`
- **Git**: `/git-workflow`, `/commit-msg`, `/versioning`
- **Quality**: `/clean-code`, `/refactoring`, `/testing`, `/audit`

### Agent Auto-Suggestion
| Task Type | Recommended Agent |
|----------|--------------|
| Frontend | `frontend-architect` |
| Backend/API | `backend-architect` |
| System design | `system-architect` |
| Python work | `python-expert` |
| Testing/QA | `quality-engineer` |
| Security review | `security-engineer` |
| Performance optimization | `performance-engineer` |
| Documentation | `technical-writer` |
| Problem analysis | `root-cause-analyst` |
| Refactoring | `refactoring-expert` |

## Memory Management

### Auto Memory (Built-in)
Claude automatically records learning in `~/.claude/projects/<project>/memory/`.

**Stored content**: Project patterns, debugging insights, architecture notes, user preferences

**Explicit save requests**:
- "Remember this project uses pnpm"
- "Save that API tests require local Redis"
- "Remember this bug resolution pattern"

**Check/edit memory**: `/memory` command

### CLAUDE.md vs Auto Memory

| Purpose | Where to Use |
|------|----------|
| Team shared rules | `./CLAUDE.md` or `.claude/rules/` |
| Personal preference (global) | `~/.claude/CLAUDE.md` |
| Personal preference (project) | `./CLAUDE.local.md` |
| What Claude learned | Auto Memory (automatic) |

## Workflow Integration
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed
- **Planning**: `/feature-planner` → `/architecture`
- **Implementation**: Domain-specific skills
- **Review**: `/code-review`, `/security-audit`, `/web-design-guidelines`
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Verification**: `/verify` → `/audit` (project rules)
- **Post-Implementation**: `/learn`
