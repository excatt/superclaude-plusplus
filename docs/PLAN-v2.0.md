# SuperClaude++ v2.0 Migration Plan

## Vision

```
v0.x: "Claude야, 이 규칙 읽고 따라줘"  (prompt-dependent)
v2.0: "시스템이 규칙을 강제한다"         (system-enforced)
```

**태그라인**: Harness Engineering이 자기 자신에게 적용되는 프레임워크

---

## Decisions Log

| 질문 | 결정 |
|------|------|
| skill-rules.json 위치 | 프로젝트(`.claude/`)에서 개발, 완료 후 전역(`~/.claude/`)에 설치 |
| commands/ 58개 처리 | skills/로 전부 통합 (skill 우선 원칙). commands/ 디렉토리 삭제 |
| BUSINESS_PANEL 파일 | optional/로 이동 |
| install.sh | 삭제. Plugin manifest로 대체 |
| Agent Teams | 별도 Phase가 아니라 Phase 3에 같이 포함 |

---

## Breaking Changes Summary

| 영역 | v0.x | v2.0 |
|------|------|------|
| 에이전트 정의 | 프롬프트 텍스트 (agents/*.md) | AGENT.md frontmatter (model, tools, maxTurns, effort, isolation) |
| 스킬 구조 | commands/ (82개) + skills/ (37개) 분리 | **skills/ 단일 디렉토리 (~118개)**, commands/ 삭제 |
| 스킬 트리거 | CLAUDE.md 키워드 테이블 | `skill-rules.json` + `UserPromptSubmit` hook |
| 스킬 컨텍스트 | 정적 텍스트 | Dynamic Context Injection (`` !`command` ``) |
| 병렬 작업 | 프롬프트 "background로" | Worktree 격리 + `/batch` + Agent Teams |
| 검증 자동화 | "리뷰해줘" 요청 | `TaskCompleted` hook → auto Two-Stage Review |
| 안전장치 | 3회 실패 규칙 (Claude 판단) | Circuit breaker hook (기계적 중단) |
| 배포 | `install.sh` 수동 복사 | Plugin manifest (`/plugin install`). install.sh 삭제 |
| 난이도→성능 | 없음 | Effort Level 자동 매핑 (Simple→low, Complex→high) |
| BUSINESS_PANEL | root에 산재 | optional/로 이동 |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  CLAUDE.md (Entry Point)              │
│  Language, Workflow, Memory — 변경 최소화              │
└───────────────┬─────────────────────────────────────┘
                │
    ┌───────────┴───────────┐
    │                       │
    ▼                       ▼
┌──────────┐        ┌──────────────┐
│ RULES.md │        │ skill-rules  │  ← NEW: 기계적 트리거
│ (행동)    │        │   .json      │
└──────────┘        └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ agents/  │ │ skills/  │ │ scripts/ │
        │ AGENT.md │ │ SKILL.md │ │ hooks    │
        │ +front-  │ │ +dynamic │ │ +circuit │
        │  matter  │ │  context │ │  breaker │
        └──────────┘ └──────────┘ └──────────┘
              │            │            │
              └────────────┼────────────┘
                           ▼
                    ┌──────────────┐
                    │  Worktree    │  ← NEW: 격리된 병렬 실행
                    │  Isolation   │
                    └──────────────┘
```

---

## Phase 1: Core Foundation

**목표**: 에이전트와 스킬의 기반을 prompt-dependent → system-enforced로 전환
**예상 변경**: 30+ 파일, 아키텍처 변경

### 1.1 AGENT.md Frontmatter 전환 (18개 에이전트)

현재 에이전트는 기본 frontmatter만 있음:
```yaml
# 현재 (v0.x)
---
name: backend-architect
description: Design reliable backend systems...
category: engineering
---
# ... 프롬프트 텍스트 ...
```

v2.0에서는 공식 AGENT.md frontmatter 전체 활용:
```yaml
# v2.0
---
name: backend-architect
description: Design reliable backend systems with focus on data integrity, security, and fault tolerance
model: opus
tools: Read, Grep, Glob, Write, Edit, Bash, WebFetch
disallowedTools: Agent
maxTurns: 20
effort: high
memory: project
skills: [api-design, db-design, security-audit]
---
# ... 프롬프트 텍스트 (간소화) ...
```

#### 에이전트별 설정 매트릭스

| Agent | model | effort | maxTurns | isolation | tools 제한 | skills |
|-------|-------|--------|----------|-----------|-----------|--------|
| `backend-architect` | opus | high | 20 | - | +WebFetch, -Agent | api-design, db-design |
| `frontend-architect` | sonnet | high | 15 | - | -Bash(rm,kill) | react-best-practices, a11y |
| `system-architect` | opus | high | 20 | - | Read-heavy | architecture |
| `security-engineer` | opus | high | 15 | - | +WebSearch, -Write, -Edit | security-audit |
| `performance-engineer` | sonnet | high | 15 | - | +Bash(perf) | perf-optimize |
| `quality-engineer` | sonnet | medium | 15 | - | +Bash(test) | testing, verify |
| `python-expert` | sonnet | high | 20 | worktree | full | python-best-practices |
| `refactoring-expert` | sonnet | high | 20 | worktree | full | refactoring, clean-code |
| `deep-research-agent` | opus | max | 25 | - | +WebFetch, +WebSearch, -Write | - |
| `root-cause-analyst` | opus | high | 15 | - | Read-only + Bash(read) | debug |
| `codebase-gc` | haiku | medium | 10 | - | Read, Grep, Glob only | audit |
| `pm-agent` | sonnet | medium | 10 | - | Read, Grep, Write | - |
| `technical-writer` | sonnet | medium | 15 | - | Read, Grep, Write | - |
| `requirements-analyst` | sonnet | medium | 10 | - | Read, Grep, WebSearch | - |
| `devops-architect` | sonnet | high | 15 | - | +Bash, +WebFetch | docker, cicd |
| `learning-guide` | haiku | low | 10 | - | Read only | - |
| `socratic-mentor` | sonnet | medium | 10 | - | Read only | - |
| `business-panel-experts` | opus | high | 15 | - | Read, WebSearch | - |

**핵심 원칙**:
- Read-only 에이전트에는 Write/Edit 비허용 → 실수 방지
- Research 에이전트에는 WebFetch/WebSearch 추가
- 구현 에이전트에만 worktree 격리
- codebase-gc는 haiku로 비용 절감

### 1.2 Dynamic Context Injection

현재 스킬은 정적 텍스트만 제공. v2.0에서는 `` !`command` `` 구문으로 실시간 상태 주입.

**적용 대상 스킬**:

| 스킬 | 주입할 컨텍스트 |
|------|----------------|
| `/verify` | `` !`git diff --stat` ``, `` !`git status --short` `` |
| `/confidence-check` | `` !`cat package.json \| jq '.dependencies' 2>/dev/null` `` |
| `/tdd` | `` !`git log --oneline -3` `` (최근 red/green/refactor 커밋 확인) |
| `/build-fix` | `` !`cat .claude/state/last-build-error.log 2>/dev/null` `` |
| `/checkpoint` | `` !`git stash list` ``, `` !`git log --oneline -5` `` |
| `/audit` | `` !`ls .claude/audit-rules/ 2>/dev/null` `` |
| `/security-audit` | `` !`cat package.json \| jq '.dependencies' 2>/dev/null` `` |
| `/code-review` | `` !`git diff --name-only HEAD~1` `` |

### 1.3 Effort Level ↔ 난이도 매핑

RULES.md의 난이도 평가(Step 0)를 공식 Effort Level과 연동:

```
┌─────────────┐     ┌──────────────┐
│ Step 0:     │     │ Effort Level │
│ 난이도 평가  │ ──→ │ 자동 설정     │
└─────────────┘     └──────────────┘

Simple  → effort: low    (빠른 응답, 최소 분석)
Medium  → effort: medium (기본값, 균형)
Complex → effort: high   (심층 분석)
Complex + --ultrathink → effort: max (Opus 전용, 현재 세션)
```

RULES.md에 매핑 규칙 추가, MODES.md에서 참조.

### 1.4 WebFetch/WebSearch 활성화

현재 사용하지 않는 내장 도구를 research 계열에 활성화:

**변경 파일**:
- `agents/deep-research-agent.md` → tools에 WebFetch, WebSearch 추가
- `agents/security-engineer.md` → tools에 WebSearch 추가
- `agents/requirements-analyst.md` → tools에 WebSearch 추가
- `skills/confidence-check/SKILL.md` → Check 3, 4에서 WebFetch/WebSearch 직접 사용
- `optional/MODE_DeepResearch.md` → WebSearch 우선 사용 명시

### 1.5 commands/ → skills/ 통합

**가장 큰 기계적 작업**. 82개 command 파일을 skills/ 형식으로 변환.

#### 변환 규칙

**A. commands/*.md (55개, frontmatter 없음)**
```
# 현재: commands/debug.md
# Debug Skill
체계적 디버깅을 위한...

# 변환 후: skills/debug/SKILL.md
---
name: debug
description: 체계적 디버깅을 위한 구조화된 접근법. 에러 분석, 스택 트레이스 추적, 가설 검증.
user-invocable: true
argument-hint: [error-description]
---
# Debug Skill
체계적 디버깅을 위한...
```

**B. commands/sc/*.md (27개, frontmatter 있음)**
```
# 현재: commands/sc/analyze.md
---
name: analyze
description: "Comprehensive code analysis..."
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# 변환 후: skills/analyze/SKILL.md (또는 sc-analyze)
---
name: analyze
description: "Comprehensive code analysis across quality, security, performance, and architecture"
user-invocable: true
argument-hint: [target] [--focus quality|security|performance|architecture]
---
```

**C. 중복 처리 (1개: security-audit)**
- `commands/security-audit.md` 내용을 `skills/security-audit/SKILL.md`에 머지
- command 버전은 삭제

#### 네이밍 충돌 방지

sc/ 명령어는 이름 앞에 `sc-` 접두사 없이 그대로 사용.
이유: 공식 Claude Code에서는 `skills/analyze/SKILL.md` → `/analyze`로 자동 등록.
기존 commands/sc/ 접두사(`/sc:analyze`)는 v2.0에서 폐기, `/analyze`로 통합.

#### 작업 순서 (병렬화 가능)

| 배치 | 대상 | 수량 | 처리 |
|------|------|------|------|
| Batch 1 | commands/*.md (domain knowledge) | 55개 | 에이전트 병렬 변환 |
| Batch 2 | commands/sc/*.md (SC commands) | 27개 | 에이전트 병렬 변환 |
| Batch 3 | 중복 머지 + 검증 | 1개 | 수동 |
| Batch 4 | commands/ 디렉토리 삭제 | - | 최종 정리 |

### 1.6 BUSINESS_PANEL 파일 이동

| 파일 | 이동 |
|------|------|
| `BUSINESS_PANEL_EXAMPLES.md` | → `optional/BUSINESS_PANEL_EXAMPLES.md` |
| `BUSINESS_SYMBOLS.md` | → `optional/BUSINESS_SYMBOLS.md` |
| `RESEARCH_CONFIG.md` | → `optional/RESEARCH_CONFIG.md` |

### 1.7 Core Docs 정리

v2.0에서 불필요해지는 문서 영역:

| 파일 | 변경 |
|------|------|
| `CLAUDE.md` | Auto-Invoke 키워드 테이블 → `skill-rules.json` 참조로 교체 |
| `RULES.md` | Agent Model Selection 섹션 → AGENT.md frontmatter로 이관 |
| `RULES.md` | Effort Level 매핑 섹션 추가 |
| `FLAGS.md` | `--model` 플래그 설명 → AGENT.md frontmatter 우선 명시 |
| `.superclaude-metadata.json` | version → "2.0.0", 구조 업데이트 |

---

## Phase 2: Automation Layer

**목표**: 규칙 실행을 Claude 판단 → 기계적 강제로 전환
**의존**: Phase 1 완료 필요

### 2.1 Skill Auto-Activation System

#### 2.1.1 `skill-rules.json` 설계

```jsonc
// .claude/skill-rules.json
{
  "version": "2.0",
  "rules": [
    // Auto-invoke (확인 없이 즉시 실행)
    {
      "skill": "build-fix",
      "mode": "auto",
      "triggers": {
        "prompt_patterns": ["error TS\\d+", "Build failed", "빌드 에러", "컴파일 에러"],
        "exit_codes": [1],
        "file_patterns": ["*.ts", "*.tsx", "*.js", "*.jsx"]
      },
      "cooldown": 300
    },
    {
      "skill": "confidence-check",
      "mode": "auto",
      "triggers": {
        "prompt_patterns": ["구현", "만들어", "implement", "create", "build"],
        "conditions": ["difficulty >= medium"]
      },
      "cooldown": 0
    },
    {
      "skill": "tdd",
      "mode": "suggest",
      "triggers": {
        "prompt_patterns": ["버그", "fix", "고쳐", "수정해", "테스트"],
        "conditions": ["tests_dir_exists"]
      },
      "message": "TDD 워크플로우로 진행할까요? (Y/n)"
    },
    {
      "skill": "checkpoint",
      "mode": "auto",
      "triggers": {
        "prompt_patterns": ["리팩토링", "삭제", "refactor", "delete", "대규모"],
        "conditions": ["estimated_files >= 10"]
      }
    },
    {
      "skill": "react-best-practices",
      "mode": "auto",
      "triggers": {
        "prompt_patterns": ["리뷰", "review"],
        "file_patterns": ["*.jsx", "*.tsx"]
      },
      "cooldown": 600
    },
    {
      "skill": "python-best-practices",
      "mode": "auto",
      "triggers": {
        "prompt_patterns": ["리뷰", "review"],
        "file_patterns": ["*.py"]
      },
      "cooldown": 600
    },
    {
      "skill": "security-audit",
      "mode": "suggest",
      "triggers": {
        "prompt_patterns": ["보안", "security", "JWT", "auth", "로그인"],
        "file_patterns": ["**/auth/**", "**/middleware/**", "**/security/**"]
      },
      "message": "보안 감사를 실행할까요? (Y/n)"
    },

    // Proactive suggestions
    {
      "skill": "code-smell",
      "mode": "suggest",
      "triggers": {
        "conditions": ["function_lines >= 50"]
      },
      "message": "50줄+ 함수 감지. /code-smell 실행? (Y/n)"
    },
    {
      "skill": "debug",
      "mode": "auto",
      "triggers": {
        "prompt_patterns": ["pytest FAILED", "test failed", "테스트 실패"]
      }
    }
  ],

  // Global settings
  "settings": {
    "suggestion_level": "all",
    "max_auto_per_session": 10,
    "rejected_skills_cooldown": -1
  }
}
```

#### 2.1.2 `skill-matcher.py` (UserPromptSubmit hook)

```
UserPromptSubmit hook
    │
    ├─ stdin으로 프롬프트 수신
    ├─ skill-rules.json 로드
    ├─ 패턴 매칭 (regex + file context)
    ├─ 조건 평가 (difficulty, file count 등)
    ├─ cooldown 체크 (중복 실행 방지)
    │
    ├─ mode: "auto" → stdout에 스킬 호출 컨텍스트 주입
    ├─ mode: "suggest" → stdout에 제안 메시지 주입
    └─ mode: "silent" → 로그만 기록
```

### 2.2 Hook 기반 자동 검증

#### 2.2.1 TaskCompleted → Two-Stage Review

```json
// settings.json 추가
{
  "hooks": {
    "TaskCompleted": [{
      "matcher": "*",
      "hooks": [{
        "type": "prompt",
        "prompt": "이 task의 결과를 Two-Stage Review로 검증하세요. Stage 1: Spec Compliance, Stage 2: Code Quality."
      }]
    }]
  }
}
```

#### 2.2.2 SubagentStop → 결과 품질 게이트

```json
{
  "hooks": {
    "SubagentStop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "python3 ~/.claude/scripts/subagent-quality-gate.py",
        "timeout": 5000
      }]
    }]
  }
}
```

#### 2.2.3 FileChanged → 보안 경고

```json
{
  "hooks": {
    "FileChanged": [{
      "matcher": ".env*",
      "hooks": [{
        "type": "command",
        "command": "echo '⚠️ .env 파일 변경 감지. 커밋에 포함되지 않도록 주의하세요.'"
      }]
    }]
  }
}
```

#### 2.2.4 ConfigChange → 설정 유효성 검증

```json
{
  "hooks": {
    "ConfigChange": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "python3 ~/.claude/scripts/config-validator.py",
        "timeout": 3000
      }]
    }]
  }
}
```

### 2.3 Circuit Breaker

`Stop` hook에 circuit breaker 내장:

```bash
# scripts/circuit-breaker.sh
# 동일 에러 패턴 3회 반복 → 자동 중단 + Struggle Report 트리거
```

동작:
1. Stop hook에서 에러 패턴 추출
2. `.claude/state/error-history.log`에 기록
3. 동일 패턴 3회 감지 → `{"decision":"block"}` 반환
4. Claude에게 "Architecture Alert: 3회 동일 에러. /debug 또는 아키텍처 리뷰 필요" 주입

현재 RULES.md의 "3+ Fixes Architecture Rule"을 **기계적으로 강제**.

### 2.4 InstructionsLoaded Hook

프로젝트별 설정 자동 적용:

```json
{
  "hooks": {
    "InstructionsLoaded": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "python3 ~/.claude/scripts/project-context-loader.py",
        "timeout": 3000
      }]
    }]
  }
}
```

프로젝트의 `.claude/project-config.json` 읽어서 난이도 기본값, 스킬 우선순위 등 자동 설정.

---

## Phase 3: Parallel Execution

**목표**: 안전한 병렬 작업 기반 구축
**의존**: Phase 1 완료 필요

### 3.1 Worktree 격리 패턴

#### Harness Mode IMPLEMENT 단계

```yaml
# agents/harness-worker.md (NEW)
---
name: harness-worker
description: Harness Mode의 IMPLEMENT 단계 워커. Worktree에서 격리 실행.
model: sonnet
effort: high
isolation: worktree
background: true
tools: Read, Grep, Glob, Write, Edit, Bash
maxTurns: 30
skills: [verify]
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      type: command
      command: "~/.claude/scripts/type-check.sh"
---
```

#### --delegate 패턴

```
Orchestrator (main context)
    │
    ├─ Agent(isolation: worktree, model: sonnet) → Feature A
    ├─ Agent(isolation: worktree, model: sonnet) → Feature B
    └─ Agent(isolation: worktree, model: sonnet) → Feature C
    │
    └─ Merge results → Two-Stage Review
```

### 3.2 Generator + Validator 에이전트 쌍

```yaml
# agents/generator.md (NEW)
---
name: generator
description: 코드/설정 생성 전문. Validator와 쌍으로 동작.
model: sonnet
effort: medium
isolation: worktree
background: true
tools: Read, Grep, Glob, Write, Edit, Bash
maxTurns: 20
---

# agents/validator.md (NEW)
---
name: validator
description: Generator 출력 검증 전문. Read-only로 동작.
model: sonnet
effort: medium
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit, Agent
maxTurns: 10
---
```

워크플로우:
```
Generator (worktree) → 생성 완료 → Validator (검증) → Pass/Fail → 수정/완료
```

### 3.3 Agent Teams 통합

**상태**: 실험적 기능이지만, SuperClaude의 Orchestrator/Worker 패턴과 자연스럽게 맞음.

#### 활성화

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

#### Harness Mode Team 구성

```
Team Lead (Orchestrator)
    │
    ├─ Teammate: implementer (worktree)
    │   └─ skills: [verify, tdd]
    │   └─ model: sonnet
    │
    ├─ Teammate: reviewer
    │   └─ skills: [code-review, security-audit]
    │   └─ tools: Read-only
    │   └─ model: opus
    │
    └─ Teammate: tester
        └─ skills: [pytest-runner, verify]
        └─ model: sonnet
```

#### Bugfix Team 구성

```
Team Lead (root-cause-analyst)
    │
    ├─ Teammate: reproducer (worktree)
    │   └─ skills: [tdd, debug]
    │
    └─ Teammate: fixer (worktree)
        └─ skills: [build-fix, verify]
```

#### Feature Team 구성

```
Team Lead (requirements-analyst)
    │
    ├─ Teammate: planner
    │   └─ skills: [feature-planner, architecture]
    │
    ├─ Teammate: implementer-1 (worktree)
    │   └─ 모듈 A 담당
    │
    ├─ Teammate: implementer-2 (worktree)
    │   └─ 모듈 B 담당
    │
    └─ Teammate: qa
        └─ skills: [verify, security-audit]
```

#### 팀 에이전트 정의

```yaml
# agents/team-implementer.md (NEW)
---
name: team-implementer
description: Agent Teams 환경에서 구현 담당. Worktree 격리 필수.
model: sonnet
effort: high
isolation: worktree
tools: Read, Grep, Glob, Write, Edit, Bash
maxTurns: 30
skills: [verify, tdd]
---
```

```yaml
# agents/team-reviewer.md (NEW)
---
name: team-reviewer
description: Agent Teams 환경에서 코드 리뷰 담당. Read-only.
model: opus
effort: high
tools: Read, Grep, Glob
disallowedTools: Write, Edit, Bash, Agent
maxTurns: 10
skills: [code-review, security-audit]
---
```

#### MODES.md Harness Mode 업데이트

```
기존: INTENT → SCAFFOLD → IMPLEMENT → VERIFY → DELIVER
v2.0: INTENT → SCAFFOLD → TEAM(optional) → IMPLEMENT → VERIFY → DELIVER
                              │
                              ├─ Agent Teams 활성화 시: Team Lead가 자율 조율
                              └─ 비활성화 시: 기존 Subagent 패턴 유지
```

### 3.4 /batch 내장 스킬 활용

`--delegate` 플래그에서 내부적으로 `/batch` 활용:

```
사용자: "이 10개 파일에 동일 변경 적용해줘 --delegate"
    │
    ▼
Orchestrator: /batch "각 파일에 [변경사항] 적용"
    │
    ├─ Worker 1 (worktree) → file1, file2, file3
    ├─ Worker 2 (worktree) → file4, file5, file6
    └─ Worker 3 (worktree) → file7, file8, file9, file10
    │
    └─ Merge → Verify
```

---

## Phase 4: Distribution & Safety

**목표**: 설치/배포 현대화 + 보안 강화
**의존**: Phase 2, 3 완료 필요

### 4.1 Plugin Manifest

```jsonc
// plugin.json (NEW)
{
  "name": "superclaude-plusplus",
  "version": "2.0.0",
  "description": "System-enforced development framework for Claude Code",
  "author": "excatt",
  "license": "MIT",
  "components": {
    "agents": "agents/",
    "skills": "skills/",
    "hooks": "config/settings.json",
    "scripts": "scripts/"
  },
  "requires": {
    "claude-code": ">=2.1.0"
  },
  "postInstall": "scripts/post-install.sh"
}
```

설치: `/plugin install github:excatt/superclaude-plusplus`

### 4.2 Prompt Injection 방어

```json
// settings.json 추가
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "mcp__*",
      "hooks": [{
        "type": "command",
        "command": "python3 ~/.claude/scripts/injection-scanner.py",
        "timeout": 5000
      }]
    }]
  }
}
```

스캔 대상:
- MCP 응답에 숨겨진 instruction injection
- `<system>`, `<instructions>` 등의 태그
- Data exfiltration 패턴 (URL에 민감 데이터 포함)

### 4.3 Config Doctor

```yaml
# skills/config-doctor/SKILL.md (NEW)
---
name: config-doctor
description: SuperClaude++ 설정 유효성 검증. AGENT.md frontmatter, skill-rules.json, hook 경로 등 검사.
---
```

검사 항목:
- AGENT.md frontmatter 필수 필드 존재 여부
- skill-rules.json 문법 + 참조 스킬 존재 여부
- Hook 스크립트 경로 유효성
- MCP 서버 연결 상태
- `.claude/rules/`의 dead file 탐지

---

## File Change Summary

### 신규 파일

| 파일 | 용도 | Phase |
|------|------|-------|
| `.claude/skill-rules.json` | 스킬 자동 활성화 규칙 | 2 |
| `scripts/skill-matcher.py` | UserPromptSubmit hook 핸들러 | 2 |
| `scripts/circuit-breaker.sh` | 에러 반복 감지 + 자동 중단 | 2 |
| `scripts/subagent-quality-gate.py` | SubagentStop 품질 게이트 | 2 |
| `scripts/config-validator.py` | ConfigChange 유효성 검증 | 2 |
| `scripts/project-context-loader.py` | InstructionsLoaded 컨텍스트 로드 | 2 |
| `scripts/injection-scanner.py` | MCP 응답 injection 스캔 | 4 |
| `agents/harness-worker.md` | Harness Mode worktree 워커 | 3 |
| `agents/generator.md` | Generator+Validator 쌍 | 3 |
| `agents/validator.md` | Generator+Validator 쌍 | 3 |
| `skills/config-doctor/SKILL.md` | 설정 유효성 검증 | 4 |
| `skills/fix-pr/SKILL.md` | PR 코멘트 자동 수정 | 2 |
| `plugin.json` | Plugin manifest | 4 |
| `docs/PLAN-v2.0.md` | 이 문서 | 0 |
| `docs/MIGRATION-v2.0.md` | 마이그레이션 가이드 | 4 |

### 수정 파일

| 파일 | 변경 내용 | Phase |
|------|----------|-------|
| `agents/*.md` (18개) | AGENT.md frontmatter 추가 | 1 |
| `skills/verify/SKILL.md` | Dynamic Context Injection 추가 | 1 |
| `skills/confidence-check/SKILL.md` | Dynamic Context + WebFetch 활용 | 1 |
| `skills/tdd/SKILL.md` | Dynamic Context 추가 | 1 |
| `skills/build-fix/SKILL.md` | Dynamic Context 추가 | 1 |
| `skills/checkpoint/SKILL.md` | Dynamic Context 추가 | 1 |
| `skills/audit/SKILL.md` | Dynamic Context 추가 | 1 |
| `skills/security-audit/SKILL.md` | Static analysis 통합 + Dynamic Context | 1 |
| `CLAUDE.md` | Auto-Invoke 테이블 → skill-rules.json 참조 | 2 |
| `RULES.md` | Effort Level 매핑, Agent Model Selection 간소화 | 1 |
| `FLAGS.md` | Effort 플래그 추가 | 1 |
| `MODES.md` | Harness Mode worktree 업데이트 | 3 |
| `config/settings.json` | 신규 hooks 추가 (8개 이벤트) | 2 |
| `.superclaude-metadata.json` | version 2.0.0, 구조 업데이트 | 4 |
| `install.sh` | Plugin 호환 모드 추가 | 4 |
| `optional/MODE_Harness.md` | Worktree 격리 워크플로우 | 3 |
| `optional/WORKER_TEMPLATES.md` | AGENT.md frontmatter 기반 템플릿 | 1 |

### 삭제 대상

| 파일/디렉토리 | 이유 |
|--------------|------|
| `commands/` (82개 파일) | skills/로 통합 완료 후 삭제 |
| `install.sh` | Plugin manifest로 대체 |
| CLAUDE.md Auto-Invoke 키워드 테이블 | `skill-rules.json`으로 이관 |
| RULES.md Agent Model Selection 상세 표 | AGENT.md frontmatter로 이관 |

### 이동 대상

| 파일 | 이동 위치 | 이유 |
|------|----------|------|
| `BUSINESS_PANEL_EXAMPLES.md` | `optional/` | 온디맨드 로딩 |
| `BUSINESS_SYMBOLS.md` | `optional/` | 온디맨드 로딩 |
| `RESEARCH_CONFIG.md` | `optional/` | 온디맨드 로딩 |

### 신규 에이전트 (Phase 3 Agent Teams용)

| 에이전트 | 역할 |
|----------|------|
| `agents/harness-worker.md` | Harness IMPLEMENT 워커 (worktree) |
| `agents/generator.md` | Generator+Validator 생성 담당 |
| `agents/validator.md` | Generator+Validator 검증 담당 |
| `agents/team-implementer.md` | Agent Teams 구현 담당 |
| `agents/team-reviewer.md` | Agent Teams 리뷰 담당 |

---

## Implementation Order

```
Phase 1 (Core Foundation) ← 가장 큰 작업량
    │
    ├─ 1.1 AGENT.md frontmatter 전환 (18 agents)
    ├─ 1.2 Dynamic Context Injection (8+ skills)
    ├─ 1.3 Effort Level 매핑 (RULES.md + FLAGS.md)
    ├─ 1.4 WebFetch/WebSearch 활성화
    ├─ 1.5 commands/ → skills/ 통합 (82개 → ~118개) ← 가장 큰 기계적 작업
    ├─ 1.6 BUSINESS_PANEL → optional/ 이동
    └─ 1.7 Core Docs 정리
    │
    ▼
Phase 2 (Automation) ──────────── Phase 3 (Parallel + Teams)
    │                                  │
    ├─ 2.1 skill-rules.json            ├─ 3.1 Worktree 격리
    ├─ 2.2 Hook 기반 자동 검증          ├─ 3.2 Generator+Validator
    ├─ 2.3 Circuit Breaker             ├─ 3.3 Agent Teams 통합
    └─ 2.4 InstructionsLoaded          └─ 3.4 /batch 통합
    │                                  │
    └──────────────┬───────────────────┘
                   ▼
             Phase 4 (Distribution)
                   │
                   ├─ 4.1 Plugin Manifest (install.sh 삭제)
                   ├─ 4.2 Injection 방어
                   └─ 4.3 Config Doctor
```

Phase 2와 3은 **병렬 진행 가능** (독립적).

### 작업량 추정

| Phase | 파일 변경 | 핵심 작업 |
|-------|----------|----------|
| Phase 1 | ~120개 (82 변환 + 18 agent + 8 skill + docs) | commands→skills 벌크 변환이 80% |
| Phase 2 | ~10개 (신규 scripts + settings.json) | skill-matcher.py가 핵심 |
| Phase 3 | ~10개 (신규 agents + mode docs) | Agent Teams 설정이 핵심 |
| Phase 4 | ~5개 (plugin.json + install.sh 삭제) | 구조 재배치 |
| **합계** | **~145개** | |

### 병렬화 전략

Phase 1.5 (commands→skills 변환)이 전체의 56%를 차지.
**에이전트 병렬 처리로 가속**:

```
Orchestrator
    │
    ├─ Worker A (haiku): commands/a11y.md ~ commands/debug.md (14개)
    ├─ Worker B (haiku): commands/design-patterns.md ~ commands/i18n.md (14개)
    ├─ Worker C (haiku): commands/logging.md ~ commands/regex.md (14개)
    ├─ Worker D (haiku): commands/remix.md ~ commands/websocket.md (13개)
    └─ Worker E (haiku): commands/sc/*.md (27개)
```

---

## Verification Criteria

### Phase 1 완료 조건
- [ ] 18개 에이전트 모두 AGENT.md frontmatter 포함
- [ ] model, tools, maxTurns, effort 필드 모두 설정
- [ ] Dynamic Context가 적용된 스킬에서 실시간 상태 로딩 확인
- [ ] Effort Level이 난이도에 따라 자동 설정됨

### Phase 2 완료 조건
- [ ] skill-rules.json이 프롬프트 패턴 매칭으로 스킬 자동 활성화
- [ ] TaskCompleted hook에서 Two-Stage Review 자동 트리거
- [ ] Circuit breaker가 동일 에러 3회 시 자동 중단
- [ ] FileChanged hook이 .env 변경 감지

### Phase 3 완료 조건
- [ ] harness-worker가 worktree에서 격리 실행
- [ ] Generator+Validator 쌍이 생성-검증 루프 수행
- [ ] --delegate 모드에서 병렬 worktree 작업 성공

### Phase 4 완료 조건
- [ ] `/plugin install` 으로 설치 가능
- [ ] Injection scanner가 MCP 응답 스캔
- [ ] Config doctor가 설정 유효성 검증 통과

---

## Risk Assessment

| 리스크 | 확률 | 영향 | 완화 |
|--------|------|------|------|
| AGENT.md frontmatter 호환성 | 낮음 | 높음 | 단계적 전환, 기존 형식도 fallback 지원 |
| skill-matcher.py 성능 (매 프롬프트) | 중간 | 중간 | timeout 3초, 캐싱, 경량 구현 |
| Worktree 충돌 | 낮음 | 중간 | 자동 cleanup hook, 변경 없으면 자동 제거 |
| Circuit breaker 오탐 | 중간 | 낮음 | 동일 패턴만 카운트, 리셋 명령 제공 |
| Plugin 형식 변경 | 중간 | 높음 | install.sh fallback 유지 |

---

## Timeline Estimate

| Phase | 작업량 | 의존성 |
|-------|--------|--------|
| Phase 1 | 18 agents + 8 skills + 3 docs | 없음 |
| Phase 2 | 6 new scripts + settings.json | Phase 1 |
| Phase 3 | 3 new agents + mode docs | Phase 1 |
| Phase 4 | plugin.json + install 개편 | Phase 2, 3 |

---

## Resolved Decisions

| # | 질문 | 결정 | 반영 위치 |
|---|------|------|----------|
| 1 | skill-rules.json 위치 | 프로젝트(`.claude/`)에서 개발, 완료 후 전역(`~/.claude/`)에 설치 | Phase 2.1 |
| 2 | commands/ 처리 | skills/로 전부 통합 (~118개). commands/ 삭제 | Phase 1.5 |
| 3 | BUSINESS_PANEL 파일 | optional/로 이동 | Phase 1.6 |
| 4 | install.sh | 삭제. Plugin manifest(`plugin.json`)로 대체 | Phase 4.1 |
| 5 | Agent Teams | Phase 3에 통합 (실험적이지만 동시 진행) | Phase 3.3 |

## Remaining Open Questions

없음. 모든 결정 완료.

| # | 질문 | 결정 |
|---|------|------|
| 6 | `/sc:` 접두사 | 폐기. alias 없음. `/analyze`, `/brainstorm` 등으로 직접 전환 |
| 7 | Plugin marketplace | 미등록. GitHub repo(`/plugin install github:...`)로만 배포 |
