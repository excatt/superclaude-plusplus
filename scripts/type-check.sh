#!/bin/bash
# Auto Type Check - PostToolUse hook for Edit operations
# Runs TypeScript compiler on edited .ts/.tsx files

set -e

# Get the edited file from hook context
file_path="${CLAUDE_FILE_PATH:-}"

# Skip if not a TypeScript file
if [[ ! "$file_path" =~ \.(ts|tsx)$ ]]; then
  exit 0
fi

# Skip test files and node_modules
if [[ "$file_path" =~ (\.test\.|\.spec\.|__tests__|node_modules) ]]; then
  exit 0
fi

# Check if tsc is available
if ! command -v npx &> /dev/null; then
  exit 0
fi

# Find project root (look for tsconfig.json)
dir=$(dirname "$file_path")
while [[ "$dir" != "/" ]]; do
  if [[ -f "$dir/tsconfig.json" ]]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

if [[ -z "$project_root" ]]; then
  exit 0
fi

# Run type check on the specific file
cd "$project_root"
errors=$(npx tsc --noEmit --pretty false 2>&1 | grep -E "^${file_path}" | head -5 || true)

if [[ -n "$errors" ]]; then
  echo "⚠️  [TypeCheck] Type errors in $(basename "$file_path"):" >&2
  echo "$errors" | while read -r line; do
    echo "   $line" >&2
  done
fi
