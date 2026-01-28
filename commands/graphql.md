# GraphQL Skill

GraphQL 스키마 설계 가이드를 실행합니다.

## 스키마 기본

### 타입 정의
```graphql
# 스칼라 타입
type User {
  id: ID!
  name: String!
  email: String!
  age: Int
  isActive: Boolean!
  balance: Float
  createdAt: DateTime!
}

# 열거형
enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

# 인터페이스
interface Node {
  id: ID!
}

type User implements Node {
  id: ID!
  name: String!
}

# 유니온
union SearchResult = User | Product | Order
```

### 관계 모델링
```graphql
type User {
  id: ID!
  name: String!
  orders: [Order!]!          # 1:N
  profile: Profile           # 1:1
  friends: [User!]!          # N:N
}

type Order {
  id: ID!
  user: User!                # N:1
  items: [OrderItem!]!
}

type OrderItem {
  id: ID!
  product: Product!
  quantity: Int!
}
```

## Query 설계

### 기본 쿼리
```graphql
type Query {
  # 단일 조회
  user(id: ID!): User

  # 목록 조회 (페이지네이션)
  users(
    first: Int
    after: String
    filter: UserFilter
    orderBy: UserOrderBy
  ): UserConnection!

  # 검색
  search(query: String!): [SearchResult!]!

  # 뷰어 패턴 (현재 사용자)
  viewer: User
}

# 필터 입력
input UserFilter {
  status: UserStatus
  createdAfter: DateTime
  nameContains: String
}

# 정렬 입력
input UserOrderBy {
  field: UserOrderField!
  direction: OrderDirection!
}

enum UserOrderField {
  NAME
  CREATED_AT
}

enum OrderDirection {
  ASC
  DESC
}
```

### Connection 패턴 (Relay)
```graphql
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

## Mutation 설계

### 입력 타입
```graphql
type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(input: UpdateUserInput!): UpdateUserPayload!
  deleteUser(id: ID!): DeleteUserPayload!
}

input CreateUserInput {
  name: String!
  email: String!
  password: String!
}

# Payload 패턴
type CreateUserPayload {
  user: User
  errors: [Error!]
}

type Error {
  field: String
  message: String!
  code: ErrorCode!
}

enum ErrorCode {
  VALIDATION_ERROR
  NOT_FOUND
  UNAUTHORIZED
  CONFLICT
}
```

### 일괄 처리
```graphql
type Mutation {
  bulkUpdateUsers(input: BulkUpdateUsersInput!): BulkUpdateUsersPayload!
}

input BulkUpdateUsersInput {
  updates: [UserUpdateInput!]!
}

input UserUpdateInput {
  id: ID!
  name: String
  email: String
}

type BulkUpdateUsersPayload {
  users: [User!]!
  failedIds: [ID!]!
  errors: [Error!]
}
```

## Subscription 설계

```graphql
type Subscription {
  # 실시간 업데이트
  orderStatusChanged(orderId: ID!): Order!

  # 새 메시지
  messageReceived(channelId: ID!): Message!

  # 필터링된 이벤트
  notificationReceived(userId: ID!): Notification!
}
```

## Resolver 구현

### 기본 Resolver
```javascript
const resolvers = {
  Query: {
    user: async (_, { id }, context) => {
      return context.dataSources.users.findById(id);
    },

    users: async (_, { first, after, filter }, context) => {
      return context.dataSources.users.findAll({ first, after, filter });
    },
  },

  Mutation: {
    createUser: async (_, { input }, context) => {
      try {
        const user = await context.dataSources.users.create(input);
        return { user, errors: null };
      } catch (error) {
        return {
          user: null,
          errors: [{ message: error.message, code: 'VALIDATION_ERROR' }],
        };
      }
    },
  },

  User: {
    orders: async (user, _, context) => {
      return context.dataSources.orders.findByUserId(user.id);
    },
  },
};
```

### DataLoader (N+1 해결)
```javascript
const DataLoader = require('dataloader');

// DataLoader 생성
const userLoader = new DataLoader(async (ids) => {
  const users = await db.users.findByIds(ids);
  return ids.map(id => users.find(u => u.id === id));
});

// Resolver에서 사용
const resolvers = {
  Order: {
    user: (order, _, context) => {
      return context.loaders.user.load(order.userId);
    },
  },
};
```

## 인증/인가

### Context 설정
```javascript
const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: async ({ req }) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const user = token ? await verifyToken(token) : null;

    return {
      user,
      dataSources: { /* ... */ },
      loaders: { /* ... */ },
    };
  },
});
```

### Directive 기반 인가
```graphql
directive @auth(requires: Role = USER) on FIELD_DEFINITION

enum Role {
  ADMIN
  USER
  GUEST
}

type Query {
  users: [User!]! @auth(requires: ADMIN)
  viewer: User @auth
}
```

```javascript
const authDirective = (schema, directiveName) => {
  return mapSchema(schema, {
    [MapperKind.OBJECT_FIELD]: (fieldConfig) => {
      const directive = getDirective(schema, fieldConfig, directiveName)?.[0];
      if (directive) {
        const { resolve = defaultFieldResolver } = fieldConfig;
        fieldConfig.resolve = async (source, args, context, info) => {
          if (!context.user) throw new AuthenticationError('Not authenticated');
          if (directive.requires && context.user.role !== directive.requires) {
            throw new ForbiddenError('Not authorized');
          }
          return resolve(source, args, context, info);
        };
      }
      return fieldConfig;
    },
  });
};
```

## 에러 처리

```javascript
// 커스텀 에러
class ValidationError extends ApolloError {
  constructor(message, fields) {
    super(message, 'VALIDATION_ERROR', { fields });
  }
}

// Resolver에서 사용
const resolvers = {
  Mutation: {
    createUser: async (_, { input }) => {
      if (!isValidEmail(input.email)) {
        throw new ValidationError('Invalid email', { email: 'Invalid format' });
      }
      // ...
    },
  },
};
```

## 성능 최적화

### Query Complexity
```javascript
const server = new ApolloServer({
  validationRules: [
    createComplexityLimitRule(1000, {
      scalarCost: 1,
      objectCost: 10,
      listFactor: 10,
    }),
  ],
});
```

### Depth Limiting
```javascript
const depthLimit = require('graphql-depth-limit');

const server = new ApolloServer({
  validationRules: [depthLimit(5)],
});
```

## 체크리스트

### 스키마 설계
- [ ] 명확한 타입 정의
- [ ] Null 가능성 명시 (!)
- [ ] Connection 패턴 (페이지네이션)
- [ ] Input/Payload 타입 분리

### 보안
- [ ] 인증/인가
- [ ] Query complexity 제한
- [ ] Depth limiting
- [ ] Rate limiting

### 성능
- [ ] DataLoader (N+1 해결)
- [ ] 적절한 캐싱
- [ ] 쿼리 분석

## 출력 형식

```
## GraphQL Schema Design

### Types
```graphql
# 핵심 타입 정의
```

### Queries
```graphql
# 쿼리 정의
```

### Mutations
```graphql
# 뮤테이션 정의
```

### Resolver Example
```javascript
// Resolver 구현
```

### Security
- 인증: JWT
- 인가: Directive 기반
- 제한: Complexity 1000, Depth 5
```

---

요청에 맞는 GraphQL 스키마를 설계하세요.
