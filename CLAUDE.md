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

## Skill & Agent System

Skill names/descriptions and available agent types are auto-injected by the
harness every session — they are not listed again here. Agents enforce
`model`, `tools`, `maxTurns`, `effort` via AGENT.md frontmatter.

- **Auto-Invoke**: `UserPromptSubmit` hook (`scripts/skill-matcher.py` +
  `.claude/skill-rules.json`) — mechanical prompt/file matching
- **Manual**: `/skill-name` | **Proactive**: suggestion with confirmation
- **Suggestion intensity**: `--suggest-all` (default) | `--suggest-minimal` | `--suggest-off`
- Third-party skill provenance: [`NOTICE.md`](NOTICE.md), pinned via `skills-lock.json`

## Workflow Integration
- **Step 0**: Difficulty Assessment (Simple/Medium/Complex) → protocol branching
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed (Medium+)
- **Goal Lock (autonomous mode)**: When Strong success criteria exist and work spans multiple turns → `/goal "<verifiable condition>"` (Claude Code 2.1.139+). See `optional/GOAL_PATTERNS.md` for safe condition patterns.
- **Planning**: `/feature-planner` → `/architecture` (Complex: + reasoning templates)
- **Design**: `DESIGN.md` (if exists) → `/ui-ux-pro-max` → `/frontend-design` → `/web-design-guidelines`
- **Implementation**: Domain-specific skills (Complex: + mid-checkpoint at 50%)
- **Review**: Two-Stage Review (Simple: Stage 1 only | Medium: Stage 1+2 | Complex: + Cascade Impact)
- **Deployment**: `/docker`, `/cicd`, `/monitoring`
- **Verification**: `/verify` → `/audit` (project rules)
- **Post-Implementation**: `/learn` → `/goal clear` (if a goal was set)

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
- `optional/GOAL_PATTERNS.md` — `/goal` condition patterns, anti-patterns, `/loop` vs `/goal` decision table
- `optional/WORKER_TEMPLATES.md` — Worker agent 4-element prompt templates

