#!/usr/bin/env bash
# Config Doctor — SuperClaude++ configuration consistency check.
# Backs /config-doctor and runs in CI. Exit 1 when any ERROR is found.
#
# Usage: bash scripts/config-doctor.sh [--quiet]
#   ERROR  → something is broken or contradictory (fails CI)
#   WARN   → drift that does not break anything (does not fail CI)

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
QUIET=false; [[ "${1:-}" == "--quiet" ]] && QUIET=true

errors=0; warns=0
err()  { errors=$((errors+1)); echo "  ❌ $*"; }
warn() { warns=$((warns+1));   echo "  ⚠️  $*"; }
info() { $QUIET || echo "  · $*"; }
section() { echo; echo "▶ $*"; }

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing dependency: $1"; exit 1; }; }
need python3

# ---------------------------------------------------------------- 1. agents
section "1. Agent frontmatter (agents/*.md)"
for f in agents/*.md; do
  fm="$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$f")"
  [[ -z "$fm" ]] && { err "$f: no YAML frontmatter"; continue; }
  for key in name description model tools maxTurns effort; do
    grep -qE "^${key}:" <<< "$fm" || err "$f: missing '$key'"
  done
  name="$(grep -E '^name:' <<< "$fm" | head -1 | sed 's/^name:[[:space:]]*//')"
  [[ "$name" == "$(basename "$f" .md)" ]] || err "$f: name '$name' != filename"
done
info "$(ls agents/*.md | wc -l | tr -d ' ') agents checked"

# ---------------------------------------------------------------- 2. skills
section "2. Skills (skills/*/SKILL.md)"
skill_total=0
for d in skills/*/; do
  d="${d%/}"; n="$(basename "$d")"
  if [[ ! -f "$d/SKILL.md" ]]; then
    [[ "$n" == "learned" ]] && continue   # runtime output dir for /learn
    err "$d: missing SKILL.md"; continue
  fi
  skill_total=$((skill_total+1))
  first="$(head -1 "$d/SKILL.md")"
  if [[ "$first" != "---" ]]; then
    err "$d/SKILL.md: no frontmatter (name/description are what the harness injects)"
    continue
  fi
  fm="$(awk 'NR>1 && $0=="---"{exit} NR>1{print}' "$d/SKILL.md")"
  grep -qE '^description:' <<< "$fm" || err "$d/SKILL.md: missing 'description'"
  sname="$(grep -E '^name:' <<< "$fm" | head -1 | sed 's/^name:[[:space:]]*//; s/^["'"'"']//; s/["'"'"']$//')"
  [[ -n "$sname" && "$sname" != "$n" ]] && warn "$d/SKILL.md: name '$sname' != directory"
done
info "$skill_total skills checked"

# ---------------------------------------------------------------- 3. skill rules
section "3. Skill rules (.claude/skill-rules.json)"
python3 - << 'PY' || errors=$((errors+1))
import json, os, re, sys
bad = 0
try:
    rules = json.load(open(".claude/skill-rules.json"))
except Exception as e:
    print(f"  ❌ skill-rules.json unreadable: {e}"); sys.exit(1)
seen = set()
for rule in rules.get("rules", []):
    skill = rule.get("skill", "")
    if skill in seen:
        print(f"  ❌ duplicate rule for skill '{skill}'"); bad += 1
    seen.add(skill)
    if not os.path.isfile(f"skills/{skill}/SKILL.md"):
        print(f"  ❌ rule → skills/{skill}/SKILL.md does not exist"); bad += 1
    for pat in rule.get("triggers", {}).get("prompt_patterns", []):
        try: re.compile(pat)
        except re.error as e:
            print(f"  ❌ invalid regex in {skill}: {pat!r} ({e})"); bad += 1
print(f"  · {len(rules.get('rules', []))} rules checked")
sys.exit(1 if bad else 0)
PY

# ---------------------------------------------------------------- 4. hooks
section "4. Hooks (config/settings.json)"
python3 - << 'PY' || errors=$((errors+1))
import json, os, re, sys
bad = 0
s = json.load(open("config/settings.json"))
hooks = s.get("hooks", {})
events = 0; entries = 0
for event, groups in hooks.items():
    events += 1
    for g in groups:
        for h in g.get("hooks", []):
            entries += 1
            cmd = h.get("command", "")
            t = h.get("timeout")
            if isinstance(t, (int, float)) and t > 600:
                print(f"  ❌ {event}: timeout {t} looks like milliseconds — the field is seconds"); bad += 1
            for tok in cmd.split():
                if "~/.claude/scripts/" in tok:
                    rel = tok.replace("~/.claude/", "")
                    if not os.path.isfile(rel):
                        print(f"  ❌ {event}: {tok} → repo has no {rel}"); bad += 1
                    elif not os.access(rel, os.X_OK) and not cmd.startswith("python3"):
                        print(f"  ⚠️  {event}: {rel} is not executable")
                    inst = os.path.expanduser(tok)
                    if not os.path.isfile(inst):
                        print(f"  ⚠️  {event}: {tok} not installed (run scripts/sync-global.sh)")
            if "CLAUDE_FILE_PATH" in cmd or "CLAUDE_TOOL_OUTPUT" in cmd:
                print(f"  ❌ {event}: relies on CLAUDE_* env var — Claude Code passes context on stdin"); bad += 1
