---
name: uv-package
description: Utilize uv package manager. Manage dependencies, virtual environments, project initialization, and lock files.
---

# uv Package Manager Skill

## Overview

Support Python package management and project setup using uv.

**uv**: Ultra-fast Python package and project manager written in Rust (by Astral)

## Basic Commands

### Project Initialization
```bash
# Create new project
uv init my-project

# Add uv to existing project
uv init

# Install dependencies
uv sync

# Create virtual environment (automatically managed)
uv venv
```

### Dependency Management
```bash
# Add package
uv add fastapi

# Add development dependency
uv add --dev pytest mypy ruff

# Add version constraint
uv add "fastapi>=0.100.0,<1.0.0"

# Remove package
uv remove requests

# Upgrade all dependencies
uv lock --upgrade

# Upgrade specific package only
uv lock --upgrade-package fastapi
```

### Lock File Management
```bash
# Create/update lock file
uv lock

# Install based on lock file (reproducible)
uv sync --frozen

# Verify lock file
uv lock --check
```

### Virtual Environment Management
```bash
# Environment information
uv venv

# Use specific Python version
uv venv --python 3.11

# Install Python version
uv python install 3.11
```

## Output Format

### On Dependency Addition
```
📦 Package Management
─────────────────────
✅ Added: fastapi (>=0.115.0)
📝 Updated: pyproject.toml
🔒 Lock File: uv.lock (updated)

Next: uv sync
```

### Conflict Resolution
```
⚠️ Dependency Conflict
─────────────────────
Package: urllib3
Required by:
  - requests (>=1.26.18,<2.0)
  - boto3 (>=1.26.0)

Resolution Options:
   1. uv add "urllib3>=1.26.18,<2.0"
   2. uv add "requests>=2.32.0" (urllib3 2.x support)

Recommended:
   uv add "urllib3>=1.26.18,<2.0" --locked
```

## pyproject.toml Templates

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

### pyproject.toml Integrated Configuration
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

## Workflows

### General Development Flow
```bash
# 1. Install dependencies
uv sync

# 2. Run code
uv run python main.py

# 3. Run tests
uv run pytest
uv run mypy src/
uv run ruff check src/

# 4. Commit after adding package
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

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Install dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Copy source
COPY . .

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

## Troubleshooting

### Frequently Used Diagnostic Commands
```bash
# Check dependency tree
uv tree

# Clean cache
uv cache clean

# Regenerate lock file
rm uv.lock && uv lock

# Recreate virtual environment
rm -rf .venv && uv sync

# Verify lock file sync
uv lock --check
```

### Dependency Groups
```toml
[dependency-groups]
dev = ["pytest>=8.0", "mypy>=1.8"]    # Development
test = ["pytest>=8.0", "coverage>=7"]  # Testing
docs = ["sphinx>=7.0", "furo>=2024"]   # Documentation
```

## Quick Reference

| Command | Description |
|---------|-------------|
| `uv init` | Initialize project |
| `uv add [pkg]` | Add package |
| `uv sync` | Install dependencies |
| `uv lock --upgrade` | Update dependencies |
| `uv tree` | Dependency tree |
| `uv lock --check` | Validate configuration |
