#!/bin/bash
# Project Checklist - Priority-based validation runner
# MCP 서버 없는 환경에서 /verify, /audit의 fallback으로 사용
# Inspired by Antigravity Kit's checklist.py pattern
#
# Usage:
#   bash scripts/checklist.sh [project-path]
#   bash scripts/checklist.sh .
#   bash scripts/checklist.sh . --quick    # P0-P1 only

set -euo pipefail

PROJECT_PATH="${1:-.}"
QUICK_MODE="${2:-}"
PASS=0
FAIL=0
SKIP=0
WARNINGS=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo -e "\n${BOLD}${CYAN}════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  Project Checklist${NC}"
  echo -e "${BOLD}${CYAN}════════════════════════════════════════${NC}\n"
}

run_check() {
  local priority="$1"
  local name="$2"
  local cmd="$3"

  echo -ne "  ${priority} ${name}... "

  if eval "$cmd" > /dev/null 2>&1; then
    echo -e "${GREEN}✅${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}❌${NC}"
    FAIL=$((FAIL + 1))
  fi
}

skip_check() {
  local priority="$1"
  local name="$2"
  local reason="$3"

  echo -e "  ${priority} ${name}... ${YELLOW}⏭ ${reason}${NC}"
  SKIP=$((SKIP + 1))
}

print_header

cd "$PROJECT_PATH"

# ═══════════════════════════════════════
# P0: Security (always run)
# ═══════════════════════════════════════
echo -e "${BOLD}P0: Security${NC}"

# Check for hardcoded secrets
if grep -rqE '(password|secret|api_key|apikey|token)\s*=\s*["\x27][^"\x27]{8,}' \
  --include="*.py" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" \
  --include="*.env" --include="*.yaml" --include="*.yml" --include="*.json" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=__pycache__ \
  --exclude-dir=.venv --exclude="*.lock" --exclude="package-lock.json" \
  --exclude="pnpm-lock.yaml" . 2>/dev/null; then
  echo -e "  P0 Hardcoded secrets... ${RED}❌ 의심되는 패턴 발견${NC}"
  FAIL=$((FAIL + 1))
else
  echo -e "  P0 Hardcoded secrets... ${GREEN}✅${NC}"
  PASS=$((PASS + 1))
fi

# Check .env in .gitignore
if [[ -f .gitignore ]]; then
  if grep -qE '^\s*\.env' .gitignore 2>/dev/null; then
    echo -e "  P0 .env in .gitignore... ${GREEN}✅${NC}"
    PASS=$((PASS + 1))
  else
    if ls .env* > /dev/null 2>&1; then
      echo -e "  P0 .env in .gitignore... ${RED}❌ .env 파일 존재하나 .gitignore에 없음${NC}"
      FAIL=$((FAIL + 1))
    else
      skip_check "P0" ".env in .gitignore" ".env 파일 없음"
    fi
  fi
else
  skip_check "P0" ".env in .gitignore" ".gitignore 없음"
fi

# ═══════════════════════════════════════
# P1: Code Quality (always run)
# ═══════════════════════════════════════
echo -e "\n${BOLD}P1: Code Quality${NC}"

# TypeScript check
if [[ -f tsconfig.json ]]; then
  run_check "P1" "TypeScript" "npx tsc --noEmit 2>&1"
else
  skip_check "P1" "TypeScript" "tsconfig.json 없음"
fi

# ESLint check
if [[ -f .eslintrc.js ]] || [[ -f .eslintrc.json ]] || [[ -f .eslintrc.cjs ]] || [[ -f eslint.config.mjs ]] || [[ -f eslint.config.js ]]; then
  run_check "P1" "ESLint" "npx eslint . --max-warnings 0 2>&1"
else
  skip_check "P1" "ESLint" "ESLint 설정 없음"
fi

# Python: ruff check
if [[ -f pyproject.toml ]] && command -v ruff &> /dev/null; then
  run_check "P1" "Ruff (Python)" "ruff check . 2>&1"
