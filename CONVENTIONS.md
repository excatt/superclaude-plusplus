# Naming Conventions

프로젝트 전반의 네이밍 컨벤션 가이드.

## 공통

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| DB 컬럼/테이블 | snake_case | `created_at`, `user_id` |
| API 요청/응답 (JSON) | camelCase | `createdAt`, `userId` |
| URL 경로 | kebab-case | `/api/v1/voc-stats` |
| Query 파라미터 | camelCase | `?startDate=2025-01` |
| 환경 변수 | SCREAMING_SNAKE_CASE | `POSTGRES_HOST` |
| Git 브랜치 | kebab-case | `feature/add-login` |

## Python

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| 변수/함수 | snake_case | `get_user_data()` |
| 클래스 | PascalCase | `UserService` |
| 상수 | SCREAMING_SNAKE_CASE | `MAX_PAGE_SIZE = 100` |
| 파일명 | snake_case | `user_service.py` |
| Private | _prefix | `_internal_method()` |

### Python 패키지 관리

| 항목 | 규칙 |
|------|------|
| **패키지 매니저** | **uv** (필수) |
| 설정 파일 | `pyproject.toml` (PEP 621 표준) |
| Lock 파일 | `uv.lock` (커밋 필수) |
| 가상환경 | uv 자동 관리 |
| Docker | `uv sync --frozen --no-dev` |

**uv 기본 명령어**:
```bash
uv init              # 프로젝트 초기화
uv sync              # 의존성 설치
uv add <pkg>         # 패키지 추가
uv add --dev <pkg>   # 개발 의존성 추가
uv lock              # lock 파일 생성
uv run <cmd>         # 가상환경에서 실행
```

**pyproject.toml 필수 구조**:
```toml
[project]
name = "project-name"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[dependency-groups]
dev = [
    "pytest>=8.0",
    "mypy>=1.8",
    "ruff>=0.1",
]
```

**Dockerfile 패턴**:
```dockerfile
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
```

## TypeScript

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| 변수/함수 | camelCase | `getUserData()` |
| 클래스 | PascalCase | `UserService` |
| 인터페이스 | PascalCase | `UserResponse` |
| 타입 | PascalCase | `ApiResult<T>` |
| Enum | PascalCase + UPPER values | `enum Status { ACTIVE, INACTIVE }` |
| 상수 | SCREAMING_SNAKE_CASE | `const MAX_PAGE_SIZE = 100` |
| 파일명 (컴포넌트) | PascalCase | `UserCard.tsx` |
| 파일명 (utils/hooks) | camelCase | `useAuth.ts`, `formatDate.ts` |
| Private | #prefix 또는 _prefix | `#privateField` |
| 제네릭 | 단일 대문자 | `T`, `K`, `V` |

### Node.js/TypeScript 패키지 관리

| 항목 | 규칙 |
|------|------|
| **패키지 매니저** | **pnpm** (필수) |
| 설정 파일 | `package.json` |
| Lock 파일 | `pnpm-lock.yaml` (커밋 필수) |
| Workspace | `pnpm-workspace.yaml` (monorepo) |

**지원 프레임워크**: React, Next.js, NestJS, Vue, Angular, Node.js

**pnpm 기본 명령어**:
```bash
pnpm init              # 프로젝트 초기화
pnpm install           # 의존성 설치
pnpm add <pkg>         # 패키지 추가
pnpm add -D <pkg>      # 개발 의존성 추가
pnpm remove <pkg>      # 패키지 제거
pnpm run <script>      # 스크립트 실행
pnpm dlx <cmd>         # npx 대체
```

**Dockerfile 패턴**:
```dockerfile
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
```

**CI/CD 패턴** (GitHub Actions):
```yaml
- uses: pnpm/action-setup@v2
  with:
    version: 9
- run: pnpm install --frozen-lockfile
```

## React/Next.js

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| 컴포넌트 | PascalCase | `UserCard`, `LoginForm` |
| 컴포넌트 Props | PascalCase + Props 접미사 | `interface UserCardProps` |
| Hooks | use 접두사 + camelCase | `useAuth`, `useFetchData` |
| 커스텀 훅 파일 | use 접두사 | `useAuth.ts`, `useLocalStorage.ts` |
| 이벤트 핸들러 | handle 접두사 | `handleClick`, `handleSubmit` |
| 콜백 Props | on 접두사 | `onClick`, `onSubmit`, `onChange` |
| Boolean Props | is/has/can 접두사 | `isLoading`, `hasError`, `canEdit` |
| Context | PascalCase + Context 접미사 | `AuthContext`, `ThemeContext` |
| Provider | PascalCase + Provider 접미사 | `AuthProvider`, `ThemeProvider` |
| HOC | with 접두사 | `withAuth`, `withTheme` |
| Pages (Next.js) | kebab-case 디렉토리 | `app/user-profile/page.tsx` |
| Layout (Next.js) | layout.tsx | `app/dashboard/layout.tsx` |

## 테스트

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| Python 테스트 파일 | test_ 접두사 | `test_user_service.py` |
| Python 테스트 함수 | test_ 접두사 | `def test_create_user():` |
| Python 테스트 클래스 | Test 접두사 | `class TestUserService:` |
| TypeScript 테스트 파일 | .test.ts 또는 .spec.ts | `UserCard.test.tsx`, `api.spec.ts` |
| 테스트 설명 (describe) | 대상 컴포넌트/함수 | `describe('UserCard', ...)` |
| 테스트 케이스 (it/test) | should + 동작 | `it('should render user name', ...)` |
| 테스트 디렉토리 | __tests__ 또는 tests | `src/__tests__/`, `tests/` |
| Mock 파일 | __mocks__ | `__mocks__/api.ts` |
| Fixtures | fixtures | `tests/fixtures/user.json` |

## CSS/스타일링

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| CSS 클래스 | kebab-case | `user-card`, `btn-primary` |
| CSS 변수 | --kebab-case | `--color-primary`, `--font-size-lg` |
| CSS Module 클래스 | camelCase | `styles.userCard`, `styles.btnPrimary` |
| Tailwind 커스텀 | kebab-case | `text-brand-primary` |
| SCSS 변수 | $kebab-case | `$color-primary`, `$spacing-md` |
| SCSS mixin | kebab-case | `@mixin flex-center` |
| BEM (선택) | block__element--modifier | `card__title--highlighted` |
| Styled Components | PascalCase | `const StyledButton = styled.button` |
| CSS-in-JS 변수 | camelCase | `const primaryColor = '#007bff'` |
