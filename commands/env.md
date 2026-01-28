# Environment Configuration Skill

환경 설정 관리를 위한 가이드를 실행합니다.

## 핵심 원칙

```
1. 코드와 설정 분리 (12-Factor App)
2. 환경별 설정 관리
3. 민감 정보 보호
4. 기본값 제공
5. 유효성 검증
```

## 환경 변수 관리

### .env 파일 구조
```bash
# .env.example (버전 관리에 포함)
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/db
DATABASE_POOL_SIZE=10

# Redis
REDIS_URL=redis://localhost:6379

# API Keys (실제 값 대신 플레이스홀더)
API_KEY=your_api_key_here
JWT_SECRET=your_jwt_secret_here

# Feature Flags
FEATURE_NEW_UI=false
```

### 환경별 파일
```
.env                 # 기본 (공통)
.env.local           # 로컬 오버라이드 (gitignore)
.env.development     # 개발 환경
.env.staging         # 스테이징 환경
.env.production      # 프로덕션 환경
.env.test            # 테스트 환경
```

### 로딩 우선순위
```
1. 시스템 환경 변수
2. .env.{NODE_ENV}.local
3. .env.{NODE_ENV}
4. .env.local
5. .env
```

## 유효성 검증

### Node.js (Zod)
```typescript
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production', 'test']),
  PORT: z.string().transform(Number).default('3000'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_SECRET: z.string().min(32),
  API_KEY: z.string().min(1),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const env = envSchema.parse(process.env);
```

### Node.js (envalid)
```typescript
import { cleanEnv, str, port, url, bool } from 'envalid';

export const env = cleanEnv(process.env, {
  NODE_ENV: str({ choices: ['development', 'staging', 'production', 'test'] }),
  PORT: port({ default: 3000 }),
  DATABASE_URL: url(),
  JWT_SECRET: str({ desc: 'Secret for JWT signing' }),
  ENABLE_CACHE: bool({ default: true }),
});
```

### Python (pydantic)
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    node_env: str = "development"
    port: int = 3000
    database_url: str
    jwt_secret: str
    enable_cache: bool = True

    class Config:
        env_file = ".env"

settings = Settings()
```

## 설정 구조화

### Config 객체
```typescript
// config/index.ts
export const config = {
  app: {
    name: env.APP_NAME,
    port: env.PORT,
    env: env.NODE_ENV,
  },
  database: {
    url: env.DATABASE_URL,
    poolSize: env.DATABASE_POOL_SIZE,
  },
  redis: {
    url: env.REDIS_URL,
    ttl: env.REDIS_TTL,
  },
  auth: {
    jwtSecret: env.JWT_SECRET,
    jwtExpiresIn: env.JWT_EXPIRES_IN,
  },
  features: {
    newUi: env.FEATURE_NEW_UI,
  },
} as const;
```

### 환경별 설정
```typescript
// config/database.ts
const configs = {
  development: {
    poolSize: 5,
    logging: true,
  },
  production: {
    poolSize: 20,
    logging: false,
  },
  test: {
    poolSize: 1,
    logging: false,
  },
};

export const dbConfig = configs[env.NODE_ENV];
```

## 시크릿 관리

### 절대 금지
```bash
# ❌ 절대 하지 말 것
git add .env
git add credentials.json
git add *.pem
```

### .gitignore
```gitignore
# Environment
.env
.env.local
.env.*.local
!.env.example

# Secrets
*.pem
*.key
credentials.json
secrets/
```

### 프로덕션 시크릿 관리
```
옵션:
├── 환경 변수 (CI/CD에서 주입)
├── AWS Secrets Manager
├── HashiCorp Vault
├── Google Secret Manager
└── Azure Key Vault
```

### Docker Secrets
```yaml
# docker-compose.yml
services:
  app:
    secrets:
      - db_password
    environment:
      DATABASE_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Feature Flags

### 간단한 구현
```typescript
// config/features.ts
export const features = {
  newDashboard: env.FEATURE_NEW_DASHBOARD === 'true',
  betaApi: env.FEATURE_BETA_API === 'true',
  darkMode: env.FEATURE_DARK_MODE === 'true',
};

// 사용
if (features.newDashboard) {
  renderNewDashboard();
}
```

### 환경별 기본값
```typescript
const featureDefaults = {
  development: {
    newDashboard: true,
    betaApi: true,
  },
  production: {
    newDashboard: false,
    betaApi: false,
  },
};
```

## 체크리스트

### 설정 파일
- [ ] .env.example 작성
- [ ] .gitignore에 .env 추가
- [ ] 환경별 설정 분리
- [ ] 유효성 검증 구현

### 보안
- [ ] 민감 정보 하드코딩 없음
- [ ] 프로덕션 시크릿 안전하게 관리
- [ ] 로그에 민감 정보 출력 안됨
- [ ] 에러 메시지에 시크릿 노출 안됨

### 문서화
- [ ] 필수 환경 변수 문서화
- [ ] 기본값 명시
- [ ] 형식/제약조건 설명

## 출력 형식

```
## Environment Configuration

### .env.example
```bash
# 환경 변수 템플릿
```

### Validation Schema
```typescript
// 유효성 검증 코드
```

### Config Structure
```typescript
// 설정 구조
```

### Environment Matrix
| 변수 | 개발 | 스테이징 | 프로덕션 |
|------|------|---------|---------|
| LOG_LEVEL | debug | info | warn |

### Secrets Management
[시크릿 관리 방안]
```

---

요청에 맞는 환경 설정을 구성하세요.
