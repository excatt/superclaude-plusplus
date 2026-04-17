---
name: error-handling-pattern
scope: "src/**"
severity: error
---

# Error Handling Pattern

## What
Catch blocks must handle errors explicitly. Empty catch blocks silently swallow failures, making debugging impossible. Bare catches without error typing lose type information.

## Check
```bash
grep -rn "catch\s*(" src/ --include="*.ts" --include="*.tsx" -A 2
```

## Pass Criteria
- No empty catch blocks (`catch (e) {}`)
- All catch blocks log or rethrow the error
- Catch blocks specify error type when possible (`catch (e: AxiosError)`)
- Async functions have try-catch or .catch() error boundaries
- No `catch (e) { /* ignore */ }` patterns without explicit justification comment

## Examples
```typescript
// BAD - empty catch
try {
  await fetchData();
} catch (e) {}

// BAD - bare catch without handling
try {
  await fetchData();
} catch (e) {
  console.log(e);
}

// GOOD - typed error with proper handling
try {
  await fetchData();
} catch (e) {
  if (e instanceof AxiosError) {
    logger.error("API call failed", { status: e.response?.status, url: e.config?.url });
    throw new AppError("DATA_FETCH_FAILED", e.message);
  }
  throw e;
}

// GOOD - intentional ignore with justification
try {
  await cache.invalidate(key);
} catch {
  // Cache invalidation failure is non-critical; stale cache will expire via TTL
}
```
