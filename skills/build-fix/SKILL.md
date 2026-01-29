---
name: build-fix
description: 최소 변경 원칙으로 빌드 에러만 해결하는 전문 스킬. 빌드 실패, 타입 에러, 컴파일 에러 발생 시 사용합니다. Keywords: build, fix, error, compile, typescript, type, resolve, 빌드, 에러, 수정, 컴파일.
---

# Build Fix Skill

## Purpose
빌드/컴파일 에러를 **최소한의 변경**으로 해결합니다. 아키텍처 변경, 리팩토링, 기능 추가 없이 오직 빌드 통과만을 목표로 합니다.

**핵심 원칙**: 최소 변경 → 빌드 통과 → 끝. 그 이상 하지 않음.

## Activation Triggers
- 빌드 실패 (`npm run build` 실패)
- TypeScript 컴파일 에러 (`tsc --noEmit` 실패)
- 타입 에러 다수 발생
- CI/CD 파이프라인 빌드 실패
- 사용자 명시적 요청: `/build-fix`, `빌드 고쳐줘`, `컴파일 에러`

---

## Scope Definition

### ✅ DO Fix (수정 대상)
| Category | Examples |
|----------|----------|
| **타입 어노테이션** | 누락된 타입, 잘못된 타입 |
| **Null/Undefined 처리** | Optional chaining, nullish coalescing |
| **Import/Export** | 누락된 import, 잘못된 경로 |
| **타입 정의** | interface, type 추가/수정 |
| **의존성 문제** | 누락된 패키지, 버전 충돌 |
| **설정 파일** | tsconfig, eslint 설정 오류 |

### ❌ DON'T Change (건드리지 않음)
| Category | Reason |
|----------|--------|
| **관련 없는 코드** | 범위 외 |
| **아키텍처** | 별도 작업 필요 |
| **변수명/함수명** | 리팩토링 영역 |
| **로직 흐름** | 기능 변경 위험 |
| **성능 최적화** | 별도 최적화 작업 |
| **테스트 코드** | 테스트 수정은 별개 |

---

## Workflow

### Step 1: 에러 수집
```bash
# TypeScript
npx tsc --noEmit 2>&1 | head -100

# Build
npm run build 2>&1

# ESLint (에러만)
npx eslint src/ --quiet
```

### Step 2: 에러 분류
```
/build-fix

🔍 에러 분석 중...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Error Summary
┌──────────────────────┬───────┐
│ Category             │ Count │
├──────────────────────┼───────┤
│ Type Inference       │ 5     │
│ Missing Types        │ 3     │
│ Import Errors        │ 2     │
│ Null/Undefined       │ 4     │
│ Config Issues        │ 1     │
└──────────────────────┴───────┘
Total: 15 errors

🎯 Resolution Order:
1. Config Issues (blocks others)
2. Import Errors (dependency chain)
3. Missing Types (foundation)
4. Type Inference (detail)
5. Null/Undefined (safety)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3: 최소 수정 적용
```
🔧 Fixing errors...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/15] src/api/user.ts:45
  Error: Property 'id' does not exist on type '{}'
  Fix: Add type annotation

  - const user = {}
  + const user: User = {} as User

