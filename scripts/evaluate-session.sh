#!/bin/bash
# Continuous Learning - Session Evaluator (Stop hook)
# Signals that the session is worth running /learn on when it was long
# and contained error → resolution cycles. Informational only.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/hook-common.sh"

LEARNED_SKILLS_PATH="${HOME}/.claude/skills/learned"
MIN_SESSION_LENGTH=${MIN_SESSION_LENGTH:-10}

# Transcript path arrives in the Stop event JSON, not in an env var
transcript_path="$(hook_json_get '.transcript_path')"
[[ -n "$transcript_path" && -f "$transcript_path" ]] || exit 0

message_count="$(count_matches '"role":"user"' "$transcript_path")"
[[ "$message_count" -lt "$MIN_SESSION_LENGTH" ]] && exit 0

error_patterns="$(count_matches '"error"' "$transcript_path")"
fix_indicators="$(count_matches -E '(fixed|resolved|working|success)' "$transcript_path")"

if [[ "$error_patterns" -gt 0 && "$fix_indicators" -gt 0 ]]; then
  mkdir -p "$LEARNED_SKILLS_PATH" 2>/dev/null || true
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "💡 [Learn] Session had $message_count messages with error resolutions" >&2
  echo "   Consider running /learn to extract reusable patterns" >&2
  echo "   Skills saved to: $LEARNED_SKILLS_PATH" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
fi
exit 0
