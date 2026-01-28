#!/bin/bash
# Todo Continuation Hook
# Checks for incomplete todos and prevents premature stopping
# Inspired by oh-my-claudecode's stop-continuation

set -e

# Configuration
MAX_ITERATIONS=${MAX_ITERATIONS:-10}
STATE_DIR="${HOME}/.claude/state"
ITERATION_FILE="${STATE_DIR}/iteration-count.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Read stdin (Claude Code provides session context)
INPUT=$(cat)

# Initialize iteration tracking
get_iteration_count() {
  local session_id="$1"
  if [[ -f "$ITERATION_FILE" ]] && command -v jq &> /dev/null; then
    jq -r ".\"$session_id\" // 0" "$ITERATION_FILE" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

increment_iteration() {
  local session_id="$1"
  local current=$(get_iteration_count "$session_id")
  local new_count=$((current + 1))

  if command -v jq &> /dev/null; then
    if [[ -f "$ITERATION_FILE" ]]; then
      jq ".\"$session_id\" = $new_count" "$ITERATION_FILE" > "${ITERATION_FILE}.tmp" && mv "${ITERATION_FILE}.tmp" "$ITERATION_FILE"
    else
      echo "{\"$session_id\": $new_count}" > "$ITERATION_FILE"
    fi
  fi
  echo "$new_count"
}

reset_iteration() {
  local session_id="$1"
  if [[ -f "$ITERATION_FILE" ]] && command -v jq &> /dev/null; then
    jq "del(.\"$session_id\")" "$ITERATION_FILE" > "${ITERATION_FILE}.tmp" && mv "${ITERATION_FILE}.tmp" "$ITERATION_FILE"
  fi
}

# Get session ID if available
SESSION_ID=""
if command -v jq &> /dev/null; then
  SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // .session_id // "default"' 2>/dev/null)
fi
[[ -z "$SESSION_ID" || "$SESSION_ID" == "null" ]] && SESSION_ID="default"

# Check Claude's internal todo system
TODOS_DIR="$HOME/.claude/todos"
INCOMPLETE_COUNT=0

if [[ -d "$TODOS_DIR" ]]; then
  for todo_file in "$TODOS_DIR"/*.json; do
    if [[ -f "$todo_file" ]]; then
      if command -v jq &> /dev/null; then
        COUNT=$(jq '[.[] | select(.status != "completed" and .status != "cancelled")] | length' "$todo_file" 2>/dev/null || echo "0")
        INCOMPLETE_COUNT=$((INCOMPLETE_COUNT + COUNT))
      fi
    fi
  done
fi

# Also check TaskList state (if available in session)
if command -v jq &> /dev/null; then
  TASK_PENDING=$(echo "$INPUT" | jq -r '.tasks // [] | [.[] | select(.status == "pending" or .status == "in_progress")] | length' 2>/dev/null || echo "0")
  INCOMPLETE_COUNT=$((INCOMPLETE_COUNT + TASK_PENDING))
fi

# Check iteration count to prevent infinite loops
CURRENT_ITERATION=$(get_iteration_count "$SESSION_ID")

if [[ "$INCOMPLETE_COUNT" -gt 0 ]]; then
  # Check if we've exceeded max iterations
  if [[ "$CURRENT_ITERATION" -ge "$MAX_ITERATIONS" ]]; then
    reset_iteration "$SESSION_ID"
    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "⚠️ [Persistence] Max iterations ($MAX_ITERATIONS) reached" >&2
    echo "   $INCOMPLETE_COUNT tasks remain incomplete" >&2
    echo "   Allowing stop to prevent infinite loop" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    # Allow stop after max iterations
    exit 0
  fi

  # Increment iteration and continue
  NEW_ITERATION=$(increment_iteration "$SESSION_ID")

  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "🔄 [Persistence] $INCOMPLETE_COUNT incomplete tasks detected" >&2
  echo "   Iteration: $NEW_ITERATION/$MAX_ITERATIONS" >&2
  echo "   Continue working on the next pending task" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

  # Return continuation message to Claude
  cat << EOF
{
  "continue": false,
  "reason": "[SYSTEM - PERSISTENCE ENFORCEMENT]\n\nIncomplete tasks remain ($INCOMPLETE_COUNT pending). Iteration $NEW_ITERATION/$MAX_ITERATIONS.\n\nContinue working:\n- Check TodoList for next pending task\n- Complete current in_progress tasks\n- Do not stop until all tasks are done\n- Mark tasks complete when finished"
}
EOF
  exit 0
fi

# All tasks complete - reset iteration count and allow stop
reset_iteration "$SESSION_ID"
echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "✅ [Persistence] All tasks completed" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
exit 0
