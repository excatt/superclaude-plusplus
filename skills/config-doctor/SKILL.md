---
name: config-doctor
description: SuperClaude++ 설정 정합성 진단. scripts/config-doctor.sh를 실행해 에이전트/스킬 frontmatter, skill-rules 참조, 훅 스크립트 존재·계약, 버전·개수 정합, 문서 참조를 검사합니다.
user-invocable: true
---

# Config Doctor

## Purpose
SuperClaude++ 설정의 무결성을 **기계적으로** 검증합니다. 모든 검사는
`scripts/config-doctor.sh` 한 스크립트에 있고, 같은 스크립트가 CI에서도 돕니다.
문서와 코드가 어긋나면(개수, 버전, 존재하지 않는 스크립트 경로) 여기서 잡힙니다.

## Dynamic Context

Current framework version:
!`python3 -c "import json; print(json.load(open('plugin.json'))['version'])" 2>/dev/null || echo "plugin.json not found (run from repo root)"`

## Run

```bash
bash scripts/config-doctor.sh          # 전체 진단 (❌ 있으면 exit 1)
bash scripts/config-doctor.sh --quiet  # ❌/⚠️ 만 출력
bash tests/hooks/run.sh                # 훅 계약 픽스처 테스트 (27 cases)
```

## Checks (config-doctor.sh)

| # | 검사 | 실패 시 |
|---|------|---------|
| 1 | `agents/*.md` frontmatter — `name` `description` `model` `tools` `maxTurns` `effort`, name == 파일명 | ❌ |
| 2 | `skills/*/SKILL.md` 존재 + frontmatter(`description` 필수), name == 디렉터리 | ❌ / ⚠️ |
| 3 | `.claude/skill-rules.json` — 파싱, 중복 rule, 대상 스킬 존재, regex 컴파일 | ❌ |
| 4 | `config/settings.json` hooks — `~/.claude/scripts/*` 명령이 저장소에 존재(❌)·설치됨(⚠️), `timeout` > 600이면 ms 오기(❌), `CLAUDE_*` 환경변수 의존(❌), statusLine 경로 | ❌ / ⚠️ |
| 5 | 버전·개수 — `plugin.json` == CHANGELOG 최상단 == CHANGELOG 표 행, README/CLAUDE.md 제목 major.minor, README 헤드라인·`### Skills (N개` == 실제 스킬/에이전트 수, `InstructionsLoaded` 배너 | ❌ / ⚠️ |
| 6 | 참조 파일 — CLAUDE.md On-Demand 목록의 `optional/*.md`, MODES/RULES가 가리키는 `optional/`, 문서가 언급하는 `scripts/*.sh|py`, 스킬 심볼릭 링크 | ❌ |
| 7 | 문법 — `bash -n`, `py_compile`, JSON 파싱, shellcheck(설치 시) | ❌ / ⚠️ |

## Output

```
▶ 1. Agent frontmatter (agents/*.md)
  · 9 agents checked
...
════════════════════════════════════════
 Config Doctor: 0 error(s), 1 warning(s)
 Framework Health: HEALTHY
════════════════════════════════════════
```

`HEALTHY`가 아니면 ❌ 항목을 먼저 고치세요. ⚠️는 CI를 막지 않습니다.

## Adding a check
새 드리프트 유형을 발견하면 `scripts/config-doctor.sh`의 해당 섹션에 `err`/`warn` 한 줄을
추가합니다. 문서에 규칙을 적는 것보다 스크립트가 잡는 쪽이 유지됩니다(PRINCIPLES.md
"Machine-readable Constraints").
