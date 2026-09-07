#!/bin/bash
# Strategic Compact with Auto-Note - PreToolUse hook
# Suggests /compact at logical workflow boundaries
# AUTOMATICALLY saves important context to notepad before compaction
#
# Philosophy: Suggest compaction at phase transitions, not arbitrary points
# - After exploration, before execution
# - After completing a milestone
# - When tool count reaches threshold

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

# Configuration
INITIAL_THRESHOLD=${COMPACT_INITIAL_THRESHOLD:-50}
REMINDER_INTERVAL=${COMPACT_REMINDER_INTERVAL:-25}

# Counter is keyed by session_id. ($$ was the hook's own PID — a new one on
# every call — so the count never got past 1 and /tmp filled with files.)
SESSION_ID="$(hook_session_id)"
COUNTER_DIR="${HOME}/.claude/state"
COUNTER_FILE="${COUNTER_DIR}/tool-counter-${SESSION_ID}"
mkdir -p "$COUNTER_DIR" 2>/dev/null || exit 0
# Drop counters from sessions that ended more than a day ago
find "$COUNTER_DIR" -name 'tool-counter-*' -mtime +1 -delete 2>/dev/null || true
# Initialize counter file if not exists
if [[ ! -f "$COUNTER_FILE" ]]; then
  echo "0" > "$COUNTER_FILE"
fi

# Read and increment counter
count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
[[ "$count" =~ ^[0-9]+$ ]] || count=0
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

# Check if we should suggest compaction
should_suggest=false
if [[ "$count" -eq "$INITIAL_THRESHOLD" ]]; then
  should_suggest=true
  suggestion_reason="Reached $INITIAL_THRESHOLD tool calls"
elif [[ "$count" -gt "$INITIAL_THRESHOLD" ]]; then
  since_threshold=$((count - INITIAL_THRESHOLD))
  if [[ $((since_threshold % REMINDER_INTERVAL)) -eq 0 ]]; then
    should_suggest=true
    suggestion_reason="$count total tool calls"
  fi
fi

# Output suggestion if needed - NOW WITH MANDATORY NOTE SAVE
if [[ "$should_suggest" == "true" ]]; then
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "💭 [Context] $suggestion_reason" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "" >&2
  echo "📝 [MANDATORY] Before /compact, save important context:" >&2
  echo "" >&2

  # PreToolUse contract: additionalContext reaches Claude; a bare
  # {"continue":true,"message":...} object has no "message" field and
  # was being injected as raw JSON text.
  hook_emit_context PreToolUse "[PRE-COMPACT PROTOCOL]

Context threshold reached ($suggestion_reason). BEFORE running /compact:

1. **SAVE CRITICAL INFO** to notepad:
   - Current task status and progress
   - Key discoveries or decisions made
   - File paths and line numbers being worked on
   - Any errors being debugged

2. Use these commands:
   - \`/note <info>\` for working memory
   - \`/note --priority <info>\` for must-remember info

3. Then run \`/compact\` when ready.

**DO NOT skip note-saving.** Information lost to compaction cannot be recovered."
fi
exit 0
