---
name: help
description: List available framework skills and their functionality
user-invocable: true
---

# Command Reference

The authoritative skill list (names + descriptions) is auto-injected by the
harness every session — enumerate that when the user asks what is available.
This reference only groups the framework's own skills by role. Information
display only — no execution.

## Framework Core (workflow mechanisms)
| Skill | Purpose |
|-------|---------|
| `/confidence-check` | Pre-implementation confidence assessment (Medium+ difficulty) |
| `/verify` | 6-phase verification (build → type → lint → test → security → diff) |
| `/checkpoint` | Git-based restore point before risky operations |
| `/tdd` | RED-GREEN-REFACTOR cycle enforcement |
| `/build-fix` | Resolve build errors with minimal changes |
| `/audit` | Project-specific rule validation |
| `/gap-analysis` | Design-vs-implementation Match Rate (PDCA Check) |
| `/feature-planner` | Phase-based feature planning |
| `/learn` | Extract and save session patterns |
| `/note` | Persist memos across sessions |
| `/fix-pr` | Collect PR review comments and fix |
| `/config-doctor` | Framework configuration diagnosis |
| `/eval-harness` | Eval-driven development for AI features |

## Review & Critique
`/devils-advocate` (decision challenge) · `/business-panel` (expert panel) ·
`/brainstorm` (requirements discovery) · `/grill-with-docs` (domain model
stress-test) · `/security-audit` · `/react-best-practices` ·
`/python-best-practices` · `/composition-patterns` · `/web-design-guidelines`

## Design & Frontend
`/ui-ux-pro-max` (design intelligence) · `/frontend-design` ·
`/impeccable` + 17 sub-commands (`/shape`, `/layout`, `/typeset`, `/colorize`,
`/animate`, `/delight`, `/polish`, `/critique`, `/design-audit`, `/harden`,
`/optimize`, `/clarify`, `/distill`, `/quieter`, `/bolder`, `/adapt`,
`/overdrive`) · `/theme-factory` · `/brand-guidelines` · `/canvas-design` ·
`/algorithmic-art`

## Documents & Tooling
`/pdf` · `/pptx` · `/xlsx` · `/internal-comms` · `/artifacts-builder` ·
`/slack-gif-creator` · `/mcp-builder` · `/skill-creator` · `/webapp-testing` ·
`/agent-browser` · `/pytest-runner` · `/uv-package`

## Removed in v3.0
Generic topic guides (architecture, caching, docker, GraphQL, naming, ...) and
thin command wrappers (analyze, implement, improve, cleanup, ...) were removed
— the model handles these natively. Ask directly instead of looking for a
skill.