[2/15] src/utils/format.ts:12
  Error: Parameter 'date' implicitly has 'any' type
  Fix: Add parameter type

  - function formatDate(date) {
  + function formatDate(date: Date): string {

... (계속)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: 검증
```
✅ Verification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Build:     ✅ PASS
TypeCheck: ✅ PASS (0 errors)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Changes Summary:
- Files modified: 8
- Lines changed: +23, -15
- No architectural changes
- No logic changes

🎯 Build fixed with minimal changes!
```

---

## Common Error Patterns

### 1. Type Inference Failures
```typescript
// ❌ Error: Type 'string' is not assignable to type 'number'
const count = "5";  // inferred as string

// ✅ Fix: Explicit type or conversion
const count: number = 5;
// or
const count = Number("5");
```

### 2. Null/Undefined Handling
```typescript
// ❌ Error: Object is possibly 'undefined'
const name = user.profile.name;

// ✅ Fix: Optional chaining
const name = user?.profile?.name;

// ✅ Fix: Nullish coalescing
const name = user?.profile?.name ?? "Unknown";
```

### 3. Missing Properties
```typescript
// ❌ Error: Property 'email' is missing
const user: User = { name: "John" };

// ✅ Fix: Add missing property
const user: User = { name: "John", email: "" };

// ✅ Fix: Make optional in type
interface User {
  name: string;
  email?: string;  // optional
}
```

### 4. Import Errors
```typescript
// ❌ Error: Module not found
import { utils } from "./util";

// ✅ Fix: Correct path
import { utils } from "./utils";

// ✅ Fix: Add missing export
// In utils.ts: export { utils };
```

### 5. Generic Constraints
```typescript
// ❌ Error: Type 'T' is not assignable to constraint
function process<T>(item: T) {
  return item.id;  // Error: Property 'id' doesn't exist
}

// ✅ Fix: Add constraint
function process<T extends { id: string }>(item: T) {
  return item.id;
}
```

### 6. React Hook Violations
```typescript
// ❌ Error: React Hook is called conditionally
if (condition) {
  const [state, setState] = useState();
}

// ✅ Fix: Move hook outside condition
const [state, setState] = useState();
if (condition) {
  // use state here
}
```

### 7. Async/Await Issues
```typescript
// ❌ Error: 'await' only allowed in async function
function fetchData() {
  const data = await api.get();
}

// ✅ Fix: Add async
async function fetchData() {
  const data = await api.get();
}
```

### 8. Module Resolution
```typescript
// ❌ Error: Cannot find module '@/components'

// ✅ Fix: Check tsconfig.json paths
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

---

## Fix Strategies

### Strategy 1: Type Assertion (빠르지만 위험)
```typescript
// Quick fix - use sparingly
const data = response as UserData;
```

### Strategy 2: Type Guard (안전)
```typescript
// Safer approach
function isUser(obj: unknown): obj is User {
  return obj !== null && typeof obj === 'object' && 'id' in obj;
}
```

### Strategy 3: Type Narrowing (권장)
```typescript
// Best practice
if (user && user.profile) {
  // TypeScript knows user.profile exists here
}
```

---

## When NOT to Use

| Situation | Use Instead |
|-----------|-------------|
| 테스트 실패 | `/verify` → 테스트 수정 |
| 성능 문제 | `/perf-optimize` |
| 보안 취약점 | `/security-audit` |
| 리팩토링 필요 | `/refactoring` |
| 아키텍처 변경 | `/architecture` |
| 새 기능 추가 | `/feature-planner` |

---

## Integration

### With `/verify`
```
/build-fix → 빌드 통과
/verify quick → Build + Type 확인
/verify full → 전체 품질 검증
```

### With `/checkpoint`
```
/checkpoint create "before-build-fix"
/build-fix
/verify quick
# 문제 있으면: /checkpoint restore "before-build-fix"
```

### CI/CD 연동
```yaml
# Build 실패 시 자동 수정 시도
- name: Build
  run: npm run build
  continue-on-error: true

- name: Auto Fix
  if: failure()
  run: claude build-fix --auto
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/build-fix` | 빌드 에러 분석 및 수정 |
| `/build-fix --dry-run` | 수정 미리보기 (적용 안 함) |
| `/build-fix --auto` | 자동 수정 (확인 없이) |
| `/build-fix <file>` | 특정 파일만 수정 |

---

## Output Format

### 성공
```
╔══════════════════════════════════════════════════════╗
║              🔧 BUILD FIX COMPLETE                   ║
╠══════════════════════════════════════════════════════╣
║ Errors Fixed: 15/15                                  ║
║ Files Modified: 8                                    ║
║ Lines Changed: +23, -15                              ║
║                                                      ║
║ Build Status: ✅ PASSING                             ║
║ Type Check: ✅ PASSING                               ║
║                                                      ║
║ ⚠️  Reminder: Run /verify for full quality check    ║
╚══════════════════════════════════════════════════════╝
```

### 부분 성공
```
╔══════════════════════════════════════════════════════╗
║              🔧 BUILD FIX PARTIAL                    ║
╠══════════════════════════════════════════════════════╣
║ Errors Fixed: 12/15                                  ║
║ Remaining: 3                                         ║
║                                                      ║
║ ⚠️  Manual intervention needed:                     ║
║ 1. src/complex/module.ts:89 - Circular dependency   ║
║ 2. src/legacy/old.ts:45 - Deprecated API usage      ║
║ 3. src/types/index.ts:12 - Conflicting declarations ║
║                                                      ║
║ 💡 Suggestions:                                      ║
║ - Consider refactoring circular dependency          ║
║ - Update deprecated API calls                       ║
╚══════════════════════════════════════════════════════╝
```
