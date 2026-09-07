#!/usr/bin/env bash
# Circuit Breaker for Claude Code Stop hook
# Detects repeated error patterns in the assistant's final message and
# blocks the stop when the same error appears THRESHOLD times within
# WINDOW_SECONDS for this session. Diagnosis only — no auto-fix.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

WINDOW_SECONDS=600  # 10 minutes
THRESHOLD=3
MAX_KEY_LEN=200

hook_read_input
[[ -z "$HOOK_INPUT" ]] && exit 0

# Never re-block while Claude is already continuing from a blocked stop —
# the same pattern would still match and we would loop forever.
if hook_stop_hook_active; then
  exit 0
fi

session_id="$(hook_session_id)"

# Analyse only the assistant's last message, not the whole JSON envelope
# (field names like "transcript_path" must not become "error patterns").
stop_context="$(hook_json_get '.last_assistant_message')"
[[ -z "$stop_context" ]] && exit 0

# State lives with the project when we know it, else under ~/.claude.
project_dir="$(hook_json_get '.cwd')"
[[ -d "${project_dir:-}" ]] || project_dir="$HOME/.claude"
STATE_DIR="${project_dir}/.claude/state"
[[ "$project_dir" == "$HOME/.claude" ]] && STATE_DIR="$HOME/.claude/state"
ERROR_LOG="${STATE_DIR}/error-history.log"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

# --- Extract error-like lines ---
error_lines="$(printf '%s\n' "$stop_context" | grep -iE '(Error:|FAIL|failed|Exception|TypeError|SyntaxError|ReferenceError|RuntimeError|ImportError|ModuleNotFoundError|KeyError|ValueError|AttributeError|NameError|IndexError|panic|FATAL|Cannot find|cannot read|is not defined|is not a function|unexpected token)' || true)"
[[ -z "$error_lines" ]] && exit 0

# --- Normalize: strip paths, line numbers, addresses, big numbers ---
normalize_pattern() {
  printf '%s' "$1" \
    | tr -d '|' \
    | sed -E 's|/[^ :]+/||g' \
    | sed -E 's|[^ :]+\.[a-zA-Z]{1,4}:[0-9]+:[0-9]+||g' \
    | sed -E 's|[^ :]+\.[a-zA-Z]{1,4}:[0-9]+||g' \
    | sed -E 's|line [0-9]+||gi' \
    | sed -E 's|at 0x[0-9a-fA-F]+||g' \
    | sed -E 's|[0-9]{4,}||g' \
    | sed -E 's|  +| |g' \
    | sed -E 's|^ +||;s| +$||' \
    | cut -c1-"$MAX_KEY_LEN"
}

now_epoch="$(date +%s)"
now_iso="$(date '+%Y-%m-%dT%H:%M:%S')"
first_pattern=""

# Log format: epoch|iso|session_id|pattern   (pattern has no '|')
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  pattern="$(normalize_pattern "$line")"
  [[ -z "$pattern" ]] && continue
  printf '%s|%s|%s|%s\n' "$now_epoch" "$now_iso" "$session_id" "$pattern" >> "$ERROR_LOG"
  [[ -z "$first_pattern" ]] && first_pattern="$pattern"
done <<< "$error_lines"
[[ -z "$first_pattern" ]] && exit 0

# --- Count this session's occurrences of the pattern inside the window ---
cutoff_epoch=$(( now_epoch - WINDOW_SECONDS ))
count=0
while IFS='|' read -r ts _ sid logged_pattern; do
  [[ "${ts:-0}" -ge "$cutoff_epoch" ]] 2>/dev/null || continue
  [[ "$sid" == "$session_id" && "$logged_pattern" == "$first_pattern" ]] && count=$(( count + 1 ))
done < "$ERROR_LOG"

if [[ "$count" -ge "$THRESHOLD" ]]; then
  hook_emit_block "⚠️ Circuit Breaker: 동일 에러 ${count}회 반복 감지 (${first_pattern}). 추가 수정 시도를 멈추고 아키텍처 리뷰 + Agent Struggle Report를 작성하세요 (RULES.md Circuit Breaker 절차)."
fi

# --- Prune entries older than 1 hour ---
prune_cutoff=$(( now_epoch - 3600 ))
tmp_log="${ERROR_LOG}.tmp"
while IFS='|' read -r ts rest; do
  [[ "${ts:-0}" -ge "$prune_cutoff" ]] 2>/dev/null && printf '%s|%s\n' "$ts" "$rest"
done < "$ERROR_LOG" > "$tmp_log" 2>/dev/null
mv "$tmp_log" "$ERROR_LOG" 2>/dev/null || true

exit 0
