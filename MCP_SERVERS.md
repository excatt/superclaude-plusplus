# MCP Servers Reference

Unified MCP server matrix. Provides purpose, triggers, and selection criteria in compressed format.

## Quick Selection Matrix

| Server | Purpose | Best For | NOT For |
|--------|---------|----------|---------|
| **Context7** | Official docs lookup | Framework patterns, version-specific APIs | General explanations |
| **Magic** | UI component generation | Buttons, forms, modals, tables | Backend logic |
| **Morphllm** | Pattern-based editing | Bulk transforms, style application | Symbol renaming |
| **Playwright** | Browser automation | E2E tests, screenshots | Static code analysis |
| **Sequential** | Multi-step reasoning | Complex debugging, architecture analysis | Simple tasks |
| **Serena** | Semantic code understanding | Symbol operations, session management | Simple text substitution |
| **Tavily** | Web search/research | Latest info, research | Local file operations |

---

## Context7
**Purpose**: Official library documentation lookup and framework pattern guide

**Triggers**: `import`, `require`, `from` | Framework keywords | Version-specific implementation needed

**Examples**:
- "implement React useEffect" → Context7
- "add Auth0 authentication" → Context7
- "just explain this function" → Native Claude

---

## Magic
**Purpose**: 21st.dev pattern-based modern UI component generation

**Triggers**: `/ui`, `/21` commands | button, form, modal, card, table, nav

**Examples**:
- "create a login form" → Magic
- "build responsive navbar" → Magic
- "write a REST API" → Native Claude

---

## Morphllm
**Purpose**: Token-optimized pattern-based code editing engine

**Triggers**: Multi-file edits | Style application | Bulk text substitution

**Examples**:
- "update all class components to hooks" → Morphllm
- "replace console.log with logger" → Morphllm
- "rename getUserData everywhere" → Serena (symbol operation)

---

## Playwright
**Purpose**: Real browser interaction and E2E testing

**Triggers**: Browser tests | Screenshots | Form submission tests | Accessibility validation

**Examples**:
- "test the login flow" → Playwright
- "take responsive screenshots" → Playwright
- "review function logic" → Native Claude

---

## Sequential
**Purpose**: Multi-step reasoning for complex analysis and systematic problem-solving

**Triggers**: `--think`, `--think-hard`, `--ultrathink` | Multi-layer debugging | Architecture analysis

**Examples**:
- "why is this API slow?" → Sequential
- "design microservices architecture" → Sequential
- "explain this function" → Native Claude

---

## Serena
**Purpose**: Semantic code understanding with project memory and session persistence

**Triggers**: Symbol operations (rename, extract, move) | `/sc:load`, `/sc:save` | LSP integration

**Examples**:
- "rename getUserData everywhere" → Serena
- "find all references to this class" → Serena
- "load my project context" → Serena

---

## Tavily
**Purpose**: Web search for research and latest information

**Triggers**: `/sc:research` | Post-cutoff info | Fact-checking | Competitive analysis

**Config**: Requires `TAVILY_API_KEY` environment variable

**Search Types**: Web | News | Academic | Domain-filtered

**Examples**:
- "latest TypeScript features 2024" → Tavily
- "OpenAI updates this week" → Tavily
- "explain recursion" → Native Claude

**Fallback**: Native WebSearch

---

## Server Combinations

| Task | Primary | Secondary |
|------|---------|-----------|
| Framework UI implementation | Magic | Context7 |
| Complex refactoring | Serena | Morphllm |
| Research + analysis | Tavily | Sequential |
| E2E test design | Sequential | Playwright |
| Doc-based coding | Context7 | Sequential |

---

## Flag Reference

```
--c7, --context7    → Enable Context7
--magic             → Enable Magic
--morph, --morphllm → Enable Morphllm
--play, --playwright → Enable Playwright
--seq, --sequential → Enable Sequential
--serena            → Enable Serena
--tavily            → Enable Tavily
--all-mcp           → Enable all MCP
--no-mcp            → Disable MCP (native only)
```
