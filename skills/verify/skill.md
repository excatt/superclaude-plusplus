---
name: verify
description: 6단계 체계적 검증 루프로 코드 품질을 보장합니다. 기능 완료 후, PR 생성 전, 리팩토링 후, 또는 주기적 품질 체크 시 사용합니다. Keywords: verify, verification, check, validate, quality, build, lint, test, security, pr-ready, 검증, 확인, 품질.
---

# Verification Loop Skill

## Purpose
코드 변경 후 체계적인 6단계 검증을 통해 품질을 보장하고 PR 준비 상태를 확인합니다.

**핵심 원칙**: Build 실패 시 즉시 중단 → 문제 해결 → 재검증

## Activation Triggers
- 기능 구현 완료 후
- PR 생성 전 (`--pre-pr`)
- 리팩토링 작업 후
- 주기적 품질 체크 (15분 간격 또는 주요 컴포넌트 완료 시)
- 사용자 명시적 요청: `/verify`, `검증해줘`, `확인해줘`

## 6-Phase Verification Pipeline

### Phase 1: Build Verification 🔨
**목적**: 프로젝트 컴파일/빌드 성공 확인

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

**실패 시**: 🚨 **즉시 중단** - 빌드 에러 해결이 최우선

---

### Phase 2: Type Checking 📝
**목적**: 타입 안전성 검증

```bash
# TypeScript
npx tsc --noEmit

# Python (with type hints)
pyright src/ || mypy src/

# Flow
npx flow check
```

**출력**: 타입 에러 개수 및 위치

---

### Phase 3: Linting 🔍
**목적**: 코드 스타일 및 잠재적 문제 검출

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

**출력**: 린트 위반 개수 및 심각도

---

### Phase 4: Testing 🧪
**목적**: 테스트 통과 및 커버리지 확인

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

**기준**:
- ✅ 모든 테스트 통과
- ✅ 커버리지 ≥ 80% (비즈니스 로직)
- ⚠️ 커버리지 < 80% → 경고 표시

---

### Phase 5: Security Scanning 🛡️
**목적**: 보안 취약점 및 민감 정보 노출 검사

**5.1 Secrets Detection**:
```bash
# .env, credentials, API keys 검사
grep -r "PRIVATE_KEY\|SECRET\|PASSWORD\|API_KEY" src/ --include="*.ts" --include="*.js" --include="*.py"
```

**5.2 Debug Statement Detection**:
```bash
# console.log, print, debugger 검사
grep -rn "console\.log\|console\.debug\|debugger" src/ --include="*.ts" --include="*.tsx" --include="*.js"
grep -rn "print(" src/ --include="*.py" | grep -v "# noqa"
```

**5.3 Dependency Vulnerabilities** (선택적):
```bash
npm audit --audit-level=high
pip-audit
```

**출력**: 발견된 보안 이슈 목록

---

### Phase 6: Diff Review 📋
**목적**: 변경사항 최종 검토

```bash
git diff --stat
git diff HEAD~1 --name-only
```

**검토 항목**:
- [ ] 의도치 않은 파일 변경 없음
- [ ] 누락된 에러 핸들링 없음
- [ ] 엣지 케이스 처리 확인
- [ ] 불필요한 console.log/print 제거
- [ ] 하드코딩된 값 없음

---

## Verification Modes

### Quick Mode (`/verify quick`)
빠른 검증 - Build + Type Check만 실행
```
Phase 1: Build ✅
Phase 2: Types ✅
⏱️ 완료: ~30초
```

### Full Mode (`/verify` 또는 `/verify full`)
전체 6단계 검증
```
Phase 1: Build ✅
Phase 2: Types ✅
Phase 3: Lint ✅
Phase 4: Tests ✅ (Coverage: 85%)
Phase 5: Security ✅
Phase 6: Diff ✅
⏱️ 완료: ~2-5분
```

### Pre-PR Mode (`/verify pre-pr`)
PR 제출 전 엄격한 검증 (Security 강화)
```
Phase 1-6: Full verification
+ 추가 보안 스캔
+ 의존성 취약점 검사
+ 커밋 메시지 검토
```

### Pre-Commit Mode (`/verify pre-commit`)
커밋 전 빠른 검증
```
Phase 1: Build ✅
Phase 2: Types ✅
Phase 3: Lint ✅
Phase 5: Security (secrets only) ✅
```

---

## Report Format

### 성공 보고서
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

### 실패 보고서
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
- 함수/컴포넌트 완료 후 → `/verify quick`
- 15분 경과 시 → `/verify`
- 주요 마일스톤 완료 → `/verify full`

### Session Integration
```
작업 시작
    │
    ├─→ 기능 구현
    │       │
    │       └─→ [15분 경과] → /verify quick
    │
    ├─→ 컴포넌트 완료
    │       │
    │       └─→ /verify
    │
    ├─→ 기능 완료
    │       │
    │       └─→ /verify full
    │
    └─→ PR 준비
            │
            └─→ /verify pre-pr
```

---

## Integration with Other Skills

### With `/checkpoint`
```
/checkpoint create "before-refactor"
... 리팩토링 작업 ...
/verify full
/checkpoint verify "before-refactor"  # 변경사항 비교
```

### With `/feature-planner`
각 Phase Quality Gate에서 자동 `/verify` 실행

### With `/code-review`
```
/verify pre-pr
/code-review  # 검증 통과 후 코드 리뷰
```

---

## Auto-Fix Suggestions

검증 실패 시 자동 수정 제안:

| Issue Type | Suggested Fix |
|------------|---------------|
| Type Error | 타입 어노테이션 추가/수정 |
| Lint Error | `npm run lint -- --fix` 또는 `ruff --fix` |
| Missing Test | 테스트 케이스 생성 제안 |
| console.log | 해당 라인 제거 또는 logger로 교체 |
| Security Issue | 환경변수로 이동 제안 |

---

## Configuration

프로젝트별 설정 (`.claude/verify.config.json`):
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
| `/verify` | 전체 6단계 검증 |
| `/verify quick` | Build + Type만 검증 |
| `/verify pre-pr` | PR 전 엄격한 검증 |
| `/verify pre-commit` | 커밋 전 빠른 검증 |
| `/verify --fix` | 자동 수정 가능한 것들 수정 |
