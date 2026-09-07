#!/bin/bash
# Auto Type Check - PostToolUse hook for Edit|Write
# Runs tsc on the project of an edited .ts/.tsx file and reports errors
# for that file back to Claude as additionalContext.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

file_path="$(hook_file_path)"

[[ "$file_path" =~ \.(ts|tsx)$ ]] || exit 0
[[ "$file_path" =~ (\.test\.|\.spec\.|__tests__|node_modules) ]] && exit 0
[[ -f "$file_path" ]] || exit 0
command -v npx >/dev/null 2>&1 || exit 0

# Find project root (nearest tsconfig.json)
project_root=""
dir="$(dirname "$file_path")"
while [[ "$dir" != "/" && "$dir" != "." ]]; do
  if [[ -f "$dir/tsconfig.json" ]]; then
    project_root="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done
[[ -z "$project_root" ]] && exit 0

# tsc --pretty false prints paths relative to the project root:
#   src/foo.ts(12,5): error TS2322: ...
cd "$project_root" || exit 0
rel_path="${file_path#"$project_root"/}"
errors="$(npx tsc --noEmit --pretty false 2>&1 | grep -F "${rel_path}(" | head -5 || true)"

[[ -z "$errors" ]] && exit 0

hook_emit_context PostToolUse "⚠️ [TypeCheck] Type errors in ${rel_path}:
${errors}"
exit 0
