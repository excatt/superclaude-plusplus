# KNOWLEDGE.md

**Accumulated insights, best practices, and troubleshooting guide**

---

## Core Insights

### PM Agent ROI: 25-250x Token Savings

Pre-implementation confidence checks deliver excellent ROI.

| Task Type | Normal Tokens | With PM Agent | Savings |
|-----------|--------------|---------------|---------|
| Typo fix | 200-500 | 200-300 | 40% |
| Bug fix | 2,000-5,000 | 1,000-2,000 | 50% |
| Feature addition | 10,000-50,000 | 5,000-15,000 | 60% |
| Wrong direction | 50,000+ | 100-200 (prevented) | 99%+ |

**Effective for**: Unclear requirements, new codebases, complex features, bug fixes
**Can skip**: Trivial changes, clear path, urgent hotfixes

---

### Parallel Execution: 3.5x Speedup

**Pattern**: Wave -> Checkpoint -> Wave

```python
# Wave 1: Independent reads (parallel)
files = [Read(f1), Read(f2), Read(f3)]
# Checkpoint: Analysis (sequential)
analysis = analyze_files(files)
# Wave 2: Independent edits (parallel)
edits = [Edit(f1), Edit(f2), Edit(f3)]
```

**When to use**: Multiple independent file reads/edits, multiple independent searches, parallel tests
**Do not use**: Dependent tasks, sequential analysis, shared state modifications

**Key insight**: Diminishing returns after ~10 operations per wave

---

## Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Implementing without duplicate check | Re-implementing existing functionality | `grep -r "function_name" src/` |
| Architecture assumptions | Ignoring the tech stack | Read CLAUDE.md, package.json first |
| Skipping test output | Claiming pass, actually failing | `npm test 2>&1 \| tail -20` |
| Unchecked dependencies | Importing non-existent libraries | `cat package.json \| jq '.dependencies'` |

---

## Lessons Learned

### Documentation Drift
README describing non-existent features -> Add documentation review checklist per release

### Tests Are Non-Negotiable
No tests of their own -> Specify test requirements in PR template

### No Completion Without Evidence
"Done" report but actually failing -> Mandate Self-Check Protocol, require evidence

**Note**: See RULES.md for Hallucination Detection details

---

## Advanced Techniques

### Progressive Context Loading

| Layer | Tokens | Triggers | Use Case |
|-------|--------|----------|----------|
| 0 | 150 | Always | Bootstrap |
| 1 | 500-800 | progress, status | Status check |
| 2 | 500-1K | typo, rename | Small changes |
| 3 | 3-4.5K | bug, fix | Related file analysis |
| 4 | 8-12K | feature | System understanding (confirm needed) |
| 5 | 20-50K | redesign | External references (WARNING) |

### Intent Classification
```python
ultra_light = ["progress", "status", "update"]
light = ["typo", "rename", "comment"]
medium = ["bug", "fix", "refactor"]
heavy = ["feature", "implement", "create"]
ultra_heavy = ["redesign", "migration", "rewrite"]
```

---

## Getting Help

**When stuck**:
1. Check this KNOWLEDGE.md for similar issues
2. Read PLANNING.md for architecture context
3. Search GitHub issues/discussions

**When sharing knowledge**: Document solutions in this file
