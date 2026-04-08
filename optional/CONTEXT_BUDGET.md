# Context Budget Management

The context window is finite. Unnecessary file loading directly degrades performance.

---

## Core Principles

1. **Minimize full-file reads** -- Read only the needed functions/classes
2. **No duplicate reads** -- Never re-read a file already in context
3. **Lazy loading** -- Load resources only when needed
4. **Read tracking** -- Mentally track which files and symbols have been read

---

## File Reading Strategy

### Large files (500+ lines)
```
BAD:  Read("app/services/user_service.py")              ← entire 800-line file
GOOD: Read("app/services/user_service.py", offset=45, limit=30)  ← target function only
GOOD: Grep("def create_user", path="app/services/")     ← locate first
```

### Standard files (100-500 lines)
```
OK:   Read entire file (once only)
GOOD: Grep to find target location → Read with offset/limit
```

### Small files (<100 lines)
```
OK:   Read entire file (efficient)
```

### Exploration order
1. **Glob** -- Locate files
2. **Grep** -- Find target symbols/patterns
3. **Read** (offset/limit) -- Read only the needed portion
4. **Read** (full) -- Only for small files or when full understanding required

---

## Budget by Difficulty

### Simple Tasks
| Category | Budget | Notes |
|----------|--------|-------|
| File reads | 1-2 full | Target files only |
| Exploration | 1-2 Grep calls | Minimal exploration |
| **Total context** | **~2K tokens** | |

### Medium Tasks
| Category | Budget | Notes |
|----------|--------|-------|
| File reads | 3-5 | Target + related files |
| Exploration | 3-5 Grep/Glob calls | Pattern verification |
| Reference docs | 1-2 from optional/ | As needed |
| **Total context** | **~5-10K tokens** | |

### Complex Tasks
| Category | Budget | Notes |
|----------|--------|-------|
| File reads | No limit (avoid duplicates) | Prefer symbol-level reads |
| Exploration | As needed | Systematic exploration |
| Reference docs | As needed from optional/ | |
| **Total context** | **~15-30K tokens** | Maintain efficiency |

---

## Read Tracking (Mental Model)

Track files read during large tasks:

```
## Read Files
- app/api/todos.py:23-55 (create_todo, update_todo)
- app/models/todo.py (full, 40-line small file)
- app/schemas/todo.py:1-20 (TodoCreate schema only)

## Not Yet Read (next steps)
- app/services/todo_service.py (read during implementation)
- tests/test_todos.py (reference during test writing)
```

**Purpose**:
- Prevent reading the same file twice
- Clarify next steps
- Efficient context transfer when spawning agents

---

## Context Overflow Symptoms & Response

| Symptom | Cause | Response |
|---------|-------|----------|
| Forgetting previously read code | Context window saturation | Take notes on key info; keep re-referable |
| Re-reading the same file | Insufficient tracking | Check Read Tracking log |
| Output suddenly becomes terse | Output token shortage | Write essentials only; skip supplementary explanations |
| Ignoring instructions | Rule file content forgotten | Re-reference only core rules |
| Intermediate work results vanish | Context compression triggered | Use `/note`; persist state |

**Prevention**: Enable `--uc` mode; distribute context via agent delegation

---

## Agent Spawn Context Efficiency

Optimize context when spawning worker agents:

```
GOOD: "Modify the create_todo() function in app/api/todos.py (lines 23-55).
       Add a priority field to the TodoCreate schema (app/schemas/todo.py:5-15),
       and update create_todo to handle it."

BAD:  "Modify the todos-related code." (agent must explore entire codebase)
```

**Principle**: Pass file paths + line numbers + specific changes to workers.
The orchestrator bears the exploration cost so workers can focus on execution.
