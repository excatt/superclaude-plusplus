# SuperClaude Framework Flags

Behavioral flags quick reference. See MODES.md for detailed mode descriptions.

---

## Mode Activation

See MODES.md Mode Quick Reference for details.

`--brainstorm` | `--introspect` | `--task-manage` | `--orchestrate` | `--token-efficient` (`--uc`) | `--harness`

---

## MCP Server Flags

See MCP_SERVERS.md for details.

`--c7`/`--context7` Context7 | `--seq`/`--sequential` Sequential | `--magic` Magic | `--morph`/`--morphllm` Morphllm | `--serena` Serena | `--play`/`--playwright` Playwright | `--tavily` Tavily | `--all-mcp` All | `--no-mcp` None

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
| `--delegate [auto\|files\|folders]` | Sub-agent parallel processing |
| `--concurrency [n]` | Max concurrent tasks (1-15) |
| `--loop` | Iterative improvement cycle |
| `--iterations [n]` | Number of improvement cycles (1-10) |
| `--validate` | Pre-execution risk assessment |
| `--safe-mode` | Maximum verification, conservative execution |

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
| `--suggest-all` | Actively suggest all relevant tools (default) |
| `--suggest-minimal` | Suggest core tools only |
| `--suggest-off`, `--no-suggest` | Disable auto-suggestions |
| `--auto-agent` | Enable automatic agent suggestions |
| `--auto-mcp` | Enable automatic MCP server activation suggestions |

---

## Model Selection

| Flag | Strength | Use Case |
|------|----------|----------|
| `--model haiku` | Fast response, lightweight | Exploration, simple questions, single file |
| `--model sonnet` | Balanced (default) | Implementation, review, orchestration |
| `--model opus` | Best reasoning | Architecture, deep research |

---

## Context Mode

See CONTEXTS.md for details.

| Flag | Mode | Priority |
|------|------|----------|
| `--ctx dev` | Development | Working > perfect, code first |
| `--ctx review` | Review | Deep analysis, organized by severity |
| `--ctx research` | Research | Completeness > speed, evidence-based |

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
