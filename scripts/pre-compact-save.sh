#!/bin/bash
# Pre-Compact Auto-Save Hook
# Automatically saves context state before compaction
# Triggered by PreCompact event (auto or manual)

set -e

# Configuration
STATE_DIR="${HOME}/.claude/state"
SNAPSHOT_DIR="${STATE_DIR}/snapshots"
MAX_SNAPSHOTS=10

# Ensure directories exist
mkdir -p "$SNAPSHOT_DIR"

# Read stdin (JSON input from Claude Code)
INPUT=$(cat)

# Get timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Extract session info if available
SESSION_ID="default"
if command -v jq &> /dev/null; then
  SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // .session_id // "default"' 2>/dev/null)
  [[ "$SESSION_ID" == "null" ]] && SESSION_ID="default"
fi

# Create snapshot filename
SNAPSHOT_FILE="${SNAPSHOT_DIR}/snapshot-${TIMESTAMP}.json"

# Gather current state
NOTEPAD_PROJECT="${PWD}/.claude/notepad.md"
NOTEPAD_GLOBAL="${HOME}/.claude/notepad.md"
PDCA_STATUS="${PWD}/docs/.pdca-status.json"

# Build snapshot
cat > "$SNAPSHOT_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "session_id": "$SESSION_ID",
  "working_directory": "$PWD",
  "notepad": {
    "project": $(if [[ -f "$NOTEPAD_PROJECT" ]]; then echo "true"; else echo "false"; fi),
    "global": $(if [[ -f "$NOTEPAD_GLOBAL" ]]; then echo "true"; else echo "false"; fi)
  },
  "pdca_status": $(if [[ -f "$PDCA_STATUS" ]]; then cat "$PDCA_STATUS" 2>/dev/null || echo "null"; else echo "null"; fi)
}
EOF

# Cleanup old snapshots (keep only MAX_SNAPSHOTS)
SNAPSHOT_COUNT=$(ls -1 "$SNAPSHOT_DIR"/snapshot-*.json 2>/dev/null | wc -l)
if [[ "$SNAPSHOT_COUNT" -gt "$MAX_SNAPSHOTS" ]]; then
  ls -1t "$SNAPSHOT_DIR"/snapshot-*.json | tail -n +$((MAX_SNAPSHOTS + 1)) | xargs rm -f 2>/dev/null
fi

# Output to stderr for visibility
echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "💾 [PreCompact] State snapshot saved" >&2
echo "   File: $SNAPSHOT_FILE" >&2
echo "   Snapshots kept: $MAX_SNAPSHOTS" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

# Return success with message
cat << EOF
{
  "continue": true,
  "message": "[PRE-COMPACT] State snapshot saved to $SNAPSHOT_FILE"
}
EOF

exit 0
