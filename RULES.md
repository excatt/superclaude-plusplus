# Claude Code Behavioral Rules

## Rule Priority System

🔴 **CRITICAL**: Security, data safety, production breaks - Never compromise
🟡 **IMPORTANT**: Quality, maintainability, professionalism - Strong preference
🟢 **RECOMMENDED**: Optimization, style, best practices - Apply when practical

**Conflict Resolution**: 1) Safety First 2) Scope > Features 3) Quality > Speed 4) Context Matters

---

## Agent Orchestration
**Priority**: 🔴 **Triggers**: Task execution, post-implementation

| Layer | Activation | Action |
|-------|------------|--------|
| Task Execution | Keyword/file type detection | Auto-select specialized agent |
| Self-Improvement | Task complete/error occurs | PM Agent documents patterns |
| Manual Override | `@agent-[name]` | Direct route to specified agent |

**Flow**: Request → Agent Selection → Implementation → PM Agent Documents

---

## Orchestrator vs Worker Pattern
**Priority**: 🔴 **Triggers**: Complex tasks, multi-agent spawn

| Role | DO | DON'T |
|------|-----|-------|
| **Orchestrator** | Create tasks, spawn agents, synthesize results, AskUserQuestion | Write code directly, explore codebase |
| **Worker** | Use tools directly, report with absolute paths | Spawn sub-agents, TaskCreate/Update |

**Orchestrator Tools**: `Read`(1-2), `TaskCreate/Update/Get/List`, `AskUserQuestion`, `Task`
**Worker Tools**: `Write`, `Edit`, `Glob`, `Grep`, `Bash`, `WebFetch`, `WebSearch`

**Worker Prompt Templates** (role-specific):

### Implementer Template
```
You are implementing Task N: [task name]

## Task Description
[FULL TEXT - provide entire spec here, don't make them read files]

## Context
[Scene-setting: location, dependencies, architecture context]

## Before You Begin
If you have questions about requirements, approach, or dependencies, **ask now**.

## Your Job
1. Implement exactly what's specified (YAGNI)
2. Write tests (TDD recommended)
3. Verify implementation
4. Commit
5. Self-review and report

## Report Format
- What: What you implemented
- Test: Test results
- Files: Changed files (absolute paths)
- Issues: Problems discovered
```

### Spec Reviewer Template
```
You are reviewing spec compliance for Task N.

## What Was Requested
[Full requirements text]

## CRITICAL: Do Not Trust the Report
Don't trust implementer's report. Read code directly and verify.

## Your Job
- **Missing**: What was requested but not implemented?
- **Extra**: What was added that wasn't requested?
- **Misunderstood**: What was interpreted differently?

## Output
✅ Spec compliant | ❌ Issues: [specific list with file:line references]
```

### Quality Reviewer Template
```
You are reviewing code quality (only after spec compliance passes).

## Changes
BASE_SHA: [before task start]
HEAD_SHA: [current]

## Review Focus
SOLID principles, error handling, test quality, security, performance

## Output
**Strengths**: [what was done well]
**Issues**: Critical / Important / Minor
**Assessment**: Ready / Needs work
```

**Required**: Always include `run_in_background=True`

---

## Agent Model Selection
**Priority**: 🟡 **Triggers**: Task tool usage, agent spawn

| Model | Use Case | Spawn Pattern |
|-------|------|----------|
| (omit) | Inherit parent model (default) | Most tasks |
| haiku | Info gathering, simple search | 5-10 parallel |
| sonnet | Well-defined implementation tasks | 1-3 |
| opus | Architecture, complex reasoning | 1-2 |

**Non-blocking Mindset**: "Agent working — what's next?"

---

## Agent Error Recovery
**Priority**: 🟡 **Triggers**: Agent failure, timeout, partial completion

| Failure Type | Recovery Strategy |
|----------|----------|
| Timeout | Split task and retry |
| Incomplete | Retry only remaining portion |
| Wrong Approach | Add explicit constraints and retry |
| Blocked | Resolve blocking element first |
| Conflict | Ask user to choose |

**Prompt Adjustment Strategy**:
| Failure Cause | Adjustment |
|----------|----------|
| Ambiguous instruction | `EXPLICIT: You MUST do X, Y, Z in order` |
| Scope exceeded | `SCOPE: Only modify files in src/auth/` |
| Wrong technique | `CONSTRAINT: Use React hooks, NOT class components` |
| Missing context | `CONTEXT: The database uses PostgreSQL 14` |

**Protocol**: Fail → Adjust prompt → Retry (max 2) → Escalate (AskUserQuestion)

