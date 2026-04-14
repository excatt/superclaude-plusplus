# SuperClaude++ v2.0

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
@CONTEXTS.md
@KNOWLEDGE.md

## Skill System (v2.0)

**118 skills unified under `skills/`. All 0-token when idle.**

### Skill Activation
- **Auto-Invoke**: `UserPromptSubmit` hook in `.claude/skill-rules.json` analyzes prompts for mechanical matching (implemented in Phase 2)
- **Manual**: Direct invocation via `/skill-name`
- **Proactive**: Context-based auto-suggestion (confirmation required before execution)

**Suggestion intensity**: `--suggest-all` (default) | `--suggest-minimal` | `--suggest-off`

### Core Skills (Always Active)
| Skill | Purpose |
|-------|---------|
| `/confidence-check` | Pre-implementation confidence assessment (≥90% required, Medium+ difficulty) |
| `/verify` | 6-phase verification (build → type → lint → test → security → diff) |
| `/checkpoint` | Create restore point before risky operations |
| `/tdd` | Enforce RED-GREEN-REFACTOR cycle |
| `/build-fix` | Resolve build errors with minimal changes |
| `/audit` | Validate project rules |
| `/learn` | Extract and save patterns |
| `/note` | Persist memos across sessions |

### Domain Skills (118 total, major categories)
- **Analysis**: `/think`, `/debug`, `/code-review`, `/code-smell`, `/analyze`
- **Architecture**: `/architecture`, `/api-design`, `/db-design`, `/design-patterns`, `/design`
- **Security**: `/security-audit`, `/auth`, `/error-handling`
- **Performance**: `/perf-optimize`, `/caching`, `/scaling`
- **Frontend**: `/react-best-practices`, `/composition-patterns`, `/web-design-guidelines`, `/responsive`, `/a11y`, `/state`, `/seo`, `/ui-ux-pro-max`
- **Backend**: `/graphql`, `/websocket`, `/queue`, `/pagination`, `/rate-limit`, `/fastapi`
- **Python**: `/python-best-practices`, `/pytest-runner`, `/uv-package`
- **DevOps**: `/docker`, `/cicd`, `/monitoring`, `/env`
- **Git**: `/git-workflow`, `/commit-msg`, `/versioning`, `/git`
- **Quality**: `/clean-code`, `/refactoring`, `/testing`, `/audit`
- **Critical Review**: `/devils-advocate` (decisions, plans, architecture challenge)
- **Workflow**: `/brainstorm`, `/implement`, `/improve`, `/explain`, `/estimate`, `/research`

### Agent System (18 agents, AGENT.md frontmatter)

All agents have `model`, `tools`, `maxTurns`, and `effort` enforced via frontmatter.

| Task Type | Agent | model | effort |
|-----------|-------|-------|--------|
| Frontend | `frontend-architect` | sonnet | high |
| Backend/API | `backend-architect` | opus | high |
| System Design | `system-architect` | opus | high |
| Python | `python-expert` | sonnet | high |
| Testing/QA | `quality-engineer` | sonnet | medium |
| Security Review | `security-engineer` | opus | high |
| Performance | `performance-engineer` | sonnet | high |
| Documentation | `technical-writer` | sonnet | medium |
| Root Cause | `root-cause-analyst` | opus | high |
| Refactoring | `refactoring-expert` | sonnet | high |
| Research | `deep-research-agent` | opus | max |
| Codebase Cleanup | `codebase-gc` | haiku | medium |

## Memory Management

### Auto Memory (Built-in)
Claude automatically records learnings to `~/.claude/projects/<project>/memory/`.

**Stored content**: Project patterns, debugging insights, architecture notes, user preferences

**Explicit save requests**:
- "이 프로젝트는 pnpm 사용한다고 기억해"
- "API 테스트는 로컬 Redis 필요하다고 저장해"
- "이 버그 해결 패턴 기억해둬"

**View/edit memory**: `/memory` command

### CLAUDE.md vs Auto Memory

| Purpose | Location |
|---------|----------|
| Team shared rules | `./CLAUDE.md` or `.claude/rules/` |
| Personal preferences (global) | `~/.claude/CLAUDE.md` |
| Personal preferences (project) | `./CLAUDE.local.md` |
| Claude's learned knowledge | Auto Memory (automatic) |

## Workflow Integration
- **Step 0**: Difficulty Assessment (Simple/Medium/Complex) → protocol branching
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed (Medium+)
- **Planning**: `/feature-planner` → `/architecture` (Complex: + reasoning templates)
- **Design**: `DESIGN.md` (if exists) → `/ui-ux-pro-max` → `/frontend-design` → `/web-design-guidelines`
- **Implementation**: Domain-specific skills (Complex: + mid-checkpoint at 50%)
- **Review**: Two-Stage Review (Simple: Stage 1 only | Medium: Stage 1+2 | Complex: + Cascade Impact)
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Verification**: `/verify` → `/audit` (project rules)
- **Post-Implementation**: `/learn`

### DESIGN.md (Visual Design System)
AI 에이전트가 읽는 디자인 시스템 문서 ([Google Stitch format](https://stitch.withgoogle.com/docs/design-md/overview/)).

| File | Who reads it | What it defines |
|------|-------------|-----------------|
| `AGENTS.md` | Coding agents | How to build the project |
| `DESIGN.md` | Design agents | How the project should look and feel |

**Usage**:
- **Install brand design**: `npx getdesign@latest add {brand}` (66 brands: vercel, stripe, linear.app, etc.)
- **Generate custom**: `/ui-ux-pro-max --design-system --persist`
- **Template**: `templates/visual-design.template.md`
- **Collection**: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)

## Optional References (load on demand)
- `optional/REASONING_TEMPLATES.md` — Structured reasoning (debugging, architecture decisions, performance analysis)
- `optional/CONTEXT_BUDGET.md` — Context budget management (file reading strategy, overflow handling)
- `optional/WORKER_TEMPLATES.md` — Worker agent 4-element prompt templates

