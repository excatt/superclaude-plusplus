# Audit Rule Format Guide

Each audit rule is a standalone markdown file stored in `.claude/audit-rules/`.

## File Structure

```markdown
---
name: rule-name-in-kebab-case
scope: "src/api/**"
severity: error | warning | info
---

# Rule Name

## What
What to verify and why this rule exists.

## Check
```bash
# Optional: automated check commands
grep -rn "pattern" src/
```

## Pass Criteria
- Condition 1 that must be true
- Condition 2 that must be true

## Examples
```typescript
// BAD
bad_pattern()

// GOOD
good_pattern()
```
```

## Frontmatter Fields

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `name` | Yes | kebab-case string | Unique rule identifier |
| `scope` | Yes | glob pattern | Files this rule applies to |
| `severity` | Yes | `error` / `warning` / `info` | How failures are classified |

### Scope Patterns

| Pattern | Matches |
|---------|---------|
| `"src/api/**"` | All files under src/api/ |
| `"**/*.ts"` | All TypeScript files |
| `"src/{api,services}/**"` | Multiple directories |
| `"*"` | All files (universal rule) |

### Severity Levels

| Level | Audit Status | Action |
|-------|-------------|--------|
| `error` | NEEDS FIX | Must fix before commit |
| `warning` | REVIEW | Should review, may proceed |
| `info` | CLEAR | Informational only |

## Body Sections

### What (Required)
Explain what the rule checks and why it matters. Keep it to 2-3 sentences.

### Check (Optional)
Bash commands that produce output for analysis. If omitted, Claude performs AI-only analysis by reading matching files directly.

### Pass Criteria (Required)
Bullet list of conditions. All must be satisfied to pass. Be specific and verifiable.

### Examples (Optional but Recommended)
Show BAD and GOOD patterns side by side. Helps Claude and humans understand intent.

## Tips

- One rule per concern (Single Responsibility)
- Scope should be as narrow as possible
- Check commands should be fast (< 5 seconds)
- Pass Criteria should be objectively verifiable
- Reference project CONVENTIONS.md for naming rules

## Example Rules

See `examples/` directory for ready-to-use rules:
- `api-response-format.md` — API response consistency
- `error-handling-pattern.md` — Error handling patterns
- `naming-convention.md` — Naming convention enforcement
