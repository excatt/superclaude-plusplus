---
name: api-response-format
scope: "src/api/**"
severity: error
---

# API Response Format

## What
All API endpoints must return a consistent response envelope. Inconsistent response formats break client-side error handling and make API consumption unpredictable.

## Check
```bash
grep -rn "res\.json\|res\.send\|Response(" src/api/ --include="*.ts" --include="*.py"
```

## Pass Criteria
- All success responses use `{ data: T }` wrapper (TS) or standardized schema (Python)
- All error responses use `{ error: { code: string, message: string } }` format
- No raw object returns without envelope (e.g., `res.json(user)` should be `res.json({ data: user })`)
- HTTP status codes match response type (2xx for success, 4xx/5xx for errors)

## Examples
```typescript
// BAD - raw object without envelope
app.get("/users/:id", (req, res) => {
  const user = getUser(req.params.id);
  res.json(user);
});

// GOOD - consistent envelope
app.get("/users/:id", (req, res) => {
  const user = getUser(req.params.id);
  res.json({ data: user });
});

// GOOD - error envelope
app.get("/users/:id", (req, res) => {
  try {
    const user = getUser(req.params.id);
    res.json({ data: user });
  } catch (e) {
    res.status(404).json({ error: { code: "USER_NOT_FOUND", message: "User does not exist" } });
  }
});
```
