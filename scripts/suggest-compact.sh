#!/bin/bash
# Strategic Compact with Auto-Note - PreToolUse hook
# Suggests /compact at logical workflow boundaries
# AUTOMATICALLY saves important context to notepad before compaction
#
# Philosophy: Suggest compaction at phase transitions, not arbitrary points
# - After exploration, before execution
# - After completing a milestone
# - When tool count reaches threshold

set -e

# Configuration
INITIAL_THRESHOLD=${COMPACT_INITIAL_THRESHOLD:-50}
REMINDER_INTERVAL=${COMPACT_REMINDER_INTERVAL:-25}
COUNTER_FILE="/tmp/claude-tool-counter-$$"
NOTEPAD_FILE="${PWD}/.claude/notepad.md"
GLOBAL_NOTEPAD="${HOME}/.claude/notepad.md"

# Use project notepad if exists, otherwise global
if [[ -f "$NOTEPAD_FILE" ]]; then
  ACTIVE_NOTEPAD="$NOTEPAD_FILE"
else
  ACTIVE_NOTEPAD="$GLOBAL_NOTEPAD"
fi

# Initialize counter file if not exists
if [[ ! -f "$COUNTER_FILE" ]]; then
  echo "0" > "$COUNTER_FILE"
fi

# Read and increment counter
count=$(cat "$COUNTER_FILE")
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

  # Return instruction to Claude to save notes before compaction
  cat << 'EOF'
{
  "continue": true,
  "message": "[PRE-COMPACT PROTOCOL]\n\nContext threshold reached. BEFORE running /compact:\n\n1. **SAVE CRITICAL INFO** to notepad:\n   - Current task status and progress\n   - Key discoveries or decisions made\n   - File paths and line numbers being worked on\n   - Any errors being debugged\n\n2. Use these commands:\n   - `/note <info>` for working memory\n   - `/note --priority <info>` for must-remember info\n\n3. Then run `/compact` when ready.\n\n**DO NOT skip note-saving.** Information lost to compaction cannot be recovered."
}
EOF
fi