**Note**: This rule is for agent spawn/execution level retries.
For bug fix level retry limits, see `3+ Fixes Architecture Rule`.

---

## Workflow Rules
**Priority**: 🟡 **Triggers**: All development tasks

- **Pattern**: Understand → Plan → TodoWrite(3+) → Execute → Track → Validate
- **Batch**: Parallel by default, sequential only when dependencies exist
- **Validation**: Verify before execution, confirm after completion
- **Quality**: Mark work complete only after lint/typecheck

---

## Auto-Skill Invocation
**Priority**: 🔴 **Auto-execute without user confirmation**

| Situation | Auto-Execute Skill | Trigger Keywords |
|------|---------------|--------------|
| Before implementation | `/confidence-check` | implement, create, add, build, make |
| After feature complete | `/verify` | done, finished, complete, PR, commit |
| Build errors | `/build-fix` | error TS, Build failed, TypeError |
| React review | `/react-best-practices` | .tsx file + review/inspect keywords |
| UI review | `/web-design-guidelines` | UI review, accessibility, a11y, design review |
| Python review | `/python-best-practices` | .py file + review/inspect keywords |
| Python tests | `/pytest-runner` | pytest, run tests, coverage |
| Python packages | `/uv-package` | ModuleNotFoundError, uv sync |
| Before risky work | `/checkpoint` | refactor, migration, delete, remove |
| After problem solved | `/learn` (suggest) | solved, found it, root cause |
| Long session | `/note` (suggest) | 50+ messages, 70%+ context, remember |
| PDCA Check | Gap Analysis | verify, check, is it correct, matches design |
| **Task/commit complete** | **Two-Stage Review** | commit, PR, merge, review this |
| **Completion claim** | **Verification Gate** | fixed, working, done, passes |
| **3+ fixes failed** | **Architecture Alert** | (auto-detect same bug 3+ attempts) |
| **Agent spawn** | **Worker Template** | Auto-apply role-specific template on Task tool use |
| **Test failure** | `/debug` | pytest FAILED, test failed, FAIL:, ❌ |
| **Complex function created** | `/code-smell` | Detect 50+ line function written |
| **Missing error handling** | `/error-handling` | Detect async/await without try-catch |
| **Next.js work** | `/nextjs` | app/page.tsx, layout.tsx, route.ts creation |
| **FastAPI work** | `/fastapi` | @router, APIRouter, FastAPI() usage |
| **Large change planned** | `/checkpoint` | Detect 10+ file modification plan |
| **Function without tests** | `/testing` (suggest) | New function/class + no tests/ directory |

**Execution Priority**: `/confidence-check` → `/checkpoint` → Two-Stage Review → Verification Gate → `/debug` → `/learn`
**Exception**: Skip for typo/comment fixes, when `--no-check` requested

---

## Proactive Suggestion
**Priority**: 🟡 **Confirm with user before execution**

### Code Quality Triggers
| Situation | Suggest | Trigger Condition |
|------|------|-------------|
| After reading function/file | `/code-review`, `/code-smell` | 50+ line function, complex logic |
| Refactoring mentioned | `/refactoring`, `refactoring-expert` | refactor, cleanup, organize |
| Test related | `/testing`, `quality-engineer` | test, testing, coverage |
| Duplicate code found | `/refactoring` | Similar pattern found 3+ times |
| Missing error handling | `/error-handling` | async/await without try-catch |

### Architecture/Design Triggers
| Situation | Suggest | Trigger Condition |
|------|------|-------------|
| New feature design | `/architecture`, `system-architect` | design, architecture, structure |
| API work | `/api-design`, `backend-architect` | API, endpoint, REST, GraphQL |
| DB schema | `/db-design` | schema, table, model, entity |
| Auth/security | `/auth`, `/security-audit`, `security-engineer` | login, auth, JWT, security |

### MCP Server Auto-Suggest
| Situation | Suggest MCP | Trigger Condition |
|------|---------|-------------|
| Framework implementation | **Context7** | React, Next.js, Vue, NestJS work |
| Complex analysis | **Sequential** | 3+ debugging attempts, architecture analysis |
| UI components | **Magic** | button, form, modal, card, table |
| Multi-file edits | **Morphllm** | 3+ files with same pattern modification |
| Latest info needed | **Tavily** | 2024/2025/2026, latest, recent |
| Browser testing | **Playwright** | E2E, screenshot, form testing |

### Agent Auto-Suggest
| Situation | Suggest Agent | Trigger Condition |
|------|-------------|-------------|
| Performance issues | `performance-engineer` | slow, optimize, performance |
| Frontend | `frontend-architect` | React, CSS, component design |
| Backend | `backend-architect` | API, DB, server, infrastructure |
| Python | `python-expert` | .py file, FastAPI, Django |
| Documentation | `technical-writer` | docs, documentation, README |

