# SuperClaude++ v3.3

Claude Code를 위한 harness-aware 개발 프레임워크 - 60개 스킬, 9개 에이전트, 9개 훅 이벤트.
**모델이 스스로 알 수 없는 것만 문서로 남기고, 사람의 기억에 의존하던 규칙은 훅으로 강제합니다.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/excatt/superclaude-plusplus/actions/workflows/ci.yml/badge.svg)](https://github.com/excatt/superclaude-plusplus/actions/workflows/ci.yml)

---

## 왜 이 프레임워크인가

Claude 5 세대 모델과 Claude Code 하네스는 검증 후 완료 선언, 지속 실행, 스코프 절제,
병렬 도구 호출 같은 행동을 이미 보장합니다. 이런 것을 CLAUDE.md에 다시 적는 건
컨텍스트만 차지하는 순비용입니다. SuperClaude++는 세 가지만 다룹니다.

| 남긴 것 | 예 | 어디에 |
|---------|----|--------|
| **모델이 알 수 없는 사실** | 한국어 응답, uv/pnpm 강제, 네이밍 컨벤션, Co-Authored-By 금지 | `CLAUDE.md` + 4개 `.md` (상시 로드 약 2,000단어) |
| **하네스 기본값 오버라이드** | 난이도별 프로토콜 분기, Two-Stage Review, 서지컬 변경 규칙 | `RULES.md` |
| **결정적 기계 장치** | 스킬 자동 활성화, Circuit Breaker, 컨벤션 체크, injection 스캔 | `config/settings.json` 훅 16개 |

프로세스 지식(모드, 플래그, 추론 템플릿, MCP 가이드)은 `optional/` 28개 문서와
스킬로 내려가 필요할 때만 로드됩니다. 이 원칙이 어떻게 자리 잡았는지는
[CHANGELOG](CHANGELOG.md)의 v2.0(시스템 강제)·v3.0(harness-aware slim) 항목에 있습니다.

---

## 빠른 시작

### 설치

```bash
# Plugin (권장)
/plugin install github:excatt/superclaude-plusplus

# Manual
git clone https://github.com/excatt/superclaude-plusplus.git
cd superclaude-plusplus
scripts/sync-global.sh --dry-run   # 무엇이 바뀌는지 먼저 확인
scripts/sync-global.sh
```

`sync-global.sh`는 프레임워크 `.md`, `optional/`, `scripts/`(훅), `agents/`, 이 저장소가
배포하는 `skills/`, `skill-rules.json`을 `~/.claude/`로 복사합니다. `~/.claude/skills`나
`agents`에 있는 다른 항목은 건드리지 않습니다. `settings.json`은 **병합**합니다.

| 키 | 병합 규칙 |
|----|-----------|
| `hooks`, `statusLine` | 프로젝트가 덮어씀 (프레임워크 소유) |
| `permissions.allow/deny`, `enabledPlugins`, `extraKnownMarketplaces`, `env` | 합집합 |
| `permissions.defaultMode`, 프로젝트에 없는 키 | 글로벌 값 유지 |

### 설치 후

1. **Claude Code 재시작.** `enabledPlugins`에 선언된 플러그인 5종이 업스트림에서 설치됩니다.
2. `/config-doctor` 로 설정 정합성 확인.
3. LSP 플러그인용 바이너리 설치:
   ```bash
   pnpm add -g pyright typescript typescript-language-server
   ```

### 함께 켜지는 플러그인 (참조 선언, 코드 미포함)

| 플러그인 | 역할 |
|----------|------|
| `fluent-korean` | 한국어 output style. 조사·어미 보존, 번역투 교정 |
| `security-guidance` | Edit/Write 시 위험 패턴 경고, Stop 시 diff 보안 리뷰, commit 시 파일 간 데이터 흐름 추적 |
| `pyright-lsp`, `typescript-lsp` | 언어 서버. 타입 오류를 도구 호출 없이 즉시 인식 |
| `context7` | 최신 공식 문서 조회 MCP (원격, 로컬 설치 불필요) |

출처와 검토 후 미채택한 플러그인은 [NOTICE.md](NOTICE.md)에 있습니다.

---

## 작업 흐름

모든 구현 요청은 아래 순서를 따릅니다. 난이도에 따라 단계가 생략됩니다.

```
Step 0  난이도 평가 (Simple / Medium / Complex)
   │
   ├─ Medium+  /confidence-check ─ 90% 미만이면 조사 후 재평가
   │
   ▼
구현 ── 훅이 편집마다 컨벤션·console.log·보안 패턴 체크
   │
   ▼
Two-Stage Review ── Stage 1 스펙 준수 → Stage 2 코드 품질 → (Complex) Stage 3 연쇄 영향
   │
   ▼
/verify → /audit ── 빌드·테스트·프로젝트 규칙
   │
   ▼
/learn ── 재사용 패턴 추출 (선택)
```

| 난이도 | 기준 (다수결) | 프로토콜 |
|--------|--------------|----------|
| **Simple** | 파일 1개, 기존 패턴 반복, diff 50줄 미만 | 즉시 구현, Stage 1만 |
| **Medium** | 파일 2~3개, 기존 패턴을 새 영역에 적용, 50~200줄 | confidence-check + Stage 1·2 |
| **Complex** | 파일 4개 이상, 새 패턴 도입, 아키텍처 결정, 200줄 이상 | 전체 + Cascade Impact Review |

검증 가능한 종료 조건이 있는 멀티턴 작업은 `/goal "<조건>"`로 자율 루프를 돕니다.
약한 조건("잘 되게 해줘")은 절대 `/goal`에 넘기지 않습니다. 패턴은 `optional/GOAL_PATTERNS.md`.

---

## 구성 요소

### 상시 로드 문서 (5개)

| 파일 | 내용 |
|------|------|
| `CLAUDE.md` | 엔트리 포인트. 언어, 워크플로우 통합, 온디맨드 참조 목록 |
| `RULES.md` | 난이도 분기, Two-Stage Review, Circuit Breaker, 서지컬 변경, Git·패키지 규칙 |
| `PRINCIPLES.md` | Complexity Timing, KISS/YAGNI 체크, **Build Ladder** 8단, Harness Engineering |
| `MODES.md` | 8개 행동 모드 Quick Reference (상세는 `optional/MODE_*.md`) |
| `CONVENTIONS.md` | Python·TypeScript·React·CSS 네이밍, uv/pnpm 필수 |

### Skills (60개)

스킬 메타데이터는 idle에도 컨텍스트에 상주하므로, 모델이 이미 할 수 있는 것은
스킬로 만들지 않습니다. 남은 기준은 네 가지입니다. 기계 장치나 데이터를 가진 것,
프레임워크 워크플로우의 코어, 검증된 큐레이션 콘텐츠, 출처가 추적되는 서드파티 스킬.

| 그룹 | 스킬 |
|------|------|
| **Framework Core** (13) | `confidence-check` `verify` `checkpoint` `tdd` `build-fix` `audit` `gap-analysis` `feature-planner` `learn` `note` `fix-pr` `config-doctor` `eval-harness` |
| **Review & Critique** (9) | `devils-advocate` `business-panel` `brainstorm` `grill-with-docs` `security-audit` `react-best-practices` `python-best-practices` `composition-patterns` `web-design-guidelines` |
| **Design & Frontend** (24) | `ui-ux-pro-max` `frontend-design` `theme-factory` `brand-guidelines` `canvas-design` `algorithmic-art` + Impeccable 18 (`impeccable` 엔트리 + `shape` `layout` `typeset` `colorize` `animate` `delight` `polish` `critique` `design-audit` `harden` `optimize` `clarify` `distill` `quieter` `bolder` `adapt` `overdrive`) |
| **Documents & Tooling** (14) | `pdf` `pptx` `xlsx` `docx` `internal-comms` `artifacts-builder` `slack-gif-creator` `mcp-builder` `skill-creator` `webapp-testing` `agent-browser` `pytest-runner` `uv-package` `help` |

`/help`가 전체 목록을 보여줍니다.

### Agents (9개)

에이전트는 frontmatter로 `model`, `tools`, `maxTurns`, `effort`, `isolation`을 선언합니다.
범용 페르소나(architect, frontend 등)는 하네스의 general-purpose 에이전트와 model
오버라이드로 대체 가능해 두지 않았습니다. 남은 것은 프레임워크 배선에 연결되어 있거나
고유한 실행 구성을 가진 것입니다.

| Agent | 역할 | model | isolation | 배선 |
|-------|------|-------|-----------|------|
| `security-engineer` | 보안 취약점 분석 (Read-only) | opus | - | RULES.md 보안 인시던트 에스컬레이션 |
| `deep-research-agent` | 심층 리서치 (WebFetch/WebSearch) | opus | - | Deep Research 모드 (`--research`) |
| `business-panel-experts` | 9인 전문가 패널 전략 분석 | opus | - | `/business-panel` |
| `codebase-gc` | dead code·doc 동기화 점검 | haiku | - | Harness 모드 세션 종료 |
| `generator` / `validator` | 생성(worktree)과 Read-only 검증의 분리 쌍 | sonnet | worktree / - | Orchestration 모드 |
| `harness-worker` | Harness IMPLEMENT 단계 워커 | sonnet | worktree | Harness 모드 |
| `team-implementer` / `team-reviewer` | Agent Teams 구현 / 리뷰 | sonnet / opus | worktree / - | Harness TEAM·VERIFY 단계 |

### Hooks (9개 이벤트, 16개 훅)

모든 훅 스크립트는 Claude Code의 훅 계약을 따릅니다. stdin으로 이벤트 JSON을 받고,
`hookSpecificOutput.additionalContext`(컨텍스트 주입) 또는 `decision: block`(Stop 차단)으로
응답합니다. 공통 파서는 `scripts/lib/hook-common.sh`(jq → python3 폴백), 계약 테스트는
`tests/hooks/run.sh`.

| 이벤트 | 훅 | 동작 |
|--------|-----|------|
| `UserPromptSubmit` | `skill-matcher.py` | `.claude/skill-rules.json` 23개 규칙과 프롬프트·파일 패턴 매칭 → 스킬 자동 활성화/제안 |
| | `pre-compact-note.sh` | `/compact` 직전 노트 저장 여부 확인 |
| `PreToolUse` (Edit\|Write) | `suggest-compact.sh` | 세션당 도구 호출 50회 도달 시 노트 저장 + 컴팩션 제안 |
| `PostToolUse` (Edit\|Write) | `console-log-check.sh` `auto-format.sh` `convention-check.sh` | console.log 감지, Prettier, CONVENTIONS.md 네이밍 체크 |
| `PostToolUse` (mcp__*) | `injection-scanner.py` | MCP 응답의 instruction injection·데이터 유출·시크릿 패턴 |
| `Stop` | `todo-continuation.sh` | 이 세션에 미완료 TODO가 있으면 `decision: block`으로 계속 진행 (최대 10회) |
| | `circuit-breaker.sh` | 동일 에러가 10분 내 3회 반복되면 차단 + Agent Struggle Report 요구 |
| | `evaluate-session.sh` | 에러 → 해결 사이클이 있던 긴 세션에 `/learn` 제안 |
| | `session-summary.py` | `~/.claude/projects/<slug>/memory/last-session.md` 갱신 |
| `SubagentStop` | echo | 서브에이전트 결과 검증 알림 |
| `TaskCompleted` | prompt | Two-Stage Review 트리거 |
| `FileChanged` (.env*) | echo | 민감 파일 변경 경고 |
| `ConfigChange` | echo | 설정 변경 알림 |
| `InstructionsLoaded` | echo | 프레임워크 로드 배너 |

**스킬 자동 활성화 규칙** (`.claude/skill-rules.json`, 발췌):

```jsonc
{
  "skill": "react-best-practices",
  "mode": "auto",                       // auto: 즉시 실행 | suggest: 확인 후 실행
  "triggers": {
    "prompt_patterns": ["리뷰", "review", "검토해"],
    "file_patterns": ["*.jsx", "*.tsx"]  // 프로젝트에 해당 파일이 있을 때만
  },
  "cooldown": 600                        // 같은 스킬 재발동 간격(초)
}
```

auto 10개: `build-fix` `confidence-check` `verify` `checkpoint` `audit` `brainstorm`
`react-best-practices` `python-best-practices` `pytest-runner` `web-design-guidelines`.
suggest 13개: `tdd` `security-audit` `feature-planner` `learn` `impeccable` `ui-ux-pro-max` 등.
auto 활성화는 세션당 15회로 제한되고, suggest는 제한이 없습니다. 제안 강도는
`--suggest-all`(기본) `--suggest-minimal` `--suggest-off`로 조절합니다.

### Modes & Flags

| 모드 | 트리거 | 플래그 |
|------|--------|--------|
| Brainstorming | 모호한 요청, "생각중인데" | `--brainstorm` |
| Deep Research | "조사해줘", "알아봐줘" | `--research` |
| Introspection | 에러 복구, "내 추론 분석해봐" | `--introspect` |
| Orchestration | 3개 이상 파일 병렬 작업 | `--orchestrate` |
| Task Management | 3단계 이상 작업, "정리해" | `--task-manage` |
| Token Efficiency | 컨텍스트 75% 초과 | `--uc` |
| Business Panel | `/business-panel` | - |
| Harness | "에이전트한테 맡겨", "전부 자동으로" | `--harness` |

분석 깊이는 `--think`(~4K) `--think-hard`(~10K) `--ultrathink`(~32K), 상황 모드는
`--ctx dev|review|research`. 전체 정의는 `optional/FLAGS.md`.

**MCP 서버는 번들되지 않습니다.** `--c7` `--seq` `--magic` `--serena` `--tavily` 플래그는
해당 서버가 프로젝트나 머신에 설치돼 있을 때만 의미가 있고, 미설치 시 폴백
(WebFetch, `--think-hard`, `/frontend-design`, Grep, WebSearch)은 `optional/MCP_SERVERS.md`에
있습니다. `context7`만 플러그인으로 함께 켜집니다.

---

## 핵심 개념

**Build Ladder** (`PRINCIPLES.md`). 무언가를 만들기 전에 8단을 순서대로 묻고 첫 번째로
해당하는 단에서 멈춥니다. 0 존재할 필요가 있는가 → 1 이 코드베이스에 이미 있는가 →
2 stdlib → 3 플랫폼 네이티브 → 4 설치된 의존성 → 5 검증된 라이브러리 → 6 신흥 라이브러리
→ 7 직접 구현. 디버깅에는 적용하지 않습니다(최소 diff 편향이 증상 패치를 만듭니다).
사례 카탈로그는 `optional/OVERENGINEERING_TRAPS.md`.

**Circuit Breaker** (`RULES.md`, `circuit-breaker.sh`). 같은 에러가 3회 반복되면 수정을
멈추고 아키텍처 리뷰와 Agent Struggle Report(Task, 시도, 실패 분류, 권고)를 씁니다.
분류는 Repo Gap / Architecture / External / Requirement / Capability. 자동 수정은 하지
않고 사용자가 결정합니다.

**Two-Stage Review** (`RULES.md`). 리뷰어 원칙은 "구현자의 보고를 믿지 않는다". Stage 1은
요구사항 대비 누락과 과잉을, Stage 2는 코드 품질(80% 미만 확신은 Minor로 강등)을,
Complex 난이도에서만 Stage 3이 변경된 심볼의 호출부와 전체 테스트를 확인합니다.

**Harness Engineering** (`PRINCIPLES.md`). 저장소 자체가 도메인 지식의 단일 원천이어야
합니다. 의존 방향은 `Types → Config → Domain → Service → Runtime → UI` 단방향. 에이전트가
실패하면 저장소에 부족한 것(도구, 가드레일, 타입, 문서)을 진단하되 자동으로 고치지는
않습니다. `codebase-gc` 에이전트가 주기적으로 엔트로피를 점검합니다.

**PDCA** (`RULES.md`, `templates/`). Plan → Design → Do → Check → Act → Report.
`/gap-analysis`가 설계 문서와 구현을 비교해 Match Rate를 내고, 90% 미만이면 Act로
돌아갑니다(최대 5회). 산출물은 `docs/01-plan` ~ `docs/04-report`.

**DESIGN.md**. 디자인 에이전트가 읽는 시각 디자인 시스템 문서(Google Stitch 포맷).
`npx getdesign@latest add {brand}`로 66개 브랜드 중 가져오거나 `/ui-ux-pro-max
--design-system --persist`로 생성합니다. 파이프라인은 `DESIGN.md → /ui-ux-pro-max →
/frontend-design → /web-design-guidelines`. 템플릿은 `templates/visual-design.template.md`.

**Memory**. Claude Code 내장 Auto Memory(`~/.claude/projects/<slug>/memory/`)를 그대로
씁니다. 이 프레임워크는 `session-summary.py`로 마지막 세션 요약을 같은 디렉토리에 두고,
컴팩션에서 살아남아야 할 메모는 `/note`, 프로젝트 간 재사용 패턴은 `/learn`으로
분리합니다. 저장 기준은 `skills/learn/SKILL.md`.

**패키지 관리**. Python은 uv, Node.js는 pnpm만 허용합니다. `requirements.txt`, `poetry.lock`,
`package-lock.json`, `yarn.lock`이 보이면 마이그레이션을 제안합니다. Dockerfile·CI 패턴은
`CONVENTIONS.md`와 `optional/PROJECT_RULES.md`.

---

## 커스터마이즈

| 바꾸려면 | 어디를 |
|----------|--------|
| 응답 언어 | `CLAUDE.md` Language 섹션 (`ALWAYS respond in Korean` → English 등) |
| 스킬 자동 활성화 패턴·모드·쿨다운 | `.claude/skill-rules.json` |
| 훅 추가·제거 | `config/settings.json` `hooks`. 새 스크립트는 `scripts/lib/hook-common.sh`를 source |
| 상태바 | `scripts/statusline.sh` (cc-statusline 기반) |
| 플러그인 | `config/settings.json` `enabledPlugins` (설치는 Claude Code가 업스트림에서) |

변경 후 `scripts/sync-global.sh`로 글로벌에 반영하고, `bash scripts/lint.sh`로 검증합니다.

---

## 검증

이 저장소는 자기 자신의 정합성을 기계적으로 검사합니다. 문서의 개수·버전이 실제와
어긋나거나, 훅이 존재하지 않는 스크립트를 가리키면 CI가 실패합니다.

```bash
bash scripts/config-doctor.sh   # 에이전트/스킬 frontmatter, skill-rules 참조, 훅 경로·timeout 단위·
                                #   CLAUDE_* 의존, 버전·개수 정합, 문서 참조, 심볼릭 링크, bash -n/py_compile/shellcheck
bash tests/hooks/run.sh         # 실제 이벤트 JSON 픽스처로 훅 계약 검증 (27건, jq 없이도 통과)
python3 -m unittest tests/test_skill_matcher.py   # glob·지연 순회·세션 상한·쿨다운·로그 회전 (10건)
bash scripts/lint.sh            # 위 전부 + shellcheck = .github/workflows/ci.yml과 동일
```

`/config-doctor` 스킬이 첫 번째 스크립트를 실행합니다.

---

## 디렉토리 구조

```
superclaude-plusplus/
├── plugin.json                    # Plugin manifest
├── CLAUDE.md  RULES.md  PRINCIPLES.md  MODES.md  CONVENTIONS.md   # 상시 로드
├── CONTEXT.md                     # 도메인 어휘 사전 (/grill-with-docs가 갱신)
├── NOTICE.md                      # 서드파티 출처·라이선스·미채택 사유
├── CHANGELOG.md
├── config/settings.json           # 훅 16개, 권한, statusLine, 플러그인 선언
├── .claude/
│   ├── skill-rules.json           # 스킬 자동 활성화 규칙 23개
│   └── context.md                 # 프로젝트 컨텍스트
├── skills/                        # 60개 (각 SKILL.md; pptx/ooxml → docx/ooxml 심볼릭 링크)
├── agents/                        # 9개 (frontmatter: model, tools, maxTurns, effort, isolation)
├── scripts/                       # 16개
│   ├── lib/hook-common.sh         # 훅 공통: stdin 파싱, additionalContext / decision:block 출력
│   ├── skill-matcher.py           # UserPromptSubmit
│   ├── pre-compact-note.sh        # UserPromptSubmit
│   ├── suggest-compact.sh         # PreToolUse
│   ├── console-log-check.sh  auto-format.sh  convention-check.sh   # PostToolUse (Edit|Write)
│   ├── injection-scanner.py       # PostToolUse (mcp__*)
│   ├── todo-continuation.sh  circuit-breaker.sh  evaluate-session.sh  session-summary.py   # Stop
│   ├── config-doctor.sh           # 정합성 진단
│   ├── lint.sh                    # 로컬 CI
│   ├── sync-global.sh             # 프로젝트 → ~/.claude
│   └── statusline.sh              # 상태바
├── tests/
│   ├── hooks/run.sh  hooks/fixtures/*.json
│   └── test_skill_matcher.py
├── optional/                      # 28개 온디맨드 문서
│   ├── FLAGS.md  CONTEXTS.md  GOAL_PATTERNS.md  OVERENGINEERING_TRAPS.md
│   ├── REASONING_TEMPLATES.md  CONTEXT_BUDGET.md  WORKER_TEMPLATES.md  PROTOCOLS.md  PROJECT_RULES.md
│   ├── MODE_*.md (8)              # 모드별 상세
│   ├── MCP_SERVERS.md  MCP_*.md (7)   # MCP 선택 매트릭스, 서버별 가이드, 미설치 폴백
│   └── BUSINESS_PANEL_EXAMPLES.md  BUSINESS_SYMBOLS.md  RESEARCH_CONFIG.md
├── templates/                     # PDCA 4종, visual-design, context, session, notepad
└── .github/workflows/ci.yml
```

---

## 요구사항

- [Claude Code](https://docs.anthropic.com/claude-code) CLI 2.1.139 이상 (`/goal`). `security-guidance` 플러그인은 2.1.144 이상
- Claude 구독 또는 Anthropic API 키
- Python 3.9 이상 (`skill-matcher.py`, `injection-scanner.py`, `session-summary.py`, 훅의 jq 폴백)
- `jq` (선택. 없으면 python3 폴백)
- `pnpm` (LSP 바이너리 설치용), `shellcheck` (선택. lint.sh)

| 플랫폼 | 지원 |
|--------|------|
| macOS (Intel / Apple Silicon) | Full. 기본 개발·테스트 환경 |
| Linux | Full |
| Windows + WSL2 | Full |
| Windows 네이티브 | 미지원. 훅이 Bash 스크립트 |

---

## 업데이트 / 삭제

```bash
# 업데이트
/plugin update superclaude-plusplus            # Plugin
git pull && scripts/sync-global.sh             # Manual (삭제된 파일도 글로벌에서 정리)

# 삭제
/plugin uninstall superclaude-plusplus         # Plugin
rm -f  ~/.claude/{CLAUDE,RULES,PRINCIPLES,MODES,CONVENTIONS}.md ~/.claude/skill-rules.json
rm -rf ~/.claude/optional ~/.claude/scripts
for d in skills/*/;  do rm -rf ~/.claude/skills/$(basename "$d"); done   # 이 저장소 스킬만
for f in agents/*.md; do rm -f  ~/.claude/agents/$(basename "$f"); done  # 이 저장소 에이전트만
# ~/.claude/settings.json의 hooks·statusLine·enabledPlugins 항목은 직접 정리
```

`~/.claude` 전체를 지우면 메모리·세션·개인 설정까지 사라지니 위처럼 선택 삭제하세요.

---

## 버전 히스토리

| 버전 | 핵심 |
|------|------|
| **3.3** (2026-09) | 훅 전부를 Claude Code 훅 계약에 맞게 재작성(이전에는 상당수가 no-op). sync-global이 스크립트·스킬·에이전트를 실제로 설치. config-doctor.sh + 훅 계약 테스트 + CI. 공식 플러그인 5종 참조 선언 |
| **3.1 ~ 3.2** (2026-08) | Build Ladder 8단, 과설계 함정 카탈로그, fluent-korean output style |
| **3.0** (2026-07) | harness-aware slim. 상시 로드 -66%, 스킬 139 → 60, 에이전트 23 → 9 |
| **2.0 ~ 2.3** (2026-04~05) | 시스템 강제 패러다임: skill-rules 훅, AGENT.md frontmatter, Circuit Breaker, `/goal` 위임, `/grill-with-docs` |
| **0.9.x** (2026-02~03) | Karpathy Guidelines, Harness Engineering, oh-my-agent 프로토콜 통합 |

상세는 [CHANGELOG.md](CHANGELOG.md).

---

## 출처

이 프로젝트는 [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)를
기반으로 개인 사용에 맞게 확장한 것입니다. 벤더링한 스킬과 차용한 개념의 라이선스·출처·
미채택 사유는 [NOTICE.md](NOTICE.md)가 단일 원천이며, 아래는 요약입니다.

| 출처 | 가져온 것 |
|------|-----------|
| [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) | 프레임워크 구조, 모드 시스템 |
| [Karpathy Guidelines](https://github.com/forrestchang/andrej-karpathy-skills) | 가정 투명성, 서지컬 변경, 단순성 우선 |
| [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) | Repository as Knowledge Base, Dependency Flow, Struggle = Signal |
| [oh-my-agent](https://github.com/first-fluke/oh-my-agent) | 난이도 분기, 추론 템플릿, 컨텍스트 예산, Cascade Impact Review |
| [gstack](https://github.com/garrytan/gstack) | Search Before Building(→ Build Ladder), LLM Security Audit |
| [ponytail](https://github.com/DietrichGebert/ponytail) | Decision Ladder의 조기 종료 구조, 과설계 함정 (개념만) |
| [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | TDD RED/GREEN Gate, Confidence-Based Review Filtering |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `/grill-with-docs` 포팅, 인터뷰 행동 규칙 |
| [Antigravity Kit](https://github.com/vudovn/antigravity-kit) | Brainstorming Questioning Principles |
| [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | BM25 디자인 인텔리전스 (67 스타일, 96 팔레트, 57 폰트, 100 규칙, 13 스택) |
| [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | DESIGN.md 66 브랜드 컬렉션 |
| [Impeccable](https://github.com/pbakaus/impeccable) | Design Language 스킬 18개 (Apache 2.0) |
| [Vercel Labs](https://github.com/vercel-labs/agent-skills) | React Best Practices, Composition Patterns, Web Interface Guidelines |
| [anthropics/skills](https://github.com/anthropics/skills) | docx/pdf/pptx/xlsx, frontend-design, skill-creator, theme-factory 등 |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | 플러그인 4종 참조 선언, `/learn` 저장 기준(claude-md-management) |
| [snflkd/fluent-korean](https://github.com/snflkd/fluent-korean) | 한국어 output style |
| [cc-statusline](https://www.npmjs.com/package/@chongdashu/cc-statusline) | 상태바 |
| [claude-code-infrastructure-showcase](https://github.com/diet103/claude-code-infrastructure-showcase), [Ralph](https://github.com/frankbria/ralph-claude-code), [Superpowers](https://github.com/obra/superpowers), [parry](https://github.com/vaporif/parry) | skill-rules 훅 설계, Circuit Breaker, Two-Stage Review, injection scanner 참조 |

---

## License

MIT License - see [LICENSE](LICENSE).
