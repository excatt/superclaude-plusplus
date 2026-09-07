#!/bin/bash
# Console.log Detection - PostToolUse hook for Edit|Write
# Warns Claude about debug statements left in JS/TS source files.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

file_path="$(hook_file_path)"

[[ -n "$file_path" && -f "$file_path" ]] || exit 0
[[ "$file_path" =~ (\.test\.|\.spec\.|__tests__|node_modules|\.config\.|jest\.|vite\.|next\.config) ]] && exit 0
[[ "$file_path" =~ \.(js|jsx|ts|tsx)$ ]] || exit 0

matches="$(grep -n 'console\.\(log\|debug\|info\|warn\|error\)' "$file_path" 2>/dev/null \
  | grep -v '// eslint-disable' | grep -v '// noqa' | head -3 || true)"

[[ -z "$matches" ]] && exit 0

count="$(printf '%s\n' "$matches" | wc -l | tr -d ' ')"
hook_emit_context PostToolUse "⚠️ [Debug] ${count} console statement(s) in $(basename "$file_path") — consider removing before commit:
${matches}"
exit 0
