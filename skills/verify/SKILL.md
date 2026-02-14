---
name: verify
description: Ensure code quality with systematic 6-phase verification loop. Use after feature completion, before PR creation, after refactoring, or for periodic quality checks. Keywords: verify, verification, check, validate, quality, build, lint, test, security, pr-ready.
---

# Verification Loop Skill

## Purpose
Ensure quality through systematic 6-phase verification after code changes and confirm PR-ready state.

**Core Principle**: Build failure → Immediate stop → Fix issue → Re-verify

## Activation Triggers
- After feature implementation completion
- Before PR creation (`--pre-pr`)
- After refactoring work
- Periodic quality checks (15-min intervals or major component completion)
- User explicit request: `/verify`, `verify`, `check`

## 6-Phase Verification Pipeline

### Phase 1: Build Verification 🔨
**Purpose**: Confirm project compilation/build success

```bash
# JavaScript/TypeScript
npm run build || pnpm build || yarn build

# Python
python -m py_compile src/**/*.py

# Go
go build ./...

# Rust
cargo build
```

**On Failure**: 🚨 **Immediate stop** - Build error resolution is top priority

---

### Phase 2: Type Checking 📝
**Purpose**: Verify type safety

```bash
# TypeScript
npx tsc --noEmit

# Python (with type hints)
pyright src/ || mypy src/

# Flow
npx flow check
```

**Output**: Type error count and locations

---

### Phase 3: Linting 🔍
**Purpose**: Detect code style and potential issues

```bash
# JavaScript/TypeScript
npm run lint || npx eslint src/

# Python
ruff check src/ || flake8 src/

# Go
golangci-lint run

# Rust
cargo clippy
```

**Output**: Lint violation count and severity

---

### Phase 4: Testing 🧪
**Purpose**: Confirm test passing and coverage

```bash
# JavaScript/TypeScript
npm test -- --coverage

# Python
pytest --cov=src --cov-report=term-missing

# Go
go test -cover ./...

# Rust
cargo test
```

**Criteria**:
- ✅ All tests pass
- ✅ Coverage ≥ 80% (business logic)
- ⚠️ Coverage < 80% → Show warning

---

### Phase 5: Security Scanning 🛡️
**Purpose**: Check security vulnerabilities and sensitive information exposure

**5.1 Secrets Detection**:
```bash
# Check .env, credentials, API keys
grep -r "PRIVATE_KEY\|SECRET\|PASSWORD\|API_KEY" src/ --include="*.ts" --include="*.js" --include="*.py"
```

**5.2 Debug Statement Detection**:
```bash
# Check console.log, print, debugger
grep -rn "console\.log\|console\.debug\|debugger" src/ --include="*.ts" --include="*.tsx" --include="*.js"
grep -rn "print(" src/ --include="*.py" | grep -v "# noqa"
```

**5.3 Dependency Vulnerabilities** (optional):
```bash
npm audit --audit-level=high
pip-audit
```

**Output**: List of discovered security issues

---

### Phase 6: Diff Review 📋
**Purpose**: Final review of changes

```bash
git diff --stat
git diff HEAD~1 --name-only
```

**Review Items**:
- [ ] No unintended file changes
- [ ] No missing error handling
- [ ] Edge case handling confirmed
- [ ] Unnecessary console.log/print removed
- [ ] No hardcoded values

---

## Verification Modes

### Quick Mode (`/verify quick`)
Fast verification - Execute Build + Type Check only
```
Phase 1: Build ✅
Phase 2: Types ✅
⏱️ Complete: ~30 seconds
```

### Full Mode (`/verify` or `/verify full`)
Complete 6-phase verification
```
Phase 1: Build ✅
Phase 2: Types ✅
Phase 3: Lint ✅
Phase 4: Tests ✅ (Coverage: 85%)
Phase 5: Security ✅
Phase 6: Diff ✅
⏱️ Complete: ~2-5 minutes
```

### Pre-PR Mode (`/verify pre-pr`)
Strict verification before PR submission (Enhanced security)
```
Phase 1-6: Full verification
+ Additional security scan
+ Dependency vulnerability check
+ Commit message review
```

### Pre-Commit Mode (`/verify pre-commit`)
Quick verification before commit
```
Phase 1: Build ✅
Phase 2: Types ✅
Phase 3: Lint ✅
Phase 5: Security (secrets only) ✅
```

