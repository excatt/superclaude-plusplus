#!/bin/bash
# Console.log Detection - PostToolUse hook for Edit operations
# Warns about debug statements in source code

set -e

# Get the edited file from hook context
file_path="${CLAUDE_FILE_PATH:-}"

# Skip if empty
if [[ -z "$file_path" ]] || [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Skip test files, config files, and node_modules
if [[ "$file_path" =~ (\.test\.|\.spec\.|__tests__|node_modules|\.config\.|jest\.|vite\.|next\.config) ]]; then
  exit 0
fi

# Check for JavaScript/TypeScript files
if [[ ! "$file_path" =~ \.(js|jsx|ts|tsx)$ ]]; then
  exit 0
fi

# Find console.log/debug statements
matches=$(grep -n "console\.\(log\|debug\|info\|warn\|error\)" "$file_path" 2>/dev/null | grep -v "// eslint-disable" | grep -v "// noqa" | head -3 || true)

if [[ -n "$matches" ]]; then
  count=$(echo "$matches" | wc -l | tr -d ' ')
  echo "⚠️  [Debug] Found $count console statement(s) in $(basename "$file_path"):" >&2
  echo "$matches" | while read -r line; do
    echo "   $line" >&2
  done
  echo "   💡 Consider removing before commit" >&2
fi
