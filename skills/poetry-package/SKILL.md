---
name: poetry-package
description: Poetry 패키지 매니저 활용. 의존성 관리, 가상환경 관리, 프로젝트 초기화, lock 파일 관리.
---

# Poetry Package Manager Skill

## Purpose

Poetry를 사용한 Python 패키지 관리 및 프로젝트 설정을 지원합니다.

**Poetry**: Python 의존성 관리 및 패키징을 위한 현대적 도구

## When to Use

- Python 프로젝트 초기화
- 의존성 설치/업데이트
- 가상환경 관리
- 패키지 버전 충돌 해결
- 패키지 배포 준비

## Core Commands

### Project Initialization
```bash
# 새 프로젝트 생성
poetry new my-project
cd my-project

# 기존 프로젝트에 poetry 추가
poetry init

# 가상환경 생성 및 의존성 설치
poetry install

# 가상환경 활성화
poetry shell
```

### Dependency Management
```bash
# 패키지 추가
poetry add fastapi

# 개발 의존성 추가
poetry add --group dev pytest mypy ruff

# 특정 버전 추가
poetry add "fastapi>=0.100.0,<1.0.0"

# 패키지 제거
poetry remove requests

# 의존성 업데이트
poetry update

# 특정 패키지만 업데이트
poetry update fastapi
```

### Lock File Management
```bash
# lock 파일 생성/업데이트
poetry lock

# lock 파일 없이 설치 (비권장)
poetry install --no-lock

# 정확한 버전으로 설치
poetry install --sync
```

### Environment Management
```bash
# 가상환경 정보
poetry env info

# 가상환경 목록
poetry env list

# 특정 Python 버전 사용
poetry env use python3.11

# 가상환경 삭제
poetry env remove python3.11
```

---

## Output Format

### Installation Success
```
📦 POETRY PACKAGE INSTALLATION
==============================

✅ Installed 15 packages

📋 Added:
   fastapi      0.109.0
   pydantic     2.5.3
   uvicorn      0.27.0
   starlette    0.35.1
   ... +11 dependencies

📁 Virtual Environment: .venv
🔒 Lock File: poetry.lock (updated)
```

### Dependency Conflict
```
📦 POETRY DEPENDENCY RESOLUTION
===============================

❌ Dependency conflict detected!

🔴 Conflict:
   requests (>=2.28) requires urllib3<2.0
   boto3 (>=1.34) requires urllib3>=2.0

💡 Solutions:
   1. poetry add "urllib3>=1.26.18,<2.0"
   2. poetry add "requests>=2.32.0" (urllib3 2.x 지원)
   3. 별도 환경에서 분리 실행

Recommended:
   poetry add "urllib3>=1.26.18,<2.0" --lock
```

---

## Project Templates

### pyproject.toml (FastAPI)
```toml
[tool.poetry]
name = "my-api"
version = "0.1.0"
description = "FastAPI Application"
authors = ["Your Name <you@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.109.0"
uvicorn = {extras = ["standard"], version = "^0.27.0"}
pydantic = "^2.5.0"
sqlalchemy = "^2.0.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-cov = "^4.1.0"
pytest-asyncio = "^0.23.0"
mypy = "^1.8.0"
ruff = "^0.1.14"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### pyproject.toml (Django)
```toml
[tool.poetry]
name = "my-django"
version = "0.1.0"
description = "Django Application"
authors = ["Your Name <you@example.com>"]

[tool.poetry.dependencies]
python = "^3.11"
django = "^5.0"
psycopg = {extras = ["binary"], version = "^3.1.0"}
django-environ = "^0.11.0"
gunicorn = "^21.0.0"

[tool.poetry.group.dev.dependencies]
pytest-django = "^4.7.0"
factory-boy = "^3.3.0"
django-debug-toolbar = "^4.2.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

---

## Tool Configuration

### pyproject.toml 통합 설정
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
asyncio_mode = "auto"

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true

[tool.ruff]
line-length = 88
target-version = "py311"
select = ["E", "F", "I", "N", "W", "UP"]

[tool.ruff.isort]
known-first-party = ["my_package"]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "*/__pycache__/*"]

[tool.coverage.report]
fail_under = 80
```

---

## Workflow Integration

### Development Workflow
```bash
# 1. 프로젝트 클론 후
git clone repo && cd repo
poetry install

# 2. 개발 환경 진입
poetry shell

# 3. 코드 작성 후 검증
poetry run pytest
poetry run mypy src/
poetry run ruff check src/

# 4. 새 의존성 추가 시
poetry add new-package
git add pyproject.toml poetry.lock
git commit -m "chore: add new-package"
```

### CI/CD Integration
```yaml
# GitHub Actions
- name: Install Poetry
  uses: snok/install-poetry@v1
  with:
    version: 1.7.1

- name: Install dependencies
  run: poetry install --no-interaction

- name: Run tests
  run: poetry run pytest --cov

- name: Type check
  run: poetry run mypy src/
```

### Docker Integration
```dockerfile
FROM python:3.11-slim

# Poetry 설치
RUN pip install poetry

WORKDIR /app

# 의존성 파일 복사
COPY pyproject.toml poetry.lock ./

# 가상환경 생성 안 함 (컨테이너 자체가 격리)
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --only main

COPY . .
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

---

## Troubleshooting

### Common Issues

**1. "Package not found"**
```bash
# PyPI 확인
poetry search package-name

# 대체 소스 추가
poetry source add private https://private.pypi.org/simple/
```

**2. "Version solving failed"**
```bash
# 의존성 트리 확인
poetry show --tree

# 캐시 클리어
poetry cache clear pypi --all

# lock 파일 재생성
rm poetry.lock && poetry lock
```

**3. "Virtual environment not found"**
```bash
# 환경 재생성
poetry env remove python
poetry install
```

**4. "Hash mismatch"**
```bash
# lock 파일 업데이트
poetry lock --no-update
```

---

## Best Practices

### Version Constraints
```toml
# ✅ Good - 유연하면서 안전
fastapi = "^0.109.0"      # >=0.109.0,<0.110.0
pydantic = "~2.5.0"       # >=2.5.0,<2.6.0

# ⚠️ Careful - 너무 느슨함
requests = "*"            # 어떤 버전이든

# ✅ Good - 정확한 제어 필요시
numpy = "1.26.3"          # 정확히 이 버전
```

### Group Organization
```toml
[tool.poetry.group.dev.dependencies]    # 개발용
[tool.poetry.group.test.dependencies]   # 테스트용
[tool.poetry.group.docs.dependencies]   # 문서용
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/poetry init` | 프로젝트 초기화 |
| `/poetry add [pkg]` | 패키지 추가 |
| `/poetry install` | 의존성 설치 |
| `/poetry update` | 의존성 업데이트 |
| `/poetry show --tree` | 의존성 트리 |
| `/poetry check` | 설정 검증 |
