# Claude Code Behavioral Rules

Rules here either **override a harness default** or add something the model
cannot know on its own. Behavior the harness or the model already guarantees
(verification before completion claims, persistence until done, parallel tool
calls, scope discipline, root-cause-first debugging, faithful reporting,
matching surrounding code style) is intentionally not restated.

## Rule Priority System

🔴 **CRITICAL**: Security, data safety, production breaks - Never compromise
🟡 **IMPORTANT**: Quality, maintainability, professionalism - Strong preference
🟢 **RECOMMENDED**: Optimization, style, best practices - Apply when practical

**Conflict Resolution**: 1) Safety First 2) Scope > Features 3) Quality > Speed 4) Context Matters

---

## Difficulty Assessment & Protocol Branching
**Priority**: 🔴 **Triggers**: Before starting any implementation/modification task (Step 0)

Assess difficulty before starting any task; branch protocol depth based on difficulty level.

### Assessment Criteria

| Signal | Simple | Medium | Complex |
|--------|--------|--------|---------|
| File count | 1 | 2-3 | 4+ |
| Pattern match | Repeating existing pattern | Applying existing pattern (new domain) | Introducing new pattern |
| Design decisions | None | Some required | Architecture decisions required |
| Cross-module | Within single module | 2-3 modules | System-wide |
| Change nature | Additive | Modification + some refactoring | Structural change |
| Expected diff | <50 lines | 50-200 lines | 200+ lines |

**Verdict**: Majority rule. When uncertain, assess one level higher.

### Protocol Branching

**Simple → Fast Track**:
- `/confidence-check`: Skip
- Analysis/planning: Skip → implement immediately
- Verification: Minimal (build/test pass confirmation only)
- Two-Stage Review: Stage 1 only (verify change diff)

**Medium → Standard Protocol**:
- `/confidence-check`: Execute
- Analysis: Brief → Planning: Brief → Implement → Full verification
- Two-Stage Review: Stage 1 + Stage 2

**Complex → Extended Protocol**:
- `/confidence-check`: Required
- Analysis: Full → Planning: Full + checkpoints → Implement → Mid-checkpoint (50%) → Full verification
- Two-Stage Review: Stage 1 + Stage 2 + Cascade Impact Review
- Additional references: `optional/REASONING_TEMPLATES.md`, `optional/CONTEXT_BUDGET.md`

### Difficulty Misjudgment Recovery
- Started as Simple but grew complex → Upgrade to Medium, record progress
- Started as Medium but architecture decisions needed → Upgrade to Complex
- Started as Complex but actually simple → Complete quickly (minimize overhead)

---

## Auto-Skill & Proactive Suggestion
**Priority**: 🔴 (Auto-Skill) / 🟡 (Proactive)

Mechanical skill activation is handled by the `UserPromptSubmit` hook
(`scripts/skill-matcher.py` + `.claude/skill-rules.json`).

**Execution priority**: Difficulty assessment (Step 0) → `/confidence-check` → `/checkpoint` → Two-Stage Review → `/learn`
**Difficulty gate**: Simple → skip confidence-check, may skip Stage 2 | Medium → Standard | Complex → Full + Cascade Impact
**Exceptions**: Typo/comment fixes, `--no-check` request
**Frequency control**: Once per skill per session; no re-suggestion after rejection

---

## Two-Stage Review System
**Priority**: 🔴 **Triggers**: Task completion, pre-commit, pre-PR

### Stage 1: Spec Compliance Review
**Purpose**: Verify requirements compliance (detect both excess and omissions)

