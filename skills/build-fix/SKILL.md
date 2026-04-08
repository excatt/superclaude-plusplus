---
name: build-fix
description: Expert skill for resolving build errors with minimal change principle. Use for build failures, type errors, compile errors. Keywords: build, fix, error, compile, typescript, type, resolve.
---

## Dynamic Context

Last build output:
!`cat .claude/state/last-build-error.log 2>/dev/null | tail -20 || echo "No cached build error"`

# Build Fix Skill

## Purpose
Resolve build/compile errors with **minimal changes**. Target only build passing - no architecture changes, refactoring, or feature additions.

**Core Principle**: Minimal change → Build passes → Done. Nothing more.

## Activation Triggers
- Build failure (`npm run build` fails)
- TypeScript compilation error (`tsc --noEmit` fails)
- Multiple type errors occurring
- CI/CD pipeline build failure
- User explicit request: `/build-fix`, `fix build`, `compile error`

---

## Scope Definition

### ✅ DO Fix (Targets for fixing)
| Category | Examples |
|----------|----------|
| **Type annotations** | Missing types, incorrect types |
| **Null/Undefined handling** | Optional chaining, nullish coalescing |
| **Import/Export** | Missing imports, incorrect paths |
| **Type definitions** | Add/modify interface, type |
| **Dependency issues** | Missing packages, version conflicts |
| **Config files** | tsconfig, eslint configuration errors |

### ❌ DON'T Change (Don't touch)
| Category | Reason |
|----------|--------|
| **Unrelated code** | Out of scope |
| **Architecture** | Requires separate work |
| **Variable/function names** | Refactoring area |
| **Logic flow** | Risk of functionality change |
| **Performance optimization** | Separate optimization work |
| **Test code** | Test fixes are separate |

---

## Workflow

### Step 1: Collect Errors
```bash
# TypeScript
npx tsc --noEmit 2>&1 | head -100

# Build
npm run build 2>&1

# ESLint (errors only)
npx eslint src/ --quiet
```

### Step 2: Classify Errors
```
/build-fix

🔍 Analyzing errors...
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

### Step 3: Apply Minimal Fixes
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

... (continued)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Verify
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

### Strategy 1: Type Assertion (Quick but risky)
```typescript
// Quick fix - use sparingly
const data = response as UserData;
```

### Strategy 2: Type Guard (Safe)
```typescript
// Safer approach
function isUser(obj: unknown): obj is User {
  return obj !== null && typeof obj === 'object' && 'id' in obj;
}
```

### Strategy 3: Type Narrowing (Recommended)
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
| Test failures | `/verify` → Fix tests |
| Performance issues | `/perf-optimize` |
| Security vulnerabilities | `/security-audit` |
| Refactoring needed | `/refactoring` |
| Architecture change | `/architecture` |
| Add new feature | `/feature-planner` |

---

## Integration

### With `/verify`
```
/build-fix → Build passes
/verify quick → Confirm Build + Type
/verify full → Full quality verification
```

### With `/checkpoint`
```
/checkpoint create "before-build-fix"
/build-fix
/verify quick
# If issues: /checkpoint restore "before-build-fix"
```

### CI/CD Integration
```yaml
# Auto-fix attempt on build failure
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
| `/build-fix` | Analyze and fix build errors |
| `/build-fix --dry-run` | Preview fixes (don't apply) |
| `/build-fix --auto` | Auto-fix (no confirmation) |
| `/build-fix <file>` | Fix specific file only |

---

## Output Format

### Success
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

### Partial Success
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
