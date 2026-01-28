# Monorepo Skill

모노레포 설정 가이드를 실행합니다.

## 모노레포 장단점

### 장점
```
✅ 코드 공유 용이
✅ 일관된 개발 환경
✅ 원자적 변경 (여러 패키지 동시 수정)
✅ 단일 이슈 트래커
✅ 통합 CI/CD
```

### 단점
```
❌ 초기 설정 복잡
❌ 빌드 시간 증가
❌ 큰 저장소 크기
❌ 권한 관리 어려움
```

## 도구 선택

| 도구 | 특징 |
|------|------|
| **Turborepo** | 빠름, 캐싱, 간단한 설정 |
| **Nx** | 풍부한 기능, 플러그인 생태계 |
| **Lerna** | npm/yarn 기반, 버전 관리 |
| **pnpm workspaces** | 빠름, 디스크 효율적 |

## Turborepo 설정

### 프로젝트 구조
```
my-monorepo/
├── apps/
│   ├── web/          # Next.js 앱
│   │   └── package.json
│   └── api/          # Express 서버
│       └── package.json
├── packages/
│   ├── ui/           # 공유 컴포넌트
│   │   └── package.json
│   ├── config/       # 공유 설정
│   │   └── package.json
│   └── utils/        # 유틸리티
│       └── package.json
├── package.json
├── turbo.json
└── pnpm-workspace.yaml
```

### package.json (루트)
```json
{
  "name": "my-monorepo",
  "private": true,
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test"
  },
  "devDependencies": {
    "turbo": "^1.10.0"
  },
  "packageManager": "pnpm@8.0.0"
}
```

### pnpm-workspace.yaml
```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### turbo.json
```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {},
    "test": {
      "dependsOn": ["build"],
      "inputs": ["src/**/*.ts", "test/**/*.ts"]
    }
  }
}
```

### 패키지 package.json
```json
// packages/ui/package.json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsup src/index.ts --dts",
    "dev": "tsup src/index.ts --dts --watch"
  }
}

// apps/web/package.json
{
  "name": "web",
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

## Nx 설정

### 초기화
```bash
npx create-nx-workspace@latest my-monorepo
```

### nx.json
```json
{
  "npmScope": "myorg",
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "lint", "test"]
      }
    }
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"]
    }
  }
}
```

### 프로젝트 생성
```bash
# 앱 생성
nx g @nx/next:app web
nx g @nx/express:app api

# 라이브러리 생성
nx g @nx/js:lib utils
nx g @nx/react:lib ui
```

## 공유 설정

### TypeScript
```json
// packages/config/tsconfig.base.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true
  }
}

// apps/web/tsconfig.json
{
  "extends": "@repo/config/tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist"
  }
}
```

### ESLint
```json
// packages/config/eslint-preset.js
module.exports = {
  extends: ['eslint:recommended', 'prettier'],
  env: { node: true, es2022: true },
  parserOptions: { ecmaVersion: 2022 },
};

// apps/web/.eslintrc.js
module.exports = {
  extends: ['@repo/config/eslint-preset'],
  // 프로젝트별 설정
};
```

## 버전 관리

### Changesets
```bash
# 설치
pnpm add -Dw @changesets/cli
pnpm changeset init

# 변경사항 기록
pnpm changeset

# 버전 업데이트
pnpm changeset version

# 배포
pnpm changeset publish
```

### .changeset/config.json
```json
{
  "$schema": "https://unpkg.com/@changesets/config/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main"
}
```

## CI/CD

### GitHub Actions
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - uses: pnpm/action-setup@v2
        with:
          version: 8

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

      - run: pnpm install

      # Turborepo 캐시
      - uses: actions/cache@v3
        with:
          path: .turbo
          key: ${{ runner.os }}-turbo-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-turbo-

      # 변경된 패키지만 빌드
      - run: pnpm turbo run build lint test --filter=...[HEAD^1]
```

## 체크리스트

### 초기 설정
- [ ] 도구 선택 (Turborepo/Nx)
- [ ] 디렉토리 구조 설계
- [ ] 공유 설정 (TS, ESLint)
- [ ] 워크스페이스 설정

### 개발
- [ ] 패키지 간 의존성 관리
- [ ] 로컬 개발 환경
- [ ] 핫 리로드 설정

### CI/CD
- [ ] 캐싱 전략
- [ ] 변경 감지
- [ ] 선택적 배포

## 출력 형식

```
## Monorepo Setup

### Structure
```
my-monorepo/
├── apps/
├── packages/
└── ...
```

### Tool
- 선택: [Turborepo/Nx]
- 패키지 매니저: [pnpm]

### Configuration
```json
// turbo.json 또는 nx.json
```

### Shared Packages
| 패키지 | 용도 |
|--------|------|
| @repo/ui | 공유 컴포넌트 |
| @repo/utils | 유틸리티 |
```

---

요청에 맞는 모노레포를 설정하세요.
