---
name: pytest-runner
description: pytest 기반 테스트 실행 및 분석. 커버리지 리포트, 실패 분석, 픽스처 디버깅 포함.
---

# Pytest Runner Skill

## Purpose

Python 프로젝트의 테스트를 실행하고 결과를 분석합니다.

## When to Use

- Python 테스트 실행 요청 시 **자동 실행**
- "테스트 돌려줘", "pytest", "test" 키워드 감지 시
- CI/CD 전 로컬 테스트 검증

## Execution Modes

### 1. Quick Test
```bash
pytest -x -q
# 첫 번째 실패 시 중단, 간단한 출력
```

### 2. Full Test with Coverage
```bash
pytest --cov=src --cov-report=term-missing --cov-report=html
# 전체 테스트 + 커버리지 리포트
```

### 3. Specific Test
```bash
pytest tests/test_api.py::test_create_user -v
# 특정 테스트만 실행
```

### 4. Failed Only
```bash
pytest --lf
# 마지막 실패한 테스트만 재실행
```

---

## Output Format

### All Pass
```
🧪 PYTEST RESULTS
=================

✅ All tests passed!

📊 Summary:
   Tests: 47 passed
   Time: 3.2s
   Coverage: 87%

📈 Coverage by Module:
   src/api.py        92%
   src/models.py     95%
   src/utils.py      78%  ⚠️
   src/db.py         85%
```

### With Failures
```
🧪 PYTEST RESULTS
=================

❌ 3 tests failed

📊 Summary:
   Tests: 44 passed, 3 failed
   Time: 4.1s

🔴 Failures:

1. test_api.py::test_create_user_invalid_email
   ├─ Expected: ValidationError
   └─ Got: None

   💡 Fix: 이메일 검증 로직 확인 필요
   📍 Location: src/api.py:45

2. test_db.py::test_connection_timeout
   ├─ Expected: TimeoutError after 5s
   └─ Got: Hung indefinitely

   💡 Fix: DB 연결 타임아웃 설정 확인

3. test_utils.py::test_parse_date
   ├─ Expected: datetime(2024, 1, 15)
   └─ Got: ValueError

   💡 Fix: 날짜 포맷 파싱 로직 확인
```

---

## Coverage Analysis

### Minimum Thresholds
```yaml
coverage:
  minimum: 80%      # 전체 최소
  critical_paths:
    - src/api.py: 90%
    - src/auth.py: 95%
    - src/models.py: 85%
```

### Uncovered Lines Report
```
📋 Uncovered Code:

src/utils.py (78% covered):
   Lines 45-52: Error handling branch
   Lines 78-85: Edge case for empty input

   💡 테스트 추가 필요:
   - test_parse_with_empty_input()
   - test_parse_with_invalid_format()
```

---

## Fixture Analysis

### Fixture Dependencies
```
📦 Fixture Graph:

db_session
  └─→ test_user
      └─→ authenticated_client
          └─→ admin_client

⚠️  Warning: Deep fixture chain (4 levels)
    → 테스트 격리 확인 필요
```

### Slow Fixtures
```
⏱️  Slow Fixtures:

| Fixture | Avg Time | Usage |
|---------|----------|-------|
| db_session | 0.8s | 32 tests |
| redis_client | 0.5s | 12 tests |
| mock_api | 0.3s | 8 tests |

💡 Optimization: db_session을 module scope로 변경 고려
```

---

## Integration

```bash
# Pre-commit hook
pytest --co -q && pytest -x

# CI pipeline
pytest --cov --cov-fail-under=80 --junitxml=report.xml

# Watch mode (with pytest-watch)
ptw -- --lf
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/pytest` | 전체 테스트 실행 |
| `/pytest --quick` | 빠른 테스트 (-x -q) |
| `/pytest --cov` | 커버리지 포함 |
| `/pytest --failed` | 실패한 것만 재실행 |
| `/pytest [path]` | 특정 경로만 실행 |
