# Docker Skill

Docker 및 컨테이너 설정을 위한 가이드를 실행합니다.

## Docker Compose V2 (2024+)

### 기본 구조 (최신)
```yaml
# docker-compose.yml (v2 - version 키 불필요)
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      db:
        condition: service_healthy
        restart: true
    develop:  # NEW: Watch mode
      watch:
        - action: sync
          path: ./src
          target: /app/src
        - action: rebuild
          path: package.json
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    restart: unless-stopped
    networks:
      - app-network

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Docker Compose Watch (개발용)
```bash
# 파일 변경 자동 감지 및 동기화
docker compose watch

# 또는 백그라운드
docker compose up --watch
```

## Dockerfile 베스트 프랙티스

### Node.js (Bun 포함)
```dockerfile
# ===== Node.js =====
FROM node:22-alpine AS base
WORKDIR /app

# Dependencies
FROM base AS deps
COPY package*.json ./
RUN npm ci --only=production

# Build
FROM base AS builder
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production
FROM base AS production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]

# ===== Bun (대안) =====
FROM oven/bun:1 AS bun-base
WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile --production
COPY . .
USER bun
EXPOSE 3000
CMD ["bun", "run", "start"]
```

### Python (uv 포함)
```dockerfile
# ===== Python with uv (2024 최신) =====
FROM python:3.12-slim AS base
WORKDIR /app

# uv 설치
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Production
COPY . .
USER nobody
EXPOSE 8000
CMD ["uv", "run", "gunicorn", "-b", "0.0.0.0:8000", "app:app"]

# ===== 전통적 pip 방식 =====
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER nobody
EXPOSE 8000
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
```

### Go
```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o main .

FROM scratch
COPY --from=builder /app/main /main
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["/main"]
```

### Rust
```dockerfile
FROM rust:1.75-alpine AS builder
WORKDIR /app
RUN apk add --no-cache musl-dev
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM scratch
COPY --from=builder /app/target/release/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
```

## 최적화 체크리스트

### 이미지 크기
- [ ] 멀티스테이지 빌드 사용
- [ ] 경량 베이스 이미지 (alpine, slim, distroless)
- [ ] .dockerignore 설정
- [ ] 불필요한 파일/패키지 제거
- [ ] `--no-cache` 플래그 사용

### 보안
- [ ] non-root 사용자 실행
- [ ] 시크릿 관리 (BuildKit secrets)
- [ ] 읽기 전용 파일시스템
- [ ] 취약점 스캔 (Trivy, Snyk)
- [ ] 신뢰할 수 있는 베이스 이미지

### 캐싱
- [ ] 레이어 순서 최적화 (변경 적은 것 먼저)
- [ ] BuildKit 캐시 마운트
- [ ] 의존성 파일 먼저 COPY

### BuildKit 캐시 마운트
```dockerfile
# npm 캐시
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# pip 캐시
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Go 모듈 캐시
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
```

## .dockerignore
```
node_modules
npm-debug.log
.git
.gitignore
.env*
*.md
!README.md
Dockerfile*
docker-compose*.yml
.dockerignore
coverage
.nyc_output
dist
build
*.log
.DS_Store
```

## 자주 쓰는 명령어 (V2)

### 이미지
```bash
docker build -t name:tag .
docker build --target production -t name:prod .
docker images
docker image prune -a
docker buildx build --platform linux/amd64,linux/arm64 -t name:tag .
```

### 컨테이너
```bash
docker run -d -p 3000:3000 --name app image
docker ps -a
docker logs -f --tail 100 <container>
docker exec -it <container> sh
docker stats
docker top <container>
```

### Compose V2
```bash
docker compose up -d
docker compose up --watch       # 개발 모드
docker compose down -v          # 볼륨 포함 삭제
docker compose logs -f app
docker compose exec app sh
docker compose ps
docker compose config           # 설정 검증
docker compose pull             # 이미지 업데이트
```

### 정리
```bash
docker system prune -a --volumes
docker builder prune            # BuildKit 캐시 정리
```

## 프로덕션 체크리스트

```yaml
# docker-compose.prod.yml
services:
  app:
    image: myapp:${VERSION:-latest}
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
      restart_policy:
        condition: on-failure
        max_attempts: 3
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 출력 형식

```
## Docker Configuration

### Dockerfile
```dockerfile
# 최적화된 Dockerfile
```

### docker-compose.yml
```yaml
# 서비스 구성
```

### Commands
```bash
# 빌드 및 실행 명령어
```

### Optimization Notes
- 베이스 이미지: [선택 이유]
- 예상 이미지 크기: ~XXX MB
- 보안 고려사항: [적용된 보안 조치]
- 캐싱 전략: [캐시 최적화 방법]
```

---

요청에 맞는 Docker 설정을 생성하세요.
