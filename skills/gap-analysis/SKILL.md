---
name: gap-analysis
description: Compare design documents against implementation and compute a Match Rate with a gap list (PDCA Check phase). Use after implementation or before PR to verify design conformance.
user-invocable: true
argument-hint: "[feature-name]"
---

# Gap Analysis Skill

> Analyze discrepancies between design documents and actual implementation code to calculate Match Rate.

## When to Use

Use proactively when:
- Post-implementation design comparison needed
- "Does it match design?", "Is it correct?", "Verify" requests
- Pre-PR/code review verification
- PDCA Check phase execution

Triggers: gap analysis, design-implementation comparison, verify, validate,
verify implementation, compare design, check implementation,
design vs code

Do NOT use for: Simple code review, design document creation, bug fixes

## Usage

```bash
/gap-analysis user-auth          # Analyze user-auth feature gaps
/gap-analysis                    # Analyze current PDCA state feature
```

## Analysis Workflow

### Step 1: Document & Code Discovery

```
1. Find design document
   - docs/02-design/features/{feature}.design.md
   - docs/02-design/{feature}.design.md
   - docs/design/{feature}.md

2. Find implementation code
   - src/features/{feature}/
   - src/{feature}/
   - app/{feature}/
   - lib/{feature}/
```

### Step 2: Comparison Items

#### 2.1 API Comparison
| Item | Design | Implementation | Status |
|------|--------|----------------|--------|
| Endpoint URL | Design spec | Actual route | ✅/❌ |
| HTTP Method | GET/POST/PUT/DELETE | Actual method | ✅/❌ |
| Request Params | Schema definition | Actual type | ✅/❌ |
| Response Format | Design schema | Actual response | ✅/❌ |
| Error Codes | Defined errors | Actual errors | ✅/❌ |

#### 2.2 Data Model Comparison
| Item | Design | Implementation | Status |
|------|--------|----------------|--------|
| Entity List | Design ERD | Actual models | ✅/❌ |
| Field Definitions | Schema | Type definitions | ✅/❌ |
| Relationships | Design relations | Actual relations | ✅/❌ |

#### 2.3 Feature Comparison
| Item | Design | Implementation | Status |
|------|--------|----------------|--------|
| Feature List | Requirements | Actual functions | ✅/❌ |
| Business Logic | Design flow | Actual logic | ✅/❌ |
| Error Handling | Design cases | Actual handling | ✅/❌ |

#### 2.4 Convention Compliance
| Item | Rule | Actual | Status |
|------|------|--------|--------|
| Naming | PascalCase/camelCase | Actual naming | ✅/❌ |
| Folder Structure | Design structure | Actual structure | ✅/❌ |
| Import Order | Rule | Actual order | ✅/❌ |

### Step 3: Match Rate Calculation

```
Match Rate = (Matched Items / Total Comparison Items) × 100

Status Determination:
├─ >= 90%  → ✅ PASS (Proceed to Report phase)
├─ 70-89%  → ⚠️ WARN (Act phase - auto fix)
└─ < 70%   → ❌ FAIL (Design review required)
```

### Step 4: Gap Classification

```markdown
## Gap Classification

### 🔴 Missing (Design O, Implementation X)
Items in design but not implemented
→ Implementation required

### 🟡 Added (Design X, Implementation O)
Items implemented but not in design
→ Update design document or remove code

### 🔵 Changed (Design ≠ Implementation)
Items where design differs from implementation
→ Synchronization needed (fix design or implementation)
```

## Output Format

```markdown
# Gap Analysis Report: {feature}

## Analysis Overview
- **Target**: {feature}
- **Design Doc**: docs/02-design/features/{feature}.design.md
- **Implementation Path**: src/features/{feature}/
- **Analysis Time**: YYYY-MM-DD HH:mm

## Match Rate

| Category | Score | Status |
|----------|:-----:|:------:|
| API Match | 85% | ⚠️ |
| Data Model | 100% | ✅ |
| Feature Implementation | 80% | ⚠️ |
| Convention | 90% | ✅ |
| **Total** | **88%** | ⚠️ |

## Gap List

### 🔴 Missing (Implementation Required)
| Item | Design Location | Description |
|------|----------------|-------------|
| Password Reset | design.md:45 | POST /auth/forgot-password not implemented |

### 🟡 Added (Documentation Required)
| Item | Implementation Location | Description |
|------|------------------------|-------------|
| Social Login | src/auth/social.ts | Feature added not in design |

### 🔵 Changed (Synchronization Required)
| Item | Design | Implementation | Impact |
|------|--------|----------------|--------|
| Response Format | { data: [] } | { items: [] } | High |

## Recommended Actions

### Immediate Actions (matchRate < 90%)
1. Implement or remove Missing items from design
2. Synchronize Changed items

### Documentation Updates
1. Reflect Added items in design document
```

## PDCA Status Update

Update `.pdca-status.json` on analysis completion:

```json
{
  "feature": "{feature}",
  "phase": "check",
  "matchRate": 88,
  "gaps": {
    "missing": 1,
    "added": 1,
    "changed": 1
  },
  "lastAnalysis": "2025-01-31T10:00:00Z",
  "iteration": 0
}
```

## Next Steps Guidance

```
matchRate >= 90%:
  → "Gap analysis passed! Generate completion report with /pdca report {feature}."

matchRate < 90%:
  → "Gaps detected. Start auto-correction? (Act phase)"
  → On user approval, proceed with gap-based fixes
  → Auto re-analysis after fixes
```

## Related Skills

- `/feature-planner` - Plan phase
- `/verify` - General verification (Gap Analysis specializes in design-implementation comparison)
- `/code-review` - Code quality review
