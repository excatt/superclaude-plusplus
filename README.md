# SuperClaude++ v3.0

Claude Code를 위한 harness-aware 개발 프레임워크 - 60개 스킬, 9개 에이전트, 16개 훅 타입. 모델이 못 하는 것만 남기고 자동화합니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## About

SuperClaude++는 [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)를 기반으로 개인 사용에 맞게 확장한 프로젝트입니다. 원본 SuperClaude의 강력한 구조 위에 다양한 커뮤니티 베스트 프랙티스, 자동화 워크플로우, 전문가 에이전트 시스템을 통합하여 Claude Code의 잠재력을 최대한 끌어냅니다.

### v2.0 패러다임 전환

```
v0.x: "Claude야, 이 규칙 읽고 따라줘"  (prompt-dependent)
v2.0: "시스템이 규칙을 강제한다"         (system-enforced)
```

v0.x에서는 CLAUDE.md에 규칙을 적어두고 Claude가 이를 읽고 따르기를 기대했습니다. v2.0에서는 `skill-rules.json` + `settings.json` 훅 시스템이 규칙 실행을 **기계적으로 강제**합니다. Circuit Breaker가 동일 에러 3회 반복을 자동 차단하고, Prompt Injection Scanner가 MCP 응답을 실시간 검사하며, Skill Matcher가 프롬프트 패턴에 따라 스킬을 자동 활성화합니다.

**태그라인**: Harness Engineering이 자기 자신에게 적용되는 프레임워크

### v3.0 패러다임 전환

```
v2.0: "시스템이 규칙을 강제한다"           (system-enforced)
v3.0: "모델이 못 하는 것만 남긴다"          (harness-aware slim)
```

Claude 5 세대(Fable/Opus 5)부터는 검증 후 완료 선언, 지속 실행, 스코프 절제,
병렬 도구 호출 같은 행동이 하네스와 모델에 내재화되었습니다. v3.0은 이런
중복 규정을 상시 로드에서 제거하고, **모델이 스스로 알 수 없는 것**(프로젝트
사실, 컨벤션, 사용자 선호, 하네스 기본값 오버라이드)과 **결정적 기계 장치**
(훅, Circuit Breaker)만 남깁니다. 상시 로드 ~9,000단어 → ~2,000단어.
프로세스 지식은 `optional/`과 스킬로 강등되어 필요할 때만 로드됩니다.

## Features

### Core Framework (상시 로드, v3.0에서 4+1개로 축소)
| 파일 | 설명 |
|------|------|
| **CLAUDE.md** | 엔트리 포인트 및 언어 설정 (한국어) |
| **RULES.md** | 하네스 오버라이드 + 모델이 모르는 규칙만 (난이도 평가, Circuit Breaker, 프로젝트 규칙) |
| **PRINCIPLES.md** | 적용 시점 선호만 (Complexity Timing, Build Ladder, Harness Engineering) |
| **MODES.md** | 모드 Quick Reference (상세는 `optional/MODE_*.md`) |
| **CONVENTIONS.md** | 네이밍 컨벤션 + 패키지 관리 규칙 (uv/pnpm 필수) |

온디맨드(`optional/`)로 이동: **FLAGS.md**(플래그 정의), **CONTEXTS.md**(컨텍스트 모드),
**MCP_SERVERS.md**(MCP 선택 매트릭스), **PATTERNS.md**(코드 패턴).
**KNOWLEDGE.md**는 v3.0에서 제거 (근거 없는 수치와 모델 기본값 중복).

### Agent System (9개, v3.0에서 23개 → 9개로 통폐합)

에이전트는 AGENT.md frontmatter로 정의됩니다. `model`, `tools`, `maxTurns`,
`effort`, `isolation` 등의 속성을 선언적으로 지정하여, 에이전트 행동이
프롬프트 의존이 아닌 시스템 수준에서 제어됩니다.

v3.0에서 **범용 페르소나 14개 삭제** (backend/frontend/system/devops-architect,
performance/quality-engineer, python/refactoring-expert, root-cause-analyst,
requirements-analyst, technical-writer, learning-guide, socratic-mentor,
pm-agent) — 하네스의 general-purpose + model 오버라이드로 동일하게 수행
가능한 역할 래퍼였습니다. 잔존 기준은 스킬과 동일: 프레임워크 배선(RULES/
MODES/스킬)에 연결되어 있거나 고유한 실행 구성(worktree 격리, 팀 구성)을
갖는 것.

```yaml
# 예시: agents/harness-worker.md
---
name: harness-worker
model: sonnet
tools: Read, Grep, Glob, Write, Edit, Bash
disallowedTools: Agent
maxTurns: 30
effort: high
isolation: worktree
skills: [verify]
---
```

| Agent | 역할 | model | isolation | 배선 |
|-------|------|-------|-----------|------|
| `security-engineer` | 보안 취약점 분석 (Read-only) | opus | - | RULES.md 보안 인시던트 에스컬레이션 |
| `deep-research-agent` | 심층 리서치 (WebFetch/WebSearch) | opus | - | Deep Research 모드 |
| `business-panel-experts` | 비즈니스 전략 분석 (9명 전문가 패널) | opus | - | `/business-panel` 스킬 |
| `codebase-gc` | 코드베이스 정리 (dead code, doc-code 동기화) | haiku | - | Harness 모드 세션 종료 GC |
| `generator` | Generator+Validator 쌍 - 코드 생성 | sonnet | worktree | Orchestration 모드 |
| `validator` | Generator+Validator 쌍 - Read-only 검증 | sonnet | - | Orchestration 모드 |
| `harness-worker` | Harness IMPLEMENT phase 워커 | sonnet | worktree | Harness 모드 |
| `team-implementer` | Agent Teams 구현 담당 | sonnet | worktree | Harness TEAM phase |
| `team-reviewer` | Agent Teams 리뷰 담당 (Read-only) | opus | - | Harness VERIFY phase |

