---
name: learn
description: Extract reusable patterns from sessions and save them as skills. Use after solving complex problems, discovering useful workarounds, or establishing project-specific conventions. Keywords: learn, pattern, extract, skill, knowledge, save, remember.
---

# Learn Skill

## Purpose
Analyze problem-solving patterns, debugging techniques, and workarounds from sessions to save them as reusable skills.

**Core Principle**: Recurring problem-solving → Pattern extraction → Skill creation → Reuse in future sessions

## Activation Triggers
- After solving complex errors
- When discovering useful workarounds
- When establishing project-specific conventions
- Session end knowledge consolidation
- Explicit user request: `/learn`, `remember this`, `save pattern`

---

## Pattern Extraction Focus

**Gate question**: *Would a future session, starting cold, save real time because
this was written down?* If the answer is "it would have figured this out from the
code or from general knowledge in under a minute", do not save it. Every saved
line is prompt context; it has to earn its place.

### Include ✅
| Category | Examples | Why it earns its place |
|----------|----------|------------------------|
| **Commands/workflows discovered** | The build variant that actually works, the test invocation with the required flag (`--runInBand` for shared DB state) | Saves re-discovery on every session |
| **Error Resolution Patterns** | TypeScript type error fixes, build failure repairs | Prevents repeating a debugging session |
| **Debugging Techniques** | Specific tool combinations, log analysis methods | Not derivable from code |
| **Library Quirks** | Undocumented behaviors, version-specific differences | Invisible in the codebase |
| **API / Config Quirks** | Rate-limit workarounds, `NEXT_PUBLIC_*` must be set at build time, Redis needs `?family=0` for IPv6 | Environment knowledge that costs an outage to learn |
| **Module Relationships** | "`auth` needs `crypto` initialized first; import order in `bootstrap.ts` matters" | Architecture knowledge the code does not state |
| **Testing approaches that worked** | Which helper/factory to use instead of inline mocks | Establishes a pattern others will follow |
| **Project Conventions** | Naming rules, file structure, code style **beyond** what CONVENTIONS.md already says | Only the project-specific delta |
| **Architecture Decisions** | Pattern selection rationale, trade-offs | The "why" is never in the code |

### Exclude ❌
| Category | Reason | Bad example |
|----------|--------|-------------|
| **Obvious from code** | The name or signature already says it | "`UserService` handles user operations" |
| **Generic best practice** | Universal advice, not project-specific; the model already knows it | "Always write tests", "use meaningful names" |
| **One-off fixes** | Will not recur; clutters the file | "Fixed login button bug in commit abc123" |
| **Verbose explanations** | A one-liner carries the same information | A paragraph on what JWT is → `Auth: JWT HS256, Bearer header` |
| Simple typo / syntax fixes | No reuse value | — |
| Transient external issues | Service outage, flaky network | — |
| Machine-specific paths/secrets | Not generalizable; secrets never | `/Users/me/...`, tokens |
| Already in CLAUDE.md / RULES.md / CONVENTIONS.md | Duplicate context is pure cost | — |

### Where it goes
| Learning type | Destination |
|---------------|-------------|
| Reusable across projects (library quirk, debugging technique) | `~/.claude/skills/learned/<name>.md` (this skill) |
| Project-specific command, gotcha, module relationship | Project `CLAUDE.md` (team) or `CLAUDE.local.md` (personal, gitignored) — one line per concept, `<command or pattern>` - `<why>` |
| Must survive compaction in *this* session only | `/note` |

---

## Workflow

### Step 1: Session Analysis
```
/learn

🔍 Analyzing session...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Messages: 47
Tool calls: 89
Errors resolved: 3 cases
Main task: Auth system implementation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2: Pattern Identification
```
💡 Extractable patterns found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [HIGH VALUE] NextAuth + Prisma Session Type Extension
   - Problem: userId missing in Session type
   - Solution: Type extension in next-auth.d.ts
   - Reusability: ⭐⭐⭐⭐⭐

2. [MEDIUM VALUE] Supabase RLS Debugging Pattern
   - Problem: Empty results due to RLS policy
   - Solution: Test with service_role key, then fix policy
   - Reusability: ⭐⭐⭐⭐

3. [LOW VALUE] ESLint Rule Disable
   - Problem: unused-vars warning
   - Solution: .eslintrc modification
   - Reusability: ⭐⭐ (project-specific)

Select patterns to save [1,2,3 or all]:
```

### Step 3: Skill Document Generation
```
📝 Generating skill document...

File: ~/.claude/skills/learned/nextauth-prisma-session-type.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NextAuth + Prisma Session Type Extension

## Problem
Type error when accessing userId in NextAuth session
`Property 'userId' does not exist on type 'Session'`

