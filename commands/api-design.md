# API Design Skill

REST/GraphQL API 설계를 위한 체계적 가이드를 실행합니다.

## REST API 설계 원칙

### URL 구조
```
# 리소스 기반 설계
GET    /users              # 목록 조회
GET    /users/{id}         # 단일 조회
POST   /users              # 생성
PUT    /users/{id}         # 전체 수정
PATCH  /users/{id}         # 부분 수정
DELETE /users/{id}         # 삭제

# 관계 표현
GET    /users/{id}/orders  # 중첩 리소스
GET    /orders?user_id=123 # 쿼리 파라미터

# 버전 관리
/api/v1/users
/api/v2/users
```

### HTTP 상태 코드
```
# 성공
200 OK              # 조회/수정 성공
201 Created         # 생성 성공
204 No Content      # 삭제 성공

# 클라이언트 에러
400 Bad Request     # 잘못된 요청
401 Unauthorized    # 인증 필요
403 Forbidden       # 권한 없음
404 Not Found       # 리소스 없음
409 Conflict        # 충돌
422 Unprocessable   # 유효성 검증 실패
429 Too Many Requests # 레이트 리밋

# 서버 에러
500 Internal Error  # 서버 에러
503 Unavailable     # 서비스 불가
```

### 응답 형식
```json
// 성공 응답
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}

// 에러 응답
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "사용자 친화적 메시지",
    "details": [
      { "field": "email", "message": "유효한 이메일 필요" }
    ]
  }
}
```

## GraphQL 설계 원칙

### 스키마 설계
```graphql
type User {
  id: ID!
  email: String!
  orders(first: Int, after: String): OrderConnection!
}

type Query {
  user(id: ID!): User
  users(filter: UserFilter, pagination: Pagination): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}
```

### 베스트 프랙티스
- [ ] Nullable 필드 최소화
- [ ] Connection 패턴 (페이지네이션)
- [ ] Input 타입 분리
- [ ] Payload 타입으로 응답
- [ ] N+1 문제 해결 (DataLoader)

## API 체크리스트

### 보안
- [ ] 인증 (JWT/OAuth)
- [ ] 권한 검사
- [ ] 입력 검증
- [ ] Rate Limiting
- [ ] CORS 설정

### 문서화
- [ ] OpenAPI/Swagger 스펙
- [ ] 요청/응답 예시
- [ ] 에러 코드 문서
- [ ] 인증 방법 설명

### 성능
- [ ] 페이지네이션
- [ ] 필드 필터링
- [ ] 응답 압축
- [ ] 캐싱 헤더
- [ ] ETag 지원

## 출력 형식

```
## API Design Review

### Overview
- 스타일: REST / GraphQL
- 버전: v1
- 기본 URL: /api/v1

### Endpoints

#### [리소스명]
| Method | Path | Description |
|--------|------|-------------|
| GET | /resource | 목록 조회 |
| POST | /resource | 생성 |

#### Request/Response Examples
```json
// Request
{ "field": "value" }

// Response
{ "data": { ... } }
```

### Issues & Recommendations
1. [이슈] 권장 수정사항

### OpenAPI Spec (요약)
```yaml
paths:
  /users:
    get:
      summary: 사용자 목록
```
```

---

위 가이드를 기반으로 API 설계를 분석하거나 생성하세요.
