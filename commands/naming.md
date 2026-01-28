# Naming Skill

네이밍 컨벤션 가이드를 실행합니다.

## 핵심 원칙

```
1. 명확성 > 간결성
2. 일관성 유지
3. 발음 가능하게
4. 검색 가능하게
5. 의도를 드러내게
```

## 케이스 스타일

| 스타일 | 예시 | 용도 |
|--------|------|------|
| camelCase | `getUserName` | JS/TS 변수, 함수 |
| PascalCase | `UserService` | 클래스, 타입, 컴포넌트 |
| snake_case | `get_user_name` | Python, Ruby, DB |
| SCREAMING_SNAKE | `MAX_RETRIES` | 상수 |
| kebab-case | `user-profile` | URL, CSS, 파일명 |

## 언어별 컨벤션

### JavaScript/TypeScript
```javascript
// 변수: camelCase
const userName = 'John';
const isActive = true;

// 함수: camelCase, 동사로 시작
function getUserById(id) {}
const calculateTotal = (items) => {};

// 클래스: PascalCase
class UserService {}

// 상수: SCREAMING_SNAKE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = '/api/v1';

// 타입/인터페이스: PascalCase
interface UserProfile {}
type OrderStatus = 'pending' | 'completed';

// 컴포넌트: PascalCase
function UserCard() {}
const ProfilePage = () => {};

// 파일: kebab-case 또는 PascalCase
// user-service.ts 또는 UserService.ts
// UserCard.tsx (컴포넌트)
```

### Python
```python
# 변수: snake_case
user_name = 'John'
is_active = True

# 함수: snake_case
def get_user_by_id(user_id):
    pass

# 클래스: PascalCase
class UserService:
    pass

# 상수: SCREAMING_SNAKE
MAX_RETRY_COUNT = 3

# 모듈: snake_case
# user_service.py

# Private: _ 접두사
def _internal_method():
    pass

_private_var = 'hidden'
```

### SQL/Database
```sql
-- 테이블: snake_case, 복수형
CREATE TABLE users ();
CREATE TABLE order_items ();

-- 컬럼: snake_case
user_id, created_at, is_active

-- 인덱스: idx_{table}_{columns}
idx_users_email
idx_orders_user_id_created_at

-- Foreign Key: fk_{table}_{ref_table}
fk_orders_users
```

## 네이밍 패턴

### 불리언
```javascript
// is, has, can, should 접두사
const isActive = true;
const hasPermission = true;
const canEdit = true;
const shouldRefresh = true;
```

### 함수/메서드
```javascript
// 동사로 시작
get, set, fetch, create, update, delete
find, search, filter, sort
calculate, compute, process
validate, verify, check
format, parse, convert
handle, on (이벤트)
```

```javascript
// 예시
getUserById()       // 단일 조회
getUsers()          // 목록 조회
createUser()        // 생성
updateUser()        // 수정
deleteUser()        // 삭제
findUserByEmail()   // 조건 조회
validateEmail()     // 검증
formatDate()        // 포맷팅
handleClick()       // 이벤트
onSubmit()          // 콜백
```

### 컬렉션
```javascript
// 복수형 또는 타입 명시
const users = [];
const userList = [];
const userMap = new Map();
const userSet = new Set();
const userById = {};  // { id: user }
```

### 약어 규칙
```javascript
// 일반적인 약어는 허용
id, url, api, db, io

// 도메인 약어는 컨텍스트에서
userId, apiKey, dbConnection

// PascalCase에서 약어
UserId (O)  vs  UserID (X)
ApiClient (O) vs APIClient (X)

// 모호한 약어 피하기
temp, data, info, item, thing (X)
```

## 안티패턴

### 피해야 할 것
```javascript
// ❌ 한 글자 변수 (루프 제외)
const x = getUser();

// ❌ 숫자로 구분
const user1 = ...;
const user2 = ...;

// ❌ 헝가리안 표기법
const strName = 'John';
const arrUsers = [];

// ❌ 부정형 불리언
const isNotActive = false;  // 이중 부정 혼란

// ❌ 타입을 이름에
const userObject = {};
const nameString = '';

// ❌ 의미없는 접두사
const theUser = ...;
const aName = ...;
```

### 개선 예시
```javascript
// ❌ Bad
const d = new Date();
const list = getItems();
const temp = calculate();

// ✅ Good
const currentDate = new Date();
const orderItems = getItems();
const totalPrice = calculate();
```

## 컨텍스트별 가이드

### API 엔드포인트
```
GET    /users           # 목록
GET    /users/:id       # 단일
POST   /users           # 생성
PUT    /users/:id       # 수정
DELETE /users/:id       # 삭제
GET    /users/:id/orders  # 관계
POST   /auth/login      # 액션
```

### 파일/폴더
```
src/
├── components/        # 컴포넌트
│   └── UserCard.tsx
├── services/          # 서비스
│   └── user-service.ts
├── utils/             # 유틸리티
│   └── date-utils.ts
├── types/             # 타입
│   └── user.types.ts
└── constants/         # 상수
    └── api-endpoints.ts
```

### 환경변수
```bash
# SCREAMING_SNAKE, 접두사로 그룹화
DATABASE_URL=
DATABASE_HOST=
API_KEY=
API_BASE_URL=
JWT_SECRET=
JWT_EXPIRES_IN=
```

## 출력 형식

```
## Naming Review

### Current Issues
| 현재 | 문제 | 제안 |
|------|------|------|
| `getData` | 모호함 | `getUserProfile` |
| `x` | 의미없음 | `userCount` |

### Recommended Names
```javascript
// 변수
const userName = ...;

// 함수
function getUserById(id) {}

// 클래스
class UserRepository {}
```

### Conventions Applied
- 스타일: [camelCase/snake_case]
- 불리언: is/has 접두사
- 함수: 동사 시작
```

---

요청에 맞는 네이밍을 검토하거나 제안하세요.
