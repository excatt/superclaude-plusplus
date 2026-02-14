# SuperClaude Framework Flags

Behavioral flags quick reference. See MODES.md for detailed mode descriptions.

---

## Mode Activation

| Flag | Trigger | Behavior |
|------|---------|----------|
| `--brainstorm` | "maybe", "thinking about" | Collaborative requirements exploration |
| `--introspect` | Error recovery, self-analysis | Metacognitive analysis, use markers |
| `--task-manage` | >3 steps, >2 directories | Hierarchical task organization |
| `--orchestrate` | Multi-tool, parallel opportunities | Tool optimization, parallel thinking |
| `--token-efficient` | Context >75%, `--uc` | Symbol communication, 30-50% reduction |

---

## MCP Server Flags

See MCP_SERVERS.md for details.

| Flag | Server | Use Case |
|------|--------|----------|
| `--c7`, `--context7` | Context7 | Official docs, framework patterns |
| `--seq`, `--sequential` | Sequential | Complex debugging, system design |
| `--magic` | Magic | UI components (/ui, /21) |
| `--morph`, `--morphllm` | Morphllm | Bulk transforms, pattern edits |
| `--serena` | Serena | Symbol operations, project memory |
| `--play`, `--playwright` | Playwright | Browser tests, E2E |
| `--tavily` | Tavily | Web search, research |
| `--all-mcp` | All | Maximum complexity scenarios |
| `--no-mcp` | None | Native only, performance priority |

---

## Analysis Depth

| Flag | Tokens | Triggers | Enables |
|------|--------|----------|---------|
| `--think` | ~4K | Medium complexity | Sequential |
| `--think-hard` | ~10K | Architecture analysis | Sequential + Context7 |
| `--ultrathink` | ~32K | System redesign | All MCP |

---

## Execution Control

| Flag | Description |
|------|-------------|
| `--delegate [auto\|files\|folders]` | Parallel subagent processing |
| `--concurrency [n]` | Max concurrent tasks (1-15) |
| `--loop` | Iterative improvement cycles |
| `--iterations [n]` | Improvement cycle count (1-10) |
| `--validate` | Pre-execution risk assessment |
| `--safe-mode` | Maximum validation, conservative execution |

---

## Output & Scope

| Flag | Description |
|------|-------------|
| `--uc`, `--ultracompressed` | Symbol system, token reduction |
| `--scope [file\|module\|project\|system]` | Define analysis scope |
| `--focus [performance\|security\|quality\|...]` | Focus on specific domain |

---

## Proactive Suggestion

| Flag | Description |
|------|-------------|
| `--suggest-all` | Suggest all relevant tools aggressively (default) |
| `--suggest-minimal` | Suggest only core tools |
| `--suggest-off`, `--no-suggest` | Disable auto-suggestions |
| `--auto-agent` | Enable automatic agent suggestions |
| `--auto-mcp` | Suggest automatic MCP server activation |

---

## Model Selection

| Flag | Strengths | Use Case |
|------|------|----------|
| `--model haiku` | Fast response, lightweight | Exploration, simple queries, single file |
| `--model sonnet` | Balanced (default) | Implementation, review, orchestration |
| `--model opus` | Best reasoning | Architecture, deep research |

---

## Context Mode

See CONTEXTS.md for details.

| Flag | Mode | Priority |
|------|------|----------|
| `--ctx dev` | Development | Working > Perfect, code first |
| `--ctx review` | Review | Deep analysis, sorted by severity |
| `--ctx research` | Research | Completeness > Speed, evidence-based |

---

## Priority Rules

```
Safety: --safe-mode > --validate > optimization
Override: User flags > auto-detection
Depth: --ultrathink > --think-hard > --think
MCP: --no-mcp overrides individual flags
Scope: system > project > module > file
Model: --model flag > auto-selection
```
