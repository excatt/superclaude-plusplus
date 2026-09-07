#!/usr/bin/env bash
# Hook contract tests — feed realistic Claude Code event JSON to each hook
# script and assert on exit code + stdout shape. No external deps beyond
# bash, jq (or python3) and the hooks themselves.
#
# Usage: bash tests/hooks/run.sh

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS="$ROOT/scripts"
FX="$ROOT/tests/hooks/fixtures"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ok()   { pass=$((pass+1)); echo "  ✓ $1"; }
bad()  { fail=$((fail+1)); echo "  ✗ $1"; [[ -n "${2:-}" ]] && printf '      %s\n' "$2"; }

# run_hook <script> <fixture-file>  → sets OUT, CODE
run_hook() {
  OUT="$(HOME="$TMP/home" bash "$SCRIPTS/$1" < "$2" 2>"$TMP/stderr")"; CODE=$?
}
json_get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -r "$2" 2>/dev/null
  else
    JG_PATH="$2" python3 -c '
import json, os, sys
d = json.load(sys.stdin)
for k in [k for k in os.environ["JG_PATH"].split(".") if k]:
    d = d[k]
print(d)' <<< "$1" 2>/dev/null
  fi
}

# Portable timeout (macOS has no coreutils `timeout`): exit 124 on expiry.
with_timeout() {
  local secs="$1"; shift
  "$@" & local pid=$!
  ( sleep "$secs"; kill "$pid" 2>/dev/null ) & local watchdog=$!
  wait "$pid" 2>/dev/null; local rc=$?
  kill "$watchdog" 2>/dev/null; wait "$watchdog" 2>/dev/null
  [[ $rc -eq 143 ]] && rc=124
  return $rc
}

mkdir -p "$TMP/home/.claude"

echo "▶ lib/hook-common.sh"
( source "$SCRIPTS/lib/hook-common.sh"
  n="$(count_matches ZZZ /etc/hosts)"
  [[ "$n" == "0" ]] && ok "count_matches prints single 0 on no match" || bad "count_matches → '$n'"
  s="$(hook_json_string $'a"b\nc')"
  [[ "$s" == '"a\"b\nc"' ]] && ok "hook_json_string escapes quotes/newlines" || bad "hook_json_string → $s"
  # shellcheck disable=SC2034  # consumed by the sourced hook_* functions
  HOOK_INPUT='{"tool_input":{"file_path":"rel/x.ts"},"session_id":"s1"}'
  [[ "$(hook_file_path)" == "$PWD/rel/x.ts" ]] && ok "hook_file_path absolutizes relative path" || bad "hook_file_path → $(hook_file_path)"
  [[ "$(hook_session_id)" == "s1" ]] && ok "hook_session_id" || bad "hook_session_id"
)

echo "▶ PostToolUse: console-log-check.sh"
mkdir -p "$TMP/proj/src"; printf 'const a = 1;\nconsole.log(a);\n' > "$TMP/proj/src/App.tsx"
sed "s|__FILE__|$TMP/proj/src/App.tsx|" "$FX/posttooluse-edit.json" > "$TMP/e1.json"
run_hook console-log-check.sh "$TMP/e1.json"
[[ $CODE -eq 0 ]] && ok "exit 0" || bad "exit $CODE"
[[ "$(json_get "$OUT" .hookSpecificOutput.hookEventName)" == "PostToolUse" ]] && ok "emits PostToolUse additionalContext" || bad "stdout: $OUT"
json_get "$OUT" .hookSpecificOutput.additionalContext | grep -q "console.log" && ok "reports the console.log line" || bad "context missing match"

echo "▶ PostToolUse: convention-check.sh"
printf 'const user_name = 1;\n' > "$TMP/proj/src/util.ts"
sed "s|__FILE__|$TMP/proj/src/util.ts|" "$FX/posttooluse-edit.json" > "$TMP/e2.json"
run_hook convention-check.sh "$TMP/e2.json"
[[ $CODE -eq 0 ]] && ok "exit 0" || bad "exit $CODE"
json_get "$OUT" .hookSpecificOutput.additionalContext | grep -q "camelCase" && ok "flags snake_case in TS" || bad "stdout: $OUT"
run_hook convention-check.sh "$FX/posttooluse-nofile.json"
[[ $CODE -eq 0 && -z "$OUT" ]] && ok "silent when file_path missing" || bad "exit $CODE out=$OUT"

echo "▶ PostToolUse: auto-format.sh terminates on relative paths"
# No prettier config anywhere above → must exit 0 quickly, not loop on dirname
( cd "$TMP/proj" && printf '{"tool_input":{"file_path":"src/App.tsx"}}' | with_timeout 5 bash "$SCRIPTS/auto-format.sh" >/dev/null 2>&1 )
c=$?
[[ $c -eq 0 ]] && ok "auto-format.sh exits 0 (no infinite dirname loop)" || bad "auto-format.sh exit $c (124 = timeout)"

echo "▶ PostToolUse: injection-scanner.py"
run_hook_py() { OUT="$(python3 "$SCRIPTS/$1" < "$2" 2>/dev/null)"; CODE=$?; }
run_hook_py injection-scanner.py "$FX/posttooluse-mcp-injection.json"
[[ $CODE -eq 0 ]] && ok "exit 0" || bad "exit $CODE"
[[ "$(json_get "$OUT" .hookSpecificOutput.hookEventName)" == "PostToolUse" ]] && ok "emits additionalContext on injection" || bad "stdout: $OUT"
run_hook_py injection-scanner.py "$FX/posttooluse-mcp-clean.json"
[[ -z "$OUT" ]] && ok "silent on clean tool_response (does not self-match envelope)" || bad "false positive: $OUT"

