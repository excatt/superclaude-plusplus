# Rate Limiting Skill

레이트 리밋 설계 가이드를 실행합니다.

## 레이트 리밋 알고리즘

### Token Bucket
```
버킷에 토큰이 일정 속도로 추가
요청 시 토큰 소비
토큰 없으면 거부

┌─────────────┐
│ ○ ○ ○ ○ ○  │ ← 토큰 추가 (초당 10개)
│   Bucket    │
└──────┬──────┘
       ↓ 요청당 1토큰 소비
    [Request]

장점: 버스트 허용, 평균 속도 제한
구현: Redis + Lua Script
```

### Leaky Bucket
```
요청이 버킷에 쌓임
일정 속도로 처리
버킷 넘치면 거부

     [Request]
         ↓
┌─────────────┐
│ ░ ░ ░ ░ ░  │ ← 큐 (고정 크기)
└──────┬──────┘
       ↓ 일정 속도로 처리
   [Processed]

장점: 일정한 출력 속도
단점: 버스트 불가
```

### Fixed Window
```
고정 시간 창에서 요청 수 제한

|----60초----|----60초----|
| 100 요청   | 100 요청   |
|____________|____________|

단점: 경계에서 2배 버스트 가능
      (59초에 100개 + 61초에 100개)
```

### Sliding Window Log
```
각 요청의 타임스탬프 기록
윈도우 내 요청 수 계산

현재 시간: 10:05:30
윈도우: 60초
[10:04:31, 10:04:45, 10:05:10, 10:05:25]
→ 윈도우 내 4개 요청

장점: 정확함
단점: 메모리 사용 많음
```

### Sliding Window Counter
```
이전 윈도우와 현재 윈도우 가중 평균

이전 윈도우 (70개) × 30% + 현재 윈도우 (50개) × 70%
= 21 + 35 = 56개

장점: 메모리 효율적, 상당히 정확
```

## 구현 예시

### Redis + Token Bucket
```lua
-- rate_limit.lua
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

local bucket = redis.call('HMGET', key, 'tokens', 'last_update')
local tokens = tonumber(bucket[1]) or limit
local last_update = tonumber(bucket[2]) or now

-- 토큰 리필
local elapsed = now - last_update
local refill = elapsed * (limit / window)
tokens = math.min(limit, tokens + refill)

if tokens >= 1 then
    tokens = tokens - 1
    redis.call('HMSET', key, 'tokens', tokens, 'last_update', now)
    redis.call('EXPIRE', key, window)
    return {1, tokens}  -- 허용, 남은 토큰
else
    return {0, 0}  -- 거부
end
```

### Node.js 미들웨어
```javascript
const Redis = require('ioredis');
const redis = new Redis();

const rateLimitScript = fs.readFileSync('rate_limit.lua', 'utf8');

async function rateLimit(options) {
  const { key, limit, window } = options;

  return async (req, res, next) => {
    const identifier = req.ip; // 또는 req.user.id
    const redisKey = `ratelimit:${key}:${identifier}`;

    const [allowed, remaining] = await redis.eval(
      rateLimitScript,
      1,
      redisKey,
      limit,
      window,
      Date.now() / 1000
    );

    res.set('X-RateLimit-Limit', limit);
    res.set('X-RateLimit-Remaining', remaining);

    if (!allowed) {
      res.set('Retry-After', window);
      return res.status(429).json({
        error: 'Too Many Requests',
        retryAfter: window,
      });
    }

    next();
  };
}

// 사용
app.use('/api/', rateLimit({ key: 'api', limit: 100, window: 60 }));
app.use('/api/search', rateLimit({ key: 'search', limit: 10, window: 60 }));
```

### Express Rate Limit
```javascript
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');

const limiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:',
  }),
  windowMs: 60 * 1000, // 1분
  max: 100, // 100 요청
  message: { error: 'Too many requests' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', limiter);
```

## 레이트 리밋 전략

### 계층별 제한
```javascript
const limits = {
  global: { limit: 10000, window: 60 },      // 전체 API
  authenticated: { limit: 1000, window: 60 }, // 인증된 사용자
  anonymous: { limit: 100, window: 60 },      // 익명 사용자
  endpoint: {                                  // 엔드포인트별
    '/api/search': { limit: 10, window: 60 },
    '/api/upload': { limit: 5, window: 60 },
  },
};
```

### 사용자 티어별
```javascript
const tierLimits = {
  free: { limit: 100, window: 3600 },      // 시간당 100
  basic: { limit: 1000, window: 3600 },    // 시간당 1000
  pro: { limit: 10000, window: 3600 },     // 시간당 10000
  enterprise: { limit: 100000, window: 3600 },
};

function getRateLimit(user) {
  return tierLimits[user.tier] || tierLimits.free;
}
```

### 동적 제한
```javascript
// 부하에 따른 동적 조정
async function getDynamicLimit() {
  const load = await getSystemLoad();

  if (load > 0.9) return { limit: 50, window: 60 };   // 높은 부하
  if (load > 0.7) return { limit: 75, window: 60 };   // 중간 부하
  return { limit: 100, window: 60 };                   // 정상
}
```

## 응답 헤더

### 표준 헤더
```
X-RateLimit-Limit: 100        # 최대 요청 수
X-RateLimit-Remaining: 45     # 남은 요청 수
X-RateLimit-Reset: 1640000000 # 리셋 시간 (Unix timestamp)
Retry-After: 30               # 재시도까지 초 (429 응답 시)
```

### 응답 예시
```json
// 429 Too Many Requests
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 30 seconds.",
    "retryAfter": 30,
    "limit": 100,
    "remaining": 0,
    "reset": 1640000000
  }
}
```

## 분산 환경

### Redis Cluster
```javascript
// 모든 인스턴스가 같은 Redis 참조
const redis = new Redis.Cluster([
  { host: 'redis-1', port: 6379 },
  { host: 'redis-2', port: 6379 },
  { host: 'redis-3', port: 6379 },
]);
```

### 일관성 고려
```
Strong Consistency: 모든 노드가 동일한 카운트 (느림)
Eventual Consistency: 일시적 불일치 허용 (빠름)

대부분의 레이트 리밋은 Eventual Consistency로 충분
약간의 초과 허용이 성능보다 덜 중요
```

## 체크리스트

### 설계
- [ ] 알고리즘 선택
- [ ] 제한 수치 결정
- [ ] 키 식별자 정의 (IP, 사용자, API 키)
- [ ] 티어별 제한 설계

### 구현
- [ ] 분산 저장소 (Redis)
- [ ] 응답 헤더 설정
- [ ] 에러 응답 형식
- [ ] 바이패스 규칙 (내부, 헬스체크)

### 운영
- [ ] 모니터링/알림
- [ ] 제한 초과 로깅
- [ ] 동적 조정 메커니즘

## 출력 형식

```
## Rate Limit Design

### Strategy
- 알고리즘: Token Bucket
- 저장소: Redis

### Limits
| 대상 | 제한 | 윈도우 | 키 |
|------|------|--------|-----|
| Global | 10000 | 분 | IP |
| Auth User | 1000 | 분 | user_id |
| Search API | 10 | 분 | user_id |

### Implementation
```javascript
// 핵심 구현 코드
```

### Response Format
```json
// 429 응답 예시
```
```

---

요청에 맞는 레이트 리밋 전략을 설계하세요.
