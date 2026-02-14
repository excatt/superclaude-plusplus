---
name: note
description: Persistent memo system surviving session compaction. Save critical context to .claude/notepad.md preventing information loss in long sessions. Keywords: note, memo, remember, context, save.
---

# Note Skill

## Purpose
Persistent memo system surviving session compaction. Prevents critical context loss through compression in long sessions.

**Core Principle**: Critical info → Save memo → Persist after compaction → Available in next session

## Storage Location
- **Project Level**: `.claude/notepad.md` (project root)
- **Global Level**: `~/.claude/notepad.md` (shared across projects)

---

## Commands

| Command | Description |
|---------|-------------|
| `/note <content>` | Add to Working Memory with timestamp |
| `/note --priority <content>` | Add to Priority Context (always loaded) |
| `/note --manual <content>` | Add to MANUAL section (never deleted) |
| `/note --show` | Display current notepad contents |
| `/note --prune` | Clean Working Memory items older than 7 days |
| `/note --clear` | Delete Working Memory only (keep Priority, MANUAL) |

---

## Sections

### 1. Priority Context (Always Loaded)
```markdown
## Priority Context
<!-- 500 char limit - always injected at session start -->
- Project uses pnpm, not npm
- API client: src/api/client.ts
- Auth: NextAuth + Prisma adapter
```

**Purpose**:
- Project core information
- Must-know at every session start
- **500 char limit** (context budget consideration)

### 2. Working Memory (Temporary Memos)
```markdown
## Working Memory
<!-- Includes timestamp, auto-cleaned after 7 days -->
[2025-01-28 14:30] Auth bug found - UserContext missing useEffect dependency
[2025-01-28 15:45] RLS policy issue resolved - test with service_role key
```

**Purpose**:
- Debugging discoveries
- Current work content
- Auto-cleaned after 7 days (--prune)

### 3. MANUAL (Permanent Storage)
```markdown
## MANUAL
<!-- Never auto-deleted -->
- Backend Team: backend@company.com
- Production DB: readonly, never directly modify
- Deploy: main branch push → Vercel auto-deploy
```

**Purpose**:
- Team contacts
- Deployment info
- Project rules
- Never-forget information

---

## Notepad File Format

```markdown
# Notepad
<!-- Session memos surviving compaction -->
<!-- Storage: .claude/notepad.md -->

## Priority Context
<!-- 500 char limit - always loaded -->
- Project uses TypeScript strict mode
- All files in src/, tests in tests/
- API endpoints: /api/v1/*

## Working Memory
<!-- Includes timestamp, auto-cleaned after 7 days -->
[2025-01-28 14:30] Found race condition in worker.ts:89

## MANUAL
<!-- Permanent storage - never auto-deleted -->
- Contact: api-team@company.com for backend questions
- NEVER commit to main directly
```

---

## Workflow

### Adding a Note

```
User: /note Auth module needs JWT expiry handling

Claude:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 [Note] Added to Working Memory
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[2025-01-28 14:30] Auth module needs JWT expiry handling

Saved to: .claude/notepad.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Adding Priority Context

```
User: /note --priority This project uses pnpm, npm commands forbidden

Claude:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 [Note] Added to Priority Context
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- This project uses pnpm, npm commands forbidden

⚠️ Priority Context: 127/500 chars used
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Showing Notes

```
User: /note --show

Claude:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 [Note] Current Notepad Contents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Priority Context (127/500 chars)
- This project uses pnpm, npm commands forbidden
- API: src/api/client.ts

## Working Memory (2 items)
[2025-01-28 14:30] Auth module needs JWT expiry handling
[2025-01-28 15:00] Fixed type error in UserService.ts:45

## MANUAL (1 item)
- Backend Team: backend@company.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Implementation

### On Skill Invocation

1. **Parse Arguments**
   - Check options: `--priority`, `--manual`, `--show`, `--prune`, `--clear`
   - Extract content

2. **Load/Create Notepad**
   - Read or create `.claude/notepad.md`
   - Parse by section

3. **Execute Action**
   - Default: Add to Working Memory with timestamp
   - `--priority`: Add to Priority Context (check 500 char limit)
   - `--manual`: Add to MANUAL section
   - `--show`: Display full contents
   - `--prune`: Delete Working Memory older than 7 days
   - `--clear`: Delete entire Working Memory

4. **Save Notepad**
   - Save changes

---

## Session Integration

### Session Start
Auto-check notepad at session start:
1. Check `.claude/notepad.md` or `~/.claude/notepad.md` existence
2. Load Priority Context (always)
3. Load recent Working Memory (within 24 hours)

### Session End
Suggest noting important info before session end:
- Complex problems solved
- Project rules discovered
- Context needed for next session

---

## Best Practices

### Priority Context Writing Tips
```markdown
✅ Good (concise and essential)
- Use pnpm, not npm
- API: src/api/client.ts
- Auth: NextAuth + Prisma

❌ Bad (too detailed)
- This project uses the pnpm package manager.
  Using npm or yarn can cause lock file conflicts,
  so please always use pnpm...
```

### Working Memory Writing Tips
```markdown
✅ Good (specific, includes file/line)
[2025-01-28] worker.ts:89 missing await on Promise.all - race condition cause

❌ Bad (vague)
[2025-01-28] Bug found
```

### MANUAL Writing Tips
```markdown
✅ Good (permanently useful info)
- Production DB: readonly access only
- Deploy: main push → Vercel auto-deploy
- Hotfix: hotfix/* branch → immediate deploy

❌ Bad (temporary info)
- Meeting today at 3pm
```

---

## Related

- `/learn` - Pattern extraction and skill saving
- `/checkpoint` - Create restore point before work
- `/sc:save` - Save entire session state