**Reviewer Principle**: "DO NOT trust the implementer's report"
- Read actual code (don't trust report)
- Compare line-by-line with requirements
- Identify missing features and unrequested additions

**Output**: ✅ Spec compliant | ❌ Issues: [list of omissions/excess]

**Auto-pass**: Difficulty Simple + diff < 50 lines + single file + no new dependencies → diff-reading only

### Stage 2: Code Quality Review
**Purpose**: Verify implementation quality (only after Stage 1 passes)

| Severity | Action |
|------|------|
| Critical | Fix immediately required |
| Important | Fix before proceeding |
| Minor | Can handle later |

**Confidence Filter**: Only report issues with ≥80% confidence. Below 80% → classify as Minor (informational).

**Auto-pass**: Difficulty Simple + all tests green + lint/typecheck passing

### Stage 3: Cascade Impact Review (Complex difficulty only)
**Key question**: "Did this change affect anything elsewhere?"
- Grep references to changed functions/types/variables, verify call sites
- Run full existing test suite (including tests outside changed files)

**Trigger conditions**: Complex difficulty OR 4+ modules changed OR public API changed

### Review Loop
```
Implement → Spec Review → [Fail: Fix → Re-review] →
Quality Review → [Fail: Fix → Re-review] →
Cascade Impact (Complex only) → [Fail: Fix → Re-review] →
/verify → /audit → Complete
```

---

## React Code Review
**Priority**: 🔴 **Triggers**: .jsx/.tsx + 리뷰 keyword

When `.jsx`/`.tsx` + review keyword detected → **Always** execute `/react-best-practices` first

---

## Feature Planning
**Priority**: 🟡 **Triggers**: New feature requests

- >3 files or >2 hour work → `/feature-planner` required
- Single file, <30 min work → Can skip

---

## PDCA Workflow
**Priority**: 🟡 **Triggers**: Feature implementation, design document creation

| Phase | Deliverable |
|-------|--------|
| Plan | `docs/01-plan/{feature}.plan.md` |
| Design | `docs/02-design/{feature}.design.md` |
| Do | Source code |
| Check | `docs/03-analysis/{feature}.analysis.md` (gap analysis) |
| Act | Code modifications: matchRate <90% → iterate (max 5) |
| Report | `docs/04-report/{feature}.report.md` |

**Gap Analysis**: API, data model, feature behavior, convention. matchRate ≥90% → Report, <90% → Act iteration.

---

## Assumption Transparency
**Priority**: 🔴 **Triggers**: All implementation tasks

- When multiple interpretations exist, state which one you picked and why —
  or present the options if the choice materially changes the work.

### Direction Correction Rule
Track the number of times the user corrects direction or requests a redo:
- **1 correct**: Apply correction, continue
- **2+ corrects**: Reconfirm full scope — "Let me summarize my understanding of the full requirements" then get user confirmation
- **1 redo**: Analyze root cause, restart
- **2 redos**: Stop immediately → ask user to re-specify requirements

**correct vs redo**: correct = partial adjustment ("그게 아니라 이렇게 해줘") | redo = full restart ("아예 다시 해줘", "이 방향 아니야")

---

## Surgical Change Preferences
**Priority**: 🔴 **Triggers**: Modifying existing code

- Orphans YOUR changes created (unused imports, variables) → clean up.
  Pre-existing dead code → mention it, don't delete it.
- Bug fix diffs must not include drive-by formatting/refactoring changes.

---

## Circuit Breaker (3+ Fixes Architecture Rule)
**Priority**: 🔴 **Triggers**: Repeated fix failures

After 3 fix attempts still failing:
1. **Stop immediately** - No more fix attempts
2. **Architecture review** - "Is this pattern fundamentally correct?"
3. **Agent Struggle Report** - diagnosis-only report: Task + Attempts +
   Failure Classification (Repo Gap | Architecture | External | Requirement |
   Capability) + Recommended Action
4. **User escalation** - Deliver report and discuss before continuing

The `circuit-breaker.sh` hook mechanically detects 3 repetitions of the same
error and auto-halts. Diagnosis only — no auto-fix; user decides whether to retry.

**Pattern indicators** (architecture problem signals): each fix creates new
problems elsewhere, or "major refactoring" claims appear.
**Red Flag**: "One more try" (after already 2+ failures)

---

## Git Preferences
**Priority**: 🔴

- **No Co-Authored-By**: Never include Claude co-author lines in commits
  (explicit override of the harness default).
- Meaningful commit messages (no "fix", "update"); Conventional Commit format
  when the project uses it.

---

## File Organization
**Priority**: 🟡 **Triggers**: File creation, documentation

- Tests: `tests/`, `__tests__/`, `test/` — no test files next to source
- Scripts: `scripts/`, `tools/`, `bin/`
- Claude-generated docs/reports: `claudedocs/`

---

## Project Rules
**Priority**: 🔴

- **Package managers**: Python → uv (pip/poetry/pipenv forbidden), Node.js →
  pnpm (npm/yarn forbidden). Details and required file layouts: CONVENTIONS.md.
- **Safety**: Check deps before using libraries | Plan → Execute → Verify
- **Security**: No hardcoded credentials | On security incident, stop
  immediately → `security-engineer`

Dockerfile/CI patterns, Security Checklist details: `optional/PROJECT_RULES.md`

---

## Goal-Driven Autonomous Loops (`/goal`)
**Priority**: 🔴 **Triggers**: Multi-turn work with a verifiable end state

- Strong success criteria (test counts, exit codes, file existence) →
  `/goal "<verifiable condition>"` loops autonomously (Claude Code 2.1.139+).
- Weak criteria ("make it work", "improve it") → clarify first.
  **NEVER pass weak criteria to `/goal`** — guarantees runaway loops.
- Safety nets stay active regardless: Circuit Breaker overrides `/goal`;
  Two-Stage Review runs on completion.

Condition patterns, anti-patterns, and the `/loop` vs `/goal` decision table:
`optional/GOAL_PATTERNS.md`

---

## Session Protocols
**Priority**: 🟢

- **Note**: `/note <content>` persists memos across sessions.
- Structured session snapshots for long tasks: `optional/PROTOCOLS.md`.
