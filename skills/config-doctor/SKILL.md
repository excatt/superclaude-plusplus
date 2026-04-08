---
name: config-doctor
description: SuperClaude++ 설정 유효성 검증. AGENT.md frontmatter, skill-rules.json, hook 스크립트 경로 등 전체 설정을 진단합니다.
user-invocable: true
---

# Config Doctor

## Purpose
SuperClaude++ v2.0 프레임워크의 설정 무결성을 검증합니다.

## Dynamic Context

Current framework version:
!`cat .superclaude-metadata.json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('framework',{}).get('version','unknown'))" 2>/dev/null || echo "metadata not found"`

## Checks

### 1. Agent Frontmatter Validation
모든 `agents/*.md` 파일에 필수 frontmatter 필드 존재 확인:
- `name` (필수)
- `description` (필수)
- `model` (필수: haiku | sonnet | opus)
- `tools` (필수)
- `maxTurns` (필수)
- `effort` (필수: low | medium | high | max)

```bash
for f in agents/*.md; do
  echo "Checking $f..."
  head -20 "$f" | grep -q "^model:" || echo "  ❌ Missing: model"
  head -20 "$f" | grep -q "^tools:" || echo "  ❌ Missing: tools"
  head -20 "$f" | grep -q "^maxTurns:" || echo "  ❌ Missing: maxTurns"
  head -20 "$f" | grep -q "^effort:" || echo "  ❌ Missing: effort"
done
```

### 2. Skill Rules Validation
`.claude/skill-rules.json` 문법 및 참조 검증:
- JSON 파싱 가능 여부
- 각 rule의 `skill` 이 `skills/` 에 실제 존재하는지
- regex 패턴 유효성

```bash
python3 -c "
import json, os, re
rules = json.load(open('.claude/skill-rules.json'))
for rule in rules.get('rules', []):
    skill = rule['skill']
    if not os.path.isdir(f'skills/{skill}'):
        print(f'  ❌ Skill not found: {skill}')
    for pat in rule.get('triggers', {}).get('prompt_patterns', []):
        try:
            re.compile(pat)
        except re.error as e:
            print(f'  ❌ Invalid regex in {skill}: {pat} ({e})')
print('Skill rules validation complete.')
"
```

### 3. Hook Script Path Validation
`config/settings.json`의 모든 hook command 경로가 유효한지 확인:

```bash
python3 -c "
import json, os
settings = json.load(open('config/settings.json'))
for hook_type, entries in settings.get('hooks', {}).items():
    for entry in entries:
        for hook in entry.get('hooks', []):
            cmd = hook.get('command', '')
            if cmd and not cmd.startswith('echo') and not cmd.startswith('python3'):
                script = cmd.split()[0].replace('~', os.path.expanduser('~'))
                if not os.path.exists(script):
                    print(f'  ⚠️ {hook_type}: Script not found: {script}')
print('Hook path validation complete.')
"
```

### 4. Skills Directory Integrity
모든 `skills/*/` 디렉토리에 `SKILL.md`가 존재하는지:

```bash
for d in skills/*/; do
  [ ! -f "$d/SKILL.md" ] && echo "  ⚠️ Missing SKILL.md: $d"
done
```

### 5. MCP Server Connectivity
설정된 MCP 서버의 실행 가능 여부:

```bash
python3 -c "
import json, os
settings = json.load(open('config/settings.json'))
for name, config in settings.get('mcpServers', {}).items():
    cmd = config.get('command', '')
    print(f'  MCP {name}: command={cmd}')
"
```

## Output Format

```
╔══════════════════════════════════════════════╗
║          🏥 CONFIG DOCTOR REPORT             ║
╠══════════════════════════════════════════════╣
║ 1. Agent Frontmatter    ✅/❌ (N issues)     ║
║ 2. Skill Rules          ✅/❌ (N issues)     ║
║ 3. Hook Scripts         ✅/❌ (N issues)     ║
║ 4. Skills Integrity     ✅/❌ (N issues)     ║
║ 5. MCP Servers          ✅/❌ (N issues)     ║
╠══════════════════════════════════════════════╣
║ Total Issues: N                              ║
║ Framework Health: HEALTHY / DEGRADED / BROKEN║
╚══════════════════════════════════════════════╝
```

## Usage

```bash
/config-doctor          # Full diagnostic
/config-doctor --quick  # Checks 1-4 only (skip MCP)
```