## Solution
Create `types/next-auth.d.ts`:
\`\`\`typescript
import { DefaultSession } from "next-auth"

declare module "next-auth" {
  interface Session {
    user: {
      id: string
    } & DefaultSession["user"]
  }
}
\`\`\`

## When to Apply
- When using NextAuth + Prisma combination
- When adding custom fields to session

## Related
- NextAuth official docs: TypeScript section
- Prisma adapter configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Skill saved
```

### Step 4: Confirmation
```
View saved skill? [y/N]
```

---

## Learned Skills Storage

### Storage Location
```
~/.claude/skills/learned/
├── nextauth-prisma-session-type.md
├── supabase-rls-debugging.md
├── react-hydration-mismatch-fix.md
└── vercel-edge-function-timeout.md
```

### Skill File Structure
```markdown
---
name: pattern-name
description: Brief description
learned_at: 2025-01-26
source_project: project-name
tags: [nextauth, prisma, typescript]
---

# Pattern Name

## Problem
Problem situation description

## Cause
Root cause analysis

## Solution
Resolution method (with code examples)

## When to Apply
Situations where this pattern applies

## Caveats
Warnings, edge cases

## Related
Related documentation, resource links
```

---

## Auto-Learning (Stop Hook)

### Automatic Session End Analysis
`.claude/settings.json`:
```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "~/.claude/scripts/evaluate-session.sh"
      }
    ]
  }
}
```

### Auto-Learning Configuration
`.claude/learn.config.json`:
```json
{
  "auto_learn": {
    "enabled": true,
    "min_session_length": 10,
    "extraction_threshold": "medium",
    "auto_approve": false
  },
  "storage": {
    "path": "~/.claude/skills/learned/",
    "max_skills": 100
  },
  "filters": {
    "ignore_patterns": [
      "typo",
      "syntax_error",
      "one_time_fix"
    ],
    "focus_patterns": [
      "error_resolution",
      "debugging_technique",
      "workaround",
      "architecture_decision"
    ]
  }
}
```

---

## Integration

### With PM Agent
Integration with PM Agent's self-improvement layer:
```
Session complete
    │
    ├─→ /learn (pattern extraction)
    │
    └─→ PM Agent (documentation, knowledge base update)
```

### With `/checkpoint`
```
/checkpoint create "before-experiment"
... experimental resolution attempts ...
... success! ...
/learn  # Save successful pattern
```

### With Future Sessions
Saved skills auto-referenced when similar problems occur:
```
🔍 Similar pattern detected
━━━━━━━━━━━━━━━━━━━━━━━━━━
Previously learned pattern available:
- nextauth-prisma-session-type.md

Apply? [y/N]
```

---

## Quality Filters

### Value Assessment
| Criterion | Weight |
|-----------|--------|
| Reusability potential | 40% |
| Resolution complexity | 30% |
| Time-saving impact | 20% |
| Documentation value | 10% |

### Pre-save Checklist (all must be true)
- [ ] Project- or library-specific — not generic advice
- [ ] Not already obvious from the code, and not already in CLAUDE.md / RULES.md / CONVENTIONS.md
- [ ] Commands were actually run and work; file paths are real
- [ ] Expressed in the most concise form (one line per concept where possible)
- [ ] A new session would find it *before* needing it (name and tags are searchable)

### Extraction Threshold
- **Low**: Extract most patterns (noisy)
- **Medium**: Medium+ value only (recommended)
- **High**: High-value patterns only (strict)

---

## Commands

| Command | Description |
|---------|-------------|
| `/learn` | Analyze current session and extract patterns |
| `/learn list` | List saved skills |
| `/learn show <name>` | View specific skill content |
| `/learn delete <name>` | Delete skill |
| `/learn search <keyword>` | Search skills |

---

## Best Practices

### Good Pattern Example
```markdown
# React Server Component Data Fetching

## Problem
Waterfall issue when fetching server data
in client components

## Solution
Fetch data in server component, pass as props
or use Suspense + parallel fetch

## Code Example
\`\`\`tsx
// ✅ Good: Server Component
async function Page() {
  const data = await fetchData()
  return <ClientComponent data={data} />
}
\`\`\`
```

### Patterns to Avoid
```markdown
# Fix Typo in Config  ❌
## Problem
Build failure due to typo
## Solution
Fix typo

→ No reuse value, do not save
```

```markdown
# UserService  ❌
The `UserService` class handles user operations.

→ Obvious from the code, do not save
```

```markdown
# JWT Authentication  ❌
JWT (JSON Web Tokens) are an open standard (RFC 7519) that defines a compact
and self-contained way for securely transmitting information ... (12 lines)

→ Verbose; the useful residue is one line: `Auth: JWT HS256, Bearer header`
```

*Include/Exclude criteria and the bad examples above are adapted from Anthropic's
`claude-md-management` plugin (`update-guidelines.md`, Apache 2.0) — see NOTICE.md.*