echo "▶ Stop: todo-continuation.sh"
mkdir -p "$TMP/home/.claude/todos"
echo '[{"status":"pending"},{"status":"completed"}]' > "$TMP/home/.claude/todos/sess-A-agent-1.json"
echo '[{"status":"pending"}]' > "$TMP/home/.claude/todos/sess-OTHER-agent-1.json"
run_hook todo-continuation.sh "$FX/stop-session-a.json"
[[ "$(json_get "$OUT" .decision)" == "block" ]] && ok "blocks with decision:block when this session has pending todos" || bad "stdout: $OUT"
json_get "$OUT" .reason | grep -q "1 pending" && ok "counts only this session's todos (1, not 2)" || bad "reason: $(json_get "$OUT" .reason)"
run_hook todo-continuation.sh "$FX/stop-session-a-active.json"
[[ -z "$OUT" && $CODE -eq 0 ]] && ok "does not block when stop_hook_active=true" || bad "stdout: $OUT"
rm "$TMP/home/.claude/todos/sess-A-agent-1.json"
run_hook todo-continuation.sh "$FX/stop-session-a.json"
[[ -z "$OUT" ]] && ok "allows stop when no pending todos for this session" || bad "stdout: $OUT"

echo "▶ Stop: circuit-breaker.sh"
mkdir -p "$TMP/cwd"
sed "s|__CWD__|$TMP/cwd|" "$FX/stop-error.json" > "$TMP/s1.json"
run_hook circuit-breaker.sh "$TMP/s1.json"; o1="$OUT"
run_hook circuit-breaker.sh "$TMP/s1.json"; o2="$OUT"
run_hook circuit-breaker.sh "$TMP/s1.json"; o3="$OUT"
[[ -z "$o1" && -z "$o2" ]] && ok "silent on 1st and 2nd occurrence" || bad "early trip: $o1 / $o2"
[[ "$(json_get "$o3" .decision)" == "block" ]] && ok "trips on 3rd identical error" || bad "3rd: $o3"
grep -q '^[0-9]*|[^|]*|sess-A|TypeError' "$TMP/cwd/.claude/state/error-history.log" && ok "log key is the normalized error line, not the JSON envelope" || bad "log: $(head -1 "$TMP/cwd/.claude/state/error-history.log")"
sed "s|__CWD__|$TMP/cwd|; s|sess-A|sess-B|" "$FX/stop-error.json" > "$TMP/s2.json"
run_hook circuit-breaker.sh "$TMP/s2.json"
[[ -z "$OUT" ]] && ok "another session's identical error does not trip" || bad "cross-session leak: $OUT"
sed "s|__CWD__|$TMP/cwd|" "$FX/stop-no-error.json" > "$TMP/s3.json"
run_hook circuit-breaker.sh "$TMP/s3.json"
[[ -z "$OUT" && $CODE -eq 0 ]] && ok "silent when last message has no error" || bad "$OUT"

echo "▶ Stop: evaluate-session.sh"
: > "$TMP/short.jsonl"; for _ in 1 2 3; do echo '{"role":"user"}' >> "$TMP/short.jsonl"; done
sed "s|__TRANSCRIPT__|$TMP/short.jsonl|" "$FX/stop-transcript.json" > "$TMP/t1.json"
run_hook evaluate-session.sh "$TMP/t1.json"
[[ $CODE -eq 0 ]] && ok "exit 0 on short session (numeric compare works)" || bad "exit $CODE: $(cat "$TMP/stderr")"
grep -q "syntax error" "$TMP/stderr" && bad "arithmetic error in stderr" || ok "no arithmetic errors"

echo "▶ Stop: session-summary.py"
mkdir -p "$TMP/home/.claude/projects/-proj"; T="$TMP/home/.claude/projects/-proj/abc.jsonl"
printf '%s\n' '{"message":{"role":"user","content":"first ask"}}' '{"message":{"role":"user","content":"second ask"}}' > "$T"
sed "s|__TRANSCRIPT__|$T|" "$FX/stop-transcript.json" | HOME="$TMP/home" python3 "$SCRIPTS/session-summary.py"
[[ -f "$TMP/home/.claude/projects/-proj/memory/last-session.md" ]] && ok "writes memory/last-session.md next to transcript" || bad "summary not written"

echo "▶ PreToolUse: suggest-compact.sh"
for _ in $(seq 1 49); do run_hook suggest-compact.sh "$FX/pretooluse-edit.json"; done
[[ -z "$OUT" ]] && ok "silent at 49 calls" || bad "premature: $OUT"
run_hook suggest-compact.sh "$FX/pretooluse-edit.json"
[[ "$(json_get "$OUT" .hookSpecificOutput.hookEventName)" == "PreToolUse" ]] && ok "emits PreToolUse additionalContext at threshold 50 (counter persists per session)" || bad "stdout: $OUT"
[[ -f "$TMP/home/.claude/state/tool-counter-sess-A" ]] && ok "counter file keyed by session_id" || bad "counter file missing"

echo "▶ UserPromptSubmit: pre-compact-note.sh"
run_hook pre-compact-note.sh "$FX/userprompt-compact.json"
[[ "$(json_get "$OUT" .hookSpecificOutput.hookEventName)" == "UserPromptSubmit" ]] && ok "emits UserPromptSubmit additionalContext on /compact" || bad "stdout: $OUT"
run_hook pre-compact-note.sh "$FX/userprompt-plain.json"
[[ -z "$OUT" ]] && ok "silent on ordinary prompt" || bad "$OUT"

echo
echo "passed: $pass  failed: $fail"
[[ $fail -eq 0 ]]
