---
name: "api-design"
description: "Designs REST endpoints and GraphQL schemas with versioning, pagination, auth strategies, and OpenAPI spec generation. Follows a structured review workflow from resource identification through validation. Use when: API design, REST API, GraphQL schema, endpoint structure, API architecture, OpenAPI, Swagger, API versioning, endpoint design. Do NOT use for: API testing, API debugging, frontend-only changes."
user-invocable: true
argument-hint: [domain-or-requirements]
---

## Dynamic Context

Existing API structure:
!`find . -name "*.ts" -path "*/api/*" -o -name "*.py" -path "*/api/*" -o -name "*.go" -path "*/api/*" 2>/dev/null | head -10 || echo "No API files found"`

# API Design Skill

## Purpose

Design and review APIs through a structured workflow that covers resource modeling, endpoint design, schema definition, and validation against best practices.

## Usage

```bash
/api-design "user management system"     # design from requirements
/api-design src/api/                      # review existing API
/api-design --style graphql "order system" # specify API style
```

## Design Workflow

### Step 1: Identify Resources and Relationships

Map the domain model:
- List all resources (nouns): users, orders, products, etc.
- Define relationships: one-to-many, many-to-many
- Identify aggregate roots vs. sub-resources

### Step 2: Choose API Style

| Factor | REST | GraphQL |
|--------|------|---------|
| Multiple clients with different data needs | Overhead (over/under-fetching) | Strong fit (client-specified queries) |
| Simple CRUD operations | Strong fit | Overhead |
| Real-time subscriptions needed | Requires WebSocket add-on | Built-in subscriptions |
| Caching requirements | HTTP caching built-in | Requires custom caching |
| Team familiarity | Widely known | Steeper learning curve |

**Decision**: Default to REST unless the project has specific needs that GraphQL addresses better.

### Step 3: Design Endpoints (REST) or Schema (GraphQL)

**REST**: Define resources, methods, and URL patterns. Use plural nouns, nest sub-resources max 2 levels deep, and keep URLs consistent.

**GraphQL**: Define types, queries, and mutations. Use Input types for mutations, Connection pattern for pagination, and Payload types for mutation responses.

### Step 4: Define Error Handling and Pagination

**Errors**: Use a consistent error response envelope with machine-readable codes and human-readable messages.

**Pagination**: Choose cursor-based (for infinite scroll, real-time data) or offset-based (for page numbers, known total counts).

### Step 5: Validate Against Checklist

**Security**:
- [ ] Authentication strategy defined (JWT, OAuth, API keys)
- [ ] Authorization at resource level
- [ ] Input validation on all endpoints
- [ ] Rate limiting configured
- [ ] CORS policy defined

**Consistency**:
- [ ] Naming conventions consistent across all endpoints
- [ ] Response envelope format standardized
- [ ] Error codes documented and unique
- [ ] Versioning strategy defined

**Performance**:
- [ ] Pagination on all list endpoints
- [ ] Field filtering supported where beneficial
- [ ] Caching headers defined for read endpoints

**Documentation**:
- [ ] OpenAPI/Swagger spec generated
- [ ] Request/response examples for each endpoint
- [ ] Authentication method documented

## Output Format

```
## API Design Review

### Overview
- Style: REST / GraphQL
- Version: v1
- Base URL: /api/v1

### Resources
| Resource | Endpoints | Auth Required |
|----------|-----------|---------------|
| users    | CRUD + search | Yes |

### Endpoint Details

#### [Resource]
| Method | Path | Description | Request | Response |
|--------|------|-------------|---------|----------|
| GET    | /resource | List all | - | 200: paginated list |
| POST   | /resource | Create | body: {...} | 201: created resource |

### Recommendations
1. [Issue found] → [Recommended fix]

### OpenAPI Spec (key paths)
[Generated spec snippet]
```

## Related Skills

- `/security-audit` - Audit API security
- `/auth` - Authentication and authorization patterns
- `/rate-limit` - Rate limiting strategies
