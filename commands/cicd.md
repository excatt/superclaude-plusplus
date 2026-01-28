# CI/CD Skill

CI/CD 파이프라인 설계 및 구성을 위한 가이드를 실행합니다.

## 파이프라인 구조

### 기본 스테이지
```
┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│  Build  │ → │  Test   │ → │  Scan   │ → │ Deploy  │ → │ Monitor │
└─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
```

### 환경별 배포
```
main → staging → production (수동 승인)
feature/* → preview environments
```

## GitHub Actions

### 기본 템플릿
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci
      - run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  security:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  deploy:
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/

      - name: Deploy to production
        run: |
          # 배포 스크립트
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

### 재사용 워크플로우
```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      DEPLOY_TOKEN:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - name: Deploy
        run: ./deploy.sh ${{ inputs.environment }}
```

## GitLab CI

```yaml
stages:
  - build
  - test
  - security
  - deploy

variables:
  NODE_VERSION: "20"

build:
  stage: build
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test:
  stage: test
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm test
  coverage: '/Coverage: \d+\.\d+%/'

security_scan:
  stage: security
  image: snyk/snyk:node
  script:
    - snyk test

deploy_staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - ./deploy.sh staging
  only:
    - develop

deploy_production:
  stage: deploy
  environment:
    name: production
    url: https://example.com
  script:
    - ./deploy.sh production
  only:
    - main
  when: manual
```

## 베스트 프랙티스

### 속도 최적화
- [ ] 캐싱 활용 (dependencies, Docker layers)
- [ ] 병렬 실행 (독립적인 job)
- [ ] 변경된 파일만 테스트
- [ ] 작은 Docker 이미지

### 보안
- [ ] 시크릿 관리 (Vault, GitHub Secrets)
- [ ] 최소 권한 원칙
- [ ] 의존성 취약점 스캔
- [ ] 코드 서명

### 신뢰성
- [ ] 멱등성 보장
- [ ] 롤백 전략
- [ ] 헬스 체크
- [ ] 배포 알림

### 모니터링
- [ ] 파이프라인 메트릭
- [ ] 배포 추적
- [ ] 에러 알림

## 출력 형식

```
## CI/CD Pipeline Design

### Pipeline Overview
```
[Build] → [Test] → [Security] → [Deploy]
```

### Configuration
```yaml
# CI/CD 설정 파일
```

### Environments
| 환경 | 트리거 | URL |
|------|--------|-----|
| staging | develop 브랜치 | staging.example.com |
| production | main 브랜치 (수동) | example.com |

### Secrets Required
- `DEPLOY_TOKEN`: 배포 인증
- `SNYK_TOKEN`: 보안 스캔

### Estimated Duration
- Build: ~2분
- Test: ~5분
- Deploy: ~3분
- Total: ~10분
```

---

요청에 맞는 CI/CD 파이프라인을 설계하세요.
