#!/usr/bin/env bash
# Sync project framework files and sound config to global ~/.claude/
# Usage: bash scripts/sync-global.sh [--dry-run]
#
# Direction: project (source of truth) → global (~/.claude/)
# Syncs: framework .md files, peon-ping config (plain copy)
#        settings.json (top-level MERGE + ~ path expansion — global-only keys survive)

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

# --- Framework files (always-resident set, v3.0) ---
echo "=== Framework Files ==="
for file in CLAUDE.md RULES.md PRINCIPLES.md MODES.md CONVENTIONS.md; do
  sync_file "$PROJECT_DIR/$file" "$GLOBAL_DIR/$file" "$file"
done

# --- On-demand references ---
echo ""
echo "=== Optional References ==="
for src in "$PROJECT_DIR"/optional/*.md; do
  file="optional/$(basename "$src")"
  sync_file "$src" "$GLOBAL_DIR/$file" "$file"
done

# --- Stale root files (moved to optional/ or removed in v3.0) ---
echo ""
echo "=== Stale Files ==="
for file in FLAGS.md CONTEXTS.md MCP_SERVERS.md KNOWLEDGE.md; do
  if [[ -f "$GLOBAL_DIR/$file" ]]; then
    if $DRY_RUN; then
      echo "  WOULD-RM  $file (no longer a root framework file)"
    else
      rm "$GLOBAL_DIR/$file"
      echo "  RM    $file (no longer a root framework file)"
    fi
  fi
done

# --- Peon-ping config ---
echo ""
echo "=== Peon-ping Config ==="
sync_file "$PROJECT_DIR/config/peon-ping.json" "$PEON_DIR/config.json" "peon-ping config"

# --- Settings.json (merge, not overwrite; expand ~ to $HOME) ---
#
# Unlike the .md files above, settings.json is NOT a blind copy. The global file
# legitimately carries machine-local keys the project does not define (model
# selection, notification toggles, permission-prompt preferences). A plain copy
# silently deletes them.
#
# Merge rule: per TOP-LEVEL key — project wins where it defines a key, global-only
# keys are preserved. Every replaced/preserved key is reported, so nothing changes
# silently. Nested merging is deliberately NOT attempted: array semantics (union vs
# replace for permissions.allow) are ambiguous, and reporting the replacement is
# more honest than guessing. Consequence: a key deleted from the project settings
# lingers in global until removed by hand.
echo ""
echo "=== Settings.json ==="
SETTINGS_SRC="$PROJECT_DIR/config/settings.json"
SETTINGS_DST="$GLOBAL_DIR/settings.json"

if [[ -f "$SETTINGS_SRC" ]]; then
  set +e
  python3 - "$SETTINGS_SRC" "$SETTINGS_DST" "$HOME" "$DRY_RUN" <<'PY'
import json, os, pathlib, sys

src, dst, home, dry_run = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "true"

try:
    project = json.loads(pathlib.Path(src).read_text().replace("~/", home + "/"))
except json.JSONDecodeError as exc:
    print(f"  ERROR settings.json (project file is not valid JSON: {exc})")
    sys.exit(2)

existing = {}
if os.path.isfile(dst):
    try:
        existing = json.loads(pathlib.Path(dst).read_text())
    except json.JSONDecodeError as exc:
        print(f"  ERROR settings.json (global file is not valid JSON: {exc})")
        print("        Refusing to overwrite — fix or move the global file, then re-run.")
        sys.exit(2)

# Project order first, then global-only keys — deterministic across runs.
merged = dict(project)
preserved = [k for k in existing if k not in project]
for key in preserved:
    merged[key] = existing[key]

def canon(value):
    return json.dumps(value, sort_keys=True)

added = [k for k in project if k not in existing]
replaced = [k for k in project if k in existing and canon(existing[k]) != canon(project[k])]

if existing == merged:
    print("  OK    settings.json (already in sync)")
    sys.exit(0)

verb = "WOULD" if dry_run else "SYNC "
print(f"  {verb} settings.json (~ expanded to {home})")
if added:
    print(f"        + added    : {', '.join(added)}")
if replaced:
    print(f"        ~ replaced : {', '.join(replaced)}")
if preserved:
    print(f"        = preserved: {', '.join(preserved)} (global-only, not in project)")

if not dry_run:
    pathlib.Path(dst).write_text(json.dumps(merged, indent=2, ensure_ascii=False) + "\n")

sys.exit(10)
PY
  settings_status=$?
  set -e
  case $settings_status in
    0)  skipped=$((skipped + 1)) ;;
    10) synced=$((synced + 1)) ;;
    *)  skipped=$((skipped + 1)) ;;
  esac
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