### Skills (60개, v3.0에서 139개 → 60개로 통폐합)

v3.0에서 모델이 네이티브로 수행하는 **주제 가이드 51개**(architecture, caching,
docker, graphql, naming, nextjs, ... "○○ 가이드를 실행합니다"형)와 **범용 명령
래퍼 28개**(analyze, implement, improve, think, cleanup, load/save, pm, ...)를
삭제했습니다. 스킬 메타데이터는 idle에도 컨텍스트에 상주하므로, "모델이 이미
할 수 있는 것"의 스킬화는 순비용이기 때문입니다.

**잔존 기준**: ① 기계 장치·데이터 보유(BM25 검색, Git 체크포인트, 훅 연동),
② 프레임워크 워크플로우 코어, ③ 검증된 큐레이션 콘텐츠(Vercel 가이드라인 등),
④ 서드파티 벤더 스킬(출처 추적성 유지).

#### Framework Core (13개)
`confidence-check` `verify` `checkpoint` `tdd` `build-fix` `audit`
`gap-analysis` `feature-planner` `learn` `note` `fix-pr` `config-doctor`
`eval-harness`

#### Review & Critique (9개)
`devils-advocate` `business-panel` `brainstorm` `grill-with-docs`
`security-audit` `react-best-practices` `python-best-practices`
`composition-patterns` `web-design-guidelines`

#### Design & Frontend (24개)
`ui-ux-pro-max` `frontend-design` `theme-factory` `brand-guidelines`
`canvas-design` `algorithmic-art` + Impeccable Design Language 18개
(`impeccable` 엔트리 + 17개 서브커맨드, Apache 2.0)

#### Documents & Tooling (14개)
`pdf` `pptx` `xlsx` `document-skills` `internal-comms` `artifacts-builder`
`slack-gif-creator` `mcp-builder` `skill-creator` `webapp-testing`
`agent-browser` `pytest-runner` `uv-package` `help`

### Automation

#### Skill Auto-Activation (v2.0 핵심)

v2.0에서 스킬 자동 활성화는 `.claude/skill-rules.json`에 선언적으로 정의되고, `scripts/skill-matcher.py`가 `UserPromptSubmit` 훅으로 실행하여 프롬프트 패턴을 매칭합니다. Claude의 판단에 의존하던 v0.x와 달리, 기계적으로 트리거됩니다.

```jsonc
// .claude/skill-rules.json (발췌) — 23 rules (v3.0: 삭제 스킬 규칙 정리)
{
  "skill": "build-fix",
  "mode": "auto",
  "triggers": {
    "prompt_patterns": [
      "error TS\\d+", "Build failed",
      "빌드 에러", "빌드 실패", "에러 났어", "안 돌아가"
    ]
  },
  "cooldown": 300
}
```

**Auto-Invoke 스킬** (확인 없이 즉시 실행):
- `build-fix` - 빌드 에러 패턴 감지 시
- `confidence-check` - 구현 키워드 + 난이도 Medium 이상
- `verify` - 완료/커밋 키워드 감지 시
- `checkpoint` - 리팩토링/삭제 키워드 감지 시
- `react-best-practices` - .jsx/.tsx + 리뷰 키워드
- `python-best-practices` - .py + 리뷰 키워드

**Suggest 스킬** (확인 후 실행):
- `tdd` - 버그 수정 + tests/ 디렉토리 존재 시
- `security-audit` - 보안 관련 키워드/파일 패턴 감지 시

전체 규칙은 `.claude/skill-rules.json` 참조.

#### Proactive Suggestions
작업 컨텍스트에 맞는 스킬/에이전트/MCP 서버를 적극 제안 (확인 후 실행):

| 상황 | 제안 도구 | 트리거 조건 |
|------|----------|-------------|
| 보안 관련 | `security-engineer`, `/security-audit` | 로그인, JWT, 보안, LLM 보안 |
| 프레임워크 | **Context7** MCP | React, Next.js, Vue |
| UI 컴포넌트 | **Magic** MCP | button, form, modal |
| 복잡한 분석 | **Sequential** MCP | 디버깅 3회+, 설계 |
| 프로젝트 규칙 검증 | `/audit` | commit, PR + `.claude/audit-rules/` 존재 시 |
| 테스트 가능 기능 | `/tdd` | 새 기능 + tests/ 존재, 버그 수정 |
| UI/UX 디자인 | `/ui-ux-pro-max` | landing page, 디자인 시스템 |

**제안 강도 플래그**: `--suggest-all` (기본) | `--suggest-minimal` | `--suggest-off`

#### Hook System (16개 타입)

`config/settings.json`에서 16개 훅 타입을 통해 자동화를 구성합니다.

| Hook Type | 역할 |
|-----------|------|
| `UserPromptSubmit` | 프롬프트 제출 시 skill-matcher 실행, 사전 노트 저장 |
| `PostToolUse` | 파일 작성 후 타입 체크, 포맷팅, 컨벤션 체크, injection 스캔 |
| `PreToolUse` | 편집 전 컴팩션 제안 |
| `Stop` | TODO 미완료 방지, 세션 평가, circuit breaker |
| `SessionStart` | 세션 시작 알림 |
| `SessionEnd` | 세션 종료 알림 |
| `SubagentStart` | 서브에이전트 시작 알림 |
| `SubagentStop` | 서브에이전트 종료 + 결과 품질 게이트 |
| `TaskCompleted` | 자동 Two-Stage Review 트리거 |
| `PreCompact` | 컴팩션 전 상태 보존 |
| `Notification` | 알림 이벤트 |
| `PermissionRequest` | 권한 요청 이벤트 |
| `PostToolUseFailure` | 도구 실행 실패 시 알림 |
| `FileChanged` | .env 파일 등 민감 파일 변경 경고 |
| `ConfigChange` | 설정 변경 시 유효성 검증 |
| `InstructionsLoaded` | 프로젝트별 설정 자동 적용 |