---

## Report Format

### Success Report
```
╔══════════════════════════════════════════════════════╗
║              🎯 VERIFICATION REPORT                  ║
╠══════════════════════════════════════════════════════╣
║ Phase 1: Build        ✅ OK                          ║
║ Phase 2: Type Check   ✅ OK                          ║
║ Phase 3: Lint         ✅ OK (0 issues)               ║
║ Phase 4: Tests        ✅ OK (47/47 passed, 85% cov)  ║
║ Phase 5: Security     ✅ OK (0 issues)               ║
║ Phase 6: Diff Review  ✅ OK (3 files changed)        ║
╠══════════════════════════════════════════════════════╣
║ 📊 Total Issues: 0                                   ║
║ 🚀 PR Ready: YES                                     ║
╚══════════════════════════════════════════════════════╝
```

### Failure Report
```
╔══════════════════════════════════════════════════════╗
║              🎯 VERIFICATION REPORT                  ║
╠══════════════════════════════════════════════════════╣
║ Phase 1: Build        ✅ OK                          ║
║ Phase 2: Type Check   ❌ FAIL (3 errors)             ║
║   → src/api/user.ts:45 - Type 'string' not assignable║
║   → src/utils/format.ts:12 - Missing return type     ║
║   → src/components/Card.tsx:78 - Property missing    ║
║ Phase 3: Lint         ⚠️ WARN (2 warnings)           ║
║ Phase 4: Tests        ⏸️ SKIPPED (blocked by Phase 2)║
║ Phase 5: Security     ⏸️ SKIPPED                     ║
║ Phase 6: Diff Review  ⏸️ SKIPPED                     ║
╠══════════════════════════════════════════════════════╣
║ 📊 Total Issues: 5                                   ║
║ 🚀 PR Ready: NO                                      ║
║                                                      ║
║ 🔧 Suggested Fixes:                                  ║
║ 1. Fix type errors in src/api/user.ts:45            ║
║ 2. Add return type to formatDate function           ║
║ 3. Add missing 'onClick' prop to Card component     ║
╚══════════════════════════════════════════════════════╝
```

---

## Periodic Verification Strategy

### Mental Checkpoints
- After function/component completion → `/verify quick`
- After 15 minutes elapsed → `/verify`
- Major milestone completed → `/verify full`

### Session Integration
```
Start work
    │
    ├─→ Feature implementation
    │       │
    │       └─→ [15min elapsed] → /verify quick
    │
    ├─→ Component completion
    │       │
    │       └─→ /verify
    │
    ├─→ Feature completion
    │       │
    │       └─→ /verify full
    │
    └─→ PR preparation
            │
            └─→ /verify pre-pr
```

---

## Integration with Other Skills

### With `/checkpoint`
```
/checkpoint create "before-refactor"
... refactoring work ...
/verify full
/checkpoint verify "before-refactor"  # Compare changes
```

### With `/feature-planner`
Auto-execute `/verify` at each Phase Quality Gate

### With `/code-review`
```
/verify pre-pr
/code-review  # Code review after verification passes
```

---

## Auto-Fix Suggestions

Suggest automatic fixes on verification failure:

| Issue Type | Suggested Fix |
|------------|---------------|
| Type Error | Add/modify type annotation |
| Lint Error | `npm run lint -- --fix` or `ruff --fix` |
| Missing Test | Suggest test case creation |
| console.log | Remove line or replace with logger |
| Security Issue | Suggest moving to environment variables |

---

## Configuration

Project-specific configuration (`.claude/verify.config.json`):
```json
{
  "coverageThreshold": 80,
  "skipPhases": [],
  "customCommands": {
    "build": "pnpm build",
    "test": "pnpm test:ci",
    "lint": "pnpm lint"
  },
  "securityPatterns": [
    "API_KEY",
    "SECRET",
    "PASSWORD",
    "PRIVATE_KEY"
  ],
  "ignoreFiles": [
    "**/*.test.ts",
    "**/*.spec.ts",
    "**/fixtures/**"
  ]
}
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `/verify` | Full 6-phase verification |
| `/verify quick` | Verify Build + Type only |
| `/verify pre-pr` | Strict verification before PR |
| `/verify pre-commit` | Quick verification before commit |
| `/verify --fix` | Fix auto-fixable issues |
