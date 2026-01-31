#!/bin/bash
# Post-Write Convention Check Hook
# Extracts file path from PostToolUse input and runs convention check

set -e

# Read stdin (JSON input from Claude Code)
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=""
if command -v jq &> /dev/null; then
  # Try different possible JSON structures
  FILE_PATH=$(echo "$INPUT" | jq -r '
    .tool_input.file_path //
    .tool_input.filePath //
    .input.file_path //
    .input.filePath //
    .file_path //
    .filePath //
    ""
  ' 2>/dev/null)
fi

# Fallback: grep for file path pattern
if [[ -z "$FILE_PATH" || "$FILE_PATH" == "null" ]]; then
  FILE_PATH=$(echo "$INPUT" | grep -oP '"file_?[pP]ath"\s*:\s*"\K[^"]+' | head -1)
fi

# Exit if no file path found
if [[ -z "$FILE_PATH" || "$FILE_PATH" == "null" ]]; then
  exit 0
fi

# Exit if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Get file extension
EXT="${FILE_PATH##*.}"

# Only check code files
case "$EXT" in
  py|ts|tsx|js|jsx|sql|css|scss|sass)
    # Export for convention-check.sh
    export CLAUDE_FILE_PATH="$FILE_PATH"

    # Run convention check
    SCRIPT_DIR="$(dirname "$0")"
    if [[ -f "$SCRIPT_DIR/convention-check.sh" ]]; then
      bash "$SCRIPT_DIR/convention-check.sh" 2>&1
    fi
    ;;
esac

exit 0