#### v2.0 안전장치

| 기능 | 설명 |
|------|------|
| **Circuit Breaker** | 동일 에러 3회 반복 감지 시 자동 중단 + Architecture Alert (Stop 훅) |
| **Prompt Injection Scanner** | MCP 응답에서 instruction injection, data exfiltration 패턴 스캔 (PostToolUse 훅) |
| **Skill Matcher** | 프롬프트 패턴 기반 스킬 자동 활성화 (UserPromptSubmit 훅) |
| **Config Doctor** | AGENT.md frontmatter, skill-rules.json, 훅 경로 유효성 검증 |

### Sound Notifications (peon-ping)

[peon-ping](https://github.com/PeonPing/peon-ping) 연동으로 AI 코딩 에이전트 이벤트를 게임 캐릭터 음성으로 알림합니다.

| 기능 | 설명 |
|------|------|
| **오디오 알림** | 작업 완료, 에러, 입력 요청 시 게임 캐릭터 보이스 재생 |
| **데스크톱 오버레이** | macOS JXA 기반 화면 상단 배너 (멀티스크린 지원) |
| **모바일 푸시** | ntfy.sh / Pushover / Telegram 연동 |
| **MCP 서버** | Claude가 대화 중 `play_sound` tool로 직접 사운드 재생 |

**설치된 사운드 팩**: Orc Peon, Human Peasant, GLaDOS (Portal), Sarah Kerrigan (StarCraft), Battlecruiser

**Quick controls**:
```bash
peon toggle           # 음소거/해제
peon volume 0.7       # 볼륨 조절
peon packs use glados # 팩 변경
/peon-ping-toggle     # Claude Code 내에서 토글
```

### Flags & Modes

전체 플래그 정의는 `optional/FLAGS.md` (v3.0부터 온디맨드 로드).

#### Analysis Depth
| Flag | 토큰 | 용도 |
|------|------|------|
| `--think` | ~4K | 중간 복잡도 |
| `--think-hard` | ~10K | 아키텍처 분석 |
| `--ultrathink` | ~32K | 시스템 재설계 |

#### MCP Server Flags
| Flag | 서버 | 용도 |
|------|------|------|
| `--c7` | Context7 | 공식 문서 조회 |
| `--magic` | Magic | UI 컴포넌트 생성 |
| `--seq` | Sequential | 다단계 추론 |
| `--serena` | Serena | 시맨틱 코드 이해 |
| `--tavily` | Tavily | 웹 검색/리서치 |

#### Context Modes
| Flag | 모드 | 특성 |
|------|------|------|
| `--ctx dev` | 개발 | 작동 > 완벽, 코드 먼저 |
| `--ctx review` | 리뷰 | 심층 분석, 심각도별 정리 |
| `--ctx research` | 리서치 | 완전성 > 속도, 증거 기반 |

#### Harness Mode
| Flag | 용도 |
|------|------|
| `--harness` | 에이전트 주도 구현 (5-Phase: Intent - Scaffold - Implement - Verify - Deliver) |
| `--harness --orchestrate` | 병렬 에이전트 최대 활용 |
| `--harness --safe-mode` | 모든 Phase에서 사용자 확인 (`/goal` 비호환) |
| `--harness` + `/goal` | DELIVER 조건을 검증 가능한 명령으로 표현, 자율 루프 활성화 (v2.2 신규, 상세: `optional/GOAL_PATTERNS.md`) |

#### Proactive Suggestion Flags
| Flag | 설명 |
|------|------|
| `--suggest-all` | 모든 관련 도구 적극 제안 (기본값) |
| `--suggest-minimal` | 핵심 도구만 제안 |
| `--suggest-off` | 자동 제안 비활성화 |
| `--auto-agent` | 에이전트 자동 제안 활성화 |
| `--auto-mcp` | MCP 서버 자동 활성화 제안 |

## Installation

### Plugin Install (권장)

```bash
/plugin install github:excatt/superclaude-plusplus
```

Claude Code 내에서 위 명령어를 실행하면 `plugin.json` 매니페스트에 따라 스킬, 에이전트, 훅, 스크립트가 자동 설치됩니다.

### Manual Install

```bash
git clone https://github.com/excatt/superclaude-plusplus.git
cd superclaude-plusplus
scripts/sync-global.sh
```

### 설치 후
1. **Claude Code 재시작** - 변경 사항 적용
2. `/config-doctor` - 설정 유효성 검증
3. `/note --show` - 노트 시스템 확인
4. 기존 `settings.json`이 있었다면 hooks 설정 병합 필요

## Directory Structure

```
superclaude-plusplus/                # 프로젝트 저장소 (source of truth)
├── plugin.json                     # Plugin manifest (설치 진입점)
├── CLAUDE.md                       # 메인 엔트리 포인트
├── RULES.md                        # 행동 규칙 (v3.0: 오버라이드+비추론 사실만)
├── PRINCIPLES.md                   # 엔지니어링 원칙 (v3.0: 적용 선호만)
├── MODES.md                        # 행동 모드 Quick Reference
├── CONVENTIONS.md                  # 네이밍 컨벤션
├── notepad.md                      # 영구 메모
├── skills/                         # 60개 스킬 (각각 SKILL.md)
│   ├── confidence-check/SKILL.md
│   ├── verify/SKILL.md
│   ├── tdd/SKILL.md
│   ├── config-doctor/SKILL.md      # v2.0 신규
│   ├── fix-pr/SKILL.md             # v2.0 신규
│   ├── ui-ux-pro-max/              # AI 디자인 인텔리전스 (BM25 검색)
│   ├── web-design-guidelines/      # UI/UX 리뷰
│   ├── impeccable/                 # Impeccable Design Language 엔트리 (+ 17 서브)
│   ├── grill-with-docs/            # v2.3 신규 (도메인 stress-test, MIT)
│   └── ...                         # 60개 스킬 디렉토리
├── agents/                         # 9개 에이전트 (AGENT.md frontmatter)
│   ├── security-engineer.md
│   ├── generator.md                # Generator+Validator 쌍
│   ├── validator.md                # Generator+Validator 쌍
│   ├── harness-worker.md           # v2.0 신규 (Worktree 워커)
│   ├── team-implementer.md         # v2.0 신규 (Agent Teams)
│   ├── team-reviewer.md            # v2.0 신규 (Agent Teams)
│   └── ...                         # 9개 에이전트 정의
├── scripts/                        # 17개 자동화 스크립트
│   ├── skill-matcher.py            # v2.0: UserPromptSubmit hook 핸들러
│   ├── circuit-breaker.sh          # v2.0: 에러 반복 자동 차단
│   ├── injection-scanner.py        # v2.0: MCP injection 방어
│   ├── statusline.sh               # 상태바 스크립트
│   ├── checklist.sh                # 프로젝트 검증 (P0-P4)
│   ├── convention-check.sh         # 네이밍 컨벤션 자동 체크
│   ├── type-check.sh               # 타입 체크
│   ├── auto-format.sh              # 자동 포맷팅
│   ├── session-summary.py          # 세션 요약 자동 생성
│   └── ...                         # 17개 스크립트
├── config/                         # 설정 파일
│   ├── settings.json               # 16개 hook 타입 + 권한 + MCP 설정
│   └── peon-ping.json              # peon-ping 설정 (포터블)
├── .claude/                        # Claude Code 내부 설정
│   ├── skill-rules.json            # v2.0: 스킬 자동 활성화 규칙
│   ├── settings.local.json         # 로컬 설정 오버라이드
│   ├── context.md                  # 프로젝트 컨텍스트
│   └── state/                      # 세션 상태 저장
├── optional/                       # 29개 선택적 로딩 문서
│   ├── FLAGS.md                    # v3.0 이동: 플래그 정의
│   ├── CONTEXTS.md                 # v3.0 이동: DEV/REVIEW/RESEARCH 컨텍스트 모드
│   ├── MCP_SERVERS.md              # v3.0 이동: MCP 선택 매트릭스
│   ├── MCP_*.md                    # MCP 서버별 상세 가이드 (7개)
│   ├── MODE_*.md                   # MODE별 상세 가이드 (8개)
│   ├── REASONING_TEMPLATES.md      # 구조화된 추론 템플릿
│   ├── CONTEXT_BUDGET.md           # 컨텍스트 예산 관리
│   ├── WORKER_TEMPLATES.md         # 워커 에이전트 프롬프트 템플릿
│   ├── GOAL_PATTERNS.md            # /goal 조건 패턴, 안티 패턴, /loop vs /goal 결정표
│   ├── OVERENGINEERING_TRAPS.md    # v3.1 신규: Build Ladder 적용 규칙 3종 + rung 3 사례 카탈로그
│   └── ...                         # PATTERNS, PROTOCOLS, PROJECT_RULES 등
├── docs/
│   └── PLAN-v2.0.md                # v2.0 마이그레이션 계획
└── templates/                      # PDCA + 디자인 시스템 템플릿
    ├── plan.template.md
    ├── design.template.md
    ├── visual-design.template.md   # DESIGN.md 템플릿 (Google Stitch 9-section)
    ├── analysis.template.md
    └── report.template.md
```

## Key Concepts

### v2.0 Core: System-Enforced Automation

v2.0의 핵심은 Claude의 자율 판단 의존을 줄이고, 시스템이 규칙을 강제하는 것입니다.

| 영역 | v0.x (prompt-dependent) | v2.0 (system-enforced) |
|------|------------------------|----------------------|
| 스킬 트리거 | CLAUDE.md 키워드 테이블 | `skill-rules.json` + `UserPromptSubmit` hook |
| 에이전트 설정 | 프롬프트 텍스트 | AGENT.md frontmatter (model, effort, isolation) |
| 검증 자동화 | "리뷰해줘" 요청 | `TaskCompleted` hook -> auto Two-Stage Review |
| 안전장치 | 3회 실패 규칙 (Claude 판단) | Circuit breaker hook (기계적 중단) |
| 스킬 컨텍스트 | 정적 텍스트 | Dynamic Context Injection |
| 병렬 작업 | 프롬프트 "background로" | Worktree 격리 + Agent Teams |
| 배포 | ~~install.sh~~ | Plugin manifest (`/plugin install`) |
| 스킬 구조 | ~~commands/~~ + skills/ 분리 | **skills/ 단일 디렉토리** (v3.0: 60개) |

### Generator + Validator 패턴

v2.0에서 도입된 에이전트 쌍 패턴입니다. Generator가 Worktree에서 코드를 생성하고, Validator가 Read-only로 검증합니다.

```
Generator (worktree) -> 생성 완료 -> Validator (Read-only 검증) -> Pass/Fail -> 수정/완료
```

- Generator는 Write/Edit 가능, Validator는 Read/Grep/Bash만 허용
- 생성과 검증의 관심사 분리로 품질 향상

### Worktree Isolation

병렬 에이전트가 서로의 작업에 영향을 주지 않도록 Git worktree로 격리합니다.

```
Orchestrator (main context)
    |
    ├─ Agent(isolation: worktree) -> Feature A
    ├─ Agent(isolation: worktree) -> Feature B
    └─ Agent(isolation: worktree) -> Feature C
    |
    └─ Merge results -> Two-Stage Review
```

### Agent Teams (실험적)

Claude Code의 Agent Teams 기능과 통합하여 팀 단위 자율 작업을 지원합니다.

```
Team Lead (Orchestrator)
    |
    ├─ Teammate: implementer (worktree, sonnet)
    ├─ Teammate: reviewer (Read-only, opus)
    └─ Teammate: tester (sonnet)
```

활성화: `settings.json`에서 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### DESIGN.md (Visual Design System)

AI 에이전트가 읽는 디자인 시스템 문서 ([Google Stitch format](https://stitch.withgoogle.com/docs/design-md/overview/)). 프로젝트 루트에 `DESIGN.md`를 배치하면 에이전트가 일관된 UI를 생성합니다.

| File | 독자 | 정의 |
|------|------|------|
| `AGENTS.md` | 코딩 에이전트 | 프로젝트를 어떻게 빌드하는지 |
| `DESIGN.md` | 디자인 에이전트 | 프로젝트가 어떻게 보이는지 |

**사용 방법**:
```bash
npx getdesign@latest add vercel    # 66개 브랜드 중 선택 (vercel, stripe, linear.app 등)
npx getdesign@latest list          # 전체 목록
```

**디자인 파이프라인**:
```
DESIGN.md (source of truth) → /ui-ux-pro-max → /frontend-design → /web-design-guidelines
```

- **커스텀 생성**: `/ui-ux-pro-max --design-system --persist`
- **템플릿**: `templates/visual-design.template.md` (9-section Stitch format)
- **컬렉션**: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (66 brands)

### PDCA Workflow
체계적인 개발 사이클을 위한 Plan-Do-Check-Act 워크플로우:
```
Plan -> Design -> Do -> Check -> Act -> Report
```
- **Match Rate 기반 품질 게이트**: >=90% 통과, 70-89% 자동 수정, <70% 설계 재검토
- **Gap Analysis**: 설계 문서와 구현 코드 자동 비교
- **템플릿 제공**: `plan.template.md`, `design.template.md`, `analysis.template.md`, `report.template.md`

### Two-Stage Review System
작업 완료 시 `TaskCompleted` 훅에 의해 자동 트리거됩니다.

| Stage | 목적 | 검증 항목 |
|-------|------|----------|
| **Stage 1: Spec Compliance** | 요구사항 준수 | 누락 기능, 과잉 구현, 스펙 일치 |
| **Stage 2: Code Quality** | 코드 품질 | Critical/Important/Minor 이슈 |
| **Stage 3: Cascade Impact** | 연쇄 영향 (Complex 전용) | 다른 모듈/기능 깨짐 여부 |

- **Reviewer 원칙**: "DO NOT trust the implementer's report" - 실제 코드 직접 확인
- **Confidence Filter**: 80% 미만 신뢰도 이슈는 Minor(informational)로 분류

### Verification Iron Law
```
"NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE"
```

v3.0부터 별도 규칙 섹션이 아닙니다 — Claude 5 세대에서 검증 후 완료 선언은
모델 내재 행동이 되었기 때문입니다. 개념은 `CONTEXT.md` 어휘 사전에
존속하며, `/goal`의 soft check가 이 원칙을 대체하지 않는다는 경계로
쓰입니다.

### 3+ Fixes Architecture Rule + Circuit Breaker
동일 버그 3회 수정 실패 시:
1. **Circuit Breaker가 기계적으로 차단** (v2.0: Stop 훅에서 자동 감지)
2. 아키텍처/설계 재검토
3. **Agent Struggle Report 생성** (Failure Classification + Repo 개선 제안)
4. 사용자에게 보고서와 함께 방향 확인

**Failure Classification**: Repo Gap / Architecture Issue / External Dependency / Requirement Issue / Capability Limit

### Orchestrator/Worker Pattern
에이전트 역할 분리를 통한 효율적인 작업 분배. Orchestrator는 작업 분해와
결과 합성만, Worker는 실행만 담당합니다. v3.0부터 상시 규칙이 아니라
`CONTEXT.md` 어휘 + `optional/WORKER_TEMPLATES.md`(프롬프트 템플릿)로
온디맨드 제공됩니다.

### Harness Engineering
[OpenAI의 Harness Engineering](https://openai.com/index/harness-engineering/) 방법론에서 영감을 받은 에이전트 주도 개발 환경:

**핵심 원칙**:
- **Repository as Knowledge Base**: 레포 자체가 에이전트의 도메인 지식 원천
- **Dependency Flow**: `Types -> Config -> Domain -> Service -> Runtime -> UI` 단방향 강제
- **Struggle = Signal**: 에이전트 실패 시 레포에 부족한 것을 진단 (자동 수정 금지)
- **Codebase GC**: 주기적 dead code/import/doc 일관성 점검

**Harness Mode** (`--harness`):
```
Intent -> Scaffold -> Implement -> Verify -> Deliver
  (사용자)   (에이전트+확인)  (에이전트 자율)  (자동검증)   (합류)
```

### Memory Management
Claude Code의 내장 Auto Memory를 활용한 세션 간 연속성. v3.0부터 하네스가
메모리 지침을 직접 주입하므로 CLAUDE.md의 중복 규정은 제거되었습니다:

**Auto Memory** (`~/.claude/projects/<project>/memory/`):
- 프로젝트 패턴, 디버깅 인사이트, 아키텍처 노트 자동 저장
- 세션 시작 시 MEMORY.md 자동 로드 (첫 200줄)

**명시적 저장 요청**:
```
"이 프로젝트는 pnpm 사용한다고 기억해"
"API 테스트는 로컬 Redis 필요하다고 저장해"
```

**CLAUDE.md 계층**:
| 용도 | 위치 |
|------|------|
| 팀 공유 규칙 | `./CLAUDE.md`, `.claude/rules/` |
| 개인 전역 | `~/.claude/CLAUDE.md` |
| 개인 프로젝트 | `./CLAUDE.local.md` |

### Package Management Rules
프로젝트별 패키지 매니저 강제:

| 언어 | 필수 | 금지 |
|------|------|------|
| **Python** | uv | pip, poetry, pipenv |
| **Node.js** | pnpm | npm, yarn |

- 자동 감지: `requirements.txt`, `poetry.lock`, `package-lock.json`, `yarn.lock` 발견 시 마이그레이션 제안
- Dockerfile/CI 패턴 예시 포함

## Configuration

### Language
기본값: 한국어

CLAUDE.md에서 변경:
```markdown
## Language
- **ALWAYS respond in English**
```

### Skill Rules Customization
`.claude/skill-rules.json`에서 스킬 자동 활성화 규칙을 편집할 수 있습니다.

### Hooks Customization
`config/settings.json`의 `hooks` 섹션에서 훅 스크립트 추가/제거 가능.

### StatusLine
`scripts/statusline.sh`를 수정하여 표시 항목 커스터마이즈.

### Config Validation
```bash
/config-doctor    # 설정 유효성 검증
```

## Updating

```bash
# Plugin 방식
/plugin update superclaude-plusplus

# Manual 방식
cd superclaude-plusplus
git pull
scripts/sync-global.sh
```

## Uninstall

```bash
# Plugin 방식
/plugin uninstall superclaude-plusplus

# Manual 방식 — 주의: ~/.claude 전체 삭제는 메모리/세션/개인 설정까지 지웁니다.
# 프레임워크 파일만 선택 제거:
rm -f ~/.claude/{CLAUDE,RULES,PRINCIPLES,MODES,CONVENTIONS}.md
rm -rf ~/.claude/optional ~/.claude/skills ~/.claude/agents
rm -f ~/.claude/skill-rules.json
```

## Requirements

- [Claude Code](https://docs.anthropic.com/claude-code) CLI (>= 2.1.139, `/goal` 통합 요건)
- Claude Max/Pro 구독 또는 Anthropic API 키
- Python 3.9+ (skill-matcher.py, injection-scanner.py 실행용)
- `jq` (선택사항, 일부 스크립트에서 사용)

### Platform Support

| 플랫폼 | 지원 수준 | 비고 |
|---------|-----------|------|
| **macOS** (Intel/Apple Silicon) | Full | 기본 개발/테스트 환경 |
| **Linux** (Ubuntu, Debian 등) | Full | - |
| **Windows + WSL2** | Full | WSL2 내에서 실행 시 완전 호환 |
| **Windows (네이티브)** | Not Supported | hook 시스템이 Bash 스크립트 기반으로 동작 불가 |

> **Windows 사용자**: WSL2 (Windows Subsystem for Linux) 환경에서 실행해 주세요. 14개 hook 스크립트가 Bash 기반이므로 네이티브 Windows(cmd.exe, PowerShell)에서는 hook 시스템이 작동하지 않습니다. Git Bash는 부분적으로 동작할 수 있으나 공식 지원하지 않습니다.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Credits & Acknowledgements

### Special Thanks

이 프로젝트는 [**SuperClaude Framework**](https://github.com/SuperClaude-Org/SuperClaude_Framework)의 뛰어난 기반 위에 구축되었습니다. SuperClaude 팀의 혁신적인 접근 방식과 잘 설계된 아키텍처 덕분에 이 확장이 가능했습니다.

> *"거인의 어깨 위에 서서 더 멀리 본다"* - SuperClaude가 그 거인입니다.

### Inspirations & Integrations

- **[SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)** - 핵심 프레임워크 구조 및 모드 시스템
- **[Karpathy Guidelines](https://github.com/forrestchang/andrej-karpathy-skills)** - LLM 코딩 행동 규칙 (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution). [Andrej Karpathy의 관찰](https://x.com/karpathy/status/2015883857489522876)에서 파생
- **[Harness Engineering](https://openai.com/index/harness-engineering/)** - OpenAI의 에이전트 주도 개발 방법론 (Repository as Knowledge Base, Dependency Flow, Struggle = Signal, Codebase GC). [Martin Fowler의 분석](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) 참조
- **[UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)** - BM25 기반 UI/UX 디자인 인텔리전스 (67 스타일, 96 팔레트, 57 폰트, 100 추론 규칙, 13 스택). MIT License
- **[awesome-design-md](https://github.com/VoltAgent/awesome-design-md)** - 66개 브랜드 디자인 시스템 컬렉션 (Google Stitch DESIGN.md 포맷). `npx getdesign@latest add {brand}`로 즉시 사용. MIT License
- **[Antigravity Kit](https://github.com/vudovn/antigravity-kit)** - Gemini 대상 AI 에이전트 프레임워크. Brainstorming Questioning Principles (결과 드러내는 질문, 트레이드오프 명시, 기본값 제공), 우선순위 기반 검증 파이프라인 (`checklist.sh` 영감). MIT License
- **[oh-my-agent](https://github.com/first-fluke/oh-my-agent)** - 멀티 에이전트 하네스의 공유 프로토콜 (`_shared/`). 난이도 분기(difficulty-guide), 추론 템플릿(reasoning-templates), 컨텍스트 예산(context-budget/loading), 4요소 프롬프트(prompt-structure), Phase Gate 자동통과(phase-gates), Cascade Impact Review(multi-review-protocol), Clarification Debt(session-metrics). MIT License
- **[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)** - 자동화 훅 및 워크플로우 아이디어
- **[cc-statusline](https://www.npmjs.com/package/@chongdashu/cc-statusline)** - 상태바 구현 참고
- **[gstack](https://github.com/garrytan/gstack)** - Garry Tan의 Claude Code 스킬팩. Search Before Building 원칙(v3.1에서 **Build Ladder** 8단으로 확장), AI Slop Detection 체크리스트, LLM Security Audit Phase (프롬프트 인젝션, 스킬 서플라이 체인). MIT License
- **[everything-claude-code](https://github.com/affaan-m/everything-claude-code)** - Affaan Mustafa의 에이전트 하네스 시스템. TDD RED/GREEN Gate 워크플로우, 구조화된 Session Save (What Did NOT Work), Confidence-Based Review Filtering. MIT License
- **[mattpocock/skills](https://github.com/mattpocock/skills)** - Matt Pocock의 Claude Code 스킬 모음. **`/grill-with-docs`** (도메인 모델 stress-test, `CONTEXT.md` glossary + ADR 인라인 갱신)을 그대로 포팅. `grill-me`의 3대 행동 규칙(한 번에 한 질문 / 추천답 동반 / 코드 우선 탐색)은 기존 `/brainstorm`에 흡수됨. MIT License (Copyright (c) 2026 Matt Pocock). v2.3 통합 (2026-05-20). 상세: [`NOTICE.md`](NOTICE.md)
- **[ponytail](https://github.com/DietrichGebert/ponytail)** - "가장 게으른 시니어 개발자" 플러그인. **개념 2건만 차용, 코드는 미포함** — (1) Decision Ladder의 순서화된 조기 종료 구조(특히 rung 0 "존재할 필요가 있는가"와 "래더는 문제를 *이해한 후에* 돈다"는 단서) → `PRINCIPLES.md` **Build Ladder** 표로 병합, (2) 과설계 함정 사례 → `optional/OVERENGINEERING_TRAPS.md` 신규. 훅 11개·항시 주입·`ponytail:` 부채 마커·6개 스킬은 v3.0 감량 기조 및 기존 배선과 충돌하여 **의도적으로 제외**. 원본 벤치마크 수치("54% less code" 등)는 Haiku 4.5 단일 모델 n=4 기준이라 인용하지 않음. MIT License. v3.1 통합 (2026-08-11). 제외 사유 상세: [`NOTICE.md`](NOTICE.md)
- **Business Panel** - 클래식 비즈니스 문헌 기반 전문가 패널 방법론 (Christensen, Porter, Drucker 등)

### What's New in v2.0

SuperClaude++ v2.0 = v0.x + 시스템 강제 패러다임:
- **Skill Auto-Activation**: `skill-rules.json` + `UserPromptSubmit` 훅으로 스킬 자동 트리거
- **AGENT.md Frontmatter**: model, tools, maxTurns, effort, isolation 선언적 정의
- **Circuit Breaker**: 동일 에러 3회 반복 시 기계적 자동 차단
- **Prompt Injection Scanner**: MCP 응답 실시간 보안 스캔
- **Worktree Isolation**: 병렬 에이전트 Git worktree 격리 실행
- **Generator+Validator 패턴**: 생성/검증 관심사 분리 에이전트 쌍
- **Agent Teams**: 팀 단위 자율 작업 지원 (실험적)
- **Dynamic Context Injection**: 스킬에 실시간 상태 주입
- **Plugin Manifest**: `/plugin install`로 설치 자동화
- **140개 Skills**: commands/ 통합으로 단일 디렉토리 체계 (v2.1: Impeccable 18개 추가, v2.3: `/grill-with-docs` 추가)
- **23개 Agents**: Generator, Validator, Harness Worker, Team 에이전트 추가
- **16개 Hook Types**: TaskCompleted, FileChanged, ConfigChange 등 전체 활용
- **신규 스킬**: `/fix-pr` (PR 코멘트 자동 수정), `/config-doctor` (설정 검증)
- **v2.2 `/goal` 통합**: Claude Code 2.1.139 빌트인 자율 루프를 SC++ 워크플로우에 위임. Persistence Enforcement를 네이티브로 단순화하되 Circuit Breaker · Verification Iron Law · Two-Stage Review 3중 안전망은 유지. 상세: `optional/GOAL_PATTERNS.md`
- **v2.3 `/grill-with-docs` 통합**: 기존 도메인 모델 stress-test 스킬 신규 (MIT, mattpocock/skills). 1대1 인터뷰 + 추천답 동반 + 코드 우선 탐색으로 용어와 결정을 코드와 정렬하고 `CONTEXT.md` / ADR을 인라인 갱신. `/brainstorm`(새 기능 탐색)과 역할 분리. 루트 `CONTEXT.md`에 우리 프로젝트 자체 어휘 사전 작성. 출처는 [`NOTICE.md`](NOTICE.md)에 추적.

### What's New in v3.0

v3.0 = "모델이 못 하는 것만 남긴다" (harness-aware slim):
- **상시 로드 -66%**: @import 4개(RULES/PRINCIPLES/MODES/CONVENTIONS)로 축소, 8,994 → 3,023 단어
- **스킬 139 → 60**: 주제 가이드 51개 + 범용 래퍼 28개 삭제 — 모델 네이티브 지식의 재포장은 순비용
- **에이전트 23 → 9**: 범용 페르소나 삭제, 프레임워크 배선/고유 실행 구성 보유분만 잔존
- **skill-matcher 오탐 수정**: stdin JSON 파싱, ASCII 단어 경계, 홈 디렉터리 스캔 가드
- **KNOWLEDGE.md 제거**, FLAGS/CONTEXTS/MCP_SERVERS는 `optional/`로 이동
- 하네스가 이미 보장하는 규칙(Verification Iron Law, Persistence, Scope Discipline 등)의 재규정 삭제 — 개념은 `CONTEXT.md` 어휘 사전에 존속

### What's New in v3.1
- **Build Ladder**: gstack 유래 Search Before Building을 **8단(rung 0–7) 조기 종료 표**로 재작성. rung 0 "존재할 필요가 있는가"(YAGNI) 신설, 기존 Layer 1/2/3는 rung 5/6/7로 편입. v3.0 감량 기조를 지켜 **상시 로드는 표만(+12줄)**, 적용 규칙 3종(ordering rule / scope limit / no-compression)은 `optional/`로 분리
- **`optional/OVERENGINEERING_TRAPS.md` 신규**: rung 3 "네이티브 플랫폼 기능" 사례 카탈로그 — HTML·CSS·JS stdlib·Python stdlib·백엔드 5개 영역 대응표, "라이브러리가 정답인 경우" 역함정 5조건, 측정 한계 명시
- **디버깅 제외 명문화**: 최소 diff 편향은 증상 패치를 유발하므로 래더를 root-cause 조사에 적용하지 않는다. root-cause-first는 v3.0에서 하네스 보장 항목으로 승격됐으므로 규칙 재진술 대신 래더 쪽에 scope limit을 둠
- 스킬 0개 추가, 훅 0개 추가 — 문서 재작성만 (착안: ponytail, MIT, 개념만)

### What's Carried from v0.x
- PDCA 워크플로우 및 Gap Analysis
- Orchestrator/Worker 패턴 및 에이전트 에러 복구
- Proactive Suggestion (스킬/에이전트/MCP 적극 제안)
- Auto Memory 활용 (Claude Code 내장 기능)
- Two-Stage Review, Verification Iron Law, 3+ Fixes Rule
- oh-my-agent 프로토콜 (난이도 분기, 추론 템플릿, 컨텍스트 예산)
- Karpathy Guidelines (가정 투명성, 수술적 변경, 코드 단순성)
- Harness Engineering (Agent Struggle Report, Dependency Flow, codebase-gc)
- Note 시스템, UI/UX Pro Max, peon-ping 사운드 알림
- gstack 통합 (Search Before Building, AI Slop Detection, LLM Security Audit)
- ECC 통합 (TDD RED/GREEN Gate, Session Save, Confidence-Based Review Filtering)
- 패키지 관리 규칙 강제 (uv/pnpm)
- 한국어 응답 지원 (config/skill 파일은 영어 - 토큰 효율 30-40% 향상)

## 참고 출처 (v2.0)

v2.0의 설계와 기능은 다음 소스에서 영감을 받았습니다:

### 커뮤니티 생태계
- **[awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** — Claude Code 생태계 큐레이션 리스트. 생태계 분석의 출발점.
- **[Claude Code Infrastructure Showcase](https://github.com/diet103/claude-code-infrastructure-showcase)** — Hook 기반 Skill Auto-Activation 패턴 (`skill-rules.json` 설계의 핵심 참조)
- **[Trail of Bits Security Skills](https://github.com/trailofbits/skills)** — Static analysis 통합, injection 방어 패턴 참조
- **[cc-devops-skills](https://github.com/akin-ozer/cc-devops-skills)** — Generator + Validator 쌍 패턴 참조
- **[Ralph for Claude Code](https://github.com/frankbria/ralph-claude-code)** — Circuit Breaker 패턴 참조
- **[Superpowers](https://github.com/obra/superpowers)** — Subagent-Driven Development, Two-Stage Review 패턴 참조
- **[Compound Engineering Plugin](https://github.com/EveryInc/compound-engineering-plugin)** — Compound Learning 루프 참조
- **[Dippy](https://github.com/ldayton/Dippy)** — AST 기반 auto-approve 패턴 참조
- **[parry](https://github.com/vaporif/parry)** — Prompt injection scanner 설계 참조
- **[Fullstack Dev Skills](https://github.com/jeffallan/claude-skills)** — `/common-ground` (가정 표면화) 패턴 참조

### 공식 Claude Code 기능 (2026년 5월 기준)
- **AGENT.md Frontmatter** — `model`, `tools`, `maxTurns`, `effort`, `isolation` 시스템 강제
- **Agent Teams** (실험적) — 팀원 간 직접 메시징, 공유 태스크 리스트
- **Worktree Isolation** — 서브에이전트별 독립 git checkout
- **Dynamic Context Injection** — `!` backtick 구문으로 스킬에 실시간 상태 주입
- **Effort Level** — `low`, `medium`, `high`, `max` 노력 수준 시스템
- **26 Hook Types** — TaskCompleted, SubagentStop, FileChanged, ConfigChange 등
- **Plugin System** — `plugin.json` manifest, `/plugin install` 배포
- **WebFetch/WebSearch** — 내장 웹 도구 활용
- **`/batch` Built-in Skill** — 대규모 병렬 변경 오케스트레이션
- **[`/goal` Command](https://code.claude.com/docs/en/goal)** (v2.1.139, 2026-05-12) — 검증 가능한 종료 조건 기반 자율 멀티턴 루프. SC++ v2.2에서 Persistence Enforcement 위임 대상으로 통합

## License

MIT License - see [LICENSE](LICENSE) for details.
