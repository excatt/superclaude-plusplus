# Common Code Patterns

Collection of reusable code patterns and architectural approaches.

## API Response Format

Standardized API response structure:

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

Data access abstraction:

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

Reusable React hooks:

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

React error boundary:

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

Business logic separation:

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

Object creation abstraction:

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

Recommended approach when starting a new project:

### 1. Search
```bash
# Search for validated starter projects on GitHub
- "next.js starter typescript"
- "express api boilerplate"
- "react vite template"
```

### 2. Evaluate
Evaluate with parallel agents:
- **Security**: Dependency vulnerabilities, authentication patterns
- **Scalability**: Architecture flexibility, modularity
- **Maintainability**: Code quality, test coverage
- **Community**: Activity level, documentation quality

### 3. Adopt
Select the most suitable starter

### 4. Customize
Modify to fit project requirements on top of the validated foundation

---

## Result Pattern (Error Handling)

Use Result type instead of exceptions:

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

| Scenario | Recommended Pattern |
|----------|-------------------|
| API response standardization | API Response Format |
| Data access separation | Repository Pattern |
| React state logic reuse | Custom Hooks |
| Error recovery UI | Error Boundary |
| Business logic separation | Service Layer |
| Diverse object creation | Factory Pattern |
| Safe error handling | Result Pattern |
| Global resource management | Singleton Pattern |
