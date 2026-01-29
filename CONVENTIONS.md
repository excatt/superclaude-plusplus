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

## TypeScript

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| 변수/함수 | camelCase | `getUserData()` |
| 클래스 | PascalCase | `UserService` |
| 인터페이스 | PascalCase | `UserResponse` |
| 타입 | PascalCase | `ApiResult<T>` |
| Enum | PascalCase + UPPER 값 | `enum Status { ACTIVE, INACTIVE }` |
| 상수 | SCREAMING_SNAKE_CASE | `const MAX_PAGE_SIZE = 100` |
| 파일명 (컴포넌트) | PascalCase | `UserCard.tsx` |
| 파일명 (유틸/훅) | camelCase | `useAuth.ts`, `formatDate.ts` |
| Private | #prefix 또는 _prefix | `#privateField` |
| 제네릭 | 단일 대문자 | `T`, `K`, `V` |

## React/Next.js

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| 컴포넌트 | PascalCase | `UserCard`, `LoginForm` |
| 컴포넌트 Props | PascalCase + Props 접미사 | `interface UserCardProps` |
| 훅 | use prefix + camelCase | `useAuth`, `useFetchData` |
| 커스텀 훅 파일 | use prefix | `useAuth.ts`, `useLocalStorage.ts` |
| 이벤트 핸들러 | handle prefix | `handleClick`, `handleSubmit` |
| 콜백 Props | on prefix | `onClick`, `onSubmit`, `onChange` |
| Boolean Props | is/has/can prefix | `isLoading`, `hasError`, `canEdit` |
| 컨텍스트 | PascalCase + Context 접미사 | `AuthContext`, `ThemeContext` |
| Provider | PascalCase + Provider 접미사 | `AuthProvider`, `ThemeProvider` |
| HOC | with prefix | `withAuth`, `withTheme` |
| 페이지 (Next.js) | kebab-case 디렉토리 | `app/user-profile/page.tsx` |
| 레이아웃 (Next.js) | layout.tsx | `app/dashboard/layout.tsx` |

## 테스트

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| Python 테스트 파일 | test_ prefix | `test_user_service.py` |
| Python 테스트 함수 | test_ prefix | `def test_create_user():` |
| Python 테스트 클래스 | Test prefix | `class TestUserService:` |
| TypeScript 테스트 파일 | .test.ts 또는 .spec.ts | `UserCard.test.tsx`, `api.spec.ts` |
| 테스트 설명 (describe) | 대상 컴포넌트/함수명 | `describe('UserCard', ...)` |
| 테스트 케이스 (it/test) | should + 동작 | `it('should render user name', ...)` |
| 테스트 디렉토리 | __tests__ 또는 tests | `src/__tests__/`, `tests/` |
| 목 파일 | __mocks__ | `__mocks__/api.ts` |
| 픽스처 | fixtures | `tests/fixtures/user.json` |

## CSS/스타일

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| CSS 클래스 | kebab-case | `user-card`, `btn-primary` |
| CSS 변수 | --kebab-case | `--color-primary`, `--font-size-lg` |
| CSS 모듈 클래스 | camelCase | `styles.userCard`, `styles.btnPrimary` |
| Tailwind 커스텀 | kebab-case | `text-brand-primary` |
| SCSS 변수 | $kebab-case | `$color-primary`, `$spacing-md` |
| SCSS 믹스인 | kebab-case | `@mixin flex-center` |
| BEM (선택적) | block__element--modifier | `card__title--highlighted` |
| Styled Components | PascalCase | `const StyledButton = styled.button` |
| CSS-in-JS 변수 | camelCase | `const primaryColor = '#007bff'` |
