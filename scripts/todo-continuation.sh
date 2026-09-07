#!/bin/bash
# Todo Continuation Hook
# Checks for incomplete todos and prevents premature stopping
# Inspired by oh-my-claudecode's stop-continuation

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

# Configuration
MAX_ITERATIONS=${MAX_ITERATIONS:-10}
STATE_DIR="${HOME}/.claude/state"
ITERATION_FILE="${STATE_DIR}/iteration-count.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Read stdin (Claude Code provides session context)
hook_read_input
INPUT="$HOOK_INPUT"

# If Claude is already continuing because a Stop hook blocked, never block
# again from here — that would loop until MAX_ITERATIONS for nothing new.
if hook_stop_hook_active; then
  exit 0
fi

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
  local current
  current=$(get_iteration_count "$session_id")
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

# Session ID scopes both the iteration counter and the todo lookup
SESSION_ID="$(hook_session_id)"

# Check Claude's internal todo system — only THIS session's files
# (~/.claude/todos/<session_id>-agent-<agent_id>.json). Counting every
# session's todos let a stale todo from another project block this stop.
TODOS_DIR="$HOME/.claude/todos"
INCOMPLETE_COUNT=0

if [[ -d "$TODOS_DIR" && "$SESSION_ID" != "default" ]]; then
  for todo_file in "$TODOS_DIR"/"$SESSION_ID"*.json; do
    [[ -f "$todo_file" ]] || continue
    if command -v jq &> /dev/null; then
      COUNT=$(jq '[.[] | select(.status != "completed" and .status != "cancelled")] | length' "$todo_file" 2>/dev/null || echo "0")
    else
      COUNT=$(python3 -c 'import json,sys
try: print(sum(1 for t in json.load(open(sys.argv[1])) if t.get("status") not in ("completed","cancelled")))
except Exception: print(0)' "$todo_file" 2>/dev/null || echo "0")
    fi
    [[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=0
    INCOMPLETE_COUNT=$((INCOMPLETE_COUNT + COUNT))
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

  # Stop-hook contract: decision "block" keeps Claude working.
  # ("continue": false would do the opposite — halt Claude entirely.)
  hook_emit_block "[SYSTEM - PERSISTENCE ENFORCEMENT]

Incomplete tasks remain ($INCOMPLETE_COUNT pending). Iteration $NEW_ITERATION/$MAX_ITERATIONS.

Continue working:
- Check TodoList for next pending task
- Complete current in_progress tasks
- Do not stop until all tasks are done
- Mark tasks complete when finished"
  exit 0
fi

# All tasks complete - reset iteration count and allow stop
reset_iteration "$SESSION_ID"
echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "✅ [Persistence] All tasks completed" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
exit 0
