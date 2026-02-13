---
name: uv-package
description: uv 패키지 매니저 활용. 의존성 관리, 가상환경 관리, 프로젝트 초기화, lock 파일 관리.
---

# uv Package Manager Skill

## 개요

uv를 사용한 Python 패키지 관리 및 프로젝트 설정을 지원합니다.

**uv**: Rust로 작성된 초고속 Python 패키지 및 프로젝트 매니저 (by Astral)

## 기본 명령어

### 프로젝트 초기화
```bash
# 새 프로젝트 생성
uv init my-project

# 기존 프로젝트에 uv 추가
uv init

# 의존성 설치
uv sync

# 가상환경 생성 (자동으로 관리됨)
uv venv
```

### 의존성 관리
```bash
# 패키지 추가
uv add fastapi

# 개발 의존성 추가
uv add --dev pytest mypy ruff

# 버전 제약 추가
uv add "fastapi>=0.100.0,<1.0.0"

# 패키지 제거
uv remove requests

# 전체 의존성 업그레이드
uv lock --upgrade

# 특정 패키지만 업그레이드
uv lock --upgrade-package fastapi
```

### Lock 파일 관리
```bash
# lock 파일 생성/업데이트
uv lock

# lock 파일 기반 설치 (재현 가능)
uv sync --frozen

# lock 파일 검증
uv lock --check
```

### 가상환경 관리
```bash
# 환경 정보
uv venv

# 특정 Python 버전 사용
uv venv --python 3.11

# Python 버전 설치
uv python install 3.11
```

## 출력 형식

### 의존성 추가 시
```
📦 Package Management
─────────────────────
✅ Added: fastapi (>=0.115.0)
📝 Updated: pyproject.toml
🔒 Lock File: uv.lock (updated)

Next: uv sync
```

### 충돌 해결
```
⚠️ Dependency Conflict
─────────────────────
Package: urllib3
Required by:
  - requests (>=1.26.18,<2.0)
  - boto3 (>=1.26.0)

Resolution Options:
   1. uv add "urllib3>=1.26.18,<2.0"
   2. uv add "requests>=2.32.0" (urllib3 2.x 지원)

Recommended:
   uv add "urllib3>=1.26.18,<2.0" --locked
```

## pyproject.toml 템플릿

### pyproject.toml (FastAPI)
```toml
[project]
name = "my-api"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "sqlalchemy>=2.0",
    "alembic>=1.13",
    "pydantic>=2.0",
    "httpx>=0.27.0",
]

[dependency-groups]
dev = [
    "pytest>=8.0",
    "pytest-asyncio>=0.24",
    "mypy>=1.8",
    "ruff>=0.8",
    "coverage>=7.4",
]
```

### pyproject.toml (Django)
```toml
[project]
name = "my-webapp"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "django>=5.0",
    "django-rest-framework>=3.15",
    "psycopg[binary]>=3.1",
    "django-cors-headers>=4.3",
    "celery>=5.3",
    "redis>=5.0",
]

[dependency-groups]
dev = [
    "pytest>=8.0",
    "pytest-django>=4.8",
    "mypy>=1.8",
    "ruff>=0.8",
    "django-stubs>=5.0",
]
```

### pyproject.toml 통합 설정
```toml
[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP"]

[tool.mypy]
python_version = "3.11"
strict = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
```

## 워크플로우

### 일반 개발 플로우
```bash
# 1. 의존성 설치
uv sync

# 2. 코드 실행
uv run python main.py

# 3. 테스트 실행
uv run pytest
uv run mypy src/
uv run ruff check src/

# 4. 패키지 추가 후 커밋
uv add new-package
git add pyproject.toml uv.lock
git commit -m "deps: add new-package"
```

### CI/CD (GitHub Actions)
```yaml
- uses: astral-sh/setup-uv@v5
  with:
    version: "latest"

- name: Install dependencies
  run: uv sync --frozen

- name: Run tests
  run: uv run pytest --cov

- name: Type check
  run: uv run mypy src/
```

### Docker
```dockerfile
FROM python:3.11-slim

# uv 설치
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# 의존성 설치
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# 소스 복사
COPY . .

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

## 트러블슈팅

### 자주 쓰는 진단 명령
```bash
# 의존성 트리 확인
uv tree

# 캐시 정리
uv cache clean

# lock 파일 재생성
rm uv.lock && uv lock

# 가상환경 재생성
rm -rf .venv && uv sync

# lock 파일 동기화 확인
uv lock --check
```

### Dependency Groups
```toml
[dependency-groups]
dev = ["pytest>=8.0", "mypy>=1.8"]    # 개발용
test = ["pytest>=8.0", "coverage>=7"]  # 테스트용
docs = ["sphinx>=7.0", "furo>=2024"]   # 문서용
```

## 퀵 레퍼런스

| 명령 | 설명 |
|------|------|
| `uv init` | 프로젝트 초기화 |
| `uv add [pkg]` | 패키지 추가 |
| `uv sync` | 의존성 설치 |
| `uv lock --upgrade` | 의존성 업데이트 |
| `uv tree` | 의존성 트리 |
| `uv lock --check` | 설정 검증 |
