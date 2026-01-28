# API Versioning Skill

API 버저닝 전략 가이드를 실행합니다.

## 버저닝 방식

### URL Path
```
GET /api/v1/users
GET /api/v2/users

장점: 명확함, 캐싱 용이
단점: URL 변경, 리소스 중복
```

### Query Parameter
```
GET /api/users?version=1
GET /api/users?version=2

장점: 선택적 버전 지정
단점: 라우팅 복잡, 캐싱 어려움
```

### Header
```
GET /api/users
Accept: application/vnd.api+json; version=1
Accept-Version: v1
X-API-Version: 1

장점: 깔끔한 URL
단점: 테스트 어려움, 숨겨진 버전
```

### Content Negotiation
```
GET /api/users
Accept: application/vnd.company.users.v1+json

장점: HTTP 표준 준수
단점: 복잡함
```

## 구현 예시

### URL Path (Express)
```javascript
const express = require('express');
const app = express();

// v1 라우터
const v1Router = express.Router();
v1Router.get('/users', getUsersV1);

// v2 라우터
const v2Router = express.Router();
v2Router.get('/users', getUsersV2);

app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);

// 기본 버전 (최신)
app.use('/api', v2Router);
```

### Header (미들웨어)
```javascript
function versionMiddleware(req, res, next) {
  const version = req.headers['accept-version'] ||
                  req.headers['x-api-version'] ||
                  'v2'; // 기본값

  req.apiVersion = version.replace('v', '');
  next();
}

app.use(versionMiddleware);

// 컨트롤러에서 버전 분기
async function getUsers(req, res) {
  if (req.apiVersion === '1') {
    return getUsersV1(req, res);
  }
  return getUsersV2(req, res);
}
```

### 버전별 응답 변환
```javascript
// 응답 트랜스포머
const transformers = {
  1: (user) => ({
    id: user.id,
    name: user.name,
    email: user.email,
  }),
  2: (user) => ({
    id: user.id,
    fullName: user.name,
    emailAddress: user.email,
    createdAt: user.created_at,
    updatedAt: user.updated_at,
  }),
};

function transformResponse(data, version) {
  const transformer = transformers[version];
  if (Array.isArray(data)) {
    return data.map(transformer);
  }
  return transformer(data);
}
```

## 버전 수명주기

### Deprecation 프로세스
```
1. 새 버전 릴리스 (v2)
2. 이전 버전 deprecation 공지
3. Sunset 헤더 추가
4. Deprecation 기간 (6-12개월)
5. 이전 버전 종료
```

### Deprecation 헤더
```javascript
function deprecationMiddleware(req, res, next) {
  if (req.apiVersion === '1') {
    res.set('Deprecation', 'true');
    res.set('Sunset', 'Sat, 31 Dec 2024 23:59:59 GMT');
    res.set('Link', '</api/v2>; rel="successor-version"');
  }
  next();
}
```

### Changelog 관리
```markdown
# API Changelog

## v2 (2024-01-15)

### Breaking Changes
- `name` → `fullName`
- `email` → `emailAddress`

### New Features
- Added `createdAt`, `updatedAt` fields
- New `/users/search` endpoint

### Deprecated
- v1 deprecated, sunset: 2024-12-31

## v1 (2023-01-01)
- Initial release
```

## 버전 전략

### Major.Minor.Patch (SemVer)
```
Major: Breaking changes (v1 → v2)
Minor: New features, backward compatible
Patch: Bug fixes

API에서는 보통 Major만 URL에 노출
```

### Date-based
```
GET /api/2024-01-15/users

장점: 명확한 릴리스 시점
단점: URL이 길어짐
```

## Breaking Change 최소화

### 추가적 변경만
```javascript
// v1 응답
{ "id": 1, "name": "John" }

// v2 응답 (필드 추가만)
{ "id": 1, "name": "John", "email": "john@example.com" }
```

### 필드 이름 변경 시
```javascript
// 두 필드 모두 포함 (전환 기간)
{
  "name": "John",      // deprecated
  "fullName": "John"   // new
}
```

### Wrapper 패턴
```javascript
// v1과 v2가 같은 핵심 로직 사용
async function getUsersCore(options) {
  return db.users.findAll(options);
}

async function getUsersV1(req, res) {
  const users = await getUsersCore({ limit: 10 });
  res.json(users.map(transformV1));
}

async function getUsersV2(req, res) {
  const users = await getUsersCore({ limit: 20 });
  res.json(users.map(transformV2));
}
```

## 문서화

### OpenAPI (Swagger)
```yaml
openapi: 3.0.0
info:
  title: My API
  version: 2.0.0

servers:
  - url: https://api.example.com/v2
    description: Production (v2)
  - url: https://api.example.com/v1
    description: Production (v1, deprecated)

paths:
  /users:
    get:
      summary: Get users
      deprecated: false  # v1에서는 true
```

## 체크리스트

### 설계
- [ ] 버저닝 방식 선택
- [ ] 버전 수명주기 정의
- [ ] Breaking change 정책

### 구현
- [ ] 버전 라우팅
- [ ] 응답 변환
- [ ] Deprecation 헤더

### 운영
- [ ] 버전별 문서
- [ ] Changelog 관리
- [ ] 사용 통계 모니터링

## 출력 형식

```
## API Versioning Strategy

### Approach
- 방식: [URL Path/Header/etc]
- 현재 버전: v2
- Deprecated: v1 (sunset: 2024-12-31)

### URL Structure
```
/api/v{version}/resource
```

### Implementation
```javascript
// 버전 라우팅 코드
```

### Migration Guide
| v1 | v2 | 변경사항 |
|----|----|---------|
| name | fullName | 필드명 변경 |

### Deprecation Timeline
- v1 deprecated: 2024-01-15
- v1 sunset: 2024-12-31
```

---

요청에 맞는 API 버저닝 전략을 설계하세요.
