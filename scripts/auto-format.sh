#!/bin/bash
# Auto Formatting - PostToolUse hook for Edit|Write
# Runs Prettier on the edited file when the project uses Prettier.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

file_path="$(hook_file_path)"

[[ -n "$file_path" && -f "$file_path" ]] || exit 0
[[ "$file_path" =~ \.(js|jsx|ts|tsx|json|css|scss|md|yaml|yml|html)$ ]] || exit 0
[[ "$file_path" =~ (node_modules|\.next|/dist/|/build/|\.git/) ]] && exit 0
command -v npx >/dev/null 2>&1 || exit 0

# Find project root: nearest dir with a prettier config or a package.json
# that lists prettier.
project_root=""
dir="$(dirname "$file_path")"
while [[ "$dir" != "/" && "$dir" != "." ]]; do
  if [[ -f "$dir/.prettierrc" || -f "$dir/.prettierrc.js" || -f "$dir/.prettierrc.json" ]] \
     || { [[ -f "$dir/package.json" ]] && grep -q '"prettier"' "$dir/package.json" 2>/dev/null; }; then
    project_root="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done
[[ -z "$project_root" ]] && exit 0

cd "$project_root" || exit 0
npx prettier --check "$file_path" >/dev/null 2>&1 && exit 0   # already formatted

if npx prettier --write "$file_path" >/dev/null 2>&1; then
  hook_emit_context PostToolUse "✨ [Format] Prettier reformatted $(basename "$file_path") on disk; re-read it before further edits."
fi
exit 0
