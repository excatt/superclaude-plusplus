# Git Workflow Skill

Git 브랜치 전략 및 워크플로우 가이드를 실행합니다.

## 브랜치 전략

### Git Flow
```
main (production)
  │
  └─ develop
       │
       ├─ feature/xxx
       ├─ release/x.x
       └─ hotfix/xxx

복잡하지만 정교한 릴리스 관리
대규모 팀, 정기 릴리스에 적합
```

### GitHub Flow
```
main
  │
  └─ feature/xxx → PR → main

단순함, 지속적 배포에 적합
소규모 팀, 빠른 릴리스
```

### Trunk Based Development
```
main
  │
  └─ short-lived branches (< 1일)

CI/CD에 최적화
Feature Flags와 함께 사용
```

## 브랜치 네이밍

### 컨벤션
```
feature/  새 기능
bugfix/   버그 수정
hotfix/   긴급 수정
release/  릴리스 준비
docs/     문서
refactor/ 리팩토링
test/     테스트

예시:
feature/user-authentication
bugfix/login-error
hotfix/security-patch
release/v1.2.0
```

### 이슈 연결
```
feature/123-user-auth
bugfix/456-fix-login
```

## 커밋 컨벤션

### Conventional Commits
```
<type>(<scope>): <subject>

<body>

<footer>

타입: feat, fix, docs, style, refactor, test, chore
```

### 예시
```bash
git commit -m "feat(auth): add OAuth2 login

- Implement Google OAuth2
- Add token refresh logic

Closes #123"
```

## Git Flow 워크플로우

### 기능 개발
```bash
# 1. develop에서 feature 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b feature/user-auth

# 2. 개발 & 커밋
git add .
git commit -m "feat(auth): implement login"

# 3. develop에 머지
git checkout develop
git pull origin develop
git merge --no-ff feature/user-auth
git push origin develop

# 4. feature 브랜치 삭제
git branch -d feature/user-auth
```

### 릴리스
```bash
# 1. release 브랜치 생성
git checkout develop
git checkout -b release/v1.2.0

# 2. 버전 업데이트, 버그 수정
npm version 1.2.0

# 3. main에 머지
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin main --tags

# 4. develop에도 머지
git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop
```

### 핫픽스
```bash
# 1. main에서 hotfix 브랜치
git checkout main
git checkout -b hotfix/security-fix

# 2. 수정 & 커밋
git commit -m "fix(security): patch XSS vulnerability"

# 3. main에 머지
git checkout main
git merge --no-ff hotfix/security-fix
git tag -a v1.2.1 -m "Hotfix v1.2.1"

# 4. develop에도 머지
git checkout develop
git merge --no-ff hotfix/security-fix
```

## GitHub Flow 워크플로우

```bash
# 1. main에서 브랜치 생성
git checkout main
git pull origin main
git checkout -b feature/new-feature

# 2. 개발 & 푸시
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# 3. PR 생성 (GitHub에서)
# - 리뷰 요청
# - CI 통과 확인
# - Squash and merge

# 4. 로컬 정리
git checkout main
git pull origin main
git branch -d feature/new-feature
```

## 유용한 명령어

### 되돌리기
```bash
# 마지막 커밋 수정
git commit --amend

# 스테이징 취소
git reset HEAD file.txt

# 커밋 되돌리기 (기록 유지)
git revert <commit>

# 커밋 되돌리기 (기록 삭제) - 주의!
git reset --hard <commit>
```

### 브랜치 관리
```bash
# 머지된 브랜치 삭제
git branch --merged | grep -v main | xargs git branch -d

# 원격 브랜치 정리
git remote prune origin

# 브랜치 비교
git log main..feature/xxx
```

### Rebase vs Merge
```bash
# Merge: 히스토리 보존
git merge feature/xxx

# Rebase: 깔끔한 히스토리
git rebase main
# 충돌 해결 후
git rebase --continue

# Interactive Rebase (커밋 정리)
git rebase -i HEAD~3
```

### Stash
```bash
# 임시 저장
git stash

# 목록 확인
git stash list

# 복원
git stash pop

# 특정 stash 복원
git stash apply stash@{1}
```

## PR 체크리스트

```markdown
## PR Checklist
- [ ] 테스트 통과
- [ ] 린트 통과
- [ ] 문서 업데이트
- [ ] 스크린샷 (UI 변경 시)
- [ ] Breaking change 확인
- [ ] 리뷰어 지정
```

## 보호 규칙

### GitHub Branch Protection
```yaml
main:
  - Require pull request reviews
  - Require status checks (CI)
  - Require linear history
  - Include administrators
  - Restrict force pushes
```

## 출력 형식

```
## Git Workflow Design

### Strategy
- 방식: [Git Flow/GitHub Flow/etc]
- 이유: [선택 이유]

### Branch Structure
```
main
├── develop (Git Flow)
├── feature/*
├── release/*
└── hotfix/*
```

### Naming Convention
- feature/[issue-number]-[description]
- bugfix/[issue-number]-[description]

### Commit Convention
- Conventional Commits
- 예: feat(scope): subject

### CI/CD Integration
- PR 생성 → CI 실행
- main 머지 → 자동 배포
```

---

요청에 맞는 Git 워크플로우를 설계하세요.