elif [[ -f pyproject.toml ]]; then
  skip_check "P1" "Ruff (Python)" "ruff 미설치"
fi

# Python: mypy check
if [[ -f pyproject.toml ]] && command -v mypy &> /dev/null; then
  run_check "P1" "Mypy (Python)" "mypy . 2>&1"
elif [[ -f pyproject.toml ]]; then
  skip_check "P1" "Mypy (Python)" "mypy 미설치"
fi

# Quick mode stops here
if [[ "$QUICK_MODE" == "--quick" ]]; then
  echo -e "\n${YELLOW}(--quick 모드: P0-P1만 실행)${NC}"
else

# ═══════════════════════════════════════
# P2: Tests
# ═══════════════════════════════════════
echo -e "\n${BOLD}P2: Tests${NC}"

# Jest/Vitest
if [[ -f package.json ]]; then
  if grep -qE '"(jest|vitest)"' package.json 2>/dev/null || [[ -f vitest.config.ts ]] || [[ -f jest.config.ts ]] || [[ -f jest.config.js ]]; then
    run_check "P2" "Tests (JS/TS)" "npx --no-install vitest run 2>&1 || npx --no-install jest 2>&1"
  else
    skip_check "P2" "Tests (JS/TS)" "테스트 프레임워크 없음"
  fi
fi

# Pytest
if [[ -f pyproject.toml ]] && command -v pytest &> /dev/null; then
  run_check "P2" "Tests (Python)" "pytest --tb=short -q 2>&1"
elif [[ -f pyproject.toml ]]; then
  skip_check "P2" "Tests (Python)" "pytest 미설치"
fi

# ═══════════════════════════════════════
# P3: Build
# ═══════════════════════════════════════
echo -e "\n${BOLD}P3: Build${NC}"

if [[ -f package.json ]] && grep -q '"build"' package.json 2>/dev/null; then
  run_check "P3" "Build" "npm run build 2>&1"
else
  skip_check "P3" "Build" "build 스크립트 없음"
fi

# ═══════════════════════════════════════
# P4: Lock files
# ═══════════════════════════════════════
echo -e "\n${BOLD}P4: Dependency Hygiene${NC}"

if [[ -f package.json ]]; then
  if [[ -f pnpm-lock.yaml ]]; then
    echo -e "  P4 Lock file (pnpm)... ${GREEN}✅${NC}"
    PASS=$((PASS + 1))
  elif [[ -f package-lock.json ]]; then
    echo -e "  P4 Lock file (npm)... ${YELLOW}⚠️ pnpm 권장${NC}"
    PASS=$((PASS + 1))
    WARNINGS+="  ⚠️ npm 대신 pnpm 사용 권장\n"
  else
    echo -e "  P4 Lock file... ${RED}❌ lock 파일 없음${NC}"
    FAIL=$((FAIL + 1))
  fi
fi

if [[ -f pyproject.toml ]]; then
  if [[ -f uv.lock ]]; then
    echo -e "  P4 Lock file (uv)... ${GREEN}✅${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "  P4 Lock file (uv)... ${RED}❌ uv.lock 없음${NC}"
    FAIL=$((FAIL + 1))
  fi
fi

fi # end of non-quick mode

# ═══════════════════════════════════════
# Summary
# ═══════════════════════════════════════
echo -e "\n${BOLD}${CYAN}────────────────────────────────────────${NC}"
TOTAL=$((PASS + FAIL + SKIP))
echo -e "  ${GREEN}✅ Pass: $PASS${NC}  ${RED}❌ Fail: $FAIL${NC}  ${YELLOW}⏭ Skip: $SKIP${NC}  Total: $TOTAL"

if [[ -n "$WARNINGS" ]]; then
  echo -e "\n${YELLOW}Warnings:${NC}"
  echo -e "$WARNINGS"
fi

if [[ $FAIL -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}❌ $FAIL check(s) failed${NC}"
  exit 1
else
  echo -e "\n${GREEN}${BOLD}✅ All checks passed${NC}"
  exit 0
fi
