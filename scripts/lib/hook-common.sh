#!/usr/bin/env bash
# Shared helpers for Claude Code hook scripts.
#
# Claude Code passes hook context as ONE JSON object on stdin (never via
# CLAUDE_* env vars). Hooks reply on stdout with event-specific JSON.
# Source this file, then:
#
#   hook_read_input                      # fills $HOOK_INPUT (idempotent)
#   hook_json_get '.tool_input.file_path' # jq-style path → value or ""
#   hook_file_path                       # Edit/Write/NotebookEdit target
#   hook_session_id                      # .session_id or "default"
#   hook_emit_context PostToolUse "msg"  # additionalContext for Claude
#   hook_emit_block "reason"             # Stop/SubagentStop decision:block
#   count_matches <grep args>            # grep -c that never prints "0\n0"
#
# jq is preferred; python3 is the fallback. With neither, getters return ""
# so callers exit quietly instead of crashing.

HOOK_INPUT="${HOOK_INPUT:-}"

hook_read_input() {
  [[ -n "$HOOK_INPUT" ]] && return 0
  if [[ ! -t 0 ]]; then
    HOOK_INPUT="$(cat 2>/dev/null || true)"
  fi
  return 0
}

# hook_json_get '<path>'  — path is a jq expression like .a.b or .a // .b
hook_json_get() {
  local expr="$1" val=""
  hook_read_input
  [[ -z "$HOOK_INPUT" ]] && { echo ""; return 0; }

  if command -v jq >/dev/null 2>&1; then
    val="$(printf '%s' "$HOOK_INPUT" | jq -r "${expr} // empty" 2>/dev/null || true)"
  elif command -v python3 >/dev/null 2>&1; then
    # Only simple dotted paths are supported in the python fallback.
    # JSON travels via env var: `python3 -` would take the script from stdin.
    local path="${expr%% //*}"
    val="$(HOOK_JSON="$HOOK_INPUT" HOOK_PATH="$path" python3 -c '
import json, os, sys
try:
    data = json.loads(os.environ["HOOK_JSON"])
    for key in [k for k in os.environ["HOOK_PATH"].strip().split(".") if k]:
        data = data[key]
    if data is not None:
        print(data if isinstance(data, str) else json.dumps(data, ensure_ascii=False))
except Exception:
    pass
' 2>/dev/null || true)"
  fi
  [[ "$val" == "null" ]] && val=""
  printf '%s' "$val"
}

hook_file_path() {
  local p
  p="$(hook_json_get '.tool_input.file_path // .tool_input.notebook_path')"
  # Normalize to an absolute path so dirname-walks terminate at "/".
  if [[ -n "$p" && "$p" != /* ]]; then
    p="${PWD}/${p}"
  fi
  printf '%s' "$p"
}

hook_session_id() {
  local sid
  sid="$(hook_json_get '.session_id')"
  printf '%s' "${sid:-default}"
}

hook_stop_hook_active() {
  # "true" when Claude is already continuing because a Stop hook blocked.
  # Hooks must not block again in that state or they loop forever.
  local v
  v="$(hook_json_get '.stop_hook_active')"
  [[ "$v" == "true" ]]
}

# JSON-encode a string (with surrounding quotes).
hook_json_string() {
  local s="$1"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$s" | jq -Rs . 2>/dev/null && return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$s" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read(), ensure_ascii=False))' 2>/dev/null && return 0
  fi
  # Last resort: escape the characters that break JSON.
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//$'\n'/\\n}"; s="${s//$'\t'/\\t}"
  printf '"%s"' "$s"
}

# hook_emit_context <HookEventName> <text>
# Supported events: UserPromptSubmit, PreToolUse, PostToolUse, SessionStart.
hook_emit_context() {
  local event="$1" text="$2"
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":%s}}\n' \
    "$event" "$(hook_json_string "$text")"
}

# hook_emit_block <reason>  — Stop / SubagentStop: keep Claude working.
hook_emit_block() {
  printf '{"decision":"block","reason":%s}\n' "$(hook_json_string "$1")"
}

# count_matches <grep args...>  — always prints a single integer.
count_matches() {
  local n
  n="$(grep -c "$@" 2>/dev/null)" || true
  n="${n%%$'\n'*}"
  printf '%s' "${n:-0}"
}
