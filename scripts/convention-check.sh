#!/bin/bash
# Convention Check Hook
# Checks naming conventions based on CONVENTIONS.md

FILE_PATH="${CLAUDE_FILE_PATH:-}"

# Exit if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Exit if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Get file extension
EXT="${FILE_PATH##*.}"

warnings=""

case "$EXT" in
  py)
    # Python: Check for camelCase variables/functions (should be snake_case)
    # Look for patterns like: def getUserData or myVariable =
    if grep -qE '\bdef [a-z]+[A-Z][a-zA-Z]*\(' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ Python 함수명은 snake_case 사용 권장 (camelCase 감지)\n"
    fi

    # Check for camelCase in variable assignments (excluding class attributes and dict keys)
    if grep -qE '^\s+[a-z]+[A-Z][a-zA-Z]* =' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ Python 변수명은 snake_case 사용 권장 (camelCase 감지)\n"
    fi

    # Check test file naming (should be test_*.py)
    filename=$(basename "$FILE_PATH" .py)
    if grep -qE '\b(def test_|class Test|pytest|unittest)' "$FILE_PATH" 2>/dev/null; then
      if [[ ! "$filename" =~ ^test_ ]] && [[ ! "$filename" =~ _test$ ]]; then
        warnings+="⚠️ Python 테스트 파일명은 test_*.py 사용 권장\n"
      fi
    fi

    # Check test class naming (should be TestXxx)
    if grep -qE 'class [A-Z][a-zA-Z]*Test[^a-zA-Z]' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ Python 테스트 클래스명은 Test prefix 사용 권장 (예: TestUserService)\n"
    fi
    ;;

  ts|tsx|js|jsx)
    # TypeScript/JavaScript: Check for snake_case variables/functions (should be camelCase)
    # Look for patterns like: const user_data or function get_user
    if grep -qE '\b(const|let|var|function) [a-z]+_[a-z]+' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ TypeScript 변수/함수명은 camelCase 사용 권장 (snake_case 감지)\n"
    fi

    # Check interface/type names (should be PascalCase)
    if grep -qE '\b(interface|type) [a-z][a-zA-Z]*[_][a-zA-Z]*' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ TypeScript interface/type은 PascalCase 사용 권장\n"
    fi

    # Check component file naming (should be PascalCase for .tsx)
    if [[ "$EXT" == "tsx" ]]; then
      filename=$(basename "$FILE_PATH" .tsx)
      if [[ "$filename" =~ ^[a-z] ]] && [[ ! "$filename" =~ ^use[A-Z] ]]; then
        # Lowercase start but not a hook (useXxx)
        if [[ "$filename" =~ _ ]]; then
          warnings+="⚠️ React 컴포넌트 파일명은 PascalCase 사용 권장: $filename.tsx\n"
        fi
      fi
    fi

    # Check React hook file naming (should be useXxx.ts)
    if [[ "$EXT" == "ts" || "$EXT" == "tsx" ]]; then
      filename=$(basename "$FILE_PATH" ".$EXT")
      # If file contains "export function use" or "export const use", it's likely a hook
      if grep -qE 'export (function|const) use[A-Z]' "$FILE_PATH" 2>/dev/null; then
        if [[ ! "$filename" =~ ^use[A-Z] ]]; then
          warnings+="⚠️ React 훅 파일명은 use prefix 사용 권장: use*.ts\n"
        fi
      fi
    fi

    # Check test file naming
    filename=$(basename "$FILE_PATH")
    if grep -qE '\b(describe|it|test|expect)\(' "$FILE_PATH" 2>/dev/null; then
      if [[ ! "$filename" =~ \.(test|spec)\.(ts|tsx|js|jsx)$ ]]; then
        warnings+="⚠️ 테스트 파일명은 *.test.ts 또는 *.spec.ts 사용 권장\n"
      fi
    fi
    ;;

  sql)
    # SQL: Check for camelCase (should be snake_case)
    if grep -qiE 'CREATE TABLE [a-z]+[A-Z]' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ SQL 테이블명은 snake_case 사용 권장\n"
    fi
    ;;

  css)
    # CSS: Check for camelCase class names (should be kebab-case)
    if grep -qE '\.[a-z]+[A-Z][a-zA-Z]*\s*\{' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ CSS 클래스명은 kebab-case 사용 권장 (camelCase 감지)\n"
    fi

    # Check for snake_case class names (should be kebab-case)
    if grep -qE '\.[a-z]+_[a-z]+\s*\{' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ CSS 클래스명은 kebab-case 사용 권장 (snake_case 감지)\n"
    fi

    # Check CSS variable naming (should be --kebab-case)
    if grep -qE '--[a-z]+[A-Z]' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ CSS 변수명은 --kebab-case 사용 권장\n"
    fi
    ;;

  scss|sass)
    # SCSS: Check for camelCase class names
    if grep -qE '\.[a-z]+[A-Z][a-zA-Z]*\s*\{' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ SCSS 클래스명은 kebab-case 사용 권장 (camelCase 감지)\n"
    fi

    # Check SCSS variable naming (should be $kebab-case)
    if grep -qE '\$[a-z]+[A-Z]' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ SCSS 변수명은 \$kebab-case 사용 권장\n"
    fi

    # Check SCSS variable with snake_case
    if grep -qE '\$[a-z]+_[a-z]+' "$FILE_PATH" 2>/dev/null; then
      warnings+="⚠️ SCSS 변수명은 \$kebab-case 사용 권장 (snake_case 감지)\n"
    fi
    ;;
esac

# Output warnings if any
if [[ -n "$warnings" ]]; then
  echo -e "\n📋 Convention Check ($FILE_PATH):"
  echo -e "$warnings"
  echo "📖 참고: ~/.claude/CONVENTIONS.md"
fi

exit 0
