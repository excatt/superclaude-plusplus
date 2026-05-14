# Harness Mode

**Purpose**: Agent drives the entire implementation while the engineer focuses on intent definition, environment design, and feedback.

**Triggers**:
- Explicit: `--harness`, "에이전트한테 맡겨", "전부 자동으로"
- Large-scale delegation: "이 기능 전체 구현해", "처음부터 끝까지"
- Repetitive task delegation: "이 패턴으로 나머지도 다 만들어"

## Role Division

| Role | Engineer (User) | Agent |
|------|-----------------|-------|
| **Intent** | Define requirements and success criteria | Interpret requirements, ask clarifying questions |
| **Environment** | Architecture decisions, constraints | Code generation, testing, iteration |
| **Feedback** | Review, direction adjustments | PR creation, automated verification |
| **Quality** | Final approval | Lint, typecheck, test execution |

## Harness Workflow

```
┌─────────────────────────────────────────────────────────┐
│  Phase 1: INTENT (Engineer-led)                         │
│  ↓ Define requirements + success criteria + constraints │
├─────────────────────────────────────────────────────────┤
│  Phase 2: SCAFFOLD (Agent-led)                          │
│  ↓ Structure design, type definitions, module boundaries│
│  ↓ Proceed after user confirmation                      │
├─────────────────────────────────────────────────────────┤
│  Phase 3: IMPLEMENT (Agent autonomous)                  │
│  ↓ Code generation → test → lint → iterate              │
│  ↓ Parallel agents for independent modules              │
├─────────────────────────────────────────────────────────┤
│  Phase 4: VERIFY (Agent → Engineer)                     │
│  ↓ Full test suite + Two-Stage Review                   │
│  ↓ Agent Struggle Report (on failure)                   │
├─────────────────────────────────────────────────────────┤
│  Phase 5: DELIVER (Converge)                            │
│  → Commit/PR + engineer final approval                  │
└─────────────────────────────────────────────────────────┘
```

## Safety Guardrails

| Rule | Description |
|------|-------------|
| **Phase Gate** | User confirmation required after Phase 2 (scaffold approval) |
| **Scope Lock** | No changes outside the scope defined in INTENT |
| **Struggle Escalation** | After 3 failures: Agent Struggle Report → user decides |
| **No Silent Decisions** | Architecture decisions always presented to user |
| **Incremental Delivery** | Large tasks split into module-level units with intermediate verification |

## Dependency Flow Enforcement

Harness Mode strictly enforces dependency direction:
```
Types → Config → Domain → Service → Runtime → UI
```

- **Violation detection**: Warn on reverse-direction imports
- **Verification timing**: At Phase 2 (Scaffold) completion + Phase 4 (Verify)
- **Violation handling**: Report to user; no automatic fixes

## Codebase Garbage Collection

Suggest running `codebase-gc` agent at Harness Mode session end:
- Dead code detection (unused exports, orphan files)
- Import cleanup (unused, duplicated)
- Documentation consistency check (code changes not reflected in docs)
- Test coverage gap reporting

## Integration with Existing Modes

| Combined Mode | Effect |
|---------------|--------|
| `--harness --orchestrate` | Maximize parallel agent utilization |
| `--harness --safe-mode` | User confirmation at every phase (`/goal` incompatible) |
| `--harness --think-hard` | Deep analysis during scaffold phase |
| `--harness --uc` | Compressed reporting, token savings |
| `--harness` + `/goal` | After Phase 2 approval, declare DELIVER condition with `/goal` for autonomous Phase 3→4 loop |

## /goal Integration (v2.2+)

After Phase 2 (SCAFFOLD) user approval, the engineer can hand off Phase 3 (IMPLEMENT) → Phase 4 (VERIFY) iteration to Claude Code's native `/goal` command (2.1.139+). The harness checks the condition after each turn and continues until met.

**Declare on entry to Phase 3**:
```
/goal "pnpm test → 0 failures AND pnpm build exit 0 AND PR opened"
```

**Condition requirements** (no exceptions):
- Reference command exit codes, counts, or file existence — never subjective state
- Must be falsifiable by a single shell command the engineer can run
- Must include final delivery artifact (PR opened, branch merged, etc.)

**Soft check caveat**: `/goal`'s per-turn check uses a small model. It judges whether the condition *seems* met, not whether tests actually passed. Therefore:
- Verification Iron Law gates the final completion claim (hard evidence required)
- Circuit Breaker overrides `/goal` — diagnosis report wins on 3 repeated failures
- Phase 4 (VERIFY) Two-Stage Review still runs regardless of loop termination

**Anti-pattern**: `/goal "코드가 잘 동작하면 멈춰"` — soft check + subjective wording = runaway loop. See `optional/GOAL_PATTERNS.md` for safe and unsafe patterns.

**Termination**:
- Automatic when condition holds
- `/goal clear` if scope drifts or you observe wrong direction
- Forced halt by `circuit-breaker.sh` after 3 same-error repetitions

---

## v2.0 Enhancements

### Worktree Isolation
`harness-worker` agents run in independent git checkouts using `isolation: worktree` frontmatter.
- Prevents main branch contamination
- No conflicts between parallel workers
- Worktree auto-cleanup when no changes present

### Agent Teams Integration
When `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable is set:
- TEAM phase: Team Lead autonomously spawns team members
- `team-implementer` (worktree isolation) + `team-reviewer` (read-only, opus) combination
- Autonomous coordination through shared task lists
- Falls back to existing subagent pattern when disabled

### Circuit Breaker (Mechanical Enforcement)
`circuit-breaker.sh` (Stop hook) mechanically replaces the "3-failure rule":
- Auto-stops on 3 repetitions of the same error pattern
- Returns `{"decision":"block"}` to force Claude into architecture review
- Counts within a 10-minute window; logs auto-cleanup
