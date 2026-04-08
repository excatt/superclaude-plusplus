#!/usr/bin/env bash
# Circuit Breaker for Claude Code Stop hook
# Detects repeated error patterns and blocks premature stops
# when the same error appears 3+ times in the last 10 minutes.

set -euo pipefail

# --- Config ---
STATE_DIR=".claude/state"
ERROR_LOG="${STATE_DIR}/error-history.log"
WINDOW_SECONDS=600  # 10 minutes
THRESHOLD=3

# --- Ensure state directory exists ---
mkdir -p "${STATE_DIR}"

# --- Read stop context from env or stdin ---
stop_context="${CLAUDE_STOP_REASON:-}"
if [ -z "${stop_context}" ]; then
  if [ ! -t 0 ]; then
    stop_context="$(cat)"
  fi
fi

# Exit silently if no context provided
if [ -z "${stop_context}" ]; then
  exit 0
fi

# --- Extract error patterns ---
# Pull lines containing error-like keywords
error_lines="$(printf '%s\n' "${stop_context}" | grep -iE '(Error:|FAIL|failed|Exception|TypeError|SyntaxError|ReferenceError|RuntimeError|ImportError|ModuleNotFoundError|KeyError|ValueError|AttributeError|NameError|IndexError|panic|FATAL|Cannot find|cannot read|is not defined|is not a function|unexpected token)' 2>/dev/null || true)"

# Exit silently if no errors found
if [ -z "${error_lines}" ]; then
  exit 0
fi

# --- Normalize error pattern ---
# Strip line numbers, file paths, and volatile details to get a stable key
normalize_pattern() {
  local line="$1"
  printf '%s' "${line}" \
    | sed -E 's|/[^ :]+/||g' \
    | sed -E 's|[^ :]+\.[a-zA-Z]{1,4}:[0-9]+:[0-9]+||g' \
    | sed -E 's|[^ :]+\.[a-zA-Z]{1,4}:[0-9]+||g' \
    | sed -E 's|line [0-9]+||gi' \
    | sed -E 's|at 0x[0-9a-fA-F]+||g' \
    | sed -E 's|[0-9]{4,}||g' \
    | sed -E 's|  +| |g' \
    | sed -E 's|^ +||;s| +$||'
}

# --- Log each error pattern with timestamp ---
now_epoch="$(date +%s)"
now_iso="$(date '+%Y-%m-%dT%H:%M:%S')"
normalized=""

while IFS= read -r line; do
  [ -z "${line}" ] && continue
  pattern="$(normalize_pattern "${line}")"
  [ -z "${pattern}" ] && continue
  printf '%s|%s|%s\n' "${now_epoch}" "${now_iso}" "${pattern}" >> "${ERROR_LOG}"
  # Keep the first normalized pattern for checking
  if [ -z "${normalized}" ]; then
    normalized="${pattern}"
  fi
done <<< "${error_lines}"

# Exit silently if normalization produced nothing
if [ -z "${normalized}" ]; then
  exit 0
fi

# --- Count occurrences of this pattern within the time window ---
cutoff_epoch=$(( now_epoch - WINDOW_SECONDS ))
count=0

while IFS='|' read -r ts _ logged_pattern; do
  # Skip entries outside the time window
  if [ "${ts}" -ge "${cutoff_epoch}" ] 2>/dev/null; then
    if [ "${logged_pattern}" = "${normalized}" ]; then
      count=$(( count + 1 ))
    fi
  fi
done < "${ERROR_LOG}"

# --- Circuit breaker decision ---
if [ "${count}" -ge "${THRESHOLD}" ]; then
  printf '{"decision":"block","reason":"\\u26a0\\ufe0f Circuit Breaker: \\ub3d9\\uc77c \\uc5d0\\ub7ec 3\\ud68c \\ubc18\\ubcf5 \\uac10\\uc9c0. \\uc544\\ud0a4\\ud14d\\ucc98 \\ub9ac\\ubdf0\\uac00 \\ud544\\uc694\\ud569\\ub2c8\\ub2e4. /debug \\ub610\\ub294 \\uadfc\\ubcf8 \\uc6d0\\uc778 \\ubd84\\uc11d\\uc744 \\uc2dc\\uc791\\ud558\\uc138\\uc694."}\n'
fi

# --- Prune old entries (older than 1 hour) to keep log small ---
prune_cutoff=$(( now_epoch - 3600 ))
if [ -f "${ERROR_LOG}" ]; then
  tmp_log="${ERROR_LOG}.tmp"
  while IFS='|' read -r ts rest; do
    if [ "${ts}" -ge "${prune_cutoff}" ] 2>/dev/null; then
      printf '%s|%s\n' "${ts}" "${rest}"
    fi
  done < "${ERROR_LOG}" > "${tmp_log}" 2>/dev/null
  mv "${tmp_log}" "${ERROR_LOG}" 2>/dev/null || true
fi

exit 0
