#!/bin/bash
# Pre-Compact Auto-Note Hook
# Detects /compact command and enforces note-saving before compaction
#
# Runs on UserPromptSubmit to intercept /compact

set -e

# Read stdin (JSON input from Claude Code)
INPUT=$(cat)

# Extract the prompt text
PROMPT=""
if command -v jq &> /dev/null; then
  PROMPT=$(echo "$INPUT" | jq -r '
    if .prompt then .prompt
    elif .message then .message
    elif .content then .content
    else ""
    end
  ' 2>/dev/null)
fi

# Fallback if jq fails
if [[ -z "$PROMPT" || "$PROMPT" == "null" ]]; then
  PROMPT=$(echo "$INPUT" | grep -oE '"(prompt|message|content)"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//')
fi

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
    WM_COUNT=$(grep -c '^\[' "$NOTEPAD_FILE" 2>/dev/null || echo "0")
  fi

  # Inject pre-compact reminder
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "📋 [Pre-Compact] Notepad has $WM_COUNT entries" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

  # Return instruction
  cat << EOF
{
  "continue": true,
  "message": "[PRE-COMPACT CHECK]\n\nBefore compaction completes, verify:\n\n✅ Current task/progress saved to notepad?\n✅ Key file paths and line numbers noted?\n✅ Important discoveries preserved?\n\nNotepad entries: $WM_COUNT\nLocation: ${NOTEPAD_FILE:-none}\n\nIf critical info is missing, use /note FIRST."
}
EOF
fi

exit 0
