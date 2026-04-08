# Session Protocols

Detailed protocols for session management, learning, and memory.

## Note Protocol
**Priority**: 🟡 **Triggers**: Long sessions, context loss risk

| Section | Purpose | Lifetime |
|---------|---------|----------|
| Priority Context | Core info | Permanent (500 chars) |
| Working Memory | Temp notes | 7 days |
| MANUAL | Permanent info | Never deleted |

**Commands**: `/note <content>`, `/note --priority`, `/note --manual`, `/note --show`
**Auto-Suggest**: At 50+ messages or 70%+ context usage

## Learning Protocol
**Priority**: 🟢 **Triggers**: After solving complex problems

**Save Criteria** (must meet all):
1. Non-Googleable: Not findable in a 5-minute search
2. Project-Specific: Specific to this codebase
3. Hard-Won: Actual debugging effort involved
4. Actionable: Includes specific files, lines, code

**Storage**: `~/.claude/skills/learned/`
**Auto-Suggest**: On error resolution, after 3+ attempts before success, keywords like "해결/찾았다/solved"

## Memory Management
**Priority**: 🟢 **Triggers**: Important information discovered, pattern learned

### Auto Memory (built-in)
Claude auto-records to `~/.claude/projects/<project>/memory/`:
- Project patterns, debugging insights, architecture notes, preferences

### Explicit Save
- On "기억해", "저장해", "remember this" requests → record to Auto Memory
- Use `/memory` command to view/edit

### CLAUDE.md Hierarchy
| Purpose | Location |
|---------|----------|
| Team rules | `./CLAUDE.md`, `.claude/rules/` |
| Personal global | `~/.claude/CLAUDE.md` |
| Personal project | `./CLAUDE.local.md` |
