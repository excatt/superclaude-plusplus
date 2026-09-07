#!/bin/bash
# Pre-Compact Auto-Note Hook
# Detects /compact command and enforces note-saving before compaction
#
# Runs on UserPromptSubmit to intercept /compact

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

# UserPromptSubmit input carries the text in .prompt
PROMPT="$(hook_json_get '.prompt')"

# Exit if no prompt
if [[ -z "$PROMPT" ]]; then
  exit 0
fi

# Convert to lowercase for matching
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Check for /compact command
if echo "$PROMPT_LOWER" | grep -qE '^\s*/compact\b'; then
  # Notepad locations
  PROJECT_NOTEPAD="${PWD}/.claude/notepad.md"
  GLOBAL_NOTEPAD="${HOME}/.claude/notepad.md"

  # Check if notepad has recent entries (within last hour)
  NOTEPAD_FILE=""
  if [[ -f "$PROJECT_NOTEPAD" ]]; then
    NOTEPAD_FILE="$PROJECT_NOTEPAD"
  elif [[ -f "$GLOBAL_NOTEPAD" ]]; then
    NOTEPAD_FILE="$GLOBAL_NOTEPAD"
  fi

  # Count Working Memory entries
  WM_COUNT=0
  if [[ -n "$NOTEPAD_FILE" ]]; then
    WM_COUNT="$(count_matches '^\[' "$NOTEPAD_FILE")"
  fi

  # Inject pre-compact reminder
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "📋 [Pre-Compact] Notepad has $WM_COUNT entries" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

  # UserPromptSubmit contract: additionalContext (not "message")
  hook_emit_context UserPromptSubmit "[PRE-COMPACT CHECK]

Before compaction completes, verify:

✅ Current task/progress saved to notepad?
✅ Key file paths and line numbers noted?
✅ Important discoveries preserved?

Notepad entries: $WM_COUNT
Location: ${NOTEPAD_FILE:-none}

If critical info is missing, use /note FIRST."
fi

exit 0
