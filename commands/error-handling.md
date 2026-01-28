# Error Handling Skill

에러 핸들링 패턴 및 전략을 위한 가이드를 실행합니다.

## 에러 분류

### 운영 에러 (Operational)
```
- 예상 가능, 복구 가능
- 네트워크 타임아웃
- 잘못된 사용자 입력
- 외부 서비스 장애
→ 처리: 적절한 응답, 재시도, 폴백
```

### 프로그래머 에러 (Programmer)
```
- 버그, 복구 불가
- null 참조
- 잘못된 타입
- 로직 오류
→ 처리: 수정 필요, 프로세스 재시작
```

## 에러 클래스 설계

### 커스텀 에러 (JavaScript/TypeScript)
```typescript
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message: string, public fields: Record<string, string>) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401);
  }
}
```

### Python
```python
class AppError(Exception):
    def __init__(self, message, code, status_code=500, is_operational=True):
        super().__init__(message)
        self.code = code
        self.status_code = status_code
        self.is_operational = is_operational

class ValidationError(AppError):
    def __init__(self, message, fields):
        super().__init__(message, 'VALIDATION_ERROR', 400)
        self.fields = fields

class NotFoundError(AppError):
    def __init__(self, resource):
        super().__init__(f'{resource} not found', 'NOT_FOUND', 404)
```

## 에러 처리 패턴

### 전역 에러 핸들러 (Express)
```typescript
// 에러 핸들링 미들웨어
const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // 로깅
  logger.error({
    err,
    path: req.path,
    method: req.method,
    traceId: req.traceId,
  });

  // 응답
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        ...(err instanceof ValidationError && { fields: err.fields }),
      },
    });
  }

  // 알 수 없는 에러
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'Something went wrong',
    },
  });
};
```

### Result 패턴 (함수형)
```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function parseJSON<T>(json: string): Result<T> {
  try {
    return { success: true, data: JSON.parse(json) };
  } catch (e) {
    return { success: false, error: e as Error };
  }
}

// 사용
const result = parseJSON<User>(data);
if (result.success) {
  console.log(result.data);
} else {
  console.error(result.error);
}
```

### Either 모나드
```typescript
class Either<L, R> {
  private constructor(
    private left: L | null,
    private right: R | null
  ) {}

  static left<L, R>(value: L): Either<L, R> {
    return new Either(value, null);
  }

  static right<L, R>(value: R): Either<L, R> {
    return new Either(null, value);
  }

  map<T>(fn: (r: R) => T): Either<L, T> {
    return this.right !== null
      ? Either.right(fn(this.right))
      : Either.left(this.left!);
  }
}
```

## 재시도 전략

### Exponential Backoff
```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  options: {
    maxRetries: number;
    baseDelay: number;
    maxDelay: number;
  }
): Promise<T> {
  let lastError: Error;

  for (let i = 0; i <= options.maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;

      if (i === options.maxRetries) break;

      const delay = Math.min(
        options.baseDelay * Math.pow(2, i),
        options.maxDelay
      );
      await sleep(delay + Math.random() * 1000); // jitter
    }
  }

  throw lastError!;
}
```

### Circuit Breaker
```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailure: Date | null = null;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';

  constructor(
    private threshold: number = 5,
    private timeout: number = 30000
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailure!.getTime() > this.timeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit is OPEN');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }

  private onFailure() {
    this.failures++;
    this.lastFailure = new Date();
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
    }
  }
}
```

## 에러 응답 형식

### REST API
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "email", "message": "Invalid email format" },
      { "field": "age", "message": "Must be positive number" }
    ],
    "traceId": "abc-123"
  }
}
```

## 체크리스트

### 구현
- [ ] 커스텀 에러 클래스 정의
- [ ] 전역 에러 핸들러
- [ ] 적절한 HTTP 상태 코드
- [ ] 에러 로깅 (스택트레이스 포함)
- [ ] 사용자 친화적 메시지

### 복원력
- [ ] 재시도 로직
- [ ] Circuit Breaker
- [ ] 타임아웃 설정
- [ ] 폴백 전략
- [ ] Graceful degradation

## 출력 형식

```
## Error Handling Strategy

### Error Classes
```typescript
// 커스텀 에러 클래스
```

### Global Handler
```typescript
// 전역 에러 핸들러
```

### Error Responses
| 상황 | 코드 | HTTP | 메시지 |
|------|------|------|--------|
| 유효성 검증 실패 | VALIDATION_ERROR | 400 | Invalid input |

### Resilience Patterns
- 재시도: 3회, exponential backoff
- Circuit Breaker: threshold 5, timeout 30s
```

---

요청에 맞는 에러 핸들링 전략을 설계하세요.
