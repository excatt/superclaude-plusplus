#!/usr/bin/env bash
# Sync project framework files and sound config to global ~/.claude/
# Usage: bash scripts/sync-global.sh [--dry-run]
#
# Direction: project (source of truth) → global (~/.claude/)
# Syncs: framework .md files, peon-ping config, settings.json (with ~ path expansion)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
GLOBAL_DIR="$HOME/.claude"
PEON_DIR="$GLOBAL_DIR/hooks/peon-ping"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

synced=0
skipped=0

sync_file() {
  local src="$1" dst="$2" label="$3"

  if [[ ! -f "$src" ]]; then
    echo "  SKIP  $label (not found in project)"
    skipped=$((skipped + 1))
    return
  fi

  if [[ -f "$dst" ]] && diff -q "$src" "$dst" > /dev/null 2>&1; then
    echo "  OK    $label (already in sync)"
    skipped=$((skipped + 1))
    return
  fi

  if $DRY_RUN; then
    echo "  WOULD $label (project → global)"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  SYNC  $label"
  fi
  synced=$((synced + 1))
}

# --- Framework files ---
echo "=== Framework Files ==="
for file in CLAUDE.md FLAGS.md RULES.md PRINCIPLES.md MODES.md MCP_SERVERS.md CONVENTIONS.md; do
  sync_file "$PROJECT_DIR/$file" "$GLOBAL_DIR/$file" "$file"
done

# --- Peon-ping config ---
echo ""
echo "=== Peon-ping Config ==="
sync_file "$PROJECT_DIR/config/peon-ping.json" "$PEON_DIR/config.json" "peon-ping config"

# --- Settings.json (expand ~ to $HOME) ---
echo ""
echo "=== Settings.json ==="
SETTINGS_SRC="$PROJECT_DIR/config/settings.json"
SETTINGS_DST="$GLOBAL_DIR/settings.json"

if [[ -f "$SETTINGS_SRC" ]]; then
  EXPANDED=$(sed "s|~/|$HOME/|g" "$SETTINGS_SRC")
  if [[ -f "$SETTINGS_DST" ]] && echo "$EXPANDED" | diff -q "$SETTINGS_DST" - > /dev/null 2>&1; then
    echo "  OK    settings.json (already in sync)"
    skipped=$((skipped + 1))
  else
    if $DRY_RUN; then
      echo "  WOULD settings.json (expand ~ → $HOME)"
    else
      echo "$EXPANDED" > "$SETTINGS_DST"
      echo "  SYNC  settings.json (~ expanded to $HOME)"
    fi
    synced=$((synced + 1))
  fi
else
  echo "  SKIP  settings.json (not found in project)"
  skipped=$((skipped + 1))
fi

echo ""
if $DRY_RUN; then
  echo "Dry run: $synced file(s) would be synced, $skipped skipped"
else
  echo "Done: $synced file(s) synced, $skipped already up-to-date"
fi
