---
name: python-best-practices
description: Python 코드 리뷰 및 베스트 프랙티스 검증. 타입 힌트, 테스트, 린팅, 패키지 관리를 포함한 종합 분석.
---

# Python Best Practices Skill

## Purpose

Python 코드의 품질, 타입 안전성, 테스트 커버리지, 린팅 규칙 준수를 종합적으로 분석합니다.

## When to Use

- Python 코드 리뷰 요청 시 **자동 실행**
- `.py` 파일 분석 시
- FastAPI, Django, Flask 프로젝트 검토 시
- 패키지 의존성 검토 시

## Analysis Categories

### 1. Type Hints (25%)

**체크 항목**:
- 함수 파라미터 타입 힌트
- 반환 타입 명시
- 복잡한 타입 (Generic, Union, Optional)
- TypedDict, Protocol 사용

```python
# ❌ Bad
def get_user(id):
    return db.query(id)

# ✅ Good
def get_user(id: int) -> User | None:
    return db.query(id)
```

**검증 도구**: `mypy --strict`

### 2. Code Quality (25%)

**체크 항목**:
- PEP 8 스타일 준수
- 함수/클래스 복잡도
- Import 정리
- Docstring 존재

```python
# ❌ Bad
def f(x,y,z): return x+y+z

# ✅ Good
def calculate_sum(a: int, b: int, c: int) -> int:
    """Calculate the sum of three integers."""
    return a + b + c
```

**검증 도구**: `ruff check`, `ruff format --check`

### 3. Testing (20%)

**체크 항목**:
- 테스트 파일 존재 (`tests/`, `*_test.py`)
- 테스트 커버리지 (≥80% 권장)
- 픽스처 사용
- 모킹 패턴

```python
# ✅ Good test structure
def test_get_user_returns_user(db_session: Session):
    user = create_user(db_session, name="test")
    result = get_user(user.id)
    assert result.name == "test"

def test_get_user_returns_none_for_invalid_id():
    result = get_user(999999)
    assert result is None
```

**검증 도구**: `pytest --cov`

### 4. Security (15%)

**체크 항목**:
- SQL Injection 방지
- 하드코딩된 시크릿
- 안전하지 않은 deserialize
- 입력 검증

```python
# ❌ Bad
query = f"SELECT * FROM users WHERE id = {user_id}"

# ✅ Good
query = "SELECT * FROM users WHERE id = :id"
result = db.execute(query, {"id": user_id})
```

**검증 도구**: `bandit`

### 5. Dependencies (15%)

**필수 규칙**: **uv** 사용 (pip, poetry, pipenv 금지)

**체크 항목**:
- `pyproject.toml` (PEP 621 표준) 존재
- `uv.lock` 존재 및 커밋됨
- 버전 범위 적절히 지정 (`^`, `~`)
- 개발 의존성 그룹 분리

```toml
# ✅ Good pyproject.toml (PEP 621 / uv)
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[dependency-groups]
dev = [
    "pytest>=8.0",
    "mypy>=1.8",
    "ruff>=0.1",
]
```

```toml
# ❌ Bad - requirements.txt 또는 Poetry 형식 사용
[tool.poetry]
dependencies = {python = "^3.11"}

# ❌ Bad - poetry.lock 사용
```

**검증 도구**: `uv lock --check`, `uv sync --frozen`

**Docker 패턴**:
```dockerfile
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
```

---

## Output Format

### High Quality (≥90%)
```
📋 Python Best Practices Check:
   ✅ Type Hints: 95% coverage (mypy strict pass)
   ✅ Code Quality: A (ruff 0 errors)
   ✅ Testing: 87% coverage (42 tests)
   ✅ Security: No issues (bandit clean)
   ✅ Dependencies: All pinned, no vulnerabilities

📊 Score: 0.94 (94%)
✅ Production Ready
```

### Needs Improvement (70-89%)
```
📋 Python Best Practices Check:
   ✅ Type Hints: 78% coverage
   ⚠️  Code Quality: B (12 ruff warnings)
   ✅ Testing: 72% coverage
   ⚠️  Security: 2 low-severity issues
   ✅ Dependencies: OK

📊 Score: 0.76 (76%)
⚠️  Review Recommended

💡 개선 필요:
1. src/utils.py:45 - 타입 힌트 누락
2. src/api.py:120 - 복잡도 높음 (리팩토링 권장)
3. src/db.py:67 - SQL 문자열 포맷팅 주의
```

### Poor Quality (<70%)
```
📋 Python Best Practices Check:
   ❌ Type Hints: 32% coverage
   ❌ Code Quality: D (47 errors)
   ❌ Testing: 15% coverage (3 tests)
   ⚠️  Security: 5 issues
   ❌ Dependencies: Unpinned versions

📊 Score: 0.42 (42%)
❌ Not Ready for Review

🚨 Critical Issues:
1. Type safety 부족 - mypy 실행 불가
2. 테스트 커버리지 심각하게 낮음
3. requirements.txt 버전 미고정
```

---

## Verification Commands

```bash
# uv 환경에서 실행

# Type checking
uv run mypy --strict src/

# Linting & formatting
uv run ruff check src/
uv run ruff format --check src/

# Testing
uv run pytest --cov=src --cov-report=term-missing

# Security
uv run bandit -r src/

# Dependencies
uv lock --check        # lock 파일 동기화 확인
uv sync --frozen       # lock 파일 기반 설치 검증
uv pip list --outdated # 업데이트 가능한 패키지

# 가상환경 관리
uv venv                # 환경 정보/생성
uv sync                # 의존성 설치
uv lock --upgrade      # 의존성 업데이트
```

---

## Framework-Specific Checks

### FastAPI
```python
# ✅ Good patterns
from fastapi import Depends, HTTPException, status
from pydantic import BaseModel

class UserCreate(BaseModel):
    name: str
    email: EmailStr

@app.post("/users", response_model=UserResponse)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
) -> UserResponse:
    ...
```

**추가 체크**:
- Pydantic 모델 사용
- 의존성 주입 패턴
- 비동기 엔드포인트
- OpenAPI 문서화

### Django
```python
# ✅ Good patterns
from django.db import models
from django.core.validators import MinLengthValidator

class User(models.Model):
    name = models.CharField(max_length=100, validators=[MinLengthValidator(2)])
    email = models.EmailField(unique=True)

    class Meta:
        indexes = [models.Index(fields=['email'])]
```

**추가 체크**:
- 모델 인덱스
- 마이그레이션 상태
- 시큐리티 미들웨어
- CSRF 보호

---

## Integration with Other Skills

```
/confidence-check     → Python 프로젝트 아키텍처 확인
    │
    ▼
/python-best-practices → 코드 품질 분석
    │
    ▼
/verify               → 빌드/테스트 검증
    │
    ▼
/learn                → 패턴 저장
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/python-best-practices` | 전체 분석 |
| `/python-best-practices --quick` | 타입/린트만 |
| `/python-best-practices --security` | 보안 집중 |
| `/python-best-practices --deps` | 의존성 집중 |
