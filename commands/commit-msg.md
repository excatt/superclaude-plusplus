# Commit Message Skill

일관된 커밋 메시지 작성을 위한 컨벤션 가이드를 실행합니다.

## Conventional Commits 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

## 커밋 타입

| Type | 설명 | 예시 |
|------|------|------|
| `feat` | 새로운 기능 | 로그인 기능 추가 |
| `fix` | 버그 수정 | 로그인 오류 수정 |
| `docs` | 문서 변경 | README 업데이트 |
| `style` | 코드 스타일 (포맷팅) | 들여쓰기 수정 |
| `refactor` | 리팩토링 | 함수 분리 |
| `perf` | 성능 개선 | 쿼리 최적화 |
| `test` | 테스트 추가/수정 | 단위 테스트 추가 |
| `build` | 빌드 시스템 | webpack 설정 |
| `ci` | CI 설정 | GitHub Actions |
| `chore` | 기타 작업 | 의존성 업데이트 |
| `revert` | 커밋 되돌리기 | feat 커밋 롤백 |

## 작성 규칙

### Subject (제목)
- 50자 이내
- 명령형 현재 시제 ("Add" not "Added")
- 첫 글자 대문자
- 마침표 없음

### Body (본문)
- 72자마다 줄바꿈
- "무엇을" "왜" 설명
- "어떻게"는 코드로

### Footer (꼬리말)
```
# 이슈 참조
Refs: #123
Closes: #456

# Breaking Change
BREAKING CHANGE: 설명
```

## 예시

### 기능 추가
```
feat(auth): add OAuth2 login with Google

- Implement Google OAuth2 authentication flow
- Add callback handling for token exchange
- Store refresh tokens securely

Refs: #123
```

### 버그 수정
```
fix(cart): resolve race condition in quantity update

When rapidly clicking +/- buttons, the cart quantity
would sometimes show incorrect values due to stale state.

Fixed by implementing optimistic locking.

Closes: #456
```

### 리팩토링
```
refactor(user): extract validation logic to separate module

Move user validation functions from UserService to
dedicated UserValidator class for better testability.

No functional changes.
```

### Breaking Change
```
feat(api)!: change response format to JSON:API spec

BREAKING CHANGE: API responses now follow JSON:API
specification. Clients need to update response parsing.

Migration guide: docs/migration-v2.md
```

## 커밋 체크리스트

- [ ] 하나의 논리적 변경만 포함
- [ ] 테스트 통과 확인
- [ ] 타입이 변경 내용과 일치
- [ ] scope가 명확 (선택사항)
- [ ] subject가 명확하고 간결
- [ ] body에 "왜" 설명 (필요시)
- [ ] 관련 이슈 참조

## 출력 형식

변경사항 분석 후 커밋 메시지 제안:

```
## Suggested Commit Message

```
feat(module): brief description

- Change 1
- Change 2

Refs: #issue
```

### Alternative Options
1. `fix(module): ...` - if this is a bug fix
2. `refactor(module): ...` - if no functional change
```

---

변경된 파일들을 분석하여 적절한 커밋 메시지를 제안하세요.
