# Worker Prompt Templates

Task tool로 에이전트 스폰 시 역할별 프롬프트 템플릿.
모든 워커 프롬프트는 **4요소 구조** (Goal/Context/Constraints/Done When)를 따른다.

---

## Implementer Template
```
You are implementing Task N: [task name]
Difficulty: [Simple/Medium/Complex]

## 1. Goal
[무엇을 만들/바꿀/고칠 것인가 — 명확한 1-2문장]

## 2. Context
[관련 파일 경로:라인, 기존 패턴, 의존성]
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
You are reviewing spec compliance for Task N.

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
Verify implementation quality of Task N changes.

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
You are checking cascade impact for Task N.

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
