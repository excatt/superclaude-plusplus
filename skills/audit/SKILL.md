---
name: audit
description: |
  프로젝트 고유 검증 규칙을 실행하는 스킬. 린터가 잡지 못하는 비즈니스 로직,
  아키텍처 패턴, 네이밍 컨벤션을 검증합니다. 규칙이 없으면 자동으로 부트스트랩을 제안합니다.

  Triggers: audit, check rules, 규칙 검증, run audit, audit manage, 규칙 관리
  Do NOT use for: build/lint/test (/verify), design vs implementation (/gap-analysis)
user-invocable: true
argument-hint: "[manage]"
---

# Audit Skill

Project-specific verification rules that generic linters cannot enforce.

| Skill | Checks |
|-------|--------|
| `/verify` | Build, types, lint, test, security |
| `/audit` | Business logic, architecture patterns, naming conventions |
| `/gap-analysis` | Design doc vs implementation matchRate |

## Mode Selection

```
/audit          → rules exist? → RUN mode (execute rules)
                → no rules?   → MANAGE mode (bootstrap)
/audit manage   → MANAGE mode (create/delete/sync rules)
```

Rules location: `.claude/audit-rules/*.md`

---

## RUN Mode

### Step 1: Collect & Match

Read all `.claude/audit-rules/*.md`. Match each rule's `scope` against changed files:

```bash
BASE=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')
BASE=${BASE:-main}
git diff "$BASE"...HEAD --name-only
```

Skip rules whose scope has no matching changes.

**Auto-exempt files** (always skip, no rule needed):
- Lock files: `pnpm-lock.yaml`, `uv.lock`, `package-lock.json`, `Cargo.lock`
- Generated/build output: `dist/`, `build/`, `.next/`, `__pycache__/`
- Docs: `README.md`, `CHANGELOG.md`, `LICENSE`
- Test fixtures: `fixtures/`, `__fixtures__/`, `test-data/`
- Vendor/third-party: `vendor/`, `node_modules/`
- CI/CD config: `.github/`, `.gitlab-ci.yml`, `Dockerfile`
- CLAUDE.md and `.claude/` internals

### Step 2: Execute

For each matched rule:
1. Run bash commands from `## Check` section (if any)
2. AI-analyze results against `## Pass Criteria`
3. Classify: PASS / FAIL / WARN / SKIP

### Step 3: Report

```
AUDIT REPORT
=============
  api-response-format      PASS
  error-handling           FAIL  2 violations
    src/api/users.ts:45    bare catch without error type
    src/api/posts.ts:78    empty catch block
  naming-convention        PASS
---------------------------------------------
  Rules: 3 | Passed: 2 | Failed: 1
  Status: NEEDS FIX
```

Status: all pass → `CLEAR` / any error-severity fail → `NEEDS FIX` / warning-only → `REVIEW`

### Step 4: Fix (if issues found)

Ask user via `AskUserQuestion`:
1. **전체 수정** — Apply all recommended fixes automatically
2. **개별 수정** — Review and approve each fix one by one
3. **건너뛰기** — Report only, no changes

After fixes, re-run only failed rules and show before/after comparison.

---

## MANAGE Mode

### Bootstrap (No Rules)

Detect project type from config files and propose seed rules:

| Signal | Type | Suggested Rules |
|--------|------|-----------------|
| `next` in package.json | Next.js | Server/Client separation, API response format |
| `fastapi` in pyproject.toml | FastAPI | HTTPException usage, router naming |
| `express`/`nest` in package.json | Node API | Error middleware, response wrapper |
| Any project | Universal | Naming convention |

### Change Analysis

```bash
git diff "$BASE"...HEAD --name-only --stat
```

Compare changed domains against existing rule scopes → propose CREATE/UPDATE/DELETE.

### User Confirmation

Always confirm before creating or deleting rules:

```
Proposed:
  + api-response-format   (new, covers src/api/**)
  - legacy-auth-check     (stale, files removed)

Apply? [Y/n]
```

---

## Rule Format

Each rule is a markdown file with YAML frontmatter (`name`, `scope`, `severity`) and structured sections (`What`, `Check`, `Pass Criteria`, `Examples`).

Full guide: `references/rule-format.md`
Example rules: `references/examples/`

---

## Integration

Pre-commit flow: `/verify` → `/audit` → commit

Review loop: `Implement → Spec Review → Quality Review → /verify → /audit → Complete`
