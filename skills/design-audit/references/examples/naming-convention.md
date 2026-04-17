---
name: naming-convention
scope: "*"
severity: warning
---

# Naming Convention

## What
Enforce project naming conventions defined in CONVENTIONS.md. Consistent naming reduces cognitive load and makes codebase navigation predictable.

## Check
```bash
# Check TypeScript files for snake_case functions (should be camelCase)
grep -rn "function [a-z]*_[a-z]" src/ --include="*.ts" --include="*.tsx"

# Check Python files for camelCase functions (should be snake_case)
grep -rn "def [a-z]*[A-Z]" src/ --include="*.py"

# Check component files for non-PascalCase names
ls src/components/ 2>/dev/null | grep -v "^[A-Z]"
```

## Pass Criteria
- TypeScript: functions/variables use camelCase, classes use PascalCase
- Python: functions/variables use snake_case, classes use PascalCase
- React components: PascalCase filenames and export names
- Constants: SCREAMING_SNAKE_CASE in both languages
- API URLs: kebab-case paths
- Database: snake_case columns and tables
- No mixed conventions within the same language context

## Examples
```typescript
// BAD - snake_case in TypeScript
function get_user_data() {}
const user_name = "Alice";

// GOOD - camelCase in TypeScript
function getUserData() {}
const userName = "Alice";

// BAD - non-PascalCase component
// file: userCard.tsx
export default function userCard() {}

// GOOD - PascalCase component
// file: UserCard.tsx
export default function UserCard() {}
```

```python
# BAD - camelCase in Python
def getUserData():
    userName = "Alice"

# GOOD - snake_case in Python
def get_user_data():
    user_name = "Alice"
```
