---
name: confidence-check
description: Pre-implementation confidence assessment (≥90% required). Verifies duplicate check, architecture compliance, official docs, OSS references, root cause understanding. Keywords: confidence, check, verify, before, implement.
---

# Confidence Check Skill

## Purpose

Assess confidence **before** implementation to prevent wrong-direction execution.

**Requirement**: ≥90% confidence needed to proceed with implementation

**ROI**: 100-200 token confidence check → prevents 5,000-50,000 token wrong-direction work

## When to Use

Use before starting implementation work to verify:
- No duplicate implementation exists
- Architecture compliance confirmed
- Official documentation reviewed
- Working OSS implementation found
- Root cause properly understood

## Confidence Assessment Criteria

Calculate confidence score (0.0 - 1.0) based on 5 checks:

### 1. No Duplicate Implementation? (25%)

**Check**: Search codebase for existing functionality

```bash
# Search for similar functions
grep -r "function featureName" src/
grep -r "def feature_name" src/

# Find related modules
find src/ -name "*feature*"
```

✅ Pass if no duplicate exists
❌ Fail if similar implementation found

### 2. Architecture Compliant? (25%)

**Check**: Verify tech stack alignment

- Read `CLAUDE.md`, `package.json`, `requirements.txt`
- Verify using existing patterns
- Avoid reinventing existing solutions

```bash
# Check tech stack
cat package.json | grep -E "(supabase|prisma|firebase|next)"
```

✅ Pass if using existing tech stack (e.g., Supabase, UV, pytest)
❌ Fail if introducing unnecessary new dependencies

### 3. Official Docs Checked? (20%)

**Check**: Review official documentation before implementation

- Query official docs with Context7 MCP
- Access documentation URLs with WebFetch
- Verify API compatibility

✅ Pass if official docs reviewed
❌ Fail if relying on assumptions

### 4. Working OSS Implementation Referenced? (15%)

**Check**: Find proven implementation

- Use Tavily MCP or WebSearch
- Search GitHub for examples
- Verify working code samples

✅ Pass if OSS reference found
❌ Fail if no working example exists

### 5. Root Cause Understood? (15%)

**Check**: Understand actual problem

- Analyze error messages
- Check logs and stack traces
- Identify root issue

✅ Pass if root cause clear
❌ Fail if symptoms unclear

---

## Confidence Score Calculation

```
Total = Check1 (25%) + Check2 (25%) + Check3 (20%) + Check4 (15%) + Check5 (15%)

If Total >= 0.90:  ✅ Proceed with implementation
If Total >= 0.70:  ⚠️  Suggest alternatives, ask questions
If Total < 0.70:   ❌ STOP - Request more context
```

---

## Output Format

### High Confidence (≥90%)
```
📋 Confidence Checks:
   ✅ No duplicate implementation
   ✅ Using existing tech stack
   ✅ Official docs verified
   ✅ Working OSS implementation found
   ✅ Root cause understood

📊 Confidence: 1.00 (100%)
✅ High confidence - proceed with implementation
```

### Medium Confidence (70-89%)
```
📋 Confidence Checks:
   ✅ No duplicate implementation
   ✅ Using existing tech stack
   ⚠️  Official docs partially verified
   ❌ OSS implementation not found
   ✅ Root cause understood

📊 Confidence: 0.75 (75%)
⚠️  Medium confidence - suggest alternatives

💡 Options:
1. JWT-based auth (recommended) - matches existing pattern
2. OAuth integration - requires additional setup
3. Session-based - legacy approach

Which direction should we proceed?
```

### Low Confidence (<70%)
```
📋 Confidence Checks:
   ❌ Duplicate check failed - search needed
   ⚠️  Architecture unclear
   ❌ Official docs not verified
   ❌ No OSS reference
   ❌ Root cause unclear

📊 Confidence: 0.45 (45%)
❌ Low confidence - STOP

❓ Need following information to proceed:
1. Should we use JWT or OAuth for authentication?
2. What's the expected session timeout?
3. Is 2FA support required?

Please guide so we can proceed with confidence.
```

---

## Workflow Integration

### Before Any Implementation
```
User request received
    │
    ▼
┌─────────────────────┐
│  /confidence-check  │
└─────────────────────┘
    │
    ├─→ ≥90%: Proceed with implementation
    │
    ├─→ 70-89%: Suggest alternatives → User choice → Proceed
    │
    └─→ <70%: STOP → Ask questions → Wait for answers → Reassess
```

### With /feature-planner
```
/confidence-check        # Check confidence first
    │
    └─→ ≥90%
          │
          ▼
/feature-planner        # Create plan
    │
    ▼
Proceed with implementation
```

### With /verify
```
/confidence-check       # Pre-implementation confidence
    │
    ▼
Implementation work
    │
    ▼
/verify                 # Post-implementation verification
```

---

## Check Implementation Details

### Check 1: Duplicate Search
```bash
# Search by function name
grep -rn "function ${feature_name}" src/
grep -rn "def ${feature_name}" src/
grep -rn "const ${feature_name}" src/

# Search by filename
find . -name "*${feature}*" -type f

# Search by class name
grep -rn "class ${FeatureName}" src/
```

### Check 2: Architecture Verification
```bash
# Check tech stack in package.json
cat package.json | jq '.dependencies'

# Check architecture guide in CLAUDE.md
cat CLAUDE.md | grep -A 10 "Architecture"

# Check existing patterns
ls -la src/
```

### Check 3: Documentation Review
```bash
# Query official docs with Context7 MCP
# Access documentation URLs with WebFetch
# Check README and internal docs
```

### Check 4: OSS Reference Search
```bash
# GitHub search
# Search implementation examples with Tavily/WebSearch
# Check npm/pip packages
```

### Check 5: Root Cause Analysis
```bash
# Analyze error logs
# Review stack traces
# Verify reproduction steps
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/confidence-check` | Full confidence assessment |
| `/confidence-check --quick` | Quick check (1, 2 only) |
| `/confidence-check --verbose` | Detailed output for each check |

---

## Best Practices

### Always Use When
- Before implementing new feature
- Before fixing bug (understand root cause)
- Before refactoring (verify architecture)
- Before external API integration

### Can Skip When
- Fixing typo
- Adding comment
- Formatting change
- Simple config change

### Red Flags
If tempted to proceed with low confidence:
- 🚩 "Probably fine" - need verification
- 🚩 "No time" - wrong direction wastes more time
- 🚩 "Fix it later" - accumulates tech debt
