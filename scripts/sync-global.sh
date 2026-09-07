#!/usr/bin/env bash
# Sync project framework files to global ~/.claude/
# Usage: bash scripts/sync-global.sh [--dry-run]
#
# Direction: project (source of truth) → global (~/.claude/)
# Syncs: framework .md files, optional/*.md
#        scripts/ (hook scripts + lib/, made executable)
#        agents/*.md, skills/<name>/ (only the skills this repo ships —
#          user-installed skills/agents in ~/.claude are left alone)
#        .claude/skill-rules.json
#        settings.json (top-level MERGE + ~ path expansion — global-only keys survive)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
GLOBAL_DIR="$HOME/.claude"

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

# sync_tree <src_dir> <dst_dir> <label>
# Mirrors ONE directory (files added/updated/removed inside it). Used per
# skill / per script so that neighbours the repo does not own are untouched.
sync_tree() {
  local src="$1" dst="$2" label="$3"

  if [[ ! -d "$src" ]]; then
    echo "  SKIP  $label (not found in project)"
    skipped=$((skipped + 1))
    return
  fi

  if [[ -d "$dst" ]] && diff -rq "$src" "$dst" > /dev/null 2>&1; then
    skipped=$((skipped + 1))
    return
  fi

  if $DRY_RUN; then
    echo "  WOULD $label/"
  else
    mkdir -p "$dst"
    if command -v rsync > /dev/null 2>&1; then
      rsync -a --delete --exclude '__pycache__' "$src/" "$dst/"
    else
      rm -rf "$dst"
      cp -R "$src" "$dst"
      find "$dst" -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null || true
    fi
    echo "  SYNC  $label/"
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

# --- Hook scripts (settings.json hooks point at ~/.claude/scripts/*) ---
echo ""
echo "=== Scripts ==="
for src in "$PROJECT_DIR"/scripts/*.sh "$PROJECT_DIR"/scripts/*.py; do
  file="scripts/$(basename "$src")"
  sync_file "$src" "$GLOBAL_DIR/$file" "$file"
done
sync_tree "$PROJECT_DIR/scripts/lib" "$GLOBAL_DIR/scripts/lib" "scripts/lib"
if ! $DRY_RUN; then
  chmod +x "$GLOBAL_DIR"/scripts/*.sh "$GLOBAL_DIR"/scripts/*.py 2>/dev/null || true
fi

# --- Agents ---
echo ""
echo "=== Agents ==="
for src in "$PROJECT_DIR"/agents/*.md; do
  file="agents/$(basename "$src")"
  sync_file "$src" "$GLOBAL_DIR/$file" "$file"
done

# --- Skills (per-skill mirror; skills not shipped by this repo are kept) ---
echo ""
echo "=== Skills ==="
skill_count=0
for src in "$PROJECT_DIR"/skills/*/; do
  src="${src%/}"
  [[ -f "$src/SKILL.md" ]] || continue
  name="$(basename "$src")"
  sync_tree "$src" "$GLOBAL_DIR/skills/$name" "skills/$name"
  skill_count=$((skill_count + 1))
done
echo "  ($skill_count skills checked)"

# --- Skill auto-activation rules (skill-matcher.py fallback path) ---
echo ""
echo "=== Skill Rules ==="
sync_file "$PROJECT_DIR/.claude/skill-rules.json" "$GLOBAL_DIR/skill-rules.json" "skill-rules.json"

# --- Stale root files (moved to optional/ or removed in v3.0) ---
echo ""
echo "=== Stale Files ==="
# Root .md files moved to optional/ (v3.0) and scripts removed in v3.3.
for file in FLAGS.md CONTEXTS.md MCP_SERVERS.md KNOWLEDGE.md optional/PATTERNS.md \
            scripts/post-write-check.sh scripts/pre-compact-save.sh scripts/checklist.sh; do
  if [[ -f "$GLOBAL_DIR/$file" ]]; then
    if $DRY_RUN; then
      echo "  WOULD-RM  $file (removed from framework)"
    else
      rm "$GLOBAL_DIR/$file"
      echo "  RM    $file (removed from framework)"
    fi
  fi
done

# --- Settings.json (merge, not overwrite; expand ~ to $HOME) ---
#
# Unlike the .md files above, settings.json is NOT a blind copy. The global file
# legitimately carries machine-local keys the project does not define (model
# selection, notification toggles, permission-prompt preferences). A plain copy
# silently deletes them.
#
# Merge rule: per TOP-LEVEL key — project wins where it defines a key, global-only
# keys are preserved. A few keys hold machine-local state INSIDE them and get a
# nested policy instead of wholesale replacement:
#   permissions.allow / .deny   → union (global entries kept)
#   permissions.defaultMode     → global wins (per-machine preference)
#   extraKnownMarketplaces,
#   enabledPlugins, env         → dict union, project wins on shared keys
#   hooks (and everything else) → project replaces (framework-owned)
# Every replaced/preserved key is reported, so nothing changes silently.
# Consequence: a key deleted from the project settings lingers in global until
# removed by hand.
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

def merge_permissions(proj, glob):
    out = dict(glob)
    out.update(proj)
    for key in ("allow", "deny"):
        if key in proj or key in glob:
            seen, union = set(), []
            for item in list(proj.get(key, [])) + list(glob.get(key, [])):
                if item not in seen:
                    seen.add(item)
                    union.append(item)
            out[key] = union
    if "defaultMode" in glob:
        out["defaultMode"] = glob["defaultMode"]
    return out

def merge_dict_union(proj, glob):
    out = dict(glob)
    out.update(proj)
    return out

NESTED_POLICY = {
    "permissions": merge_permissions,
    "extraKnownMarketplaces": merge_dict_union,
    "enabledPlugins": merge_dict_union,
    "env": merge_dict_union,
}

# Project order first, then global-only keys — deterministic across runs.
merged = dict(project)
for key, policy in NESTED_POLICY.items():
    if key in project and isinstance(project[key], dict) and isinstance(existing.get(key), dict):
        merged[key] = policy(project[key], existing[key])
preserved = [k for k in existing if k not in project]
for key in preserved:
    merged[key] = existing[key]

def canon(value):
    return json.dumps(value, sort_keys=True)

added = [k for k in project if k not in existing]
replaced = [k for k in project if k in existing and canon(existing[k]) != canon(merged[k])]

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
