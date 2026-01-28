#!/bin/bash
# Continuous Learning - Session Evaluator
# Runs on Stop hook to signal pattern extraction opportunity
#
# This script signals to Claude that the session should be
# evaluated for extractable patterns if it meets criteria.

set -e

LEARNED_SKILLS_PATH="${HOME}/.claude/skills/learned"
MIN_SESSION_LENGTH=${MIN_SESSION_LENGTH:-10}

# Ensure learned skills directory exists
mkdir -p "$LEARNED_SKILLS_PATH"

# Get transcript path from environment (set by Claude Code)
transcript_path="${CLAUDE_TRANSCRIPT_PATH:-}"

# Exit silently if no transcript
if [[ -z "$transcript_path" ]] || [[ ! -f "$transcript_path" ]]; then
  exit 0
fi

# Count messages in session (approximate by counting user messages)
message_count=$(grep -c '"role":"user"' "$transcript_path" 2>/dev/null || echo "0")

# Skip short sessions
if [[ "$message_count" -lt "$MIN_SESSION_LENGTH" ]]; then
  exit 0
fi

# Check for error resolution patterns (errors that were eventually fixed)
error_patterns=$(grep -c '"error"' "$transcript_path" 2>/dev/null || echo "0")
fix_indicators=$(grep -c -E '(fixed|resolved|working|success)' "$transcript_path" 2>/dev/null || echo "0")

# Signal for pattern extraction if session had meaningful error resolution
if [[ "$error_patterns" -gt 0 ]] && [[ "$fix_indicators" -gt 0 ]]; then
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "💡 [Learn] Session had $message_count messages with error resolutions" >&2
  echo "   Consider running /learn to extract reusable patterns" >&2
  echo "   Skills saved to: $LEARNED_SKILLS_PATH" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
fi
