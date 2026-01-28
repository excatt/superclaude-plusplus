#!/bin/bash
# Auto Formatting - PostToolUse hook for Edit operations
# Runs Prettier on edited files

set -e

# Get the edited file from hook context
file_path="${CLAUDE_FILE_PATH:-}"

# Skip if empty or doesn't exist
if [[ -z "$file_path" ]] || [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Skip non-formattable files
if [[ ! "$file_path" =~ \.(js|jsx|ts|tsx|json|css|scss|md|yaml|yml|html)$ ]]; then
  exit 0
fi

# Skip node_modules and build directories
if [[ "$file_path" =~ (node_modules|\.next|dist|build|\.git) ]]; then
  exit 0
fi

# Find project root (look for package.json with prettier)
dir=$(dirname "$file_path")
project_root=""
while [[ "$dir" != "/" ]]; do
  if [[ -f "$dir/package.json" ]]; then
    # Check if prettier is a dependency
    if grep -q '"prettier"' "$dir/package.json" 2>/dev/null; then
      project_root="$dir"
      break
    fi
  fi
  if [[ -f "$dir/.prettierrc" ]] || [[ -f "$dir/.prettierrc.js" ]] || [[ -f "$dir/.prettierrc.json" ]]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

# Exit if no prettier config found
if [[ -z "$project_root" ]]; then
  exit 0
fi

# Check if npx is available
if ! command -v npx &> /dev/null; then
  exit 0
fi

# Run prettier
cd "$project_root"
if npx prettier --check "$file_path" &>/dev/null; then
  exit 0  # Already formatted
fi

# Format the file
if npx prettier --write "$file_path" &>/dev/null; then
  echo "✨ [Format] Auto-formatted $(basename "$file_path")" >&2
fi
