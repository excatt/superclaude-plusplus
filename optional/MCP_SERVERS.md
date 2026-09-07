# MCP Servers Reference

Unified MCP server matrix. Provides each server's purpose, triggers, and selection criteria in compressed format.

> **Not bundled.** SuperClaude++ ships no `mcpServers` entry. These servers are
> installed per project (`.mcp.json`, `claude mcp add`) or per machine
> (`~/.claude.json`). Flags and triggers below only apply when the server is
> present; otherwise use the fallback in the last column. Per-server guides:
> [`MCP_Context7.md`](MCP_Context7.md) · [`MCP_Magic.md`](MCP_Magic.md) ·
> [`MCP_Morphllm.md`](MCP_Morphllm.md) · [`MCP_Playwright.md`](MCP_Playwright.md) ·
> [`MCP_Sequential.md`](MCP_Sequential.md) · [`MCP_Serena.md`](MCP_Serena.md) ·
> [`MCP_Tavily.md`](MCP_Tavily.md)

## Fallback When Not Installed

| Server | Fallback |
|--------|----------|
| Context7 | `WebFetch` on the official docs URL |
| Magic | `/frontend-design`, `/impeccable`, `/ui-ux-pro-max` |
| Morphllm | `Edit` with `replace_all`, or `/batch` for multi-file |
| Playwright | `claude-in-chrome` skill, `/agent-browser`, `/webapp-testing` |
| Sequential | `--think` / `--think-hard` (built-in extended reasoning) |
| Serena | `Grep` / `Read`; session memos via `/note` |
| Tavily | `WebSearch` |

## Quick Selection Matrix

| Server | Purpose | Best For | NOT For |
|--------|---------|----------|---------|
| **Context7** | Official docs lookup | Framework patterns, version-specific APIs | General explanations |
| **Magic** | UI component generation | Buttons, forms, modals, tables | Backend logic |
| **Morphllm** | Pattern-based editing | Bulk transforms, style application | Symbol renames |
| **Playwright** | Browser automation | E2E tests, screenshots | Static code analysis |
| **Sequential** | Multi-step reasoning | Complex debugging, architecture analysis | Simple tasks |
| **Serena** | Semantic code understanding | Symbol operations, session management | Simple text replacement |
| **Tavily** | Web search/research | Latest information, research | Local file operations |

---

## Server Details

| Server | Triggers | Key Examples |
|--------|----------|-------------|
| **Context7** | `import`, `require`, `from`, framework keywords, version-specific implementation | React useEffect → C7, Auth0 → C7 |
| **Magic** | `/ui`, `/21`, button, form, modal, card, table, nav | login form → Magic, navbar → Magic |
| **Morphllm** | Multi-file editing, style application, bulk replacement | class→hooks → Morph, console.log→logger → Morph |
| **Playwright** | Browser testing, screenshots, form submission, accessibility | login flow test → Play, screenshots → Play |
| **Sequential** | `--think*`, multi-layer debugging, architecture | API slow → Seq, microservices → Seq |
| **Serena** | Symbol operations, LSP, session memory | rename everywhere → Serena, find refs → Serena |
| **Tavily** | `--research` (Deep Research mode), latest information, fact-checking, competitive analysis. Requires `TAVILY_API_KEY` | latest TS features → Tavily. **Fallback**: WebSearch |

## Server Combinations

| Task | Primary | Secondary |
|------|---------|-----------|
| Framework UI | Magic | Context7 |
| Complex refactoring | Serena | Morphllm |
| Research + analysis | Tavily | Sequential |
| E2E test design | Sequential | Playwright |
| Doc-based coding | Context7 | Sequential |
