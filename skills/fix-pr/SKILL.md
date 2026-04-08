---
name: fix-pr
description: PR 리뷰 코멘트를 자동 수집하고, 해당 코드를 수정하여 재커밋합니다. GitHub PR 피드백 루프를 자동화합니다.
user-invocable: true
argument-hint: [pr-number]
---

# Fix PR

## Purpose
GitHub PR의 리뷰 코멘트를 수집하고, 코멘트에 따라 코드를 자동 수정하여 재커밋합니다.

## Dynamic Context

Current branch:
!`git branch --show-current 2>/dev/null`

Open PR comments:
!`gh pr view --json number,title,reviewDecision 2>/dev/null || echo "No PR found for current branch"`

## Usage

```bash
/fix-pr           # 현재 브랜치의 PR 코멘트 수정
/fix-pr 123       # PR #123의 코멘트 수정
```

## Workflow

### Step 1: Collect Comments
```bash
# PR의 모든 미해결 리뷰 코멘트 수집
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  --jq '.[] | select(.position != null) | {path: .path, line: .line, body: .body}'

# 리뷰 쓰레드의 미해결 항목
gh api repos/{owner}/{repo}/pulls/{pr}/reviews \
  --jq '.[] | select(.state == "CHANGES_REQUESTED") | {body: .body}'
```

### Step 2: Categorize
각 코멘트를 분류:
- **Must Fix**: 변경 요청 (CHANGES_REQUESTED)
- **Should Fix**: 제안 (suggestion, consider)
- **Optional**: 질문, 의견

### Step 3: Apply Fixes
각 Must Fix / Should Fix 코멘트에 대해:
1. 해당 파일과 라인 위치 파악
2. 코멘트 의도에 맞게 코드 수정
3. 수정 내용 요약

### Step 4: Verify & Commit
```bash
# 빌드/테스트 확인
/verify quick

# 수정 커밋
git add -A
git commit -m "fix: address PR review comments

- [comment 1 summary]
- [comment 2 summary]
..."

# 푸시
git push
```

### Step 5: Report
```
## PR Fix Report

### Fixed (N items)
| # | File | Line | Comment | Fix |
|---|------|------|---------|-----|
| 1 | src/api.ts | 45 | Missing error handling | Added try-catch |

### Skipped (N items)
| # | Reason | Comment |
|---|--------|---------|
| 1 | Optional/Opinion | "Consider using X" |

### Action Required
- [ ] Re-request review
- [ ] Resolve conversations on GitHub
```

## Constraints
- 코드 수정만 -- PR 설정, 라벨, 할당 등은 변경하지 않음
- Must Fix 항목은 모두 처리
- 불확실한 코멘트는 스킵하고 보고
- 푸시 전 반드시 /verify 실행
