# {feature} Design Document

> **Summary**: {한 줄 요약}
>
> **Project**: {프로젝트명}
> **Author**: {작성자}
> **Date**: {YYYY-MM-DD}
> **Status**: Draft | In Review | Approved
> **Plan Doc**: [plan.md](../01-plan/features/{feature}.plan.md)

---

## 1. Overview

### 1.1 Design Goals
- {설계 목표 1}
- {설계 목표 2}
- {설계 목표 3}

### 1.2 Design Constraints
- {제약 조건 1}
- {제약 조건 2}

---

## 2. Architecture

### 2.1 System Context
```
┌─────────────────────────────────────────┐
│                 Client                   │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│              {feature}                   │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ API     │  │ Service │  │ Model   │ │
│  └─────────┘  └─────────┘  └─────────┘ │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│              Database                    │
└─────────────────────────────────────────┘
```

### 2.2 Component Diagram
```
src/features/{feature}/
├── api/
│   └── routes.ts          # API 라우트
├── components/
│   ├── {Feature}Form.tsx  # 폼 컴포넌트
│   └── {Feature}List.tsx  # 리스트 컴포넌트
├── hooks/
│   └── use{Feature}.ts    # 커스텀 훅
├── services/
│   └── {feature}.service.ts  # 비즈니스 로직
├── types/
│   └── {feature}.types.ts    # 타입 정의
└── index.ts               # 퍼블릭 API
```

---

## 3. Data Model

### 3.1 Entity Definitions

#### {Entity1}
```typescript
interface {Entity1} {
  id: string;
  createdAt: Date;
  updatedAt: Date;
  // 필드 정의
}
```

#### {Entity2}
```typescript
interface {Entity2} {
  id: string;
  {entity1}Id: string;  // FK
  // 필드 정의
}
```

### 3.2 Entity Relationships
```
{Entity1} 1──────N {Entity2}
    │
    └──────1 {Entity3}
```

### 3.3 Database Schema
```sql
CREATE TABLE {entity1} (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE {entity2} (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  {entity1}_id UUID REFERENCES {entity1}(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 4. API Specification

### 4.1 Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /api/{feature} | 목록 조회 | Required |
| GET | /api/{feature}/:id | 상세 조회 | Required |
| POST | /api/{feature} | 생성 | Required |
| PUT | /api/{feature}/:id | 수정 | Required |
| DELETE | /api/{feature}/:id | 삭제 | Required |

### 4.2 Request/Response Examples

#### GET /api/{feature}
**Request**
```http
GET /api/{feature}?page=1&limit=10
Authorization: Bearer {token}
```

**Response (Success)**
```json
{
  "data": [
    { "id": "...", "name": "..." }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10
  }
}
```

#### POST /api/{feature}
**Request**
```json
{
  "name": "example",
  "description": "..."
}
```

**Response (Success)**
```json
{
  "data": {
    "id": "...",
    "name": "example",
    "createdAt": "2025-01-31T00:00:00Z"
  }
}
```

### 4.3 Error Responses
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "name", "message": "Name is required" }
    ]
  }
}
```

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| VALIDATION_ERROR | 400 | 입력 검증 실패 |
| UNAUTHORIZED | 401 | 인증 필요 |
| FORBIDDEN | 403 | 권한 없음 |
| NOT_FOUND | 404 | 리소스 없음 |
| INTERNAL_ERROR | 500 | 서버 에러 |

---

## 5. UI Components

### 5.1 Component List
| Component | Props | Description |
|-----------|-------|-------------|
| {Feature}Form | onSubmit, initialData? | 생성/수정 폼 |
| {Feature}List | items, onSelect | 목록 표시 |
| {Feature}Card | item, onEdit, onDelete | 개별 아이템 |

### 5.2 State Management
```typescript
// Zustand store or React Context
interface {Feature}State {
  items: {Feature}[];
  isLoading: boolean;
  error: string | null;

  // Actions
  fetch: () => Promise<void>;
  create: (data: Create{Feature}Input) => Promise<void>;
  update: (id: string, data: Update{Feature}Input) => Promise<void>;
  delete: (id: string) => Promise<void>;
}
```

---

## 6. Security Considerations

### 6.1 Authentication
- [ ] JWT 토큰 검증
- [ ] 세션 관리

### 6.2 Authorization
- [ ] 역할 기반 접근 제어 (RBAC)
- [ ] 리소스 소유권 검증

### 6.3 Data Protection
- [ ] 입력 검증 (XSS, SQL Injection 방지)
- [ ] 민감 데이터 암호화
- [ ] Rate Limiting

---

## 7. Testing Strategy

### 7.1 Unit Tests
- [ ] Service 함수 테스트
- [ ] 유틸리티 함수 테스트

### 7.2 Integration Tests
- [ ] API 엔드포인트 테스트
- [ ] 데이터베이스 연동 테스트

### 7.3 E2E Tests
- [ ] 사용자 시나리오 테스트
- [ ] 크로스 브라우저 테스트

---

## 8. Implementation Order

| 순서 | 태스크 | 의존성 | 예상 |
|------|--------|--------|------|
| 1 | 데이터 모델 정의 | - | - |
| 2 | API 엔드포인트 구현 | 1 | - |
| 3 | Service 레이어 구현 | 1, 2 | - |
| 4 | UI 컴포넌트 구현 | 2, 3 | - |
| 5 | 테스트 작성 | 1-4 | - |

---

## Changelog

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 0.1 | {YYYY-MM-DD} | 초안 작성 | {작성자} |