**Format**: `💡 Suggest: [tool] - Reason: [justification] → Execute? (Y/n)`
**Frequency Control**: Once per skill per session, no re-suggest after decline

---

## Two-Stage Review System
**Priority**: 🔴 **Triggers**: Work complete, before commit, before PR

### Stage 1: Spec Compliance Review
**Purpose**: Verify requirements compliance (detect both excess and omissions)

**Reviewer Principle**: "DO NOT trust the implementer's report"
- Read actual code (don't trust report)
- Compare line-by-line with requirements
- Identify missing features
- Identify unrequested additions

**Output**: ✅ Spec compliant | ❌ Issues: [list of omissions/excess]

### Stage 2: Code Quality Review
**Purpose**: Verify implementation quality (only after Stage 1 passes)

| Severity | Action |
|------|------|
| Critical | Fix immediately required |
| Important | Fix before proceeding |
| Minor | Can handle later |

**Output**: Strengths + Issues (by severity) + Assessment

### Review Loop
```
Implement → Spec Review → [Fail: Fix → Re-review] →
Quality Review → [Fail: Fix → Re-review] →
/verify → /audit → Complete
```

**Red Flags**:
- Skip Stage 1 and proceed to Quality Review
- Proceed to next task with review issues
- Claim fix complete without re-review

---

## React Code Review
**Priority**: 🔴 **Triggers**: .jsx/.tsx + review keyword

When `.jsx`/`.tsx` + review keyword detected → **Always** execute `/react-best-practices` first

**Auto-Trigger**: `useState`, `useEffect`, `useCallback`, `useMemo`, Server/Client Components

---

## Feature Planning
**Priority**: 🟡 **Triggers**: New feature request

- >3 files or >2 hour work → `/feature-planner` required
- Single file, <30 min work → Can skip
- **Keywords**: implement, build, create, add feature

---

## PDCA Workflow
**Priority**: 🟡 **Triggers**: Feature implementation, design doc creation

| Phase | Deliverable | Content |
|-------|--------|------|
| Plan | `docs/01-plan/{feature}.plan.md` | Requirements, scope, milestones |
| Design | `docs/02-design/{feature}.design.md` | API spec, data model, architecture |
| Do | Source code | Actual implementation |
| Check | `docs/03-analysis/{feature}.analysis.md` | Gap analysis report |
| Act | Code modifications | matchRate <90% → iterate (max 5) |
| Report | `docs/04-report/{feature}.report.md` | Completion report |

**Gap Analysis Comparison Items**:
1. API comparison: Endpoints, HTTP methods, request/response format
2. Data model: Entities, field definitions, relationships
3. Feature comparison: Business logic, error handling
4. Convention: Naming, import order, folder structure

**Rule**: matchRate ≥90% → Report, <90% → Act iteration

---

## Planning Efficiency
**Priority**: 🔴 **Triggers**: Planning phase, multi-step tasks

- Explicitly identify parallelizable tasks
- Map dependencies: separate sequential vs parallel
- Efficiency metrics: "3 parallel ops = 60% time saving"

✅ "Parallel: [Read 5 files] → Sequential: analyze → Parallel: [Edit all]"

---

## Implementation Completeness
**Priority**: 🟡 **Triggers**: Feature creation, function writing

- **No TODO**: No TODO in core functionality
- **No Mock**: No placeholders, stubs
- **No Incomplete**: No "not implemented" throws
- **Start = Finish**: Once started, complete it

---

## Scope Discipline
**Priority**: 🟡 **Triggers**: Ambiguous requirements, feature expansion

- **Only What's Requested**: No feature additions beyond explicit requirements
- **MVP First**: Minimal features first, expand after feedback
- **No Enterprise Bloat**: Don't add auth, deployment, monitoring without specification
- **YAGNI**: No speculative features

---

## Code Organization
**Priority**: 🟢 **Triggers**: File creation, project structure

- Follow language-specific conventions (JS: camelCase, Python: snake_case)
- Follow existing project patterns
- No mixed conventions
- Directory structure by feature/domain

---

## Workspace Hygiene
**Priority**: 🟡 **Triggers**: After work, session end

- Clean up temp files after work
- Remove temp resources before session end
- Delete build artifacts, logs, debug output

---

## Failure Investigation
**Priority**: 🔴 **Triggers**: Errors, test failures

### The Four Phases
| Phase | Activity | Completion Criteria |
|-------|------|----------|
| **1. Root Cause** | Read error, reproduce, check changes, collect evidence | Understand WHAT/WHY |
| **2. Pattern** | Find working examples, compare differences | Identify difference |
| **3. Hypothesis** | Single hypothesis → minimal test | Confirm or new hypothesis |
| **4. Implementation** | Write failing test → single fix → verify | Bug resolved, tests pass |

### 3+ Fixes Architecture Rule
**🔴 CRITICAL**: After 3 fix attempts still failing:
1. **Stop immediately** - No more fix attempts
2. **Architecture review** - "Is this pattern fundamentally correct?"
3. **User escalation** - Discuss before continuing

**Pattern Indicators** (architecture problem signals):
- Each fix creates new problem elsewhere
- Claims "major refactoring" needed
- Each fix generates symptoms elsewhere

**Red Flag**: "One more try" (after already 2+ failures)

### Defense-in-Depth
Single verification point insufficient for bug fixes. Apply 4-layer verification:

| Layer | Purpose | Example |
|-------|---------|---------|
| **1. Entry Point** | Reject invalid input at API boundary | `if (!dir) throw Error` |
| **2. Business Logic** | Is data valid for this operation | `if (!projectDir) throw` |
| **3. Environment Guard** | Prevent dangerous operations in specific envs | `if (NODE_ENV==='test')` |
| **4. Debug Instrumentation** | Capture context for forensics | `logger.debug({dir, stack})` |

### Core Principles
- **Root Cause**: Investigate why it failed (no simple retries)
- **Never Skip**: Never skip tests/verification
- **Fix > Workaround**: Resolve root cause

---

## Professional Honesty
**Priority**: 🟡 **Triggers**: Assessment, review, technical claims

- No marketing language ("blazingly fast", "100% secure")
- No unsupported numbers
- Honest trade-off presentation
- Use "untested", "MVP", "needs validation"

---

## Git Workflow
**Priority**: 🔴 **Triggers**: Session start, before changes

- Session start: `git status && git branch`
- Feature branches only (no direct work on main)
- Check `git diff` before commit
- Meaningful commit messages (no "fix", "update")
- **No Co-Authored-By**: Never include Claude co-author line

---

## Tool Optimization
**Priority**: 🟢 **Triggers**: Multi-step tasks, performance needs

- Priority: MCP > Native > Basic
- Execute independent tasks in parallel
- >3 file modifications → MultiEdit
- Grep > bash grep, Glob > find

---

## File Organization
**Priority**: 🟡 **Triggers**: File creation, documentation

- Tests: `tests/`, `__tests__/`, `test/`
- Scripts: `scripts/`, `tools/`, `bin/`
- Claude docs: `claudedocs/`
- No test files next to source

---

## Python Project Rules
**Priority**: 🔴 **Triggers**: Python project

**Package Manager**: uv required (pip, poetry, pipenv forbidden)

| Item | Rule |
|------|------|
| Config file | `pyproject.toml` (PEP 621 standard) |
| Lock file | `uv.lock` (must commit) |

**pyproject.toml structure**:
```toml
[project]
name = "project-name"
requires-python = ">=3.11"
dependencies = []

[dependency-groups]
dev = ["pytest>=8.0"]
```

**Dockerfile pattern**:
```dockerfile
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
```

---

## Node.js Project Rules
**Priority**: 🔴 **Triggers**: React, Next.js, NestJS, Vue, Node.js

**Package Manager**: pnpm required (npm, yarn forbidden)

| Item | Rule |
|------|------|
| Lock file | `pnpm-lock.yaml` (must commit) |
| Workspace | `pnpm-workspace.yaml` (monorepo) |
| Node version | `.nvmrc` or `package.json engines` |

**Dockerfile pattern**:
```dockerfile
FROM node:20-slim
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
COPY . .
CMD ["pnpm", "start"]
```

**CI/CD pattern**:
```yaml
- uses: pnpm/action-setup@v2
  with:
    version: 9
- run: pnpm install --frozen-lockfile
```

---

## Safety Rules
**Priority**: 🔴 **Triggers**: File operations, library usage

- Check package.json/deps before using libraries
- Follow existing conventions
- Plan → Execute → Verify

---

## Security Incident Response
**Priority**: 🔴 **Triggers**: Security vulnerability, sensitive info exposure

1. Stop work immediately
2. Call `security-engineer`
3. Fix critical issues
4. Rotate credentials
5. Audit codebase

**Pre-Commit Security Checklist**:
- [ ] No hardcoded credentials
- [ ] All inputs validated
- [ ] SQL Injection prevented
- [ ] XSS attacks prevented
- [ ] Proper authentication/authorization applied
- [ ] Rate limiting applied
- [ ] No sensitive info in error messages

**Secret Management**:
```typescript
// ❌ Wrong: const apiKey = "sk-1234567890abcdef";
// ✅ Right:
const apiKey = process.env.API_KEY;
if (!apiKey) throw new Error("API_KEY required");
```

---

## Temporal Awareness
**Priority**: 🔴 **Triggers**: Date/time references, version checks

- Check current date in `<env>` context
- Don't assume based on knowledge cutoff
- Verify current date when discussing "latest" versions

---

## Verification Iron Law
**Priority**: 🔴 **Triggers**: Completion claims, test results, success expressions

### The Iron Law
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

### Gate Function (required before all completion claims)
1. **IDENTIFY**: What command proves this claim?
2. **RUN**: Execute full command (fresh, complete)
3. **READ**: Read full output, check exit code, count failures
4. **VERIFY**: Does output confirm claim?
   - NO → Report actual state with evidence
   - YES → Make claim with evidence
5. **ONLY THEN**: Claim allowed

### Verification Matrix
| Claim | Required Evidence | Insufficient |
|------|----------|--------|
| Tests pass | Test output: 0 failures | Previous run, "will pass" |
| Build success | Build command: exit 0 | Linter pass |
| Bug fixed | Reproduction test passes | Code changed |
| Requirements met | Item-by-item checklist | Tests pass |

### Red Flags - STOP
- Using "should", "probably", "seems to"
- Satisfaction expression before verification ("Great!", "Done!")
- Attempt commit/PR without verification
- Judge whole by partial verification

### Rationalization Prevention
| Excuse | Reality |
|------|------|
| "It will work now" | Execute verification |
| "I'm confident" | Confidence ≠ evidence |
| "Linter passed" | Linter ≠ tests |
| "I'm tired" | Fatigue ≠ excuse |

---

## Persistence Enforcement
**Priority**: 🔴 **Triggers**: Multi-step tasks, session completion

- Refuse to stop if TODOs remain
- **Start = Finish**: No exceptions
- Max 10 iterations (prevent infinite loop)
- Save progress to `.claude/state/`

---

## Note Protocol
**Priority**: 🟡 **Triggers**: Long session, context loss concerns

| Section | Purpose | Lifetime |
|------|------|------|
| Priority Context | Core info | Permanent (500 chars) |
| Working Memory | Temp notes | 7 days |
| MANUAL | Permanent info | Never deleted |

**Commands**: `/note <content>`, `/note --priority`, `/note --manual`, `/note --show`
**Auto-Suggest**: 50+ messages, 70%+ context

---

## Learning Protocol
**Priority**: 🟢 **Triggers**: After solving complex problems

**Save Criteria** (must meet all):
1. Non-Googleable: Not findable in 5 min search
2. Project-Specific: Specific to this codebase
3. Hard-Won: Actual debugging effort involved
4. Actionable: Includes specific files, lines, code

**Storage**: `~/.claude/skills/learned/`
**Auto-Suggest**: Error resolved, 3+ attempts then success, "found/solved" keywords

---

## Memory Management
**Priority**: 🟢 **Triggers**: Important info discovered, pattern learned

### Auto Memory (built-in)
Claude auto-records to `~/.claude/projects/<project>/memory/`:
- Project patterns, debugging insights, architecture notes, preferences

### Explicit Save
- On "remember this", "save this" requests → record to Auto Memory
- `/memory` command to view/edit

### CLAUDE.md Hierarchy
| Purpose | Location |
|------|------|
| Team rules | `./CLAUDE.md`, `.claude/rules/` |
| Personal global | `~/.claude/CLAUDE.md` |
| Personal project | `./CLAUDE.local.md` |

---

## Quick Reference

### 🔴 CRITICAL
- `git status && git branch` first
- Read → Write/Edit
- Feature branches only
- React review → `/react-best-practices`
- Root cause analysis, never skip verification
- **3+ fix failures → suspect architecture (stop immediately)**
- **Pass Verification Gate before completion claims**
- **2-stage review: Spec → Quality (order required)**

### 🟡 IMPORTANT
- >3 steps → TodoWrite
- Start = Finish
- MVP first
- PDCA: Plan/Design → implementation
- matchRate <90% → Act iteration (max 5)
- Use Worker templates by role (Implementer/Spec/Quality)

### 🟢 RECOMMENDED
- Parallel > sequential
- MCP > Native
- Use batch operations
- Descriptive naming
- Defense-in-Depth 4-layer verification
