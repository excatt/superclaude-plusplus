# Common Code Patterns

재사용 가능한 코드 패턴과 아키텍처 접근법 모음.

## API Response Format

표준화된 API 응답 구조:

```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  pagination?: {
    total: number;
    page: number;
    limit: number;
    hasMore: boolean;
  };
}

// Usage
function createSuccessResponse<T>(data: T, pagination?: Pagination): ApiResponse<T> {
  return {
    success: true,
    data,
    ...(pagination && { pagination }),
  };
}

function createErrorResponse(code: string, message: string): ApiResponse<never> {
  return {
    success: false,
    error: { code, message },
  };
}
```

---

## Repository Pattern

데이터 액세스 추상화:

```typescript
interface Repository<T, ID = string> {
  findAll(options?: QueryOptions): Promise<T[]>;
  findById(id: ID): Promise<T | null>;
  create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T>;
  update(id: ID, data: Partial<T>): Promise<T>;
  delete(id: ID): Promise<void>;
}

interface QueryOptions {
  where?: Record<string, unknown>;
  orderBy?: { field: string; direction: 'asc' | 'desc' };
  limit?: number;
  offset?: number;
}

// Implementation example
class UserRepository implements Repository<User> {
  constructor(private db: Database) {}

  async findAll(options?: QueryOptions): Promise<User[]> {
    return this.db.users.findMany(options);
  }

  async findById(id: string): Promise<User | null> {
    return this.db.users.findUnique({ where: { id } });
  }

  async create(data: CreateUserInput): Promise<User> {
    return this.db.users.create({ data });
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    return this.db.users.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await this.db.users.delete({ where: { id } });
  }
}
```

---

## Custom Hooks Pattern (React)

재사용 가능한 React 훅:

### useDebounce
```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

// Usage
const [search, setSearch] = useState('');
const debouncedSearch = useDebounce(search, 300);

useEffect(() => {
  fetchResults(debouncedSearch);
}, [debouncedSearch]);
```

### useLocalStorage
```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue;
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    const valueToStore = value instanceof Function ? value(storedValue) : value;
    setStoredValue(valueToStore);
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    }
  };

  return [storedValue, setValue] as const;
}
```

### useAsync
```typescript
interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

function useAsync<T>(asyncFn: () => Promise<T>, deps: unknown[] = []) {
  const [state, setState] = useState<AsyncState<T>>({
    data: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let mounted = true;
    setState(prev => ({ ...prev, loading: true }));

    asyncFn()
      .then(data => {
        if (mounted) setState({ data, loading: false, error: null });
      })
      .catch(error => {
        if (mounted) setState({ data: null, loading: false, error });
      });

    return () => { mounted = false; };
  }, deps);

  return state;
}
```

---

## Error Boundary Pattern

React 에러 경계:

```typescript
interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<
  { children: ReactNode; fallback?: ReactNode },
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send to error tracking service
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <DefaultErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}

// Usage
<ErrorBoundary fallback={<ErrorPage />}>
  <App />
</ErrorBoundary>
```

---

## Service Layer Pattern

비즈니스 로직 분리:

```typescript
// Service interface
interface UserService {
  register(input: RegisterInput): Promise<User>;
  login(email: string, password: string): Promise<AuthResult>;
  getProfile(userId: string): Promise<UserProfile>;
  updateProfile(userId: string, data: UpdateProfileInput): Promise<User>;
}

// Implementation
class UserServiceImpl implements UserService {
  constructor(
    private userRepo: UserRepository,
    private authProvider: AuthProvider,
    private emailService: EmailService
  ) {}

  async register(input: RegisterInput): Promise<User> {
    // Validate
    await this.validateRegistration(input);

    // Create user
    const user = await this.userRepo.create({
      email: input.email,
      passwordHash: await this.authProvider.hashPassword(input.password),
    });

    // Send welcome email
    await this.emailService.sendWelcome(user.email);

    return user;
  }

  // ... other methods
}
```

---

## Factory Pattern

객체 생성 추상화:

```typescript
interface NotificationFactory {
  create(type: NotificationType, data: NotificationData): Notification;
}

class NotificationFactoryImpl implements NotificationFactory {
  create(type: NotificationType, data: NotificationData): Notification {
    switch (type) {
      case 'email':
        return new EmailNotification(data);
      case 'sms':
        return new SmsNotification(data);
      case 'push':
        return new PushNotification(data);
      default:
        throw new Error(`Unknown notification type: ${type}`);
    }
  }
}
```

---

## Skeleton Project Approach

새 프로젝트 시작 시 권장 접근법:

### 1. 검색 (Search)
```bash
# GitHub에서 검증된 스타터 프로젝트 검색
- "next.js starter typescript"
- "express api boilerplate"
- "react vite template"
```

### 2. 평가 (Evaluate)
병렬 에이전트로 평가:
- **보안**: 의존성 취약점, 인증 패턴
- **확장성**: 아키텍처 유연성, 모듈화
- **유지보수성**: 코드 품질, 테스트 커버리지
- **커뮤니티**: 활성도, 문서화 수준

### 3. 채택 (Adopt)
가장 적합한 스타터 선택

### 4. 커스터마이징 (Customize)
검증된 기반 위에서 프로젝트 요구사항에 맞게 수정

---

## Result Pattern (Error Handling)

예외 대신 Result 타입 사용:

```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function divide(a: number, b: number): Result<number, string> {
  if (b === 0) {
    return { success: false, error: 'Division by zero' };
  }
  return { success: true, data: a / b };
}

// Usage
const result = divide(10, 2);
if (result.success) {
  console.log(result.data); // 5
} else {
  console.error(result.error);
}
```

---

## Singleton Pattern (with TypeScript)

```typescript
class DatabaseConnection {
  private static instance: DatabaseConnection;
  private connection: Connection;

  private constructor() {
    this.connection = this.createConnection();
  }

  static getInstance(): DatabaseConnection {
    if (!DatabaseConnection.instance) {
      DatabaseConnection.instance = new DatabaseConnection();
    }
    return DatabaseConnection.instance;
  }

  private createConnection(): Connection {
    // Connection logic
  }

  query<T>(sql: string, params?: unknown[]): Promise<T> {
    return this.connection.query(sql, params);
  }
}

// Usage
const db = DatabaseConnection.getInstance();
```

---

## Pattern Selection Guide

| 상황 | 권장 패턴 |
|------|----------|
| API 응답 표준화 | API Response Format |
| 데이터 액세스 분리 | Repository Pattern |
| React 상태 로직 재사용 | Custom Hooks |
| 에러 복구 UI | Error Boundary |
| 비즈니스 로직 분리 | Service Layer |
| 객체 생성 다양화 | Factory Pattern |
| 안전한 에러 처리 | Result Pattern |
| 전역 리소스 관리 | Singleton Pattern |
