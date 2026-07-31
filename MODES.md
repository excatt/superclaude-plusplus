# Behavioral Modes

Context-adaptive behavioral modes. Each mode adjusts mindset, priorities, and
communication style. Only this quick reference stays resident — read the
detail file in `optional/` when a mode actually activates.

## Mode Quick Reference

| Mode | Purpose | Trigger | Flag | Details |
|------|---------|---------|------|---------|
| **Brainstorming** | Requirements exploration | "maybe", "생각중인데", vague requests | `--brainstorm` | `optional/MODE_Brainstorming.md` |
| **Deep Research** | Systematic investigation | `/sc:research`, "조사해줘", "알아봐줘" | `--research` | `optional/MODE_DeepResearch.md` |
| **Introspection** | Metacognitive analysis | Error recovery, "내 추론 분석해봐" | `--introspect` | `optional/MODE_Introspection.md` |
| **Orchestration** | Tool optimization | Multi-tool, parallel execution (>3 files) | `--orchestrate` | `optional/MODE_Orchestration.md` |
| **Task Management** | Hierarchical task management | >3-step tasks, "다듬어", "정리해" | `--task-manage` | `optional/MODE_Task_Management.md` |
| **Token Efficiency** | Compressed communication | Context >75% | `--uc` | `optional/MODE_Token_Efficiency.md` |
| **Business Panel** | Expert panel analysis | `/sc:business-panel` | - | `optional/MODE_Business_Panel.md` |
| **Harness** | Agent-driven implementation | "에이전트한테 맡겨", "전부 자동으로" | `--harness` | `optional/MODE_Harness.md` |

## Context Modes (DEV / REVIEW / RESEARCH / PLANNING)

`--ctx dev|review|research` switches situational priorities and output format.
Definitions: `optional/CONTEXTS.md`

## Flags

Full flag reference (analysis depth, MCP servers, execution control, model
selection): `optional/FLAGS.md`

## Progressive Context Loading

Load context incrementally by task difficulty (Simple → RULES.md essentials
only | Medium → +1-2 optional files | Complex → +REASONING_TEMPLATES,
CONTEXT_BUDGET). Details: `optional/CONTEXT_BUDGET.md`
