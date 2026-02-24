# Project-Specific Rules

프로젝트 유형별 패키지 관리 및 빌드 규칙. CONVENTIONS.md와 함께 참조.

## Python Project Rules
**Priority**: 🔴

**Package Manager**: uv required (pip, poetry, pipenv forbidden)

| Item | Rule |
|------|------|
| Config file | `pyproject.toml` (PEP 621 standard) |
| Lock file | `uv.lock` (must commit) |

**pyproject.toml structure**:
```toml
[project]
name = "project-name"
requires-python = ">=3.11"
dependencies = []

[dependency-groups]
dev = ["pytest>=8.0"]
```

**Dockerfile pattern**:
```dockerfile
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
```

## Node.js Project Rules
**Priority**: 🔴

**Package Manager**: pnpm required (npm, yarn forbidden)

| Item | Rule |
|------|------|
| Lock file | `pnpm-lock.yaml` (must commit) |
| Workspace | `pnpm-workspace.yaml` (monorepo) |
| Node version | `.nvmrc` or `package.json engines` |

**Dockerfile pattern**:
```dockerfile
FROM node:20-slim
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
COPY . .
CMD ["pnpm", "start"]
```

**CI/CD pattern**:
```yaml
- uses: pnpm/action-setup@v2
  with:
    version: 9
- run: pnpm install --frozen-lockfile
```

## Security Incident Response
**Priority**: 🔴

1. Stop work immediately
2. Call `security-engineer`
3. Fix critical issues
4. Rotate credentials
5. Audit codebase

**Pre-Commit Security Checklist**:
- [ ] No hardcoded credentials
- [ ] All inputs validated
- [ ] SQL Injection prevented
- [ ] XSS attacks prevented
- [ ] Proper authentication/authorization applied
- [ ] Rate limiting applied
- [ ] No sensitive info in error messages

**Secret Management**:
```typescript
// ❌ Wrong: const apiKey = "sk-1234567890abcdef";
// ✅ Right:
const apiKey = process.env.API_KEY;
if (!apiKey) throw new Error("API_KEY required");
```
