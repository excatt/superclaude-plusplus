# Caching Skill

캐싱 전략 설계를 위한 가이드를 실행합니다.

## 캐시 계층

```
        응답시간
L1: 브라우저 캐시     ~1ms
L2: CDN              ~10ms
L3: 애플리케이션 캐시  ~1ms
L4: Redis/Memcached  ~1-5ms
L5: 데이터베이스      ~10-100ms
```

## 캐싱 패턴

### Cache-Aside (Lazy Loading)
```
Read:
1. 캐시 확인
2. Miss → DB 조회 → 캐시 저장 → 반환
3. Hit → 캐시에서 반환

Write:
1. DB 업데이트
2. 캐시 무효화
```

```javascript
async function getUser(id) {
  // 1. 캐시 확인
  const cached = await cache.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  // 2. DB 조회
  const user = await db.users.findById(id);

  // 3. 캐시 저장
  await cache.set(`user:${id}`, JSON.stringify(user), 'EX', 3600);

  return user;
}
```

### Write-Through
```
Write:
1. 캐시에 쓰기
2. 캐시가 DB에 동기적으로 쓰기

장점: 데이터 일관성
단점: 쓰기 지연
```

### Write-Behind (Write-Back)
```
Write:
1. 캐시에 쓰기
2. 비동기로 DB에 배치 쓰기

장점: 쓰기 성능 좋음
단점: 데이터 손실 위험
```

### Read-Through
```
Read:
1. 캐시에서 읽기
2. Miss → 캐시가 DB 조회 후 저장

캐시 라이브러리가 로딩 담당
```

## 캐시 무효화 전략

### TTL (Time To Live)
```javascript
// 시간 기반 만료
await cache.set('key', value, 'EX', 3600); // 1시간

// 적합: 자주 바뀌지 않는 데이터
// 주의: 오래된 데이터 가능성
```

### 이벤트 기반
```javascript
// 변경 시 즉시 무효화
async function updateUser(id, data) {
  await db.users.update(id, data);
  await cache.del(`user:${id}`);
  await cache.del(`users:list`);  // 관련 캐시도 무효화
}
```

### 버전 기반
```javascript
// 키에 버전 포함
const version = await getVersion('users');
const key = `users:v${version}:${id}`;

// 버전 증가로 전체 무효화
await incrementVersion('users');
```

## 캐시 키 설계

### 네이밍 컨벤션
```
{prefix}:{entity}:{identifier}:{variant}

예시:
user:123                    # 단일 사용자
users:list:page:1           # 페이지네이션
user:123:profile            # 프로필
user:123:orders:recent      # 최근 주문
search:products:q=phone     # 검색 결과
```

### 키 관리
```javascript
const CacheKeys = {
  user: (id) => `user:${id}`,
  userList: (page) => `users:list:page:${page}`,
  userOrders: (id) => `user:${id}:orders`,
};

// 패턴으로 일괄 삭제
await cache.del(cache.keys('user:123:*'));
```

## Redis 활용

### 데이터 구조별 사용
```javascript
// String: 단순 값
await redis.set('user:123', JSON.stringify(user));

// Hash: 객체 필드
await redis.hset('user:123', 'name', 'John', 'email', 'john@example.com');

// List: 최근 항목
await redis.lpush('user:123:activities', activity);
await redis.ltrim('user:123:activities', 0, 99); // 최근 100개만

// Set: 유니크 컬렉션
await redis.sadd('online:users', '123');

// Sorted Set: 랭킹
await redis.zadd('leaderboard', score, 'user:123');
```

### 분산 락
```javascript
async function withLock(key, fn, ttl = 10000) {
  const lockKey = `lock:${key}`;
  const acquired = await redis.set(lockKey, '1', 'PX', ttl, 'NX');

  if (!acquired) throw new Error('Lock not acquired');

  try {
    return await fn();
  } finally {
    await redis.del(lockKey);
  }
}
```

## HTTP 캐싱

### 캐시 헤더
```javascript
// 정적 자원 (이미지, JS, CSS)
res.set('Cache-Control', 'public, max-age=31536000, immutable');

// API 응답
res.set('Cache-Control', 'private, max-age=60');

// 캐시 금지
res.set('Cache-Control', 'no-store');
```

### ETag
```javascript
const etag = crypto.createHash('md5').update(data).digest('hex');
res.set('ETag', `"${etag}"`);

if (req.headers['if-none-match'] === `"${etag}"`) {
  return res.status(304).end();
}
```

## 캐싱 체크리스트

### 설계
- [ ] 캐싱할 데이터 식별
- [ ] 적절한 TTL 설정
- [ ] 무효화 전략 결정
- [ ] 캐시 키 설계

### 구현
- [ ] 캐시 미스 처리
- [ ] 직렬화/역직렬화
- [ ] 에러 핸들링 (캐시 장애 시)
- [ ] 메모리 제한 설정

### 모니터링
- [ ] 히트율 측정
- [ ] 메모리 사용량
- [ ] 지연시간
- [ ] 무효화 빈도

## 출력 형식

```
## Caching Strategy

### Overview
[캐싱 목표 및 대상]

### Cache Layers
| 계층 | 대상 | TTL | 패턴 |
|------|------|-----|------|
| CDN | 정적 자원 | 1년 | Immutable |
| Redis | 사용자 데이터 | 1시간 | Cache-Aside |

### Key Design
```
prefix:entity:id
```

### Invalidation Strategy
[무효화 방식 및 트리거]

### Implementation
```javascript
// 핵심 캐싱 코드
```

### Monitoring
- 목표 히트율: 90%+
- 알림: 히트율 < 80%
```

---

요청에 맞는 캐싱 전략을 설계하세요.
