---
name: checkpoint
description: Git 기반 경량 체크포인트 시스템으로 작업 상태를 저장하고 복원합니다. 위험한 작업 전, 마일스톤 완료 시, 실험적 변경 전에 사용합니다. Keywords: checkpoint, save, restore, rollback, snapshot, backup, git, stash, 체크포인트, 저장, 복원, 롤백.
---

# Checkpoint Skill

## Purpose
Git stash/commit 기반의 경량 체크포인트 시스템으로 작업 상태를 저장하고, 비교하고, 필요시 복원합니다.

**핵심 원칙**: 위험한 작업 전 항상 체크포인트 → 안전한 실험 → 필요시 롤백

## Activation Triggers
- 위험한 리팩토링 전
- 실험적 변경 시작 전
- 주요 마일스톤 완료 시
- PR 제출 전 최종 상태 저장
- 사용자 명시적 요청: `/checkpoint`, `체크포인트`, `저장해줘`

---

## Commands

### Create Checkpoint
```
/checkpoint create <name>
```

**동작**:
1. 현재 상태가 clean인지 확인
2. 변경사항이 있으면 stash 또는 commit 생성
3. `.claude/checkpoints.log`에 기록
4. 타임스탬프와 Git SHA 저장

**예시**:
```
/checkpoint create before-auth-refactor

✅ Checkpoint Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:      before-auth-refactor
Time:      2025-01-26 14:30:22
SHA:       a1b2c3d
Files:     12 staged, 3 modified
Status:    Clean state saved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Verify Against Checkpoint
```
/checkpoint verify <name>
```

**동작**:
1. 저장된 체크포인트 찾기
2. 현재 상태와 비교
3. 변경 메트릭 보고

**예시**:
```
/checkpoint verify before-auth-refactor

📊 Checkpoint Comparison
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Checkpoint:    before-auth-refactor
Created:       2025-01-26 14:30:22
Current SHA:   d4e5f6g

📁 Files Changed: 8
   ├─ src/auth/login.ts      (+45, -12)
   ├─ src/auth/middleware.ts (+23, -5)
   ├─ src/api/user.ts        (+15, -8)
   └─ ... 5 more files

📈 Test Coverage:
   Before: 78%
   After:  85% (+7%)

🧪 Tests:
   Before: 42 passed
   After:  47 passed (+5 new)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### List Checkpoints
```
/checkpoint list
```

**예시**:
```
/checkpoint list

📋 Saved Checkpoints
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name                    Time                 SHA       Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
before-auth-refactor    2025-01-26 14:30    a1b2c3d   ← HEAD~3
feature-complete        2025-01-26 12:15    x7y8z9a   ← HEAD~8
initial-setup           2025-01-26 09:00    m4n5o6p   ← HEAD~15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 3 checkpoints
```

---

### Restore Checkpoint
```
/checkpoint restore <name>
```

**동작**:
1. 현재 변경사항 백업 (자동 stash)
2. 체크포인트로 복원
3. 복원 확인

**예시**:
```
/checkpoint restore before-auth-refactor

⚠️ Restore Confirmation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This will:
1. Stash current changes (auto-backup)
2. Reset to checkpoint: before-auth-refactor
3. You will lose: 8 file changes since checkpoint

Proceed? [y/N]
```

---

### Clear Old Checkpoints
```
/checkpoint clear
```

**동작**: 최근 5개만 유지, 나머지 삭제

---

## Implementation Details

### Checkpoint Log Format
`.claude/checkpoints.log`:
```
[2025-01-26T14:30:22] before-auth-refactor | SHA:a1b2c3d | stash@{0}
[2025-01-26T12:15:10] feature-complete | SHA:x7y8z9a | commit
[2025-01-26T09:00:05] initial-setup | SHA:m4n5o6p | commit
```

### Git Commands Used
```bash
# Create checkpoint (commit-based)
git add -A
git commit -m "checkpoint: <name>"

# Create checkpoint (stash-based for uncommitted work)
git stash push -m "checkpoint: <name>"

# Verify
git diff <checkpoint-sha>..HEAD --stat

# Restore
git stash  # backup current
git checkout <checkpoint-sha>

# List
git log --oneline --grep="checkpoint:"
```

---

## Workflow Integration

### Typical Development Flow
```
/checkpoint create "start-feature"
    │
    ├─→ 구현 작업
    │
    ├─→ /verify quick
    │
    ├─→ /checkpoint create "mid-feature"
    │
    ├─→ 위험한 리팩토링
    │       │
    │       ├─→ 성공 → 계속 진행
    │       │
    │       └─→ 실패 → /checkpoint restore "mid-feature"
    │
    ├─→ /verify full
    │
    └─→ /checkpoint create "feature-complete"
```

### With `/verify`
```
/checkpoint create "before-refactor"
... 리팩토링 ...
/verify full
    │
    ├─→ ✅ 통과 → 계속 진행
    │
    └─→ ❌ 실패 → /checkpoint restore "before-refactor"
```

### With `/feature-planner`
각 Phase 시작 전 자동 체크포인트:
```
Phase 1 시작 → /checkpoint create "phase-1-start"
Phase 1 완료 → /checkpoint create "phase-1-complete"
Phase 2 시작 → /checkpoint create "phase-2-start"
...
```

---

## Best Practices

### 체크포인트 네이밍 규칙
```
✅ Good:
- before-auth-refactor
- phase-2-complete
- pre-db-migration
- working-login-flow

❌ Bad:
- checkpoint1
- test
- temp
- asdf
```

### 권장 체크포인트 타이밍
| 상황 | 체크포인트 |
|------|-----------|
| 기능 시작 | `start-<feature>` |
| 작동하는 상태 도달 | `working-<feature>` |
| 위험한 변경 전 | `before-<change>` |
| Phase 완료 | `phase-N-complete` |
| PR 전 | `pre-pr-<feature>` |

### 체크포인트 관리
- 5개 이상 쌓이면 `/checkpoint clear`
- 의미 있는 이름 사용
- 작동하는 상태에서만 체크포인트 생성

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `/checkpoint create <name>` | 체크포인트 생성 |
| `/checkpoint verify <name>` | 체크포인트와 비교 |
| `/checkpoint list` | 모든 체크포인트 목록 |
| `/checkpoint restore <name>` | 체크포인트로 복원 |
| `/checkpoint clear` | 오래된 체크포인트 정리 |
