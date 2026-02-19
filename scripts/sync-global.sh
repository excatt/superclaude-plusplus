#!/usr/bin/env bash
# Sync project framework files to global ~/.claude/ config
# Usage: bash scripts/sync-global.sh [--dry-run]
#
# Direction: project (source of truth) → global (~/.claude/)
# Files: CLAUDE.md, FLAGS.md, RULES.md, PRINCIPLES.md, MODES.md, MCP_SERVERS.md, CONVENTIONS.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
GLOBAL_DIR="$HOME/.claude"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

FILES=(
  CLAUDE.md
  FLAGS.md
  RULES.md
  PRINCIPLES.md
  MODES.md
  MCP_SERVERS.md
  CONVENTIONS.md
)

synced=0
skipped=0

for file in "${FILES[@]}"; do
  src="$PROJECT_DIR/$file"
  dst="$GLOBAL_DIR/$file"

  if [[ ! -f "$src" ]]; then
    echo "  SKIP  $file (not found in project)"
    ((skipped++))
    continue
  fi

  if [[ -f "$dst" ]] && diff -q "$src" "$dst" > /dev/null 2>&1; then
    echo "  OK    $file (already in sync)"
    ((skipped++))
    continue
  fi

  if $DRY_RUN; then
    echo "  WOULD $file (project → global)"
  else
    cp "$src" "$dst"
    echo "  SYNC  $file → $GLOBAL_DIR/"
  fi
  ((synced++))
done

echo ""
if $DRY_RUN; then
  echo "Dry run: $synced file(s) would be synced, $skipped skipped"
else
  echo "Done: $synced file(s) synced, $skipped already up-to-date"
fi
