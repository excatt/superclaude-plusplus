# SuperClaude++ v3.0

## Language
- **ALWAYS respond in Korean (한글)**
- Code comments/variables: English
- Technical terms: English when common (WebSocket, API, etc.)
- Korean fluency (조사/어미 보존, 번역투 방지): `fluent-korean` output style
  ([snflkd/fluent-korean](https://github.com/snflkd/fluent-korean) 플러그인,
  `config/settings.json`에서 선언 — provenance: [NOTICE.md](NOTICE.md))

## Core Framework
@RULES.md
@PRINCIPLES.md
@MODES.md
@CONVENTIONS.md

Always-resident context is limited to the four files above. Everything else
loads on demand from `optional/` or as skills. Rules restate neither harness
guarantees nor model defaults — see the preamble in RULES.md.

## Skill & Agent System

Skill names/descriptions and available agent types are auto-injected by the
harness every session — they are not listed again here. Agents enforce
`model`, `tools`, `maxTurns`, `effort` via AGENT.md frontmatter.

- **Auto-Invoke**: `UserPromptSubmit` hook (`scripts/skill-matcher.py` +
  `.claude/skill-rules.json`) — mechanical prompt/file matching
- **Manual**: `/skill-name` | **Proactive**: suggestion with confirmation
- **Suggestion intensity**: `--suggest-all` (default) | `--suggest-minimal` | `--suggest-off`
- Third-party skill provenance: [`NOTICE.md`](NOTICE.md)

## Workflow Integration
- **Step 0**: Difficulty Assessment (Simple/Medium/Complex) → protocol branching
- **Pre-Implementation**: `/confidence-check` → ≥90% proceed (Medium+)
- **Goal Lock (autonomous mode)**: Strong success criteria + multi-turn work → `/goal "<verifiable condition>"` (see `optional/GOAL_PATTERNS.md`)
- **Planning**: `/feature-planner`
- **Design**: `DESIGN.md` (if exists) → `/ui-ux-pro-max` → `/frontend-design` → `/web-design-guidelines`
- **Review**: Two-Stage Review (Simple: Stage 1 only | Medium: Stage 1+2 | Complex: + Cascade Impact)
- **Verification**: `/verify` → `/audit` (project rules)
- **Post-Implementation**: `/learn` → `/goal clear` (if a goal was set)

### DESIGN.md (Visual Design System)
AI 에이전트가 읽는 디자인 시스템 문서 ([Google Stitch format](https://stitch.withgoogle.com/docs/design-md/overview/)).

| File | Who reads it | What it defines |
|------|-------------|-----------------|
| `AGENTS.md` | Coding agents | How to build the project |
| `DESIGN.md` | Design agents | How the project should look and feel |

**Usage**: `npx getdesign@latest add {brand}` (66 brands) | `/ui-ux-pro-max --design-system --persist` | Template: `templates/visual-design.template.md`

## On-Demand References (`optional/`, load when needed)
- `FLAGS.md` — behavioral flag definitions (`--think`, `--uc`, `--delegate`, ...)
- `CONTEXTS.md` — DEV/REVIEW/RESEARCH/PLANNING context modes
- `MCP_SERVERS.md` — MCP server selection matrix; per-server guides in `MCP_*.md`
- `GOAL_PATTERNS.md` — `/goal` condition patterns, anti-patterns, `/loop` vs `/goal`
- `OVERENGINEERING_TRAPS.md` — Build Ladder application rules + rung 3 native-feature catalog
- `REASONING_TEMPLATES.md` — structured reasoning (debugging, architecture, performance)
- `CONTEXT_BUDGET.md` — context budget management
- `WORKER_TEMPLATES.md` — worker agent prompt templates
- `PROTOCOLS.md` — session save/restore protocols
- `PROJECT_RULES.md` — Dockerfile/CI patterns, security checklist