sl = s.get("statusLine", {}).get("command", "")
if sl:
    rel = sl.replace("~/.claude/", "")
    if "~/.claude/scripts/" not in sl or not os.path.isfile(rel):
        print(f"  ❌ statusLine → {sl} not under ~/.claude/scripts/ or missing in repo ({rel})"); bad += 1
print(f"  · {events} events, {entries} hooks checked")
sys.exit(1 if bad else 0)
PY

# ---------------------------------------------------------------- 5. versions & counts
section "5. Versions & counts (plugin.json / README / CHANGELOG / CLAUDE.md)"
ver="$(python3 -c 'import json;print(json.load(open("plugin.json"))["version"])')"
cl_ver="$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | tr -d '#[] ')"
[[ "$cl_ver" == "$ver" ]] || err "CHANGELOG top entry $cl_ver != plugin.json $ver"
grep -qE "^\| $ver " CHANGELOG.md || err "CHANGELOG version table has no row for $ver"
mm="${ver%.*}"
grep -qE "^# SuperClaude\+\+ v${mm}" README.md || err "README title is not v$mm"
grep -qE "^# SuperClaude\+\+ v${mm}" CLAUDE.md || err "CLAUDE.md title is not v$mm"
grep -q "v${mm} loaded" config/settings.json || warn "InstructionsLoaded banner does not say v$mm"
agent_total="$(ls agents/*.md | wc -l | tr -d ' ')"
grep -qE "${skill_total}개 스킬, ${agent_total}개 에이전트" README.md || err "README headline count != ${skill_total} skills / ${agent_total} agents"
grep -qE "### Skills \(${skill_total}개" README.md || err "README '### Skills (N개' != $skill_total"
grep -qE "${skill_total} skills, ${agent_total} agents" plugin.json || err "plugin.json description count != ${skill_total}/${agent_total}"
info "version $ver, $skill_total skills, $agent_total agents"

# ---------------------------------------------------------------- 6. referenced files
section "6. Referenced files"
# On-Demand References list in CLAUDE.md: "- `FILE.md` — ..."
for f in $(grep -oE '^- `[A-Z_]+\.md`' CLAUDE.md | tr -d '`- ' | sort -u); do
  [[ -f "optional/$f" ]] || err "CLAUDE.md On-Demand list references optional/$f (missing)"
done
for f in $(grep -oE 'optional/[A-Za-z_]+\.md' MODES.md CLAUDE.md RULES.md PRINCIPLES.md | cut -d: -f2 | sort -u); do
  [[ -f "$f" ]] || err "$f referenced but missing"
done
for f in $(grep -oE 'scripts/[a-z-]+\.(sh|py)' README.md RULES.md CLAUDE.md | cut -d: -f2 | sort -u); do
  [[ -f "$f" ]] || err "$f referenced in docs but missing"
done
while IFS= read -r l; do
  [[ -e "$l" ]] || err "$l: dangling symlink"
done < <(find skills -type l)
info "doc references and symlinks resolved"

# ---------------------------------------------------------------- 7. syntax
section "7. Script syntax"
for f in scripts/*.sh scripts/lib/*.sh tests/hooks/*.sh; do bash -n "$f" 2>/dev/null || err "$f: bash -n failed"; done
for f in scripts/*.py; do python3 -m py_compile "$f" 2>/dev/null || err "$f: py_compile failed"; done
python3 -c 'import json;json.load(open("config/settings.json"));json.load(open(".claude/skill-rules.json"));json.load(open("plugin.json"))' || err "a JSON config does not parse"
if command -v shellcheck >/dev/null 2>&1; then
  # statusline.sh is vendored (cc-statusline) and linted upstream
  lint_targets=()
  for f in scripts/*.sh scripts/lib/*.sh tests/hooks/run.sh; do
    [[ "$f" == scripts/statusline.sh ]] || lint_targets+=("$f")
  done
  shellcheck -S warning -x "${lint_targets[@]}" || err "shellcheck reported warnings"
else
  warn "shellcheck not installed — skipped (brew install shellcheck / apt install shellcheck)"
fi
info "syntax checked"

echo
echo "════════════════════════════════════════"
echo " Config Doctor: ${errors} error(s), ${warns} warning(s)"
if [[ $errors -eq 0 ]]; then echo " Framework Health: HEALTHY"; else echo " Framework Health: BROKEN"; fi
echo "════════════════════════════════════════"
[[ $errors -eq 0 ]]
