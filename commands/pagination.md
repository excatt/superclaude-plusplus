# Pagination Skill

페이지네이션 패턴 설계 가이드를 실행합니다.

## 페이지네이션 유형

### Offset 기반
```
GET /users?page=2&limit=20
→ OFFSET (page-1)*limit LIMIT limit

장점: 구현 단순, 특정 페이지 이동 가능
단점: 대용량에서 느림, 데이터 변경 시 중복/누락
```

### Cursor 기반
```
GET /users?cursor=abc123&limit=20
→ WHERE id > cursor LIMIT limit

장점: 대용량에서 빠름, 일관된 결과
단점: 특정 페이지 이동 불가
```

### Keyset 기반
```
GET /users?after_id=100&after_date=2024-01-15&limit=20
→ WHERE (created_at, id) > (after_date, after_id)

장점: 정렬된 대용량 데이터에 효율적
단점: 복잡한 정렬 시 어려움
```

## 구현 예시

### Offset (SQL)
```javascript
async function getUsers(page = 1, limit = 20) {
  const offset = (page - 1) * limit;

  const [users, [{ total }]] = await Promise.all([
    db.query(`
      SELECT * FROM users
      ORDER BY created_at DESC
      LIMIT $1 OFFSET $2
    `, [limit, offset]),
    db.query('SELECT COUNT(*) as total FROM users'),
  ]);

  return {
    data: users,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasNext: page < Math.ceil(total / limit),
      hasPrev: page > 1,
    },
  };
}
```

### Cursor (SQL)
```javascript
async function getUsers(cursor, limit = 20) {
  const query = cursor
    ? `SELECT * FROM users WHERE id > $1 ORDER BY id LIMIT $2`
    : `SELECT * FROM users ORDER BY id LIMIT $1`;

  const params = cursor ? [cursor, limit + 1] : [limit + 1];
  const users = await db.query(query, params);

  const hasNext = users.length > limit;
  if (hasNext) users.pop();

  return {
    data: users,
    pagination: {
      nextCursor: hasNext ? users[users.length - 1].id : null,
      hasNext,
    },
  };
}
```

### Relay Connection (GraphQL)
```javascript
async function getUsersConnection(first, after) {
  const cursor = after ? decodeCursor(after) : null;

  const query = cursor
    ? `SELECT * FROM users WHERE id > $1 ORDER BY id LIMIT $2`
    : `SELECT * FROM users ORDER BY id LIMIT $1`;

  const users = await db.query(query, cursor ? [cursor, first + 1] : [first + 1]);
  const hasNextPage = users.length > first;
  if (hasNextPage) users.pop();

  const edges = users.map(user => ({
    node: user,
    cursor: encodeCursor(user.id),
  }));

  return {
    edges,
    pageInfo: {
      hasNextPage,
      hasPreviousPage: !!cursor,
      startCursor: edges[0]?.cursor,
      endCursor: edges[edges.length - 1]?.cursor,
    },
    totalCount: await getTotalCount(),
  };
}

function encodeCursor(id) {
  return Buffer.from(`cursor:${id}`).toString('base64');
}

function decodeCursor(cursor) {
  return Buffer.from(cursor, 'base64').toString().replace('cursor:', '');
}
```

## API 응답 형식

### Offset 스타일
```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Cursor 스타일
```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTAwfQ==",
    "prevCursor": "eyJpZCI6ODB9",
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Link 헤더 (RFC 5988)
```
Link: <https://api.example.com/users?page=3>; rel="next",
      <https://api.example.com/users?page=1>; rel="prev",
      <https://api.example.com/users?page=1>; rel="first",
      <https://api.example.com/users?page=8>; rel="last"
```

## 성능 최적화

### 인덱스
```sql
-- Offset 페이지네이션
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Cursor 페이지네이션
CREATE INDEX idx_users_id ON users(id);

-- 복합 정렬
CREATE INDEX idx_users_created_id ON users(created_at DESC, id DESC);
```

### Count 최적화
```javascript
// 대략적인 카운트 (PostgreSQL)
async function getEstimatedCount(table) {
  const result = await db.query(`
    SELECT reltuples::bigint AS estimate
    FROM pg_class
    WHERE relname = $1
  `, [table]);
  return result[0].estimate;
}

// 캐시된 카운트
async function getCachedCount(key) {
  let count = await cache.get(key);
  if (!count) {
    count = await db.query('SELECT COUNT(*) FROM users');
    await cache.set(key, count, 'EX', 300); // 5분 캐시
  }
  return count;
}
```

## 선택 가이드

| 상황 | 권장 방식 |
|------|----------|
| 작은 데이터셋 (<10K) | Offset |
| 대용량 + 순차 탐색 | Cursor |
| 특정 페이지 점프 필요 | Offset |
| 실시간 데이터 | Cursor |
| GraphQL API | Relay Connection |
| 무한 스크롤 | Cursor |

## 체크리스트

- [ ] 적절한 방식 선택
- [ ] 인덱스 최적화
- [ ] 기본 limit 값 설정
- [ ] 최대 limit 제한
- [ ] 일관된 응답 형식

## 출력 형식

```
## Pagination Design

### Strategy
- 방식: [Offset/Cursor/Keyset]
- 이유: [선택 이유]

### API Design
```
GET /resource?[params]
```

### Response Format
```json
{
  "data": [...],
  "pagination": {...}
}
```

### Implementation
```javascript
// 구현 코드
```
```

---

요청에 맞는 페이지네이션을 설계하세요.
