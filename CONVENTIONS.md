# Naming Conventions

Project-wide naming convention guide.

## Common

| Area | Convention | Example |
|------|------------|---------|
| DB columns/tables | snake_case | `created_at`, `user_id` |
| API request/response (JSON) | camelCase | `createdAt`, `userId` |
| URL paths | kebab-case | `/api/v1/voc-stats` |
| Query params | camelCase | `?startDate=2025-01` |
| Environment variables | SCREAMING_SNAKE_CASE | `POSTGRES_HOST` |
| Git branches | kebab-case | `feature/add-login` |

## Python

| Area | Convention | Example |
|------|------------|---------|
| Variables/functions | snake_case | `get_user_data()` |
| Classes | PascalCase | `UserService` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_PAGE_SIZE = 100` |
| Filenames | snake_case | `user_service.py` |
| Private | _prefix | `_internal_method()` |

### Python Package Management

| Item | Rule |
|------|------|
| **Package manager** | **uv** (required) |
| Config file | `pyproject.toml` (PEP 621 standard) |
| Lock file | `uv.lock` (must commit) |
| Virtual env | uv auto-managed |
| Docker | `uv sync --frozen --no-dev` |

**uv basic commands**:
```bash
uv init              # Initialize project
uv sync              # Install dependencies
uv add <pkg>         # Add package
uv add --dev <pkg>   # Add dev dependency
uv lock              # Generate lock file
uv run <cmd>         # Run in virtual env
```

**pyproject.toml required structure**:
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

**Dockerfile pattern**:
```dockerfile
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
```

## TypeScript

| Area | Convention | Example |
|------|------------|---------|
| Variables/functions | camelCase | `getUserData()` |
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase | `UserResponse` |
| Types | PascalCase | `ApiResult<T>` |
| Enum | PascalCase + UPPER values | `enum Status { ACTIVE, INACTIVE }` |
| Constants | SCREAMING_SNAKE_CASE | `const MAX_PAGE_SIZE = 100` |
| Filenames (components) | PascalCase | `UserCard.tsx` |
| Filenames (utils/hooks) | camelCase | `useAuth.ts`, `formatDate.ts` |
| Private | #prefix or _prefix | `#privateField` |
| Generics | Single uppercase | `T`, `K`, `V` |

### Node.js/TypeScript Package Management

| Item | Rule |
|------|------|
| **Package manager** | **pnpm** (required) |
| Config file | `package.json` |
| Lock file | `pnpm-lock.yaml` (must commit) |
| Workspace | `pnpm-workspace.yaml` (monorepo) |

**Supported frameworks**: React, Next.js, NestJS, Vue, Angular, Node.js

**pnpm basic commands**:
```bash
pnpm init              # Initialize project
pnpm install           # Install dependencies
pnpm add <pkg>         # Add package
pnpm add -D <pkg>      # Add dev dependency
pnpm remove <pkg>      # Remove package
pnpm run <script>      # Run script
pnpm dlx <cmd>         # Replace npx
```

**Dockerfile pattern**:
```dockerfile
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
```

**CI/CD pattern** (GitHub Actions):
```yaml
- uses: pnpm/action-setup@v2
  with:
    version: 9
- run: pnpm install --frozen-lockfile
```

## React/Next.js

| Area | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserCard`, `LoginForm` |
| Component Props | PascalCase + Props suffix | `interface UserCardProps` |
| Hooks | use prefix + camelCase | `useAuth`, `useFetchData` |
| Custom hook files | use prefix | `useAuth.ts`, `useLocalStorage.ts` |
| Event handlers | handle prefix | `handleClick`, `handleSubmit` |
| Callback Props | on prefix | `onClick`, `onSubmit`, `onChange` |
| Boolean Props | is/has/can prefix | `isLoading`, `hasError`, `canEdit` |
| Context | PascalCase + Context suffix | `AuthContext`, `ThemeContext` |
| Provider | PascalCase + Provider suffix | `AuthProvider`, `ThemeProvider` |
| HOC | with prefix | `withAuth`, `withTheme` |
| Pages (Next.js) | kebab-case directory | `app/user-profile/page.tsx` |
| Layout (Next.js) | layout.tsx | `app/dashboard/layout.tsx` |

## Testing

| Area | Convention | Example |
|------|------------|---------|
| Python test files | test_ prefix | `test_user_service.py` |
| Python test functions | test_ prefix | `def test_create_user():` |
| Python test classes | Test prefix | `class TestUserService:` |
| TypeScript test files | .test.ts or .spec.ts | `UserCard.test.tsx`, `api.spec.ts` |
| Test description (describe) | Target component/function | `describe('UserCard', ...)` |
| Test case (it/test) | should + action | `it('should render user name', ...)` |
| Test directory | __tests__ or tests | `src/__tests__/`, `tests/` |
| Mock files | __mocks__ | `__mocks__/api.ts` |
| Fixtures | fixtures | `tests/fixtures/user.json` |

## CSS/Styling

| Area | Convention | Example |
|------|------------|---------|
| CSS classes | kebab-case | `user-card`, `btn-primary` |
| CSS variables | --kebab-case | `--color-primary`, `--font-size-lg` |
| CSS Module classes | camelCase | `styles.userCard`, `styles.btnPrimary` |
| Tailwind custom | kebab-case | `text-brand-primary` |
| SCSS variables | $kebab-case | `$color-primary`, `$spacing-md` |
| SCSS mixins | kebab-case | `@mixin flex-center` |
| BEM (optional) | block__element--modifier | `card__title--highlighted` |
| Styled Components | PascalCase | `const StyledButton = styled.button` |
| CSS-in-JS variables | camelCase | `const primaryColor = '#007bff'` |
