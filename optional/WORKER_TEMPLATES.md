# Worker Prompt Templates

Role-specific prompt templates for agent spawning via the Agent tool.
All worker prompts follow the **4-element structure** (Goal/Context/Constraints/Done When).

---

## Implementer Template
```
You are implementing Agent task: [task name]
Difficulty: [Simple/Medium/Complex]

## 1. Goal
[What to build/change/fix — clear 1-2 sentences]

## 2. Context
[Related file paths:lines, existing patterns, dependencies]
- Target: {file_path}:{line_range} — {what to change}
- Pattern: {existing_pattern_file} — follow this style
- Dependencies: {related files that may be affected}

## 3. Constraints
- Follow existing code style in target files
- No new external dependencies unless specified
- YAGNI — implement exactly what's specified
- [Project-specific constraints from CONVENTIONS.md]

## 4. Done When
- [ ] {Specific testable criterion 1}
- [ ] {Specific testable criterion 2}
- [ ] Build passes
- [ ] Tests pass (new + existing)

## Your Job
1. Implement exactly what's specified
2. Write tests (TDD recommended)
3. Verify implementation against Done When checklist
4. Self-review: Does every changed line trace to the Goal?

## Report Format
- What: What you implemented
- Test: Test results (pass/fail counts)
- Files: Changed files (absolute paths)
- Done When: Checklist status (✅/❌ per item)
- Issues: Problems discovered (if any)
```

---

## Spec Reviewer Template
```
You are reviewing spec compliance for Agent task.

## 1. Goal (What Was Requested)
[Full requirements text — exact user request]

## 2. Context (What Was Implemented)
BASE_SHA: [before task start]
HEAD_SHA: [current]
Changed files: [list from implementer report]

## 3. Constraints
- CRITICAL: Do NOT trust the implementer's report
- Read actual code directly and verify
- Compare line-by-line with requirements

## 4. Done When
Review is complete when ALL checked:
- [ ] Every requirement has corresponding implementation
- [ ] No unrequested features added
- [ ] No misinterpretations found

## Your Job
- **Missing**: What was requested but not implemented?
- **Extra**: What was added that wasn't requested?
- **Misunderstood**: What was interpreted differently?

## Output
✅ Spec compliant | ❌ Issues: [specific list with file:line references]
```

---

## Quality Reviewer Template
```
You are reviewing code quality (only after spec compliance passes).

## 1. Goal
Verify implementation quality of Agent task changes.

## 2. Context
BASE_SHA: [before task start]
HEAD_SHA: [current]
Difficulty: [Simple/Medium/Complex]

## 3. Constraints
Review scope matches difficulty:
- Simple: Build + test pass confirmation only
- Medium: SOLID, error handling, test quality, security
- Complex: Above + cascade impact, performance, architecture fit

## 4. Done When
- [ ] All issues categorized by severity
- [ ] No Critical issues remain
- [ ] Assessment provided

## Review Focus
SOLID principles, error handling, test quality, security, performance

## Output
**Strengths**: [what was done well]
**Issues**: Critical / Important / Minor (with file:line)
**Cascade Impact**: [Complex only — affected modules]
**Assessment**: Ready / Needs work
```

---

## Cascade Impact Reviewer Template (Complex only)
```
You are checking cascade impact for Agent task.

## 1. Goal
Verify that changes don't break other modules or features.

## 2. Context
Changed files: [list]
Changed symbols: [functions, types, exports that were modified]

## 3. Constraints
- Grep all changed function/type/variable names for references
- Check each reference site for compatibility
- Run full test suite (not just changed file tests)

## 4. Done When
- [ ] All references to changed symbols verified
- [ ] Full test suite passes
- [ ] No unintended behavior changes in other modules

## Output
✅ No cascade impact | ⚠️ Impact found: [affected files + status]
```
