# Testing Skill

테스트 전략 및 구현 가이드를 실행합니다.

## 테스트 피라미드 (2024)

```
        ┌───────────┐
        │   E2E     │  적게, 핵심 플로우만
        │ Playwright│
        ├───────────┤
        │Integration│  API, DB 연동
        │  Vitest   │
        ├───────────┤
        │   Unit    │  많이, 빠르게
        │  Vitest   │
        └───────────┘
```

## 2024 테스트 도구 권장

| 유형 | 권장 도구 | 대안 |
|-----|----------|------|
| Unit/Integration | **Vitest** | Jest |
| E2E | **Playwright** | Cypress |
| Component | Testing Library | Storybook |
| API | **Vitest** + supertest | - |
| Visual | Playwright | Chromatic |

## Vitest (Unit/Integration)

### 설정
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    include: ['**/*.{test,spec}.{js,ts,jsx,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['node_modules', 'tests'],
      thresholds: {
        lines: 80,
        branches: 80,
        functions: 80,
      },
    },
  },
});
```

### Setup 파일
```typescript
// tests/setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach, vi } from 'vitest';

afterEach(() => {
  cleanup();
});

// Mock global
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    back: vi.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => new URLSearchParams(),
}));
```

### 기본 테스트
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('Calculator', () => {
  it('adds two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });

  it('handles edge cases', () => {
    expect(add(0, 0)).toBe(0);
    expect(add(-1, 1)).toBe(0);
  });
});
```

### Mocking
```typescript
// 함수 모킹
const mockFn = vi.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue({ data: 'test' });

// 모듈 모킹
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'John' }),
}));

// 타이머 모킹
vi.useFakeTimers();
vi.advanceTimersByTime(1000);
vi.useRealTimers();
```

## React Testing Library

### 컴포넌트 테스트
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';

describe('LoginForm', () => {
  it('submits form with valid data', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

### 쿼리 우선순위
```typescript
// 1순위: 접근성 기반 (권장)
screen.getByRole('button', { name: /submit/i });
screen.getByLabelText(/email/i);

// 2순위: 시맨틱
screen.getByAltText(/profile/i);
screen.getByText(/welcome/i);

// 3순위: 테스트 ID (최후 수단)
screen.getByTestId('submit-button');
```

## MSW (API Mocking)

```typescript
// mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John' },
    ]);
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 3, ...body }, { status: 201 });
  }),
];

// tests/setup.ts
import { server } from '../mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Playwright (E2E)

### 설정
```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 14'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E 테스트
```typescript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Login' }).click();

  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByText('Welcome back')).toBeVisible();
});
```

### Page Object Model
```typescript
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Login' }).click();
  }
}

// 사용
test('login flow', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
});
```

## 명령어

```bash
# Vitest
npx vitest              # watch 모드
npx vitest run          # 단일 실행
npx vitest --coverage

# Playwright
npx playwright test
npx playwright test --ui
npx playwright codegen
```

## 체크리스트

- [ ] 테스트 피라미드 준수
- [ ] 커버리지 80%+
- [ ] CI 통합
- [ ] 접근성 기반 쿼리
- [ ] MSW로 API 모킹

## 출력 형식

```
## Test Strategy

### Test Types
| 유형 | 도구 | 커버리지 |
|------|------|---------|
| Unit | Vitest | 80% |
| E2E | Playwright | 핵심 플로우 |

### Example Tests
```typescript
// 테스트 코드
```
```

---

요청에 맞는 테스트 전략을 설계하세요.
